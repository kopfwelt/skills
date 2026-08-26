# Kopfwelt Skills

Agent skills by [Kopfwelt](https://kopfwelt.com) — design thinking
facilitation, and workflow skills for keeping track of work in flight.
Documentation lives at [kopfwelt.com/skills](https://kopfwelt.com/skills).

## Skills

| Skill | Category | What it does |
|---|---|---|
| [design-thinking-methods](skills/facilitation/design-thinking-methods) | facilitation | Selects the right design thinking method for your situation, renders it as an interactive workshop canvas, and analyzes the results to propose the next step. Canvases render in the conversation language. |
| [wip](skills/workflow/wip) | workflow | Builds one board of everything in flight — open PRs, branches without a PR, stray worktrees, uncommitted work, review requests, parked handoffs — derived from git and GitHub instead of maintained by hand. |
| [handoff](skills/workflow/handoff) | workflow | Writes the live thread of a long session into a portable document, so another agent, harness, or colleague can continue without re-reading the conversation. |

## Installation

### Claude Code (plugin)

Add the marketplace once, then install from it:

```bash
claude plugin marketplace add kopfwelt/skills
claude plugin install kopfwelt-skills@kopfwelt
```

The id after `@` is the **marketplace name** from
`.claude-plugin/marketplace.json` — `kopfwelt` — not the repository path.
Installing before the marketplace is added fails with "not found in
marketplace", which reads like a stale cache but means it was never added.

### Any agent (copy skill files)

```bash
npx skills@latest add kopfwelt/skills
```

### claude.ai (single skill upload)

Each skill can be packaged as a zip for claude.ai
(Settings → Capabilities → Skills):

```bash
./skills/<category>/<skill-name>/scripts/package.sh
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
