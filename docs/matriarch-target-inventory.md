# Matriarch construction target inventory

Status: blocked, fail-closed proposal only. This record does not authorize VM
construction or any live mutation.

Packet: `implementation/2026-07-31-matriarch-construction-inventory.packet.md`
Collector: Codex implementation worker
Evidence profile: `matriarch-libvirt-readonly-v1`
Private evidence reference:
`handoff/runs/20260731T182652Z-480b835-291014/host-evidence/`
Evidence manifest:
`handoff/runs/20260731T182652Z-480b835-291014/host-evidence/manifest.sha256`
Collection timestamp: 2026-07-31T18:26:52Z

All 22 evidence items match the supplied manifest. This inventory uses only
that supervisor-verified evidence. Historical host material is not evidence of
current Matriarch state.

| Field | Value | Source / exact command or evidence reference | Timestamp (UTC) | Confidence | Confidence rationale |
| --- | --- | --- | --- | --- | --- |
| Confirmed Matriarch host identity | `ws-matriarch`, Fedora Linux 44 | `host-evidence/evidence-01-hostnamectl.txt`: `hostnamectl`; `host-evidence/evidence-02-fedora-release.txt`: `cat /etc/fedora-release` | 2026-07-31T18:26:52Z | high | The recorded host identity and Fedora release directly identify the confirmed evidence host. |
| KVM availability | `/dev/kvm` present | `host-evidence/evidence-05-dev-kvm.txt`: `test -e /dev/kvm` (exit 0) | 2026-07-31T18:26:52Z | high | Successful existence test establishes KVM device presence at collection time. |
| System libvirt availability | `UNRESOLVED` | `host-evidence/evidence-06-system-version.txt`: `virsh --readonly --connect qemu:///system version` (exit 127, `virsh` unavailable); `host-evidence/evidence-21-libvirtd-status.txt` and `evidence-22-virtqemud-status.txt`: recorded inactive | 2026-07-31T18:26:52Z | high | No system libvirt connection was made; unavailable client and inactive recorded services do not establish a usable construction plane. |
| System libvirt domain list | `UNRESOLVED` | `host-evidence/evidence-07-system-domains.txt`: `virsh --readonly --connect qemu:///system list --all` (exit 127, `virsh` unavailable) | 2026-07-31T18:26:52Z | high | The required system-plane query did not execute. |
| Domain `mail-core-9000` existence/name availability | `UNRESOLVED` | No `dominfo mail-core-9000` evidence item is supplied; `host-evidence/manifest.sha256` is authoritative for this run. | 2026-07-31T18:26:52Z | high | The supplied evidence neither queries this name nor establishes the system domain plane, so neither existence nor availability can be inferred. |
| System libvirt network list | `UNRESOLVED` | `host-evidence/evidence-08-system-networks.txt`: `virsh --readonly --connect qemu:///system net-list --all` (exit 127, `virsh` unavailable) | 2026-07-31T18:26:52Z | high | No system libvirt network facts were collected. |
| System libvirt storage-pool list | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`: `virsh --readonly --connect qemu:///system pool-list --all` (exit 127, `virsh` unavailable) | 2026-07-31T18:26:52Z | high | No system libvirt storage-pool facts were collected. |
| Construction storage placement | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`; no operator-approved pool or targeted `pool-info` evidence is supplied. | 2026-07-31T18:26:52Z | high | The packet prohibits selecting a pool or inspecting unrelated storage. |
| Isolated mail-data placement | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`; no operator-approved pool or targeted `pool-info` evidence is supplied. | 2026-07-31T18:26:52Z | high | No dedicated data placement is supported by targeted evidence. |
| Existing construction network attachment | `UNRESOLVED` | `host-evidence/evidence-08-system-networks.txt`; `host-evidence/evidence-14-ip-link.txt`; `host-evidence/evidence-17-bridge-link.txt` | 2026-07-31T18:26:52Z | high | Host links were observed, but no system libvirt network or attachment was available; the only recorded bridge membership is Podman-related and is not selected. |
| Proposed guest IP configuration | `UNRESOLVED` | `host-evidence/evidence-15-ip-address.txt`; `host-evidence/evidence-16-ip-route.txt`; `host-evidence/evidence-19-resolver-status.txt` | 2026-07-31T18:26:52Z | high | Observed host addressing, routes, and resolvers do not authorize or identify a guest address, gateway, or resolver assignment. |
| `home.arpa` DNS ownership/path | `UNRESOLVED` | No `getent hosts mail.home.arpa` evidence item or established operator authority is supplied; `host-evidence/manifest.sha256` is authoritative for this run. | 2026-07-31T18:26:52Z | high | Resolver configuration does not establish the owner or authoritative internal path for `home.arpa`. |
| Internal TLS issuance, trust, renewal, and replacement practice | `UNRESOLVED` | No direct read-only evidence or established operator authority is supplied; `host-evidence/manifest.sha256` is authoritative for this run. | 2026-07-31T18:26:52Z | high | No issuer, trust anchor, renewal, or replacement practice is assumed. |
| `APPLIANCE_EXPORT_REFERENCE` status | `UNRESOLVED` | Packet and supplied evidence contain no opaque reference; destination not accessed. | 2026-07-31T18:26:52Z | high | The required opaque reference is absent and its destination remains out of scope. |

## Read-only collection result

The supplied evidence records only read-only collection commands. System
libvirt queries could not run because the fixed `virsh` candidate was
unavailable. No targeted pool query was supplied because no pool was
identified or operator-approved. No numeric libvirt runtime ID was used to
assess construction ID `9000`.

## Validation and render result

`scripts/validate/all.sh` passed (exit 0): required-file checks, JSON syntax,
secret scan, fail-closed relay policy, and unresolved-production-example guard
all passed.

`scripts/render/render.sh inventory/production/values.env.example` refused
(exit 2): `unresolved or unsafe: VM_STORAGE`. This expected fail-closed result
did not create a deployable definition.

## Stop condition

Stop without live mutation: system libvirt availability and the
`mail-core-9000` name remain unresolved; construction storage and isolated
mail-data placement, construction network attachment, guest IP configuration,
DNS ownership/path, TLS practice, and `APPLIANCE_EXPORT_REFERENCE` remain
unresolved.

Live mutation: none.
