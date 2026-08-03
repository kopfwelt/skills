# Export-Contract

Das JSON, das der "Ergebnis exportieren"-Button jedes Canvas in die
Zwischenablage legt — und das Phase 3 des Skills parst. Dieses Schema ist
zugleich das Payload eines späteren `submit_canvas`-MCP-Tools. Änderungen
hier sind Breaking Changes: Version hochzählen, alte Version weiter
akzeptieren.

## Schema (v1)

```json
{
  "contract_version": 1,
  "session_id": "dt-2026-08-03-a1",
  "method_id": "crazy-8s",
  "phase": "ideate",
  "kontext": {
    "problem_statement": "..."
  },
  "eingaben": [
    { "zone": "z1", "text": "...", "autor": null }
  ],
  "meta": {
    "dauer_tatsaechlich_min": 12,
    "teilnehmer": 4,
    "exportiert_am": "2026-08-03T14:30:00Z"
  }
}
```

## Feldregeln

| Feld | Typ | Pflicht | Regel |
|---|---|---|---|
| `contract_version` | int | ja | aktuell `1` |
| `session_id` | string | ja | Format `dt-<YYYY-MM-DD>-<kurzid>`, vergeben vom Skill in Phase 2 |
| `method_id` | string | ja | muss einer Methodendatei entsprechen (`id` im Frontmatter) |
| `phase` | string | ja | `discover` \| `define` \| `ideate` \| `prototype` \| `test` |
| `kontext` | object | ja | die `braucht_input`-Werte, mit denen das Canvas gerendert wurde; leeres Objekt erlaubt |
| `eingaben[].zone` | string | ja | Zonen-ID aus dem Canvas-Config (`z1`, `z2`, … oder sprechende IDs wie `says`) |
| `eingaben[].text` | string | ja | Rohtext, nicht getrimmt außer Whitespace an den Rändern |
| `eingaben[].autor` | string\|null | nein | optional, `null` wenn nicht erfasst |
| `meta.dauer_tatsaechlich_min` | int\|null | nein | vom Timer gemessen, sonst `null` |
| `meta.teilnehmer` | int\|null | nein | Selbstauskunft im Canvas, sonst `null` |
| `meta.exportiert_am` | string | ja | ISO 8601 UTC |

## Parsing-Regeln für Phase 3

- Unbekannte Zusatzfelder ignorieren, nicht ablehnen (forward compatible).
- Fehlt ein Pflichtfeld: konkret benennen, was fehlt, und um erneuten
  Export bitten — nicht raten.
- Leere `eingaben`: nicht auswerten, sondern nachfragen, ob der Export zu
  früh geklickt wurde.
