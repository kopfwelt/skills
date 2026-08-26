#!/usr/bin/env bash
# Works out where a handoff document belongs, creates the directory, and
# prints the path. Also prints the context the document's frontmatter
# needs, so the agent does not have to shell out three more times.
#
# Usage: new-handoff.sh <slug> [--print-only]
#   <slug>        short kebab-case topic, e.g. faq-content-blocks
#   --print-only  do not create anything, just report the path
#
# Inside a git repo the document goes to <repo>/.claude/handoffs/, which
# is durable and findable — the wip skill reports parked handoffs as open
# items. Outside a repo it goes to ~/.claude/handoffs/.
set -uo pipefail

SLUG=""; PRINT_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --print-only) PRINT_ONLY=1; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) SLUG="$1"; shift ;;
  esac
done

[ -n "$SLUG" ] || { echo "usage: new-handoff.sh <slug> [--print-only]" >&2; exit 2; }
# Normalise: transliterate first, then lowercase and dash. Slugs are
# routinely written in the conversation language, so dropping umlauts
# instead of transliterating turns "Blöcke" into "bl-cke".
SLUG=$(printf '%s' "$SLUG" | tr '[:upper:]' '[:lower:]' \
       | sed -E 's/ä/ae/g; s/ö/oe/g; s/ü/ue/g; s/ß/ss/g; s/[àáâã]/a/g; s/[èéêë]/e/g; s/[ìíîï]/i/g; s/[òóô]/o/g; s/[ùúû]/u/g; s/ç/c/g; s/ñ/n/g' \
       | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
[ -n "$SLUG" ] || { echo "slug is empty after normalisation" >&2; exit 2; }

DATE=$(date +%Y-%m-%d)

if REPO=$(git rev-parse --show-toplevel 2>/dev/null); then
  DIR="$REPO/.claude/handoffs"
  FILE="$DIR/$DATE-$SLUG.md"
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  SLUGREPO=$(git remote get-url origin 2>/dev/null \
             | sed -E 's#^.*github\.com[:/]##; s#\.git$##; s#^[^/]*@##')
  COMMIT=$(git rev-parse --short HEAD 2>/dev/null)
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
else
  REPO=""; BRANCH=""; SLUGREPO=""; COMMIT=""; DIRTY=0
  DIR="$HOME/.claude/handoffs"
  FILE="$DIR/$(basename "$PWD")-$DATE-$SLUG.md"
fi

[ "$PRINT_ONLY" = 1 ] || mkdir -p "$DIR"

# A handoff is personal working state by default. Flag the case where it
# is neither ignored nor tracked, so the choice gets made on purpose.
GITSTATUS="n/a"
if [ -n "$REPO" ]; then
  if git check-ignore -q "$FILE" 2>/dev/null; then
    GITSTATUS="ignored"
  elif git ls-files --error-unmatch "$DIR" >/dev/null 2>&1; then
    GITSTATUS="tracked"
  else
    GITSTATUS="undecided — neither gitignored nor tracked; ask whether handoffs get committed"
  fi
fi

cat <<EOF
path:      $FILE
repo:      ${SLUGREPO:-–}
branch:    ${BRANCH:-–}
commit:    ${COMMIT:-–}
dirty:     $DIRTY file(s) uncommitted
git:       $GITSTATUS
exists:    $([ -f "$FILE" ] && echo "yes — appending would overwrite; pick another slug" || echo "no")
EOF
