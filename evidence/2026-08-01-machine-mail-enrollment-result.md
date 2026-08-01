# Machine and human mail enrollment result

Date: 2026-08-01  
Starting mail-core commit: `40eb4ad083c23a4600a16d919002ec41bc7d3caf`
Result: `ACCEPTED UNDER OPERATOR-APPROVED ENDPOINT DEFERRALS`
Soak: `SOAK_STATUS=STARTED`

## Identity and bundle result

Live Stalwart schema was queried before mutation. The four existing foundation
accounts were unchanged. One create-only declarative operation created exactly
the seven authorized machine accounts and two authorized human accounts. Its
dry-run and apply both reported nine creates, no update, upsert, destroy,
reconcile, or failure.

Nine credentials were generated independently in protected ignored state and
passed pairwise-distinct checks without exposing values or hashes. A separate
cross-credential test proved another identity's credential cannot authenticate
as the tested identity. Authenticated external relay was rejected for every
new identity.

Exactly nine named onboarding archives were generated. Every plaintext staging
tree and temporary plaintext tarball was removed after age encryption. Each
ciphertext was decrypted in an isolated protected directory and its internal
manifest and checksums passed. No private CA key or unrelated credential was
included.

## Dual Foundation placement

Both accepted vaults matched their committed filesystem and encryption-layer
fingerprints, were distinct, read-only, had sufficient capacity, and had no
active user process. Each was handled as a separate transaction:

1. remount read-write;
2. create only `credentials/mail-onboarding` mode 0700;
3. install the nine ciphertext archives and non-secret manifest mode 0600;
4. flush and compare every destination hash;
5. remount read-only;
6. compare every hash again.

Foundation returned read-only before Second Foundation's write window opened.
Both ended read-only with all ten hashes matching the verified source. No
pre-existing credential was removed or replaced.

## Endpoint status

The following identities completed trusted certificate verification,
authenticated submission, local reply, IMAPS retrieval, cross-credential
isolation, external-relay rejection, Stalwart-restart persistence, and full
guest-reboot persistence:

```text
hv-lore@home.arpa
hv-katra@home.arpa
hv-matrix@home.arpa
ws-matriarch@home.arpa
ws-hadrian@home.arpa
louis@home.arpa
admin@home.arpa
```

The following physical endpoints were unavailable from the approved control
path before the operator amended the soak gate:

```text
ws-alpha@home.arpa       192.168.10.84 is offline/unreachable
ws-wowzerwin@home.arpa   Windows endpoint 192.168.10.82 is offline/unreachable
```

Their Stalwart identities, distinct credentials, encrypted bundles, and both
verified Foundation copies exist. Neither endpoint is falsely classified as
tested.

## Preserved boundaries

Forward-only DNS and trusted TLS remain healthy. Stalwart retains only the
reviewed loopback endpoints plus internal `.199:587` and `.199:993`. Port 25,
wildcard/public administration, Fastmail, and external relay remain disabled.
No RouterOS, firewall, bridge, NetworkManager, libvirt, host-storage, public
DNS, or public-certificate mutation occurred.

## Hadrian continuation

Current Infrastructure evidence identified `192.168.10.86` as Hadrian's active
Wi-Fi identity. The address became reachable and strict SSH verification
confirmed hostname `ws-hadrian`, Fedora 44, and x86_64.

Only `ws-hadrian-mail-onboarding.tar.gz.age` was retrieved from read-only
Foundation. Its outer hash, safe archive structure, internal checksums,
`ws-hadrian@home.arpa` manifest identity, service address, and Helix root CA
matched the accepted records. Decrypted temporary material was removed.

The Helix root was absent from Hadrian's trust anchors. It was installed using
Fedora's supported `/etc/pki/ca-trust/source/anchors/` and `update-ca-trust`
path, then verified as an active CA anchor. Hadrian's own protected credential
and mail settings were installed without another machine's credential.

From physical `ws-hadrian`, trusted TLS, authenticated submission, local
delivery, receipt of a reply, IMAPS retrieval, a fresh random incorrect
credential rejection, external relay rejection, and absence of pre-TLS
password mechanisms all passed. Hadrian is `ENROLLED AND VERIFIED`.

## Operator-approved endpoint deferrals and soak start

The operator confirmed that `ws-alpha` currently cohabitates with the already
enrolled and verified `ws-matriarch` operating surface. Its separate endpoint
test is deferred without deleting or merging the `ws-alpha@home.arpa` identity,
credential, or bundle.

The operator also confirmed that `ws-wowzer-win` is temporarily not
serviceable. Its endpoint test is explicitly deferred. Its distinct identity,
credential, encrypted bundle, and dual custody remain preserved for later
enrollment; no test success is claimed.

Immediately before soak start, both configured resolvers still returned only
`mail.home.arpa A 192.168.100.199`. Submission and IMAPS independently verified
the accepted certificate chain and hostname over TLS 1.3. All nine archive
hashes matched on both distinct read-only Foundations, and scoped plaintext
assembly/verification directories remained absent.

Under this amended operator-approved gate, every currently serviceable endpoint
and both human identities meet the enrollment contract. The construction soak
started at `2026-08-01T14:06:05-04:00` in `America/Detroit`. The minimum
two-week period becomes eligible for review at
`2026-08-15T14:06:05-04:00`.

Soak start does not declare promotion readiness and does not authorize
Fastmail, public SMTP, production placement, or export-reference work.
