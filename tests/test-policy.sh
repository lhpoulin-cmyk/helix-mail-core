#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
policy="$root/config/stalwart/policy-contract.json"
jq -e '.listeners.smtp_submission.authentication == "required"' "$policy" >/dev/null
jq -e '.recipient_policy.unauthenticated_submission == "reject"' "$policy" >/dev/null
jq -e '.recipient_policy.external_recipients == "reject"' "$policy" >/dev/null
jq -e '.recipient_policy.domain_allow_relaying == false' "$policy" >/dev/null
jq -e '.fastmail.enabled == false' "$policy" >/dev/null
echo "PASS policy static assertions"

