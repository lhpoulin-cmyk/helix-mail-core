# Fastmail boundary

Fastmail at `smtp.fastmail.com` is a disabled external transport boundary,
not inbound mail, identity, or availability dependency. The bridge sender is
`cluster_admin@fastmail.com`. The checked-in policy has `enabled: false`.

## Accepted bridge design

The operator selected store-and-forward copies for the two local
administrative mailboxes:

- `admin@home.arpa`
- `cluster-admin@home.arpa`

Local delivery remains authoritative. A successful local delivery is retained
in its home.arpa mailbox, then an independently queued copy may cross the
Fastmail boundary to exactly `cluster_admin@fastmail.com`. The bridge is not a
move, mailbox migration, alias, or replacement for local delivery.

This is the useful failure mode: when the Internet or Fastmail is unavailable,
local administrators and machines continue exchanging mail. The external copy
waits in a visible queue, retries under a bounded policy, and eventually
produces an operator-visible failure instead of disappearing with professional
confidence.

The accepted design does not yet mean deployed. Fastmail remains disabled
until the implementation packet proves the current Stalwart 0.16.15 schema,
the exact app-password source, sender rewriting accepted by Fastmail, loop
prevention, queue observability, and rollback.

Activation requires a separate explicit packet naming an allowlisted message
class, rate/volume cap, sender mapping, protected runtime-secret source,
verification recipient, rollback, and operator approval. An app password is
entered directly into a protected runtime secret (file with restrictive mode or
approved secret facility), never Git, cloud-init, logs, history, template, or
fixture. Configure Stalwart relay authentication from the protected source.

Fail closed: no general authenticated relay, no MX route for arbitrary domains,
and no relay if the secret/policy is absent. The only external recipient is
`cluster_admin@fastmail.com`, and the only eligible local sources are the two
administrative mailboxes. An approved outbound message is kept queued for retry
or classified failed with an alert; it is never silently discarded. Routine
logs, telemetry, repeating monitor events, and bulk mail are not eligible.
Disable immediately by removing the policy route/secret and restarting only
under an approved change.

The route must use a Stalwart Relay object with certificate validation enabled
and an `authSecret` supplied by its `File` or `EnvironmentVariable` variant;
these are supported Stalwart relay-secret sources, not a license to place the
secret in configuration source.
