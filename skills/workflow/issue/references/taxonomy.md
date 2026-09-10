# Taxonomy — labels and severity

The repository's existing labels always win. This file is what to reach for
when a repo has none yet, or when a finding does not map onto anything that
is there.

## The four axes

A label set stops working when it mixes questions. These four are asked
separately, and every label answers exactly one of them:

| Axis | Question | Cardinality |
|---|---|---|
| Severity | How bad is it? | **exactly 1** |
| Type | What kind of change is it? | 0–1 |
| Domain | Which concern does it belong to? | 0–n |
| Origin / status | Where did it come from, what is known about it? | 0–n |

Two severities on one issue means nobody decided. Two types means it is two
issues.

## Severity

Derived from **consequence and reach**. Not from effort — a one-line fix on
the payment path is `sev:critical`, a three-week refactor of dead code is
`sev:low`.

### `sev:critical` — act now

Money path, personal data, credentials, data loss, production down. What
these share: waiting makes it worse, and the damage is not recoverable by
shipping the fix later.

- a preview token in the delivered HTML of a published page
- registration codes that can be brute-forced unthrottled
- 76 duplicate pages indexed — half a section of the site
- a paid transaction stuck in a retry loop

### `sev:high` — concrete damage, clear path

Someone is measurably worse off, and you can name who. Or: a defect that
holds across an entire section rather than a page.

- structured data missing on all 89 articles of a section
- screen-reader users get no feedback on an async form error
- five internal links 404

### `sev:medium` — the default

A real defect with bounded damage. **A finding starts here** and moves up
only when the body names the damage. Most issues stay.

- an inconsistent URL scheme
- a redirect chain of two hops instead of one
- a missing `media-src` in a CSP that is not enforced yet

### `sev:low` — cosmetic, docs, legacy

True, worth writing down, hurts nobody today.

- a nice-to-have schema field
- an open decision with no deadline
- a legacy path nothing links to

### The failure mode

Severity inflation. Everything feels urgent while you are looking at it, and
a backlog where 80 % is `sev:high` is an unsorted backlog with extra steps.

Two guards:

1. **`sev:medium` is the starting point**, not `sev:high`.
2. **Above medium needs a sentence in the body** naming the damage and who
   takes it. If that sentence cannot be written, the label is wrong.

Ask "what happens if this ships next quarter instead of this week?" — the
answer is the severity.

## Type

At most one. It says what kind of change closes the issue, which is what a
person filtering the backlog for an afternoon of work is actually asking.

| Label | Use for |
|---|---|
| `bug` | Behaviour contradicts the intent visible in the code |
| `enhancement` | Works as intended, could do more |
| `documentation` | The code is right, what is written about it is not |
| `question` | A decision is needed before anything can be built |

A defect where the intended behaviour is itself unclear is a `question`,
not a `bug` — and the body says which decision is missing.

## Domain

As many as genuinely apply, but two is usually the honest number. The domain
is what a specialist filters on.

| Label | Scope |
|---|---|
| `security` | Secrets, authn/authz, injection, exposure |
| `correctness` | Produces wrong output — data, calculations, schema |
| `architecture` | Structure and maintainability, no user-visible defect today |
| `perf` | Load time, bundle size, query time, cost |
| `seo` | Crawling, indexing, structured data, rankings |
| `a11y` | Assistive technology, keyboard, contrast |

`correctness` next to `bug` is not redundant: `bug` is the type (a change
fixes it), `correctness` is the domain (the output is wrong). A missing
feature is a `bug` in neither sense.

## Origin and status

Where it came from, and what is known about it. These are the ones that let
you find a whole batch again in three months.

| Label | Meaning |
|---|---|
| `audit-<yyyy-mm>` | From a specific audit — one label per campaign |
| `gsc` | Finding from an external tool, named (Search Console here) |
| `verified` | Someone read the code and confirmed it |
| `duplicate` | Superseded — the surviving issue is linked in the body |

A campaign label is worth its cost: `audit-2026-09` is the only way to ask
"what did that audit find, and what is left of it" once the issues have
scattered across milestones. One per campaign, dated, never reused.

`verified` is a claim, not a formality. Leave it off for anything taken from
a report, a user or a tool without opening the file.

## Bootstrapping a fresh repository

Only after asking. Colours follow the GitHub defaults where they exist, so
`bug` and `enhancement` keep the shades people already read as bug and
feature.

```bash
gh label create "sev:critical" -c B60205 -d "Sofort handeln — Zahlungspfad, Datenschutz, Zugangsdaten"
gh label create "sev:high"     -c D93F0B -d "Hoch — konkreter Schaden, klarer Pfad"
gh label create "sev:medium"   -c FBCA04 -d "Mittel — Standardfall"
gh label create "sev:low"      -c C2E0C6 -d "Niedrig / Doku / Altlast"

gh label create "security"     -c 5319E7 -d "Sicherheitsbefund"
gh label create "correctness"  -c 1D76DB -d "Korrektheitsbefund"
gh label create "architecture" -c 0E8A16 -d "Architektur / Wartbarkeit"
gh label create "perf"         -c FEF2C0 -d "Performance / Ladezeit / Kosten"
gh label create "seo"          -c C5DEF5 -d "SEO / Crawling / Indexierung"
gh label create "a11y"         -c 0075CA -d "Barrierefreiheit"

gh label create "verified"     -c 006B75 -d "Gegen den Code nachgeprüft"
```

Descriptions in the repository's issue language — they show up in the label
picker, which is where the taxonomy is either understood or ignored.

`bug`, `enhancement`, `documentation`, `question` and `duplicate` ship with
every GitHub repository; do not recreate them.

Campaign labels are created per campaign, when the campaign starts:

```bash
gh label create "audit-2026-09" -c D4C5F9 -d "Aus dem SEO-Audit vom 10.09.2026"
```
