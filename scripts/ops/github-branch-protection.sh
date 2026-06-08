#!/usr/bin/env bash
# Require the CI gate check on master. Run once after CI workflow is merged.
set -euo pipefail

REPO="${GITHUB_REPO:-awfixers-stuff/awchat}"
BRANCH="${GITHUB_BRANCH:-master}"
GATE_CHECK="gate"

payload="$(cat <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["${GATE_CHECK}"]
  },
  "enforce_admins": true,
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

echo "Applying branch protection to ${REPO}@${BRANCH} (required check: ${GATE_CHECK})"
gh api \
  --method PUT \
  "repos/${REPO}/branches/${BRANCH}/protection" \
  --input - <<<"${payload}"

echo "Done. Enable Railway 'Wait for CI' on broker, auth, and awchat services."