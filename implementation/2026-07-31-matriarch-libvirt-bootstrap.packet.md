# Matriarch libvirt bootstrap packet

Target: `ws-matriarch`, Fedora 44
Purpose: enable the local construction platform for `mail-core-9000`

## Authority

This packet authorizes only the listed Fedora package installation and local
modular libvirt socket activation after a recorded, reviewed DNF transaction.
It does not authorize VM construction or any other infrastructure change.

## Package transaction

Before installation, record installed state and render, without accepting, the
DNF transaction for exactly:

```text
libvirt-daemon-kvm
libvirt-client
virt-install
```

Use only already configured Fedora repositories. Record added, upgraded,
removed, and replaced packages. Stop if the proposal removes unrelated
packages, changes repositories, or introduces an unexpected virtualization
stack. After that review, install only the three named packages and their
required dependencies. Do not install `virt-manager` or unrelated GUI tools.

## Local service scope

Inspect installed units. Where present and required for local QEMU/KVM
inspection, enable/start only modular socket units:

```text
virtqemud.socket
virtnetworkd.socket
virtstoraged.socket
virtlogd.socket
virtlockd.socket
```

Do not enable `libvirtd.service`, `libvirtd.socket`, `virtproxyd.socket`, or
remote TCP/TLS libvirt access. If installed-unit evidence says a legacy or
remote path is required, stop for operator review. Do not create or activate
the default NAT network.

## Prohibitions

Do not create, define, start, or modify `mail-core-9000`; networks; pools;
disks; NetworkManager, bridge, VLAN, route, firewall, DNS, certificate,
credential, group, polkit, sudo, Fastmail, production-placement, or opaque
export-reference state.

## Verification and completion

Record each live mutation and run:

```text
virsh --version
virt-install --version
systemctl is-enabled <authorized socket>
systemctl is-active <authorized socket>
virsh --readonly --connect qemu:///system version
virsh --readonly --connect qemu:///system list --all
virsh --readonly --connect qemu:///system dominfo mail-core-9000
virsh --readonly --connect qemu:///session list --all
```

Keep session and system findings distinct. If unprivileged system access is
denied, record the exact denial and do not alter access control. Run repository
validation. After successful bootstrap, dispatch the existing approved
profiled read-only inventory once, then stop for remaining genuine operator
choices. `APPLIANCE_EXPORT_REFERENCE` may remain unresolved; never create VM
9000.
