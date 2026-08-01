# Machine and human mail enrollment result

Date: 2026-08-01  
Starting mail-core commit: `40eb4ad083c23a4600a16d919002ec41bc7d3caf`
Result: `PARTIAL — THREE PHYSICAL ENDPOINTS UNAVAILABLE`
Soak: `SOAK_STATUS=NOT_STARTED`

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
louis@home.arpa
admin@home.arpa
```

The following required physical endpoints were unavailable from the approved
control path and remain `GENERATED — ENDPOINT TEST PENDING`:

```text
ws-alpha@home.arpa       192.168.10.84 returned no route to host
ws-hadrian@home.arpa     no currently resolvable/reachable SSH endpoint
ws-wowzerwin@home.arpa   no currently resolvable/reachable SSH endpoint
```

Their Stalwart identities, distinct credentials, encrypted bundles, and both
verified Foundation copies exist. No endpoint was marked enrolled without a
successful physical endpoint test.

## Preserved boundaries

Forward-only DNS and trusted TLS remain healthy. Stalwart retains only the
reviewed loopback endpoints plus internal `.199:587` and `.199:993`. Port 25,
wildcard/public administration, Fastmail, and external relay remain disabled.
No RouterOS, firewall, bridge, NetworkManager, libvirt, host-storage, public
DNS, or public-certificate mutation occurred.

The soak cannot start until all three unavailable workstation endpoint tests
pass. No soak timestamp is assigned.
