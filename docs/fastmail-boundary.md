# Fastmail boundary

Fastmail participates in two deliberately different directions. One is an
approved authority contract for operator instructions coming into the lab. The
other is the active best-effort copy bridge carrying selected local mail out
for visibility. Sharing a provider does not make them the same protocol.

| Direction | Purpose | Authority and record | Current delivery treatment |
| --- | --- | --- | --- |
| Fastmail -> `home.arpa` | Operator direction to local coders and control-plane intake | Authoritative only when the approved sender, authenticated identity, and designated recipient validate. Preserve the locally received message and intake evidence. | Execution remains bounded by normal packet, review, safety, and scope doctrine. The transport and coder-intake enforcement are not yet deployed. |
| `home.arpa` -> Fastmail | Off-site visibility for selected administrative mail | Not an operator-direction channel. The local mailbox is authoritative; the external copy is a convenience record only. | Best effort, exact-recipient scoped, with the documented restart/queue limitation. |

## Inbound authoritative operator direction

The approved authority path is:

```text
Louis using louis@poulin-arpa.com
  -> admin@home.arpa or cluster-admin@home.arpa
  -> local Stalwart delivery
  -> reviewed local coder or control-plane intake
  -> authoritative operator instruction
```

The approved sender and designated control recipients are recorded in
[`../config/stalwart/policy-contract.json`](../config/stalwart/policy-contract.json).
The sender identity is policy, not a secret; its application password remains
protected runtime material.

An accepted message communicates operator authority and intent. It does not
approve whatever a parser can imagine. Intake must fail closed when sender
authentication is missing or fails, the envelope sender is not the approved
identity, the recipient is not a designated control address, the instruction
is ambiguous, the requested action exceeds its stated scope, or repository
doctrine requires an implementation packet that is absent. The original local
message and sanitized intake decision are evidence.

This policy does not infer authority from replies, notifications, outbound
copies, display names, message bodies claiming a different identity, or mail
to another address. It also does not create a general Fastmail return route or
bidirectional command protocol. Public SMTP remains disabled, and no deployed
Fastmail-to-`home.arpa` transport or coder-intake service has yet been accepted;
those require separate bounded implementation and verification.

## Best-effort external copy bridge

This is the currently active direction. Fastmail at `smtp.fastmail.com` is an
external-copy boundary, not a local identity or availability dependency. SMTP
authenticates as `louis@poulin-arpa.com`; the only delivery recipients are the
existing aliases `admin@poulin-arpa.com` and
`cluster_admin@poulin-arpa.com`. The checked-in outbound policy has
`enabled: true`.

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
notifications and conveniences, never operator-direction records. They do not
become authoritative merely because someone replies to one; only the
separately allowlisted inbound path can carry operator direction.

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
