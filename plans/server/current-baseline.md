# AWChat Relay Server — Current Baseline

| Field                    | Value                                                                                     |
| ------------------------ | ----------------------------------------------------------------------------------------- |
| **Status**               | Baseline capture (post-PR 5 / PR 11)                                                      |
| **Created**              | 2026-06-08                                                                                |
| **Updated**              | 2026-06-08 (feedback plan 003 added)                                                      |
| **Purpose**              | Record what the relay ships today and the v1 contract it fulfills before enhancement work |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4)                                          |
| **Module path**          | `server/relay/`                                                                           |

---

## Summary

AWChat ships a **relay server skeleton** at `server/relay/` (PR 5) and an Android **network client** at `core/network/` (PR 11). The relay is a dumb encrypted relay — it stores and forwards ciphertext but never decrypts message bodies.

This document is the handoff surface for server enhancement work: it states the **current baseline** (shipped skeleton + v1 contract) so follow-on plans can diff against it.

---

## Implementation status (as of 2026-06-08)

| Artifact                         | State                                              |
| -------------------------------- | -------------------------------------------------- |
| `server/relay/`                  | **Shipped** (Elixir/Gleam/Rust umbrella)           |
| Ecto migrations                  | **Shipped** (`apps/gateway/priv/repo/migrations/`) |
| Docker Compose for local relay   | **Shipped** (`server/relay/docker-compose.yml`)    |
| Elixir gateway application       | **Shipped** (`apps/gateway`)                       |
| PostgreSQL schema                | **Implemented** (+ signed/kyber prekey tables)     |
| Rust `libsignal-core` verify NIF | **Shipped** (XEdDSA REST + WS; no decrypt)         |
| Client network layer             | **Shipped** (`core/network` — PR 11)               |
| CI for relay                     | **Shipped** (`.github/workflows/relay.yml`)        |
| Feature UI / E2EE messaging      | **Pending** (PRs 13–22)                            |

**Related client work already shipped:** `core:crypto` (SessionManager, identity sealing, `UserId` derivation) and `core:network` (REST signer, WS client, auth handshake frames). End-to-end messaging still requires feature modules (PRs 18–19).

---

## Role and constraints

The relay is a **dumb encrypted relay**. It is the entire AWChat backend in v1 — there is no separate “chat server” vs “relay”; `server/relay` **is** the server.

| Principle                    | Detail                                                                                                                       |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| No plaintext                 | Server never decrypts message bodies, receipts, or sender-key material                                                       |
| No custom crypto             | Uses `libsignal-core` (Rust NIF) only for **XEdDSA signature verification** on REST and WebSocket auth                       |
| Client-owned retention logic | “Seen by all” and 24h-after-seen purge deadlines are computed on clients; server executes signed purge requests and hard TTL |
| Minimal metadata             | No `last_receipt_at` or server-side read-receipt aggregation                                                                 |
| Single node (v1)             | One Elixir OTP node (Bandit); in-memory `userId → WebSocket` map; offline queue in Postgres                                  |
| No push (v1)                 | No FCM; delivery requires foreground app / active WebSocket (NG8)                                                            |
| Scale target                 | ~1k users MVP; HA / multi-node deferred to v2                                                                                |

---

## Planned stack and operations

| Layer                 | Choice                                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Runtime               | **Elixir** (Bandit/OTP) + **Gleam** (`packages/core`) + **Rust** NIF                                                           |
| Database              | **PostgreSQL** (envelope source of truth); **Redis** on hosted stack per [Plan 002](./002-redis-durable-encrypted-pipeline.md) |
| Migrations            | **Ecto** (`mix ecto.migrate` / `Gateway.Release.migrate/0`)                                                                    |
| Crypto library        | `libsignal-core` (Rust, v0.86.x) — XEdDSA verify only                                                                          |
| Deploy (default)      | Single **Railway** project (relay service + Railway Postgres)                                                                  |
| Secrets               | `DATABASE_URL`, TLS cert — **no server keystore**                                                                              |
| Health                | `GET /v1/health` (liveness), `GET /v1/ready` (DB + migration version)                                                          |
| TTL job               | Cron every **15 min** — hard-delete expired envelopes                                                                          |
| Nonce cleanup         | Cron every **5 min** — delete expired `auth_nonces`                                                                            |
| Graceful shutdown     | SIGTERM → stop accepting WS, drain 10s, finish in-flight acks                                                                  |
| Observability (PR 24) | Prometheus: `envelopes_stored`, `purge_lag_seconds`, `ws_connections`, `ack_latency_ms`                                        |

---

