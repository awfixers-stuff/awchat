# Server — Feedback (Linear + SMTP)

| Field                    | Value                                                                                           |
| ------------------------ | ----------------------------------------------------------------------------------------------- |
| **Status**               | Draft                                                                                           |
| **Created**              | 2026-06-08                                                                                      |
| **Depends on**           | [`current-baseline.md`](./current-baseline.md); [Plan 001](../001-support-and-bug-reporting.md) |
| **Authoritative design** | [`docs/DESIGN.md`](../../docs/DESIGN.md) (rev 4)                                                |
| **Module path**          | `server/relay/apps/gateway`                                                                     |

---

## Goals

1. Add `POST /v1/feedback/bug` and `POST /v1/feedback/support` to the relay v1 API.
2. Create Linear issues via GraphQL without exposing `LINEAR_API_KEY` to clients.
3. Send support email to Basecamp inbox via transactional SMTP (Resend default).
4. Rate-limit per authenticated `user_id`; audit in Postgres `feedback_submissions`.
5. Expose Prometheus counters (wired fully in PR 24 observability pass).

Non-goals: decrypting E2EE envelopes; anonymous feedback; storing user message bodies beyond audit row metadata.

---

## Delta from baseline

Extends [`current-baseline.md`](./current-baseline.md) — does **not** break existing v1 messaging contract.

| Area                  | Baseline                | This plan                                                            |
| --------------------- | ----------------------- | -------------------------------------------------------------------- |
| REST surface          | 8 endpoints             | +2 feedback endpoints                                                |
| Auth                  | XEdDSA on mutating REST | Same — feedback requires valid signature                             |
| Postgres              | 8 tables                | +`feedback_submissions`                                              |
| External integrations | None                    | Linear GraphQL, Resend/SMTP                                          |
| Plaintext on server   | Routing metadata only   | User feedback text + allowlisted diagnostics (operational, not E2EE) |

---

## Railway / broker path

Production traffic: **Client → broker (public TLS) → relay (internal)**.

Feedback endpoints live on **relay** (`awchat` service). Broker proxies `/v1/feedback/*` like other `/v1/*` routes. No feedback-specific broker logic.

---

## Authentication

Same as baseline REST auth:

| Header               | Purpose                                                              |
| -------------------- | -------------------------------------------------------------------- |
| `X-AWChat-User-Id`   | Authenticated user                                                   |
| `X-AWChat-Timestamp` | Replay window ±120s                                                  |
| `X-AWChat-Signature` | XEdDSA over `method\|path\|base64(SHA-256(body))\|timestamp\|userId` |

**Authorization rule:** Caller must exist in `users` table (registered identity). No chat membership check.

---

## API

### `POST /v1/feedback/bug`

**Request**

```json
{
  "title": "string, 5–120 chars",
  "description": "string, 10–4000 chars",
  "steps_to_reproduce": "optional string, max 2000",
  "expected_behavior": "optional string, max 1000",
  "actual_behavior": "optional string, max 1000",
  "diagnostics": {
    "client_platform": "android|linux-gtk|tui|macos|ios",
    "app_version": "string",
    "build_number": "int",
    "flavor": "debug|release",
    "os_version": "string",
    "device_model": "string",
    "locale": "string"
  }
}
```

**Response `201`**

```json
{
  "issue_identifier": "AWT-123",
  "issue_url": "https://linear.app/awtools/issue/AWT-123/..."
}
```

**Errors:** `400` validation, `401` auth, `429` rate limit, `502` Linear failure (opaque client message), `503` Linear/SMTP disabled in env.

### `POST /v1/feedback/support`

**Request**

```json
{
  "category": "account|billing|privacy|other",
  "message": "string, 10–4000 chars",
  "contact_email": "optional email",
  "diagnostics": { "... same shape as bug ..." }
}
```

**Response `202`**

```json
{
  "ticket_id": "uuid",
  "status": "queued"
}
```

### Rate limits

| Endpoint | Limit           | Storage                                        |
| -------- | --------------- | ---------------------------------------------- |
| Bug      | 5 / user / hour | `feedback_submissions` count + Hammer optional |
| Support  | 3 / user / hour | same                                           |

Return `429` with `Retry-After` header when exceeded.

---

## Linear integration

### Workspace (as of 2026-06-07)

| Item      | Value                                                |
| --------- | ---------------------------------------------------- |
| Team      | **Awtools** (`f8ccd0a2-9135-4a5b-85ec-713449a479ae`) |
| Project   | **AWChat** — create before implementation            |
| Bug label | `4089d123-a465-4cfd-86aa-2a7a72e283d0`               |

### GraphQL

```graphql
mutation CreateBugIssue($input: IssueCreateInput!) {
  issueCreate(input: $input) {
    success
    issue {
      id
      identifier
      url
    }
  }
}
```

Server builds title: `[AWChat <Platform>] <user title>` from `diagnostics.client_platform`.

Description template:

```markdown
## Report

<user description>

## Diagnostics

| Field           | Value                   |
| --------------- | ----------------------- |
| client_platform | …                       |
| app_version     | …                       |
| build_number    | …                       |
| flavor          | …                       |
| os_version      | …                       |
| device_model    | …                       |
| locale          | …                       |
| user_id         | <from X-AWChat-User-Id> |
| client_time_utc | <server now ISO-8601>   |

## Optional

- steps_to_reproduce
- expected_vs_actual
```

