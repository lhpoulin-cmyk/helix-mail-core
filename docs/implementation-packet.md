# Recommended next bounded implementation packet

**Objective:** establish current, read-only placement evidence for the requested
`hv-matriarch` target and produce a fully resolved render; do not create VM
9000 or change networking.

**Allowed actions:** authenticated read-only inspection of the confirmed target:
`pveversion -v`, `qm list`, `pvesm status`, storage/backup capability,
bridge/VLAN inventory, firewall status, resolver/DNS authority, and CA practice.
Record sanitized outputs outside Git and promote facts only.

**Success criteria:** identifies a host that the operator confirms is the
provisional Matriarch target; a durable, independently restorable VM/data
storage sufficient for VM 9000 and a consistent appliance export; approved
internal bridge/VLAN/address/DNS/CA values;
and verifies VMID 9000 availability.

**Stop conditions:** target identity ambiguity, insufficient VM 9000 storage,
no appliance-export location, no services VLAN, no DNS/CA owner, or occupied
VMID 9000.
Render unresolved values and make no mutation.
