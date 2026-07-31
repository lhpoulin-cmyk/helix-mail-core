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

## Read-only capture and rendered plan — 2026-07-31

**Capture authority:** operator authorization following commit `ac2a354`;
read-only inspection and command rendering only.
**Capture result:** no NetworkManager profile, device, route, firewall, DNS,
bridge, VLAN, libvirt, storage, or VM state was changed.

### Sanitized captured state

| Item | Captured state |
| --- | --- |
| Host | `ws-matriarch` |
| Parent | `enp7s0`, connected Ethernet, MTU 9000, no bridge controller or port relationship |
| Active parent profile | `Lab 10GbE`; UUID fingerprint `ae9c31ec1260`; bound to `enp7s0`; autoconnect enabled with priority `-999` |
| Parent IPv4 | Manual single address on the Lab-10 /24; no gateway; route metric 50; never-default; no explicit routes or DNS server |
| Parent IPv6 | Automatic; no configured address, gateway, route, or DNS server; no default-route suppression |
| Parent DNS | Search domain `arpa`; automatic DNS/routes are not suppressed |
| Effective firewall zone | `FedoraWorkstation` |
| Parent profile fingerprint | `dece40ae70dc8dc3f542`, over the selected non-secret migration properties |
| `eno1` invariant | Separate connected Ethernet profile `Lab 2.5GbE`, UUID fingerprint `cd485ca99948`, MTU 1500; invariant fingerprint `fd3a7f133792829c0c6b` |
| `eno1.80` invariant | Separate connected VLAN profile `Lab Admin VLAN 80`, UUID fingerprint `8bc7828068f6`, MTU 1500, VLAN 80 parented by `eno1`; invariant fingerprint `0c8c2b412348e94a18ea` |
| Existing unrelated bridge | `podman0` only; it has a Podman veth port and is not part of this operation |
| Current management | The observed established SSH management session terminates on Lab 2.5GbE, not Lab 10GbE. A logged-in local `seat0` / `tty2` session is also present. Both are independent of `enp7s0`. |
| Checkpoint capability | NetworkManager 1.56.1 does not expose an `nmcli` checkpoint command. `/usr/bin/systemd-run` is present (systemd 259) and can arm a local timed rollback independent of network reachability. |
| Separate default path | IPv4 default route is static on `eno1`, metric 100; fingerprint `2777bf8bfd1476209ae8`. It is not a Lab-10 route and must remain unchanged. |
| Resolver verification target | Two current resolver addresses are configured on `eno1`; set fingerprint `e1f289695a33f4307409`. `ws-matriarch.arpa` resolves through that configured resolver path; name fingerprint `82b6505c6e6360db`. |
| Lab-10 peer verification target | `192.168.100.20`, operator-nominated and evidenced on the connected Lab-10 route. Its neighbor state is `REACHABLE` (MAC fingerprint `c2df397396993060`), and a one-probe interface-bound ARP request received a reply. ICMP is filtered and is not the verification method. |

Credential-bearing NetworkManager settings were intentionally not read. The
active profile is wired Ethernet and the captured non-secret settings contain
no controller, secondary connection, configured gateway, explicit route, or
explicit DNS-server value that must be translated. Raw connection UUIDs, MAC
addresses, and host addresses remain out of Git.

### Stale-state gates

The following read-only gates are mandatory immediately before any future
execution. Each must succeed before a profile is created or modified:

```bash
set -euo pipefail
PARENT='Lab 10GbE'
BRIDGE='br-lab10'
PORT='mail-core-br-lab10-enp7s0-port'
EXPECTED_PARENT_FP='dece40ae70dc8dc3f542'
EXPECTED_ENO1_FP='fd3a7f133792829c0c6b'
EXPECTED_ENO180_FP='0c8c2b412348e94a18ea'
FIELDS='connection.id,connection.type,connection.interface-name,connection.autoconnect,connection.autoconnect-priority,connection.zone,802-3-ethernet.mtu,ipv4.method,ipv4.dns,ipv4.dns-search,ipv4.dns-options,ipv4.dns-priority,ipv4.addresses,ipv4.gateway,ipv4.routes,ipv4.route-metric,ipv4.route-table,ipv4.routing-rules,ipv4.never-default,ipv4.ignore-auto-routes,ipv4.ignore-auto-dns,ipv4.may-fail,ipv6.method,ipv6.dns,ipv6.dns-search,ipv6.dns-options,ipv6.dns-priority,ipv6.addresses,ipv6.gateway,ipv6.routes,ipv6.route-metric,ipv6.route-table,ipv6.routing-rules,ipv6.never-default,ipv6.ignore-auto-routes,ipv6.ignore-auto-dns,ipv6.may-fail'

test "$(hostname -s)" = ws-matriarch
test "$(nmcli -g GENERAL.CONNECTION device show enp7s0)" = "$PARENT"
test "$(nmcli -g GENERAL.TYPE device show enp7s0)" = ethernet
test "$(nmcli -g GENERAL.MTU device show enp7s0)" = 9000
test "$(nmcli -g "$FIELDS" connection show "$PARENT" | sha256sum | cut -c1-20)" = "$EXPECTED_PARENT_FP"
test -z "$(nmcli -g GENERAL.CONNECTION device show eno1 | grep -Fx "$PARENT" || true)"
test -z "$(nmcli -g GENERAL.CONNECTION device show eno1.80 | grep -Fx "$PARENT" || true)"
test -z "$(nmcli -g NAME connection show "$BRIDGE" 2>/dev/null || true)"
test -z "$(nmcli -g NAME connection show "$PORT" 2>/dev/null || true)"
```

