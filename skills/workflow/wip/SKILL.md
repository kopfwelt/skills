---
name: wip
description: Builds one board of everything you have in flight — open PRs,
  branches without a PR, stray worktrees, uncommitted work, review
  requests, parked handoffs — by deriving it from git and GitHub instead
  of from a list you maintain. Use whenever someone asks what they are
  working on, what is still open, what they forgot, where a thing stands,
  or says they have lost the overview across sessions, branches and repos
  (including German "was ist noch offen", "woran arbeite ich gerade",
  "ich verliere den Überblick", "was liegt noch rum"). Also use before
  starting something new, to check the WIP limit first.
---

# WIP

One board, derived. Nothing here is maintained by hand — a board that
needs upkeep is the second thing you lose track of.

## Language

This skill is written in English. **Everything the user sees is produced
in the conversation language**: headings, state names, reasons,
recommendations. Field names from the collector stay English — they are
data, not copy.

## 1 — Collect

```bash
scripts/collect.sh --root <dir-holding-your-repos>
```

Without `--root` it scans the parent of the current repo. Pass `--root`
more than once for several locations. Takes roughly 20 s for 100 repos;
say you are collecting before you start, then run it once. Never run it
twice in a turn — if you need different thresholds, use `--branch-age`
and `--since` on the single run.

If a session-management tool is available (Claude Code Desktop exposes
`list_sessions`), call it too and join sessions to items by `branch`,
`prNumber` or `cwd`. It is the only source for "a session is still open
on this". Where it is missing — VS Code, plain CLI — build the board
without it and say once that the session column is unavailable. Do not
substitute transcript files: their timestamps say when you last typed,
not what is unfinished.

## 2 — Classify

Read `references/classification.md` and apply it literally. It defines
three states (`active`, `mine`, `theirs`), the ordered trigger list for
`mine`, what is excluded as archaeology, and the WIP limit.

Two rules matter more than the rest:

- **`theirs` is a real state.** Anything blocked on a reviewer or on CI
  leaves your list. Collapsing it into one big pile is how a board stops
  being read.
- **Exclusions get a count, not rows.** Stale branches, dormant repos and
  bot PRs are one summary line each.

## 3 — Render

One table, grouped by state, `mine` first, oldest first within a group.
Columns: item, where, state reason, age. Link PRs by URL, paths as paths.

Then, in this order:

- **The WIP line.** Number of `mine` items against the limit. Over the
  limit, name the single oldest as the one to clear first.
- **One cleanup line.** Stale branches, dormant repos, merged-PR
  worktrees, bot PRs — as counts.
- **One next step.** Exactly one, named, with its reason. Not a ranked
  list of five: the board already shows five, and the value you add is
  choosing.

Do not open the board with an inventory of what you ran. Start with the
number of open items and the WIP verdict.

## 4 — Offer, do not act

Cleanups are the user's call, every time. Offer them as a numbered list
and wait: deleting branches, removing worktrees, archiving sessions,
closing stale PRs. Nothing on that list happens without an explicit yes,
and a yes covers only what was named.

The one thing worth pushing: an item in `mine` older than 30 days is not
waiting for time. Ask for a decision — finish, hand off, or drop.

## Honesty

Report what the collector found, including the parts it could not reach:
GitHub unauthenticated, a repo without a remote, a root that does not
exist. A board that quietly drops what it could not see is worse than no
board — it converts a gap into apparent completeness.