## Responsibilities (what the relay is designed to do)

| Responsibility         | Server knowledge                   | Notes                                                                           |
| ---------------------- | ---------------------------------- | ------------------------------------------------------------------------------- |
| User registration      | Public identity key + pre-keys     | `POST /v1/register` — no auth                                                   |
| Pre-key hosting        | Public one-time pre-keys           | `GET /v1/prekeys/{userId}` — no auth                                            |
| Ciphertext storage     | Opaque blobs + routing fields      | `message_envelopes` table                                                       |
| Live delivery          | Fan-out via in-memory WS map       | Per connected `userId`                                                          |
| Offline queue          | Same ciphertext in Postgres        | Max **48h** (`created_at` / `purge_after`); **deleted immediately on full ack** |
| Chat membership        | Member IDs, chat type, size ≤ 5    | Direct + group; no plaintext chat names on server in v1 spec                    |
| Group size enforcement | Member count                       | Reject > 5 on create/patch                                                      |
| Delivery tracking      | `envelope_recipients.delivered_at` | Updated on client `ack`                                                         |
| Redelivery             | Resend on reconnect / missing ack  | Missing ack within **30s** → redeliver on next WS connect                       |
| Client-initiated purge | Signed `POST /v1/purge`            | Idempotent via `purge_audit`                                                    |
| Purge broadcast        | `purge_notify` WS frame            | To all `chat_members`                                                           |
| Hard TTL safety net    | Timestamps only                    | Delete if `created_at < now() - 48h` OR `purge_after < now()`                   |
| Authentication         | Identity public keys               | XEdDSA on REST (mutating) and WS handshake                                      |
| Optional presence      | `users.last_seen_at`               | Updated on WS heartbeat                                                         |

---

## Explicit non-responsibilities

The relay is **not** designed to:

- Decrypt or inspect `InnerMessage` protobuf types (`CHAT`, `READ_RECEIPT`, `SENDER_KEY_DIST`, `PURGE_ACK`)
- Aggregate read receipts or decide “seen by all”
- Store message history beyond the 48h envelope ceiling
- Provide search, backup, or multi-device sync
- Federate with other servers or use P2P transport
- Wake clients in the background (no FCM in v1)
- Hold server private keys for user identities (clients own keys)
- Run MLS, Matrix, or custom ratchet protocols

---

## API surface (v1 contract)

### REST

| Method  | Path                         | Auth     | Description                                                    |
| ------- | ---------------------------- | -------- | -------------------------------------------------------------- |
| `POST`  | `/v1/register`               | None     | Upload identity + pre-keys                                     |
| `GET`   | `/v1/prekeys/{userId}`       | None     | Fetch pre-key bundle                                           |
| `POST`  | `/v1/chats`                  | REST sig | Create/upsert chat; caller must be in `memberIds`; ≤ 5 members |
| `GET`   | `/v1/chats/{chatId}`         | None     | Membership sync                                                |
| `PATCH` | `/v1/chats/{chatId}/members` | REST sig | Add/remove members; forbidden on direct chats (`409`)          |
| `POST`  | `/v1/purge`                  | REST sig | Idempotent ciphertext deletion + `purge_notify` broadcast      |
| `GET`   | `/v1/health`                 | None     | Liveness                                                       |
| `GET`   | `/v1/ready`                  | None     | Readiness (DB reachable, migrations applied)                   |

### WebSocket

| Path     | Auth                        | Purpose                                   |
| -------- | --------------------------- | ----------------------------------------- |
| `/v1/ws` | WS handshake (first frames) | Bidirectional JSON frames (catalog below) |

---

## Authentication

### REST (mutating endpoints)

Required headers: `X-AWChat-User-Id`, `X-AWChat-Timestamp`, `X-AWChat-Signature`.

Signed input (UTF-8, pipe-delimited):

```
method + "|" + path + "|" + base64(SHA-256(bodyBytes)) + "|" + timestamp + "|" + userId
```

| Rule                | Value                                            |
| ------------------- | ------------------------------------------------ |
| Signature algorithm | XEdDSA via libsignal                             |
| Replay window       | Reject if `abs(serverNow - timestamp) > 120s`    |
| Identity lookup     | Load `users.identity_key` for `X-AWChat-User-Id` |

**Per-endpoint authorization (after valid signature):**

| Endpoint                           | Rule                                               |
| ---------------------------------- | -------------------------------------------------- |
| `POST /v1/chats`                   | Caller must appear in request `memberIds`          |
| `PATCH /v1/chats/{chatId}/members` | Caller must be current `chat_members` row          |
| `POST /v1/purge`                   | Caller must be `chat_members` for `chatId` in body |

