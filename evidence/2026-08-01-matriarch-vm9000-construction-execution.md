# VM 9000 construction execution record

Disposition: **INSTALLER READY — OPERATOR INPUT REQUIRED**

## Authorized execution

- Authorization baseline: `695f86b`.
- Immediate fail-closed pre-execution gate passed at
  `2026-08-01T01:01:22Z`.
- The exact rendered `virt-install` command from
  `implementation/2026-08-01-matriarch-mail-core-vm9000-construction.packet.md`
  was executed once. Libvirt started the construction domain at
  `2026-08-01T01:01:42Z`.

## Verified resulting state

| Check | Result |
| --- | --- |
| Libvirt plane | `mail-core-9000` exists and is running only in `qemu:///system`; it remains absent from `qemu:///session` |
| CPU and memory | 2 vCPU; 4096 MiB |
| Firmware / machine | libvirt default firmware with `pc-q35-10.2`; no invented loader or NVRAM path |
| Disks | `vda` is the existing 32 GiB system qcow2; `vdb` is the existing 192 GiB mail-data qcow2; no storage volume was created, resized, reformatted, or mounted on the host |
| Installer media | verified Debian 13.6 netinst ISO attached read-only as `sda` and first boot device |
| Network | one virtio NIC only, source `br-lab10`, guest-interface MTU 1500; no libvirt NAT network |
| Autostart | disabled |
| Host health | `br-lab10` remains MTU 9000 with `enp7s0` as its only port; eno1 default route remains unchanged; mail-core storage mount remains active |
| Boundaries | no RouterOS, NetworkManager, firewall, DNS, TLS, Fastmail, certificate, credential, export-reference, or unrelated host-storage mutation occurred |

## Installer handoff

`virt-install` reported a running domain and installation in progress. A local
TTY-backed `virsh console` connection attached successfully, but no installer
transcript was emitted and no keystrokes were sent. No guest account,
password, partitioning, or mail-data-disk choice has been made. In particular,
the 192 GiB `vdb` remains attached only; it must not be partitioned, formatted,
or mounted until a separate appliance-storage packet is approved.

The next action requires operator-directed installer interaction. Do not
continue into Stalwart, DNS, TLS, Fastmail, or appliance-data configuration
under this construction packet.
