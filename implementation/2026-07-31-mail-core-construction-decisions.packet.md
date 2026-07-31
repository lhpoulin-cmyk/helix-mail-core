# Mail-core construction decisions packet

Date: 2026-07-31
Status: repository-only operator decision workflow
Target: temporary Matriarch construction placement; service identity
`mail.home.arpa`

## Authority and boundary

This packet authorizes only documentation, decision recording, validation, and
rendered proposals after the required decisions are explicitly approved. It
does not authorize a VM, domain, storage pool, disk, network, bridge, VLAN,
address, DNS record, certificate, package, service, credential, access-control,
or Fastmail change. In particular, it does not authorize creation of VM 9000.

Ask and record exactly one operator decision at a time, in the order below.
Do not advance a later decision until the preceding one is recorded with its
exact inventory value and any required read-only preflight result. A decision
does not itself authorize its implementation.

## Accepted facts and boundaries

- `mail-core-9000` is absent and construction identifier/VMID `9000` is
  available at the 2026-07-31 inventory collection time.
- No system libvirt network or storage pool is defined.
- The accepted local modular-libvirt Unix-socket preset is verified; no
  monolithic stack or TCP/TLS libvirt listener is accepted or needed.
- The service identity is `mail.home.arpa`; public inbound SMTP is prohibited
  and Fastmail relay remains disabled.
- Matriarch backup architecture, production placement, and migration are out
  of scope. `APPLIANCE_EXPORT_REFERENCE` is opaque and must not be accessed.
- Fresh inventory is authoritative for current host state:
  `docs/matriarch-target-inventory.md`, evidence collected
  2026-07-31T21:15:56Z through 2026-07-31T21:15:58Z.

## Decision gates

### Required before VM construction

| Order | Decision | Inventory value | State |
| --- | --- | --- | --- |
| 1 | System-disk storage | `VM_STORAGE` | **ACTIVE — operator decision requested below** |
| 2 | Separate mail-data storage | `VM_DATA_STORAGE` | locked pending 1 |
| 3 | Existing network attachment | `NETWORK_BRIDGE`, `NETWORK_VLAN` | locked pending 2 |
| 4 | Static guest address and collision preflight | `GUEST_IPV4` | locked pending 3 |
| 5 | Gateway and DNS resolvers | `GUEST_GATEWAY`, `DNS_PRIMARY`, `DNS_SECONDARY` | locked pending 4 |

### Required before local mail acceptance

| Order | Decision | Inventory value | State |
| --- | --- | --- | --- |
| 6 | `home.arpa` authoritative mutation path | `HOME_ARPA_DNS_MUTATION_PATH` | locked pending 5 |
| 7 | Construction TLS issuance/trust/renewal practice | `TLS_CA_REFERENCE` | locked pending 6 |

### Required before promotion readiness

| Order | Decision | Inventory value | State |
| --- | --- | --- | --- |
| 8 | `APPLIANCE_EXPORT_REFERENCE` timing | `APPLIANCE_EXPORT_REFERENCE` | locked pending 7 |

## Active decision — 1. System-disk storage

**Required for:** VM construction

### Observed evidence

- Fresh accepted inventory reports no defined system libvirt storage pool and
  no targeted current storage-capacity evidence. Consequently,
  `VM_STORAGE=UNRESOLVED_DURABLE_STORAGE` remains fail-closed.
- `docs/architecture.md` requires construction-host storage and prohibits use
  of host root, scratch, GPU storage, or an undocumented path for mail data.
- The requested historical `nvme3n1` VM-storage association is not evidenced
  in this repository or the existing Matriarch infrastructure documentation
  searched on 2026-07-31. Do not infer a current kernel path, partition, or
  filesystem from that historical label.
- The only discovered historical Matriarch storage records are explicitly
  superseded: `nodes/ws-matriarch/COMPUTE_NODE.md` identifies a former-platform
  root NVMe and a secondary device with existing Windows/ext4/swap layout, and
  says not to use its storage assumptions for a live change.

### Recommended choice

Keep `VM_STORAGE` unresolved and authorize a *separately reviewed, read-only*
current storage-identification packet for the operator-nominated dedicated
VM-storage device. That packet must establish stable hardware identity,
ownership/reuse approval, existing format/mount/consumer state, capacity, and
the intended libvirt pool/path before any value is entered.

