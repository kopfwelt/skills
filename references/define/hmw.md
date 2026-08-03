---
id: hmw
phase: define
dauer_min: 25
gruppe: [2, 10]
braucht_input: [empathie_erkenntnisse]
liefert_output: [problem_statement]
gut_bei: [Erkenntnisse liegen vor aber kein Fokus, Team springt zu früh in Lösungen, Problem zu groß oder zu klein geschnitten]
schlecht_bei: [keine Nutzererkenntnisse vorhanden, Problem-Statement existiert bereits und ist gut]
canvas:
  typ: list
  zonen:
    - id: hmw_fragen
      titel: "How-Might-We-Fragen"
      hinweis: "Format: 'Wie könnten wir [Nutzer] helfen, [Bedürfnis], damit [Wirkung]?' Eine Frage pro Eintrag."
    - id: favoriten
      titel: "Favoriten (max. 2)"
      hinweis: "Nach dem Sammeln: die 1–2 Fragen hierher kopieren, die weder zu eng (Lösung versteckt) noch zu weit (Weltfrieden) sind."
naechste_methoden: [crazy-8s]
---

# How Might We (HMW)

## Ablauf

1. **Erkenntnisse sichten (5 min).** Die `empathie_erkenntnisse` (oder
   andere Research-Ergebnisse) sind im Canvas-Kontext sichtbar. Jede
   Erkenntnis ist ein Kandidat für mindestens eine HMW-Frage.
2. **Fragen generieren (10 min).** Pro Erkenntnis 1–3 Umformulierungen.
   Stellhebel zum Variieren: das Gute verstärken, das Schlechte
   entfernen, das Gegenteil erkunden, die Annahme hinterfragen.
3. **Kalibrieren und wählen (10 min).** Test pro Frage: Fallen euch
   spontan mindestens 5 verschiedene Lösungsrichtungen ein? Weniger →
   zu eng. Beliebig viele, aber alle banal → zu weit. Max. 2 Favoriten.

## Moderationshinweise

- "Wie könnten wir eine App bauen, die …" ist keine HMW-Frage, sondern
  eine versteckte Lösung. Zurückformulieren aufs Bedürfnis.
- Der `damit`-Teil erzwingt die Wirkungsebene — nicht weglassen lassen.

## Auswertungshinweise (Phase 3)

- Favoriten gegen die Erkenntnisse spiegeln: deckt jede Favoritenfrage
  eine belegte Erkenntnis ab, oder ist eine Wunschidee durchgerutscht?
- Output für die Kette: genau ein `problem_statement` (die stärkste
  HMW-Frage), begründet in einem Satz. Der zweite Favorit wird als
  Reserve notiert.
