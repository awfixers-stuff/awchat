#!/usr/bin/env bash
# Cursor stop/subagentStop: CodeRabbit review + follow-up when critical/major remain.
set -euo pipefail

json_input=$(< /dev/stdin)

loop_count=0
status="completed"
if command -v jq >/dev/null 2>&1; then
  set +e
  status=$(printf '%s' "$json_input" | jq -r '.status // "completed"' 2>/dev/null)
  loop_count=$(printf '%s' "$json_input" | jq -r '.loop_count // 0' 2>/dev/null)
  set -e
fi

if [[ "$status" == "aborted" ]] || [[ "${loop_count:-0}" -gt 0 ]]; then
  printf '%s\n' '{}'
  exit 0
fi

if [[ "${AWCHAT_SKIP_CODERABBIT:-}" == "1" ]]; then
  printf '%s\n' '{}'
  exit 0
fi

root="$(git rev-parse --show-toplevel)"
cd "$root"
export AWCHAT_REPO_ROOT="$root"
# shellcheck source=scripts/hooks/lib/resolve-bun.sh
. "$root/scripts/hooks/lib/resolve-bun.sh"

export AWCHAT_HOOK_PHASE=uncommitted
export AWCHAT_CODERABBIT_QUEUE=1

PROMPT_START='__AWCHAT_CODERABBIT_PROMPT_START__'
PROMPT_END='__AWCHAT_CODERABBIT_PROMPT_END__'

emit_followup() {
  local prompt=$1
  if command -v uv >/dev/null 2>&1; then
    printf '%s' "$prompt" | uv run python -c 'import json,sys; print(json.dumps({"followup_message": sys.stdin.read()}))'
    return 0
  fi
  echo "agent-turn-coderabbit (cursor): uv not found for JSON follow-up" >&2
  printf '%s\n' '{}'
}

if ! awchat_resolve_bun; then
  echo "agent-turn-coderabbit (cursor): bun not found — skipped" >&2
  printf '%s\n' '{}'
  exit 0
fi

combined=$(
  "$AWCHAT_BUN" "$root/scripts/hooks/coderabbit-run.ts" 2>&1 || true
  "$AWCHAT_BUN" "$root/scripts/hooks/emit-coderabbit-prompt.ts" 2>/dev/null || true
)

if ! printf '%s' "$combined" | grep -q "$PROMPT_START"; then
  printf '%s\n' '{}'
  exit 0
fi

prompt=$(
  printf '%s' "$combined" | awk -v start="$PROMPT_START" -v end="$PROMPT_END" '
    $0 ~ start { capture=1; next }
    $0 ~ end { capture=0 }
    capture { print }
  '
)

if [[ -z "${prompt//[[:space:]]/}" ]]; then
  printf '%s\n' '{}'
  exit 0
fi

emit_followup "$prompt"
exit 0