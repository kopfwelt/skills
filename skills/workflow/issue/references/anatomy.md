# Anatomy — title and body

The shape an issue takes so that someone who was not in the room can act on
it a month later.

## Title

```
<domain>: <the defect> — <the evidence that makes it concrete>
```

The domain prefix lowercase and short (`seo:`, `perf:`, `security:`,
`content:`, `a11y:`). It duplicates the label on purpose: a list of titles
is what people scan, and the label is not in it.

| | |
|---|---|
| ✅ | `seo: NewsArticle.author fehlt in allen 89 /news/-Artikeln — Extraktion existiert bereits` |
| ✅ | `perf: Render-blocking CSS kostet 600 ms auf Mobil (Critical-CSS-Inlining)` |
| ❌ | `Author-Feld ergänzen` — the fix, not the defect. Reads as done once someone opens a PR. |
| ❌ | `SEO-Probleme im News-Bereich` — no defect, no number, closable by nobody. |
| ❌ | `KRITISCH: Schema kaputt!!` — severity is a label; in a list this only shouts. |

Rules that hold across all of them:

- **The defect, not the fix.** "Add X" hides whether it is done.
- **The number belongs in the title.** 89 articles, 155 pages, 300 KB,
  600 ms. It is what decides the order of work, and nobody opens 40 issues
  to find it.
- **Present tense**, indicative. It describes what is, not what should be.
- **No severity words.** That is the label's job.
- **~100 characters.** Everything after the em dash is the reason to open it,
  so put the sharpest fact there.

## Body

Only the sections that carry content. An empty "Reproduction: n/a" heading
costs a reader more than it saves.

### Symptom — what is observable

What someone sees, without interpretation. The failing URL, the wrong
number, the message. Where it was noticed, and where it was not.

### Reproduction — how to see it yourself

Commands, URLs, steps, with the outcome next to each. Include the case that
does *not* reproduce — it is half the diagnosis:

```
GET /about/whs-lancet-commission                → 200
GET /about/whs-lancet-commission?_storyblok=1   → 404
```

Note the date and the environment it was reproduced against.

### Cause — where in the code

`file:line` plus the excerpt, and one sentence on why this produces the
symptom. This is the section that turns a report into an issue.

````markdown
## Ursache — `src/proxy.ts:97-101`

```ts
if (searchParams.has("_storyblok")) {
  url.pathname = `/draft${pathname}`;
  return NextResponse.rewrite(url);
}
```

Der Rewrite feuert unabhängig vom Deploy, die Zielroute ist in Produktion
per Design deaktiviert.
````

Two components that are each correct and only fail together: say that, and
show both. A cause that is genuinely unknown is written as unknown, with
what was ruled out.

### Impact — who is worse off

Concrete, and separated by group where they differ: editors, visitors,
crawlers, on-call. This is where the severity is justified — anything above
`sev:medium` needs its sentence here.

Reach belongs here too: one page or all 155.

### Fix — the proposal, with its alternative

The preferred fix as a diff or a code block, then the alternative and why it
is second — cost, duplication, maintenance. Where a decision is genuinely
open, list the options and what each buys; do not resolve it silently by
writing only one.

Open questions the implementer will hit go here as a list, not into a
comment three months later.

### Verification — what settles it

The command, query or check that decides whether the fix worked. Written so
the person closing the issue does not have to invent it.

````markdown
```bash
curl -s https://example.org/sessions/8b14c725 | grep -o '"superEvent":{[^}]*}'
```

Danach in der Search Console per Live-Test nachmessen: `verdict` muss auf
`PASS` gehen.
````

### Delimitation — against the neighbours

Where related issues exist, name them and say what separates them. This is
what stops the same defect being filed a fourth time, and it is the section
the duplicate check in step 3 produces almost for free.

```markdown
## Abgrenzung

* #1320 und #1321 betreffen die WARNING-Zeilen des ersten Events. Dieses
  Issue betrifft die ERROR-Zeilen des zweiten, versehentlich erzeugten —
  und blockiert das Rich Result unabhängig davon.
```

### Provenance footer — where it came from

Mandatory. Source, date, and the artefact it came out of. Without it, a
number cannot be re-checked and an old issue cannot be judged.

```markdown
---
*SEO-Audit 10.09.2026 · Befund S2 · Report: <link>*
```

or

```markdown
## Herkunft

Gemeldet 2026-09-08 von der Redaktion, gegen Produktion nachgeprüft.

> Hinweis: Die in der Meldung enthaltenen `_storyblok_tk`-Token wurden hier
> bewusst weggelassen — der Fehler reproduziert ohne sie.
```

The second form is the pattern for redaction: say what was removed and why
the issue still stands without it.

## Length

As long as the evidence needs and no longer. A one-paragraph issue with a
`file:line`, a number and a footer is complete. Three screens of prose
around a defect nobody verified is not.

The test: could someone who was not in this conversation fix it, and could a
second person tell whether the fix worked? If yes, it is finished.