`POST https://api.linear.app/graphql` with `Authorization: <LINEAR_API_KEY>`.

### Elixir modules (proposed)

| Module                          | Role                                 |
| ------------------------------- | ------------------------------------ |
| `Gateway.FeedbackController`    | Plug handlers, validation            |
| `Gateway.Feedback.LinearClient` | Finch HTTP GraphQL                   |
| `Gateway.Feedback.EmailSender`  | Resend adapter (behaviour + mock)    |
| `Gateway.Feedback.RateLimit`    | Query `feedback_submissions`         |
| `Gateway.Feedback`              | Context — persist audit, orchestrate |

---

## Support email

| Header     | Value                                                             |
| ---------- | ----------------------------------------------------------------- |
| `To`       | `SUPPORT_EMAIL_TO` (default `save-b8dA1iGELfV7@app.basecamp.com`) |
| `From`     | `AWChat Support <noreply@awfixer.me>`                             |
| `Reply-To` | User `contact_email` if provided                                  |
| `Subject`  | `[AWChat Support] <category> — <first 60 chars of message>`       |

Body: diagnostics table + user message. Send async after `202` response (Oban job or `Task.Supervisor` with audit status update).

---

## Data model

### Migration: `feedback_submissions`

| Column              | Type                        | Notes                                       |
| ------------------- | --------------------------- | ------------------------------------------- |
| `id`                | UUID PK                     | `ticket_id` for support                     |
| `user_id`           | text FK → `users.id`        |                                             |
| `kind`              | enum `bug\|support`         |                                             |
| `created_at`        | timestamptz                 | Rate limit window                           |
| `linear_issue_id`   | text nullable               | Bug only                                    |
| `linear_identifier` | text nullable               | e.g. `AWT-123`                              |
| `email_status`      | enum `queued\|sent\|failed` | Support only                                |
| `client_platform`   | text                        | From diagnostics                            |
| `app_version`       | text                        | Audit metadata only — not full user message |

Do **not** store full `description`/`message` in production logs at `info` level; optional encrypted-at-rest column deferred (v1: omit body from PG, rely on Linear/Basecamp as systems of record after forward).

---

## Environment variables

| Variable                   | Required | Default        | Notes                       |
| -------------------------- | -------- | -------------- | --------------------------- |
| `LINEAR_API_KEY`           | Staging+ | —              | Never commit                |
| `LINEAR_AWCHAT_PROJECT_ID` | Staging+ | —              |                             |
| `LINEAR_TEAM_ID`           | No       | `f8ccd0a2-...` |                             |
| `LINEAR_BUG_LABEL_ID`      | No       | `4089d123-...` |                             |
| `RESEND_API_KEY`           | Staging+ | —              |                             |
| `SUPPORT_EMAIL_TO`         | No       | Basecamp inbox |                             |
| `FEEDBACK_ENABLED`         | No       | `true`         | `false` → `503` for clients |

---

## Observability

| Metric                        | Labels                      |
| ----------------------------- | --------------------------- |
| `feedback_bug_created_total`  | `client_platform`, `flavor` |
| `feedback_support_sent_total` | `category`                  |
| `feedback_errors_total`       | `endpoint`, `reason`        |

Full dashboard wiring in PR 24; counters added here.

---

## Implementation phases

| Phase               | Scope                                                                                                                                                                                                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **0 — Ops**         | Create Linear AWChat project; Resend domain verify; staging secrets                                                                                                                                     |
| **1 — Schema**      | Ecto migration `feedback_submissions`                                                                                                                                                                   |
| **2 — Linear**      | `LinearClient` + controller bug action + tests (Bypass/Req)                                                                                                                                             |
| **3 — Email**       | `EmailSender` + support action + async delivery                                                                                                                                                         |
| **4 — Rate limits** | Per-user hourly counts + `429`                                                                                                                                                                          |
| **5 — Router**      | Register routes; broker proxy smoke; update `GET /v1/ready` optional check if `FEEDBACK_ENABLED` and Linear unreachable → degrade with warning header (not 503 — feedback is non-critical to messaging) |

---

## Acceptance criteria

| ID   | Criterion                                                                                    |
| ---- | -------------------------------------------------------------------------------------------- |
| AC-1 | Valid signed bug POST creates Linear issue in AWChat project with Bug label                  |
| AC-2 | Valid signed support POST returns `202` and email arrives at Basecamp within 5 min (staging) |
| AC-3 | Missing/invalid signature → `401`                                                            |
| AC-4 | 6th bug in hour → `429`                                                                      |
| AC-5 | `feedback_submissions` row per request with `user_id` + `kind`                               |
| AC-6 | Linear failure → `502`, no API key in response body                                          |
| AC-7 | Unit tests mock Linear and Resend; CI passes without secrets                                 |

---

## References

- [Plan 001](../001-support-and-bug-reporting.md) — cross-cutting goals and checklist
- [`current-baseline.md`](./current-baseline.md) — relay v1 contract
- [`002-redis-durable-encrypted-pipeline.md`](./002-redis-durable-encrypted-pipeline.md) — hosted stack (orthogonal)
- [Linear Creating issues](https://linear.app/docs/creating-issues)
