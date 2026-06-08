---
name: session-handoff
description: Update AGENTS.md and roadmap state after completing a PR, todo, or bugfix. Use when a roadmap phase is done, a todo is completed, a bugfix lands, or before ending a session with uncommitted work.
user-invocable: true
---

# Session Handoff

Keep `AGENTS.md` fresh so the next agent session starts with current context, not stale history.

## When to run

- Finished a roadmap PR or phase from `docs/DESIGN.md`
- Completed a todo or bugfix with meaningful code changes
- About to end a session with work in progress

## Command

```bash
bun run agents:handoff \
  --completed "PR N: <short title>" \
  --next "PR M: <short title>" \
  --summary "<one sentence of what changed and what to do next>"
```

Optional flags: `--in-progress`, `--blocker`, `--reason roadmap-phase|bugfix|todo`

## What it updates

1. `ledgers/roadmap-state.json` — machine-readable progress
2. `ROADMAP.md` — central human-readable roadmap (`<!-- ROADMAP_STATE_START -->` / `<!-- ROADMAP_STATE_END -->`)
3. `AGENTS.md` — **Session Continuity** block between `<!-- SESSION_STATE_START -->` / `<!-- SESSION_STATE_END -->`

Old session detail is replaced, not appended. Static charter sections in `AGENTS.md` and the phase table in `ROADMAP.md` stay intact.

## Grok hooks

`.grok/hooks/agents-continuity.json` syncs `AGENTS.md` on `Stop` and `SessionEnd` when there are local file changes.

`.grok/hooks/coderabbit-turn.json` runs CodeRabbit on `Stop` and `SessionEnd` (bounded timeout; not on every subagent stop). If `ledgers/coderabbit/agent-queue.json` has `"pending": true`, load `.agents/skills/code-review/SKILL.md` and fix critical/major findings before ending the session.

Trust this repo in `~/.grok/trusted-hook-projects`.

## Examples

```bash
# Completed PR 1
bun run agents:handoff \
  --completed "PR 1: build-logic + catalog + repo hygiene" \
  --next "PR 2: Android Compose shell + minimal CI" \
  --summary "Convention plugins, Justfile, package.json scripts landed"

# Bugfix mid-phase
bun run agents:handoff \
  --reason bugfix \
  --summary "Fixed flake.nix API 36 shell message drift" \
  --in-progress "PR 1: build-logic + catalog + repo hygiene"
```
