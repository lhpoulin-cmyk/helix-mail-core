#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
fail=0
pass() { printf 'PASS %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
for f in AGENTS.md docs/matriarch-target-inventory.md provisioning/vm/mail-core.qm.template config/stalwart/policy-contract.json; do
  [ -f "$root/$f" ] && pass "$f" || bad "$f"
done
for file in "$root"/config/stalwart/*.json "$root"/config/examples/*.json; do
  jq -e . "$file" >/dev/null && pass "json $file" || bad "json $file"
done
if rg -n --hidden --glob '!.git/**' --glob '!inventory/example/**' --glob '!**/*.md' '(?i)(password[[:space:]]*[:=][[:space:]]*[^" ]{8,}|api[_-]?key[[:space:]]*[:=]|BEGIN (RSA |EC )?PRIVATE KEY)' "$root"; then
  bad "possible tracked secret"
else pass "no obvious tracked secret"; fi
if jq -e '.fastmail.enabled == false and .recipient_policy.external_recipients == "reject" and .recipient_policy.unauthenticated_submission == "reject" and .recipient_policy.domain_allow_relaying == false and .listeners.smtp_port_25.enabled == false' "$root/config/stalwart/policy-contract.json" >/dev/null; then
  pass "fail-closed relay and submission policy"
else bad "fail-closed relay and submission policy"; fi
grep -q 'UNRESOLVED_' "$root/inventory/production/values.env.example" && pass "unresolved production example stops deployment" || bad "production example"
[ "$fail" -eq 0 ] && { echo "VALIDATION PASS"; exit 0; }
echo "VALIDATION FAIL"; exit 1

