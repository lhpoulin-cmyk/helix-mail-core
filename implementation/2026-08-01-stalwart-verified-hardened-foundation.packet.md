# Stalwart verified hardened local-foundation packet

Status: rendered, staged — explicit review required before manual installation
Target: `mail-core-9000`; service identity: `mail.home.arpa`
Authorization baseline: `19a629f`

## Boundary

This packet replaces the official convenience installer. Never execute that
installer, use a moving `latest` URL, container image, musl build, other
release, or unofficial mirror. Keep Fastmail, external relay, port 25, public
HTTP/JMAP, public DNS automation, ACME, POP3, and ManageSieve disabled. Do not
change DNS, RouterOS, NetworkManager, firewall, libvirt, guest networking,
credentials outside this packet, or promotion state.

The sequence is gated:

1. verified artifacts and verifier;
2. manual binary/account/path installation;
3. hardened unit installed disabled and stopped;
4. fail-closed mount test;
5. localhost-only recovery schema capture and declarative dry run;
6. explicit review of the rendered private plan;
7. TLS issuance gate;
8. recovery apply, removal of recovery access, normal local-only activation;
9. local acceptance tests.

Passing one phase never authorizes skipping a later gate. No credential-bearing
listener may bind to `192.168.100.199` before trusted TLS exists.

## Immutable server artifact

```text
release:       v0.16.4
target:        x86_64-unknown-linux-gnu
asset:         stalwart-x86_64-unknown-linux-gnu.tar.gz
URL:           https://github.com/stalwartlabs/stalwart/releases/download/v0.16.4/stalwart-x86_64-unknown-linux-gnu.tar.gz
size:          37612912 bytes
SHA-256:       38d9be6707e603d80e50ce81c58ff24273f8e19a30f7ba1efb6983cb8ed8bf8a
bundle:        stalwart-x86_64-unknown-linux-gnu.tar.gz.sigstore.json
bundle URL:    https://github.com/stalwartlabs/stalwart/releases/download/v0.16.4/stalwart-x86_64-unknown-linux-gnu.tar.gz.sigstore.json
bundle size:   10576 bytes
bundle SHA-256:0e55b74b0635c9abc0484df8bbf7fa7245c70f2177ef851f0cdb3d188fe5719f
identity:      https://github.com/stalwartlabs/stalwart/.github/workflows/ci.yml@refs/tags/v0.16.4
OIDC issuer:   https://token.actions.githubusercontent.com
workflow SHA:  0513f5fe5751bee31f00f5c6732db91d9f8a7712
```

Acquisition occurred on 2026-08-01 from those exact official URLs. GitHub API
metadata and local size/digest checks passed. Debian `cosign` 2.5.0-2+b4 then
verified the v0.3 bundle offline with exact identity and issuer; its embedded
SCT and one transparency-log entry were not bypassed:

```sh
cosign verify-blob \
  --new-bundle-format \
  --offline \
  --bundle stalwart-x86_64-unknown-linux-gnu.tar.gz.sigstore.json \
  --certificate-identity 'https://github.com/stalwartlabs/stalwart/.github/workflows/ci.yml@refs/tags/v0.16.4' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  stalwart-x86_64-unknown-linux-gnu.tar.gz
```

The protected archive contains exactly one regular relative entry named
`stalwart`; no traversal, absolute path, device, or unrelated payload exists.
The extracted temporary binary reports `0.16.4`.

## Verifier transaction

The configured Debian 13 repositories supplied `cosign` 2.5.0-2+b4. The exact
simulation and completed transaction contained one new package, zero upgrades,
zero removals, and zero downgrades. Stop on any future transaction drift; do
not add a repository.

## Immutable CLI artifact

The server archive does not contain `stalwart-cli`. The separately verified
official CLI pin is:

