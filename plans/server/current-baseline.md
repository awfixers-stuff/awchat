# AWChat Relay Server — Current Baseline

| Field              | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| **Status**         | Baseline capture (pre-implementation)                          |
| **Created**        | 2026-06-08                                                       |
| **Purpose**        | Record what the relay does today (nothing shipped) and the v1 spec it is designed to fulfill before enhancement work |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4)         |
| **Module path**    | `server/relay/` (not present in repo yet)                      |

---

## Summary

AWChat has **no relay server code in the repository today**. The backend is fully specified in `docs/DESIGN.md` and scheduled as **PR 5** (`server:relay` skeleton). Until that lands, all server behavior described below is **design intent**, not running software.

This document is the handoff surface for server enhancement work: it states the **current baseline** (zero implementation + v1 contract) so follow-on plans can diff against it.

---

## Implementation status (as of 2026-06-08)

| Artifact                         | State                                              |
| -------------------------------- | -------------------------------------------------- |
| `server/relay/`                  | **Missing**                                        |
| Flyway migrations                | **Missing** (`V1__init.sql` planned in PR 5)       |
| Docker Compose for local relay   | **Missing** (planned in PR 5)                      |
| Ktor application                 | **Missing**                                        |
| PostgreSQL schema                | **Specified only** (see Data model)                |
| `libsignal-client` JVM on server | **Specified only** (XEdDSA verify; no decrypt)     |
| Client network layer             | **Missing** (`core:network` in PR 11)              |
| CI for relay                     | **Missing** (Testcontainers test planned in PR 5)  |

**Related client work already shipped:** `core:crypto` (SessionManager, identity sealing, `UserId` derivation) — the Android side can encrypt/decrypt; it has nothing to talk to yet.

---

## Role and constraints

The relay is a **dumb encrypted relay**. It is the entire AWChat backend in v1 — there is no separate “chat server” vs “relay”; `server/relay` **is** the server.

| Principle | Detail |
| --------- | ------ |
| No plaintext | Server never decrypts message bodies, receipts, or sender-key material |
| No custom crypto | Uses `libsignal-client` (JVM) only for **XEdDSA signature verification** on REST and WebSocket auth |
| Client-owned retention logic | “Seen by all” and 24h-after-seen purge deadlines are computed on clients; server executes signed purge requests and hard TTL |
| Minimal metadata | No `last_receipt_at` or server-side read-receipt aggregation |
| Single node (v1) | One Ktor process; in-memory `userId → WebSocket` map; offline queue in Postgres |
| No push (v1) | No FCM; delivery requires foreground app / active WebSocket (NG8) |
| Scale target | ~1k users MVP; HA / multi-node deferred to v2 |

---

## Planned stack and operations

| Layer | Choice |
| ----- | ------ |
| Runtime | Kotlin **Ktor** |
| Database | **PostgreSQL only** (no Redis in v1) |
| Migrations | **Flyway** on container start (blocks readiness until complete) |
| Crypto library | `org.signal:libsignal-client` (JVM) — verify only |
| Deploy (default) | Single **Fly.io** machine + Fly Postgres |
| Secrets | `DATABASE_URL`, TLS cert — **no server keystore** |
| Health | `GET /v1/health` (liveness), `GET /v1/ready` (DB + migration version) |
| TTL job | Cron every **15 min** — hard-delete expired envelopes |
| Nonce cleanup | Cron every **5 min** — delete expired `auth_nonces` |
| Graceful shutdown | SIGTERM → stop accepting WS, drain 10s, finish in-flight acks |
| Observability (PR 24) | Prometheus: `envelopes_stored`, `purge_lag_seconds`, `ws_connections`, `ack_latency_ms` |

---

## Responsibilities (what the relay is designed to do)

