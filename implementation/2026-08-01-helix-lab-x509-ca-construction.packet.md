# Helix Lab X.509 CA construction

Status: stage 1 authorized; stages 2–6 require separate authorization  
Control workspace: `/home/louis/helix-arpa/helix-pki`  
Requested leaf identity: `DNS:mail.home.arpa`

## Boundary and separation

This packet creates and locally verifies a new offline X.509 root and issuing
intermediate. It does not reinterpret the SSH CA, operate a CA daemon, publish
DNS, touch endpoint trust, issue the mail leaf, enable Stalwart TLS listeners,
modify identities/Fastmail, write either Foundation vault, or start soak.

Stages remain separate:

1. CA construction and local verification — authorized here.
2. Temporary writable remount of both Foundation vaults — not authorized.
3. Dual encrypted CA custody placement — not authorized.
4. Guest-local leaf-key/CSR generation, offline signing, and installation — not authorized.
5. Endpoint trust installation — not authorized.
6. Stalwart internal TLS listener activation — not authorized.

## Fixed CA profile

| Authority | Subject CN | Algorithm | Validity | Constraints | Key usage |
| --- | --- | --- | --- | --- | --- |
| Root | `Helix Lab X.509 Root CA` | ECDSA P-256 | 3653 days (2026–2036 ten-year interval) | critical `CA:TRUE,pathlen:1` | critical `keyCertSign,cRLSign` |
| Issuer | `Helix Lab TLS Issuing CA` | ECDSA P-256 | 1096 days (2026–2029 three-year interval) | critical `CA:TRUE,pathlen:0` | critical `keyCertSign,cRLSign` |

The root signs only the issuing intermediate. The issuing intermediate signs
private-lab TLS leaves. Neither CA certificate carries a server SAN or server
authentication EKU.

## Workspace ownership

`helix-pki` is the permanent non-secret control repository because no existing
Infrastructure/security repository has a clean, established X.509 authority
location. It contains doctrine, public certificates, public CRLs, sanitized CA
database/state, issuance manifests, procedures, and validators.

It excludes `private/`, plaintext or encrypted private keys, decrypted custody
packages, age identities/recipients, private CSRs before review, and runtime
secret state. Encrypted custody packages are staged under ignored mode-0700
`helix-pki/private/custody/` until separately authorized placement.

## Secret-safe construction

Preflight:

- confirm mail-core is at the authorized clean commit;
- require OpenSSL 3.x and age 1.x;
- require `/dev/shm` to be writable tmpfs;
- require the approved Matriarch age identity to be a regular mode-0600 file;
- derive its recipient into a mode-0600 tmpfs file without displaying it;
- require both Foundation mounts to remain untouched by this stage.

Use a fresh `/dev/shm/helix-pki.XXXXXX` directory, mode 0700, `umask 077`, and
a cleanup trap. Generate both EC private keys there. Never enable shell tracing
or print commands containing protected paths/state.

Create an OpenSSL root database with `index.txt`, `serial`, `newcerts/`, and a
root policy/config. Self-sign the root with the exact profile. Generate the
issuer key and CSR, then sign it through `openssl ca` so the root database
records the only root-issued certificate.

Create the issuing database with `index.txt`, `serial`, `crlnumber`,
`newcerts/`, an empty issued-leaf manifest, revocation log, and an initial
public CRL. No leaf is issued in stage 1.

Encrypt the root and issuer private keys individually to the protected derived
age recipient. Create two custody packages:

```text
helix-lab-x509-root-ca-custody.tar.gz.age
helix-lab-tls-issuing-ca-custody.tar.gz.age
```

Each outer archive is also age-encrypted. The root package contains its
age-encrypted key, public certificate, root issuance database, OpenSSL config,
and manifest. The issuer package contains its age-encrypted key, public
certificate/chain/CRL, issuing database/config, manifest, renewal procedure,
and revocation procedure. No plaintext key enters an archive.

Verify both outer archives by decrypting and extracting only in a second
mode-0700 tmpfs directory; verify internal manifests; decrypt each inner key
only in tmpfs; compare its derived public key with its certificate; then remove
all verification plaintext through the cleanup trap.

Copy only the two verified ciphertext packages to the ignored protected
staging directory. Copy public artifacts and sanitized public state to the
tracked workspace. Do not copy the derived recipient or any key.

## Public artifacts

Produce:

```text
public/helix-lab-x509-root-ca.crt
public/helix-lab-tls-issuing-ca.crt
public/helix-lab-tls-chain.crt
public/helix-lab-tls-issuing-ca.crl
state/root/index.txt
state/root/serial
state/root/certs/
state/issuing/index.txt
state/issuing/serial
state/issuing/crlnumber
state/issuing/certs/
state/issued-certificate-manifest.json
state/revocations.log
docs/ISSUANCE.md
docs/RENEWAL.md
docs/REVOCATION.md
evidence/2026-08-01-ca-construction.md
```

The evidence records certificate subject, issuer, serial, UTC validity,
public-key algorithm/curve, basic constraints, key usage, SHA-256 certificate
fingerprint, archive filename/SHA-256, OpenSSL/age versions, and verification
status. It contains no recipient, private-key hash, secret path beyond the
approved generic custody interface, or raw vault identifier.

The root certificate is the sole trust anchor for onboarding bundles. The
issuer is chain material only and must never be installed as an independent
trust root.

## Future mail leaf request

Stage 4 must generate an ECDSA P-256 key inside `mail-core-9000` under protected
Stalwart TLS storage, owned by `stalwart`, mode 0600. The key never leaves the
guest. Its CSR contains exactly `DNS:mail.home.arpa`; subject CN may match that
name but the SAN is authoritative.

The issuing profile is critical `CA:FALSE`, TLS server authentication EKU,
digital-signature key usage, 180-day validity, and renewal review 30 days
before expiry. Only the CSR enters the offline workflow. Only the leaf,
issuing certificate, and public chain return to the guest. CA state never
stores a leaf private key.

## Stage-1 verification

Require:

1. root self-signature and `pathlen:1`;
2. issuer signature under root and `pathlen:0`;
3. both keys are prime256v1/P-256 ECDSA;
4. root database contains exactly the issuer certificate and no leaf;
5. issuing database has no issued leaf;
6. chain verification succeeds;
7. initial CRL verifies under the issuer;
8. public outputs contain no private-key PEM marker;
9. both custody packages decrypt, verify, and contain only expected entries;
10. inner encrypted keys decrypt only in tmpfs and match their certificates;
11. no plaintext private key remains outside the active tmpfs construction
    directory before cleanup or anywhere afterward;
12. both Foundation filesystems retain their exact pre-state and receive no
    write.

## Failure and rollback

Before publishing the new public workspace commit, any failed construction is
discarded completely: cleanup tmpfs, remove only the new incomplete
`helix-pki` workspace/staging files, and retain no CA claim. After successful
public commit, correction creates a separately versioned replacement CA; do not
silently overwrite or reinterpret an issued authority. No vault rollback is
needed in stage 1 because vault writes are prohibited.

Final stage-1 disposition is exactly one of:

```text
HELIX LAB CA CREATED — CUSTODY PLACEMENT REQUIRED
CORRECTION REQUIRED
BLOCKED — OPERATOR INPUT REQUIRED
```
