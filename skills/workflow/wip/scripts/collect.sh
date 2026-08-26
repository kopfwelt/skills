#!/usr/bin/env bash
# Harvests work-in-progress state from git and GitHub into one JSON document.
# Nothing here is maintained by hand — the board is derived, never kept.
#
# The hard part is not collecting; it is discarding. A repo will happily
# report 48 branches "ahead of main" because squash-merged branches stay
# ahead forever. Those are archaeology, not work in progress, so they are
# counted rather than listed. Only live work reaches the output.
#
# Usage: collect.sh [--root DIR]... [--since DAYS] [--branch-age DAYS]
#                   [--no-github] [--all-repos]
#   --root DIR        Directory holding git repos, scanned 2 levels deep
#                     (repeatable). Default: parent of the current repo.
#   --since DAYS      Ignore PRs untouched for longer. Default 90.
#   --branch-age DAYS A branch with no open PR counts as live only if it
#                     was committed to within this window. Default 21.
#   --all-repos       Emit dormant repos too, instead of only counting them.
#   --no-github       Skip every gh call (offline or unauthenticated).
#
# Output: JSON on stdout. GitHub failures degrade to empty lists rather
# than a non-zero exit — missing gh auth must not cost you the git half.
set -uo pipefail

ROOTS=(); USE_GH=1; SINCE_DAYS=90; BRANCH_AGE=21; ALL_REPOS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOTS+=("$2"); shift 2 ;;
    --since) SINCE_DAYS="$2"; shift 2 ;;
    --branch-age) BRANCH_AGE="$2"; shift 2 ;;
    --all-repos) ALL_REPOS=1; shift ;;
    --no-github) USE_GH=0; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ ${#ROOTS[@]} -eq 0 ]; then
  if top=$(git rev-parse --show-toplevel 2>/dev/null); then
    ROOTS=("$(dirname "$top")")
  else
    ROOTS=("$PWD")
  fi
fi

command -v jq >/dev/null 2>&1 || { echo '{"error":"jq is required"}'; exit 1; }
if [ "$USE_GH" = 1 ] && ! gh auth status >/dev/null 2>&1; then USE_GH=0; fi

iso_days_ago() {
  date -u -v-"$1"d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
    || date -u -d "$1 days ago" +%Y-%m-%dT%H:%M:%SZ
}
CUTOFF=$(iso_days_ago "$SINCE_DAYS")
BRANCH_CUTOFF=$(iso_days_ago "$BRANCH_AGE")
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# --- GitHub first: two global sweeps, not one call per repo ---------------
# Open PR head refs decide which local branches count as live, so this has
# to run before the local scan.

mine='[]'; reviews='[]'; details='[]'
if [ "$USE_GH" = 1 ]; then
  gh search prs --author=@me --state=open --limit 60 \
    --json number,title,url,repository,updatedAt,createdAt,isDraft \
    > "$TMP/mine.json" 2>/dev/null || echo '[]' > "$TMP/mine.json"
  mine=$(jq -c --arg c "$CUTOFF" '[.[] | select(.updatedAt >= $c) | {
      number, title, url, updatedAt, createdAt, isDraft,
      repo: (.repository.nameWithOwner // .repository.name // "")}]' \
    "$TMP/mine.json" 2>/dev/null || echo '[]')

  gh search prs --review-requested=@me --state=open --limit 30 \
    --json number,title,url,repository,updatedAt \
    > "$TMP/rev.json" 2>/dev/null || echo '[]' > "$TMP/rev.json"
  reviews=$(jq -c --arg c "$CUTOFF" '[.[] | select(.updatedAt >= $c) | {
      number, title, url, updatedAt,
      repo: (.repository.nameWithOwner // .repository.name // "")}]' \
    "$TMP/rev.json" 2>/dev/null || echo '[]')

  # Review state and CI, only for repos that actually have live PRs and
  # fetched in parallel. This is what separates "waiting on me" from
  # "waiting on someone else", so it earns the extra round trips.
  while IFS= read -r slug; do
    [ -z "$slug" ] && continue
    (
      gh pr list --repo "$slug" --state open --limit 50 \
        --json number,reviewDecision,mergeable,isDraft,headRefName,updatedAt,statusCheckRollup \
        2>/dev/null \
      | jq -c --arg r "$slug" '[.[] | {
          repo:$r, number, reviewDecision, mergeable, isDraft, headRefName, updatedAt,
          checks: (
            if (.statusCheckRollup // []) | length == 0 then "none"
            elif [.statusCheckRollup[] | (.conclusion // .state // "")]
                 | any(IN("FAILURE","TIMED_OUT","CANCELLED","ERROR","FAILING")) then "fail"
            elif [.statusCheckRollup[] | (.conclusion // .state // "")]
                 | any(IN("","PENDING","IN_PROGRESS","QUEUED","EXPECTED")) then "pending"
            else "pass" end)}]' > "$TMP/d-${slug//\//_}.json"
    ) &
  done < <(jq -r '[.[].repo] | unique[]' <<<"$mine")
  wait
  details=$(cat "$TMP"/d-*.json 2>/dev/null | jq -sc 'add // []')
fi

# slug -> [head ref names of open PRs]
jq -c 'group_by(.repo) | map({key: .[0].repo, value: [.[].headRefName]}) | from_entries' \
  <<<"$details" > "$TMP/prheads.json" 2>/dev/null || echo '{}' > "$TMP/prheads.json"

# --- local git state (no network) -----------------------------------------

default_branch() {
  local d=$1 b
  b=$(git -C "$d" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) \
    && { echo "${b#origin/}"; return; }
  for b in main master; do
    git -C "$d" show-ref --verify --quiet "refs/heads/$b" && { echo "$b"; return; }
  done
  git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null
}

# A linked worktree shares its object store with the main repo, so
# git reports the main repo's branches and PRs from inside it. Treating
# one as a repo of its own duplicates the entire board. Emit it as a
# worktree record instead and let the main repo own it.
is_linked_worktree() {
  local g c
  g=$(git -C "$1" rev-parse --path-format=absolute --git-dir 2>/dev/null)
  c=$(git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  [ -n "$g" ] && [ -n "$c" ] && [ "$g" != "$c" ]
}

repo_json() {
  local dir=$1 name base cur dirty slug head_date
  name=$(basename "$dir")
  base=$(default_branch "$dir")
  cur=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  # Uncommitted files in a repo nobody has touched in months are sediment,
  # not work in progress. The HEAD date is what tells the two apart.
  head_date=$(git -C "$dir" log -1 --format=%cI 2>/dev/null)
  slug=$(git -C "$dir" remote get-url origin 2>/dev/null \
         | sed -E 's#^.*github\.com[:/]##; s#\.git$##; s#^[^/]*@##')

  # One git call for every branch: name, ahead/behind against the default
  # branch, last commit date. A per-branch rev-list would multiply process
  # spawns by the branch count — that is what makes naive versions of this
  # script take minutes instead of seconds.
  local branch_tsv wt_lines ho_lines
  branch_tsv=$(git -C "$dir" for-each-ref \
    --format="%(refname:short)%09%(ahead-behind:$base)%09%(committerdate:iso-strict)" \
    refs/heads 2>/dev/null)

  # Extra worktrees — a worktree left behind is work left behind. git
  # itself is the authority here: the directory scan only reaches two
  # levels and would miss the ones under .claude/worktrees/.
  local wt_json='[]' wtpath wtbranch wtdirty wtlast
  while IFS= read -r wtpath; do
    { [ -z "$wtpath" ] || [ "$wtpath" = "$dir" ]; } && continue
    [ -d "$wtpath" ] || continue
    wtbranch=$(git -C "$wtpath" rev-parse --abbrev-ref HEAD 2>/dev/null)
    wtdirty=$(git -C "$wtpath" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    wtlast=$(git -C "$wtpath" log -1 --format=%cI 2>/dev/null)
    wt_json=$(jq -c --arg p "$wtpath" --arg b "$wtbranch" \
      --argjson d "${wtdirty:-0}" --arg l "$wtlast" \
      '. + [{path:$p, branch:$b, dirtyFiles:$d, lastCommit:$l}]' <<<"$wt_json")
  done < <(git -C "$dir" worktree list --porcelain 2>/dev/null \
           | awk '/^worktree /{print $2}')

  # Handoff documents left by the companion /handoff skill.
  ho_lines=$(ls -1t "$dir"/.claude/handoffs/*.md 2>/dev/null)

  # A single jq call per repo assembles and filters the whole object.
  jq -c -n --arg path "$dir" --arg name "$name" --arg slug "$slug" \
    --arg base "$base" --arg cur "$cur" --argjson dirty "${dirty:-0}" \
    --arg branches "$branch_tsv" --argjson worktrees "$wt_json" --arg handoffs "$ho_lines" \
    --arg bcut "$BRANCH_CUTOFF" --arg headDate "$head_date" \
    --slurpfile heads "$TMP/prheads.json" \
    '
    def lines: if . == "" then [] else split("\n") | map(select(. != "")) end;
    ($heads[0][$slug] // []) as $prheads
    | ($branches | lines | map(split("\t")) | map({
        name: (.[0] // ""),
        ahead: ((.[1] // "0 0") | split(" ") | .[0] | tonumber? // 0),
        behind: ((.[1] // "0 0") | split(" ") | .[1] | tonumber? // 0),
        lastCommit: (.[2] // "")})
      | map(select(.name != $base and .ahead > 0))
      | map(. + {hasOpenPR: ([.name] | inside($prheads)),
                 recent: (.lastCommit >= $bcut)})) as $all
    | {path:$path, name:$name, slug:$slug, defaultBranch:$base,
       currentBranch:$cur, dirtyFiles:$dirty, lastCommit:$headDate,
       recentlyActive: ($headDate >= $bcut),
       liveBranches: ([$all[] | select(.hasOpenPR or .recent)]
                      | sort_by(.lastCommit) | reverse),
       staleBranchCount: ([$all[] | select((.hasOpenPR or .recent) | not)] | length),
       worktrees: $worktrees,
       handoffs: ($handoffs | lines)}'
}

: > "$TMP/repos.jsonl"
for root in "${ROOTS[@]}"; do
  [ -d "$root" ] || continue
  while IFS= read -r gitdir; do
    d=$(dirname "$gitdir")
    # Linked worktrees are reported by their main repo, never as repos
    # of their own — otherwise the whole board appears twice.
    is_linked_worktree "$d" || repo_json "$d" >> "$TMP/repos.jsonl"
  done < <(find "$root" -maxdepth 2 -name .git -print 2>/dev/null | sort)
done

# A repo is live if it has uncommitted work, a live branch, a stray
# worktree, a handoff, or an open PR of mine. Dormant repos are counted,
# not listed — a board nobody can read is not a board.
jq -sc --argjson mine "$mine" --argjson all "$ALL_REPOS" '
  map(. as $r | $r + {openPRs: [$mine[] | select(.repo == ($r.slug // " "))]})
  | map(. + {isLive: (($all == 1)
             or (.dirtyFiles > 0 and .recentlyActive)
             or (.liveBranches | length > 0) or (.worktrees | length > 0)
             or (.handoffs | length > 0) or (.openPRs | length > 0))})
  | {kept: [.[] | select(.isLive) | del(.isLive)],
     dormant: ([.[] | select(.isLive | not)] | length)}
' "$TMP/repos.jsonl" > "$TMP/filtered.json"

jq -n --arg at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg cutoff "$CUTOFF" \
      --arg bcutoff "$BRANCH_CUTOFF" \
      --argjson gh "$([ "$USE_GH" = 1 ] && echo true || echo false)" \
      --slurpfile f "$TMP/filtered.json" \
      --argjson reviews "$reviews" --argjson details "$details" \
  '{generatedAt:$at, prCutoff:$cutoff, branchCutoff:$bcutoff,
    githubAvailable:$gh,
    repos: $f[0].kept, dormantRepoCount: $f[0].dormant,
    reviewRequests:$reviews, prDetails:$details}'
