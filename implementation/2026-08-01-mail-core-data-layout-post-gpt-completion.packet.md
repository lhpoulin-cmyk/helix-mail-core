# Mail-core data-layout post-GPT completion packet

Status: rendered correction — explicit operator authorization required
Predecessor: `2026-08-01-mail-core-guest-baseline-and-mail-data-layout.packet.md`

## Fixed target and current state

This packet completes only the preserved, already authorized data layout in
`mail-core-9000`. `/dev/vdb` is exactly 206158430208 bytes and contains the one
reviewed GPT partition `/dev/vdb1`, sectors 2048 through 402653150, type 8300,
name `stalwart-data`. `sgdisk --verify` passes. The partition has expected GPT
metadata but no filesystem type, UUID, label, or signature.

Do not rerun `sgdisk`, recreate the partition, touch `/dev/vda`, install more
packages, or change networking, accounts, DNS, TLS, mail, libvirt, or host
state.

## Immediate fail-closed preflight

```sh
set -eu
test "$(hostname -s)" = mail
test "$(blockdev --getsize64 /dev/vda)" = 34359738368
test "$(blockdev --getsize64 /dev/vdb)" = 206158430208
test "$(blockdev --getsz /dev/vdb)" = 402653184
test -b /dev/vdb1
test "$(lsblk -bnro START /dev/vdb1)" = 2048
test "$(blockdev --getsz /dev/vdb1)" = 402651103
test "$(lsblk -dnro PARTTYPE /dev/vdb1)" = 0fc63daf-8483-4772-8e79-3d69d8477de4
test "$(lsblk -dnro PARTLABEL /dev/vdb1)" = stalwart-data
sgdisk --verify /dev/vdb
test -z "$(blkid -s TYPE -o value /dev/vdb1 || true)"
test -z "$(blkid -s UUID -o value /dev/vdb1 || true)"
test -z "$(blkid -s LABEL -o value /dev/vdb1 || true)"
test -z "$(wipefs -n /dev/vdb1)"
! findmnt -rn -S /dev/vdb1
! swapon --noheadings --show=NAME | grep -Fx /dev/vdb1
! pvs --noheadings -o pv_name 2>/dev/null | grep -Fx /dev/vdb1
test ! -e /srv/stalwart
test ! -e /root/fstab.mail-core-data-before
! grep -Eq '[[:space:]]/srv/stalwart[[:space:]]' /etc/fstab
! blkid -L stalwart-data
```

## Exact completion

```sh
set -eu
mkfs.xfs -L stalwart-data /dev/vdb1
data_uuid=$(blkid -s UUID -o value /dev/vdb1)
test -n "$data_uuid"
test "$(blkid -s TYPE -o value /dev/vdb1)" = xfs
test "$(blkid -s LABEL -o value /dev/vdb1)" = stalwart-data

cp -a /etc/fstab /root/fstab.mail-core-data-before
install -d -o root -g root -m 0755 /srv/stalwart
printf 'UUID=%s /srv/stalwart xfs defaults,nodev,nosuid 0 2\n' "$data_uuid" >> /etc/fstab
findmnt --verify --verbose
mount /srv/stalwart
```

The runtime UUID must not enter Git. Stop without destructive repair after any
failure.

## Verification

Run the predecessor packet's full mount, account, service, listener, domain,
host-storage, and host-network verification. Perform one controlled guest
reboot, wait for QEMU guest agent and SSH, then prove `/srv/stalwart` remounted
from `/dev/vdb1` by the persisted UUID. Confirm the system boots the newly
installed Debian security kernel, `/srv/stalwart/data` remains absent, and VM
autostart remains disabled.

End with exactly one disposition:

```text
GUEST BASELINE AND MAIL DATA ACCEPTED
CORRECTION REQUIRED
BLOCKED — OPERATOR INPUT REQUIRED
```
