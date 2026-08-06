# Kopfwelt Skills

Agent skills by [Kopfwelt](https://kopfwelt.com) — starting with design
thinking facilitation. Documentation lives at
[kopfwelt.com/skills](https://kopfwelt.com/skills).

## Skills

| Skill | Category | What it does |
|---|---|---|
| [design-thinking-methods](skills/facilitation/design-thinking-methods) | facilitation | Selects the right design thinking method for your situation, renders it as an interactive workshop canvas, and analyzes the results to propose the next step. Canvases render in the conversation language. |

## Installation

### Claude Code (plugin)

```bash
claude plugins install kopfwelt-skills@kopfwelt/skills
```

### Any agent (copy skill files)

```bash
npx skills@latest add kopfwelt/skills
```

### claude.ai (single skill upload)

Each skill can be packaged as a zip for claude.ai
(Settings → Capabilities → Skills):

```bash
./skills/facilitation/design-thinking-methods/scripts/package.sh
```

## Repository layout

```
.claude-plugin/         # plugin + marketplace manifest (Claude Code)
skills/
  <category>/
    <skill-name>/
      SKILL.md          # entry point: triggers + process
      references/       # progressive-disclosure knowledge base
      assets/           # e.g. canvas renderer
      scripts/          # per-skill tooling
```

Skills are self-contained: everything a skill needs at runtime lives in
its own folder. See each skill's README for its architecture.

## Contributing / adding a skill

1. Create `skills/<category>/<skill-name>/SKILL.md` (frontmatter:
   `name`, `description`).
2. Add the path to `skills` in `.claude-plugin/plugin.json`.
3. Add a row to the table above.

## License

MIT — see [LICENSE](LICENSE).
