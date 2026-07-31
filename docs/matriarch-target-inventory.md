# Matriarch construction target inventory

Status: blocked, fail-closed proposal only. This record does not authorize VM
construction or any live mutation.

Packet: `implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md`
Collector: Codex implementation worker
Collection timestamp: 2026-07-31T15:43:01Z

The approved local shell could not establish the Fedora 44 Matriarch host
identity or inspect the system construction plane. Historical host material is
not used as evidence of current Matriarch state.

| Field | Value | Source / exact command | Timestamp (UTC) | Confidence | Confidence rationale |
| --- | --- | --- | --- | --- | --- |
| Confirmed Matriarch host identity | `UNRESOLVED` | `hostnamectl` (exit 1: `Failed to connect to system scope bus via local transport: Operation not permitted`) | 2026-07-31T15:43:01Z | high | The system bus was denied, so the command supplied no host identity. |
| KVM availability | `UNRESOLVED` | `test -e /dev/kvm` (exit 1) | 2026-07-31T15:43:01Z | high | `/dev/kvm` was not accessible in the collection environment; this does not establish Matriarch capability. |
| System libvirt domain list | `UNRESOLVED` | `virsh --readonly --connect qemu:///system list --all` (exit 127: `virsh: command not found`) | 2026-07-31T15:43:01Z | high | `virsh` was unavailable, so no system libvirt connection was made. |
| System libvirt network list | `UNRESOLVED` | `virsh --readonly --connect qemu:///system net-list --all` (exit 127: `virsh: command not found`) | 2026-07-31T15:43:01Z | high | `virsh` was unavailable, so no system libvirt network facts were collected. |
| System libvirt storage-pool list | `UNRESOLVED` | `virsh --readonly --connect qemu:///system pool-list --all` (exit 127: `virsh: command not found`) | 2026-07-31T15:43:01Z | high | No storage-pool facts were collected; no pool was selected or inspected further. |
| Domain `mail-core-9000` existence/name availability | `UNRESOLVED` | `virsh --readonly --connect qemu:///system dominfo mail-core-9000` (exit 127: `virsh: command not found`) | 2026-07-31T15:43:01Z | high | The required system-plane query did not execute; name availability cannot be determined. |
| User-session libvirt plane (`qemu:///session`) | `UNRESOLVED; not evidence of the system construction plane` | `virsh --readonly --connect qemu:///session list --all`; `virsh --readonly --connect qemu:///session net-list --all`; `virsh --readonly --connect qemu:///session pool-list --all` (each exit 127: `virsh: command not found`) | 2026-07-31T15:43:01Z | high | The separate session-plane inspection did not execute and, by packet authority, would not establish system construction-plane facts. |
| Existing host network attachment | `UNRESOLVED` | `ip -brief link`; `ip -brief address` (each exit 1: `Cannot open netlink socket: Operation not permitted`) | 2026-07-31T15:43:01Z | high | Host netlink inspection was denied; no bridge or VLAN is inferred. |
| Proposed guest IP configuration | `UNRESOLVED` | `ip -brief address`; `ip route` (each exit 1: `Cannot open netlink socket: Operation not permitted`) | 2026-07-31T15:43:01Z | high | No guest address, gateway, or resolver may be invented from an inaccessible host network. |
| `home.arpa` name resolution and DNS ownership/path | `UNRESOLVED` | `getent hosts mail.home.arpa` (exit 2; no result) | 2026-07-31T15:43:01Z | medium | The name did not resolve in this environment; that does not establish DNS ownership or the authoritative internal path. |
| Targeted approved-pool capacity | `UNRESOLVED` | No `virsh --readonly --connect qemu:///system pool-info <pool>` command run because no pool was identified or operator-approved. | 2026-07-31T15:43:01Z | high | The packet prohibits selecting a pool or inspecting unrelated storage. |
| Internal TLS issuance, trust, renewal, and replacement practice | `UNRESOLVED` | No direct read-only evidence or established operator authority supplied. | 2026-07-31T15:43:01Z | high | No issuer, trust anchor, renewal, or replacement practice is assumed. |
| `APPLIANCE_EXPORT_REFERENCE` status | `UNRESOLVED` | Implementation packet and operator input supplied no opaque reference; destination not accessed. | 2026-07-31T15:43:01Z | high | The required opaque reference is absent and its destination remains out of scope. |

## Read-only collection result

All packet-listed commands were attempted only as unprivileged, read-only
queries. The exact commands and sanitized results are recorded in the table.
No targeted pool query was run because no pool was identified or approved by
the operator.

## Validation and render result

`scripts/validate/all.sh` passed at 2026-07-31T15:44:13Z (exit 0): all
required files, JSON syntax, secret scan, fail-closed relay policy, and
unresolved production-example guard passed.
`scripts/render/render.sh inventory/production/values.env.example` refused at
2026-07-31T15:44:13Z (exit 2): `unresolved or unsafe: VM_STORAGE`. This is the
expected fail-closed result and did not produce a deployable definition.

## Stop condition

Stop without live mutation: the confirmed Matriarch identity is unresolved;
KVM/libvirt availability and the `mail-core-9000` name cannot be established;
and required storage, isolated data placement, network attachment, guest IP
configuration, DNS ownership/path, TLS practice, and
`APPLIANCE_EXPORT_REFERENCE` remain unresolved.

Live mutation: none.
