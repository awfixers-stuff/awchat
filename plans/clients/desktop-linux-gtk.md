# Client — Linux GTK desktop

| Field                    | Value                                              |
| ------------------------ | -------------------------------------------------- |
| **Status**               | Planned (Phase 2)                                  |
| **Created**              | 2026-06-08                                         |
| **Phase gate**           | Android + server at production standard (PR 24 GA) |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4)   |

---

## Summary

Native **Linux desktop** client using **GTK 4** and **libadwaita** (GNOME HIG). Targets power users and developers who want AWChat on the desktop without an emulator. Experimental per design doc — not a commitment to feature parity on every desktop OS.

---

## Goals

| ID  | Goal                                                        |
| --- | ----------------------------------------------------------- |
| G1  | Full E2EE 1:1 and group (≤5) against production relay `/v1` |
| G2  | X-Lite-inspired layout adapted to GTK adaptive patterns     |
| G3  | Encrypted local store (SQLCipher or platform equivalent)    |
| G4  | Plan 001 feedback with `client_platform: linux-gtk`         |
| G5  | CI on Linux (Blacksmith or Nix) — compile + unit tests      |

## Non-goals (v1 desktop)

- Windows port (community policy only)
- Wayland-only exotic compositor quirks beyond GNOME/KDE smoke
- Attachments (defer to design v1.1)
- Multi-device sync

---

## Stack (proposed)

| Layer      | Choice                          | Rationale                                                |
| ---------- | ------------------------------- | -------------------------------------------------------- |
| UI         | GTK 4 + libadwaita              | Native Linux UX; adaptive layouts                        |
| Language   | **Rust** preferred              | Share crypto with `libsignal` Rust crates; Ratatui reuse |
| Crypto     | `libsignal-protocol` (Rust)     | Align with server NIF version family                     |
| Local DB   | `rusqlite` + SQLCipher          | Match Android Room semantics                             |
| Network    | `reqwest` + `tokio-tungstenite` | REST signer + WS frames                                  |
| DI / state | Relm4 or custom MVU             | MVI-like unidirectional flow                             |

Alternative: C++ / gtkmm if Rust GTK bindings block — decision at Phase 2 kickoff.

---

## Repo placement

```
clients/linux-gtk/
  Cargo.toml
  src/
  resources/
  .github/          # optional dedicated workflow slice
```

Depends on extracted or shared protocol crate from Android `core:proto` definitions (protobuf / JSON frame types).

---

## UX mapping (from Android)

| Android (Compose)        | GTK equivalent                       |
| ------------------------ | ------------------------------------ |
| `ConversationListScreen` | `AdwNavigationView` + list           |
| `AccountDrawerSheet`     | `AdwNavigationDrawer` or preferences |
| `ChatScreen`             | Split view / navigation push         |
| `LockScreen`             | Full-window gate on resume           |
| Pinning failure          | Modal + support link                 |

---

## Dependencies

| Dependency                                                            | Notes                       |
| --------------------------------------------------------------------- | --------------------------- |
| Phase 1 GA                                                            | Frozen `/v1` relay contract |
| [`plans/android/current-baseline.md`](../android/current-baseline.md) | Reference implementation    |
| [`plans/server/current-baseline.md`](../server/current-baseline.md)   | API + auth                  |
| Plan 001                                                              | Feedback endpoints live     |

---

## Implementation phases (outline)

| Phase          | Scope                                                             |
| -------------- | ----------------------------------------------------------------- |
| **0 — Spike**  | GTK window + relay `GET /v1/health`; prove Rust libsignal session |
| **1 — Core**   | Registration, prekeys, REST signer, WS handshake                  |
| **2 — Data**   | SQLCipher schema port from Android entities                       |
| **3 — UI**     | Conversation list + thread (plaintext stub → E2EE)                |
| **4 — E2EE**   | Send/receive envelopes, receipts, purge                           |
| **5 — Polish** | App lock, feedback, pinning, packaging (.flatpak target)          |

---

## Acceptance criteria (Phase 2 GA)

1. Register, send, receive E2EE message with Android client in staging.
2. Seen-by-all purge deletes on both sides within design doc windows.
3. Bug report creates `[AWChat Linux GTK]` Linear issue.
4. Release bundle contains no `LINEAR_API_KEY`.
5. CI green on `ubuntu-latest` or Nix shell.

---

## References

- [`plans/clients/README.md`](./README.md) — portfolio phases
- [`docs/DESIGN.md`](../../docs/DESIGN.md) — community / experimental desktop note