| Responsibility | Server knowledge | Notes |
| -------------- | ---------------- | ----- |
| User registration | Public identity key + pre-keys | `POST /v1/register` — no auth |
| Pre-key hosting | Public one-time pre-keys | `GET /v1/prekeys/{userId}` — no auth |
| Ciphertext storage | Opaque blobs + routing fields | `message_envelopes` table |
| Live delivery | Fan-out via in-memory WS map | Per connected `userId` |
| Offline queue | Same ciphertext in Postgres | Max **48h** (`created_at` / `purge_after`) |
| Chat membership | Member IDs, chat type, size ≤ 5 | Direct + group; no plaintext chat names on server in v1 spec |
| Group size enforcement | Member count | Reject > 5 on create/patch |
| Delivery tracking | `envelope_recipients.delivered_at` | Updated on client `ack` |
| Redelivery | Resend on reconnect / missing ack | Missing ack within **30s** → redeliver on next WS connect |
| Client-initiated purge | Signed `POST /v1/purge` | Idempotent via `purge_audit` |
| Purge broadcast | `purge_notify` WS frame | To all `chat_members` |
| Hard TTL safety net | Timestamps only | Delete if `created_at < now() - 48h` OR `purge_after < now()` |
| Authentication | Identity public keys | XEdDSA on REST (mutating) and WS handshake |
| Optional presence | `users.last_seen_at` | Updated on WS heartbeat |

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

| Method | Path | Auth | Description |
| ------ | ---- | ---- | ----------- |
| `POST` | `/v1/register` | None | Upload identity + pre-keys |
| `GET` | `/v1/prekeys/{userId}` | None | Fetch pre-key bundle |
| `POST` | `/v1/chats` | REST sig | Create/upsert chat; caller must be in `memberIds`; ≤ 5 members |
| `GET` | `/v1/chats/{chatId}` | None | Membership sync |
| `PATCH` | `/v1/chats/{chatId}/members` | REST sig | Add/remove members; forbidden on direct chats (`409`) |
| `POST` | `/v1/purge` | REST sig | Idempotent ciphertext deletion + `purge_notify` broadcast |
| `GET` | `/v1/health` | None | Liveness |
| `GET` | `/v1/ready` | None | Readiness (DB reachable, migrations applied) |

### WebSocket

| Path | Auth | Purpose |
| ---- | ---- | ------- |
| `/v1/ws` | WS handshake (first frames) | Bidirectional JSON frames (catalog below) |

---

## Authentication

### REST (mutating endpoints)

Required headers: `X-AWChat-User-Id`, `X-AWChat-Timestamp`, `X-AWChat-Signature`.

Signed input (UTF-8, pipe-delimited):

```
method + "|" + path + "|" + base64(SHA-256(bodyBytes)) + "|" + timestamp + "|" + userId
```

| Rule | Value |
| ---- | ----- |
| Signature algorithm | XEdDSA via libsignal |
| Replay window | Reject if `abs(serverNow - timestamp) > 120s` |
| Identity lookup | Load `users.identity_key` for `X-AWChat-User-Id` |

**Per-endpoint authorization (after valid signature):**

| Endpoint | Rule |
| -------- | ---- |
| `POST /v1/chats` | Caller must appear in request `memberIds` |
| `PATCH /v1/chats/{chatId}/members` | Caller must be current `chat_members` row |
| `POST /v1/purge` | Caller must be `chat_members` for `chatId` in body |

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

| `type` | Direction | Purpose |
| ------ | --------- | ------- |
| `auth_challenge` | S → C | First frame after connect |
| `auth_response` | C → S | Signed identity proof |
| `auth_ok` | S → C | Session established |
| `auth_failed` | S → C | Handshake rejected |
| `envelope` | Bidirectional | Ciphertext relay (`id`, `chatId`, `senderId`, `ciphertext`, `sentAt`) |
| `ack` | C → S | `{ envelopeId, receivedAt }` — persisted locally |
| `nack` | C → S | `{ envelopeId, reason }` — schedule redelivery |
| `chat_created` | S → C | New group chat notification |
| `membership_changed` | S → C | Group add/remove broadcast |
| `purge_notify` | S → C | `{ messageId, chatId, purgedAt }` — clients delete immediately |
| `error` | S → C | Non-fatal (e.g. `rate_limited`) |

**Delivery semantics:** at-least-once; clients dedupe by envelope `id` (ULID). Client sends `ack` only after Room transaction commits.

---

## Data model (PostgreSQL)

Planned Flyway schema (`server/relay`):

