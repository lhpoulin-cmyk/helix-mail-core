# Matriarch br-lab10 NetworkManager bridge-construction packet

**Date:** 2026-07-31  
**Status:** Proposed bounded live mutation; final execution authorization required  
**Target:** ws-matriarch / Fedora 44  
**Decision:** `NETWORK_ATTACHMENT=br-lab10`

## Purpose and approved scope

Construct a Linux bridge named `br-lab10` with existing `enp7s0` as its
sole bridge port, moving the current `Lab 10GbE` host-layer configuration
from that physical interface to the bridge. This provides the approved
mail-core construction attachment while preserving host reachability on the
existing Lab 10GbE subnet.

The final rendered procedure must retain every material property of the
currently active `enp7s0` NetworkManager connection, including IPv4 and IPv6
methods and addresses, gateways, routes, DNS settings, MTU, firewall-zone
membership, autoconnect behavior, and any other effective connection
properties.

## Fixed boundaries

Only `enp7s0` may become a bridge port. Preserve `eno1` and `eno1.80`,
including the VLAN 80 administrative connection, without modification.

Do not create a VM or attach a guest; create or change a VLAN; create a
libvirt NAT network; use macvtap; change firewall policy, DNS records, storage,
or any accepted storage value. Do not alter `podman0`, `eno1`, or
`eno1.80`.

This packet does not itself authorize execution. It must stop after rendering
and operator review of the exact, current mutation and rollback commands.

## Mandatory immediate pre-mutation capture

Before any NetworkManager profile is created, changed, activated, or
deactivated, capture sanitized, complete current evidence for:

- the active connection and complete profile properties for `enp7s0` /
  `Lab 10GbE`;
- complete device state and effective IP configuration for `enp7s0`;
- active connections, addresses, routes, DNS/resolver state, MTU, and
  firewalld-zone attachment;
- existing bridge, bond, and VLAN state;
- complete configuration fingerprints for `eno1` and `eno1.80`, to prove
  their preservation after the change; and
- current reachability to the Lab gateway, internal DNS, relevant approved
  cluster hosts, and a public Internet target.

> Do not place raw credential material or unrelated user data in repository
> evidence. Stable identifiers and network values must be handled according to
> the repository evidence policy.

The final executor must render the exact `nmcli` commands from that capture,
not from assumptions in this packet. It must stop if the current `Lab 10GbE`
profile is absent, ambiguous, has properties that cannot be faithfully
translated to the bridge and bridge-port profiles, or the required verification
targets cannot be identified from approved evidence.

## Exact state to render for operator review

The render must show, before mutation:

1. The bridge profile for `br-lab10`, carrying the captured host-layer
   configuration.
2. The bridge-port profile for only `enp7s0`, carrying no host addresses,
   routes, gateways, or resolver configuration.
3. An explicit property-by-property comparison proving that the bridge
   preserves the prior `Lab 10GbE` configuration.
4. The original profile retained intact for rollback until verification passes.
5. The exact activation order, including the one necessary transition of the
   host configuration from `enp7s0` to `br-lab10`.
6. A post-change comparison proving `eno1` and `eno1.80` are unchanged.

## Checkpoint and rollback guard

Before activation, create a bounded, version-supported NetworkManager
checkpoint or an equivalently bounded local rollback watchdog. The exact
mechanism, timeout, and cancellation command must be rendered from the
installed tooling and reviewed before execution.

The rollback must restore the captured original `Lab 10GbE` connection to
`enp7s0`, deactivate only the newly created bridge and port profiles, and
remove only those new profiles after host reachability is restored. It must
not touch `eno1`, `eno1.80`, VLAN 80, `podman0`, libvirt networks,
firewall policy, DNS, or storage.

If checkpoint creation is unavailable, rollback cannot be made bounded, or
the executor loses required local control before verification, stop without
activating the change.

## Future execution sequence, pending final authorization

After the mandatory capture and exact render have been reviewed and explicitly
authorized:

1. Create `br-lab10` and the sole `enp7s0` bridge-port profile.
2. Apply the captured host-layer properties to `br-lab10`.
3. Arm the approved rollback checkpoint or watchdog.
4. Activate the bridge arrangement, making only the required `enp7s0` to
   `br-lab10` transition.
5. Verify local addressing, default and specific routes, resolver operation,
   Lab gateway reachability, internal DNS reachability, relevant cluster-host
   reachability, Internet reachability, and bridge/port carrier and forwarding
   state.
6. Verify that `eno1` and `eno1.80` retain their pre-change
   fingerprints and effective configuration.
7. Cancel the rollback guard only when every required verification succeeds.
   Otherwise automatically roll back where possible, record the result, and
   stop.

## Completion boundary

Record the exact commands, sanitized results, transition time, rollback status,
and final network state. Stop after bridge verification. Guest addressing,
gateway and resolver selection, authoritative DNS mutation, TLS, firewall
policy, libvirt-network work, and VM 9000 remain separate decisions and are
not authorized by this packet.
