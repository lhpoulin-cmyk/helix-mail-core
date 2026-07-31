# Matriarch local read-only inventory follow-up packet

Date: 2026-07-31
Status: approved read-only follow-up
Target: the current local Fedora 44 Matriarch construction host
Construction ID: `9000`; libvirt domain name: `mail-core-9000`

HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1

## Authority

The current local shell is the approved access path to Matriarch. Do not SSH or
contact another host. Run unprivileged commands only. No sudo, polkit approval,
password entry, privilege escalation, or live mutation is authorized.

## Scope

Collect local Fedora/KVM/libvirt facts needed for the fail-closed construction
proposal. A denied observation is evidence of an unresolved value; record the
exact command and denial. Do not stop merely because this is not a remote host.

Do not create, define, start, stop, suspend, destroy, migrate, attach storage
to, or modify any libvirt domain, pool, network, or host configuration. Do not
change DNS, NetworkManager, firewall, certificates, packages, services,
credentials, Fastmail, or the opaque destination behind
`APPLIANCE_EXPORT_REFERENCE`.

## Required local collection

Run and classify these exact read-only system-libvirt commands:

```text
hostnamectl
test -e /dev/kvm
virsh --readonly --connect qemu:///system list --all
virsh --readonly --connect qemu:///system net-list --all
virsh --readonly --connect qemu:///system pool-list --all
virsh --readonly --connect qemu:///system dominfo mail-core-9000
```

Inspect the user-session libvirt plane separately and label it `qemu:///session`.
It is not evidence of the system construction plane:

```text
virsh --readonly --connect qemu:///session list --all
virsh --readonly --connect qemu:///session net-list --all
virsh --readonly --connect qemu:///session pool-list --all
```

Also collect unprivileged local network context only:

```text
ip -brief link
ip -brief address
ip route
getent hosts mail.home.arpa
```

For an already operator-approved pool only, run targeted read-only
`virsh --readonly --connect qemu:///system pool-info <pool>`. Do not select a
pool, inspect unrelated storage, or require a Matriarch backup target.

## Required record and stop conditions

Update `docs/matriarch-target-inventory.md`. For each material observation,
record value, source/exact command, UTC timestamp, confidence, and confidence
rationale. Preserve unresolved values; never invent storage, bridge, VLAN,
address, gateway, resolver, DNS ownership, TLS practice, or
`APPLIANCE_EXPORT_REFERENCE`.

Record `mail-core-9000` name availability only from the system libvirt plane.
If a command is denied, unavailable, or returns an error, record the exact
command and sanitized denial/result as unresolved. Run repository validation
and the expected fail-closed render check against
`inventory/production/values.env.example`.

Stop before live mutation. A successful inventory and render refusal do not
authorize VM construction.
