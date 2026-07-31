# Matriarch VM-storage discovery packet

Date: 2026-07-31
Status: approved read-only discovery
Target: current Fedora 44 Matriarch construction host
Construction ID: `9000`; domain name: `mail-core-9000`

HOST_EVIDENCE_PROFILE=matriarch-storage-readonly-v1

## Purpose and authority

Identify existing storage candidates for the construction system disk and the
separate mail-data disk. This packet authorizes only the fixed, unprivileged,
sanitized metadata collection in `matriarch-storage-readonly-v1`, repository
documentation, validation, and a decision proposal. It does not select,
format, mount, partition, label, pool, or otherwise modify storage, and does
not authorize VM 9000 creation.

Historical and superseded records may identify candidates but never establish
current device identity, ownership, path, format, capacity, or suitability.
Do not assume `nvme3n1` is a current or correct device merely because it was
mentioned historically.

## Fixed observations and handling

The supervisor must collect only these fixed read-only commands; packet text,
environment values, and model output cannot add a device, path, or command:

```text
lsblk --json --bytes --output NAME,KNAME,PATH,TYPE,SIZE,FSTYPE,FSVER,LABEL,UUID,PARTUUID,MOUNTPOINTS,MODEL,SERIAL,WWN,TRAN,ROTA,PKNAME
findmnt --json
df --bytes --output=source,fstype,size,used,avail,pcent,target
blkid
pvs --noheadings --units b --nosuffix --options pv_name,pv_size,pv_free,vg_name,pv_attr
vgs --noheadings --units b --nosuffix --options vg_name,vg_size,vg_free,vg_attr
lvs --noheadings --units b --nosuffix --options lv_name,vg_name,lv_size,lv_attr,lv_path
btrfs filesystem show
zpool status
zfs list
cat /proc/mdstat
```

The collector must record each command as `observed`, `unavailable`,
`permission-denied`, `timed-out`, or `failed`. It must redact serial numbers,
UUIDs, PARTUUIDs, and WWNs while preserving enough non-secret metadata to
correlate an observed device. No sudo, polkit, password entry, or privilege
escalation is authorized. Do not inventory unrelated user file contents.

## Candidate classification

For every relevant device or existing storage location, classify it as exactly
one of:

```text
unsuitable — active unrelated use
unsuitable — insufficient capacity
unsuitable — ownership unknown
potentially suitable — existing filesystem/path
potentially suitable — unused block device
unverified
```

No mountpoint alone establishes safety. Consider current ownership, existing
data, format, active consumers, capacity/free space, and LVM, Btrfs, ZFS,
mdraid, libvirt, or other-subsystem management. A missing, denied, or
inconclusive observation is `unverified`, not evidence of an unused device.

## Required decision proposal

Update only `docs/matriarch-target-inventory.md` with sanitized, evidence-cited
facts and an operator-facing Decision 1 proposal containing:

1. Recommended location for the VM system disk.
2. Recommended location for the separate mail-data disk.
3. Whether both can occupy separate volumes in one existing storage pool.
4. Current format and ownership.
5. Available capacity.
6. Collision and data-loss risks.
7. Whether later implementation would require a libvirt storage pool,
   directories, formatting/partitioning, qcow2/raw volumes, or mount changes.
8. Exact proposed values for `VM_STORAGE`, `SYSTEM_DISK_REFERENCE`,
   `MAIL_DATA_STORAGE`, and `MAIL_DATA_DISK_REFERENCE`.

Leave every value unresolved unless current evidence directly supports its
classification and the operator can approve it. Do not inspect an opaque export
destination or select a backup architecture.

## Prohibitions

Do not format, partition, create filesystems, mount/unmount, create directories
outside ignored evidence/runtime paths, create/activate LVM/Btrfs/ZFS/mdraid/
libvirt resources, create disk images, define pools, alter fstab/systemd mount
units, inspect unrelated file contents, or create VM 9000.

## Completion and stop condition

Run repository validation and preserve the expected fail-closed production
render result. The worker result must issue exactly one standalone completion
classification:

```text
STORAGE CANDIDATE IDENTIFIED
STORAGE REQUIRES OPERATOR NOMINATION
NO SAFE STORAGE CANDIDATE
```

If a safe candidate is identified, return only to Decision 1 with an
evidence-backed recommendation for the exact location and all future mutation
needed. Do not proceed to network or guest-address decisions until the operator
approves system-disk storage.
