# AWChat — Agent Charter

AWChat is a greenfield Android encrypted ephemeral chat app (X-Lite UX, Material 3 Expressive, Signal Protocol E2EE, 1-day post-seen-all deletion). The Kotlin JVM CLI scaffold is being transformed per the 24-PR roadmap in `docs/DESIGN.md`.

> **Read this file first.** It is the session handoff surface for Grok Build, Cursor, and other agents. The **Session Continuity** block below is auto-maintained — do not edit it by hand.

---

## If You Are an AI Agent

**Non-negotiables:**

1. **Follow the PR plan.** `docs/DESIGN.md` defines 24 ordered PRs with explicit dependencies. Do not skip ahead.
2. **CI from PR 2.** Basic Android compile CI starts at PR 2; release signing at PR 23.
3. **Clean Architecture.** `core:domain` interfaces before Room implementations. No framework imports in domain.
4. **Crypto is libsignal-native.** No custom protocols. Server never decrypts message bodies.
5. **Default branch is `master`.** Blacksmith runners (`blacksmith-8vcpu-ubuntu-2404`) for CI.
6. **Dev tooling:** Nix shell + Gradle + Bun (oxlint/oxfmt only). Run `just build` / `just test` once `Justfile` exists (PR 1).
7. **Session handoff is mandatory.** After completing a roadmap phase, todo, or bugfix, run the handoff command (see [Session Handoff](#session-handoff)).

---

## Session Continuity

<!-- SESSION_STATE_START -->

**Last updated:** 2026-06-08T00:03:57.983Z
**Branch:** `master` @ `b84a8912e0af`

### In progress
- PR 1: build-logic + catalog + repo hygiene

### Completed
- _(none yet)_

### Next up
- PR 1: build-logic + catalog + repo hygiene
- PR 2: Android Compose shell + minimal CI
- PR 3: libsignal-android packaging spike

### Blockers
- _(none)_

### Last handoff
**roadmap-phase** at 2026-06-08T00:03:57.983Z

Initial hook infrastructure: lefthook changelog, Grok hooks, AGENTS.md session continuity

### Recently touched
- `.gitignore`
- `.grok/hooks/agents-continuity.json`
- `.grok/skills/session-handoff/SKILL.md`
- `AGENTS.md`
- `bun.lock`
- `flake.lock`
- `ledgers/roadmap-state.json`
- `lefthook.yml`
- `package.json`
- `scripts/changelog.ts`
- `scripts/hooks/pre-commit`
- `scripts/hooks/update-agents-md`

_Auto-synced by `scripts/update-agents-md.ts` (Grok Stop/SessionEnd hooks + `bun run agents:handoff`)._

<!-- SESSION_STATE_END -->

---

## Current Repo State (2026-06-07)

| Artifact | State |
|----------|-------|
| `docs/DESIGN.md` | Authoritative system design (rev 4) |
| `app/` | Kotlin JVM CLI scaffold — not yet Android |
| `build-logic/` | Missing (PR 1) |
| `Justfile` | Missing (PR 1) |
| `.github/workflows/` | Missing (PR 2) |
| `AGENTS.md` | This file |
| `ledgers/changes/` | Per-commit JSON changelog (lefthook pre-commit) |
| `ledgers/roadmap-state.json` | Machine-readable roadmap progress |

---

## Roadmap Summary (24 PRs)

Full detail: `docs/DESIGN.md` § PR Plan.

| Phase | PRs | Focus |
|-------|-----|-------|
| Foundation | 1–2 | build-logic, catalog, Justfile, Android shell, minimal CI |
| Crypto spike | 3–6 | libsignal packaging, core modules, SessionManager |
| Data layer | 7–10 | Keystore, SQLCipher/Room, domain interfaces |
| Network | 5, 11 | Ktor relay server + Android WS client |
| CI expansion | 12 | detekt, oxlint, emulator tests |
| Features | 13–17 | onboarding, lock, chat list, settings, contacts |
| Messaging | 18–22 | conversation lifecycle, E2EE, receipts, purge, groups |
| Ship | 23–24 | hardening, release CI, observability, docs |

---

## Session Handoff

When you finish a roadmap phase, todo, or bugfix:

```bash
bun run agents:handoff --completed "PR 1: build-logic + catalog + repo hygiene" --next "PR 2: Android Compose shell + minimal CI" --summary "Added build-logic, Justfile, package.json scripts"
```

Flags:

| Flag | Purpose |
|------|---------|
| `--completed` | Mark a PR/phase/todo done (repeatable) |
| `--next` | Override the next-up queue |
| `--in-progress` | Set current focus |
| `--blocker` | Record a blocker |
| `--summary` | One-line handoff note for the next session |
| `--reason` | Handoff category (`roadmap-phase`, `bugfix`, `todo`) |

Grok Build hooks also sync AGENTS.md automatically on `Stop` and `SessionEnd` when there are local changes.

**Trust project hooks:** add this repo path to `~/.grok/trusted-hook-projects` so `.grok/hooks/` runs.

---

## Build & Verify

```bash
# After PR 1
just build
just test
bun run lint
bun run fmt

# Changelog ledger (also runs via lefthook pre-commit)
bun run changelog
```

---

## Architecture Pointers

- **Design doc:** `docs/DESIGN.md` — crypto, retention, WS frame catalog, REST auth, DB schema
- **Server:** Kotlin Ktor relay, PostgreSQL, libsignal-client JVM — dumb encrypted relay
- **Client:** Compose + M3 Expressive, Room + SQLCipher, Hilt, MVI per feature
- **Retention:** Client-computed seen-by-all → signed `PurgeMessage` → server `PURGE_NOTIFY`

---

## License

Proprietary — see [LICENSE.md](LICENSE.md).

Built by [awfixer](https://awfixer.me)