# Client — TUI (Ratatui)

| Field | Value |
| ----- | ----- |
| **Status** | Planned (Phase 2) |
| **Created** | 2026-06-08 |
| **Phase gate** | Android + server at production standard (PR 24 GA) |
| **Platforms** | **macOS**, **Linux** |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4) |

---

## Summary

Terminal UI client using **Ratatui** for developers and minimalists. Same relay contract as Android; optimized keyboard-driven workflow. Ships in parallel with or shortly after Linux GTK desktop (Phase 2).

---

## Goals

| ID | Goal |
| --- | ---- |
| G1 | Usable 1:1 and group chat entirely in terminal |
| G2 | E2EE via Rust `libsignal-protocol` |
| G3 | Encrypted local DB (SQLCipher) |
| G4 | Plan 001 feedback with `client_platform: tui` |
| G5 | CI on macOS + Linux runners |

## Non-goals (v1 TUI)

- Mouse-heavy UI (optional click OK; keyboard first)
- Image/attachment rendering
- Windows terminal official support (community)
- Full emoji picker parity

---

## Stack (proposed)

| Layer | Choice |
| ----- | ------ |
| UI | Ratatui + Crossterm |
| Runtime | Tokio |
| Crypto / network | Shared crate with `clients/linux-gtk` where possible |
| Config | TOML in XDG config dir (`~/.config/awchat/`) |

---

## Repo placement

```
clients/tui/
  Cargo.toml
  src/
    app.rs          # MVU loop
    panes/          # list, thread, composer, lock
```

---

## UX sketch

```
┌ AWChat ──────────────────────────────┐
│ > alice                    2h  purge │
│   bob                      1d        │
├──────────────────────────────────────┤
│ alice                                │
│   Hello                              │
│   [Seen by all · deletes in 18h]     │
├──────────────────────────────────────┤
│ Compose: _                           │
└──────────────────────────────────────┘
  ^K commands  ^D send  ^L lock
```

Settings modal: theme, root warning, **Report bug**, **Contact support**.

---

## Platform notes

| Platform | Notes |
| -------- | ----- |
| **Linux** | Primary dev target; Nix flake optional dep |
| **macOS** | Terminal.app / iTerm2; Keychain for DB passphrase |
| **SSH** | Out of scope — local terminal only (no mosh-over-chat) |

---

## Dependencies

Same as [desktop-linux-gtk.md](./desktop-linux-gtk.md) Phase 2 gate. Prefer **shared Rust workspace** at `clients/` root for crypto + network crates consumed by GTK and TUI.

---

## Implementation phases (outline)

| Phase | Scope |
| ----- | ----- |
| **0 — Spike** | Ratatui event loop + health check |
| **1 — Shared core** | Extract `awchat-core` crate from GTK spike |
| **2 — Panes** | List + thread + lock screen |
| **3 — E2EE** | Wire send/receive + purge |
| **4 — Feedback** | TUI forms → Plan 001 API |
| **5 — Release** | `cargo install` + GitHub release artifacts |

---

## Acceptance criteria (Phase 2 GA)

1. macOS and Linux CI both pass integration tests.
2. Cross-chat with Android staging client succeeds.
3. Linear issues titled `[AWChat TUI]`.
4. Lock screen clears screen buffer on suspend (no message leak in scrollback — document limitation).

---

## References

- [`plans/clients/README.md`](./README.md)
- [`desktop-linux-gtk.md`](./desktop-linux-gtk.md) — shared Phase 2 work