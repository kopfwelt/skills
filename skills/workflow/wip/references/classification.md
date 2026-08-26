# Classification rules

The board is only useful if it says the same thing twice in a row. These
rules are deterministic on purpose — apply them literally rather than
judging each item on its merits.

## The three states

Everything open is in exactly one of these. The question a state answers
is always the same: **who has the ball?**

| State | Meaning | Decided by |
|---|---|---|
| `active` | Being worked on right now | A running session, or a commit within 48 h |
| `mine` | Blocked on you | See the trigger list below |
| `theirs` | Blocked on someone or something else | Open PR, checks green or pending, no changes requested |

`theirs` is the state people forget. Without it, everything looks like a
personal backlog and the board stops being trustworthy.

## What puts an item in `mine`

Check in this order and stop at the first hit — the first hit is also
what you name as the reason:

1. PR `mergeable == "CONFLICTING"` → rebase needed
2. PR `checks == "fail"` → CI broken
3. PR `reviewDecision == "CHANGES_REQUESTED"` → rework requested
4. An entry in `reviewRequests` → someone is waiting on your review
5. PR `isDraft == true` → draft, never requested for review
6. `dirtyFiles > 0` in a repo with `recentlyActive == true` → uncommitted work
7. A `liveBranch` with `hasOpenPR == false` → commits that never became a PR
8. An entry in `handoffs` → a parked thread with a written next step

Everything else with an open PR is `theirs`.

## What is not work in progress

Kept out of the board entirely. Say the counts in one line; never list
the items unless asked.

- **`staleBranchCount`** — branches ahead of the default branch whose last
  commit predates the branch window and that have no open PR. These are
  overwhelmingly squash-merge residue: a squashed branch stays "ahead"
  forever because its commits never literally land on main. Treating them
  as work is the single fastest way to make a board unreadable.
- **`dormantRepoCount`** — repos with no live signal at all.
- **Other people's PRs** in `prDetails` — that array holds *every* open PR
  in the repos concerned, so it can enrich yours. Join it to
  `myPullRequests` on `(repo, number)`. Anything left over is not yours;
  bot PRs in particular (`dependabot`, `renovate`) get a count, not rows.
- **Worktrees whose branch has an open PR** — already on the board as
  that PR. Only worktrees without one are their own item.

## Aging

Compute against `generatedAt`, from `updatedAt` for PRs and `lastCommit`
for branches and worktrees.

- **> 14 days**: mark it. Age is the most reliable signal that something
  is stuck; it needs no opinion about the content.
- **> 30 days in `mine`**: name it as a decision — finish, hand off, or
  drop. An item nobody has touched in a month is not waiting for time.

## WIP limit

Default 5 items in `mine`. Over the limit, say so plainly, name the
oldest as the one to clear first, and do not offer to start anything new.
The limit is the point of the board; a board that reports thirty open
items without objecting has only made the pile legible.

## Ambiguity

- No `git` remote or `gh` unauthenticated: report the git half and say the
  GitHub half is missing. Do not guess PR state.
- A branch whose PR is merged but whose worktree still exists: cleanup,
  not WIP.
- Item matching no rule: `mine`, marked `unclear`. Unknown work belongs to
  you until you decide otherwise — that error is cheap, the reverse is not.
