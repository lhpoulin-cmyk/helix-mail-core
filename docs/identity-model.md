# Identity model

Stalwart is authoritative only for `home.arpa`. The current live population is
thirteen distinct accounts; no account shares a credential with another.

## Operational correspondents

| Role | Identities |
| --- | --- |
| Administrators | `admin@home.arpa`, `cluster-admin@home.arpa` |
| Hypervisors | `hv-lore@home.arpa`, `hv-katra@home.arpa`, `hv-matrix@home.arpa` |
| Workstations | `ws-matriarch@home.arpa`, `ws-alpha@home.arpa`, `ws-hadrian@home.arpa`, `ws-wowzerwin@home.arpa` |

Every identity in the table has a distinct credential. The seven machine
archives and the Admin archive were verified and copied to both Foundation
vaults. The ninth accepted archive belongs to `louis@home.arpa`; the current
manifest does not record a separate Cluster-Admin onboarding archive.
`ws-alpha` and `ws-wowzerwin` remain endpoint-deferred; their accounts and
custody records exist, but their physical clients are not classified as
verified.

The canonical administrative identity is `cluster-admin@home.arpa`. There is
no underscore variant or alias.

## Supporting accounts

- `postmaster@home.arpa` — local postmaster identity;
- `louis@home.arpa` — human mailbox with its own encrypted bundle;
- `test-sender@home.arpa` and `test-receiver@home.arpa` — disposable
  construction acceptance identities.

These are separate mailboxes. In particular, `admin@home.arpa` is not an alias
for `cluster-admin@home.arpa`, and neither shares its credential.

## Delivery rules

Machines may submit local mail to either administrative mailbox. Admin and
Cluster Admin may send to any authorized local mailbox. An `hv-*` or `ws-*`
recipient rejects every other local sender before message data. External relay
is disabled.

The live enforcement combines two controls:

1. submission requires authentication and rejects an account using another
   identity's envelope sender;
2. the `machine-inbound-admin-only` RCPT-stage system Sieve policy accepts only
   the two canonical administrative envelope senders for machine recipients.

Both controls were tested. Weakening sender matching would invalidate the
machine policy even if the Sieve object remained present.

## Credential and bundle rule

Credentials are generated independently and remain in protected state outside
Git. A bundle contains one identity's settings, one credential, the public lab
CA certificate, protocol tests, and checksums. It never contains a CA private
key, recovery credential, guest-login password, Fastmail secret, or another
identity's credential.

Account creation, credential rotation, aliases, and forwarding are bounded
administrative changes. An email requesting one is still just an email.
