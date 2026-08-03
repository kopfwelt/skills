---
id: dot-voting
phase: ideate
dauer_min: 10
gruppe: [3, 12]
braucht_input: [ideen_liste]
liefert_output: [priorisierte_ideen]
gut_bei: [zu viele Optionen, Diskussion dreht sich im Kreis, dominante Stimmen verzerren die Auswahl, schnelle demokratische Vorauswahl nötig]
schlecht_bei: [weniger als 5 Optionen, Entscheidung braucht Machbarkeitsbewertung, Einzelperson ohne Gruppe]
canvas:
  typ: grid
  zonen_quelle: ideen_liste
naechste_methoden: [impact-effort-matrix]
---

# Dot Voting

## Zonen-Erzeugung (Phase 2)

`zonen_quelle: ideen_liste` heißt: Die Zonen stehen nicht in dieser
Datei, sondern werden beim Rendern aus dem Input erzeugt — **eine Zone
pro Idee bzw. Cluster** aus der `ideen_liste` der Vormethode:

- `id`: Slug der Idee (`z-video-tutorial`)
- `titel`: die Idee in Kurzform (max. ~8 Wörter)
- `hinweis`: bei Clustern die enthaltenen Einzelideen in einem Satz

Bei mehr als 12 Ideen vorher clustern (Phase 3 der Vormethode) und über
Cluster abstimmen lassen, nicht über 20 Einzelzettel.

## Ablauf

1. **Budget festlegen (1 min).** Jede Person bekommt Stimmen nach der
   Faustregel *Anzahl Optionen ÷ 3*, mindestens 2, höchstens 5. Das
   Budget steht in der Anleitung des Canvas.
2. **Still abstimmen (5 min).** Pro Stimme einen Eintrag in die Zone
   der gewählten Idee: den eigenen Namen oder ein `●`. Kumulieren ist
   erlaubt (mehrere Stimmen auf eine Idee), aber ansagen. Keine
   Diskussion während der Abstimmung — sonst wird das erste laute
   Argument zum Anker.
3. **Auszählen und Schnitt (4 min).** Einträge pro Zone = Stimmen.
   Weiter kommen die oberen 2–4, nicht "alles über null".

## Moderationshinweise

- Reihenfolge der Zonen vor der Abstimmung mischen (nicht in der
  Entstehungsreihenfolge lassen) — Positionseffekte sind real.
- Wer zuerst abstimmt, ankert. Bei starkem Hierarchiegefälle: ranghöchste
  Person stimmt zuletzt.

## Auswertungshinweise (Phase 3)

- Stimmen pro Zone zählen und als Rangliste ausgeben.
- Knappe Abstände (±1 Stimme) nicht als klares Ergebnis verkaufen —
  benennen und ggf. Stichentscheid oder impact-effort-matrix für die
  Spitzengruppe vorschlagen.
- Ideen mit null Stimmen im Protokoll behalten (nicht löschen) — sie
  sind für spätere Runden manchmal die interessantesten.
- Output für die Kette: `priorisierte_ideen` = Top 2–4 mit Stimmenzahl.
