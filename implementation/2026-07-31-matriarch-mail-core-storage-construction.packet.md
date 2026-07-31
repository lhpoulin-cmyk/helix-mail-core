# Matriarch mail-core storage construction packet

Date: 2026-07-31
Status: proposed bounded mutation; execution requires final operator approval
Target: `ws-matriarch`, Fedora 44
Construction ID: `9000`; domain name: `mail-core-9000`

## Authority and immutable boundary

This packet is the complete proposed storage implementation for the
operator-allocated 256 GiB unpartitioned tail of `/dev/nvme1n1`. It is not
execution authority. Before implementation, the operator must review the
rendered commands and approve this packet explicitly.

The implementation may create only `/dev/nvme1n1p5`; format only that new
partition; create only the declared mountpoint, persistent mount entry,
directory-backed libvirt pool, and two declared qcow2 volumes. It must not
define, create, or start `mail-core-9000`.

Do not modify `/dev/nvme1n1p1` through `/dev/nvme1n1p4`; do not shrink, move,
repartition, or format any existing partition; do not alter any other device,
filesystem, mount, libvirt pool, network, DNS, firewall, certificate,
credential, service, or access-control setting. No unrelated storage redesign
is authorized.

## Approved target layout

| Layer | Exact value |
| --- | --- |
| Host disk | `/dev/nvme1n1` |
| New sibling partition | `/dev/nvme1n1p5`, 256 GiB |
| Filesystem | XFS, label `mail-core-vmstore` |
| Mountpoint | `/var/lib/libvirt/mail-core` |
| Persistent mount | one UUID-based `/etc/fstab` entry for that mountpoint |
| Libvirt pool | `mail-core-construction`, type `dir`, target `/var/lib/libvirt/mail-core` |
| System volume | `mail-core-9000-system.qcow2`, virtual size 32 GiB |
| Mail-data volume | `mail-core-9000-data.qcow2`, virtual size 192 GiB |
| Intentional reserve | approximately 32 GiB; do not preallocate either image |

The system and mail-data disks remain distinct qcow2 volumes in the same host
pool. The pool is started only as needed to create and verify those volumes;
no pool autostart setting is changed by this packet.

## Pre-mutation gates

Run every observation before changing state. Record sanitized results and stop
without mutation on any failure, ambiguity, pre-existing target, or mismatch.

1. Confirm `ws-matriarch`, Fedora 44, clean repository state, current kernel,
   and that `/dev/nvme1n1` is the same current Fedora system disk described by
   the accepted evidence: `p1` mounted at `/boot/efi`, `p2` at `/boot`, `p3`
   Btrfs-mounted at `/`, `/home`, and container storage, and `p4` remains an
   unmounted ext4 `OS_TESTING` partition.
2. Confirm `/dev/nvme1n1p5` does not exist, no `mail-core-vmstore` filesystem
   label exists, the mountpoint is absent or empty and not mounted, the
   `mail-core-construction` pool does not exist, and neither qcow2 volume
   exists anywhere in the target directory.
3. Use a read-only partition-table view that reports free extents (for example
   `parted --script /dev/nvme1n1 unit MiB print free`) and a read-only block
   view (`lsblk --bytes ...`) to prove a single, contiguous, aligned free tail
   after `p4` contains at least 262144 MiB. Record its exact start and end.
   Stop if there is any overlap, any free extent is ambiguous, or the free tail
   is smaller than 256 GiB. Do not substitute a different disk or an earlier
   gap.
4. Confirm required local tools are installed (`sgdisk` or an equivalently
   reviewed GPT editor, `mkfs.xfs`, `blkid`, `mount`, `findmnt`, `virsh`, and
   `qemu-img`). Stop if any is unavailable; installing packages is out of
   scope.
5. Render the exact partition start/end and all subsequent commands for
   operator review. The initial write must be bounded to GPT partition number
   5 in the confirmed free tail, with a 256 GiB length. Do not proceed on a
   stale preflight: rerun gates 1–3 immediately before the write.

## Bounded implementation sequence

After final operator approval of the preflight render:

1. Create only GPT partition 5 in the confirmed free tail, type Linux
   filesystem, size exactly 256 GiB. Re-read the partition table and confirm
   the kernel exposes `/dev/nvme1n1p5`; stop if it does not.
2. Run `mkfs.xfs -L mail-core-vmstore /dev/nvme1n1p5` exactly once. Before the
   command, re-check that `p5` has no filesystem signature and is the new
   partition on the approved disk. Do not force or overwrite an existing
   signature.
3. Create `/var/lib/libvirt/mail-core` with restrictive ownership and mode
   appropriate for the local libvirt QEMU service. Do not create any other
   directory.
4. Obtain the newly created filesystem UUID locally, render one exact
   UUID-based fstab line with `defaults`, and atomically add it only if no
   mountpoint entry already exists. Preserve an operator-readable backup of
   the prior fstab in the implementation evidence directory. Validate with
   `findmnt --verify`; stop on a validation error.
5. Mount only `/var/lib/libvirt/mail-core` from the new `p5`; verify source,
   XFS type, label, UUID correlation, and free capacity. Do not mount any
   other storage.
6. Define `mail-core-construction` as libvirt type `dir` at exactly
   `/var/lib/libvirt/mail-core`; start it only to create/verify its volumes.
   Stop if a pool of that name or target already exists. Do not define a
   default network, storage pool, disk, or domain.
7. Create only these sparse qcow2 volumes in the active pool:

   ```text
   mail-core-9000-system.qcow2  32 GiB virtual
   mail-core-9000-data.qcow2   192 GiB virtual
   ```

   Use `qemu-img create -f qcow2` with the exact names and virtual sizes. Do
   not use preallocation, raw images, or additional volumes. Before each
   creation, verify the target filename is absent. Stop if available filesystem
   space after creation would be less than approximately 32 GiB.

8. Verify: partition number/size; XFS label and UUID; mounted source and
   mountpoint; fstab validity; pool type/target/activity; both qcow2 formats,
   names, and virtual sizes; actual filesystem free space; and absence of
   `mail-core-9000`. Record each command, result, timestamp, and any mutation.

## Required records and stop condition

Update the Matriarch inventory with the exact sanitized post-state, including
the allocated `VM_STORAGE`, `SYSTEM_DISK_REFERENCE`, `MAIL_DATA_STORAGE`, and
`MAIL_DATA_DISK_REFERENCE` values only after successful verification. Record
the pool reserve and the fact that neither image was preallocated. Run
repository validation and a non-executing construction render.

Stop after storage verification. Do not define or create VM `mail-core-9000`,
do not proceed to network or guest-address decisions, and do not enable pool
autostart. Any failed gate leaves the current state intact where possible and
requires operator review before retrying.
