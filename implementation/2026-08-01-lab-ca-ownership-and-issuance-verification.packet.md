# Lab CA ownership and issuance verification

Status: read-only verification complete  
Baseline: `7da0275b7b640f7c033950d0b2cb78ba405cc877`

## Boundary

This packet searched committed Infrastructure, Foundation, network-cp,
hypervisor-control, and mail-core doctrine and performed a filename-only/public
certificate inventory on the two approved mounted Foundation vaults. It did not
read private keys, encrypted payloads, or unrelated credential contents.

No certificate or key was created, copied, issued, installed, or exposed. No
trust store, listener, service, DNS, vault, or network state was changed.

## Evidence hierarchy and result

Current committed doctrine repeatedly selects a private lab CA as the desired
TLS model, manual trust installation on approved clients, and no public ACME.
It does not identify an operating X.509 CA owner, root/intermediate subject or
fingerprint, issuer host, issuance tool/API, protected leaf-key exchange,
renewal owner, or revocation procedure.

Committed SSH CA doctrine and public SSH CA keys were found. Those establish an
SSH certificate authority only and cannot establish an X.509 TLS issuer for
`mail.home.arpa`.

The approved filename-only vault search found no `.crt`/`.cer` trust anchor or
other public file identified as the lab-mail X.509 CA. Files with private-key
suggestive names were not opened. No `step-ca`, Smallstep client, `cfssl`, or
Easy-RSA executable or managed issuer service was identified on ws-matriarch.

## Required outcomes

| Requirement | Result |
| --- | --- |
| Authoritative CA owner | unresolved |
| Root/intermediate subject and non-secret fingerprints | not established |
| Reviewed issuance interface | not established |
| Issuance host/protected environment | not established |
| CA private key excluded from mail-core/bundles | required, but no CA path exists to verify operationally |
| Public trust certificate for bundles | not identified |
| Leaf request | `DNS:mail.home.arpa`, 180 days, renewal review 30 days before expiry |
| Leaf private-key generation/ownership | unresolved; must remain on or be delivered directly to mail-core through a protected path |
| Secure transfer and installation | unresolved |
| Revocation/rollback | unresolved |
| Renewal responsibility | unresolved |
| Common trust anchor for all seven endpoints | unproven |

## Disposition

No existing approved X.509 private lab CA is established by current committed
or approved read-only evidence. The construction-CA design is therefore a
separate proposal and grants no CA-creation authority.

`NO EXISTING APPROVED CA FOUND`

