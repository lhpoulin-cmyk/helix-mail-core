# Migration

The durable identity is `mail.home.arpa`, not `hv-matriarch`. This document is
a future hand-off contract, not a production-migration plan. A later promotion
packet imports the portable appliance export to an isolated target, attaches
the recovered data state, restores configuration/TLS/secrets through controlled
paths, and validates storage before exposing services.

Before cutover, select and document the new internal address/bridge/VLAN,
publish or update private DNS, issue a certificate if SAN/address policy
requires it, and trust it on clients. Prevent two active instances from sharing
the same mail data or service identity. Validate local SMTP-to-IMAP delivery,
queue inventory, and data checksums in isolation; only then stop the old VM and
publish the new DNS record. Preserve the old VM powered off until acceptance.
