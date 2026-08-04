---
id: empathy-map
phase: discover
dauer_min: 40
gruppe: [2, 8]
braucht_input: [nutzer_beschreibung, rohnotizen]
liefert_output: [empathie_erkenntnisse]
gut_bei: [Nutzerperspektive fehlt, Team argumentiert aus Eigensicht, viele unsortierte Interviewnotizen]
schlecht_bei: [weder Nutzerdaten noch Proxy-Quellen vorhanden, Entscheidung steht an]
canvas:
  typ: quadrants
  zonen:
    - id: says
      titel: "Sagt"
      hinweis: "Wörtliche Zitate aus Interviews. Keine Interpretation."
    - id: thinks
      titel: "Denkt"
      hinweis: "Was beschäftigt die Person vermutlich? Als Hypothese markieren."
    - id: does
      titel: "Tut"
      hinweis: "Beobachtetes Verhalten. Was tut sie tatsächlich — nicht was sie sagt, dass sie tut."
    - id: feels
      titel: "Fühlt"
      hinweis: "Emotionen, je ein Wort plus Auslöser: 'frustriert — weil …'"
naechste_methoden: [hmw]
---

# Empathy Map

## Ablauf

1. **Nutzer festlegen (5 min).** Eine konkrete Person oder ein scharf
   umrissenes Segment. "Unsere Kunden" ist zu breit — dann lieber zwei
   Maps.
2. **Quadranten füllen (25 min).** Aus den Rohnotizen. Reihenfolge:
   erst *Sagt* und *Tut* (beobachtbar), dann *Denkt* und *Fühlt*
   (interpretiert). Jeder Eintrag ein eigenes Element, keine Sammelposten.
3. **Spannungen markieren (10 min).** Wo widerspricht *Sagt* dem *Tut*?
   Diese Widersprüche sind die wertvollsten Erkenntnisse und der
   Rohstoff für HMW-Fragen.

## Proxy-Variante (keine Interviews vorhanden)

Fehlen echte Nutzer-Rohnotizen, ist die Map trotzdem sinnvoll — wenn
Proxy-Quellen existieren: Support-Tickets, Sales-Gespräche,
Analytics-Auffälligkeiten, eigene Beobachtungen. Zwei Regeln machen
den Unterschied zwischen Methode und Kaffeesatz:

1. **Quelle vs. Vermutung strikt trennen.** Einträge ohne Quelle sind
   Hypothesen und werden als solche markiert (Präfix "H:").
2. **Der eigentliche Output verschiebt sich:** Der Wert liegt weniger
   in der Wahrheit der Einträge als darin, sichtbar zu machen, wo
   Wissen und wo Hypothesen stehen. Die markierten Hypothesen werden
   zur Interview-Liste — sag das vorher an, sonst wirkt die Map wie
   validiertes Wissen.

Gibt es auch keine Proxy-Quellen (neues Produkt, kein Kontakt zu
Nutzern), ist die Methode falsch — dann ehrlich auf Nutzerforschung
verweisen statt eine Map aus reinen Vermutungen zu bauen.

## Moderationshinweise

- Einträge ohne Beleg in den Rohnotizen gehören in *Denkt* als markierte
  Hypothese, nicht in *Sagt*.
- Wenn ein Quadrant leer bleibt, ist das ein Befund (Datenlücke), kein
  Makel — nicht künstlich auffüllen.

## Auswertungshinweise (Phase 3)

- Cluster über Quadranten hinweg bilden, nicht pro Quadrant.
- Sagt/Tut-Widersprüche explizit als solche ausweisen.
- Bei der Proxy-Variante: "H:"-Einträge getrennt auswerten und als
  Interview-Liste ausgeben, nicht mit belegten Erkenntnissen mischen.
- Output für die Kette: 3–5 `empathie_erkenntnisse` als je ein Satz,
  jede mit Quadranten-Beleg.
