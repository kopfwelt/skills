# Auswahlmatrix

Entscheidungsgrundlage für Phase 1. Erst die Situationsfrage, dann die
Constraints (Zeit, Gruppengröße, vorhandener Input). Ergebnis ist **eine**
Empfehlung plus eine Alternative.

## Schritt 1 — Situation → Phase

| Aussage der Nutzenden (typisch) | Phase |
|---|---|
| "Wir wissen nicht genau, was das Problem ist" / "Wir kennen unsere Nutzer nicht" | discover |
| "Wir haben viel Material, aber keinen Fokus" / "Was ist eigentlich die Kernfrage?" | define |
| "Uns fallen keine Lösungen ein" / "Wir drehen uns im Kreis" / "Zu wenig Optionen" | ideate |
| "Wir haben Ideen, wissen aber nicht, ob sie funktionieren" | prototype |
| "Wir wollen wissen, wie Nutzer reagieren" | test |

Achtung, häufige Fehldiagnose: Teams, die "keine Ideen" sagen, haben oft
ein unklares Problem. Wenn kein Problem-Statement vorliegt
(`braucht_input` der Ideate-Methoden), erst define.

## Schritt 2 — Phase × Constraints → Methode

### discover

| Methode | Zeit | Gruppe | braucht | gut wenn |
|---|---|---|---|---|
| empathy-map | 30–45 min | 2–8 | Interview- oder Beobachtungsnotizen | Nutzerperspektive fehlt im Team |

### define

| Methode | Zeit | Gruppe | braucht | gut wenn |
|---|---|---|---|---|
| hmw | 20–30 min | 2–10 | Erkenntnisse aus discover (z. B. Empathy Map) | Problem bekannt, aber noch nicht als bearbeitbare Frage formuliert |

### ideate

| Methode | Zeit | Gruppe | braucht | gut wenn |
|---|---|---|---|---|
| crazy-8s | 15 min | 1–8 | Problem-Statement / HMW-Frage | festgefahrene Diskussion, Quantität vor Qualität |

*(prototype und test: noch keine Methodendateien — bei Bedarf ergänzen,
bis dahin ehrlich sagen, dass der Skill dort noch nichts anbietet.)*

## Schritt 3 — Tie-Breaker

1. **Vorhandener Input schlägt Wunschphase.** Fehlt der `braucht_input`
   einer Methode, eine Phase zurückgehen.
2. **Zeit ist hart.** Passt die Methode nicht ins Zeitfenster, nicht
   kürzen, sondern eine kürzere Methode wählen oder das ehrlich sagen.
3. **Bei Gleichstand** die Methode wählen, deren `liefert_output` den
   direkteren Anschluss an eine `naechste_methoden`-Kette hat.
