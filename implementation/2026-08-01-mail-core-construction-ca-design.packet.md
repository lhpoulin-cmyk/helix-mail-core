# Mail-core construction CA design

Status: design proposal only — operator decision and execution authorization required

## Purpose

Establish a minimal private X.509 CA suitable for internal construction and
soak TLS only because no existing approved X.509 lab CA was found. This packet
does not create a CA, root key, certificate, leaf key, or trust-store entry.

## Recommended architecture

- Operator-owned offline root CA stored only in protected Foundation custody.
- A separate constrained issuing intermediate performs leaf issuance from a
  designated protected environment; the offline root is not used routinely.
- Root and intermediate public certificates are distributed to the seven
  approved clients; no CA private key enters Git, mail-core, a bundle, or a
  normal endpoint trust directory.
- The mail-core leaf key is generated on `mail-core-9000` as the `root` owner,
  mode 0600, and only its CSR leaves the guest.
- Leaf profile permits server authentication only, SAN
  `DNS:mail.home.arpa`, validity 180 days, with review at 30 days remaining.
- Renewal owner: operator, using the same CSR/issuance path.
- Compromise rollback: stop Lab-10 TLS listeners, revoke the leaf at the
  issuing CA, publish the updated revocation state through the reviewed trust
  mechanism, generate a new guest key/CSR, reissue, verify, and restart.

## Decisions required before rendering execution

1. CA implementation and pinned version (recommended: a maintained packaged
   Smallstep `step-ca` only if its official trust and recovery model is accepted).
2. Exact offline root custody and recovery test across Foundation and Second
   Foundation.
3. Exact issuing-intermediate host and protected secret boundary.
4. Provisioner/authentication mechanism and administrator custody.
5. Public trust-anchor distribution and removal procedure for Linux and
   Windows endpoints.
6. CRL/OCSP or explicit homelab revocation publication model.
7. Backup, restore drill, rotation, and decommission owner.

Do not silently collapse root and issuer roles, create an unescrowed root, use
a self-signed leaf, expose a CA administration endpoint publicly, or use public
ACME/DNS credentials.

