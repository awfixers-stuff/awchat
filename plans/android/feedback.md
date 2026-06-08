# Android — Support & bug reporting

| Field | Value |
| ----- | ----- |
| **Status** | Draft |
| **Created** | 2026-06-08 |
| **Depends on** | [`current-baseline.md`](./current-baseline.md); [Plan 001](../001-support-and-bug-reporting.md); [server/003](../server/003-feedback-linear-smtp.md) |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4) |

---

## Goals

1. Ship `feature:feedback` with MVI screens for bug report and support request.
2. Wire entry points into `AccountDrawerSheet` (PR 16) and pinning failure UX (PR 23).
3. Collect privacy-safe diagnostics via allowlisted `DeviceDiagnostics`.
4. Reuse `core:network` `RestAuthSigner` — no new auth mechanism.

Non-goals: WebView forms, Linear API in APK, screenshot upload (v1).

---

## Dependencies

| Dependency | State | Why |
| ---------- | ----- | --- |
| PR 11 `core:network` | **done** | `FeedbackApi` extends existing Ktor client + signer |
| PR 16 `feature:settings` | pending | `AccountDrawerSheet` host rows |
| PR 23 pinning | pending | Pinning failure → support deep link |
| Server plan 003 | pending | `POST /v1/feedback/*` endpoints live in staging |

---

## Module layout

```
feature/feedback/
  build.gradle.kts
  src/main/kotlin/.../
    BugReportScreen.kt
    BugReportViewModel.kt
    SupportScreen.kt
    SupportViewModel.kt
    navigation/FeedbackNavGraph.kt
```

**Gradle deps:** `core:domain`, `core:network`, `core:designsystem`, `core:common`

---

## Domain layer

Add to `core:domain`:

```kotlin
interface FeedbackRepository {
    suspend fun submitBugReport(report: BugReport): Result<LinearIssueRef>
    suspend fun submitSupportRequest(request: SupportRequest): Result<SupportSubmissionRef>
}
```

Use cases: `SubmitBugReportUseCase`, `SubmitSupportRequestUseCase`.

Models include `client_platform = "android"` in diagnostics (server may override from User-Agent as sanity check).

---

## Network layer

Add to `core:network`:

| Piece | Detail |
| ----- | ------ |
| `FeedbackApi` | `submitBugReport`, `submitSupportRequest` |
| DTOs | Match [Plan 001](../001-support-and-bug-reporting.md) shared contract |
| Auth | Existing `RestAuthSigner` on `POST` bodies |
| Errors | Map `401`, `429`, `502`, `503` to user-facing `FeedbackError` |

Repository impl: `FeedbackRepositoryImpl` in `core:network` or `core:database` per existing repo pattern — follow where other REST repos landed after PR 10.

---

## Diagnostics collector

`core:common` → `DeviceDiagnostics`:

| Field | Source |
| ----- | ------ |
| `client_platform` | constant `"android"` |
| `app_version` | `BuildConfig.VERSION_NAME` |
| `build_number` | `BuildConfig.VERSION_CODE` |
| `flavor` | `BuildConfig.BUILD_TYPE` mapped to `debug\|release` |
| `os_version` | `Build.VERSION.RELEASE` + API level |
| `device_model` | `Build.MODEL` |
| `locale` | `Locale.getDefault().toLanguageTag()` |

**Forbidden keys** (unit test must assert never serialized): message bodies, contact IDs, safety numbers, prekeys, SQLCipher paths, identity private material, sealed blob paths.

Aligned with design doc: *"Opt-in crash counts only; no message metadata"* for telemetry scope.

---

## UI

### Screens

1. **BugReportScreen** — title (5–120), description (10–4000), optional repro fields, submit, success shows Linear `issue_identifier` + copy link action.
2. **SupportScreen** — category chips (`account`, `billing`, `privacy`, `other`), message, optional email, submit, success confirmation.

Material 3 Expressive: same motion/shape as drawer; inline validation errors; no WebView.

### Entry points

| Location | Wiring |
| -------- | ------ |
| `AccountDrawerSheet` | Two list rows navigate to feedback nav graph |
| Pinning failure (PR 23) | Full-screen block + "Contact support" → `SupportScreen` |
| About (optional) | Long-press version → `BugReportScreen` with `pinning_enabled` in diagnostics |

### Degraded UX

When server returns `503` or network unreachable:

- Show retry + **"Open in email app"** fallback via `Intent.ACTION_SENDTO` + `mailto:` prefilled with support inbox from `BuildConfig.SUPPORT_EMAIL` (public address only).

---

## Implementation phases

| Phase | Scope |
| ----- | ----- |
| **A — Core** | Domain models, `FeedbackApi`, `FeedbackRepositoryImpl`, `DeviceDiagnostics` + unit tests |
| **B — Feature module** | ViewModels, screens, navigation, fake repo screenshot tests |
| **C — Integration** | Wire drawer (after PR 16); pinning link (after PR 23); staging E2E against relay 003 |
| **D — Hardening** | ProGuard keep rules for DTOs; emulator test for forbidden diagnostics keys |

---

## Acceptance criteria

| ID | Criterion |
| -- | --------- |
| AC-1 | Bug report from drawer returns Linear identifier on mocked/staging success |
| AC-2 | Support request shows queued confirmation on `202` |
| AC-3 | `401` shown when user not registered / signer fails |
| AC-4 | `429` shows rate-limit message with retry guidance |
| AC-5 | `DeviceDiagnostics` unit test fails if forbidden key added |
| AC-6 | Release APK `strings` / decompile grep finds no `LINEAR` / API key patterns |
| AC-7 | Pinning failure navigates to support without disabling pinning |

---

## References

- [Plan 001](../001-support-and-bug-reporting.md) — cross-cutting contract
- [`plans/server/003-feedback-linear-smtp.md`](../server/003-feedback-linear-smtp.md) — server endpoints
- [`docs/DESIGN.md`](../../docs/DESIGN.md) — PR 16 drawer, PR 23 pinning, telemetry