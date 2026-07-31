# Matriarch construction target inventory

Status: Matriarch libvirt bootstrap completed and verified. Construction is
paused pending unresolved operator-owned storage, network, addressing, DNS,
TLS, and export inputs. This record does not authorize VM construction or any
further live mutation.

## Operator pause — 2026-07-31

Matriarch libvirt bootstrap is deferred because a reboot/maintenance window is
unavailable. The Katra construction path was discussed but is not authorized.
Existing packets, collected evidence, and commits are preserved unchanged.

The earlier approved Fedora package transaction was completed before this
pause; it is the only recorded live host mutation. No VM, libvirt domain,
network, storage pool, disk, DNS, firewall, certificate, credential, service
activation, or access-control mutation occurred. Resume requires an explicit
operator instruction and a newly reviewed packet; it must not be inferred from
this record.

Packet: `implementation/2026-07-31-matriarch-construction-inventory.packet.md`
Collector: Codex implementation worker
Evidence profile: `matriarch-libvirt-readonly-v1`
Private evidence reference:
`handoff/runs/20260731T185848Z-5968fc0-351076/host-evidence/`
Evidence manifest:
`handoff/runs/20260731T185848Z-5968fc0-351076/host-evidence/manifest.sha256`
Collection timestamp: 2026-07-31T18:58:48Z

This inventory uses only the supervisor-verified evidence supplied for this
run. Historical host material is not evidence of current Matriarch state.