### Alternatives and consequences

| Alternative | Consequence |
| --- | --- |
| Approve the recommendation: defer selection pending targeted current evidence | Preserves recovery and prevents use of an obsolete kernel name; VM construction remains blocked. |
| Select host root or its current filesystem immediately | Rejected: conflicts with the architecture's host-root prohibition and lacks a dedicated-pool design. |
| Select the historically documented secondary device immediately | Rejected until current identity and data-preservation/reuse are confirmed; historical records show existing layouts and are superseded. |
| Assert a current `nvme3n1` path or format from historical naming | Rejected: no evidence supports the current path, device identity, or format. |

### Exact inventory value

Until the recommended read-only evidence and a later explicit storage decision
exist, retain:

```text
VM_STORAGE=UNRESOLVED_DURABLE_STORAGE
```

After approval, enter only the exact, evidence-backed pool/path identifier
from the later packet; do not use a kernel device name as the durable value.

### Operator decision requested

Choose one:

1. Approve a separate read-only packet to identify the dedicated system-disk
   storage candidate by stable identity before selecting `VM_STORAGE`
   (recommended).
2. Keep `VM_STORAGE` unresolved and stop construction planning.

No later decision is requested yet.

## Locked decision templates

These templates define the later one-at-a-time prompts; they do not request an
operator choice now.

| Decision | Observed evidence | Recommended choice | Alternatives / consequence | Exact value to enter | Required phase |
| --- | --- | --- | --- | --- | --- |
| 2. Separate mail-data storage | No defined pool or targeted storage evidence; `/srv/stalwart` requires isolated persistent state | Use a separately approved durable role, distinct from system-disk failure domains where evidence supports it | Co-locate only with explicit recovery trade-off; host root/scratch/GPU storage prohibited | `VM_DATA_STORAGE=UNRESOLVED_DURABLE_DATA_STORAGE` until approved | construction |
| 3. Existing network attachment | No libvirt networks; host links do not authorize guest attachment | Select an existing operator-approved attachment, then specify bridge/VLAN | Creating a new network or bridge requires a separate packet | `NETWORK_BRIDGE=UNRESOLVED_NETWORK_BRIDGE`; `NETWORK_VLAN=UNRESOLVED_VLAN_ID` | construction |
| 4. Static guest address | No guest address or collision evidence | Reserve one address and run an approved collision preflight immediately before construction | DHCP or an untested static assignment changes the recovery/identity contract | `GUEST_IPV4=UNRESOLVED_GUEST_IPV4_CIDR` | construction |
| 5. Gateway and resolvers | Host routes/resolvers do not authorize guest settings | Obtain values from the approved guest network authority | Copying host values without authority can select the wrong plane | `GUEST_GATEWAY=UNRESOLVED_GATEWAY`; `DNS_PRIMARY=UNRESOLVED_DNS_PRIMARY`; `DNS_SECONDARY=UNRESOLVED_DNS_SECONDARY` | construction |
| 6. `home.arpa` mutation path | No DNS owner or authoritative path established | Name the responsible authority and approved mutation/reversal method | Local hosts-file or ad-hoc resolver override is not authoritative | `HOME_ARPA_DNS_MUTATION_PATH=UNRESOLVED` | acceptance |
| 7. Construction TLS practice | No issuer, trust, renewal, or replacement evidence | Select internal issuer, trust distribution, renewal owner, and replacement procedure | Self-signed or public issuance without reviewed trust/recovery practice blocks acceptance | `TLS_CA_REFERENCE=UNRESOLVED_TLS_CA` | acceptance |
| 8. Export-reference timing | Opaque reference absent and out of scope | Set a timing gate, not a destination, before promotion readiness | Accessing or inventing the destination violates opacity | `APPLIANCE_EXPORT_REFERENCE=UNRESOLVED_APPLIANCE_EXPORT_LOCATION` | promotion |

## Completion and stop condition

After decisions 1–5 are explicitly approved and recorded, render a VM 9000
construction proposal only. Validate it, show its exact non-executing output,
and stop for explicit construction authorization. Decisions 6–8 remain gates
for their stated later phases. Never infer a decision from a render or from
historical infrastructure documentation.
