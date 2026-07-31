# Matriarch mail-core storage construction packet

Date: 2026-07-31
Status: operator-authorized bounded mutation; exact preflight render required
Target: `ws-matriarch`, Fedora 44
Construction ID: `9000`; domain name: `mail-core-9000`

## Authority and immutable boundary

This packet is the complete operator-authorized storage implementation for the
allocated 256 GiB unpartitioned tail of `/dev/nvme1n1`. The exact geometry and
commands below are a reviewed baseline only: immediately before the first
write, the preflight must prove the same state or stop.

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
3. Capture a recoverable GPT backup using `sfdisk --dump /dev/nvme1n1` into
   the ignored run evidence directory, with restricted permissions. Do not
   print raw partition UUIDs in Git, logs, or chat.
4. Use `parted -s /dev/nvme1n1 unit s print free` and a read-only block view
   to prove the sole tail extent is exactly `3175464960s` through
   `3907029134s`, immediately after `p4`, and that no `p5` exists. The
   approved new range is exactly `3175464960s` through `3712335871s`
   inclusive: 536870912 sectors at 512 bytes/sector (256 GiB). Stop if any
   boundary, existing partition, sector size, partition table type, or free
   extent differs. Do not substitute a different disk or an earlier gap.
5. Confirm required local tools are installed: `parted`, `sfdisk`, `partprobe`,
   `udevadm`, `mkfs.xfs`, `blkid`, `mount`, `findmnt`, `virsh`, `qemu-img`,
   `semanage`, and `restorecon`. Stop if any is unavailable; package
   installation is out of scope.
6. Confirm SELinux is enforcing and that Fedora's established
   `/var/lib/libvirt(/.*)?` file-context rule is `virt_var_lib_t`. No custom
   policy or broad relabeling is authorized. Confirm no existing local
   file-context override already claims `/var/lib/libvirt/mail-core`.
7. Rerun gates 1–4 immediately before the write. If the kernel cannot reread
   the table after creation, stop before formatting; do not reboot
   automatically.

## Reviewed command render

The run directory below is the ignored, restricted evidence directory created
for this execution. Values derived after `mkfs` are observed locally; no UUID
is guessed or recorded in this packet. Commands marked **write** execute only
after the pre-mutation gates pass in the same run.

```sh
# read-only preflight and recoverable backup
sudo -n sfdisk --dump /dev/nvme1n1 >"$RUN_DIR/nvme1n1.gpt.pre.sfdisk"
sudo -n parted -s /dev/nvme1n1 unit s print free
sudo -n lsblk --bytes --output NAME,PATH,TYPE,SIZE,START,FSTYPE,LABEL,MOUNTPOINTS /dev/nvme1n1
sudo -n blkid -L mail-core-vmstore
sudo -n findmnt --target /var/lib/libvirt/mail-core
sudo -n virsh --readonly --connect qemu:///system pool-info mail-core-construction

# write: create only p5 in the exact confirmed tail, then safely reread it
sudo -n parted -s /dev/nvme1n1 unit s mkpart mail-core-vmstore xfs 3175464960s 3712335871s
sudo -n partprobe /dev/nvme1n1
sudo -n udevadm settle --timeout=15
sudo -n parted -s /dev/nvme1n1 unit s print
sudo -n lsblk --bytes --output NAME,PATH,TYPE,SIZE,START,FSTYPE,LABEL,MOUNTPOINTS /dev/nvme1n1

# write: create the filesystem only after p5's exact boundaries are verified
# A GPT PARTUUID is expected on a newly created partition; reject only an
# existing filesystem TYPE or filesystem label.
existing_type=$(sudo -n blkid -s TYPE -o value /dev/nvme1n1p5 2>/dev/null || true)
existing_label=$(sudo -n blkid -s LABEL -o value /dev/nvme1n1p5 2>/dev/null || true)
test -z "$existing_type"
test -z "$existing_label"
sudo -n mkfs.xfs -L mail-core-vmstore /dev/nvme1n1p5
new_uuid=$(sudo -n blkid -s UUID -o value /dev/nvme1n1p5)
test -n "$new_uuid"

# write: mount only the new XFS filesystem, with a UUID-bound fstab entry
sudo -n install -d -o root -g root -m 0755 /var/lib/libvirt/mail-core
sudo -n semanage fcontext -a -t virt_image_t '/var/lib/libvirt/mail-core(/.*)?'
sudo -n restorecon -RFv /var/lib/libvirt/mail-core
sudo -n ls -Zd /var/lib/libvirt/mail-core
sudo -n cp -a /etc/fstab "$RUN_DIR/fstab.pre"
tmp_fstab=/etc/fstab.mail-core.$$
sudo -n cp -a /etc/fstab "$tmp_fstab"
printf 'UUID=%s /var/lib/libvirt/mail-core xfs defaults 0 2\n' "$new_uuid" | sudo -n tee -a "$tmp_fstab" >/dev/null
sudo -n mv -f "$tmp_fstab" /etc/fstab
sudo -n findmnt --verify
sudo -n mount /var/lib/libvirt/mail-core
sudo -n findmnt --target /var/lib/libvirt/mail-core

# write: define/start only the guarded directory pool and sparse volumes
sudo -n virsh --connect qemu:///system pool-define-as mail-core-construction dir --target /var/lib/libvirt/mail-core
sudo -n virsh --connect qemu:///system pool-start mail-core-construction
sudo -n qemu-img create -f qcow2 /var/lib/libvirt/mail-core/mail-core-9000-system.qcow2 32G
sudo -n qemu-img create -f qcow2 /var/lib/libvirt/mail-core/mail-core-9000-data.qcow2 192G
sudo -n restorecon -RFv /var/lib/libvirt/mail-core
sudo -n ls -lZ /var/lib/libvirt/mail-core/mail-core-9000-system.qcow2 /var/lib/libvirt/mail-core/mail-core-9000-data.qcow2
sudo -n qemu-img info --output=json /var/lib/libvirt/mail-core/mail-core-9000-system.qcow2
sudo -n qemu-img info --output=json /var/lib/libvirt/mail-core/mail-core-9000-data.qcow2
sudo -n df -B1 --output=source,fstype,size,used,avail,target /var/lib/libvirt/mail-core
```

