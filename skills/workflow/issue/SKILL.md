---
name: issue
summary: Turns a finding into a GitHub issue — verified, categorized,
  prioritized, cross-referenced, and checked against the existing ones first.
description: Files findings, bug reports, audit results and review notes as
  GitHub issues — with the repository's own label taxonomy, one severity, code
  references that were actually read, and a duplicate check against the open
  and closed issues before anything is created. Use whenever someone wants an
  issue opened, a bug filed, a finding written up, an audit turned into
  tickets, or something put in the backlog (including German "mach ein Issue
  draus", "leg ein Ticket an", "schreib den Befund auf", "trag das ins Backlog
  ein", "das müssen wir festhalten"). Asks which repository when none can be
  derived from the working directory.
---

# Issue

Filing is one `gh` command. Everything before it is the work: is the claim
true, is it already filed, how bad is it really, and where in the code does
it live. An issue nobody can act on is worse than no issue — it is
maintained forever and read once.

## Language

This skill is written in English. **The issue is written in the language
the repository's issues already use.** Read the last few titles
(`gh issue list --limit 10`) and follow them; a German backlog does not get
one English ticket in the middle. Labels keep their existing names in
whatever language they were created.

## Options

Read these from the invocation; the rest of the input is the finding.

| Option | Default | Effect |
|---|---|---|
| `--repo owner/name` | derived from cwd | File into another repository |
| `--dry-run` | off | Render title, labels and body — create nothing |
| `--label a,b` | – | Extra labels on top of the derived ones |
| `--campaign <name>` | – | Shared origin label for a batch of findings |

There is no option to skip the duplicate check. It is the step that makes
the difference between a backlog and a pile.

## 1 — The repository

```bash
gh auth status
gh repo view --json nameWithOwner,defaultBranchRef
```

Check `gh auth status` first: without it every later step fails one at a
time, in a way that reads like a permissions problem in the repo.

**Not a git repo, no GitHub remote, or several remotes that disagree → ask
which repository.** Never guess from a folder name, and never fall back to
"the last repo we talked about". The same applies when the finding is
clearly about code that is not in this working directory: ask.

The issue belongs where the fix will land, not where the symptom appeared.
A rendering bug caused by the CMS schema is filed against the CMS repo.

## 2 — Verify before you write

An issue is a claim about a codebase. Open the file, read the lines, quote
them. A finding that survives that gets a `file:line` reference and the
excerpt; one that does not gets rewritten or dropped.

Where the claim cannot be verified against the code — a user report, an
external tool's output, a report from another session — **say so in the
body** and leave the `verified` label off. An honest "reported, not yet
reproduced" is a usable issue. A guess written in the voice of a finding
costs someone an afternoon.

Numbers are what make it actionable. `rg --count`, a sitemap line count, an
occurrence count across the tree — cheap to produce, and they turn "some
pages" into "89 articles" and "all 155 session URLs". Put the number in the
title.

## 3 — Duplicate check — never skip

Before writing anything, three passes over **open *and* closed** issues:

```bash
gh issue list --repo <repo> --state all --limit 50 --search "<words from the finding>"
gh issue list --repo <repo> --state all --limit 50 --search "<src/path/that/gets/fixed.ts>"
gh issue list --repo <repo> --state all --limit 50 --label "<domain label>"
```

Three, because one never finds it. GitHub's search is token-based, not
fuzzy: `Event-Schema` and `structured data` do not find each other, and the
same defect gets described in three vocabularies by three people — but it
always lands in the same file, which is why the path search is the one that
actually hits. The label pass catches what neither did, because a domain
label is a list short enough to read by eye. Search the symptom *and* the
cause, and in both languages where the repo has mixed history.

Then decide:

- **Same defect** → do not create. Add the new evidence as a comment on the
  existing issue (`gh issue comment`), raise its severity label if the
  evidence justifies it, and report that link instead of a new one.
- **Same area, different defect** → create, and say in the delimitation
  section what separates them. "Also about the Event schema" is not a
  duplicate; "the same missing field" is.
- **Found closed** → a regression, not a duplicate. Create a new issue,
  link the closed one, and name what changed since it was closed.

Report "no duplicate found" only after all three passes ran. Anything less
is not a check, and saying it anyway is how a backlog acquires four issues
about one bug.

## 4 — Prioritize

Exactly one severity label, derived from **consequence and reach** — never
from how much work the fix is, and never from how annoying the bug felt.

| Severity | Applies when |
|---|---|
| `sev:critical` | Money path, personal data, credentials, data loss, production down. Act now. |
| `sev:medium` | The default. Real defect, bounded damage. |
| `sev:high` | Concrete damage with a clear path to it, or a defect across a whole section of the site. |
| `sev:low` | Cosmetic, documentation, legacy that hurts nobody today. |

The order above is deliberate: `sev:medium` is where a finding starts.
Anything above it needs a sentence in the body naming the damage and who
takes it. If every issue is `sev:high`, the label carries no information and
the backlog is unsorted again — that is the single most common way this
taxonomy dies. Full rubric with worked examples:
`references/taxonomy.md`.

## 5 — Categorize

```bash
gh label list --repo <repo> --limit 100
```

**The repository's existing labels win over anything in this skill.** Read
them first and map the finding onto what is there.

Four axes, at most one label from the first two:

| Axis | Cardinality | Examples |
|---|---|---|
| Severity | exactly 1 | `sev:critical` `sev:high` `sev:medium` `sev:low` |
| Type | 0–1 | `bug` `enhancement` `documentation` `question` |
| Domain | 0–n | `security` `correctness` `architecture` `perf` `seo` `a11y` |
| Origin / status | 0–n | `audit-2026-09` `gsc` `verified` `duplicate` |

A label that does not exist yet: **ask before creating it.** A taxonomy only
this skill uses is worse than one missing label — the next person filters by
hand and finds nothing. The canonical set, with colours and descriptions for
bootstrapping a fresh repo, is in `references/taxonomy.md`.

## 6 — Write it

Title: `<domain>: <the defect> — <the evidence that makes it concrete>`

```
seo: NewsArticle.author fehlt in allen 89 /news/-Artikeln — Extraktion existiert bereits
perf: GTM + gtag laden 300 KB (141 KB ungenutzt) — Haupttreiber des Desktop-TBT von 370 ms
```

The defect, not the fix: a title reading "add author field" hides whether it
is done. Present tense, the number in the title, no severity words in it —
`critical` and `urgent` are the label's job and read as shouting in a list.
Roughly 100 characters; everything after the em dash is what makes someone
open it.

Body — these sections, in this order, using only the ones that carry
content:

**Symptom** · **Reproduction** · **Cause** (`file:line` + excerpt) ·
**Impact** · **Fix** (with the alternative and its cost) ·
**Verification** (a command or check that settles it) ·
**Delimitation** (against related issues) · **provenance footer**.

Mandatory: the evidence and the provenance footer. Cause and fix may stay
open — but then say that they are open. Section-by-section anatomy with a
full worked example: `references/anatomy.md`.

## 7 — Reference

- **Code**: repo-relative with lines — `src/lib/seo/json-ld.ts:329-337` —
  *and* the excerpt. Line numbers rot with the next commit; the quoted code
  is what still identifies the spot in six months.
- **Issues**: bare `#1234`, inside a delimitation section that says how they
  differ. Never `fixes #`/`closes #` in an issue body — those keywords belong
  in a pull request and would close the wrong issue on merge.
- **External sources**: link with the date it was read. A dashboard shows
  something else next week; the date is what makes the number checkable.
- **Redact**: tokens, session ids, unsubscribe links, personal data and
  customer names out of every pasted log, URL and screenshot — **and say
  that you removed them**, so the next person does not go looking. A private
  repo is one setting away from public, and the defect almost always
  reproduces without the secret.

## 8 — Create

```bash
gh issue create --repo <repo> --title "<title>" --body-file <path> \
  --label "sev:high" --label "seo" --label "verified"
```

`--body-file` with a temp file, never `--body` with an inline string: bodies
carry backticks, `$` and newlines, and a shell-quoted body loses its code
fences — or runs them.

`--dry-run` stops here and prints title, labels and body instead.

**Several findings → one issue per defect**, filed in severity order. Cross-
reference them only once every number exists, then edit the delimitation
sections (`gh issue edit`) — the first issue cannot reference the fifth
while it is being written. A bundle issue is a trap: it gets closed once,
and the four defects nobody looked at go with it.

## Report

One line per issue: number, title, severity, labels, URL.

Then the other half, which is the valuable one: what was **not** created and
why — duplicates found and commented on instead, findings that could not be
verified, labels that need a decision, severities you were unsure about. A
run that files three issues and names two duplicates did more than one that
files five.

A failed step stops the run: report the error, which issues already exist,
and what is still unfiled. Never file the remaining ones anyway to make the
report look complete.
