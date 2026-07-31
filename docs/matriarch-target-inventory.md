# Matriarch construction target inventory

Status: proposed, validated, and non-deployable. This inventory records only
the supervisor-verified evidence supplied for this run. It does not authorize
VM construction or any live mutation.

Packet: `implementation/2026-07-31-matriarch-construction-inventory.packet.md`
Collector: Codex implementation worker
Evidence profile: `matriarch-libvirt-readonly-v1`
Private evidence reference:
`handoff/runs/20260731T211555Z-f1ab8fc-10639/host-evidence/`
Evidence manifest:
`handoff/runs/20260731T211555Z-f1ab8fc-10639/host-evidence/manifest.sha256`
Collection time: 2026-07-31T21:15:56Z through 2026-07-31T21:15:58Z

Historical host material is not evidence of current Matriarch state. No host
inspection was performed by this worker; all host-related conclusions below
cite only the supplied evidence items.

| Field | Value | Source / exact command or evidence reference | Timestamp (UTC) | Confidence | Confidence rationale |
| --- | --- | --- | --- | --- | --- |
| Confirmed Matriarch host identity | `ws-matriarch`, Fedora Linux 44 | `host-evidence/evidence-01-hostnamectl.txt`: `hostnamectl`; `host-evidence/evidence-02-fedora-release.txt`: `cat /etc/fedora-release` | 2026-07-31T21:15:56Z | high | Direct host identity and operating-system observations at collection time. |
| KVM availability | `/dev/kvm` present | `host-evidence/evidence-05-dev-kvm.txt`: `test -e /dev/kvm` (exit 0) | 2026-07-31T21:15:56Z | high | The recorded successful existence test directly establishes device presence at collection time. |
| System libvirt availability | Available through `qemu:///system`; QEMU hypervisor reported as `10.2.2` | `host-evidence/evidence-06-system-version.txt`: `virsh --readonly --connect qemu:///system version` (exit 0); `host-evidence/evidence-24-virtqemud-status.txt`: `systemctl is-active virtqemud` (`active`) | 2026-07-31T21:15:56Z; 2026-07-31T21:15:58Z | high | The required read-only system connection succeeded, and the QEMU modular daemon was active. `libvirtd` was inactive in evidence 23, but that does not negate the successful modular system connection. |
| Domain `mail-core-9000` existence/name availability | Absent; name available at collection time | `host-evidence/evidence-07-system-domains.txt`: `virsh --readonly --connect qemu:///system list --all` (empty, exit 0); `host-evidence/evidence-10-system-dominfo.txt`: `virsh --readonly --connect qemu:///system dominfo mail-core-9000` (exit 1; `failed to get domain`) | 2026-07-31T21:15:56Z | high | The system domain list was empty and the targeted lookup reported no such domain. No numeric libvirt runtime ID was used. |
| System libvirt network inventory | No defined system libvirt networks observed | `host-evidence/evidence-08-system-networks.txt`: `virsh --readonly --connect qemu:///system net-list --all` (empty, exit 0) | 2026-07-31T21:15:56Z | high | The required system network-list query completed successfully and returned no entries. |
| System libvirt storage-pool inventory | No defined system libvirt storage pools observed | `host-evidence/evidence-09-system-pools.txt`: `virsh --readonly --connect qemu:///system pool-list --all` (empty, exit 0) | 2026-07-31T21:15:56Z | high | The required system pool-list query completed successfully and returned no entries. |
| Construction storage placement | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`; no operator-approved pool or targeted `pool-info` evidence was supplied | 2026-07-31T21:15:56Z | high | No defined system pool or targeted capacity evidence supports a selection; the packet prohibits inventing a placement. |
| Isolated mail-data placement | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`; no operator-approved pool or targeted `pool-info` evidence was supplied | 2026-07-31T21:15:56Z | high | No targeted evidence supports a dedicated data placement. |
| Existing construction network attachment | `UNRESOLVED` | `host-evidence/evidence-08-system-networks.txt`; `host-evidence/evidence-16-ip-link.txt`; `host-evidence/evidence-19-bridge-link.txt` | 2026-07-31T21:15:56Z through 2026-07-31T21:15:58Z | high | There are no defined system libvirt networks. Observed host links do not identify or approve a guest attachment; the only recorded bridge membership is `veth0` to `podman0`, which is not selected. |
| Proposed guest IP configuration | `UNRESOLVED` | `host-evidence/evidence-17-ip-address.txt`; `host-evidence/evidence-18-ip-route.txt`; `host-evidence/evidence-21-resolver-status.txt` | 2026-07-31T21:15:57Z through 2026-07-31T21:15:58Z | high | Host addresses, routes, and resolver configuration do not authorize or identify a guest address, gateway, or resolver assignment. |
| `home.arpa` DNS ownership/path | `UNRESOLVED` | No `getent hosts mail.home.arpa` evidence item or established operator authority was supplied; `host-evidence/manifest.sha256` | 2026-07-31T21:15:56Z through 2026-07-31T21:15:58Z | high | Resolver configuration in evidence 21 does not establish DNS ownership or the authoritative internal path for `home.arpa`. |
| Internal TLS issuance, trust, renewal, and replacement practice | `UNRESOLVED` | No direct read-only evidence or established operator authority was supplied; `host-evidence/manifest.sha256` | 2026-07-31T21:15:56Z through 2026-07-31T21:15:58Z | high | No issuer, trust anchor, renewal, or replacement practice is evidenced. |
| `APPLIANCE_EXPORT_REFERENCE` status | `UNRESOLVED` | Packet and supplied evidence contain no opaque reference; destination not accessed | 2026-07-31T21:15:56Z through 2026-07-31T21:15:58Z | high | The opaque reference is absent; its destination remains out of scope. |

## Read-only collection result

The supplied evidence establishes the confirmed host, KVM device presence, and
usable system libvirt read-only access. It shows no system libvirt domains,
networks, or storage pools, and establishes that `mail-core-9000` is absent.
It does not support construction storage, isolated mail-data placement, a
network attachment, guest IP configuration, DNS ownership/path, TLS practice,
or the opaque export-reference status.

## Validation and render result

`scripts/validate/all.sh` passed (exit 0): required-file checks, JSON syntax,
secret scan, fail-closed relay policy, and unresolved-production-example guard
all passed.

`scripts/render/render.sh inventory/production/values.env.example` refused
(exit 2): `unresolved or unsafe: VM_STORAGE`. This expected fail-closed result
did not create a deployable definition.

## Stop condition

Stop without live mutation: construction storage and isolated mail-data
placement, construction network attachment, guest IP configuration, DNS
ownership/path, internal TLS practice, and `APPLIANCE_EXPORT_REFERENCE` status
remain unresolved. The packet does not authorize their selection or any VM
construction.

Live mutation: none.
