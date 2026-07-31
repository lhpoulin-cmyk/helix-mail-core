# Mail-core network attachment decision packet

Date: 2026-07-31
Status: approved read-only Decision 3 discovery
Target: Fedora 44 `ws-matriarch`; future domain `mail-core-9000`

HOST_EVIDENCE_PROFILE=matriarch-network-readonly-v1

## Scope

Collect only current, sanitized networking and libvirt metadata needed to make
one operator decision for `NETWORK_ATTACHMENT`. No bridge, NetworkManager
connection, libvirt network, VLAN, route, firewall, DNS, domain, or VM may be
created or changed.

## Required decision record

Using only the run-local evidence, record: active physical interface and active
NetworkManager connection; bridges, bonds, VLANs, routes, firewall zones, and
system libvirt networks; whether an existing attachment can carry a stable
cluster-reachable internal address; whether a Linux bridge is required; and
disruption/rollback implications.

Recommend one practical attachment. The preferred architecture is direct
attachment to the approved internal-services network through an
operator-approved Linux bridge. Do not recommend macvtap if it prevents
reliable host-to-guest communication. Do not select libvirt NAT merely for
convenience: `mail.home.arpa` must be reachable by approved internal systems
without public exposure or port-forwarding fragility.

Render exactly one `NETWORK_ATTACHMENT=...` value, or
`NETWORK_ATTACHMENT=UNRESOLVED_OPERATOR_NETWORK_ATTACHMENT` if current
evidence does not establish an approved attachment. Keep guest address,
gateway/resolvers, DNS ownership, and TLS as separate decisions.

## Operator prompt and stop condition

Present exactly one Decision 3 choice: accept the recommended attachment or
keep it unresolved. Include observed state, later exact live changes,
disruption risk, rollback path, and inferior alternatives. Stop after that
decision; do not proceed to guest-address, gateway, resolver, or VM work.
