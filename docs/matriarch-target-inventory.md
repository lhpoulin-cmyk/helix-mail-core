# Matriarch construction target inventory

> Historical construction record. The observations and unresolved decisions
> below describe their collection time. Current accepted state includes the
> running `mail-core-9000` domain, `mail-core-construction` storage pool,
> `br-lab10`, Debian 13, and the beta mail service. See `architecture.md`,
> `release-status.md`, and the execution evidence before making a current-state
> claim. The historical sections are retained rather than rewritten into the
> present tense.

Status: Matriarch libvirt bootstrap completed and verified; the construction
inventory is proposed, validated, and non-deployable. This inventory records
only the supervisor-verified evidence supplied for this run. It does not
authorize VM construction or any live mutation.

## Bootstrap verification and accepted socket state

The post-reboot bootstrap verification was committed as
`f1ab8fcc2f9a0b00b3f2ea25650d7a7c24aa0f3e`. The operator accepted the exact
Fedora modular-libvirt socket preset observed there, including local Unix-domain
`virtproxyd.socket` compatibility access. This scoped acceptance does not
authorize additional socket/service activation or any construction mutation.
The accepted state has no monolithic `libvirtd` stack, no
`virtproxyd-tcp.socket` or `virtproxyd-tls.socket`, no TCP/TLS listener, and
no created domain, network, or storage pool. Do not disable local
`virtproxyd.socket` solely because it was absent from the original expected-unit
list.

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
| Session libvirt availability | Available through `qemu:///session`; QEMU hypervisor reported as `10.2.2`; no session domains, networks, or pools observed; `mail-core-9000` absent in this separate plane | `host-evidence/evidence-11-session-version.txt` through `evidence-15-session-dominfo.txt`: read-only `qemu:///session` queries | 2026-07-31T21:15:56Z through 2026-07-31T21:15:57Z | high | All session-plane read-only queries succeeded; this is distinct from, and does not replace, the system construction plane. |
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

Live mutation during this inventory run: none. The earlier approved package
transaction and verified bootstrap state are recorded in commit
`f1ab8fcc2f9a0b00b3f2ea25650d7a7c24aa0f3e`.

## Storage discovery — 2026-07-31

Packet: `implementation/2026-07-31-matriarch-vm-storage-discovery.packet.md`

Evidence profile: `matriarch-storage-readonly-v1`

Private evidence reference:
`handoff/runs/20260731T213059Z-2ee5e6e-30364/host-evidence/`

Evidence manifest:
`handoff/runs/20260731T213059Z-2ee5e6e-30364/host-evidence/manifest.sha256`

Collection time: 2026-07-31T21:30:59Z

This section records only the supervisor-verified evidence supplied for this
storage-discovery run. No host inspection was performed by this worker, and no
host-related conclusion below relies on earlier inventory evidence or
historical device names.

### Evidence limits

`df --bytes` failed because that option was not recognized, so the bundle does
not establish filesystem free capacity. `pvs`, `vgs`, and `lvs` were
permission-denied; consequently LVM ownership, allocation, and free capacity
are unverified. `zpool` and `zfs` were unavailable, so ZFS state is
unverified. `btrfs filesystem show` observed the `fedora` filesystem but also
reported a permission error and a missing device path; it cannot establish
available capacity or an allocation suitable for reuse. These limits are
recorded respectively in `host-evidence/evidence-03-df.txt`,
`evidence-05-pvs.txt` through `evidence-07-lvs.txt`,
`evidence-09-zpool.txt`, `evidence-10-zfs.txt`, and
`evidence-08-btrfs.txt`, all collected at 2026-07-31T21:30:59Z.

### Candidate classification

