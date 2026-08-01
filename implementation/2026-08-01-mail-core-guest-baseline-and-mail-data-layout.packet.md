# Mail-core guest baseline and mail-data layout implementation packet

Status: rendered — explicit operator execution authorization required
Target: `mail-core-9000` on `qemu:///system`

## Authority and exclusions

This packet proposes one bounded guest mutation: update the installed Debian
13 system, install only the tools needed for the accepted data-disk layout,
and initialize the existing empty 192 GiB `/dev/vdb` as an XFS mount at
`/srv/stalwart`.

It does not authorize execution until the operator approves this committed
render. It does not install Stalwart, create mail identities, publish DNS,
issue TLS material, configure Fastmail, expose SMTP, change the frozen network,
enable domain autostart, or dereference `APPLIANCE_EXPORT_REFERENCE`.

The construction VM's protected temporary-password arrangement is explicitly
accepted. This packet does not enroll an SSH key, rotate the password, disable
SSH password authentication, or print/read the password into evidence. Root
SSH login remains disabled.

## Observed starting state

Read-only inspection after commit `1fa76bc` established:

- Debian 13.6, kernel `6.12.94+deb13-amd64`, hostname `mail`, FQDN
  `mail.home.arpa`;
- user `louis` is UID 1000 and a member of `sudo`;
- `PermitRootLogin no`; construction-stage `PasswordAuthentication yes`;
- SSH, QEMU guest agent, and `serial-getty@ttyS0` are active;
- only SSH is listening on TCP port 22; no mail listener exists;
- the domain has 2 vCPU, 4096 MiB RAM, one `br-lab10` NIC, and autostart
  disabled;
- `/dev/vda` is the installed system disk;
- `/dev/vdb` is exactly 206158430208 bytes (402653184 512-byte sectors), has
  no partition, filesystem, mount, swap, LVM, or RAID ownership;
- the separate offline qcow2 check already classified the disk as
  **VERIFIED GUEST-VISIBLE EMPTY**;
- `sgdisk` and `mkfs.xfs` are absent; the required Debian packages are `gdisk`
  and `xfsprogs`;
- a no-lock simulation of `apt-get full-upgrade` proposed the Debian stable
  kernel update to `6.12.100+deb13-amd64` with no removals.

Package state is time-sensitive. The execution must capture a fresh simulation
and stop on removals, a release change, a third-party repository, or an
unexpected package expansion.

## Fixed proposed layout

```text
device:       /dev/vdb (206158430208 bytes)
partition:    /dev/vdb1
table:        GPT
start sector: 2048
end sector:   402653150 (last usable GPT sector)
type:         Linux filesystem (8300)
name:         stalwart-data
filesystem:   XFS
label:        stalwartdata
mountpoint:   /srv/stalwart
persistence:  newly observed filesystem UUID in /etc/fstab
mount flags:  defaults,nodev,nosuid
ownership:    root:root 0755 at the mount root
```

The first and last GPT metadata areas account for sectors outside the proposed
partition. No LVM, RAID, encryption, swap, or additional partition is created.
`/srv/stalwart/data` is not created or assigned until the verified Stalwart
package/service identity is known.

## Immediate preflight

Run from the approved guest-management path without placing the temporary
password in a command line or log. Record results but sanitize UUIDs and device
identifiers in Git.

```sh
set -eu
test "$(hostname -s)" = mail
test "$(hostname -f)" = mail.home.arpa
test "$(id -u)" = 0
test "$(blockdev --getsize64 /dev/vdb)" = 206158430208
test "$(blockdev --getsz /dev/vdb)" = 402653184
test "$(lsblk -dnro TYPE /dev/vdb)" = disk
test -z "$(lsblk -nrpo NAME /dev/vdb | sed -n '2,$p')"
test -z "$(blkid /dev/vdb || true)"
test -z "$(wipefs -n /dev/vdb)"
! findmnt -rn -S /dev/vdb
! swapon --noheadings --show=NAME | grep -Fx /dev/vdb
! pvs --noheadings -o pv_name 2>/dev/null | grep -Fx /dev/vdb
if test -r /proc/mdstat; then
  test -z "$(awk 'NR > 1 && $1 != "unused" {print}' /proc/mdstat)"
else
  test -z "$(lsblk -nrpo TYPE /dev/vdb | grep -Fx raid || true)"
fi
test "$(systemctl is-active ssh)" = active
test "$(systemctl is-active qemu-guest-agent)" = active
sshd -T | grep -Fxi 'permitrootlogin no'
sshd -T | grep -Fxi 'passwordauthentication yes'
test ! -e /srv/stalwart
! grep -Eq '[[:space:]]/srv/stalwart[[:space:]]' /etc/fstab
! blkid -L stalwartdata
```

Also reconfirm from the host immediately before execution: the expected domain
identity/XML fingerprint, autostart disabled, `/dev/vdb` backed by
`mail-core-9000-data.qcow2`, the accepted bridge and host management state, and
more than 32 GiB free on the dedicated libvirt filesystem.

## Exact baseline and reboot stage

First capture `/etc/apt/sources.list` and `sources.list.d` metadata without
credentials. Then run the following exact guest operations:

