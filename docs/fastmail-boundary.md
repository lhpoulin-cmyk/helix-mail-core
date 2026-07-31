# Fastmail boundary

Fastmail at `smtp.fastmail.com` is a disabled external transport boundary,
not inbound mail, identity, or availability dependency. The bridge sender is
`cluster_admin@fastmail.com`. The checked-in policy has `enabled: false`.

Activation requires a separate explicit packet naming an allowlisted message
class, rate/volume cap, sender mapping, protected runtime-secret source,
verification recipient, rollback, and operator approval. An app password is
entered directly into a protected runtime secret (file with restrictive mode or
approved secret facility), never Git, cloud-init, logs, history, template, or
fixture. Configure Stalwart relay authentication from the protected source.

Fail closed: no general authenticated relay, no MX route for arbitrary domains,
and no relay if the secret/policy is absent. An approved outbound message is
kept queued for retry or classified failed with an alert; it is never silently
discarded. Routine logs, telemetry, repeating monitor events, and bulk mail are
not eligible. Disable immediately by removing the policy route/secret and
restarting only under an approved change.

The route must use a Stalwart Relay object with certificate validation enabled
and an `authSecret` supplied by its `File` or `EnvironmentVariable` variant;
these are supported Stalwart relay-secret sources, not a license to place the
secret in configuration source.
