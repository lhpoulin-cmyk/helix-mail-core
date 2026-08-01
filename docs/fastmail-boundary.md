# Fastmail boundary

Fastmail at `smtp.fastmail.com` is an active best-effort external-copy boundary,
not inbound mail, identity, or availability dependency. SMTP authenticates as
`louis@poulin-arpa.com`; the only delivery recipients are the existing aliases
`admin@poulin-arpa.com` and `cluster_admin@poulin-arpa.com`. The checked-in
policy has `enabled: true`.

## Best-effort external copy bridge

The operator selected convenience copies for the two local administrative
mailboxes:

- `admin@home.arpa`
- `cluster-admin@home.arpa`

Local delivery remains authoritative. A successful local delivery is retained
in its home.arpa mailbox, then an independently queued copy may cross the
Fastmail boundary to its corresponding alias: `admin@poulin-arpa.com` or
`cluster_admin@poulin-arpa.com`. The bridge is not a
move, mailbox migration, alias, or replacement for local delivery.

When the Internet or Fastmail is unavailable, local administrators and machines
continue exchanging mail. An external copy may queue and retry during ordinary
operation, but version 1.1.1-beta does not claim durable store-and-forward,
exactly-once delivery, or restart-safe outbound queueing.

> An external Fastmail copy may be lost if Stalwart is stopped or restarted
> while that copy is in an active delivery attempt. Local authoritative
> delivery is unaffected.

Normal authenticated copies to both aliases passed with SMTP 250. The restart
limitation is accepted for beta and recorded in
[`known-limitations.md`](known-limitations.md). Fastmail copies are
notifications and conveniences, never records of authority.

Activation was bounded by an explicit packet naming the allowlisted messages,
sender mapping, protected runtime-secret source, verification recipients, and
rollback. The app password is held in a protected runtime file, never Git,
cloud-init, logs, history, template, or fixture. Stalwart reads relay
authentication from that protected source.
Use a mail-core-specific app password for `louis@poulin-arpa.com`. Do not copy
or reuse the shared hypervisor relay credential.

Fail closed: no general authenticated relay, no MX route for arbitrary domains,
and no relay if the secret/policy is absent. The only external recipients are
`admin@poulin-arpa.com` and `cluster_admin@poulin-arpa.com`, each paired to its
corresponding local administrative mailbox. Routine
logs, telemetry, repeating monitor events, and bulk mail are not eligible.
Disable immediately by removing the DATA-stage selector under an approved
change; preserve the relay route until any existing queue entries are resolved.

The route must use a Stalwart Relay object with certificate validation enabled
and an `authSecret` supplied by its `File` or `EnvironmentVariable` variant;
these are supported Stalwart relay-secret sources, not a license to place the
secret in configuration source.
