# CA custody, mail leaf, and DNS gate result

Date: 2026-08-01  
Mail-core starting commit: `06f3f7afebe908284a703e8e34ec89f53f1f621d`

## CA custody

Both verified encrypted CA custody packages were copied independently to
Foundation and Second Foundation under the bounded `credentials/helix-pki`
namespace. Source and both destination SHA-256 values matched before and after
each filesystem returned to read-only.

After leaf issuance changed the issuing database, a versioned post-leaf
encrypted issuing-state package was also placed and verified independently on
both vaults. The original pre-leaf package was preserved. Both Foundation
filesystems ended read-only. No plaintext CA key entered either vault or
ordinary host storage.

## mail.home.arpa leaf

The ECDSA P-256 server key was generated inside `mail-core-9000` at the
protected Stalwart TLS path, owned by `stalwart:stalwart`, mode 0600. It never
left the guest. Only the verified CSR entered the offline issuer.

Helix PKI issued serial `2000` for exactly `DNS:mail.home.arpa`, CA false,
digital-signature key usage, TLS server-authentication EKU, and 180-day
validity. The leaf chains through the Helix Lab TLS Issuing CA to the Helix Lab
X.509 Root CA and matches the guest-retained key. The public leaf and chain are
installed in the guest. No listener was enabled.

Helix PKI public issuance commit: `417a185`.

## Collision and DNS source

The immediate `.199` collision preflight passed. The only ARP/local-neighbor
claim matches VM 9000's sole `br-lab10` NIC. No DHCP pool, lease, RouterOS
interface, existing forward DNS answer, reverse DNS answer, or committed
conflicting allocation was found.

A clean Infrastructure worktree committed the single authoritative source row:

```text
mail.home.arpa -> 192.168.100.199
```

Infrastructure source commit: `ca48ed3`.

## DNS deployment blocker

The required network-cp sequential deployment path stopped before mutation:

- `ws-lore-agent` cannot reach `hv-lore` on documented SSH ports 22 or 69;
- `hv-katra:22` is reachable but presents a host key different from the pinned
  strict-trust record;
- no independent committed fingerprint authorizes replacing that record.

No DNS apply, resolver restart, direct resolver edit, SSH trust change, or
network repair occurred. The sanitized network-cp record is commit `2f68184`.

Authenticated Lab-10 submission/IMAPS, nine identity additions, bundle
generation, bundle custody placement, endpoint enrollment, and soak start are
blocked behind DNS acceptance and were not attempted.

`SOAK_STATUS=NOT_STARTED`
