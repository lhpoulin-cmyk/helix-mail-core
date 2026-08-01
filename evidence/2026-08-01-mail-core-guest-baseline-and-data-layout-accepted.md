# Mail-core guest baseline and data layout result

Disposition: **ACCEPTED**
Final authorization baseline: `2504e83` plus the operator-approved
`XFS_LABEL=stalwartdata` correction committed before execution

## Completed state

- Debian security kernel `6.12.100+deb13-amd64` is installed and active.
- Reviewed `gdisk` and `xfsprogs` packages and their Debian dependencies are
  installed; no package removal occurred.
- `/dev/vda` remains the distinct 32 GiB installed system disk.
- `/dev/vdb` retains the approved GPT with only `/dev/vdb1`, sectors 2048
  through 402653150, partition name `stalwart-data`.
- Only `/dev/vdb1` was formatted, as XFS with filesystem label
  `stalwartdata`.
- `/srv/stalwart` is a distinct mounted XFS filesystem sourced from
  `/dev/vdb1`, with approximately 192 GiB total capacity and 189 GiB free at
  verification time.
- `/etc/fstab` contains one UUID-backed entry for `/srv/stalwart` with
  `defaults,nodev,nosuid`; it does not use the device path. The runtime UUID
  was correlated locally and is intentionally omitted from Git.
- The mount root is `root:root` mode `0755`; `/srv/stalwart/data` does not yet
  exist.
- The mount returned correctly after a controlled guest reboot. The reboot
  also activated the reviewed Debian security kernel.

## Safety and health verification

- `/dev/vdb1` is not swap, LVM, RAID, or md-owned.
- No fallback `/srv/stalwart` directory on the root filesystem is in use.
- SSH password access for construction user `louis`, sudo to UID 0, QEMU guest
  agent, and serial/system services remain healthy. Root SSH login remains
  disabled; no SSH key or account-model change occurred.
- The guest retained `192.168.100.199/24`, gateway `192.168.100.1`, and could
  reach the gateway, both configured resolvers, and resolve Debian repository
  names.
- Only SSH listens on TCP; no mail listener or Stalwart service exists.
- The domain remains 2 vCPU, 4096 MiB, one virtio NIC on `br-lab10`, and
  autostart disabled.
- The host dedicated libvirt mount retained well over 32 GiB free; `br-lab10`
  and the `eno1` management/default route remained healthy.

## Prior failed attempts

The earlier `mkfs.xfs -L stalwart-data` attempt failed before writing because
the 13-character label exceeded XFS's 12-character limit. Subsequent inspection
proved the partition remained signature-free. The operator approved
`stalwartdata`; no other storage decision changed.

No Stalwart, DNS, TLS, Fastmail, public SMTP, router, firewall,
NetworkManager, credential, or promotion mutation occurred under this packet.
