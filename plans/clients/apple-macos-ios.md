# Client — Apple (macOS desktop + iOS mobile)

| Field | Value |
| ----- | ----- |
| **Status** | Planned (Phase 3) |
| **Created** | 2026-06-08 |
| **Phase gate** | Phase 1 GA **and** Phase 2 clients in beta; **Apple developer hardware available** |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4) |

---

## Summary

**macOS desktop** and **iOS mobile** clients after Android and server reach production quality. Design doc lists iOS as NG4 (non-goal for v1 MVP); this plan captures intent once hardware and capacity exist.

Single `clients/apple/` subtree with shared Swift/SwiftUI (or Rust FFI core) across platforms where Apple HIG allows.

---

## Goals

| ID | Goal |
| --- | ---- |
| G1 | iOS App Store + macOS notarized desktop distribution |
| G2 | E2EE parity with Android against `/v1` relay |
| G3 | Keychain + Secure Enclave for DB passphrase and unlock gates |
| G4 | Plan 001 feedback — `client_platform: ios` / `macos` |
| G5 | Shared UI code via SwiftUI multiplatform (iOS 17+, macOS 14+) |

## Non-goals (initial Apple v1)

- watchOS, tvOS, visionOS
- iCloud backup of message history (violates ephemerality)
- APNS background delivery until design v1.1 (same NG8 constraint as Android)

---

## Hardware gate

| Requirement | Why |
| ----------- | --- |
| Apple Developer Program membership | Signing, TestFlight |
| Physical iPhone + Mac | Device testing, Keychain, biometric flows |
| CI macOS runner | Xcode build (`blacksmith` or MacStadium / GitHub macOS) |

**Do not start implementation** until gate is met — planning only.

---

## Stack (proposed — TBD at kickoff)

| Layer | Leading option | Alternative |
| ----- | -------------- | ----------- |
| UI | SwiftUI | — |
| Crypto | Rust `libsignal` via FFI bridge | libsignal Swift if mature enough |
| Local DB | GRDB + SQLCipher | Core Data + encryption wrapper |
| Network | URLSession + WebSocket | Shared Rust tokio crate via FFI |

Decision recorded in ADR at Phase 3 kickoff.

---

## Repo placement

```
clients/apple/
  AWChat.xcworkspace
  AWChatIOS/
  AWChatMac/
  AWChatCore/       # shared models, FFI
  rust/             # optional libsignal bridge
```

---

## UX mapping

| Android | Apple |
| ------- | ----- |
| Material 3 Expressive | SwiftUI + platform materials |
| `AccountDrawerSheet` | Settings / sidebar (macOS) · sheet (iOS) |
| Biometric lock | Face ID / Touch ID |
| Pinning | TrustKit or custom SPKI pins |

---

## Dependencies

| Dependency | Notes |
| ---------- | ----- |
| Phase 1 GA | Production relay |
| Phase 2 | Lessons from Rust core extraction (GTK/TUI) |
| Plan 001 | Feedback API stable |
| Legal | AGPL + App Store compliance review (same as Android GA) |

---

## Implementation phases (outline)

| Phase | Scope |
| ----- | ----- |
| **0 — ADR** | Swift vs Rust FFI; monorepo layout |
| **1 — Core FFI** | Port SessionManager; Keychain sealing |
| **2 — iOS spike** | Onboarding + register against staging |
| **3 — macOS spike** | Multiplatform SwiftUI shell |
| **4 — E2EE** | Thread UI, send/receive, purge |
| **5 — Hardening** | Pinning, duress, TestFlight β |
| **6 — Store** | App Store + notarized macOS |

---

## Acceptance criteria (Phase 3 GA)

1. iOS TestFlight and macOS notarized build install on physical devices.
2. Cross-platform chat with Android production relay.
3. Linear issues use `[AWChat iOS]` / `[AWChat macOS]` titles.
4. No secrets in IPA/.app strings dump.
5. App Lock survives background/foreground per Apple HIG.

---

## Open questions

| ID | Question | Default |
| -- | -------- | ------- |
| OQ1 | Single universal binary vs separate targets? | Separate targets, shared `AWChatCore` |
| OQ2 | macOS menu bar mini client? | Defer post-GA |
| OQ3 | APNS in Apple v1 or wait for design v1.1? | Wait — foreground delivery first |

---

## References

- [`plans/clients/README.md`](./README.md) — Phase 3 gate
- [`docs/DESIGN.md`](../../docs/DESIGN.md) — NG4 iOS non-goal for MVP
- [`plans/android/current-baseline.md`](../android/current-baseline.md) — reference client