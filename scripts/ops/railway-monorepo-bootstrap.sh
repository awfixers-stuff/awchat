#!/usr/bin/env bash
# Bootstrap AWChat as a Railway isolated monorepo (broker + auth + awchat + Postgres).
# Requires: railway login, curl, jq
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

PROJECT_NAME="${1:-awchat-relay}"
REPO="${RAILWAY_REPO:-awfixers-stuff/awchat}"
BRANCH="${RAILWAY_BRANCH:-master}"
GRAPHQL_URL="${RAILWAY_GRAPHQL_URL:-https://backboard.railway.com/graphql/v2}"

if ! railway whoami >/dev/null 2>&1; then
  echo "error: not logged in to Railway (run: railway login)" >&2
  exit 1
fi

TOKEN="$(jq -r '.user.accessToken' "${HOME}/.railway/config.json")"
if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
  echo "error: Railway access token missing (~/.railway/config.json)" >&2
  exit 1
fi

gql() {
  local query="$1"
  local variables="${2:-\{\}}"
  local body
  body="$(jq -n --arg query "$query" --argjson variables "$variables" '{query: $query, variables: $variables}')"
  curl -sS "$GRAPHQL_URL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body"
}

echo "== init/link project: $PROJECT_NAME =="
if ! railway status --json >/dev/null 2>&1; then
  railway init --name "$PROJECT_NAME" --json >/dev/null
fi

STATUS="$(railway status --json)"
PROJECT_ID="$(echo "$STATUS" | jq -r '.id // .projectId // .project // empty')"
ENV_ID="$(echo "$STATUS" | jq -r '
  .environmentId //
  .environment //
  .environments.edges[0].node.id //
  empty
')"

if [[ -z "$PROJECT_ID" || -z "$ENV_ID" ]]; then
  echo "error: could not resolve project/environment ids (run from linked repo)" >&2
  echo "$STATUS" | jq . >&2 || true
  exit 1
fi

service_id() {
  local name="$1"
  railway service list --json | jq -r --arg n "$name" '.[] | select(.name == $n) | .id' | head -1
}

ensure_service() {
  local name="$1"
  local root_dir="$2"
  local config_file="$3"
  local watch_json="$4"

  local sid
  sid="$(service_id "$name")"

  if [[ -z "$sid" ]]; then
    echo "creating service: $name"
    local created
    created="$(gql \
      'mutation($input: ServiceCreateInput!) { serviceCreate(input: $input) { id name } }' \
      "$(jq -n --arg pid "$PROJECT_ID" --arg name "$name" --arg repo "$REPO" \
        '{input: {projectId: $pid, name: $name, source: {repo: $repo}}}')")"
    sid="$(echo "$created" | jq -r '.data.serviceCreate.id')"
    if [[ -z "$sid" || "$sid" == "null" ]]; then
      echo "error: serviceCreate failed for $name: $created" >&2
      exit 1
    fi
  else
    echo "service exists: $name ($sid)"
    gql \
      'mutation($id: String!, $input: ServiceConnectInput!) { serviceConnect(id: $id, input: $input) { id } }' \
      "$(jq -n --arg id "$sid" --arg repo "$REPO" --arg branch "$BRANCH" \
        '{id: $id, input: {repo: $repo, branch: $branch}}')" >/dev/null
  fi

  echo "configuring monorepo paths: $name"
  local updated
  updated="$(gql \
    'mutation($serviceId: String!, $environmentId: String!, $input: ServiceInstanceUpdateInput!) {
       serviceInstanceUpdate(serviceId: $serviceId, environmentId: $environmentId, input: $input)
     }' \
    "$(jq -n \
      --arg sid "$sid" \
      --arg eid "$ENV_ID" \
      --arg root "$root_dir" \
      --arg cfg "$config_file" \
      --argjson watch "$watch_json" \
      '{serviceId: $sid, environmentId: $eid, input: {rootDirectory: $root, railwayConfigFile: $cfg, watchPatterns: $watch}}')")"

  if [[ "$(echo "$updated" | jq -r '.data.serviceInstanceUpdate // empty')" != "true" ]]; then
    echo "error: serviceInstanceUpdate failed for $name: $updated" >&2
    exit 1
  fi

  echo "$sid"
}

