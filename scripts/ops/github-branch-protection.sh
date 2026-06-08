#!/usr/bin/env bash
# Optional: add classic branch protection requiring the CI gate check.
# Default leaves admins able to bypass (enforce_admins=false).
# Deploy gating is Railway "Wait for CI" — not this script.
set -euo pipefail

REPO="${GITHUB_REPO:-awfixers-stuff/awchat}"
BRANCH="${GITHUB_BRANCH:-master}"
GATE_CHECK="${GATE_CHECK:-gate}"
ENFORCE_ADMINS="${ENFORCE_ADMINS:-false}"

payload="$(cat <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["${GATE_CHECK}"]
  },
  "enforce_admins": ${ENFORCE_ADMINS},
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_linear_history": false,
  "required_conversation_resolution": false
}
EOF
)"

echo "Applying branch protection to ${REPO}@${BRANCH}"
echo "  required check: ${GATE_CHECK}"
echo "  enforce_admins: ${ENFORCE_ADMINS}"
gh api \
  --method PUT \
  "repos/${REPO}/branches/${BRANCH}/protection" \
  --input - <<<"${payload}"

echo "Done. Railway 'Wait for CI' is the deploy gate; branch protection is optional."