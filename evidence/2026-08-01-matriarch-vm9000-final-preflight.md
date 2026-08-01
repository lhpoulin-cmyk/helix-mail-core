# VM 9000 final construction preflight evidence reference

Status: all required read-only gates passed; no VM action authorized by this
record.

Collected through `2026-08-01T00:57:52Z` on `ws-matriarch`, from repository
commit `63bcb4f` after the renderer correction.

| Gate | Result |
| --- | --- |
| Host identity | PASS — `ws-matriarch`, Fedora 44 |
| Libvirt architecture | PASS — `virtqemud.socket` and `virtproxyd.socket` active; monolithic `libvirtd.service` inactive; system and session read-only connections succeeded |
| Construction identity | PASS — `mail-core-9000` absent from both `qemu:///system` and `qemu:///session`; construction ID 9000 remains available |
| Storage pool and mount | PASS — `mail-core-construction` running; target mounted as XFS label `mailcore-vm`; active mount UUID equals the UUID persisted for the mountpoint |
| Disks and SELinux | PASS — distinct qcow2 system and data volumes report 32 GiB and 192 GiB virtual capacity; mount and both volumes match their expected SELinux contexts |
| Soak reserve | PASS — `269447766016` bytes free, exceeding 32 GiB |
| Network | PASS — `br-lab10` is MTU 9000 with only `enp7s0` as port; `192.168.100.0/24` remains on the bridge; default route remains on `eno1` |
| Address collision | PASS — fresh RouterOS print-only checks found no interface, DHCP pool, lease, or ARP conflict for `.199`; both configured resolvers returned no conflicting A or PTR; local neighbor state empty; committed Infrastructure search found no conflicting allocation outside the approved mail-core selection and unapplied DNS proposal |
| Installer | PASS — `/var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso` exists mode `0444`, retains a valid SELinux label, and its SHA-512 equals the full value pinned in the construction packet; the signed-manifest acquisition record is present |
| Repository | PASS — clean before this factual record was added |

The RouterOS collector and narrow collision queries used only `print` commands.
Their raw evidence remains in the private operator evidence location and is not
committed. No RouterOS, DHCP, DNS, NetworkManager, firewall, storage, TLS,
Fastmail, libvirt-network, or VM mutation occurred.

## Exact executable command

The exact future command is the fenced `virt-install` command in
`implementation/2026-08-01-matriarch-mail-core-vm9000-construction.packet.md`
at commit `63bcb4f`. It pins the installer path and SHA-512, attaches the two
existing qcow2 volumes distinctly, uses only `br-lab10` with `mtu.size=1500`,
and intentionally omits autostart. It must be preceded by this same final
collision gate and requires a separate explicit operator authorization because
executing it defines and starts `mail-core-9000`.
