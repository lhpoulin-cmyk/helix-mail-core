# Mail-core guest baseline and mail-data layout proposal

Status: rendered only — explicit operator authorization required

## Accepted starting state

`mail-core-9000` runs Debian 13 as `mail.home.arpa` with the frozen single-NIC
network configuration. The system is installed only on `/dev/vda`. Offline
qcow2 comparison and in-guest inspection classify the separate 192 GiB
`/dev/vdb` as **VERIFIED GUEST-VISIBLE EMPTY**.

This packet does not authorize execution. It must not install Stalwart,
initialize mail identities, publish DNS, issue TLS material, configure
Fastmail, expose SMTP, enable domain autostart, or dereference
`APPLIANCE_EXPORT_REFERENCE`.

## Proposed guest baseline

Before data-disk mutation, capture package versions, active services, network,
mounts, block identities, SSH policy, guest-agent state, and the current
`/dev/vdb` zero/unowned proof. Proposed baseline operations are limited to:

1. apply Debian stable security and point updates;
2. retain only the existing minimal server package set;
3. preserve static network values and `serial-getty@ttyS0`;
4. retain root SSH disabled;
5. replace the temporary password with an approved operator key, then disable
   SSH password authentication, only after the key path is separately proved;
6. leave VM autostart disabled during construction and soak.

The approved operator SSH public-key identity remains unresolved. Do not remove
the temporary access method until a replacement login and sudo path succeeds.

## Proposed mail-data layout

Repository architecture fixes the application data mount at `/srv/stalwart`
and Stalwart data at `/srv/stalwart/data`. The smallest practical proposal is:

```text
device:       /dev/vdb
partition:    /dev/vdb1, one GPT partition spanning the disk
filesystem:   XFS
label:        stalwart-data
mountpoint:   /srv/stalwart
persistence:  filesystem UUID in /etc/fstab
mount flags:  defaults,nodev,nosuid
```

The future mutation must re-prove that `/dev/vdb` is the exact empty 192 GiB
disk, render the GPT boundaries, create only `/dev/vdb1`, format only that
partition, mount it by newly observed UUID, and verify capacity and reboot-safe
mounting. It must stop on any existing signature, partition, owner, mount,
swap, LVM, RAID, or unexpected nonzero data.

Stalwart is not installed, so its final service account and numeric UID/GID are
unresolved. Initially keep `/srv/stalwart` root-owned and do not create or chown
`/srv/stalwart/data`. A later Stalwart installation packet must identify the
real service account before assigning only the application data directory.

## Rollback and verification

Before mutation, capture the empty-disk proof and guest configuration. After a
partition table or filesystem is created, destructive rollback is not
authorized: stop and preserve evidence rather than recreating the disk.

Future verification must prove the system still boots solely from `/dev/vda`,
the new UUID-backed XFS mount is exactly `/srv/stalwart`, `/dev/vdb1` is not
used for swap/LVM/RAID, guest and host networking remain unchanged, guest agent
and SSH remain available, and no mail service or public listener exists.
