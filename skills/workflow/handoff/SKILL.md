---
name: handoff
description: Writes the live thread of a long session into a portable
  handoff document so a fresh agent, another harness, or a colleague can
  pick the work up without re-reading the conversation. Use when
  switching tool or machine, moving to a different repo or directory,
  parking work to continue later, forking a second agent onto a parallel
  task, or handing over to a person — and whenever someone says they are
  about to lose context, want to stop for today, or need to pass this on
  (including German "übergeben", "Zustand festhalten", "hier weitermachen",
  "für später parken", "bevor der Kontext voll ist").
---

# Handoff

A handoff document makes work portable. It is not a summary of the
conversation and not a backup of it — it is what the next agent needs to
continue, and nothing else.

Based on the /handoff skill described at
<https://www.aihero.dev/skills-handoff>, with one deliberate change: the
document is written to a durable, predictable location instead of the OS
temp directory. See "Where it goes".

## Not the same as compacting

- **compacting** shrinks context to keep going here
- **clearing** throws context away
- **handoff** moves the work somewhere else

If the work is staying in this session, in this directory, in this tool,
you do not need this skill.

## Language

This skill is written in English. **The handoff document is written in
the conversation language** — it is read by a person or by an agent
continuing that conversation. Frontmatter keys stay English.

## Where it goes

Inside a git repo:

```
<repo>/.claude/handoffs/YYYY-MM-DD-<slug>.md
```

Outside one: `~/.claude/handoffs/<context>-YYYY-MM-DD-<slug>.md`.

`scripts/new-handoff.sh <slug>` works the path out, creates the
directory, warns if `.claude/handoffs/` is neither gitignored nor
tracked, and prints the path. Use it rather than assembling paths
yourself.

Two reasons for not using the temp directory: temp paths differ per OS
and get cleaned out from under you, and a repo-local path is *findable
later* — the companion `wip` skill picks these files up and reports a
parked thread as an open item. A handoff nobody can find again is a
deleted handoff with extra steps.

Decide with the user whether handoffs are committed. Personal parking:
gitignore them. Handing over to a colleague: commit, then reference the
commit.

## What goes in

Follow `references/document-template.md`. The four rules that decide
whether the document is worth anything:

**Reference, never copy.** Specs, plans, ADRs, issues, commits, diffs —
by path or URL. Copied content is a second source that starts drifting
the moment it is written. The test: if the document could be reconstructed
by reading it next to the repo, it is the right size.

**Separate verified from assumed.** Go through your own claims and
demote every one the session did not actually check — tests you did not
run, behaviour you did not observe, causes you inferred. Sessions
generate confident-sounding conclusions; carrying an unverified one
across a handoff is how it becomes a fact nobody questions again. Mark
them explicitly as assumptions.

**Write down what failed.** Approaches tried and abandoned, with the
reason. This is the part the next agent cannot reconstruct from the repo,
and the part that otherwise gets rediscovered the expensive way.

**Redact.** No tokens, keys, passwords, connection strings, `.env`
content, URLs with credentials in them. Name the variable, not the value.
Check the document again after writing it, before you hand over the path.

## Process

1. Ask what the next session is for, unless the user already said. A
   handoff aimed at "continue the refactor" and one aimed at "review what
   I did" are different documents.
2. Draft against the template.
3. Demote unverified claims to assumptions.
4. Redact, then re-read for secrets.
5. Write the file, print the path.
6. Show the user the document and say what you left out and why.

## Picking it up

The receiving agent gets the path — not the pasted content, which loses
the file and its references.

```
Read <path> and continue from the next step it names.
```

If the document names skills under "Suggested skills", load those first.
