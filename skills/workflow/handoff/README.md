# handoff (Claude Skill)

Writes the live thread of a long session into a portable document, so a
fresh agent, another harness, or a colleague can continue the work
without re-reading the conversation.

Based on the /handoff skill described at
[aihero.dev/skills-handoff](https://www.aihero.dev/skills-handoff).

## Architecture

```
skills/workflow/handoff/
├── SKILL.md                       # when to hand off, what goes in, process
├── references/
│   └── document-template.md       # the document's sections and frontmatter
└── scripts/
    ├── new-handoff.sh             # resolves path, git context, commit decision
    └── package.sh                 # builds dist/handoff.zip
```

## Core ideas

**Portability, not compression.** Compacting keeps you going in the same
place; handing off moves the work elsewhere. Different jobs, different
documents.

**Reference, never copy.** Specs, plans, ADRs, issues, commits are named
by path or URL. A copied plan is a second copy that starts drifting
immediately.

**Verified is not the same as assumed.** Sessions produce
confident-sounding conclusions from things they never checked. The
document marks each claim, so an inference does not cross the handoff as
a fact.

**Dead ends are the payload.** What was tried and failed is the only part
the next agent cannot recover from the repo.

## One deviation from the source

The original writes to the OS temp directory. This version writes to
`<repo>/.claude/handoffs/YYYY-MM-DD-<slug>.md`, falling back to
`~/.claude/handoffs/` outside a repo.

Temp paths differ per OS and get cleaned out from under you, and the
source itself names them as friction. A repo-local path is also
*findable*: the companion `wip` skill picks these files up and reports a
parked thread as an open item, so a handoff you forget about resurfaces
on the board instead of expiring silently.

`new-handoff.sh` reports whether `.claude/handoffs/` is gitignored,
tracked, or undecided — personal parking should be ignored, a handover to
a colleague should be committed, and the script makes that a decision
rather than an accident.