```text
release:       stalwartlabs/cli v1.0.12
target:        x86_64-unknown-linux-gnu
asset:         stalwart-cli-x86_64-unknown-linux-gnu.tar.xz
URL:           https://github.com/stalwartlabs/cli/releases/download/v1.0.12/stalwart-cli-x86_64-unknown-linux-gnu.tar.xz
size:          2285984 bytes
SHA-256:       e2bb054509aaac311f13ff4f9e09c38c607195de2e9735cf84cfc6ee4776a5a2
identity:      https://github.com/stalwartlabs/cli/.github/workflows/release.yml@refs/tags/v1.0.12
OIDC issuer:   https://token.actions.githubusercontent.com
workflow SHA:  ecc8674fe1c8394b43225c4b307ebba87a11c8e0
```

GitHub artifact-attestation verification for repository `stalwartlabs/cli`
passed and bound the digest, tagged workflow identity, source commit, and
GitHub-hosted builder. The archive contains one directory with the binary plus
README and CHANGELOG; install only the binary. It reports
`stalwart-cli 1.0.12`. Never execute its moving installer.

## Immediate installation preflight

Reconfirm clean authorized repository state, domain identity, autostart
disabled, host health, and `/srv/stalwart` mounted from `/dev/vdb1` with XFS
label `stalwartdata`. Locally correlate its UUID to fstab without recording it.
Require all proposed paths, account, unit, and listeners to be absent:

```sh
set -eu
mountpoint -q /srv/stalwart
test "$(findmnt -bnro SOURCE /srv/stalwart)" = /dev/vdb1
test "$(findmnt -bnro FSTYPE /srv/stalwart)" = xfs
test "$(blkid -s LABEL -o value /dev/vdb1)" = stalwartdata
test ! -e /var/lib/stalwart
test ! -e /usr/local/bin/stalwart
test ! -e /usr/local/bin/stalwart-cli
test ! -e /etc/stalwart
test ! -e /etc/systemd/system/stalwart.service
! getent passwd stalwart
! systemctl is-enabled stalwart.service
! systemctl is-active stalwart.service
test -z "$(ss -lntH | grep -E ':(25|443|465|587|993|8080)[[:space:]]' || true)"
```

Reverify both protected artifacts immediately before installation using their
full digests and attestations. Stop on any mismatch.

## Exact manual installation

Use protected, already verified temporary extraction directories. Do not run
either installer script.

```sh
set -eu
useradd --system --user-group --no-create-home \
  --home-dir /nonexistent --shell /usr/sbin/nologin stalwart

install -d -o root -g stalwart -m 0750 \
  /etc/stalwart /etc/stalwart/tls /etc/stalwart/secrets
install -d -o stalwart -g stalwart -m 0750 \
  /srv/stalwart/data /srv/stalwart/blobs \
  /srv/stalwart/log /srv/stalwart/tmp

install -o root -g root -m 0755 \
  VERIFIED_SERVER_EXTRACT/stalwart /usr/local/bin/stalwart
install -o root -g root -m 0755 \
  VERIFIED_CLI_EXTRACT/stalwart-cli /usr/local/bin/stalwart-cli

printf '%s\n' '{"@type":"RocksDb","path":"/srv/stalwart/data"}' \
  > /etc/stalwart/config.json
chown root:stalwart /etc/stalwart/config.json
chmod 0640 /etc/stalwart/config.json

install -o root -g root -m 0644 \
  REPOSITORY_RENDER/provisioning/guest/stalwart.service \
  /etc/systemd/system/stalwart.service
systemctl daemon-reload
systemctl disable stalwart.service
systemctl stop stalwart.service
```

Render the concrete protected extraction paths and repository source path
before execution; placeholders above must never reach a shell. Verify binary
versions, passwd/group properties, directory ownership/modes, JSON equality,
unit syntax, `systemd-analyze security`, and disabled/inactive service state.
The official schema confirms `config.json` is exactly one `DataStore` object;
the `RocksDb` variant requires `path`.

## Mount guard and safe failure test

The tracked unit includes `RequiresMountsFor=/srv/stalwart`,
`ConditionPathIsMountPoint=/srv/stalwart`, and
`ExecStartPre=/usr/bin/mountpoint -q /srv/stalwart`. It grants no capability;
ports 587, 993, and 8080 are unprivileged. `ProtectSystem=strict` combines with
`ReadWritePaths` limited to the four approved `/srv/stalwart` state paths.