The executor must also recompute the two invariant fingerprints using the
captured commands before and after the transition. Any mismatch, a new bridge
relationship on `enp7s0`, or any change to `eno1` or `eno1.80` stops the
run before activation.

### Exact future NetworkManager render

The following is the complete future mutation render. It is **not authorized
to run in this cycle**. It derives the existing non-secret IP properties at
execution time only after the stale-state gates pass, rather than putting host
addresses or UUIDs in Git.

```bash
IPV4_ADDRESSES="$(nmcli -g ipv4.addresses connection show "$PARENT")"
IPV4_DNS_SEARCH="$(nmcli -g ipv4.dns-search connection show "$PARENT")"

sudo nmcli connection add type bridge ifname "$BRIDGE" con-name "$BRIDGE" \
  connection.autoconnect yes connection.autoconnect-priority -999 \
  connection.zone FedoraWorkstation 802-3-ethernet.mtu 9000 \
  ipv4.method manual ipv4.addresses "$IPV4_ADDRESSES" \
  ipv4.dns-search "$IPV4_DNS_SEARCH" ipv4.route-metric 50 \
  ipv4.never-default yes ipv4.ignore-auto-routes no \
  ipv4.ignore-auto-dns no ipv4.may-fail yes \
  ipv6.method auto ipv6.never-default no ipv6.ignore-auto-routes no \
  ipv6.ignore-auto-dns no ipv6.may-fail yes

sudo nmcli connection add type ethernet ifname enp7s0 con-name "$PORT" \
  controller "$BRIDGE" port-type bridge connection.autoconnect yes \
  802-3-ethernet.mtu 9000 ipv4.method disabled ipv6.method disabled
```

The bridge receives the prior effective firewall-zone attachment
(`FedoraWorkstation`); this does not alter firewall policy. The port carries
no host-layer address, route, gateway, resolver configuration, or VLAN. The
original `Lab 10GbE` profile remains present for rollback; its autoconnect is
temporarily disabled only while `br-lab10` carries the equivalent host role.

### Exact timed rollback render

Because installed `nmcli` has no checkpoint subcommand, future execution
must use this local 180-second systemd timer. It must be armed and verified
before deactivating the parent profile. Its service restores the original
profile and removes only the two newly created profiles.

```bash
sudo install -d -m 0700 /run/mail-core-br-lab10
sudo tee /run/mail-core-br-lab10/rollback >/dev/null <<'EOF'
#!/usr/bin/bash
set -u
/usr/bin/nmcli connection down id br-lab10 || true
/usr/bin/nmcli connection down id mail-core-br-lab10-enp7s0-port || true
/usr/bin/nmcli connection delete id mail-core-br-lab10-enp7s0-port || true
/usr/bin/nmcli connection delete id br-lab10 || true
/usr/bin/nmcli connection modify id 'Lab 10GbE' connection.autoconnect yes connection.autoconnect-priority -999
/usr/bin/nmcli connection up id 'Lab 10GbE' ifname enp7s0
EOF
sudo chmod 0700 /run/mail-core-br-lab10/rollback
sudo systemd-run --unit=mail-core-br-lab10-rollback --on-active=180s --collect \
  /run/mail-core-br-lab10/rollback
systemctl is-active mail-core-br-lab10-rollback.timer
```

After the timer is confirmed active, the only permitted activation transition
is:

```bash
sudo nmcli connection modify id "$PARENT" connection.autoconnect no
sudo nmcli connection down id "$PARENT"
sudo nmcli connection up id "$BRIDGE"
sudo nmcli connection up id "$PORT" ifname enp7s0
```

Only after every verification below succeeds may the executor cancel the timer
and remove its temporary script:

```bash
sudo systemctl stop mail-core-br-lab10-rollback.timer
sudo rm -f /run/mail-core-br-lab10/rollback
sudo rmdir /run/mail-core-br-lab10
```

If any step or check fails, do not cancel the timer. The timer is the primary
rollback mechanism. A local console on `seat0` / `tty2` and the independent
Lab 2.5GbE management path are the observed management fallbacks.

### Exact verification and manual rollback render

Run these checks before cancelling the timer:

```bash
nmcli device status
bridge link show dev enp7s0
ip -brief address show dev br-lab10
ip -4 route show 192.168.100.0/24 dev br-lab10
test "$(ip -4 route show default | sha256sum | cut -c1-20)" = 2777bf8bfd1476209ae8
ip -4 route show default | grep -F ' dev eno1 '
test "$(resolvectl dns eno1 | grep -oE '([0-9]{1,3}\\.){3}[0-9]{1,3}' | sort -u | sha256sum | cut -c1-20)" = e1f289695a33f4307409
resolvectl query --interface=eno1 ws-matriarch.arpa
nmcli -g GENERAL.CONNECTION,GENERAL.MTU device show eno1
nmcli -g GENERAL.CONNECTION,GENERAL.MTU device show eno1.80
```

