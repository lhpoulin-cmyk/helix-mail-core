# Machine mail enrollment and bundle packet

Status: rendered, blocked at DNS/TLS and protected-vault write gates  
Baseline: `372b5642511747065bff82f3e68ca99ab3100cec`  
Service: `mail.home.arpa` / `192.168.100.199`

## Purpose and authority

Provision exactly seven machine mailboxes, generate one secret-safe onboarding
bundle per machine, place independently verified encrypted copies on both
Foundation vaults, test each physical endpoint, and declare the two-week soak
only after every gate passes.

This packet does not authorize public SMTP, public administration/JMAP, POP3,
ManageSieve, Fastmail, external delivery, ACME/public certificates, PTR
publication, RouterOS/bridge redesign, new identities beyond the seven below,
promotion, or `APPLIANCE_EXPORT_REFERENCE` work.

## Fixed identities and archive names

| Identity | Archive |
| --- | --- |
| `hv-lore@home.arpa` | `hv-lore-mail-onboarding.tar.gz.age` |
| `hv-katra@home.arpa` | `hv-katra-mail-onboarding.tar.gz.age` |
| `hv-matrix@home.arpa` | `hv-matrix-mail-onboarding.tar.gz.age` |
| `ws-matriarch@home.arpa` | `ws-matriarch-mail-onboarding.tar.gz.age` |
| `ws-alpha@home.arpa` | `ws-alpha-mail-onboarding.tar.gz.age` |
| `ws-hadrian@home.arpa` | `ws-hadrian-mail-onboarding.tar.gz.age` |
| `ws-wowzerwin@home.arpa` | `ws-wowzerwin-mail-onboarding.tar.gz.age` |

Each identity receives a separately generated cryptographically random secret.
No construction administrator, guest login, recovery, test-user, Fastmail, or
other machine credential may be reused.

## Mandatory predecessor gates

Before identity or final-bundle work:

1. Complete the reviewed collision preflight for `192.168.100.199`.
2. Publish only `mail.home.arpa -> 192.168.100.199` through the clean
   Infrastructure source of truth and reviewed sequential resolver deployment.
3. Prove both resolvers return the same answer. Do not invent a PTR.
4. Prove an existing approved private-CA owner, issuance interface, protected
   key-delivery path, client trust path, renewal owner, and revocation/rollback
   procedure. Do not create a CA.
5. Issue and install a trusted leaf containing `DNS:mail.home.arpa`.
6. Enable only authenticated TLS-required submission on
   `192.168.100.199:587` and IMAPS on `192.168.100.199:993` while keeping
   management/JMAP loopback-only and port 25 disabled.
7. Complete trusted real-client TLS, delivery, retrieval, restart, reboot,
   relay-rejection, and listener-boundary acceptance.

Bundles assembled before these gates must say `NOT READY FOR MACHINE
ENROLLMENT` and must be regenerated or finalized afterward.

## Foundation custody evidence and unresolved write gate

Observed mounted destinations:

```text
Foundation:        /run/media/louis/LAB_ROOT_TRUST/credentials
Second Foundation: /run/media/louis/FOUNDATION-2/credentials
```

They are distinct ext4 filesystems over distinct LUKS mappings. Both were
observed mounted read-only. Their contents must not be inventoried beyond the
approved mail-onboarding target and non-secret verification metadata.

The primary vault's non-secret README identifies the existing Matriarch
SOPS/age recovery identity at:

```text
/run/media/louis/LAB_ROOT_TRUST/age/lab-root-trust.agekey
```

Use it only through a protected local process. Derive the public recipient
without printing it and keep it in a mode-0600 private runtime file. Never put
the identity, derived recipient, or decryption output in Git, chat, logs,
evidence, argv, or ordinary environment files.

Before placement, render and separately review the exact writable access
procedure for both already mounted vaults. The write window must identify each
filesystem by its observed stable identity, make only the machine-mail target
directory writable, copy only the seven approved ciphertext archives, sync and
verify, then return each vault to its prior read-only state. Do not remount,
unlock, rename, provision, or reinterpret either vault without that review.

## Protected assembly

Use the approved hidden secret-generation workflow in a fresh ignored local
directory mode 0700. Credential files are mode 0600. Generate each secret from
the operating system CSPRNG, never expose it on argv/stdout, and provide it to
Stalwart and bundle renderers through protected files or stdin.

Each machine staging tree contains exactly:

```text
README.md
identity.env
client-settings.md
smtp-settings.conf
imap-settings.conf
ca/lab-mail-ca.crt
tests/mail-connectivity-check
manifest.json
checksums.sha256
secrets/credential
```

Optional `systemd/`, `linux/`, `windows/`, or `powershell/` examples may be
included only when applicable and secret-free. Every configuration records:

