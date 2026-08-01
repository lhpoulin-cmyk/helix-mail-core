# Mail-core construction TLS and DNS acceptance packet

Status: rendered proposal only — explicit execution authorization required  
Target: `mail-core-9000` / `mail.home.arpa`

## Accepted inputs

```text
service identity: mail.home.arpa
mail domain:      home.arpa
guest address:    192.168.100.199
DNS primary:      192.168.10.251
DNS mirror:       192.168.10.252
leaf validity:    180 days
review threshold: 30 days before expiry
```

Stalwart v0.16.15 accepts `home.arpa`; the local foundation is active with only
loopback listeners. DNS publication and trusted TLS are required before local
network service acceptance, not for the already completed local-only tests.

## Required evidence before mutation

1. Reconfirm `.199` collision freedom immediately before publication and
   listener activation using RouterOS interface, DHCP pool/reservation/lease,
   ARP, local neighbor, forward/reverse DNS, and committed Infrastructure
   allocation evidence. Stop on conflict without selecting another address.
2. Reconfirm the current Infrastructure-owned `home.arpa` source of truth and
   reviewed sequential replication path. The proposed forward record is only:

   ```text
   mail.home.arpa. A 192.168.100.199
   ```

   Do not publish a PTR unless reverse-zone ownership and mutation are
   separately established.
3. Identify and prove the approved existing private lab CA, issuer identity,
   trust distribution, certificate profile, protected key-delivery path, and
   revocation/reissue procedure. Stop rather than creating a new trust root.

## Proposed bounded mutations

After separate operator review, issue one leaf certificate containing exactly
`DNS:mail.home.arpa`, with 180-day validity and renewal review beginning 30 days
before expiry. Keep the private key root-owned, mode 0600, outside Git. Verify
chain, SAN, key match, validity, and trust from each approved construction
client.

Publish the single forward record through the confirmed Infrastructure source
of truth, run its reviewed one-way sequential sync, and verify identical answers
from `192.168.10.251` and `192.168.10.252`. Record exact rollback. Do not edit
generated runtime hosts files directly.

Only after certificate and DNS verification, add:

- authenticated submission on `192.168.100.199:587` with TLS required;
- IMAPS on `192.168.100.199:993` with implicit TLS;
- the certificate selected as Stalwart's reviewed default/SNI certificate.

Keep management/JMAP loopback-only. Keep port 25, POP3, ManageSieve, public
HTTP/JMAP, ACME, automatic DNS, direct external delivery, Fastmail, and public
SMTP disabled. Preserve the mount guard and existing loopback listeners until
the TLS endpoints pass acceptance.

## Verification

Validate DNS consistency, certificate chain/SAN/expiry, exact listener binds,
TLS versions, absence of plaintext authentication, authenticated local delivery
and IMAPS retrieval from a controlled client, message persistence, external
recipient rejection at RCPT, mount/data placement, and guest/host health. Use
no real external recipient.

## Rollback

Remove only the new Lab-10 listener objects, restore the prior certificate
selection, revoke/reissue the leaf if key safety is in doubt, and revert the
single forward record through the same authoritative repository/sync path.
Never remove the local domain, identities, or stored local test evidence as an
implicit rollback.

## Prohibited actions

This packet does not authorize execution, a new CA, PTR publication, RouterOS or
firewall changes, Fastmail, port 25, public exposure, soak declaration,
production promotion, or `APPLIANCE_EXPORT_REFERENCE` selection.
