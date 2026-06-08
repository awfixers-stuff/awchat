# Plans

Post-roadmap and cross-cutting feature plans that extend beyond the 24-PR sequence in [`docs/DESIGN.md`](../docs/DESIGN.md).

Plans are organized by **product surface** (Android, server, future clients). Each subtree follows the same pattern:

1. **`current-baseline.md`** — what ships today and the v1 contract (handoff surface for enhancement work).
2. **Numbered enhancement plans** — deltas from the baseline with goals, architecture, acceptance criteria, and implementation phases.

The authoritative system design remains [`docs/DESIGN.md`](../docs/DESIGN.md) (rev 4). Plans **diff against** the design doc and baselines; they do not replace it until promoted into a numbered PR.

---

## Product phases

| Phase | Surfaces | Gate |
| ----- | -------- | ---- |
| **1 — Production MVP** | Android (`app/`, `core/*`) + server (`server/relay`, `server/broker`, `server/auth`) | 24-PR roadmap complete (PR 24); GA checklist in design doc |
| **2 — Desktop & TUI** | Linux GTK desktop, Ratatui TUI (macOS + Linux) | Phase 1 at production standard; shared relay contract frozen |
| **3 — Apple** | macOS desktop + iOS mobile | Phase 1 complete; Apple dev hardware available |
| **Community** | e.g. Windows volunteer port | Per [Community client ports](../docs/DESIGN.md#community-client-ports-eg-windows) policy in design doc |

---

## Plan index

### Cross-cutting

| # | Plan | Status | Depends on |
| --- | --- | --- | --- |
| 001 | [Support & bug reporting](./001-support-and-bug-reporting.md) | Draft | PR 11 (network); UI after PR 16; server [003](./server/003-feedback-linear-smtp.md) |

### Android (`plans/android/`)

| Doc | Purpose |
| --- | ------- |
| [current-baseline.md](./android/current-baseline.md) | Shipped modules, 24-PR progress, v1 client contract |
| [feedback.md](./android/feedback.md) | `feature:feedback`, diagnostics, drawer wiring (Plan 001 Android slice) |

### Server (`plans/server/`)

| # | Plan | Status | Depends on |
| --- | --- | --- | --- |
| — | [current-baseline.md](./server/current-baseline.md) | Baseline (post-PR 5 / PR 11) | — |
| 002 | [Redis + durable encrypted pipeline](./server/002-redis-durable-encrypted-pipeline.md) | In progress | current-baseline; Railway monorepo |
| 003 | [Feedback — Linear + SMTP](./server/003-feedback-linear-smtp.md) | Draft | current-baseline; Plan 001 |

### Future clients (`plans/clients/`)

| Doc | Phase | Status |
| --- | ----- | ------ |
| [README.md](./clients/README.md) | — | Portfolio index |
| [desktop-linux-gtk.md](./clients/desktop-linux-gtk.md) | 2 | Planned |
| [tui-ratatui.md](./clients/tui-ratatui.md) | 2 | Planned |
| [apple-macos-ios.md](./clients/apple-macos-ios.md) | 3 | Planned (hardware gate) |

---

## Conventions

| Convention | Rule |
| ---------- | ---- |
| **Baseline first** | Enhancement plans reference `current-baseline.md` and state what breaks or extends the v1 contract |
| **Auth** | Mutating relay REST uses `X-AWChat-*` XEdDSA signing per design doc — not JWT |
| **Secrets** | Never in client binaries; relay env only for Linear, SMTP, etc. |
| **Ship tracking** | When a plan ships, update its status here and in the plan file (implementing PR or commit) |
| **Promotion** | Cross-cutting plans (e.g. 001) stay **Plan PR A** until inserted into the 24-PR sequence |

---

## References

- [`docs/DESIGN.md`](../docs/DESIGN.md) — authoritative system design and 24-PR plan
- [`ROADMAP.md`](../ROADMAP.md) — live PR progress
- [`AGENTS.md`](../AGENTS.md) — agent handoff and session continuity
- [`RAILWAY.md`](../RAILWAY.md) — hosted server topology