# Release status

```text
VERSION=1.1.1-alpha
SOAK_STATUS=STARTED
BETA_ELIGIBLE=true
```

## 1.1.1 alpha-to-beta mail demonstration gate

Version 1.1.1 remains alpha until each required participant proves trusted
authenticated submission, local delivery, receipt of a reply, and trusted
mailbox retrieval using only its own `home.arpa` identity and credential.

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

Every test must also prove incorrect-credential rejection, external-relay
rejection, and absence of plaintext password authentication. Tests originate
on the named endpoint and use non-secret correlation identifiers.

`ws-alpha` and `ws-wowzerwin` retain their distinct identities, credentials,
bundles, dual custody, and operator-deferred status. They do not block this
specific gate and are not classified as verified.

All five required hosts and both administrative mailboxes must be
`SEND/RECEIVE VERIFIED` before setting `BETA_ELIGIBLE=true`. Satisfying this
blocker does not change the release label to beta and does not declare
promotion or production readiness. The operator must separately authorize the
actual alpha-to-beta promotion. The two-week soak, Fastmail bridge, appliance
export, and production placement remain independent gates.

## Gate result

All seven required participants are `SEND/RECEIVE VERIFIED` in
`evidence/1.1.1-alpha-to-beta-mail-demonstration.md`.

```text
1.1.1 ALPHA-TO-BETA BLOCKER SATISFIED
BETA_ELIGIBLE=true
```

The version remains `1.1.1-alpha`. Changing the release label to beta requires
a separate operator decision.
