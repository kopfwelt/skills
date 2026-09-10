---
name: ship
description: Takes work that exists only in the working tree all the way to a
  reviewed pull request — branch, commits, push, PR, merge-conflict
  resolution, code review with inline comments and applied fixes, and
  optionally an awaited GitHub Copilot review. Use whenever someone wants
  changes shipped, a PR opened, a branch pushed, review findings addressed,
  or conflicts with the base branch resolved (including German "commit und
  push", "mach einen PR draus", "bring das raus", "Konflikte auflösen",
  "Review-Findings einbauen"). Not for merging or releasing — it stops at a
  reviewed PR.
---

# Ship

Working tree → reviewed PR, in one pass. The value is not typing the
commands; it is the decisions between them — what belongs in a commit,
which conflict you may resolve yourself, which review finding is real.

## Language

This skill is written in English. **Everything the user sees is produced
in the conversation language**: commit subjects follow the repo's
existing language, PR body and summary follow the conversation.

One exception, and it is not stylistic: **GitHub's closing keywords stay
English**. They are parsed, not read. See step 4.

## Options

Read these from the invocation; treat the rest of the input as the
description of the work.

| Option | Default | Effect |
|---|---|---|
| `--copilot` | **off** | Request a GitHub Copilot review and wait for it |
| `--comment` / `--no-comment` | **on** | Post review findings as inline PR comments |
| `--fix` / `--no-fix` | **on** | Apply review findings and commit them |
| `--no-review` | – | Skip review entirely (Copilot included); stop at the open PR |
| `--draft` | off | Open the PR as a draft |

Name the active options in one line before starting. Copilot is off by
default because waiting on a bot that may not be enabled is the one step
that can stall a run for ten minutes and return nothing.

## 1 — Check before you touch anything

Not a git repo, or nothing to ship (clean tree *and* no commits ahead of
the base) → say so and stop. Do not create an empty branch.

Read everything that will be pushed for secrets — credentials, tokens,
`.env` contents, private keys — before the first `git add`: the working
tree (`git diff`, `git diff --cached`, untracked files) **and** commits
already made but not yet pushed (`git diff origin/<base>...HEAD`). The
second half is easy to skip and is the dangerous one: work committed
locally before the skill was invoked reaches step 4 without ever having
been staged. Anything suspicious stops the run — a secret in a pushed
commit stays in the history even after the fix.

## 2 — Branch

On the default branch (`main`/`master`/`develop`) → create
`<type>/<kebab-case>` with type from `feat|fix|chore|docs|refactor`,
derived from the description or, failing that, from the actual diff. If
that name already exists, switch to it if it is the same work, otherwise
suffix it — do not let a collision abort the run. Where commits were
already made on the default branch, move it back to its upstream
(`git branch -f <default> origin/<default>`) after branching, or the user
is left with a diverged local `main` once the PR merges.

Already on a feature branch → stay on it. Never branch off a branch that
is already the work.

## 3 — Commit

Read the diff; never `git add -A` blind. Build artefacts, `.env` files and
local config stay out. Unrelated changes that happen to be in the tree get
named and left behind, not swept in — someone else's half-finished work in
your PR is the fastest way to lose a review.

Separable changes become separate commits. Conventional Commits, imperative
subject ≤ 72 characters, body explains the *why*. `CLAUDE.md`,
`AGENTS.md` and `CONTRIBUTING.md` override all of this where they disagree.

Pre-commit hooks rewrite files. Re-check status afterwards and amend if the
hook changed something.

## 4 — Push and open the PR

`git push -u origin <branch>`. A rejected push is reported, never forced —
`--force` without being asked is how someone else's commits disappear.

Check for an existing PR first — `gh pr list --head <branch> --json
number,url` — and reuse it. `gh pr create` fails on a branch that already
has one, and the second run over the same branch is the normal case, not
the exception.

Otherwise `gh pr create` against the default branch,
`.github/pull_request_template.md` as the template where it exists. Body:
**what**, **why**, **how tested** — and "not tested" is an honest answer
where nothing ran.

### Linking the issue

Where the work closes an issue, the body carries the reference on **its own
line, with an English keyword**:

```
Closes #1329
```

GitHub parses exactly three verbs and their forms — `close`/`closes`/`closed`,
`fix`/`fixes`/`fixed`, `resolve`/`resolves`/`resolved`. **A translated verb
does not work.** "Behebt #1329" is not a keyword; the `#1329` in it still
produces a cross-reference in the issue's timeline, so the issue *looks*
linked — but the PR is not in its Development sidebar and the issue does not
close on merge. That is the whole trap: the failure is invisible from the
issue, and it surfaces weeks later as a closed PR next to an open issue.

Write the German sentence as prose if it reads better, and put the keyword
line underneath it. Two mechanisms, one of which is machine-readable.

Further rules the keyword actually obeys:

- **One keyword per issue.** `Closes #12, #13` links only #12. Write
  `Closes #12` and `Closes #13`.
- **Same repository only**, unless written `Closes owner/repo#12`.
- **Closes on merge into the default branch.** A PR against a release branch
  gets the link but not the close.

Then verify it, because writing the keyword is not evidence that GitHub read
it:

