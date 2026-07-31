# Migration

The durable identity is `mail.home.arpa`, not `hv-matriarch`. Restore onto a
different Proxmox host by restoring the VM backup to an isolated VMID, attaching
the recovered data disk, restoring configuration/TLS/secrets through their
controlled paths, and validating storage before exposing services.

Before cutover, select and document the new internal address/bridge/VLAN,
publish or update private DNS, issue a certificate if SAN/address policy
requires it, and trust it on clients. Prevent two active instances from sharing
the same mail data or service identity. Validate local SMTP-to-IMAP delivery,
queue inventory, and data checksums in isolation; only then stop the old VM and
publish the new DNS record. Preserve the old VM powered off until acceptance.

