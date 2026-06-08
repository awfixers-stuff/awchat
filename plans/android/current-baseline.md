# AWChat Android Client — Current Baseline

| Field | Value |
| ----- | ----- |
| **Status** | Baseline capture (post-PR 11) |
| **Created** | 2026-06-08 |
| **Updated** | 2026-06-08 |
| **Purpose** | Record what the Android client ships today and the v1 contract before enhancement work |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4) |
| **Module roots** | `app/`, `core/*` |

---

## Summary

AWChat's **production MVP client** is Android (Jetpack Compose, Material 3 Expressive, Clean Architecture). As of PR 11, the data, crypto, and network layers are in place; feature UI and E2EE messaging remain in PRs 13–22.

This document is the handoff surface for Android enhancement work — mirror of [`plans/server/current-baseline.md`](../server/current-baseline.md).

---

## Implementation status (as of 2026-06-08)

| Artifact | State |
| -------- | ----- |
| `app/` Compose shell | **Shipped** (PR 2) |
| `build-logic/` convention plugins | **Shipped** (PR 1) |
| `core:common`, `core:model`, `core:designsystem`, `core:proto` | **Shipped** (PR 4) |
| `core:crypto` — SessionManager, identity sealing | **Shipped** (PR 6) |
| `core:security` — Keystore sealing | **Shipped** (PR 7) |
| `core:database` — Room + SQLCipher entities/DAOs + repository impls | **Shipped** (PR 8–10) |
| `core:domain` — repository interfaces + use case stubs | **Shipped** (PR 9) |
| `core:network` — Ktor REST signer, WS handshake, frame DTOs | **Shipped** (PR 11) |
| CI — Android compile | **Shipped** (PR 2); detekt/oxlint/emulator in PR 12 |
| Feature modules (`feature:*`) | **Pending** (PRs 13–17) |
| E2EE messaging UI | **Pending** (PRs 18–20) |
| Security hardening (pinning, release signing) | **Pending** (PR 23) |

**Roadmap progress:** 11 / 24 PRs complete. Live state: [`ROADMAP.md`](../../ROADMAP.md).

---

## Role and constraints

| Principle | Detail |
| --------- | ------ |
| E2EE authority | Clients own crypto state, seen-by-all logic, and local retention |
| Server is dumb relay | Android never expects server to decrypt messages |
| Foreground delivery (NG8) | No FCM in v1; UX copy: messages deliver when app is open |
| Clean Architecture | `core:domain` interfaces; no framework imports in domain |
| MVI per feature | ViewModels expose `State` + `Intent` + `Effect` |
| Local DB | Room + SQLCipher 4; plaintext bodies inside encrypted DB |
| Key storage | libsignal keys in sealed local files; Keystore for DB passphrase |

---

## Module map (shipped)

```
app/
core/
  common/
  model/
  proto/
  designsystem/
  crypto/
  security/
  database/
  domain/
  network/
```

Pending per design doc PR plan:

```
feature/
  onboarding/     # PR 13
  lock/           # PR 14
  chat/           # PR 15, 19–20
  settings/       # PR 16
  contacts/       # PR 17
  feedback/       # Plan 001 — after PR 16
```

---

## Network contract (client side)

Implemented in `core:network` (PR 11):

| Capability | Detail |
| ---------- | ------ |
| REST signing | `RestAuthSigner` — `X-AWChat-User-Id`, `X-AWChat-Timestamp`, `X-AWChat-Signature` |
| WS handshake | `auth_challenge` → `auth_response` → `auth_ok` (XEdDSA) |
| Frames | `envelope`, `ack`, `nack`, `chat_created`, `membership_changed`, `purge_notify`, `error` |
| Pinning hook | Present; disabled in `debug` via `BuildConfig.PINNING_ENABLED = false` (wired in PR 23) |

---

## UI contract (design doc)

| Screen / component | PR | Status |
| ------------------ | -- | ------ |
| Single-activity shell | 2 | Shipped |
| `ConversationListScreen` | 15 | Pending |
| `AccountDrawerSheet` | 16 | Pending |
| `ChatScreen`, `MessageBubble`, `ComposerBar` | 19 | Pending |
| `LockScreen` | 14 | Pending |
| Pinning failure + support link | 23 + Plan 001 | Pending |

---

## Roadmap: when each capability lands

| PR | Android work | Status |
| -- | ------------ | ------ |
| **PR 12** | detekt, oxlint, emulator CI | in progress |
| **PR 13** | `feature:onboarding` | pending |
| **PR 14** | `feature:lock` | pending |
| **PR 15** | Conversation list UI | pending |
| **PR 16** | Account drawer | pending |
| **PR 17–22** | Contacts, lifecycle, E2EE, receipts, groups | pending |
| **PR 23** | Pinning, FLAG_SECURE, release CI | pending |
| **PR 24** | Observability polish | pending |

**Server coupling:** PR 11 complete; onboarding (PR 13) registers against relay `POST /v1/register`.

---

## Known extensions (not in v1 baseline)

| Source | Extension |
| ------ | --------- |
| [Plan 001 — Support & bug reporting](../001-support-and-bug-reporting.md) | `feature:feedback`, `DeviceDiagnostics`, drawer + pinning support links |
| `docs/DESIGN.md` v1.1 appendix | FCM, attachments |
| [Phase 2 clients](../clients/README.md) | Linux GTK, Ratatui TUI — share relay contract, not Android code |
| [Phase 3 clients](../clients/apple-macos-ios.md) | macOS + iOS when hardware available |

---

## Enhancement workspace

Use this section to track deltas from the baseline.

### Open questions

| ID | Question | Notes |
| -- | -------- | ----- |
| — | — | — |

### Proposed additions / changes

| ID | Change | Rationale | Breaks v1 contract? |
| -- | ------ | --------- | ------------------- |
| — | — | — | — |

### Acceptance criteria for “baseline + enhancements”

| ID | Criterion | Status |
| -- | --------- | ------ |
| — | — | — |

---

## References

- [`docs/DESIGN.md`](../../docs/DESIGN.md) — Android architecture, PR plan, UI/UX
- [`plans/server/current-baseline.md`](../server/current-baseline.md) — relay v1 contract
- [`ROADMAP.md`](../../ROADMAP.md) — PR progress
- [`AGENTS.md`](../../AGENTS.md) — session continuity