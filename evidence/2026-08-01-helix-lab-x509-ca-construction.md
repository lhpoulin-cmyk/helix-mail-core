# Helix Lab X.509 CA construction result

Date: 2026-08-01  
Mail-core packet commit: `1569deb41807747750d2d81edf4517fe56a5bf3d`  
Authority workspace: `/home/louis/helix-arpa/helix-pki`  
Authority workspace commit: `35aed04`

## Result

The offline Helix Lab X.509 CA was constructed and independently verified.

- Root: `CN=Helix Lab X.509 Root CA`, ECDSA P-256, critical CA true with
  path length 1, valid through 2036-08-01.
- Issuer: `CN=Helix Lab TLS Issuing CA`, ECDSA P-256, critical CA true with
  path length 0, valid through 2029-08-01.
- The root directly issued exactly the intermediate; no leaf was issued.
- The intermediate chains to the root and its initial CRL verifies.
- Public certificates, chain, CRL, CA databases, serial state, manifests, and
  lifecycle procedures are committed in the separate authority workspace.
- The root certificate is the onboarding trust anchor. The intermediate is
  chain material only.

## Secret safety and custody

Both CA keys were generated only in protected tmpfs. They were individually
age-encrypted to the approved Matriarch recipient, then placed inside separately
age-encrypted root and issuer custody packages. Both packages were decrypted
and structurally verified in an isolated tmpfs directory; each inner encrypted
key matched its public certificate.

An initial checksum-manifest verification failed because the manifest included
its own in-progress output file. Cleanup removed all tmpfs plaintext and the
incomplete encrypted staging output. The renderer was corrected to exclude the
manifest itself, construction restarted from fresh keys/state, and every
verification passed. No failed authority was published or retained.

No plaintext CA private key, age identity, or recipient entered Git, ordinary
host storage, logs, evidence, or chat. The final encrypted custody packages are
mode 0600 beneath the ignored mode-0700 authority workspace private directory.

No Foundation vault was written. No certificate leaf or server private key was
created. DNS, endpoint trust, Stalwart listeners, identities, Fastmail, and soak
state were unchanged.

Disposition: `HELIX LAB CA CREATED — CUSTODY PLACEMENT REQUIRED`