echo "== services =="
BROKER_ID="$(ensure_service broker /server/broker /server/broker/railway.toml '["/server/broker/**"]')"
AUTH_ID="$(ensure_service auth /server/auth /server/auth/railway.toml '["/server/auth/**"]')"
AWCHAT_ID="$(ensure_service awchat /server/relay /server/relay/railway.toml '["/server/relay/**"]')"

echo "== databases (skip if already present) =="
if ! railway service list --json | jq -e '.[] | select(.name | test("^Postgres"))' >/dev/null; then
  railway add --database postgres --json >/dev/null || true
  railway add --database postgres --json >/dev/null || true
  echo "added Postgres plugins (rename second to Postgres-Auth in dashboard if needed)"
else
  echo "Postgres plugin(s) already exist"
fi

if ! railway service list --json | jq -e '.[] | select(.name | test("^Redis"; "i"))' >/dev/null 2>&1; then
  railway add --database redis --json >/dev/null 2>&1 || echo "note: add Redis plugin manually in dashboard if railway add --database redis is unavailable"
else
  echo "Redis plugin already exists"
fi

echo "== variables =="
railway variable set --service auth \
  DATABASE_URL='${{Postgres-Auth.DATABASE_URL}}' \
  PORT=8081 \
  --json >/dev/null 2>&1 || \
  railway variable set --service auth \
  DATABASE_URL='${{Postgres.DATABASE_URL}}' \
  PORT=8081 \
  --json >/dev/null

railway variable set --service awchat \
  DATABASE_URL='${{Postgres.DATABASE_URL}}' \
  REDIS_URL='${{Redis.REDIS_URL}}' \
  --json >/dev/null 2>&1 || \
  railway variable set --service awchat \
  DATABASE_URL='${{Postgres.DATABASE_URL}}' \
  --json >/dev/null

OPS_TOKEN="$(openssl rand -hex 24)"
railway variable set --service broker \
  RELAY_UPSTREAM='awchat.railway.internal:8080' \
  AUTH_UPSTREAM='auth.railway.internal:8081' \
  BROKER_OPS_TOKEN="$OPS_TOKEN" \
  REDIS_URL='${{Redis.REDIS_URL}}' \
  --json >/dev/null 2>&1 || \
  railway variable set --service broker \
  RELAY_UPSTREAM='awchat.railway.internal:8080' \
  AUTH_UPSTREAM='auth.railway.internal:8081' \
  BROKER_OPS_TOKEN="$OPS_TOKEN" \
  --json >/dev/null

echo "== trigger deploys =="
for sid in "$BROKER_ID" "$AUTH_ID" "$AWCHAT_ID"; do
  gql \
    'mutation($serviceId: String!, $environmentId: String!) {
       serviceInstanceDeployV2(serviceId: $serviceId, environmentId: $environmentId)
     }' \
    "$(jq -n --arg sid "$sid" --arg eid "$ENV_ID" '{serviceId: $sid, environmentId: $eid}')" >/dev/null
done

cat <<EOF

Bootstrap complete.

Project:     $PROJECT_NAME ($PROJECT_ID)
Environment: $ENV_ID

Services:
  broker  → /server/broker  (public domain: add manually)
  auth    → /server/auth   (internal only)
  awchat  → /server/relay  (internal only)

BROKER_OPS_TOKEN saved on broker service (retrieve via dashboard or railway variables).

Next:
  1. Add public domain to broker only (chat-api.awfixer.me)
  2. Ensure Postgres-Auth is wired to auth DATABASE_URL reference
  3. ./scripts/ops/railway-health.sh

EOF