# issue (Claude Skill)

A finding — from a review, an audit, a user report, a tool — turned into a
GitHub issue that someone can act on: verified against the code, categorized
in the repository's own label set, given one severity, cross-referenced, and
checked against the existing issues before anything is created.

`gh issue create` was never the hard part. Whether the claim is true, whether
it is already filed, and how bad it really is — that is.

## Architecture

```
skills/workflow/issue/
├── SKILL.md                       # repo → verify → duplicates → prioritize → categorize → write → reference → create
├── references/
│   ├── taxonomy.md                # the four label axes, severity rubric, bootstrap set
│   └── anatomy.md                 # title convention, body sections, worked examples
└── scripts/
    └── package.sh                 # builds dist/issue.zip
```

No collector: every input is one `gh` or `rg` call away, and the skill is the
judgment applied to their output.

## Options

| Option | Default | Effect |
|---|---|---|
| `--repo owner/name` | derived from cwd | File into another repository |
| `--dry-run` | off | Render title, labels and body — create nothing |
| `--label a,b` | – | Extra labels on top of the derived ones |
| `--campaign <name>` | – | Shared origin label for a batch of findings |

There is deliberately no flag to skip the duplicate check.

## The interesting problem

Four failure modes, none of which is about the command:

- **The duplicate you do not find.** GitHub's issue search is token-based,
  not fuzzy — `Event-Schema` and `structured data` never find each other,
  and the same defect gets described in three vocabularies by three people.
  So the check is three passes, not one: the words of the finding, **the
  file path the fix will touch**, and the domain label. The path pass is the
  one that actually hits, because vocabularies differ and files do not. And
  closed issues are searched too: the same defect found again is a
  regression, which is a different issue than a duplicate.

- **Severity inflation.** Everything feels urgent while you are looking at
  it. A backlog where 80 % is `sev:high` is unsorted, with extra steps. Two
  guards: `sev:medium` is where a finding *starts*, and anything above it
  needs a sentence in the body naming the damage and who takes it. If that
  sentence cannot be written, the label was wrong.

- **The unverified claim in the voice of a finding.** An issue is a claim
  about a codebase, so the file gets opened, the lines get quoted, the count
  gets run. Where that is impossible — a user report, a tool's output — the
  body says so and the `verified` label stays off. "Reported, not yet
  reproduced" is a usable issue; a guess formatted like a finding costs
  someone an afternoon.

- **The secret you paste in as evidence.** Logs, URLs and screenshots carry
  tokens, session ids and customer names, and an issue outlives the private
  repo it was filed in. They come out — and the body says that they were
  removed, so the next person does not go looking for them.

The batch case has its own trap: five findings become five issues, never one
bundle. A bundle gets closed once, and the four defects nobody looked at go
with it.

## Degradation

`gh` missing or unauthenticated: reported at the start, before any work is
done against a repo that was never reachable. No GitHub remote, or several
that disagree: the skill asks which repository instead of guessing — a
correct issue in the wrong backlog is invisible. Labels missing from the
taxonomy: it asks before creating them, and files with what exists rather
than inventing a private scheme. Cause or fix genuinely unknown: filed as
open, marked as open.

## Scope

Ends at a filed issue. It does not implement, assign, prioritize a sprint or
close anything — a duplicate gets a comment on the surviving issue, never a
close.
