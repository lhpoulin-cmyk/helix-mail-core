# Netbrain Lab-10 gateway verification packet

**Date:** 2026-07-31  
**Status:** Bounded read-only router evidence; no RouterOS mutation authorized  
**Router:** Netbrain  
**Purpose:** Decision 4 guest addressing and routing for `mail-core-9000`

## Frozen topology decision

```
GUEST_NETWORK_MODEL=single-nic
NETWORK_ATTACHMENT=br-lab10
ROUTER=netbrain
```

Do not bridge the guest into Admin VLAN 80, attach a second guest NIC, alter
`br-lab10`, `enp7s0`, `eno1`, or `eno1.80`, use libvirt NAT or macvtap,
or invent a gateway address.

The Netbrain node record contains historical sanitized context that identifies
a Lab-10 router interface, but it is not current evidence. This packet must
collect fresh router evidence before relying on any interface, address, route,
policy, MTU, reservation, or allocation fact.

## Authorized evidence boundary

Use only a reviewed fixed profile:

```
NETBRAIN_EVIDENCE_PROFILE=netbrain-lab10-gateway-readonly-v1
```

The profile must use the established key-only Netbrain administrative path and
a hard-coded RouterOS read-only command allowlist. It must not accept command
text, interface names, addresses, or destinations from this packet or the
environment. It must not enter configuration mode, use `set`, `add`,
`remove`, `enable`, `disable`, `reset`, `reboot`, `export` without
sensitive-data handling, or any RouterOS mutation command.

If that fixed collector profile does not exist, stop and create a separate
repository-only collector-profile correction packet. Do not substitute a
historical export for fresh evidence and do not run ad hoc router commands.

Raw RouterOS output, DHCP lease details, client hardware addresses, keys, and
credential material remain private evidence. Commit only sanitized facts,
fingerprints, and evidence references.

## Required fresh observations

Collect sanitized evidence sufficient to determine:

1. The authoritative Lab-10 subnet, prefix, Netbrain interface, and its
   address. Record the exact gateway only in protected evidence until it is
   promoted as an approved inventory value.
2. Whether the interface is routed or bridged; its MTU/L2MTU and relevant
   bridge, VLAN, and switch-port relationships.
3. Existing routes and return routing between Lab-10 and:
   internal DNS resolvers, approved internal cluster systems, and the router's
   Internet/WAN path.
4. Firewall and NAT rules that could affect Lab-10 egress or return traffic.
   Identify rule order, chain, action, and sanitized match conditions; do not
   expose unrelated policy or change any rule.
5. Existing DHCP networks, static leases, address lists, ARP entries, and
   router-owned addresses relevant to a mail-core static-address candidate.
   Treat incomplete lease/ARP visibility as insufficient allocation authority.
6. Router DNS/resolver behavior only where it is relevant to reaching the
   approved internal DNS resolvers. Do not alter DNS.
7. Evidence of path policy for Debian and Fedora package repositories,
   Fastmail SMTP/IMAP endpoints, and approved internal cluster systems. A
   router default route alone does not prove firewall/NAT policy permits these
   flows.
8. Whether a single 9000-MTU NIC can work end-to-end. The conclusion must
   distinguish router interface MTU from verified path MTU. If evidence cannot
   establish end-to-end jumbo support, `GUEST_MTU` remains unresolved or is
   conservatively recommended only with explicit evidence.

## Required decision report

Render only evidence-supported values:

```
GUEST_IPV4=UNRESOLVED_GUEST_IPV4
GUEST_PREFIX=UNRESOLVED_GUEST_PREFIX
GUEST_GATEWAY=UNRESOLVED_GUEST_GATEWAY
GUEST_DNS_SERVERS=UNRESOLVED_GUEST_DNS_SERVERS
GUEST_MTU=UNRESOLVED_GUEST_MTU
GUEST_NETWORK_MODEL=single-nic
```

For each value, give observed evidence, recommendation, alternatives and
consequences, exact proposed inventory value, and confidence. Perform a
collision preflight for one recommended static candidate using authoritative
allocation/reservation evidence, router state, DNS forward/reverse evidence,
host route and neighbor evidence, and documented static assignments. Absent
ARP alone is not sufficient.

Conclude either:

- **existing Netbrain state sufficient** — proceed only to the guest-address
  operator decision; or
- **router change required** — create a separate bounded Netbrain
  router-mutation packet limited to the missing Lab-10 gateway/routing policy,
  including a current backup, exact commands, validation, rollback, and a
  separate operator authorization stop.

## Fixed prohibitions

No public inbound SMTP, unrestricted Lab-10-to-Admin access, DNS mutation,
Fastmail enablement, VM 9000 definition/creation, or unrelated Netbrain
redesign is authorized by this packet.
