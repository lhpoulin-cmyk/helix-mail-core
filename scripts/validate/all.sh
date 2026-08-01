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
if jq -e '.fastmail.enabled == true and .fastmail.direction == "home-arpa-to-fastmail" and .fastmail.classification == "best-effort-external-copy" and .fastmail.authoritative == false and .fastmail.restart_safe_active_delivery == false and .operator_direction.direction == "fastmail-to-home-arpa" and .operator_direction.implementation_status == "policy-approved-transport-and-intake-not-deployed" and .operator_direction.approved_sender == "louis@poulin-arpa.com" and .operator_direction.designated_control_recipients == ["admin@home.arpa", "cluster-admin@home.arpa"] and .operator_direction.authority == "authoritative-operator-direction-when-policy-validates" and .operator_direction.fail_closed == true and .recipient_policy.external_recipients == "reject" and .recipient_policy.unauthenticated_submission == "reject" and .recipient_policy.domain_allow_relaying == false and .listeners.smtp_port_25.enabled == false' "$root/config/stalwart/policy-contract.json" >/dev/null; then
  pass "fail-closed relay and submission policy"
else bad "fail-closed relay and submission policy"; fi
if grep -q 'Fastmail -> `home.arpa`' "$root/docs/fastmail-boundary.md" && grep -q '`home.arpa` -> Fastmail' "$root/docs/fastmail-boundary.md" && grep -q 'transport and coder-intake enforcement are not yet deployed' "$root/docs/fastmail-boundary.md"; then
  pass "Fastmail directions and authority remain distinct"
else bad "Fastmail directions and authority remain distinct"; fi
fastmail_plan="$root/config/stalwart/fastmail-store-forward.plan.ndjson.template"
if jq -se '
  length == 4 and
  ([.[] | select(.object == "MtaRoute")][0].value["fastmail-admin-copy"] | .address == "smtp.fastmail.com" and .port == 465 and .implicitTls == true and .allowInvalidCerts == false and .authUsername == "louis@poulin-arpa.com" and .authSecret == {"@type":"File","filePath":"/etc/stalwart/secrets/fastmail-app-password"}) and
  ([.[] | select(.object == "MtaOutboundStrategy")][0].value.route | .else == "'"'local'"'" and .match["0"].if == "rcpt == '"'admin@poulin-arpa.com'"'" and .match["0"].then == "'"'fastmail-admin-copy'"'" and .match["1"].if == "rcpt == '"'cluster_admin@poulin-arpa.com'"'" and .match["1"].then == "'"'fastmail-admin-copy'"'") and
  ([.[] | select(.object == "MtaStageData")][0].value.script.match["0"].if == "local_port == 587 && !is_empty(authenticated_as)") and
  ([.[] | select(.object == "SieveSystemScript")][0].value["fastmail-admin-copy"].contents | contains("redirect :copy \"admin@poulin-arpa.com\";") and contains("redirect :copy \"cluster_admin@poulin-arpa.com\";") and contains("admin@home.arpa") and contains("cluster-admin@home.arpa"))
' "$fastmail_plan" >/dev/null; then
  pass "Fastmail bridge remains exact-recipient, file-secret, TLS relay"
else bad "Fastmail proposal boundary"; fi
grep -q 'UNRESOLVED_' "$root/inventory/production/values.env.example" && pass "unresolved production example stops deployment" || bad "production example"
[ "$fail" -eq 0 ] && { echo "VALIDATION PASS"; exit 0; }
echo "VALIDATION FAIL"; exit 1
