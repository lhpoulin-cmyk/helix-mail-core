# Mail-core guest addressing and routing decision packet

**Date:** 2026-07-31  
**Status:** Read-only evidence and operator decision required  
**Target:** ws-matriarch / Fedora 44  
**Prerequisite:** network construction accepted at `55f0648`

## Frozen construction network

```
NETWORK_ATTACHMENT=br-lab10
BRIDGE_PARENT=enp7s0
BRIDGE_MTU=9000
```

Operator Decision 4 additionally freezes:

```
GUEST_NETWORK_MODEL=single-nic
ROUTER=netbrain
```

Do not reopen, alter, deactivate, or recreate `br-lab10`, `enp7s0`,
`eno1`, or `eno1.80`. No VM, libvirt network, NetworkManager, DHCP,
route, DNS, firewall, or other live configuration mutation is authorized.
Do not bridge the guest into Admin VLAN 80, attach a second guest NIC, use
libvirt NAT or macvtap, or infer a Lab-10 gateway from the host's separate
network paths.

## Purpose

Collect only current, sanitized evidence needed for one Decision 4 operator
choice: static guest addressing and routing for `mail-core-9000`. The guest
does not exist and must not be created or defined by this packet.

Every rendered value below must be directly evidence-supported; otherwise it
must remain `UNRESOLVED`. The absence of an ARP entry alone never establishes
that an address is free.

## Required read-only observations

Use a fixed trusted read-only collector profile, extending it only through a
separately reviewed repository correction if the existing profile cannot
collect a required observation. Record each command as observed, unavailable,
permission-denied, timed-out, or failed. Keep raw identifiers, hardware
addresses, lease data, and unrelated user data outside Git; commit only
sanitized facts and evidence references.

Collect:

1. Current IPv4 and IPv6 addresses, prefix, routes, route metrics, bridge
   membership, and neighbor state for `br-lab10` and `enp7s0`.
2. The connected Lab-10 subnet and only its evidence-supported usable-range
   constraints. Do not infer DHCP scope, reservation ranges, exclusions, or
   administrative ownership from a connected route.
3. Active NetworkManager profile properties for `br-lab10`, including IP
   method, addresses, gateway, route metric, DNS behavior, and search domains;
   sanitize UUIDs and hardware identifiers.
4. Current resolver configuration and resolver reachability from the Lab-10
   path, without treating the host's separate `eno1` default route as a
   guest gateway.
5. Read-only, authorized evidence for existing Lab-10 static assignments and
   DHCP reservations, if a local source is available. If no such authoritative
   source is available without privilege escalation or external access, record
   it unavailable rather than guessing.
6. Current DNS forward and reverse evidence relevant to an address candidate,
   using the configured resolvers. DNS absence is only one collision signal.
7. Current neighbor, route, and established-infrastructure evidence relevant
   to candidates. Do not scan the subnet or probe arbitrary addresses.
8. Whether an evidence-supported Lab-10 gateway exists, and whether it
   demonstrably provides paths to the configured internal DNS resolvers,
   Fedora and Debian package repositories, Fastmail SMTP/IMAP endpoints, and
   approved internal cluster systems. Do not use a gateway observed on
   `eno1` as a Lab-10 gateway.
9. Whether a single `br-lab10` NIC can meet those verified reachability
   requirements. If it cannot, recommend only the smallest evidence-supported
   correction: a routed Lab-10 gateway, a second direct internal-services
   attachment, or another explicitly justified design.

## Collision preflight

For one recommended static candidate, collect and compare all available
evidence:

- authoritative reservation/allocation evidence, if available;
- forward and reverse DNS;
- current bridge/interface address and route evidence;
- current neighbor evidence;
- the documented Lab-10 peer evidence; and
- known static-assignment evidence.

Classify the candidate as `collision detected`, `not safe to assign —
allocation authority unavailable`, `not safe to assign — conflicting
evidence`, or `candidate available pending operator approval`. The final
classification requires more than an absent ARP entry.

## Required decision report

Present exactly these values:

```
GUEST_IPV4=UNRESOLVED_GUEST_IPV4
GUEST_PREFIX=UNRESOLVED_GUEST_PREFIX
GUEST_GATEWAY=UNRESOLVED_GUEST_GATEWAY
GUEST_DNS_SERVERS=UNRESOLVED_GUEST_DNS_SERVERS
GUEST_NETWORK_MODEL=UNRESOLVED_GUEST_NETWORK_MODEL
```

For each, state observed evidence, recommendation, alternatives,
consequences, exact proposed inventory value, and whether the value is
directly supported or unresolved. Include the collision-preflight result and
the single-NIC sufficiency decision.

Ask the operator exactly one practical Decision 4 choice after presenting the
recommendation. Do not progress to DNS ownership, TLS, guest definition, or VM
9000 construction.

## Prohibited actions

Do not create, define, start, attach, or modify VM `mail-core-9000`; create
or alter a libvirt network; send DHCP requests; add, remove, or modify any
route; alter NetworkManager, firewall, DNS, TLS, storage, or credentials; or
change the frozen bridge interfaces.

## Operator Decision 4 — accepted guest network values

The operator supplies the missing static-allocation authority. Freeze:

```text
GUEST_IPV4=192.168.100.2
GUEST_PREFIX=24
GUEST_GATEWAY=192.168.100.1
GUEST_DNS_SERVERS=192.168.10.251,192.168.10.252
GUEST_MTU=1500
GUEST_NETWORK_MODEL=single-nic
NETWORK_ATTACHMENT=br-lab10
```

The gateway is the evidence-supported Netbrain Lab-10 address, not an inferred
host route. The 1500 guest MTU is a routed-path decision; it does not alter
the frozen 9000-MTU host bridge.

These values are accepted pending one immediate pre-guest-activation collision
preflight. Do not substitute another address, add a second NIC, attach Admin
VLAN 80, use libvirt NAT or macvtap, or reopen the frozen bridge decision.

### Required immediate collision preflight

Immediately before defining, starting, or attaching any guest that would use
`192.168.100.2`, collect fresh, sanitized evidence that:

1. Netbrain has no interface address at that address.
2. The address is outside/excluded from every active DHCP pool, or has an
   explicit dynamic-allocation reservation/exclusion.
3. No current DHCP lease claims it.
4. No RouterOS ARP or local Lab-10 neighbor entry claims it.
5. Configured internal DNS resolvers have no forward or reverse record
   assigning it to another identity.

The explicit operator allocation plus the completed Netbrain evidence is
sufficient only if every check passes. ARP absence alone is not sufficient.
If the address overlaps an active DHCP pool, stop and prepare a separate,
narrow Netbrain reservation/exclusion packet for this exact address; do not
select a replacement silently.

The required packet is
`implementation/2026-07-31-mail-core-guest-address-collision-preflight.packet.md`.
It must be reviewed before VM construction. No VM 9000 creation is authorized.