```text
MAIL_IDENTITY=<machine>@home.arpa
MAIL_USERNAME=<machine>@home.arpa
MAIL_HOST=mail.home.arpa
MAIL_IPV4=192.168.100.199
MAIL_SUBMISSION_PORT=587
MAIL_SUBMISSION_TLS=required
MAIL_IMAPS_PORT=993
MAIL_IMAPS_TLS=implicit
```

No bundle may contain a CA private key, recovery secret, another machine's
credential, Fastmail credential, guest-login credential, or unrelated secret.

Build a temporary plaintext `tar.gz` only inside the protected assembly
directory, encrypt it immediately with the verified existing age recipient,
verify decryption into a separate mode-0700 directory, validate manifest and
checksums, and securely remove ordinary plaintext assembly/archive residues.
Do not claim physical secure erasure on copy-on-write or journaled media.

## Identity provisioning

Inside the already accepted isolated recovery namespace:

1. describe the live Stalwart v0.16.15 schema;
2. snapshot non-secret existing object identities;
3. render exactly seven Account additions with credential placeholders;
4. prove the seven protected credentials are pairwise distinct without
   emitting their values or hashes;
5. run `stalwart-cli apply --dry-run` through the protected CLI interaction;
6. require seven creates, no updates/deletes, and no unrelated objects;
7. apply only after review, then remove recovery access and namespace state;
8. prove postmaster, cluster-admin, and both test identities are unchanged.

## Archive encryption and dual placement

For every exact archive name:

1. verify source ciphertext decryption and internal checksums in isolation;
2. compute its SHA-256 without printing unrelated paths or content;
3. copy it independently to the reviewed machine-mail directory on Foundation;
4. copy it independently to the reviewed directory on Second Foundation;
5. sync each destination and hash each copy;
6. require source, Foundation, and Second Foundation hashes to match;
7. restore both vaults to read-only and prove that state;
8. remove decrypted test trees and all plaintext staging material.

Record only archive name, SHA-256, non-disclosive destination reference,
placement timestamp, and verification status. Repository files must not record
secret values, private vault device identifiers, or protected key paths beyond
the already reviewed local interface above.

## Endpoint enrollment tests

Test from each named physical machine over the trusted internal path. For each:

1. verify the CA chain and `DNS:mail.home.arpa` SAN;
2. authenticate only as its own identity over submission TLS;
3. submit a uniquely tagged local-only message to an approved local recipient;
4. receive a local reply in the machine mailbox;
5. retrieve it through IMAPS with certificate verification enabled;
6. reject a fake external recipient at RCPT before message DATA;
7. prove another machine's credential cannot authenticate as this identity;
8. verify the mailbox after Stalwart restart and guest reboot.

Never send to a real external recipient. Tests and logs must redact credentials,
AUTH payloads, tokens, and message bodies. An unavailable physical endpoint is
`GENERATED — ENDPOINT TEST PENDING` and blocks soak start.

## Verification and result

Independently prove:

- exactly seven new identities and seven distinct protected credentials;
- all final bundles have accepted DNS, ports, TLS, and CA information;
- no plaintext credential/archive residue exists in scoped staging locations;
- both verified ciphertext copies exist for all seven archives;
- all physical endpoint tests pass;
- external relay, Fastmail, and public listeners remain disabled;
- Stalwart data remains on `/srv/stalwart` and survives restart/reboot;
- no unrelated DNS, RouterOS, bridge, firewall, libvirt, or storage mutation.

Write the sanitized factual result to
`evidence/2026-08-01-machine-mail-enrollment-result.md`. Update
`docs/soak-start-manifest.md` with archive hashes and all seven statuses.

Declare the exact soak start timestamp only when every machine is `ENROLLED AND
VERIFIED`. Any missing identity, distinct credential, archive, vault copy,
matching hash, decryption/checksum test, accepted CA/configuration, endpoint
test, authentication, local delivery/retrieval, persistence test, DNS/TLS gate,
or listener/relay safety check leaves `SOAK_STATUS=NOT_STARTED`.

## Rollback and stop conditions

Before identity apply, retain the prior sanitized object inventory. On failure,
stop exposure, remove only newly added Lab-10 TLS listeners if necessary, and
leave mailbox identities/data intact until a separately reviewed deletion
packet exists. Revert DNS only through its authoritative source and sequential
deployment procedure. Revoke/reissue a leaf only through the approved CA
owner. Never delete mail or credentials as an implicit rollback.

Stop for unresolved/failed CA issuance, collision, DNS/TLS acceptance, vault
write interface, encryption identity use, physical endpoint access, secret
exposure risk, public/external-mail scope, or any mismatch in the seven exact
identities and archives.

