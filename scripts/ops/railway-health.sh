#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if ! railway whoami >/dev/null 2>&1; then
  echo "error: not logged in to Railway (run: railway login)" >&2
  exit 1
fi

RAILWAY_PROJECT="${RAILWAY_PROJECT:-awchat-relay}"
railway link --project "$RAILWAY_PROJECT" --environment production >/dev/null 2>&1 || true

BROKER_DOMAIN="${BROKER_DOMAIN:-$(railway variables --service broker --json 2>/dev/null | jq -r '.RAILWAY_PUBLIC_DOMAIN // empty')}"
OPS_TOKEN="${BROKER_OPS_TOKEN:-$(railway variables --service broker --json 2>/dev/null | jq -r '.BROKER_OPS_TOKEN // empty')}"

echo "== broker public health =="
if [[ -n "$BROKER_DOMAIN" ]]; then
  curl -fsS "https://${BROKER_DOMAIN}/health"
  echo
else
  echo "skip: broker public domain not set"
fi

echo "== broker ops status =="
if [[ -n "$BROKER_DOMAIN" && -n "$OPS_TOKEN" ]]; then
  curl -fsS -H "X-Ops-Token: ${OPS_TOKEN}" "https://${BROKER_DOMAIN}/ops/status" | jq .
else
  echo "skip: set BROKER_DOMAIN and BROKER_OPS_TOKEN (or configure on Railway broker service)"
fi

echo "== internal upstreams (via broker /ops/status) =="
if [[ -n "$BROKER_DOMAIN" && -n "$OPS_TOKEN" ]]; then
  STATUS_JSON=$(curl -fsS -H "X-Ops-Token: ${OPS_TOKEN}" "https://${BROKER_DOMAIN}/ops/status")
  echo "$STATUS_JSON" | jq -e '.auth.health.ok and .auth.ready.ok and .relay.health.ok and .relay.ready.ok' >/dev/null
  echo "auth + relay internal probes ok"
else
  echo "skip: broker ops token unavailable"
fi

echo "ok"