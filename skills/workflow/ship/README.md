# ship (Claude Skill)

Work that exists only in your working tree, taken all the way to a
reviewed pull request: branch, commits, push, PR, merge-conflict
resolution, code review with inline comments and applied fixes, and
optionally an awaited GitHub Copilot review.

Typing the six commands was never the hard part. The decisions between
them are: what belongs in one commit, which conflict you may resolve
without asking, which review finding is real.

## Architecture

```
skills/workflow/ship/
├── SKILL.md                       # check → branch → commit → push → PR → conflicts → review → fix
└── scripts/
    └── package.sh                 # builds dist/ship.zip
```

No collector, no reference files: every input is one `git` or `gh` call
away, and the skill is the judgment applied to their output.

## Options

| Option | Default | Effect |
|---|---|---|
| `--copilot` | off | Request a GitHub Copilot review and wait for it |
| `--comment` / `--no-comment` | on | Post review findings as inline PR comments |
| `--fix` / `--no-fix` | on | Apply review findings and commit them |
| `--no-review` | – | Skip review entirely; stop at the open PR |
| `--draft` | off | Open the PR as a draft |

Copilot is opt-in because it is the only step that can stall a run for ten
minutes and return nothing — it is not enabled in every repo or org, and a
default that waits on a bot which may never answer makes the whole skill
feel broken.

## The interesting problem

Automating this sequence is easy. Automating it *safely* means knowing
where the agent must stop, because three of the steps are irreversible in
ways a diff does not show:

- **A secret in a pushed commit stays in the history.** So the secret scan
  happens before the first `git add`, not as a review finding afterwards.
- **A blanket conflict resolution looks intentional.** `--ours` and
  `--theirs` produce a file that reads as if someone chose it, while half
  the work is gone. So conflicts are resolved by reading both sides — and
  handed back when the winning intent is not derivable: colliding logic,
  migrations, schema, security-relevant code, or a suite that went red on
  the merge.
- **A force-push deletes someone else's commits.** So a rejected push is
  reported, never forced, and conflicts are merged rather than rebased —
  a rebase on a pushed branch would require the force-push this skill
  refuses to do.

The fourth is not irreversible, just wrong: **review findings are judged,
not applied.** Copilot in particular emits reliable noise alongside real
bugs. A finding that is wrong gets a reasoned reply in the thread instead
of a commit, a style opinion the repo does not hold loses to the
convention, and anything that would change architecture, public API or the
data model is reported rather than fixed — a review comment is not a
mandate.

## Degradation

Copilot not enabled, or slow past the ten-minute wait: the run continues
without it and says which half of the review is missing. No host review
capability (`/code-review` in Claude Code): the PR diff is reviewed
directly against the same bar. `gh` unavailable: the skill stops after the
push, with the branch pushed and the PR left to open by hand — reported,
not silently skipped.

## Scope

Ends at a reviewed PR. Merging, releasing and deploying are deliberately
outside it: those are the decisions worth making awake.