Before any Stalwart start and while the data paths are empty:

1. prove the service is stopped and no process uses the mount;
2. unmount `/srv/stalwart`;
3. runtime-mask `srv-stalwart.mount` so `RequiresMountsFor` cannot restore it;
4. attempt `systemctl start stalwart.service` and require failure;
5. prove no `/srv/stalwart/data` was created on the root filesystem and no
   Stalwart process/listener exists;
6. remove only the runtime mask, daemon-reload, mount `/srv/stalwart`, and
   reverify UUID correlation and directory state.

Any failure to restore the mount stops the packet. Never enable the service in
this test.

## Recovery secret and local-only start

Use the `operator-secret-entry` skill to collect one random recovery password
through a hidden local TTY prompt. Store it only under ignored mode-0700 private
state with mode 0600. Render `/etc/stalwart/stalwart.env` as root:root 0600 with:

```text
STALWART_RECOVERY_MODE=true
STALWART_RECOVERY_MODE_PORT=8080
STALWART_RECOVERY_ADMIN=admin:<PRIVATE_VALUE>
```

Do not print or log the value. Start the disabled unit manually and prove
recovery mode runs no mail/background services. The management socket must be
loopback-only. If v0.16.4 binds recovery port 8080 beyond loopback and no
documented bind control exists, stop and do not change firewall policy. Prove
connection to `192.168.100.199:8080` fails.

## Schema-derived declarative plan gate

Install no declarative configuration from remembered field names. With the
recovery endpoint local-only, run `stalwart-cli describe` interactively so the
password is entered only at the hidden TTY prompt. Capture and sanitize the
v0.16.4 schema. Render a private plan and a Git-safe placeholder template that
upserts only:

- hostname `mail.home.arpa` and local domain `home.arpa`;
- DataStore/default single-node roles rooted at `/srv/stalwart/data`;
- filesystem BlobStore rooted at `/srv/stalwart/blobs`;
- logging rooted at `/srv/stalwart/log`;
- loopback-only management/JMAP;
- after TLS only, authenticated submission on `192.168.100.199:587` and IMAPS
  on `192.168.100.199:993`;
- disabled port 25, POP3, ManageSieve, external relay, Fastmail, ACME, and DNS
  automation;
- only `postmaster@home.arpa`, `cluster-admin@home.arpa`,
  `test-sender@home.arpa`, and `test-receiver@home.arpa`.

Generate one distinct credential per identity with hidden prompts/private state.
Run `stalwart-cli apply --dry-run --file PRIVATE_PLAN`, review the complete
sanitized semantic diff, commit the schema evidence and placeholder plan, and
stop for operator review before real apply. Never put a credential in CLI
arguments, environment, Git, logs, or evidence.

## TLS gate and normal activation

The private-lab-CA issuance path is not currently proven in this repository.
After the stopped hardened service and declarative plan are reviewed, issue:

```text
TLS ISSUANCE REQUIRED
```

unless a separately reviewed CA packet supplies a 180-day leaf for
`DNS:mail.home.arpa`, protected key paths, trust rollout, validation, renewal
review 30 days before expiry, and rollback/reissue procedure. Do not create a
trust root here and do not enable credential-bearing remote listeners first.

After trusted TLS and plan approval, apply through localhost recovery mode,
remove `STALWART_RECOVERY_ADMIN` and all recovery-mode variables, stop the
service, prove the environment file contains no recovery access, and start
normally. Keep the unit disabled during construction unless separately
authorized.

## Acceptance

Run all 17 operator-required tests. Use only the two disposable identities for
delivery/retrieval, never a real external recipient. Verify persistence across
service restart and guest reboot, rejected external relay, Fastmail disabled,
no port 25/public listener, and all authoritative state under the mounted
`/srv/stalwart`. Reconfirm DNS, RouterOS, host networking, libvirt, and VM
autostart are unchanged.

End with exactly one disposition:

```text
STALWART LOCAL FOUNDATION ACCEPTED
CORRECTION REQUIRED
BLOCKED — OPERATOR INPUT REQUIRED
```