### WebSocket handshake

1. Server → `auth_challenge` (32-byte nonce, `serverTime`, `ttlSec: 120`)
2. Client signs: `nonceRaw[32B] + "|" + userId + "|" + serverTime` (raw nonce bytes, not base64 wire form)
3. Client → `auth_response`
4. Server verifies: nonce unused, clock window, XEdDSA valid → `auth_ok` + `connectionId`
5. On failure → `auth_failed`; close WS (4001 generic, 4002 nonce expired)

Nonces stored in `auth_nonces` (BYTEA PK), single-use, `expires_at = now() + 2 min`.

---

## WebSocket frame catalog (v1)

All frames are JSON with a `type` field.

| `type`               | Direction     | Purpose                                                               |
| -------------------- | ------------- | --------------------------------------------------------------------- |
| `auth_challenge`     | S → C         | First frame after connect                                             |
| `auth_response`      | C → S         | Signed identity proof                                                 |
| `auth_ok`            | S → C         | Session established                                                   |
| `auth_failed`        | S → C         | Handshake rejected                                                    |
| `envelope`           | Bidirectional | Ciphertext relay (`id`, `chatId`, `senderId`, `ciphertext`, `sentAt`) |
| `ack`                | C → S         | `{ envelopeId, receivedAt }` — persisted locally                      |
| `nack`               | C → S         | `{ envelopeId, reason }` — schedule redelivery                        |
| `chat_created`       | S → C         | New group chat notification                                           |
| `membership_changed` | S → C         | Group add/remove broadcast                                            |
| `purge_notify`       | S → C         | `{ messageId, chatId, purgedAt }` — clients delete immediately        |
| `error`              | S → C         | Non-fatal (e.g. `rate_limited`)                                       |

**Delivery semantics:** at-least-once; clients dedupe by envelope `id` (ULID). Client sends `ack` only after Room transaction commits.

---

## Data model (PostgreSQL)

Ecto schema (`server/relay/apps/gateway/priv/repo/migrations/`):

| Table                 | Purpose                                                                    |
| --------------------- | -------------------------------------------------------------------------- |
| `users`               | `id` (awchat:…), `identity_key`, `created_at`, `last_seen_at`              |
| `prekeys`             | One-time pre-keys per user (`consumed` flag)                               |
| `chats`               | `id`, `type` (`direct` \| `group`), `created_at`                           |
| `chat_members`        | Many-to-many membership                                                    |
| `message_envelopes`   | `id`, `chat_id`, `sender_id`, `ciphertext`, `created_at`, `purge_after`    |
| `envelope_recipients` | Per-recipient delivery (`delivered_at` on ack); CASCADE on envelope delete |
| `auth_nonces`         | WS handshake replay protection                                             |
| `purge_audit`         | Idempotent purge log (`message_id` PK, `purge_received_at`)                |

**Storage estimate:** ~200 MB ciphertext at 1k users × 50 msgs/day × 2 KB × 48h retention → plan **500 MB–1 GB** Postgres.

**TTL cron (authoritative server deletion):**

```sql
DELETE FROM message_envelopes
WHERE created_at < NOW() - INTERVAL '48 hours'
   OR purge_after < NOW();
```

---

## Chat lifecycle (server participation)

### Direct (1:1)

| Step                     | Server role                                                                   |
| ------------------------ | ----------------------------------------------------------------------------- |
| Client derives `chat_id` | `dm_` + base32(SHA-256(sorted member IDs))) — both clients agree              |
| First send               | Client `POST /v1/chats` — server upserts chat + 2 `chat_members` (idempotent) |
| Messaging                | WS `envelope` relay; offline → Postgres queue                                 |
| Membership changes       | **Forbidden** (`409` on PATCH)                                                |

### Group (2–5 members)

| Step           | Server role                                                                                                     |
| -------------- | --------------------------------------------------------------------------------------------------------------- |
| Create         | Client `POST /v1/chats` — server assigns `grp_` + ULID                                                          |
| Notify         | WS `chat_created` to members                                                                                    |
| Member changes | Signed `PATCH .../members` — server validates count, broadcasts `membership_changed`                            |
| Crypto         | Server only relays ciphertext; sender-key distribution is client-side via encrypted `SENDER_KEY_DIST` envelopes |

Server relays **FIFO per chat**; clients buffer out-of-order sender-key dist up to 60s.

---

## Retention and purge (server role)

