# design-thinking-methods (Skill)

Claude-Skill, der passende Design-Thinking-Methoden auswählt, sie als
interaktives Canvas-Artefakt bereitstellt und die Eingaben auswertet, um
den nächsten Prozessschritt vorzuschlagen.

## Architektur

```
design-thinking-skill/
├── SKILL.md                    # Diagnose → Auswahl → Render → Auswertung
├── references/
│   ├── auswahlmatrix.md        # Phase × Situation × Zeit × Gruppengröße
│   ├── export-contract.md      # Rückkanal-Schema (v1) — Quelle der Wahrheit
│   ├── discover/empathy-map.md
│   ├── define/hmw.md
│   └── ideate/                 # crazy-8s, dot-voting, impact-effort-matrix
├── assets/
│   └── canvas-base.html        # generischer Renderer, liest METHOD_CONFIG
└── scripts/
    └── synthesize.py           # Vorclustering bei >20 Eingaben
```

Kernideen:

- **Progressive Disclosure statt MCP:** Methodenwissen liegt in
  `references/`, Claude lädt nur die Datei, die gebraucht wird.
- **Maschinenlesbares Frontmatter** pro Methode (Selektor + Renderer
  konsumieren dasselbe Schema). `naechste_methoden` +
  `braucht_input`/`liefert_output` verketten die Methoden zum Prozess.
- **Ein Renderer für alle Methoden:** `canvas-base.html` bekommt nur den
  `METHOD_CONFIG`-Block injiziert. Muss der Renderer für eine neue
  Methode angefasst werden, ist das Schema kaputt, nicht die Methode.
- **Copy-out-Rückkanal:** Das Canvas exportiert JSON gemäß
  `references/export-contract.md` in die Zwischenablage; der Contract
  ist 1:1 das Payload eines späteren `submit_canvas`-MCP-Tools (Weg B,
  MCP Apps / SEP-1865) — der Umstieg ist dann ein Adapter, kein Rewrite.

## Neue Methode hinzufügen

1. `references/<phase>/<id>.md` anlegen — Frontmatter-Schema von einer
   bestehenden Methode kopieren (`id`, `phase`, `dauer_min`, `gruppe`,
   `braucht_input`, `liefert_output`, `gut_bei`, `schlecht_bei`,
   `canvas`, `naechste_methoden`).
2. Zeile(n) in `references/auswahlmatrix.md` ergänzen.
3. Nichts an `canvas-base.html` ändern.

## Testen

- Renderer lokal: Test-Config in `canvas-base.html` bei
  `/*__METHOD_CONFIG__*/` einsetzen und im Browser öffnen.
- Clustering: `python3 scripts/synthesize.py <export.json>`
- Trigger- und Artefakt-Verhalten (Clipboard im Sandbox-iframe,
  `window.storage`) müssen in der Zieloberfläche (claude.ai) getestet
  werden — dafür den Skill paketieren und dort installieren.

## Roadmap

1. ✅ Export-Contract + Frontmatter-Schema + 3 Methoden + Renderer
2. ✅ Konvergenz-Methoden dot-voting und impact-effort-matrix
   (inkl. `zonen_quelle`-Konvention für dynamisch erzeugte Zonen)
3. Methoden für `prototype/` (storyboard, wizard-of-oz) und `test/`
   ergänzen
4. Eval-Loop: Testprompts mit/ohne Skill fahren, Trigger-Rate der
   description messen
5. Optional MCP-Server: `list_methods`, `get_session`, `submit_canvas`,
   State in SQLite — erst wenn Session-übergreifender State oder
   Team-Sharing gebraucht wird
