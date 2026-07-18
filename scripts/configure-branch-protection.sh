#!/usr/bin/env bash
# Configure a repository ruleset so PRs into main require the EE test-build check.
# Requires: gh auth login (repo admin permission)
set -euo pipefail

REPO="${REPO:-Automation-Development-Office/ado-ee}"
RULESET_NAME="Require EE test-build"
CHECK_CONTEXT="test-build"

ruleset_body() {
  cat <<EOF
{
  "name": "${RULESET_NAME}",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "bypass_actors": [],
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": true,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          {
            "context": "${CHECK_CONTEXT}"
          }
        ]
      }
    }
  ]
}
EOF
}

echo "Configuring ruleset on ${REPO}..."
echo "Required status check: ${CHECK_CONTEXT}"

existing_id="$(gh api "repos/${REPO}/rulesets" --jq ".[] | select(.name==\"${RULESET_NAME}\") | .id" 2>/dev/null | head -n1 || true)"

if [[ -n "${existing_id}" ]]; then
  echo "Updating existing ruleset id=${existing_id}"
  ruleset_body | gh api "repos/${REPO}/rulesets/${existing_id}" --method PUT --input -
else
  echo "Creating ruleset '${RULESET_NAME}'"
  ruleset_body | gh api "repos/${REPO}/rulesets" --method POST --input -
fi

echo
echo "Done. Verify under:"
echo "  https://github.com/${REPO}/settings/rules"
echo
echo "Note: GitHub may only list '${CHECK_CONTEXT}' after it has run at least once."
echo "Open a PR or run workflow_dispatch once if the check name does not appear yet."
