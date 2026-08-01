# Fastmail bridge schema discovery

Date: 2026-08-01
Mode: read-only
Disposition: implementation packet rendered; no Fastmail mutation

The repository was clean at
`d1471330ea7964d148f6960cd50e62c957de86c2`. `mail-core-9000` was running and
reported `mail.home.arpa`. The installed binaries reported Stalwart `0.16.15`
and `stalwart-cli 1.0.12`; `stalwart.service` was active and enabled.

Observed listeners remained:

```text
127.0.0.1:8080       loopback management
127.0.0.1:1587       loopback submission test surface
127.0.0.1:1143       loopback mailbox test surface
192.168.100.199:587  authenticated internal submission
192.168.100.199:993  internal IMAPS
```

No public SMTP listener was observed.

The protected read-only CLI workflow captured a secret-stripped snapshot of
the exact objects relevant to the proposal. Current state was:

- `MtaRoute`: `local` and `mx` only;
- `MtaOutboundStrategy`: local domains route to `local`, default is `mx`;
- `MtaStageData.script`: disabled;
- `SieveSystemScript`: only `machine-inbound-admin-only`;
- `SieveSystemInterpreter`: maximum three redirects and five outbound messages.

The live v0.16.15 schema confirmed `Relay` routes with `authSecret`,
`authUsername`, implicit TLS, and invalid-certificate control; recipient-aware
outbound route expressions; DATA-stage trusted scripts; and active system Sieve
scripts. Official v0.16 documentation confirms RFC 3894 copy support and the
`File` secret variant. The official v0.16.15 source tag independently matched
those fields.

The discovery did not authenticate to Fastmail, create an app password, change
Stalwart objects, send external mail, or alter DNS, listeners, networking, or
the guest. The schema and snapshots contained no credential values and were
kept outside Git; this record contains only the facts needed to review the
rendered plan.

One material uncertainty remains intentionally operational: Fastmail may reject
a transparent copy carrying an unverified visible sender. The packet therefore
makes one bounded real-recipient compatibility test a required activation gate
and forbids silent sender rewriting.
