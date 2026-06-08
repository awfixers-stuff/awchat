# AWChat Roadmap

Central, human-readable progress tracker for the [24-PR implementation plan](docs/DESIGN.md#pr-plan). Machine-readable state lives in [`ledgers/roadmap-state.json`](ledgers/roadmap-state.json).

> The **Progress** block below is auto-maintained by `scripts/update-agents-md.ts` (session handoff + Grok hooks). Do not edit it by hand.

---

## Progress

<!-- ROADMAP_STATE_START -->

**Last updated:** 2026-06-08T07:12:09.859Z
**Branch:** `master`
**Progress:** 11 / 24 PRs complete

### In progress
- PR 12: CI expansion — detekt, oxlint, emulator

### Next up
- PR 12: CI expansion — detekt, oxlint, emulator
- PR 13: feature:onboarding
- PR 14: feature:lock

### Blockers
- _(none)_

### PR status

| PR | Title | Status |
| --- | --- | --- |
| 1 | build-logic + catalog + repo hygiene | done |
| 2 | Android Compose shell + minimal CI | done |
| 3 | libsignal-android packaging spike | done |
| 4 | core:common, core:model, core:designsystem, core:proto | done |
| 5 | server:relay skeleton (parallel track) | done |
| 6 | core:crypto — SessionManager + identity sealing | done |
| 7 | core:security — Keystore sealing | done |
| 8 | core:database — Room + SQLCipher (entities + DAOs) | done |
| 9 | core:domain — repository interfaces + use cases | done |
| 10 | core:database — repository implementations | done |
| 11 | core:network — Ktor client + WS + auth handshake | done |
| 12 | CI expansion — detekt, oxlint, emulator | **in progress** |
| 13 | feature:onboarding | pending |
| 14 | feature:lock | pending |
| 15 | feature:chat — conversation list UI | pending |
| 16 | feature:settings — account drawer | pending |
| 17 | feature:contacts | pending |
| 18 | Conversation lifecycle — create/join/sync + membership API | pending |
| 19 | feature:chat — thread + E2EE send/receive | pending |
| 20 | Client ephemeral receipts + seen-by-all | pending |
| 21 | Server purge + TTL cron + purge_notify broadcast | pending |
| 22 | Group chat — per-member sender keys + membership rotation | pending |
| 23 | Security hardening + release CI signing | pending |
| 24 | Polish + observability + relay deploy docs | pending |

_Auto-synced by `scripts/update-agents-md.ts`._

<!-- ROADMAP_STATE_END -->

---

## Phases

| Phase | PRs | Focus |
| --- | --- | --- |
| Foundation | 1–2 | build-logic, catalog, Justfile, Android shell, minimal CI |
| Crypto spike | 3–6 | libsignal packaging, core modules, SessionManager |
| Data layer | 7–10 | Keystore, SQLCipher/Room, domain interfaces |
| Network | 5, 11 | Relay server + Android WS client |
| CI expansion | 12 | detekt, oxlint, emulator tests |
| Features | 13–17 | onboarding, lock, chat list, settings, contacts |
| Messaging | 18–22 | conversation lifecycle, E2EE, receipts, purge, groups |
| Ship | 23–24 | hardening, release CI, observability, docs |

## Related docs

- **Full system design:** [`docs/DESIGN.md`](docs/DESIGN.md)
- **Agent charter:** [`AGENTS.md`](AGENTS.md)
- **Post-v1 plans:** [`plans/`](plans/)