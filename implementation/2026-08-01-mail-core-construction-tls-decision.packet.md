# Mail-core construction TLS decision

Status: recorded construction decision; no certificate or key issuance authorized
Scope: internal-only construction and soak for `mail.home.arpa`

## Observed internal practice

Current committed Infrastructure service-TLS doctrine for internal services uses
a private lab CA, rejects public ACME/DNS-01 and DNS-provider API tokens, and
limits trust-root installation to approved internal clients. The documented
SSH user CA is a separate authority and must not be reused for X.509/TLS.

The review found no committed, exact server-certificate issuance or renewal
runbook for the private lab CA. Therefore this packet does not name an issuer
command, inspect a CA private key, issue a leaf, or create a key.

## Construction decision

Use a private-lab-CA leaf certificate for `mail.home.arpa` when TLS is enabled
inside the guest. Set a **180-day** validity and create a renewal reminder or
review gate at least **30 days** before expiry. This avoids a two-week
construction certificate becoming an avoidable service-interruption risk if
development or migration takes longer.

The certificate and key must be created only by the later reviewed CA issuance
path, stored only in guest runtime secret paths with restrictive permissions,
and never committed, logged, or copied into host evidence.

## Why this method

- It matches the documented internal-service trust model.
- It avoids public ingress, public ACME, DNS API tokens, and public SMTP.
- It avoids per-client self-signed trust exceptions during a longer soak or
  later hypervisor migration.
- A 180-day leaf with a 30-day renewal gate provides practical continuity
  without treating this construction placement as permanent PKI policy.

## Boundaries and gates

- DNS publication is required before local mail-service acceptance, not before
  VM construction.
- Fastmail remains disabled.
- `APPLIANCE_EXPORT_REFERENCE` remains unresolved and blocks promotion
  readiness, not VM construction.
- Do not enable a TLS listener, issue a certificate, create a key, or add CA
  trust under this packet.
- Before local acceptance, identify the private-CA issuer, SAN/renewal method,
  approved trust clients, key storage path, validation, and rollback/reissue
  procedure in a separate bounded TLS issuance packet.
