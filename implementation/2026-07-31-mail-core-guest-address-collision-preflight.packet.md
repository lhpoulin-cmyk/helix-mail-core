# Mail-core guest-address collision preflight packet

**Status:** Deferred read-only pre-guest-activation gate  
**Candidate:** `192.168.100.199/24`
**Prerequisite:** Operator Decision 4 accepted

## Purpose

Run immediately before any VM 9000 guest NIC is defined, attached, or started.
This packet performs no allocation, DHCP, DNS, RouterOS, NetworkManager,
libvirt, bridge, or VM mutation.

## Fixed values

```text
GUEST_IPV4=192.168.100.199
GUEST_PREFIX=24
GUEST_GATEWAY=192.168.100.1
GUEST_DNS_SERVERS=192.168.10.251,192.168.10.252
GUEST_MTU=1500
GUEST_NETWORK_MODEL=single-nic
NETWORK_ATTACHMENT=br-lab10
```

## Required fresh checks

Use a reviewed fixed RouterOS read-only candidate-check helper that embeds only
this address and never accepts command text from the packet or environment.
It must inspect Netbrain interface addresses, active DHCP pools and exclusions,
leases, and ARP state. The helper must stop if Netbrain read-only access is
unavailable.

Use approved read-only resolver queries against both configured internal
resolvers for forward and reverse records. Collect local `br-lab10` route
and neighbor evidence. Do not scan the subnet, issue a DHCP request, or probe
unrelated addresses.

Classify each check as observed, unavailable, permission-denied, timed-out, or
failed. Record only sanitized results and protected evidence references.

## Gate result

Pass only when:

- no Netbrain interface address, active lease, ARP/neighbor record, or
  conflicting DNS identity claims the candidate;
- active DHCP-pool evidence proves the address is outside/excluded, or an
  explicit reservation/exclusion proves it cannot be dynamically assigned; and
- no conflicting allocation evidence exists.

If an active DHCP pool includes the address without an exclusion or reservation,
stop and create a separately reviewed Netbrain mutation packet limited to the
exact reservation/exclusion. Do not choose another address.

No collision result authorizes VM 9000 construction. A separate reviewed VM
construction packet and explicit operator authorization remain required.
