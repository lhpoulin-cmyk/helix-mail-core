# Phase 0 target inventory

Capture timestamp: 2026-07-31. Classification: read-only repository evidence;
no live host mutation was made during this work cycle.

| Item | Observation | Source | State |
| --- | --- | --- | --- |
| Construction placement | `hv-matriarch / VMID 9000` | operator instruction 2026-07-31 | proposed |
| Historical name | Historical Matriarch planning became `hv-matrix` | Infrastructure `nodes/hv-matrix/README.md` | observed |
| Current deployed hypervisor | `hv-matrix.arpa`, Proxmox VE 9.2.2 / Debian 13, 192.168.10.22 | Infrastructure capture 2026-07-27 | observed |
| Workload class | GPU compute; no guest placement approved | same | observed |
| Existing guests at baseline | none recorded 2026-07-27; VMID 9000 requires fresh live check | `VALIDATION.md` | stale for allocation |
| Storage | `local` and `local-zfs` active; ~120.53 GiB each at capture | `STORAGE.md` | observed historical |
| Candidate durable storage | none selected; only rpool-backed stores known | `STORAGE.md` | unresolved |
| Unsafe storage | two ~1 TB NVMes are reserved, unmounted, and explicitly protected | `STORAGE.md` | observed exclusion |
| Network | `vmbr0` management only; no services VLAN or non-management bridge | `NETWORKING.md` | observed historical |
| Candidate infrastructure VLAN | none established | `NETWORKING.md` | unresolved |
| DNS path | internal resolvers 192.168.10.251/.252 serve `.arpa`; no `home.arpa` evidence | `NETWORKING.md` | unresolved |
| Appliance export location | must be operator-provided for consistent portable export; Matriarch backup design is out of scope | construction boundary | unresolved |
| TLS practice | portable-root certificate evidence exists, but no mail-CA issuance practice identified | Infrastructure inventory | unresolved |
| Fresh name-resolution check | `getent hosts hv-matriarch hv-matriarch.arpa` returned no result; `hv-matrix` and `hv-matrix.arpa` resolved to `192.168.10.22` | local resolver, 2026-07-31 | observed |

## Placement conflict and stop condition

The requested host name is not an established current host identity in the
infrastructure records. The record states that historical `hv-matriarch`
planning produced `hv-matrix`, but also says the original Matriarch
workstation is separate. The actual target, storage backed by a VM restore
path, services bridge/VLAN, guest address, DNS publication path, appliance
export location, and internal certificate issuer must be freshly observed and
approved.

Consequently, this repository renders a VM contract but does not select a
datastore, bridge, VLAN, or address, and no live provisioning is authorized.
