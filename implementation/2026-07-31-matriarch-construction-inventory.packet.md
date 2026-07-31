# Matriarch mail-core construction inventory packet

Date: 2026-07-31
Status: proposed; read-only execution authorized
Target: Fedora 44 Matriarch; construction ID `9000`; libvirt domain
`mail-core-9000`
Service identity: `mail.home.arpa`

## Objective

Collect only the current facts needed to produce a fail-closed construction
proposal for the temporary appliance on Fedora 44 Matriarch. Construction ID
`9000` is a project lifecycle identifier; it is not a Proxmox VMID and must not
be compared with a transient libvirt numeric runtime ID.

The strongest completion state is a validated, non-deployable proposal that
either identifies each required value from fresh evidence or visibly leaves it
unresolved for operator review. It does not authorize VM construction.

## Authority and strict scope

This packet authorizes read-only inspection of the operator-confirmed Matriarch
host through Fedora/KVM/libvirt interfaces only. Private raw command output
stays outside Git. Commit only sanitized facts, redacted excerpts, and private
evidence references.

Allowed actions are read-only host and libvirt queries plus repository
documentation, validation, and a fail-closed render check. Do not invoke a
libvirt command that defines, creates, starts, stops, suspends, destroys,
undefines, migrates, attaches storage to, or otherwise changes a domain.

## Explicitly out of scope

- Creating, modifying, starting, stopping, or deleting `mail-core-9000` or any
  other VM/domain.
- Changing host storage, libvirt networks, bridges, VLANs, firewall, DNS,
  certificates, routes, or packages.
- Selecting, configuring, testing, or requiring a Matriarch backup target.
- Selecting a production hypervisor, assigning a production VMID, migration,
  promotion, or production placement.
- Provisioning, inspecting, mounting, validating, or reinterpreting the
  destination behind `APPLIANCE_EXPORT_REFERENCE`.
- Reading secrets or private keys; creating credentials; enabling Fastmail; or
  sending external mail.

## Preconditions

1. The operator confirms the reachable management identity for Fedora 44
   Matriarch and permits this read-only inspection.
2. The collector records command timestamps in UTC and keeps raw output in
   private evidence.
3. Historical `hv-matrix`/former `hv-matriarch` documentation is treated only
   as historical context, never as evidence of current Matriarch state.

## Read-only collection

Run only on the confirmed construction host. Record only sanitized summaries
in Git.

```text
hostnamectl
test -e /dev/kvm
virsh -c qemu:///system uri
virsh -c qemu:///system list --all --name
virsh -c qemu:///system dominfo mail-core-9000
virsh -c qemu:///system pool-list --all
virsh -c qemu:///system net-list --all
ip -brief link
ip -brief address
ip route
getent hosts mail.home.arpa
```

`dominfo mail-core-9000` may fail when the name is available; record that exit
status and the sanitized result. Do not use a numeric libvirt ID to assess the
construction ID conflict.

For a storage pool and network attachment specifically identified or approved
by the operator, collect only targeted read-only capacity and configuration
facts (for example `virsh pool-info <approved-pool>`). Do not enumerate,
mount, inspect, or alter unrelated host devices or pools. Record the existing
attachment, not an invented bridge, VLAN, address, gateway, resolver, or CA.

Determine `home.arpa` DNS ownership/path and internal TLS issuance, trust,
renewal, and replacement practice from direct read-only evidence or the
operator's established authority. If either cannot be established, record it
as unresolved. Record only whether `APPLIANCE_EXPORT_REFERENCE` is supplied or
unresolved; do not access what it denotes.

## Evidence and required results

For every material observation in `docs/matriarch-target-inventory.md`, record:

| Field | Requirement |
| --- | --- |
| Value | Sanitized observed value, or `UNRESOLVED` |
| Source | Exact read-only command, operator authority, or private evidence reference |
| Timestamp | UTC collection time |
| Confidence | high, medium, or low |
| Confidence rationale | Why the source supports the value and its limits |

The result must explicitly state:

- confirmed Matriarch host identity and KVM/libvirt availability;
- whether `mail-core-9000` already exists, or that its name is available;
- construction storage and isolated mail-data placement, each either supported
  by targeted evidence or `UNRESOLVED`;
- existing network attachment and proposed guest IP configuration, DNS owner,
  and TLS practice, each either supported or `UNRESOLVED`; and
- opaque `APPLIANCE_EXPORT_REFERENCE` status, without destination details.

## Validation, render, and stop conditions

Update only `docs/matriarch-target-inventory.md` with sanitized evidence and
unresolved values. Do not write `inventory/production/values.env` unless a
later operator-reviewed packet authorizes it.

Run:

```text
scripts/validate/all.sh
scripts/render/render.sh inventory/production/values.env.example
```

The second command is expected to reject unresolved production values. Capture
that expected failure as the fail-closed render result; it is not a deployable
construction definition. Stop without live mutation if host identity is
ambiguous, KVM/libvirt is unavailable, `mail-core-9000` exists, targeted
capacity is insufficient, or any required storage, network, IP, DNS, TLS, or
opaque export-reference status remains unresolved.

## Completion record

Record the packet path, collector, private evidence reference, evidence table,
validation output, render refusal output, unresolved values, and the statement
`Live mutation: none`. A successful static validation or render refusal never
authorizes VM construction.
