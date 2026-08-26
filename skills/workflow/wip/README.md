# wip (Claude Skill)

One board of everything in flight — open PRs, branches that never became
a PR, stray worktrees, uncommitted work, review requests, parked
handoffs — derived from git and GitHub rather than maintained by hand.

A board you have to keep up to date is the second thing you lose track
of. This one is recomputed every time it is asked for.

## Architecture

```
skills/workflow/wip/
├── SKILL.md                       # collect → classify → render → offer
├── references/
│   └── classification.md          # the three states, triggers, exclusions, WIP limit
└── scripts/
    ├── collect.sh                 # git + GitHub harvest, one JSON document
    └── package.sh                 # builds dist/wip.zip
```

## The interesting problem

Collecting is easy; discarding is the work. A repo will report dozens of
branches "ahead of main" because a squash-merged branch stays ahead
forever — its commits never literally land on the default branch. Left
in, they bury the five things that actually matter. Uncommitted files in
a repo untouched for a year are sediment, not work in progress. Linked
worktrees report the main repo's branches and PRs, so counting one as a
repo duplicates the whole board.

`collect.sh` resolves all three:

- a branch is live only if it has an open PR **or** a recent commit
  (`--branch-age`, default 21 days); the rest are counted, not listed
- uncommitted work counts only in a repo whose HEAD is recent
- linked worktrees are detected via `--git-common-dir` and reported by
  their main repo, with their own branch and dirty state

On ~100 repos this takes about 20 s and yields roughly 25 KB of JSON —
small enough to reason over in one pass.

## Performance

Two things dominate a naive implementation and both are avoided:

- **one `gh` call per repo** → two global `gh search prs` sweeps, plus
  per-repo detail calls (review state, CI) fetched in parallel and only
  for repos that actually have live PRs
- **one process per branch** → `%(ahead-behind:<base>)` in a single
  `for-each-ref`, and one `jq` invocation per repo instead of one per
  branch

Together: 71 s → 20 s on the same repo set.

## Degradation

`gh` unauthenticated or offline (`--no-github`) still produces the git
half. The skill is instructed to say which half is missing rather than
present a partial board as complete.

Session state (which sessions are still open on which branch) comes from
the host when it offers a session-management tool; where it does not, the
board is built without that column and says so.
