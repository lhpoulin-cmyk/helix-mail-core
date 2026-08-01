# Mail-core guest baseline and data-layout preflight result

Disposition: **BLOCKED — OPERATOR INPUT REQUIRED**
Authorization base: `803f5da`
Target: `mail-core-9000` on `ws-matriarch`, `qemu:///system`

## Mutation result

No guest or host mutation occurred. Debian packages were not refreshed or
installed. Neither guest disk was partitioned, formatted, resized, or mounted.
`/etc/fstab`, networking, credentials, SSH policy, libvirt configuration, and
service state were not changed. The Stalwart packet was not started.

## Passed preflight evidence

- Repository HEAD was `803f5da` and the worktree was clean.
- Host identity was `ws-matriarch`, running Fedora 44.
- `mail-core-9000` was running only in `qemu:///system`, with 2 vCPU,
  4096 MiB, autostart disabled, and the previously recorded domain topology.
- `/dev/vda` remained the distinct 32 GiB installed system disk.
- `/dev/vdb` remained the distinct 206158430208-byte (192 GiB) disk with no
  child partition, filesystem signature, mount, swap, or label conflict.
- The domain retained one virtio NIC on `br-lab10`; the host retained its
  `eno1` default route and healthy dedicated libvirt storage mount with well
  over 32 GiB free.
- Inside the guest, SSH and QEMU guest agent were active. Root SSH login was
  disabled and password authentication remained enabled. The `louis` account
  was unlocked and its password/account lifetime was not expired.

## Blocking evidence

1. The protected, ignored temporary-password file did not authenticate the
   `louis` SSH login. The value was consumed only through the existing
   mode-restricted askpass helper and was not printed or recorded. The packet
   requires networking, SSH, and sudo to remain usable and the operator has
   explicitly prohibited credential rotation or changing the account model.
   Continuing solely through QEMU guest-agent root execution would not prove
   the retained operator access path and would leave no validated sudo login.
   A subsequent secret-safe comparison of SHA-256 fingerprints (not the hash
   values themselves) proved that the protected installer password-hash file
   does not match the current `louis` shadow hash in the guest. No hash or
   password was printed, copied into Git, or changed.
2. The reviewed preflight command reads `/proc/mdstat`, but that pseudo-file is
   absent on this minimal guest. The command therefore exited nonzero after the
   disk-size, topology, signature, mount, and swap checks passed. A separately
   run read-only continuation recorded this observation and completed the
   remaining checks; it did not reinterpret the unavailable command as proof.

## Required correction

Before live execution, the operator must restore or identify the intended
temporary construction password through a secret-safe path, or separately
authorize another access method. The password must not be posted in chat or
committed. The packet also needs a repository-only correction that records
`/proc/mdstat` as unavailable when absent and uses other observed read-only RAID
ownership evidence rather than failing on the missing pseudo-file.

The existing temporary credential was not changed, removed, or disclosed.
