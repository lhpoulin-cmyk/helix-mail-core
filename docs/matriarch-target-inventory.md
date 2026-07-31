# Matriarch construction target inventory

Status: blocked, fail-closed proposal only. This record does not authorize VM
construction or any live mutation.

Packet: `implementation/2026-07-31-matriarch-construction-inventory.packet.md`
Collector: Codex implementation worker
Private evidence reference: `/tmp/helix-mail-core-matriarch-inventory.t5EMdv`
Collection timestamp: 2026-07-31T15:28:40Z

The collection environment could not establish that it was the operator-confirmed
Fedora 44 Matriarch host. It could not access `/dev/kvm` or host networking,
and `virsh` was unavailable. Historical `hv-matrix` material is intentionally
not used as evidence of current Matriarch state.

| Field | Value | Source | Timestamp (UTC) | Confidence | Confidence rationale |
| --- | --- | --- | --- | --- | --- |
| Confirmed Matriarch host identity | `UNRESOLVED` | `hostnamectl` (exit 1; private evidence reference) | 2026-07-31T15:28:40Z | low | The command could not connect to the system bus, so it supplies no host identity. |
| KVM availability | `UNRESOLVED` | `test -e /dev/kvm` (exit 1; private evidence reference) | 2026-07-31T15:28:40Z | high | `/dev/kvm` was not accessible in the collection environment; this does not establish Matriarch capability. |
| Libvirt system URI availability | `UNRESOLVED` | `virsh -c qemu:///system uri` (exit 127; private evidence reference) | 2026-07-31T15:28:40Z | high | `virsh` was unavailable, so no libvirt system connection was made. |
| Domain `mail-core-9000` existence/name availability | `UNRESOLVED` | `virsh -c qemu:///system list --all --name`; `virsh -c qemu:///system dominfo mail-core-9000` (both exit 127; private evidence reference) | 2026-07-31T15:28:40Z | high | Neither command executed; the construction ID was not compared with a libvirt runtime ID. |
| Construction storage placement | `UNRESOLVED` | `virsh -c qemu:///system pool-list --all` (exit 127; private evidence reference) | 2026-07-31T15:28:40Z | high | No storage-pool facts were collected; no pool was selected or inspected further. |
| Isolated mail-data placement | `UNRESOLVED` | No approved storage pool identified; `virsh -c qemu:///system pool-list --all` (exit 127; private evidence reference) | 2026-07-31T15:28:40Z | high | Targeted capacity evidence cannot be collected until an operator identifies or approves a pool. |
| Existing network attachment | `UNRESOLVED` | `virsh -c qemu:///system net-list --all` (exit 127); `ip -brief link` and `ip -brief address` (exit 1; private evidence reference) | 2026-07-31T15:28:40Z | high | Libvirt and netlink inspection were unavailable; no bridge or VLAN is inferred. |
| Proposed guest IP configuration | `UNRESOLVED` | `ip -brief address`; `ip route` (both exit 1; private evidence reference) | 2026-07-31T15:28:40Z | high | No guest address, gateway, or resolver may be invented from an inaccessible host network. |
| `home.arpa` DNS ownership/path | `UNRESOLVED` | `getent hosts mail.home.arpa` (exit 2; private evidence reference) | 2026-07-31T15:28:40Z | medium | The name did not resolve from the collection environment; that does not establish DNS ownership or the authoritative internal path. |
| Internal TLS issuance, trust, renewal, and replacement practice | `UNRESOLVED` | No direct read-only evidence or established operator authority supplied | 2026-07-31T15:28:40Z | high | No issuer, trust anchor, renewal, or replacement practice is assumed. |
| `APPLIANCE_EXPORT_REFERENCE` status | `UNRESOLVED` | Implementation packet and operator input supplied no opaque reference; destination not accessed | 2026-07-31T15:28:40Z | high | The required opaque reference is absent and its destination remains out of scope. |

## Read-only collection result

All packet-listed commands were attempted only as read-only queries. The
following outcomes are recorded in the private evidence manifest at the
reference above: `hostnamectl` exit 1; `test -e /dev/kvm` exit 1; all five
`virsh` queries exit 127; `ip -brief link`, `ip -brief address`, and `ip route`
exit 1; and `getent hosts mail.home.arpa` exit 2. No targeted pool query was
run because no pool was identified or approved by the operator.

## Validation and render result

`scripts/validate/all.sh` passed at 2026-07-31T15:29:34Z (exit 0): all required
files, JSON syntax, secret scan, fail-closed relay policy, and unresolved
production-example guard passed.
`scripts/render/render.sh inventory/production/values.env.example` refused at
2026-07-31T15:29:34Z (exit 2): `unresolved or unsafe: VM_STORAGE`. This is the
expected fail-closed result and did not produce a deployable definition.

## Stop condition

Stop without live mutation: the confirmed Matriarch identity is ambiguous;
KVM/libvirt availability and the `mail-core-9000` name cannot be established;
and required storage, isolated data placement, network attachment, guest IP
configuration, DNS ownership/path, TLS practice, and
`APPLIANCE_EXPORT_REFERENCE` remain unresolved.

Live mutation: none.
