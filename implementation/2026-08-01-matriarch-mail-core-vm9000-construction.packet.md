# Matriarch mail-core VM 9000 construction proposal

Status: rendered only — explicit VM-construction authorization required
Target: `ws-matriarch`, Fedora 44, `qemu:///system`
Domain: `mail-core-9000`
Guest service hostname: `mail.home.arpa`

## Frozen input values

```text
VM_STORAGE=mail-core-construction
SYSTEM_DISK_REFERENCE=mail-core-9000-system.qcow2
MAIL_DATA_STORAGE=mail-core-construction
MAIL_DATA_DISK_REFERENCE=mail-core-9000-data.qcow2
MOUNTPOINT=/var/lib/libvirt/mail-core
XFS_LABEL=mailcore-vm

NETWORK_ATTACHMENT=br-lab10
GUEST_IPV4=192.168.100.199
GUEST_PREFIX=24
GUEST_GATEWAY=192.168.100.1
GUEST_DNS_SERVERS=192.168.10.251,192.168.10.252
GUEST_MTU=1500
GUEST_NETWORK_MODEL=single-nic

GUEST_INSTALL_IMAGE=debian-13.6.0-amd64-netinst.iso
GUEST_INSTALL_IMAGE_SHA512=ce0eeee7b51fdcdbed1e5116668c1fee27e528767bdf488e5f115a67b225e5dfd0afca1d456aaa9408ceb6b8527521ff7b6b5d62fdbe6f8c5faaf8df56a96292
GUEST_INSTALL_IMAGE_REFERENCE=/var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso
```

The domain uses 2 vCPU, 4096 MiB RAM, the existing sparse 32 GiB system disk,
and the existing sparse 192 GiB mail-data disk. It attaches only `br-lab10`.
It does not create a libvirt network, a storage pool, new disks, or a second
NIC.

## Required final preflight

Immediately before a future define/start action, collect fresh read-only
evidence and stop on any failure:

1. `hostnamectl` confirms `ws-matriarch` and Fedora 44.
2. `virsh --readonly --connect qemu:///system dominfo mail-core-9000` confirms
   the domain is absent; do not reuse an existing definition.
3. `virsh --readonly --connect qemu:///system pool-info mail-core-construction`
   confirms the directory pool is active with its guarded mounted target.
4. `findmnt --target /var/lib/libvirt/mail-core`, `df -B1`, and `qemu-img
   info --output=json` confirm the expected mounted XFS filesystem, both exact
   qcow2 files, and at least 32 GiB free capacity after any planned action.
5. Read-only bridge evidence confirms `br-lab10` exists, is up, uses `enp7s0`
   as its only port, and has host MTU 9000. Do not modify it.
6. Run the final address-collision preflight for **exactly** `192.168.100.199`:
   - Netbrain interface addresses, DHCP pools/exclusions, leases, and ARP;
   - both resolver forward and reverse queries;
   - current `br-lab10` neighbor evidence.

Any conflict, missing result, unavailable read-only access, active DHCP scope
without an exclusion, or insufficient free capacity stops activation. A failed
preflight must not select another address.

7. Require the immutable installer input before any definition:

   ```bash
   install_image=/var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso
   expected_sha512=ce0eeee7b51fdcdbed1e5116668c1fee27e528767bdf488e5f115a67b225e5dfd0afca1d456aaa9408ceb6b8527521ff7b6b5d62fdbe6f8c5faaf8df56a96292
   test -f "$install_image"
   test "$(sha512sum "$install_image" | awk '{print $1}')" = "$expected_sha512"
   ```

   The path or hash mismatch is a hard stop; do not download, substitute, or
   update the image during VM construction.

## Rendered guest definition

The following fixed domain attributes may be used only after the preflight and
explicit authorization:

```text
name:           mail-core-9000
memory:         4096 MiB
vcpus:          2
system disk:    /var/lib/libvirt/mail-core/mail-core-9000-system.qcow2 (qcow2, virtio)
mail-data disk: /var/lib/libvirt/mail-core/mail-core-9000-data.qcow2 (qcow2, virtio)
network:        bridge br-lab10, one virtio NIC
guest network:  192.168.100.199/24 via 192.168.100.1; DNS .251,.252; MTU 1500
installer ISO:  /var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso (SHA-512 pinned above)
```

Fedora's installed libosinfo database identifies `debian13` as Debian 13. The
following is the complete future construction command. It is rendered only;
running it defines and starts the domain and therefore requires a separate
explicit VM-construction authorization after every preflight above passes.

```bash
set -euo pipefail
install_image=/var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso
expected_sha512=ce0eeee7b51fdcdbed1e5116668c1fee27e528767bdf488e5f115a67b225e5dfd0afca1d456aaa9408ceb6b8527521ff7b6b5d62fdbe6f8c5faaf8df56a96292
system_disk=/var/lib/libvirt/mail-core/mail-core-9000-system.qcow2
data_disk=/var/lib/libvirt/mail-core/mail-core-9000-data.qcow2

test "$(hostnamectl --static)" = ws-matriarch
test -f "$install_image"
test "$(sha512sum "$install_image" | awk '{print $1}')" = "$expected_sha512"
test -f "$system_disk"
test -f "$data_disk"
if virsh --readonly --connect qemu:///system dominfo mail-core-9000 >/dev/null 2>&1; then
  echo 'mail-core-9000 already exists; refusing to reuse a domain definition' >&2
  exit 1
fi
findmnt --target /var/lib/libvirt/mail-core >/dev/null
virsh --readonly --connect qemu:///system pool-info mail-core-construction >/dev/null
ip link show br-lab10 | grep -F 'mtu 9000'

# Run and pass the separate final 192.168.100.199 collision-preflight packet
# before this command. It is deliberately not replaced by ARP absence alone.

sudo -n virt-install \
  --connect qemu:///system \
  --name mail-core-9000 \
  --memory 4096 \
  --vcpus 2 \
  --cpu host-model \
  --os-variant debian13 \
  --disk path="$system_disk",format=qcow2,bus=virtio \
  --disk path="$data_disk",format=qcow2,bus=virtio \
  --network bridge=br-lab10,model=virtio \
  --cdrom "$install_image" \
  --graphics none \
  --console pty,target.type=serial \
  --noautoconsole
```

The command makes no libvirt NAT network, storage pool, disk, bridge, or
additional NIC. It uses the host's normal libvirt firmware default rather than
inventing an OVMF path. Guest static addressing and MTU are installed inside
Debian after boot; they are not host-side `virt-install` options.

## TLS and acceptance boundaries

Use the recorded private-lab-CA, 180-day construction/soak policy from
`implementation/2026-08-01-mail-core-construction-tls-decision.packet.md`.
Do not issue a certificate or key in VM construction. DNS publication and the
later private-CA issuance path are prerequisites for local mail-service
acceptance, not for initial VM construction.

Fastmail remains disabled. `APPLIANCE_EXPORT_REFERENCE` remains unresolved and
blocks promotion readiness only.

## Prohibitions

Do not define, start, install, or attach VM 9000 under this proposal. Do not
change NetworkManager, `br-lab10`, `enp7s0`, `eno1`, `eno1.80`, firewall, DNS,
TLS, RouterOS, storage, libvirt networks, credentials, or Fastmail. Do not
publish a PTR record unless a reviewed reverse-zone mutation path exists.
