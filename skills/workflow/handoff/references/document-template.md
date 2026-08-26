# Handoff document template

Fill every section or delete it. An empty heading reads as "nothing to
report" when it usually means "not checked" — and that difference is the
whole point of the document.

Write the body in the conversation language; keep the frontmatter keys as
they are, since `wip` and other tooling read them.

```markdown
---
handoff: 1
created: 2026-08-26
repo: kopfwelt/berlin-bootsverleih-nextjs
branch: feat/content-blocks-faq
anchor: https://github.com/kopfwelt/berlin-bootsverleih-nextjs/issues/324
purpose: continue implementation
status: parked        # parked | forked | handed-over
---

# <what this work is, in one line>

## Goal

Two or three sentences. What is supposed to be true when this is done —
not what has been done so far.

## State

Where the work actually stands. Mark every claim:

- **verified** — observed in this session (test run, output seen, page
  loaded). Name how it was verified.
- **assumed** — inferred, plausible, not checked.

## Next step

Exactly one, concrete enough to start on. If the next step is a decision
rather than an action, write the decision and the options.

## Open questions

Questions whose answers change the work. Say who can answer each.

## Dead ends

What was tried and did not work, with the reason. The most valuable
section in the document — it is the only part the next agent cannot
recover by reading the repo.

## References

Paths and URLs. Never contents.

- `specs/007-slug-manifest/plan.md` — the plan this follows
- `src/lib/api.ts:120` — the fetcher in question
- PR #325, issue #324
- commit 77c0f77 — last change made here

## Suggested skills

Which skills the next agent should load, and what for. Omit the section
if none apply — a guessed skill name costs the next agent a failed
lookup.

## Not included

What was deliberately left out: secrets redacted, long output not copied,
threads judged irrelevant. Makes the gaps visible instead of letting them
look like completeness.
```

## Size

A handoff that grew past roughly two screens is carrying content it
should be referencing. Go back and replace the longest section with a
path.