| Layer                 | Rule                                         | Trigger                                  |
| --------------------- | -------------------------------------------- | ---------------------------------------- |
| Client purge deadline | Delete locally 24h after seen-by-all         | Client receipt aggregation (inside E2EE) |
| Client → server purge | `POST /v1/purge` when seen-by-all            | Any participant; signed REST             |
| Server `purge_after`  | Default `sent_at + 48h` on outbound envelope | Client sets on send                      |
| Server hard TTL       | 48h absolute ceiling                         | Cron every 15 min                        |
| Offline queue         | Same 48h ceiling                             | `created_at` on envelope                 |

**Purge flow (server steps):**

1. Verify REST auth; caller ∈ `chat_members`
2. `INSERT INTO purge_audit ... ON CONFLICT DO NOTHING RETURNING message_id`
3. If no row returned → already purged → `200 OK` (idempotent)
4. Else `DELETE FROM message_envelopes WHERE id = :messageId` (recipients CASCADE)
5. Broadcast `purge_notify` to all members

Server records `purge_received_at = now()` — does **not** trust client wall clock for audit.

---

## Roadmap: when each capability lands

| PR        | Server work                                                                                                                                | Status   |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| **PR 5**  | Skeleton: Elixir/Bandit, Postgres schema, register/prekeys, health/ready, REST auth middleware, WS frame parsing, Docker Compose, relay CI | **done** |
| **PR 21** | Purge endpoint hardening, TTL job, WS `purge_notify` broadcast (partially in PR 5)                                                         | pending  |
| **PR 24** | Observability, relay deploy docs                                                                                                           | pending  |

**Client coupling:**

| PR     | Depends on relay                                                 | Status   |
| ------ | ---------------------------------------------------------------- | -------- |
| PR 11  | `core:network` — REST signer, WS handshake, all frames           | **done** |
| PR 13+ | Onboarding registers with relay; messaging features assume PR 11 | pending  |

---

## Known extensions (not in v1 baseline)

These are **out of scope** for the current design baseline but appear in adjacent planning:

| Source                                                                    | Extension                                                                                                  |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [Plan 001 — Support & bug reporting](../001-support-and-bug-reporting.md) | Cross-cutting feedback goals; auth + privacy aligned with design doc                                       |
| [Plan 003 — Feedback Linear + SMTP](./003-feedback-linear-smtp.md)        | `POST /v1/feedback/bug`, `POST /v1/feedback/support`; Linear GraphQL; Resend email; `feedback_submissions` |
| `docs/DESIGN.md` v1.1 appendix                                            | FCM wake-up, attachments                                                                                   |
| [Plan 002](./002-redis-durable-encrypted-pipeline.md)                     | Redis hot pending index, broker Redis rate limits, aggressive PG durability, serverless/teardown ops       |
| [Phase 2+ clients](../clients/README.md)                                  | Linux GTK, Ratatui TUI — same `/v1` contract, `client_platform` diagnostics                                |
| v2 (deferred)                                                             | Multi-node HA, sticky sessions, shared pub/sub beyond Plan 002                                             |

---

## Enhancement workspace

Use this section to track deltas from the baseline. _(Empty — fill in during enhancement planning.)_

### Open questions

| ID  | Question | Notes |
| --- | -------- | ----- |
| —   | —        | —     |

### Proposed additions / changes

| ID  | Change                       | Rationale                                                      | Breaks v1 contract? |
| --- | ---------------------------- | -------------------------------------------------------------- | ------------------- |
| E1  | Feedback REST endpoints      | Plan 001 / 003 — operational plaintext separate from E2EE path | No — additive       |
| E2  | `feedback_submissions` table | Rate limit audit per `user_id`                                 | No — additive       |
| E3  | Linear + Resend integrations | Server-mediated bug/support                                    | No — external only  |

### Acceptance criteria for “baseline + enhancements”

| ID  | Criterion | Status |
| --- | --------- | ------ |
| —   | —         | —      |

---

## References

- [`docs/DESIGN.md`](../../docs/DESIGN.md) — § Relay Server Design, WebSocket Frame Catalog, REST Request Authentication, Retention Policy, PR 5
- [`AGENTS.md`](../../AGENTS.md) — roadmap state; PR 5 and PR 11 complete; PR 12 in progress
- [`server/relay/README.md`](../../server/relay/README.md) — local dev and Railway deploy
- [`plans/001-support-and-bug-reporting.md`](../001-support-and-bug-reporting.md) — cross-cutting feedback
- [`plans/server/003-feedback-linear-smtp.md`](./003-feedback-linear-smtp.md) — relay implementation
- [`plans/clients/README.md`](../clients/README.md) — future client surfaces