| Table | Purpose |
| ----- | ------- |
| `users` | `id` (awchat:…), `identity_key`, `created_at`, `last_seen_at` |
| `prekeys` | One-time pre-keys per user (`consumed` flag) |
| `chats` | `id`, `type` (`direct` \| `group`), `created_at` |
| `chat_members` | Many-to-many membership |
| `message_envelopes` | `id`, `chat_id`, `sender_id`, `ciphertext`, `created_at`, `purge_after` |
| `envelope_recipients` | Per-recipient delivery (`delivered_at` on ack); CASCADE on envelope delete |
| `auth_nonces` | WS handshake replay protection |
| `purge_audit` | Idempotent purge log (`message_id` PK, `purge_received_at`) |

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

| Step | Server role |
| ---- | ----------- |
| Client derives `chat_id` | `dm_` + base32(SHA-256(sorted member IDs))) — both clients agree |
| First send | Client `POST /v1/chats` — server upserts chat + 2 `chat_members` (idempotent) |
| Messaging | WS `envelope` relay; offline → Postgres queue |
| Membership changes | **Forbidden** (`409` on PATCH) |

### Group (2–5 members)

| Step | Server role |
| ---- | ----------- |
| Create | Client `POST /v1/chats` — server assigns `grp_` + ULID |
| Notify | WS `chat_created` to members |
| Member changes | Signed `PATCH .../members` — server validates count, broadcasts `membership_changed` |
| Crypto | Server only relays ciphertext; sender-key distribution is client-side via encrypted `SENDER_KEY_DIST` envelopes |

Server relays **FIFO per chat**; clients buffer out-of-order sender-key dist up to 60s.

---

## Retention and purge (server role)

| Layer | Rule | Trigger |
| ----- | ---- | ------- |
| Client purge deadline | Delete locally 24h after seen-by-all | Client receipt aggregation (inside E2EE) |
| Client → server purge | `POST /v1/purge` when seen-by-all | Any participant; signed REST |
| Server `purge_after` | Default `sent_at + 48h` on outbound envelope | Client sets on send |
| Server hard TTL | 48h absolute ceiling | Cron every 15 min |
| Offline queue | Same 48h ceiling | `created_at` on envelope |

**Purge flow (server steps):**

1. Verify REST auth; caller ∈ `chat_members`
2. `INSERT INTO purge_audit ... ON CONFLICT DO NOTHING RETURNING message_id`
3. If no row returned → already purged → `200 OK` (idempotent)
4. Else `DELETE FROM message_envelopes WHERE id = :messageId` (recipients CASCADE)
5. Broadcast `purge_notify` to all members

Server records `purge_received_at = now()` — does **not** trust client wall clock for audit.

---

## Roadmap: when each capability lands

| PR | Server work |
| -- | ----------- |
| **PR 5** | Skeleton: Ktor, Postgres schema, register/prekeys, health/ready, REST auth middleware, WS frame parsing, Docker Compose, Testcontainers |
| **PR 21** | Purge endpoint, TTL job, WS `purge_notify` broadcast (may overlap PR 5 scope per design) |
| **PR 24** | Observability, relay deploy docs |

**Client coupling:**

| PR | Depends on relay |
| -- | ---------------- |
| PR 11 | `core:network` — REST signer, WS handshake, all frames |
| PR 13+ | Onboarding registers with relay; messaging features assume PR 11 |

---

## Known extensions (not in v1 baseline)

These are **out of scope** for the current design baseline but appear in adjacent planning:

| Source | Extension |
| ------ | --------- |
| [Plan 001 — Support & bug reporting](../001-support-and-bug-reporting.md) | `POST /v1/feedback/bug`, `POST /v1/feedback/support` on relay; Linear + email; rate-limited |
| `docs/DESIGN.md` v1.1 appendix | FCM wake-up, attachments |
| v2 (deferred) | Multi-node HA, Redis/sticky sessions, shared pub/sub |

---

## Enhancement workspace

Use this section to track deltas from the baseline. *(Empty — fill in during enhancement planning.)*

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

- [`docs/DESIGN.md`](../../docs/DESIGN.md) — § Relay Server Design, WebSocket Frame Catalog, REST Request Authentication, Retention Policy, PR 5
- [`AGENTS.md`](../../AGENTS.md) — roadmap state; PR 5 not started
- [`plans/001-support-and-bug-reporting.md`](../001-support-and-bug-reporting.md) — relay extensions for feedback