Run the default-route and resolver checks once before arming the timer and once
after the bridge transition. They verify the independent `eno1` collateral
path: they must not be interpreted as proof that `br-lab10` carries Lab-10
traffic. A non-gating Internet collateral check, when executed, is explicitly
bound to `eno1`:

```bash
ping -n -c 1 -W 2 -I eno1 1.1.1.1
```

The host address captured from `$PARENT` must appear only on `br-lab10`;
the Lab-10 connected route must use `br-lab10`; the pre-existing default
route must remain on its independent Lab 2.5GbE path; and `eno1` and
`eno1.80` must match their invariant fingerprints. The resolver must retain
its existing internal DNS server set and `arpa` search domain.

Immediately before the transition, the executor must prove the route and
Layer-2 reachability of the evidence-derived Lab-10 peer, then repeat the same
proof against the bridge:

```bash
LAB10_PEER='192.168.100.20'
ip route get "$LAB10_PEER" | grep -F ' dev enp7s0 '
arping -c 1 -w 2 -I enp7s0 "$LAB10_PEER"
# After the bridge transition:
ip route get "$LAB10_PEER" | grep -F ' dev br-lab10 '
arping -c 1 -w 2 -I br-lab10 "$LAB10_PEER"
```

No Lab-10 gateway is requested or permitted: this attachment has no gateway
and no default route by design. The Lab-10 peer, internal DNS name, and
resolver target are evidence-derived. If manual rollback is required before the
timer fires, run the timer's rollback script unchanged:

```bash
sudo /run/mail-core-br-lab10/rollback
```

### Disposition

**Ready for final execution authorization.** The host profile and independent
management fallback are suitable for a guarded bridge transition; a local
timed rollback is available; the default `eno1` route and resolver checks are
evidence-derived; and the Lab-10 peer has a verified route and ARP response.
No Lab-10 gateway is needed. Re-run the stale-state gates immediately before
any activation. No VM 9000 work is authorized.

## Execution record — 2026-07-31T22:55:07Z

**Authority:** operator authorization of this packet at commit `2f6d6ae`.

### Live mutations performed

1. Created NetworkManager bridge profile `br-lab10`.
2. Created NetworkManager Ethernet bridge-port profile
   `mail-core-br-lab10-enp7s0-port`, bound only to `enp7s0`.
3. Created the restricted runtime rollback script and armed
   `mail-core-br-lab10-rollback.timer` for 180 seconds. The timer was
   confirmed active before the parent transition.
4. Disabled autoconnect on the retained `Lab 10GbE` profile, deactivated it,
   activated `br-lab10`, and activated its sole `enp7s0` port.
5. After every verification passed, stopped the rollback timer and removed
   only its temporary runtime script and directory.

No profile other than the approved parent, bridge, and bridge-port profiles was
created, changed, or deleted. No VLAN, firewall policy, DNS record, libvirt
network, storage, VM, TLS, credential, or mail configuration mutation occurred.

### Verification results

All immediate pre-mutation gates passed: authorized commit, clean repository,
`ws-matriarch` identity, captured parent-profile fingerprint, independent
`eno1` default-route fingerprint, resolver-set fingerprint, internal DNS
lookup, Lab-10 ARP reachability, established SSH on the separate Lab 2.5GbE
path, and local `seat0` / `tty2` fallback.

Post-activation verification passed while the rollback timer remained armed:

- `br-lab10` is connected as a bridge at MTU 9000.
- `enp7s0` is connected at MTU 9000 as the sole forwarding port of
  `br-lab10`.
- The prior Lab-10 IPv4 address and its connected non-default route are on
  `br-lab10`; no Lab-10 gateway or default route exists.
- The evidence-derived Lab-10 peer routes through `br-lab10` and replies to
  the interface-bound ARP probe.
- The original default route remains unchanged on `eno1`; the established
  SSH management path remains on that separate interface.
- Resolver-set and `ws-matriarch.arpa` checks passed.
- `eno1` and `eno1.80` matched their pre-mutation invariant fingerprints.
- The `FedoraWorkstation` zone includes `br-lab10`; no firewall policy was
  changed.

An independent read-only review at the timestamp above repeated those bridge,
route, resolver, firewall-zone, and Lab-10 ARP checks. System libvirt domain
and network inventories were empty: no VM 9000 or libvirt network was created.

**Disposition:** ACCEPTED.

Stop after this verified bridge construction. VM 9000 creation or definition
remains unauthorized.

## Frozen network values

Network construction was accepted at commit `55f0648`. The following values
are frozen for subsequent construction decisions:

```
NETWORK_ATTACHMENT=br-lab10
BRIDGE_PARENT=enp7s0
BRIDGE_MTU=9000
```

Do not reopen or modify `br-lab10`, `enp7s0`, `eno1`, or `eno1.80`
unless later verification establishes an actual defect and a separately
reviewed packet authorizes a correction.