| Observed location | Classification | Evidence-cited facts and consequence |
| --- | --- | --- |
| `/dev/sda` (31,037,849,600 bytes; USB) | unsuitable — ownership unknown | It is an encrypted LUKS device with no mountpoint. The bundle supplies no owner, capacity-free, or reuse approval evidence; do not treat the absent mountpoint as unused. `host-evidence/evidence-01-lsblk.txt`, 2026-07-31T21:30:59Z. |
| `/dev/sdb` and its `LAB-VENTOY`, `VTOYEFI`, and `lab-vault` partitions | unsuitable — active unrelated use | The USB device already contains exFAT, FAT16, and LUKS partitions with those labels. Its existing layout presents collision and data-loss risk. `host-evidence/evidence-01-lsblk.txt`, 2026-07-31T21:30:59Z. |
| `/dev/zram0` | unsuitable — active unrelated use | It is an active swap device (`[SWAP]`). `host-evidence/evidence-01-lsblk.txt`, 2026-07-31T21:30:59Z. |
| `/dev/nvme1n1` and its Fedora partitions | unsuitable — active unrelated use | Its EFI, `/boot`, and Btrfs partitions support the current root, `/home`, and container-storage mounts. The Btrfs observation also reports 1.09 TiB used, but not usable free capacity. `host-evidence/evidence-01-lsblk.txt`, `evidence-02-findmnt.txt`, and `evidence-08-btrfs.txt`, 2026-07-31T21:30:59Z. |
| `/dev/nvme0n1` and its existing partitions | unsuitable — ownership unknown | It contains existing VFAT, NTFS, ext4, and Btrfs partitions, including `bazzite_xboot` and `bazzite_bazzite`. No ownership/reuse approval, free-capacity, or consumer evidence establishes a safe allocation, even though no mountpoint is shown. `host-evidence/evidence-01-lsblk.txt`, 2026-07-31T21:30:59Z. |
| Existing filesystem paths and managed storage | unverified | The observed local root and NFS paths are already mounted; their free capacity and storage-management ownership are not established for VM use. LVM and ZFS observations are incomplete, and no libvirt-pool observation is in this profile. `host-evidence/evidence-02-findmnt.txt`, `evidence-03-df.txt`, `evidence-05-pvs.txt` through `evidence-10-zfs.txt`, 2026-07-31T21:30:59Z. |

### Decision 1 proposal — system and mail-data storage

**Completion classification:** STORAGE REQUIRES OPERATOR NOMINATION

No safe candidate is identified. The observed devices are either already in
unrelated use, contain existing data with ownership unknown, or have
inconclusive management and free-capacity evidence. In particular, no evidence
in this run supports a storage-pool name, a directory path, an unused block
device, or available space sufficient for the proposed 32 GiB system disk and
64 GiB separate mail-data disk.

| Decision item | Proposal |
| --- | --- |
| Recommended VM system-disk location | UNRESOLVED; operator must nominate a durable location for targeted read-only verification. |
| Recommended separate mail-data location | UNRESOLVED; operator must nominate a separately approved durable location. |
| Separate volumes in one existing storage pool | UNRESOLVED; this profile contains no libvirt-pool observation and no evidence of pool free capacity or ownership. |
| Current format and ownership | No nominated location. Observed formats and their classifications are listed above; ownership suitable for reuse is not evidenced. |
| Available capacity | UNRESOLVED; `df` failed and LVM queries were permission-denied. |
| Collision and data-loss risks | Reusing any observed populated, encrypted, mounted, swap, or otherwise unapproved location can collide with unrelated data or consumers. |
| Later implementation requirements | UNRESOLVED pending nomination. A later approved implementation may require a libvirt storage pool or approved directories, and may require qcow2 or raw volumes; formatting, partitioning, or mount changes are not authorized or proposed by this packet. |

Exact proposed values remain fail-closed:

```text
VM_STORAGE=UNRESOLVED_DURABLE_STORAGE
SYSTEM_DISK_REFERENCE=UNRESOLVED_OPERATOR_NOMINATION
MAIL_DATA_STORAGE=UNRESOLVED_DURABLE_DATA_STORAGE
MAIL_DATA_DISK_REFERENCE=UNRESOLVED_OPERATOR_NOMINATION
```

`MAIL_DATA_STORAGE` denotes the Decision 1 proposal name; the current render
contract continues to use `VM_DATA_STORAGE` and remains
`UNRESOLVED_DURABLE_DATA_STORAGE`. No value above authorizes a pool, directory,
disk image, format, partition, mount change, or VM creation.

### Operator nomination correction — 2026-07-31

The operator nominated a future 256 GiB sibling partition, intended to become
`/dev/nvme1n1p5`, from the currently unpartitioned tail of `nvme1n1`. The
sealed `lsblk` evidence supports this distinction: the 2,000,398,934,016-byte
disk contains only partitions `p1` through `p4`, whose recorded sizes total
1,625,837,010,944 bytes, leaving 374,561,923,072 bytes (about 348.8 GiB)
unaccounted for by the current partition list. The active Fedora Btrfs root is
`nvme1n1p3`; it is not the nominated source and must not be shrunk or reused.

This is an operator nomination and capacity observation, not proof of exact
on-disk free-extent geometry, ownership clearance, or future storage format.
It does not authorize creation of `p5`, any filesystem, mount, directory,
libvirt pool, disk image, or VM. `VM_STORAGE`, `SYSTEM_DISK_REFERENCE`,
`MAIL_DATA_STORAGE`, and `MAIL_DATA_DISK_REFERENCE` remain unresolved pending
a separately reviewed implementation packet that validates the exact free
extent and renders the bounded future mutation.

### Stop condition

Stop at Decision 1. An operator nomination and a separately authorized
targeted read-only verification are required before a system-disk location can
be selected. Do not proceed to network or guest-address decisions. Live
mutation during this storage-discovery run: none.

## Storage construction execution — 2026-07-31