Before the pool start and before each `qemu-img create`, independently verify
with `findmnt` that the target is mounted from `/dev/nvme1n1p5` and its UUID
equals `new_uuid`. If the mount guard fails, do not define/start the pool or
create a volume. Before appending fstab, verify the mountpoint has no existing
entry; otherwise stop rather than duplicate or overwrite it.

## Bounded implementation sequence

After final operator approval of the preflight render:

1. Create only GPT partition 5 in the exact reviewed sector range. After
   `partprobe` and `udevadm settle`, verify that it is partition number 5 with
   start `3175464960s`, end `3712335871s`, and exactly 256 GiB. Stop before
   formatting if the kernel cannot reread the table safely; do not reboot.
2. Run `mkfs.xfs -L mail-core-vmstore /dev/nvme1n1p5` exactly once. Before the
   command, re-check that `p5` has no filesystem `TYPE` or label and is the
   new partition on the approved disk. Its GPT `PARTUUID` is expected and is
   not a filesystem signature. Do not force or overwrite an existing
   filesystem.
3. Create `/var/lib/libvirt/mail-core` only as `root:root`, mode `0755`.
   Add Fedora's standard `virt_image_t` file-context mapping only for that
   path, apply it with `restorecon`, and verify it on the mountpoint and both
   volume files. Do not disable SELinux or add broad custom policy.
4. Obtain the newly created filesystem UUID locally and append one exact
   UUID-based fstab line with `defaults` only if no mountpoint entry already
   exists. Preserve a restricted, recoverable fstab backup in the evidence
   directory. Validate with `findmnt --verify`; stop on a validation error.
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
   creation, verify the target filename is absent and the target is the mounted
   `p5` filesystem. Stop if available filesystem space after creation would be
   less than 32 GiB.

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

Record the construction-stage decision that this temporary host pool has no
additional host-layer LUKS encryption. This does not decide the production
appliance's final encryption policy; review it again before promotion
readiness. Add a soak requirement that warns or stops growth before filesystem
free space falls below 32 GiB. The reserve is a free-space operating threshold,
not physically reserved capacity.

Stop after storage verification. Do not define or create VM `mail-core-9000`,
do not proceed to network or guest-address decisions, and do not enable pool
autostart. Any failed gate leaves the current state intact where possible and
requires operator review before retrying.
