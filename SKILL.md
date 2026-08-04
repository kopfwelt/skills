---
name: design-thinking-methods
description: Wählt passende Design-Thinking-Methoden aus, stellt sie als
  interaktives Canvas-Artefakt bereit und wertet die Eingaben aus, um die
  nächste Prozessphase vorzuschlagen. Nutze diesen Skill immer, wenn es um
  Workshop-Planung, Ideenfindung, Problem-Framing, Nutzerforschung,
  Retrospektiven, Priorisierung oder Formulierungen wie "wir kommen nicht
  weiter", "wie strukturiere ich den Workshop", "welche Methode passt"
  geht — auch wenn "Design Thinking" nicht explizit fällt.
---

# Design-Thinking-Methoden

Drei Phasen. Überspringe keine, aber halte Phase 1 kurz.

## Phase 1 — Diagnose

Ohne Diagnose keine Methodenauswahl. Klär genau diese vier Dinge, per
AskUserQuestion falls verfügbar, sonst als kompakte Rückfrage:

1. Wo steht ihr? (Problem unklar / Lösungen fehlen / Auswahl steht an / Test)
2. Wie viele Personen?
3. Wie viel Zeit?
4. Was liegt schon vor? (Interviews, Personas, Ideenliste, nichts)

Beantwortet der Prompt bereits alle vier Punkte, nicht erneut fragen.
Fehlt etwas, frag nur das Fehlende — und warte auf die Antwort, statt
Frage und Empfehlung in dieselbe Nachricht zu packen. Was du dabei
annimmst statt weißt (z. B. "vermutlich keine Interviews vorhanden"),
benenne als Annahme.

Lies dann `references/auswahlmatrix.md` und schlage **eine** Methode vor,
mit einem Satz Begründung und einer Alternative. Nicht drei gleichwertige
Optionen anbieten — Auswahl ist die Leistung dieses Skills.

## Phase 2 — Canvas rendern

**Rendere genau ein Canvas** — das der gewählten Methode. Die
Folgemethode (`naechste_methoden`) wird erst nach der Auswertung in
Phase 3 gerendert, nie auf Vorrat: ihr `kontext` besteht aus den
Ergebnissen der aktuellen Methode, und die existieren vorher nicht.
Ein HMW-Canvas ohne Erkenntnisse ist ein leeres Formular, kein
Werkzeug.

Lies die Methodendatei unter `references/<phase>/<id>.md`. Nimm
`assets/canvas-base.html` als Grundlage und ersetze den Block
`/*__METHOD_CONFIG__*/` durch das JSON-Objekt, das du aus dem
`canvas`-Block des Frontmatters ableitest (Schema: siehe Kommentar am
Anfang von `canvas-base.html`). Ändere sonst nichts am Renderer — wenn
eine Methode nicht ohne Renderer-Änderung darstellbar ist, ist das ein
Schema-Problem, das gemeldet gehört, kein Anlass für Sonderlocken.

Sonderfall `zonen_quelle` im `canvas`-Block: Die Zonen stehen dann nicht
im Frontmatter, sondern du erzeugst sie beim Rendern aus dem benannten
Input (z. B. eine Zone pro Idee der `ideen_liste`) — Details stehen in
der jeweiligen Methodendatei. Der Renderer bekommt in jedem Fall ein
fertiges `zonen`-Array.

Das Artefakt braucht zwingend:
- Timer pro Zone, wenn `zeit_pro_zone` gesetzt ist
- Persistenz über `window.storage` (Fallback localStorage) unter
  `dt:<session_id>`
- einen Button "Ergebnis exportieren", der exakt das Schema aus
  `references/export-contract.md` in die Zwischenablage legt
- eine sichtbare Zeile: "Fertig? Export klicken und hier einfügen."

`session_id` generierst du selbst: `dt-<datum>-<kurzid>`, z. B.
`dt-2026-08-03-a1`.

## Phase 3 — Auswertung

Wenn Nutzende ein Export-JSON einfügen: gegen
`references/export-contract.md` parsen, dann

- clustern (thematisch, nicht alphabetisch — bei >20 Einträgen
  `scripts/synthesize.py` nutzen)
- Muster und Ausreißer benennen, Ausreißer nicht wegkürzen
- `naechste_methoden` der Methodendatei prüfen und gegen die aktuelle
  Diagnose spiegeln
- genau einen nächsten Schritt vorschlagen

Wenn eine Ideensammlung inhaltlich dünn ist, sag das. Ein Skill, der
zwölf mittelmäßige Post-its zu "starken Impulsen" umdeutet, ist wertlos.

## Prozesskette

`liefert_output` der einen Methode ist `braucht_input` der nächsten.
Übernimm beim Rendern der Folgemethode die relevanten Ergebnisse der
Vormethode in den `kontext`-Block des Canvas-Configs, damit sie im
Artefakt sichtbar sind.