Packet: `implementation/2026-07-31-matriarch-mail-core-storage-construction.packet.md`

Private execution evidence:
`handoff/runs/20260731T215600Z-df6f2fe-storage-execution/`

The immediate preflight matched the reviewed GPT layout. `/dev/nvme1n1p4`
ended at sector `3175464959`; the free tail began at `3175464960`. Only
`/dev/nvme1n1p5` was created, with exact boundaries `3175464960` through
`3712335871` inclusive (536870912 sectors, 256 GiB). The kernel reread the
partition table successfully. Partitions `p1` through `p4` were not changed.

The first attempt stopped before formatting because its generic `blkid` guard
treated the expected new GPT `PARTUUID` as a filesystem signature. The guard
was corrected and committed as `df6f2fe78edf03959a4b66f7d32f33516ab70479`.
The resumed pre-format check established that `p5` had no filesystem `TYPE` or
label. `mkfs.xfs` then rejected the original overlength XFS-label proposal
before writing because XFS labels are limited to 12 characters. The
operator-approved `mailcore-vm` label replaced that proposal.

Current state: `p5` is unformatted and unmounted; no fstab entry, mountpoint,
SELinux mapping, libvirt storage pool, qcow2 volume, network, domain, or VM
was created. No reboot occurred. The requested XFS label cannot be applied as
specified; do not resume until the operator supplies a label of at most 12
characters or changes the filesystem decision.

Live mutation: creation of `/dev/nvme1n1p5` only.

## Accepted storage construction state — 2026-07-31

Packet: `implementation/2026-07-31-matriarch-mail-core-storage-construction.packet.md`

Packet refinements: `3cc4fcc6dde54ecd2096bb15829c767ab6a71a91`,
`df6f2fe78edf03959a4b66f7d32f33516ab70479`,
`8626c17cded1d9d519f33147c23104bf9677289f`, and
`2e0c6fc457468d93832de370eb06afe227805dfc`.

Private execution evidence:
`handoff/runs/20260731T220000Z-8626c17-storage-execution/`

| Item | Verified state | Evidence / rationale |
| --- | --- | --- |
| GPT geometry | `p5` starts at `3175464960s`, ends at `3712335871s`, and is 536870912 sectors (256 GiB) | Final `parted -m` and `lsblk` checks. `p1` through `p4` retain their preflight boundaries. |
| Filesystem | XFS on `/dev/nvme1n1p5`; filesystem label `mailcore-vm` | `blkid` label/type check and active mount verification. The XFS UUID was observed locally for fstab correlation and is intentionally not recorded in Git. |
| Persistent mount | UUID-based fstab entry for `/var/lib/libvirt/mail-core`; source `/dev/nvme1n1p5` | Entry recorded with UUID redacted; `systemctl daemon-reload` followed by `findmnt --verify` passed without warnings. |
| SELinux and ownership | Mountpoint and both volumes are `root:root`, mode `0755` / `0600`, context `virt_image_t` | Fedora `semanage fcontext` mapping limited to `/var/lib/libvirt/mail-core(/.*)?`, followed by `restorecon` and `ls -Z`. No SELinux disablement or broad custom policy. |
| Libvirt pool | `mail-core-construction`, directory target `/var/lib/libvirt/mail-core`, persistent and running, autostart `no` | Pool definition and `pool-info`; mount source/UUID guard passed before pool and volume operations. |
| System disk | `mail-core-9000-system.qcow2`, qcow2 virtual size 32 GiB, sparse | `qemu-img info --output=json`; actual initial allocation approximately 200 KiB. |
| Mail-data disk | `mail-core-9000-data.qcow2`, qcow2 virtual size 192 GiB, sparse | `qemu-img info --output=json`; actual initial allocation approximately 200 KiB. |
| Capacity | Pool filesystem capacity 255.88 GiB; available capacity 250.94 GiB after creation | `df -B1` and `virsh pool-info`. The 32 GiB reserve is an operating threshold, not physically reserved space. |
| Construction encryption decision | No additional host-layer LUKS encryption for this temporary construction pool | Operator-approved construction-stage decision only; review final appliance encryption again before promotion readiness. |
| Soak capacity guard | Warn or stop workload growth before host filesystem free space drops below 32 GiB | Required for subsequent soak/VM-construction work; no daemon or monitor was enabled by this storage packet. |
| VM state | `mail-core-9000` absent | Read-only system libvirt `dominfo` remained absent after storage construction. |

Construction-only inventory values are now fixed as:

```text
VM_STORAGE=mail-core-construction
SYSTEM_DISK_REFERENCE=mail-core-9000-system.qcow2
MAIL_DATA_STORAGE=mail-core-construction
MAIL_DATA_DISK_REFERENCE=mail-core-9000-data.qcow2
MOUNTPOINT=/var/lib/libvirt/mail-core
XFS_LABEL=mailcore-vm
```

