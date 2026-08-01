# Unattended Debian installation execution record

Disposition: **BLOCKED — OPERATOR INPUT REQUIRED**

## Completed bounded actions

- Committed the unattended-install packet and sanitized preseed template at
  `cc4b1d1`; static validation passed.
- Created ignored private installer state at
  `handoff/private/mail-core-9000-installer/` with mode 0700 and private files
  mode 0600. No public key was unambiguously associated with the approved
  Louis lab-operator identity, so the authorized random temporary-password
  fallback was used. The protected retrieval path is that private directory.
- The exact `virt-install --reinstall` command passed `--dry-run` and then ran
  after the immediate host/storage/bridge/ISO/collision preflight passed at
  `2026-08-01T01:20:20Z`.
- Serial evidence showed unattended progress through network setup, partition
  initialization, base-system and package installation (including
  `qemu-guest-agent`), GRUB installation to `/dev/vda`, finishing steps, and
  the installer reboot request. No installer prompt or keystroke occurred.

## Hard safety stop

The pre-install data qcow2 measurement was:

```text
virtual size: 206158430208 bytes
actual allocation: 204800 bytes
```

After the installer rebooted and the domain shut off through its pre-existing
`on_reboot=destroy` lifecycle, the data qcow2 still reported the same virtual
size but an actual allocation of `200704` bytes. This changed observed
allocation prevents confirming that `/dev/vdb` remained completely untouched.
Under the approved disk-safety boundary, it is a hard stop even though no
partition, filesystem, mount, or guest-side `vdb` evidence was observed.

No ISO eject, post-install start, guest login, DNS/TLS/Fastmail action, or
mail-data-disk operation was performed after detecting this difference. The
domain is shut off; its ISO remains attached and its definition remains in
place. Do not start it or alter either disk unless the operator first reviews
and explicitly resolves this data-disk safety condition.
