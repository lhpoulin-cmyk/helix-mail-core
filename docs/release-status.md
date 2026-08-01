# Release status

```text
VERSION=1.1.1-alpha
SOAK_STATUS=STARTED
BETA_ELIGIBLE=true
```

## 1.1.1 release-blocker mail policy

The restricted machine-inbound policy is deployed and has been demonstrated
from every required participant. Version 1.1.1 remains alpha; the actual beta
promotion still requires a separate operator decision.

Required physical endpoints:

- `hv-lore`
- `hv-katra`
- `hv-matrix`
- `ws-matriarch`
- `ws-hadrian`

Required administrative mailboxes, tested independently from an approved
client endpoint:

- `admin@home.arpa`
- `cluster-admin@home.arpa`

`cluster-admin@home.arpa` is the canonical existing identity. No
`cluster_admin@home.arpa` identity is permitted.

`admin@home.arpa` and `cluster-admin@home.arpa` may deliver to any authorized
local mailbox. Every `hv-*` and `ws-*` mailbox, including deferred identities,
must accept mail only from those two authenticated administrative identities.
Machine-to-administrator delivery remains allowed; machine-to-machine and
other local-to-machine delivery must be rejected before delivery.

Tests must prove each non-deferred machine can send to an administrator and
receive/retrieve the administrator's reply. Both administrators must send to
every required machine and exchange mail with each other. Required negative
tests include `hv-lore -> hv-katra`, `ws-matriarch -> ws-hadrian`, and
`test-sender` delivery to both an `hv-*` and `ws-*` mailbox. External relay and
plaintext password transport remain prohibited.

`ws-alpha` and `ws-wowzerwin` retain their distinct identities, credentials,
bundles, dual custody, and operator-deferred status. They do not block this
specific gate and are not classified as verified.

All five required hosts and both administrative mailboxes must be
`SEND/RECEIVE VERIFIED` before setting `BETA_ELIGIBLE=true`. Satisfying this
blocker does not change the release label to beta and does not declare
promotion or production readiness. The operator must separately authorize the
actual alpha-to-beta promotion. The two-week soak, Fastmail bridge, appliance
export, and production placement remain independent gates.

## Current gate result

The `machine-inbound-admin-only` RCPT-stage system Sieve policy is active.
Submission sender impersonation is rejected, so only the canonical Admin and
Cluster Admin envelope identities can reach `hv-*` and `ws-*` recipients.
Every required positive and negative demonstration passed from the physical
endpoint or approved administrative client.

```text
1.1.1 ALPHA-TO-BETA BLOCKER SATISFIED
VERSION=1.1.1-alpha
BETA_ELIGIBLE=true
```

The version remains `1.1.1-alpha`. Changing the release label to beta requires
a separate operator decision.