These do not populate the production Proxmox value file or authorize VM
construction. The live mutations were limited to p5 creation, XFS formatting,
the UUID-based persistent mount definition and daemon reload, the path-specific
SELinux file-context mapping, local directory creation, pool definition/start,
and the two sparse qcow2 files. No VM, guest OS, libvirt network, NetworkManager,
firewall, DNS, TLS, mail identity, credential, Fastmail, or reboot action
occurred.

Independent review classification: **ACCEPTED**.

## Network attachment discovery — 2026-07-31

Packet: `implementation/2026-07-31-mail-core-network-decision.packet.md`

Evidence profile: `matriarch-network-readonly-v1`

Private evidence reference:
`handoff/runs/20260731T220648Z-5b59090-52043/host-evidence/`

Evidence manifest:
`handoff/runs/20260731T220648Z-5b59090-52043/host-evidence/manifest.sha256`

Collection time: 2026-07-31T22:06:48Z through 2026-07-31T22:06:49Z

This section records only the supervisor-verified evidence supplied for this
run. The evidence manifest verified successfully before this record was
written. No host inspection was performed by this worker; every host-related
conclusion below is limited to the cited evidence items.

### Observed state

`eno1` is active with NetworkManager connection `Lab 2.5GbE`; `enp7s0` is
active with `Lab 10GbE`; and VLAN device `eno1.80` is active with `Lab Admin
VLAN 80`. These interfaces have host addresses and connected routes, but their
observations do not establish approval for a stable guest attachment or select
an internal-services network. `evidence-03-ip-link.txt`,
`evidence-04-ip-address.txt`, `evidence-05-ip-route.txt`,
`evidence-08-nm-devices.txt`, and `evidence-09-nm-active.txt`, all collected
at 2026-07-31T22:06:48Z.

The only observed Linux bridge is `podman0`, with `veth0` as its bridge port;
it is an externally connected Podman bridge. It is not evidence of an approved
cluster-reachable mail attachment. `evidence-03-ip-link.txt`,
`evidence-06-bridge-link.txt`, and `evidence-08-nm-devices.txt`, collected at
2026-07-31T22:06:48Z.

The active firewall zones associate `eno1`, `enp7s0`, and `eno1.80` with
`FedoraWorkstation`; this does not select a guest network or authorize a
firewall change. `evidence-10-firewall-zones.txt`, collected at
2026-07-31T22:06:48Z. The system libvirt connection was available, but its
network inventory was empty. `evidence-11-system-version.txt` and
`evidence-12-system-networks.txt`, collected at 2026-07-31T22:06:49Z.

### Decision 3 — network attachment

NETWORK_ATTACHMENT=UNRESOLVED_OPERATOR_NETWORK_ATTACHMENT

**Recommendation:** keep the value unresolved. When the operator approves an
internal-services network, the practical attachment is a dedicated
operator-approved Linux bridge directly attached to that approved physical
interface or approved VLAN, with the future domain connected to that bridge.
That architecture can provide stable cluster-reachable internal addressing
without public exposure or port-forwarding fragility, but the current evidence
does not identify the approved parent interface/VLAN, bridge name, or address
authority. It therefore cannot establish that an existing attachment carries
the required address.

**The one Decision 3 choice:** accept the recommendation to keep
`NETWORK_ATTACHMENT` unresolved, or explicitly approve the recommended
operator-approved Linux-bridge attachment. No other Decision 3 alternative is
presented by this record.

If approved in a later bounded packet, the exact live changes must be limited
to: create the specifically named Linux bridge; attach only the specifically
approved physical interface or VLAN as its port; migrate only the approved host
network configuration to that bridge if required; and attach
`mail-core-9000` to that bridge. The exact parent, VLAN, bridge name, host
configuration, guest address, gateway, resolvers, DNS ownership, TLS, and
firewall policy remain unresolved and must be validated before any such work.
Changing an active physical or VLAN attachment can interrupt host connectivity;
the rollback path is to detach the proposed bridge attachment, restore the
previously captured NetworkManager connection/profile and its IP configuration
to the original approved parent, and remove only the new bridge after the
host's prior connectivity is verified. This is a proposed future procedure,
not authorization to perform it.

Macvtap is inferior because it may prevent reliable host-to-guest
communication. Libvirt NAT is inferior because no defined system libvirt
network exists in this evidence and NAT would not itself provide the required
approved internal reachability without additional exposure or port-forwarding
dependencies. Reusing `podman0` is inferior because its observed port is a
Podman veth and no evidence approves it for mail traffic.

### Stop condition

Stop after Decision 3. No approved internal-services attachment is established
by this evidence; guest address, gateway, resolver, DNS, TLS, firewall, and VM
work remain outside this packet. Live mutation during this discovery run: none.
