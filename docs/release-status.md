# Release status

```text
VERSION=1.1.1-alpha
SOAK_STATUS=STARTED
BETA_ELIGIBLE=false
```

## 1.1.1 alpha-to-beta mail demonstration gate

Version 1.1.1 remains alpha until each non-deferred physical endpoint proves
trusted authenticated submission, local delivery, receipt of a reply, and
trusted mailbox retrieval using only its own `home.arpa` identity and
credential:

- `hv-lore`
- `hv-katra`
- `hv-matrix`
- `ws-matriarch`
- `ws-hadrian`

Every test must also prove incorrect-credential rejection, external-relay
rejection, and absence of plaintext password authentication. Tests originate
on the named endpoint and use non-secret correlation identifiers.

`ws-alpha` and `ws-wowzerwin` retain their distinct identities, credentials,
bundles, dual custody, and operator-deferred status. They do not block this
specific gate and are not classified as verified.

All five required hosts must be `SEND/RECEIVE VERIFIED` before setting
`BETA_ELIGIBLE=true`. Satisfying this blocker does not declare promotion or
production readiness. The two-week soak, Fastmail bridge, appliance export,
and production placement remain independent gates.
