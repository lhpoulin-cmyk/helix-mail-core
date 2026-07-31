#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
values="$root/inventory/production/values.env"
[ "$#" -eq 0 ] || values="$1"
out="$root/.rendered"
[ -f "$values" ] || { echo "missing production values file: $values" >&2; exit 2; }
getv() { sed -n "s/^$1=//p" "$values" | tail -n 1; }
for key in VM_STORAGE VM_DATA_STORAGE NETWORK_BRIDGE NETWORK_VLAN GUEST_IPV4 GUEST_GATEWAY DNS_PRIMARY DNS_SECONDARY TLS_CA_REFERENCE APPLIANCE_EXPORT_REFERENCE; do
  value=$(getv "$key")
  [ -n "$value" ] || { echo "unresolved: $key missing" >&2; exit 2; }
  case "$value" in *UNRESOLVED_*|*'{{'*|*'&'*|*'|'*|*'/'*) echo "unresolved or unsafe: $key" >&2; exit 2;; esac
done
VM_STORAGE=$(getv VM_STORAGE); VM_DATA_STORAGE=$(getv VM_DATA_STORAGE)
NETWORK_BRIDGE=$(getv NETWORK_BRIDGE); NETWORK_VLAN=$(getv NETWORK_VLAN)
GUEST_IPV4=$(getv GUEST_IPV4); GUEST_GATEWAY=$(getv GUEST_GATEWAY)
DNS_PRIMARY=$(getv DNS_PRIMARY); DNS_SECONDARY=$(getv DNS_SECONDARY)
TLS_CA_REFERENCE=$(getv TLS_CA_REFERENCE); APPLIANCE_EXPORT_REFERENCE=$(getv APPLIANCE_EXPORT_REFERENCE)
mkdir -p "$out"
sed -e "s|{{VM_STORAGE}}|$VM_STORAGE|g" -e "s|{{VM_DATA_STORAGE}}|$VM_DATA_STORAGE|g" -e "s|{{NETWORK_BRIDGE}}|$NETWORK_BRIDGE|g" -e "s|{{NETWORK_VLAN}}|$NETWORK_VLAN|g" "$root/provisioning/vm/mail-core.qm.template" > "$out/mail-core.qm"
{
echo '# Rendered mail-core deployment report'
echo
echo 'Status: proposed only; rendering authorizes nothing.'
echo
echo '## VM'
echo '- Construction VMID: 9000; name: mail-core; service hostname: mail.home.arpa'
echo "- System disk: 32 GiB on $VM_STORAGE"
echo "- Isolated mail-data disk: 64 GiB on $VM_DATA_STORAGE"
echo
echo '## Network'
echo "- Bridge/VLAN: $NETWORK_BRIDGE / $NETWORK_VLAN"
echo "- Guest IPv4/gateway: $GUEST_IPV4 / $GUEST_GATEWAY"
echo "- Resolvers: $DNS_PRIMARY, $DNS_SECONDARY"
echo '- Firewall: internal sources only to 587 and 993; no 25/public exposure.'
echo
echo '## Operations'
echo "- Internal CA reference: $TLS_CA_REFERENCE"
echo "- Appliance export reference: $APPLIANCE_EXPORT_REFERENCE"
echo '- Data mount: /srv/stalwart; Fastmail: disabled.'
echo '- Rollback: do not publish DNS or start VM; preserve created disks/evidence for review.'
} > "$out/deployment-report.md"
echo "rendered $out/deployment-report.md"
