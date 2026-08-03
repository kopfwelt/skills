---
id: impact-effort-matrix
phase: ideate
dauer_min: 30
gruppe: [2, 8]
braucht_input: [ideen_liste]
liefert_output: [priorisierte_ideen, roadmap_kandidaten]
gut_bei: [Machbarkeit ist die kritische Dimension, Team überschätzt Lieblingsideen, Umsetzungsplanung steht an, Stakeholder wollen Begründung für die Auswahl]
schlecht_bei: [Aufwand ist noch gar nicht einschätzbar, mehr als ~15 Optionen, reine Kreativphase]
canvas:
  typ: quadrants
  zonen:
    - id: quick-wins
      titel: "Quick Wins — hoher Impact, geringer Aufwand"
      hinweis: "Zuerst umsetzen. Wenn hier alles landet, wird zu optimistisch geschätzt."
    - id: big-bets
      titel: "Big Bets — hoher Impact, hoher Aufwand"
      hinweis: "Strategische Wetten. Kandidaten für Prototyping, nicht für Sofortumsetzung."
    - id: fill-ins
      titel: "Fill-ins — geringer Impact, geringer Aufwand"
      hinweis: "Nice to have. Nur wenn Kapazität übrig ist."
    - id: money-pit
      titel: "Money Pit — geringer Impact, hoher Aufwand"
      hinweis: "Streichen. Hier ehrlich sein tut am meisten weh und bringt am meisten."
naechste_methoden: [storyboard, wizard-of-oz]
---

# Impact-Effort-Matrix

## Ablauf

1. **Achsen kalibrieren (5 min).** Erst definieren, was *Impact* hier
   konkret heißt (für wen? gemessen woran?) und was *Aufwand* umfasst
   (nur Bauzeit, oder auch Wartung und Abstimmung?). Ohne diese
   Kalibrierung sortiert jede Person nach eigenem Maßstab.
2. **Einsortieren (15 min).** Jede Idee aus der `ideen_liste` (im
   Canvas-Kontext sichtbar) als Eintrag in genau einen Quadranten.
   Erst still ein Vorschlag pro Idee, dann strittige Fälle diskutieren —
   nicht jede Idee einzeln durchdiskutieren.
3. **Konsequenzen ziehen (10 min).** Pro Quadrant die Standardaktion
   (siehe Hinweise) aussprechen und Ausnahmen begründen lassen.

## Moderationshinweise

- Relativ schätzen, nicht absolut: "aufwendiger als X?" ist
  beantwortbar, "wie viele Personentage?" an dieser Stelle nicht.
- Wenn >60 % der Ideen in *Quick Wins* landen, ist die Aufwandsachse
  zu weich kalibriert — Schritt 1 wiederholen.
- Die Matrix bewertet Annahmen, keine Fakten. Bei *Big Bets* ist die
  ehrliche Konsequenz ein Prototyp zum Testen der Impact-Annahme, kein
  Umsetzungsbeschluss.

## Auswertungshinweise (Phase 3)

- Ergebnis als Rangfolge ausgeben: Quick Wins → Big Bets (mit
  Prototyp-Empfehlung) → Fill-ins → Money Pit (gestrichen, mit
  Begründung dokumentiert).
- Leerer Money-Pit-Quadrant ist ein Warnsignal (niemand wollte streichen)
  — benennen.
- Output für die Kette: `priorisierte_ideen` (Quick Wins),
  `roadmap_kandidaten` (Big Bets). Nächster Schritt für Big Bets:
  Prototyping — `storyboard` oder `wizard-of-oz` (Methodendateien noch
  nicht vorhanden; bis dahin ehrlich sagen, dass der Skill dort noch
  nichts anbietet).