| Field | Value | Source / exact command or evidence reference | Timestamp (UTC) | Confidence | Confidence rationale |
| --- | --- | --- | --- | --- | --- |
| Confirmed Matriarch host identity | `ws-matriarch`, Fedora Linux 44 | `host-evidence/evidence-01-hostnamectl.txt`: `hostnamectl`; `host-evidence/evidence-02-fedora-release.txt`: `cat /etc/fedora-release` | 2026-07-31T18:58:48Z | high | The recorded hostname and Fedora release directly identify the evidence host at collection time. |
| KVM availability | `/dev/kvm` present | `host-evidence/evidence-05-dev-kvm.txt`: `test -e /dev/kvm` (exit 0) | 2026-07-31T18:58:48Z | high | The successful recorded existence test establishes KVM device presence at collection time. |
| System libvirt availability | `UNRESOLVED` | `host-evidence/evidence-06-system-version.txt`: `virsh --readonly --connect qemu:///system version` (exit 127, fixed candidate unavailable); `host-evidence/evidence-23-libvirtd-status.txt`: `systemctl is-active libvirtd` (inactive); `host-evidence/evidence-24-virtqemud-status.txt`: `systemctl is-active virtqemud` (inactive) | 2026-07-31T18:58:48Z | high | No system libvirt connection was established. An unavailable fixed client and inactive recorded services do not establish a usable construction plane. |
| System libvirt domain list | `UNRESOLVED` | `host-evidence/evidence-07-system-domains.txt`: `virsh --readonly --connect qemu:///system list --all` (exit 127, fixed candidate unavailable) | 2026-07-31T18:58:48Z | high | The required system-plane domain-list query did not execute. |
| Domain `mail-core-9000` existence/name availability | `UNRESOLVED` | `host-evidence/evidence-10-system-dominfo.txt`: `virsh --readonly --connect qemu:///system dominfo mail-core-9000` (exit 127, fixed candidate unavailable) | 2026-07-31T18:58:48Z | high | The supplied system-plane query did not execute, so neither domain existence nor name availability can be inferred. No numeric libvirt runtime ID was used. |
| System libvirt network list | `UNRESOLVED` | `host-evidence/evidence-08-system-networks.txt`: `virsh --readonly --connect qemu:///system net-list --all` (exit 127, fixed candidate unavailable) | 2026-07-31T18:58:48Z | high | No system libvirt network facts were collected. |
| System libvirt storage-pool list | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`: `virsh --readonly --connect qemu:///system pool-list --all` (exit 127, fixed candidate unavailable) | 2026-07-31T18:58:48Z | high | No system libvirt storage-pool facts were collected. |
| Construction storage placement | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`; no operator-approved pool or targeted `pool-info` evidence is supplied | 2026-07-31T18:58:48Z | high | The packet prohibits selecting a pool or inspecting unrelated storage; no targeted capacity evidence supports a placement. |
| Isolated mail-data placement | `UNRESOLVED` | `host-evidence/evidence-09-system-pools.txt`; no operator-approved pool or targeted `pool-info` evidence is supplied | 2026-07-31T18:58:48Z | high | No dedicated data placement is supported by targeted evidence. |
| Existing construction network attachment | `UNRESOLVED` | `host-evidence/evidence-08-system-networks.txt`; `host-evidence/evidence-16-ip-link.txt`; `host-evidence/evidence-19-bridge-link.txt` | 2026-07-31T18:58:48Z | high | Host links were observed, but no system libvirt network or attachment was available; the recorded bridge membership is Podman-related and is not selected. |
| Proposed guest IP configuration | `UNRESOLVED` | `host-evidence/evidence-17-ip-address.txt`; `host-evidence/evidence-18-ip-route.txt`; `host-evidence/evidence-21-resolver-status.txt` | 2026-07-31T18:58:48Z | high | Observed host addressing, routes, and resolvers do not authorize or identify a guest address, gateway, or resolver assignment. |
| `home.arpa` DNS ownership/path | `UNRESOLVED` | No `getent hosts mail.home.arpa` evidence item or established operator authority is supplied; `host-evidence/manifest.sha256` | 2026-07-31T18:58:48Z | high | Resolver configuration does not establish the owner or authoritative internal path for `home.arpa`. |
| Internal TLS issuance, trust, renewal, and replacement practice | `UNRESOLVED` | No direct read-only evidence or established operator authority is supplied; `host-evidence/manifest.sha256` | 2026-07-31T18:58:48Z | high | No issuer, trust anchor, renewal, or replacement practice is assumed. |
| `APPLIANCE_EXPORT_REFERENCE` status | `UNRESOLVED` | Packet and supplied evidence contain no opaque reference; destination not accessed | 2026-07-31T18:58:48Z | high | The opaque reference is absent and its destination remains out of scope. |

## Read-only collection result

The supplied evidence records read-only collection only. System and session
libvirt queries could not run because the fixed `virsh` candidate was
unavailable. No targeted pool query was supplied because no pool was identified
or operator-approved. The evidence does not establish construction storage,
mail-data placement, a construction network attachment, or any guest network
configuration.

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

Live mutation before the 2026-07-31 post-reboot check: the approved Fedora
package transaction only. No live mutation was performed during the post-reboot
check below.

## Post-reboot libvirt bootstrap verification — 2026-07-31

Operator direction authorized post-reboot verification and local modular
socket activation only, beginning from commit
`f7b9baef43e2c0fa91e72bd6e6a94a2bb955bd11`. The check was completed at
`2026-07-31T21:12:37Z` using the current local shell. No VM, domain, network,
pool, disk, DNS, TLS, credential, access-control, firewall, or host-network
configuration was created or changed.

| Check | Result | Source / exact command | Timestamp (UTC) |
| --- | --- | --- | --- |
| Host and operating system | `ws-matriarch`, Fedora Linux 44 | `hostname`; `hostnamectl`; `cat /etc/fedora-release` | 2026-07-31T21:11:44Z |
| Current boot after package installation | Installed RPM timestamps: 2026-07-31 15:29 EDT; current boot: 2026-07-31 17:06 EDT | `rpm -q --last libvirt-daemon-kvm libvirt-client virt-install`; `uptime -s`; `who -b`; `last -x reboot -F` | 2026-07-31T21:12:37Z |
| Kernel and system state | `7.0.9-205.fc44.x86_64`; system state `degraded` due only to pre-existing unrelated `movie-av1-out-handoff.path` failure | `uname -r`; `systemctl is-system-running`; `systemctl --failed --no-legend` | 2026-07-31T21:11:44Z |
| Repository | clean | `git status --short` | 2026-07-31T21:11:44Z |
| Approved transaction | DNF transaction 78 completed with status `Ok`; requested `libvirt-daemon-kvm`, `libvirt-client`, and `virt-install` installed | `dnf history info last`; `rpm -q libvirt-daemon-kvm libvirt-client virt-install` | 2026-07-31T21:11:44Z |
| Pending/failed DNF work | No DNF client process observed; transaction 78 is `Ok`. `packagekitd` was resident but is not a DNF transaction. | `dnf history list`; `pgrep -af 'dnf|dnf5|packagekit'` | 2026-07-31T21:11:44Z |
| Network and resolver comparison | No configuration difference from the 2026-07-31T18:58:48Z evidence: link set, assigned IPv4 addresses, routes, DNS servers, and search domain match. Container-interface IPv6/MAC values changed across the reboot and are not treated as host-network configuration changes. | `ip -brief link`; `ip -brief address`; `ip route`; `resolvectl status`, compared with evidence 16–18 and 21 | 2026-07-31T21:11:44Z |
| Monolithic and remote libvirt | `libvirtd.service` and `libvirtd.socket` are absent; `virtproxyd-tcp.socket` and `virtproxyd-tls.socket` are disabled/inactive; no TCP listeners on ports 16509/16514 were observed | `systemctl is-enabled`; `systemctl is-active`; `ss -ltnp` | 2026-07-31T21:11:44Z |
| Authorized modular sockets | `virtqemud.socket`, `virtnetworkd.socket`, `virtstoraged.socket`, `virtlogd.socket`, and `virtlockd.socket` are installed, enabled, and active/listening; all entered listening state during current boot | `systemctl list-unit-files`; `systemctl is-enabled`; `systemctl is-active`; `systemctl show`; `journalctl -b -u ...` | 2026-07-31T21:11:44Z |
| Extra modular socket state | `virtproxyd.socket`, its local read-only/admin companions, and interface/nodedev/nwfilter/secret modular sockets are also enabled and listening. `virtproxyd.socket` exposes only `/run/libvirt/libvirt-sock`; its TCP/TLS socket units remain disabled. This pre-existing package-preset state was observed, not enabled or changed by this check, but is outside the bootstrap packet's enumerated socket scope. | `systemctl list-unit-files 'virt*.socket' 'libvirtd*.socket'`; `systemctl list-sockets --all`; `systemctl cat virtproxyd.socket virtproxyd-tcp.socket virtproxyd-tls.socket virtqemud.socket`; `journalctl -b -u ...` | 2026-07-31T21:11:44Z |
| System libvirt read-only access | `virsh --readonly --connect qemu:///system version` succeeded; domain, network, and pool lists are empty; `dominfo mail-core-9000` returned `failed to get domain`, establishing that it is absent | `virsh --readonly --connect qemu:///system version`; `list --all`; `net-list --all`; `pool-list --all`; `dominfo mail-core-9000` | 2026-07-31T21:11:44Z |
| Session libvirt read-only access | `virsh --readonly --connect qemu:///session version` and list/network/pool checks succeeded and are empty; `dominfo mail-core-9000` returned `failed to get domain` | `virsh --readonly --connect qemu:///session version`; `list --all`; `net-list --all`; `pool-list --all`; `dominfo mail-core-9000` | 2026-07-31T21:11:44Z |
| Internal hostname observation | No local resolver result for `mail.home.arpa` | `getent hosts mail.home.arpa` | 2026-07-31T21:11:44Z |

### Bootstrap disposition

The required local QEMU and session read-only checks succeeded, the
`mail-core-9000` domain is absent, and no libvirt network or pool exists.

#### Operator acceptance — 2026-07-31

The operator accepted the exact observed Fedora modular-libvirt socket preset,
including local Unix-domain `virtproxyd.socket` compatibility access and the
other installed local modular sockets. This acceptance is limited to the
verified current state: no monolithic `libvirtd` stack, no
`virtproxyd-tcp.socket` or `virtproxyd-tls.socket`, no TCP/TLS listener, and no
created domain, network, or storage pool. It does not authorize additional
socket/service activation or any construction mutation.

Bootstrap classification: **completed and verified**. No socket unit was
enabled, disabled, started, or stopped by the post-reboot work. The scoped
acceptance expressly retains the local `virtproxyd.socket`; it must not be
disabled solely because it was omitted from the original expected-unit list.
The approved read-only construction inventory may now be dispatched. VM 9000
creation remains prohibited.
