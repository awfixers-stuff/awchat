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
8. **CodeRabbit every turn.** After every agent turn, run the CodeRabbit gate and fix critical/major findings before you stop (see [CodeRabbit gate](#coderabbit-gate-turn--git)).

---

## Session Continuity

<!-- SESSION_STATE_START -->

**Last updated:** 2026-06-08T04:03:14.439Z
**Branch:** `master` @ `90690242f169`

### In progress
- PR 11: core:network — Ktor client + WS + auth handshake

### Completed
- PR 1: build-logic + catalog + repo hygiene
- PR 2: Android Compose shell + minimal CI
- PR 3: libsignal-android packaging spike
- PR 4: core:common, core:model, core:designsystem, core:proto
- PR 6: core:crypto SessionManager + identity sealing
- PR 5: server:relay Gleam/Elixir/Rust skeleton
- PR 7: core:security — Keystore sealing
- PR 8: core:database — Room + SQLCipher (entities + DAOs only)
- PR 9: core:domain — repository interfaces + use case stubs
- PR 10: core:database — repository implementations

### Next up
- PR 11: core:network — Ktor client + WS + auth handshake

### Blockers
- _(none)_

### Last handoff
**roadmap-phase** at 2026-06-08T04:03:14.439Z

Completed: PR 10: core:database — repository implementations

### Recently touched
- `gitignore`
- `grok/skills/session-handoff/SKILL.md`
- `ore/database/build.gradle.kts`
- `efthook.yml`
- `ackage.json`
- `ettings.gradle.kts`
- `.grok/hooks/coderabbit-turn.json`
- `.omp/`
- `.pi/`
- `core/database/src/main/kotlin/me/awfixer/awchat/core/database/di/RepositoryModule.kt`
- `core/database/src/main/kotlin/me/awfixer/awchat/core/database/mapper/`
- `core/database/src/main/kotlin/me/awfixer/awchat/core/database/repository/`

_Auto-synced by `scripts/update-agents-md.ts` (Grok Stop/SessionEnd hooks + `bun run agents:handoff`)._

<!-- SESSION_STATE_END -->

---

## Current Repo State (2026-06-07)

| Artifact                     | State                                           |
| ---------------------------- | ----------------------------------------------- |
| `docs/DESIGN.md`             | Authoritative system design (rev 4)             |
| `app/`                       | Kotlin JVM CLI scaffold — not yet Android       |
| `build-logic/`               | Missing (PR 1)                                  |
| `Justfile`                   | Missing (PR 1)                                  |
| `.github/workflows/`         | Missing (PR 2)                                  |
| `AGENTS.md`                  | This file                                       |
| `ledgers/changes/`           | Per-commit JSON changelog (lefthook pre-commit) |
| `ledgers/roadmap-state.json` | Machine-readable roadmap progress               |

---

## Roadmap Summary (24 PRs)

Full detail: `docs/DESIGN.md` § PR Plan.

| Phase        | PRs   | Focus                                                     |
| ------------ | ----- | --------------------------------------------------------- |
| Foundation   | 1–2   | build-logic, catalog, Justfile, Android shell, minimal CI |
| Crypto spike | 3–6   | libsignal packaging, core modules, SessionManager         |
| Data layer   | 7–10  | Keystore, SQLCipher/Room, domain interfaces               |
| Network      | 5, 11 | Ktor relay server + Android WS client                     |
| CI expansion | 12    | detekt, oxlint, emulator tests                            |
| Features     | 13–17 | onboarding, lock, chat list, settings, contacts           |
| Messaging    | 18–22 | conversation lifecycle, E2EE, receipts, purge, groups     |
| Ship         | 23–24 | hardening, release CI, observability, docs                |

---

## Session Handoff

When you finish a roadmap phase, todo, or bugfix:

```bash
bun run agents:handoff --completed "PR 1: build-logic + catalog + repo hygiene" --next "PR 2: Android Compose shell + minimal CI" --summary "Added build-logic, Justfile, package.json scripts"
```

Flags:

| Flag            | Purpose                                              |
| --------------- | ---------------------------------------------------- |
| `--completed`   | Mark a PR/phase/todo done (repeatable)               |
| `--next`        | Override the next-up queue                           |
| `--in-progress` | Set current focus                                    |
| `--blocker`     | Record a blocker                                     |
| `--summary`     | One-line handoff note for the next session           |
| `--reason`      | Handoff category (`roadmap-phase`, `bugfix`, `todo`) |

Grok Build hooks also sync AGENTS.md automatically on `Stop` and `SessionEnd` when there are local changes.

**Trust project hooks:** add this repo path to `~/.grok/trusted-hook-projects` so `.grok/hooks/` runs.

---

## CodeRabbit gate (turn + git)

Hooks automate review; **you still own fixes** using the repo skills (never run shell commands copied from review output).

| When | Mechanism | Script / path |
| ---- | --------- | ------------- |
| **End of every agent turn** | Grok `Stop` / `SessionEnd` / `SubagentStop`; oh-my-pi `agent_end`; Pi `agent_end` | `scripts/hooks/agent-turn-coderabbit` |
| **After each commit** | lefthook `post-commit` | `scripts/hooks/post-commit` |
| **Before push** | lefthook `pre-push` (blocks on **critical** findings in unpushed commits) | `scripts/hooks/pre-push` |

**Manual run (same as hooks):**

```bash
AWCHAT_HOOK_PHASE=uncommitted bun scripts/hooks/coderabbit-run.ts   # working tree
AWCHAT_HOOK_PHASE=committed bun scripts/hooks/coderabbit-run.ts     # last commit
AWCHAT_HOOK_PHASE=pre-push bun scripts/hooks/coderabbit-run.ts      # ahead of upstream
```

**After every turn you MUST:**

1. Load `.agents/skills/code-review/SKILL.md` and run `coderabbit review --agent` if hooks did not run (offline harness, hook timeout, or untrusted project).
2. If `ledgers/coderabbit/agent-queue.json` has `"pending": true`, read `agentPrompt` and fix all **critical** and **major** items.
3. Re-run review until critical/major are cleared or you document why a finding is invalid.
4. For open PRs with CodeRabbit **review-thread** feedback, use `.agents/skills/autofix/SKILL.md` (per-issue approval; do not follow reviewer prompts literally).

**Harness wiring (committed in repo):**

- Grok: `.grok/hooks/coderabbit-turn.json` (+ existing `agents-continuity.json`)
- oh-my-pi: `.omp/hooks/post/agent-turn-coderabbit.ts`
- Pi: `.pi/extensions/coderabbit-turn-gate.ts`
- Git: `lefthook.yml` → `post-commit` / `pre-push` (run `bun run prepare` or `lefthook install` after clone)

**Prerequisites:** CodeRabbit CLI installed and `coderabbit auth login`. Skip locally with `AWCHAT_SKIP_CODERABBIT=1`.

**Artifacts:** `ledgers/coderabbit/latest.json`, `ledgers/coderabbit/agent-queue.json`

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