```bash
gh pr view <PR> --json closingIssuesReferences --jq '[.closingIssuesReferences[].number]'
```

Empty while an issue was named → the keyword was not parsed. Fix the body
(`gh pr edit <PR> --body-file …`) and check again. Never fall back to asking
the user to link it by hand in the Development sidebar — that is the manual
step this exists to remove.

Issues that the PR *relates to* but does not close get a bare `#1234` in the
prose, never a keyword: a keyword on a partially addressed issue closes it
early, and reopening loses the discussion order.

## 5 — Merge conflicts

```bash
gh pr view <PR> --json mergeable,mergeStateStatus,baseRefName
```

`mergeable` is `UNKNOWN` right after a push — GitHub computes it
asynchronously. Query a few more times before concluding anything, and if
it is still `UNKNOWN`, decide locally (`git fetch origin <base>` then
`git merge-tree`) rather than reading "not `CONFLICTING`" as "clean".

Conflicting: `git fetch origin <base>` **first**, then
`git merge origin/<base>` — merge, not rebase. Without the fetch,
`origin/<base>` is whatever the last fetch left behind, and the merge
succeeds against a stale base while the PR stays conflicting. A rebase on
a pushed branch forces a force-push, and this skill does not force-push.

Resolve each file by reading both sides and keeping both intentions. Never
blanket `--ours`/`--theirs`: it resolves the conflict and silently drops
half the work. Lockfiles are the exception in the other direction — never
hand-merge them; take the base version and re-run the install command.

**Stop and ask instead of resolving** when:

- both sides changed the same logic differently and the winning intent is
  not derivable from the code
- the conflict touches migrations, schema files, or security-relevant code
- more than ~10 files conflict, or the histories have diverged far
- tests that were green fail after the merge

`git merge --abort` returns to a clean state. Use it rather than pushing a
resolution you are not sure about — a bad resolution is invisible in the
diff, because the file looks intentional either way.

## 6 — Copilot review (only with `--copilot`)

Skipped entirely with `--no-review` — a Copilot review nobody judges is
ten minutes spent on output that is then thrown away. With `--draft`, mark
the PR ready first or skip the step and say so: Copilot does not review a
draft PR, the reviewer request still succeeds, and the wait below then
burns its full timeout for nothing.

Request it, then wait in the background:

```bash
gh api repos/{owner}/{repo}/pulls/<PR>/requested_reviewers \
  -X POST -f "reviewers[]=copilot-pull-request-reviewer[bot]"
```

404 or 422 means Copilot code review is not enabled for the repo or org.
Check `gh pr view <PR> --json reviewRequests,reviews` in case a ruleset
already requested it; otherwise skip the step, say so once, and do not
retry.

Wait with a **backgrounded** condition that exits on its own — never a
foreground sleep loop, and never an unbounded watcher:

```bash
for i in $(seq 1 40); do
  gh api repos/{owner}/{repo}/pulls/<PR>/reviews \
    --jq '.[] | select(.user.login | test("copilot"; "i")) | .id' | grep -q . && exit 0
  sleep 15
done
exit 1
```

Roughly ten minutes. The non-zero exit means "not arrived", not "step
failed" — on timeout, continue without it and say so. Then read
both halves — the summary body and the inline comments:

```bash
gh api repos/{owner}/{repo}/pulls/<PR>/reviews  --jq '.[] | select(.user.login|test("copilot";"i")) | {state, body}'
gh api repos/{owner}/{repo}/pulls/<PR>/comments --jq '.[] | select(.user.login|test("copilot";"i")) | {path, line, body}'
```

## 7 — Review (unless `--no-review`)

Run the host's review capability where one exists — in Claude Code,
`/code-review <PR>` with the active `--comment` and `--fix` options. Where
none exists, review the PR diff directly against the same bar: correctness
first, then reuse and simplification. Style opinions the repo does not
already hold are not findings.

**Every finding gets judged, not applied.** This is the whole point of the
step, and it applies hardest to Copilot's, which produce reliable noise
alongside real bugs:

- real → fix it (with `--fix`)
- wrong or irrelevant → do not fix; reply in the thread with the reason
- style preference against an established repo convention → the convention
  wins

Where your review and Copilot disagree on the same line, write your call
and its reasoning into the PR. Do not silently overwrite either.

Report rather than fix: findings that change architecture, public API
surface, or the data model. Those are the user's decision, and a review
comment is not a mandate.

## 8 — Commit the fixes

Fixes are their own commits (`fix: address review findings`), never amended
into the originals — a reviewer must be able to see what the review
changed. Run tests and linters where they exist and report failures
plainly; a green claim about a suite that never ran is worse than no claim.

Push, then re-check merge state: the base may have moved while you worked.

## Report

Short, in this order: branch, commit count, PR URL · the issues the PR
closes, as GitHub confirmed them · conflicts and how they were resolved · Copilot (arrived, timed out, unavailable) with findings
accepted vs. rejected and why · your own findings by severity and what was
fixed · what is still open and needs a decision.

A failed step stops the run. Report the error, what already happened, and
the state the repo is in right now — an in-progress merge and unpushed
commits are the two that bite the next person. Never attempt the following
steps anyway.
