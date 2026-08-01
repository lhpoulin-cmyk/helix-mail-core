# Mail-core unattended Debian 13 installation

Status: operator-authorized bounded execution

## Scope and identity

Target host: `ws-matriarch`; libvirt: `qemu:///system`; domain:
`mail-core-9000`; guest hostname: `mail.home.arpa`.

The baseline domain XML SHA-256 before reinstall is
`6cb1ee9135da4d8ef0f3c5beaa7d241a0850c889e42ea15bbf35dc26561a99a4`.
At capture it was a persistent, running 2-vCPU/4096-MiB KVM domain with
autostart disabled, two qcow2 disks, `br-lab10`, and a standard virtio guest
agent channel already present. The pre-install virtual capacities are 32 GiB
for `vda` and 192 GiB for `vdb`; both actual allocations were 204800 bytes.

Installed `virt-install` is version `5.1.0`. Its local help confirms
`--reinstall DOMAIN`, `--location`, `--initrd-inject`, and `--extra-args`.
`--reinstall` applies only installation configuration and reuses the existing
domain definition; no redefine, storage recreation, network change, or device
addition is permitted. The guest-agent channel is already present, so this
packet must not alter domain XML.

## Private installer state

Create only the Git-ignored, mode-0700 directory:

```text
handoff/private/mail-core-9000-installer/
```

Its private files must be mode 0600. It contains the rendered `preseed.cfg`,
its SHA-256 sidecar, an independently random temporary password and SHA-512
hash, a zero-length `selected-public-key.pub` marker because no unambiguous
Louis lab-operator public key was found, and `installer.log`. No value from
those files belongs in Git, command output, process listings, or worker
results. The password-fallback policy leaves SSH password authentication
available temporarily; the protected retrieval path is the directory above.

The sanitized source template is
`provisioning/guest/debian13-preseed.cfg.template`. Its rendered private copy
replaces only `__TEMPORARY_PASSWORD_HASH__` with the private SHA-512 hash.

## Guest configuration and disk guard

The preseed configures locale `en_US.UTF-8`, keyboard `us`, timezone
`America/Detroit`, UTC hardware clock, static `192.168.100.199/24`, gateway
`192.168.100.1`, resolvers `192.168.10.251 192.168.10.252`, hostname `mail`,
and domain `home.arpa`. It creates `louis`, locks root login, installs only the
standard task plus `openssh-server`, `sudo`, `qemu-guest-agent`,
`ca-certificates`, and `curl`, and enables SSH, the agent, and
`serial-getty@ttyS0`.

Automated partitioning is explicitly restricted to `/dev/vda`, uses the
non-LVM `atomic` recipe, and installs GRUB only to `/dev/vda`. `vdb` is never
named as a partition, filesystem, mount, swap, RAID, LVM, or boot target. Stop
if a fresh preflight finds a changed signature, partition table, or unexpected
allocation on the data qcow2.

## Immediate preflight

Immediately before stopping/restarting the stalled installer, require all of:

1. `ws-matriarch`, a clean worktree, and the expected domain XML fingerprint;
   autostart remains disabled.
2. Exact existing system/data qcow2 paths and virtual sizes, active mounted
   `mailcore-vm` storage, and over 32 GiB free.
3. Active `br-lab10` with `enp7s0` as its sole port.
4. Fresh collision checks for `.199`: RouterOS interface, DHCP pool,
   reservation/lease, ARP; local neighbor; both resolver A/PTR queries; and
   current committed Infrastructure allocations.
5. The exact official ISO path and full SHA-512 pinned by
   `implementation/2026-08-01-matriarch-mail-core-vm9000-construction.packet.md`.
6. `vdb` remains a blank existing qcow2 with no guest installation activity.

Any failure, changed XML/device set, address conflict, ISO mismatch, or `vdb`
change stops this packet. Do not substitute any value or repair forward.

## Exact reinstall command

After the preflight, stop only the stalled installer domain, retaining its
definition and both disks. Then run exactly:

```bash
sudo -n virt-install \
  --connect qemu:///system \
  --reinstall mail-core-9000 \
  --location /var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso \
  --initrd-inject /home/louis/helix-arpa/helix-mail-core/handoff/private/mail-core-9000-installer/preseed.cfg \
  --extra-args "auto=true priority=critical console=ttyS0,115200n8 preseed/file=/preseed.cfg" \
  --noautoconsole
```

This uses the netinst kernel/initrd from the verified ISO, injects only the
private preseed, and applies the required serial automation arguments. It does
not include credentials on the command line. Do not pass disk, network,
graphics, CPU, memory, firmware, autostart, or XML options to `--reinstall`.

## Monitoring, verification, and stop conditions

Collect serial console output without random input; check domain state, QEMU
log, system-disk activity, and guest-agent readiness through bounded waits.
Stop for any unattended-installer question, failure/loop, disappeared or
changed domain, `vdb` change, storage/network failure, or credential request
outside this packet. Do not proceed into Stalwart, DNS, TLS, Fastmail, or
mail-data layout.

After reboot from `vda`, remove/eject temporary installer media only after the
installed guest is verified. Verify via guest agent, serial console, ICMP, and
SSH: hostname/FQDN, all frozen IPv4/gateway/resolver/MTU values, gateway and
resolver reachability, Debian repository and approved external reachability,
SSH/agent enabled, `louis` sudo access, root SSH disabled, `vda` installation,
untouched `vdb`, 2 vCPU/4096 MiB/one `br-lab10` NIC/autostart disabled, and
healthy host storage, eno1 management, resolver, and bridge state.

## Rollback

Before restart, retain the original XML fingerprint and both unchanged qcow2
metadata. If the reinstall fails before guest disk mutation, stop the domain
and preserve evidence; do not redefine or recreate it. Once the installer has
partitioned `vda`, rollback is not authorized by this packet. `vdb` change is
a hard safety stop.