```sh
set -eu
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -s full-upgrade | tee /root/mail-core-full-upgrade.simulation
grep -Eq ', 0 to remove( and [0-9]+ not upgraded)?\.$' /root/mail-core-full-upgrade.simulation
apt-get -y full-upgrade
apt-get -y --no-install-recommends install gdisk xfsprogs
systemctl is-enabled ssh
systemctl is-enabled qemu-guest-agent
systemctl is-enabled serial-getty@ttyS0.service
sshd -t
```

If `/run/reboot-required` exists, perform one controlled guest reboot, wait for
the domain, QEMU guest agent, and SSH to recover, then repeat every immediate
preflight check. A changed network, disk topology, domain definition, SSH
policy, or failed service stops the packet before storage mutation.

## Exact storage mutation

Only after the repeated preflight passes:

```sh
set -eu
test "$(blockdev --getsize64 /dev/vdb)" = 206158430208
test "$(blockdev --getsz /dev/vdb)" = 402653184
test -z "$(lsblk -nrpo NAME /dev/vdb | sed -n '2,$p')"
test -z "$(blkid /dev/vdb || true)"
test -z "$(wipefs -n /dev/vdb)"
test ! -e /srv/stalwart
! grep -Eq '[[:space:]]/srv/stalwart[[:space:]]' /etc/fstab
! blkid -L stalwartdata

sgdisk --clear \
  --new=1:2048:402653150 \
  --typecode=1:8300 \
  --change-name=1:stalwart-data \
  /dev/vdb
blockdev --rereadpt /dev/vdb
udevadm settle
test -b /dev/vdb1
test "$(lsblk -bnro START /dev/vdb1)" = 2048
test "$(blockdev --getsz /dev/vdb1)" = 402651103
sgdisk --verify /dev/vdb
test -z "$(blkid /dev/vdb1 || true)"
test -z "$(wipefs -n /dev/vdb1)"

mkfs.xfs -L stalwartdata /dev/vdb1
data_uuid=$(blkid -s UUID -o value /dev/vdb1)
test -n "$data_uuid"
test "$(blkid -s TYPE -o value /dev/vdb1)" = xfs
test "$(blkid -s LABEL -o value /dev/vdb1)" = stalwartdata

test ! -e /root/fstab.mail-core-data-before
cp -a /etc/fstab /root/fstab.mail-core-data-before
install -d -o root -g root -m 0755 /srv/stalwart
printf 'UUID=%s /srv/stalwart xfs defaults,nodev,nosuid 0 2\n' "$data_uuid" >> /etc/fstab
findmnt --verify --verbose
mount /srv/stalwart
```

The newly observed UUID is runtime state and must not be copied into Git. If
any command after `sgdisk` fails, stop and preserve state and evidence. Do not
repartition, reformat, or attempt a destructive repair.

## Verification and rollback boundary

Verify locally and after one controlled guest reboot:

```sh
set -eu
findmnt -rn -S /dev/vdb1 -T /srv/stalwart -o SOURCE,TARGET,FSTYPE,OPTIONS
test "$(findmnt -bnro FSTYPE /srv/stalwart)" = xfs
test "$(findmnt -bnro SOURCE /srv/stalwart)" = /dev/vdb1
test "$(blkid -s LABEL -o value /dev/vdb1)" = stalwartdata
test "$(blkid -s UUID -o value /dev/vdb1)" = "$(findmnt -bnro UUID /srv/stalwart)"
test "$(stat -c '%U:%G %a' /srv/stalwart)" = 'root:root 755'
test ! -e /srv/stalwart/data
! swapon --noheadings --show=NAME | grep -Fx /dev/vdb1
! pvs --noheadings -o pv_name 2>/dev/null | grep -Fx /dev/vdb1
if test -r /proc/mdstat; then
  test -z "$(awk 'NR > 1 && $1 != "unused" {print}' /proc/mdstat)"
else
  test -z "$(lsblk -nrpo TYPE /dev/vdb1 | grep -Fx raid || true)"
fi
test "$(systemctl is-active ssh)" = active
test "$(systemctl is-active qemu-guest-agent)" = active
sshd -T | grep -Fxi 'permitrootlogin no'
sshd -T | grep -Fxi 'passwordauthentication yes'
test -z "$(ss -lntH | awk '{print $4}' | grep -Ev '(^|:)22$' || true)"
```

Host verification must prove the domain remains 2 vCPU/4096 MiB, uses one
`br-lab10` NIC, has autostart disabled, and that host storage, `br-lab10`, and
the `eno1` management/default-route path remain healthy.

Before `sgdisk`, rollback is no mutation or ordinary package rollback under a
separate reviewed packet. After the partition/filesystem write, destructive
rollback is not authorized. `/root/fstab.mail-core-data-before` permits an
exact fstab restoration, but unmount/restoration is allowed only by a reviewed
correction packet.

## Required result

Record every command and exit status, package versions, reboot outcome, GPT
geometry, XFS label and sanitized UUID correlation, mount state, listener
state, and host invariants. Commit only sanitized factual evidence. End with
exactly one disposition:

```text
GUEST BASELINE AND MAIL DATA ACCEPTED
CORRECTION REQUIRED
BLOCKED — OPERATOR INPUT REQUIRED
```
