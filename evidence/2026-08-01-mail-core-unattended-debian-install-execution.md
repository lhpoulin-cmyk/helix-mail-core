# Unattended Debian installation execution record

Disposition: **DEBIAN INSTALL ACCEPTED**

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

## Data-disk safety resolution

The pre-install data qcow2 measurement was:

```text
virtual size: 206158430208 bytes
actual allocation: 204800 bytes
```

After the installer rebooted and the domain shut off through its pre-existing
`on_reboot=destroy` lifecycle, the data qcow2 still reported the same virtual
size but an actual allocation of `200704` bytes. Execution initially stopped
on that difference.

The operator clarified that qcow2 container allocation is not the acceptance
invariant and authorized an offline guest-visible-content proof. With the
domain shut off, the image passed all of the following:

- `qemu-img check --output=json`: exit 0, zero check errors;
- `qemu-img map --output=json`: one full 206158430208-byte extent with
  `present=false`, `zero=true`, and `data=false`;
- non-strict `qemu-img compare` against a fresh empty 192 GiB qcow2: exit 0,
  `Images are identical`;
- no backing file, snapshot, persistent bitmap, dirty flag, or corrupt flag.

Classification: **VERIFIED GUEST-VISIBLE EMPTY**. The earlier 4096-byte host
allocation delta was a qcow2/container allocation difference, not evidence of
guest-visible modification. The temporary reference image and its protected
temporary directory were removed; the accepted data image was not recreated.

## Completed guest boot and verification

- Ejected the installer ISO from the shut-off domain and booted the installed
  Debian system from `/dev/vda`.
- Guest agent and actual password-authenticated SSH access succeeded. The
  protected temporary credential remains only under
  `handoff/private/mail-core-9000-installer/`.
- Identity is `mail` / `mail.home.arpa`; `louis` exists and authenticated sudo
  succeeded; root SSH login is disabled.
- The sole guest NIC is `192.168.100.199/24`, gateway `192.168.100.1`, DNS
  `192.168.10.251 192.168.10.252`, and MTU 1500.
- Gateway, both resolvers, Debian repositories, and Debian's external website
  were reachable.
- SSH, qemu guest agent, and `serial-getty@ttyS0` are active; required packages
  are installed.
- In the guest, `/dev/vda1` is the root filesystem and `/dev/vda5` is swap.
  `/dev/vdb` remains a 192 GiB disk with no partition table, filesystem,
  signature, mount, swap, LVM, RAID, or other ownership.
- Libvirt remains 2 vCPU, 4096 MiB, one virtio NIC on `br-lab10`, MTU 1500,
  empty CD device, and autostart disabled. Host eno1 routing, resolver state,
  bridge, and storage mount/reserve remain healthy.

No DNS publication, TLS issuance, Stalwart/Fastmail configuration, public SMTP,
RouterOS/NetworkManager/firewall change, or mail-data initialization occurred.
