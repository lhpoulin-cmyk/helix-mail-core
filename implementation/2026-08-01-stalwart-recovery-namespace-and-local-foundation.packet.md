# Stalwart recovery namespace and local-foundation continuation

Status: authorized continuation from `cd301e8`; execution is phase-gated

Target: `mail-core-9000` / `mail.home.arpa`  
Permanent unit: `/etc/systemd/system/stalwart.service` (accepted; do not replace)  
Persistent root: `/srv/stalwart` mounted from the accepted `/dev/vdb1` XFS filesystem

## Boundary

Complete v0.16.4 schema discovery and the smallest local-only mail foundation
without exposing recovery administration. Do not change DNS, firewall,
RouterOS, NetworkManager, libvirt, host storage, guest addressing, TLS trust,
Fastmail, public SMTP, or public administration. Do not send external mail.

The accepted Stalwart server v0.16.4 and CLI v1.0.12 binaries are the only
executables authorized. Do not download or run an installer.

## Preflight

Require repository HEAD `cd301e8` and a clean worktree before this packet is
committed. Immediately before guest mutation verify:

- `mail-core-9000`, guest and mount identity, capacity, SSH, sudo, and guest
  agent remain healthy;
- `/usr/local/bin/stalwart --version` is `0.16.4` and
  `/usr/local/bin/stalwart-cli --version` is `1.0.12`;
- `/srv/stalwart` is the accepted UUID-backed `/dev/vdb1` XFS mount;
- `/var/lib/stalwart` is absent and the four approved state directories are
  empty before first recovery start;
- permanent `stalwart.service` is disabled, inactive, and unchanged from the
  committed unit;
- no port 25, 587, 993, or 8080 listener exists.

Stop on material drift.

## Protected private state

Use `/home/louis/.local/share/helix-mail-core/private/stalwart-foundation`, mode
0700, outside Git. Files are mode 0600 and owned by `louis`, except the
root-only transient recovery environment. Generate locally from the kernel CSPRNG:

- one recovery password;
- distinct passwords for exactly postmaster, cluster-admin, test-sender, and
  test-receiver at `home.arpa`.

Never emit secret values. A mode-0700 root-owned helper may read a password file
and answer the CLI's interactive no-echo TTY prompt. Do not put secrets in CLI
arguments, shell history, logs, Git, or evidence. The temporary Stalwart
recovery environment is root-owned mode 0600 and removed before normal start.

## Temporary recovery unit

Install `/run/systemd/system/stalwart-recovery.service` only. It duplicates the
accepted permanent service's user, group, mount guards, filesystem restrictions,
capability bounds, and write paths, but is not installable and adds:

```ini
PrivateNetwork=yes
EnvironmentFile=/run/stalwart-recovery.env
Restart=no
```

The environment contains only the v0.16.4-supported recovery settings and is
created from private state without displaying its contents. Start the temporary
unit manually; never enable it.

Before using its credential, obtain its MainPID and prove from both namespaces:

1. `/proc/<pid>/ns/net` differs from PID 1's network namespace;
2. `nsenter -t <pid> -n ip -brief link` shows only `lo`, up;
3. the namespace has no IPv4/IPv6 default route and no non-loopback address;
4. port 8080 is listening only within that namespace;
5. host-namespace connection to `192.168.100.199:8080` fails;
6. a route lookup for an external address fails inside the namespace;
7. no SMTP, submission, IMAP, POP3, ManageSieve, or external JMAP listener is
   present.

Stop immediately if isolation differs. Do not alter firewall policy.

## Schema and declarative plan

Run the verified CLI inside the service's network namespace with
`nsenter -t <pid> -n`, as `stalwart`, targeting `http://127.0.0.1:8080`.
Supply the recovery password only through an interactive pseudoterminal helper
reading the protected file.

Capture `describe` and the descriptions of the exact object types needed for:

- system hostname and local domain;
- RocksDB/default data roles and filesystem blob storage;
- loopback-only management/mailbox interface usable for acceptance tests;
- the four authorized user accounts and password credentials;
- disabled relay, Fastmail, automatic DNS, and public listeners.

Sanitize schema output and retain it as evidence. Render a private NDJSON plan
using only fields and variants actually reported by v0.16.4. Render a Git-safe
semantic plan with placeholders. Run `stalwart-cli apply --dry-run` inside the
namespace and review every operation before real apply. Use `upsert` for the
domain and accounts and singleton `update` only where the live schema requires
it. Do not use `reconcile` or any operation that can delete unrelated state.

Apply only the reviewed plan. Query/snapshot the four identities and local
domain afterward without displaying password material.

## Recovery teardown and permanent activation

Stop `stalwart-recovery.service`, require its process to exit, remove
`/run/stalwart-recovery.env` and its runtime unit, daemon-reload, and prove:

- the temporary network namespace no longer exists;
- no recovery process or listener remains;
- no recovery variable or credential is referenced by permanent
  `stalwart.service` or `/etc/stalwart/stalwart.env`;
- port 8080 is not exposed through `192.168.100.199`.

Configure normal service listeners only where the schema-supported plan can
keep them loopback-only without trusted TLS. Do not bind submission or IMAPS to
`192.168.100.199`. Keep port 25, Fastmail, external relay, and public
administration disabled. Enable and start the accepted permanent unit only
after teardown checks pass.

## Acceptance

Using loopback-only supported protocols or management operations, test local
authenticated delivery from `test-sender@home.arpa` to
`test-receiver@home.arpa`, retrieve the message, and prove persistence across a
service restart and guest reboot. Test an unmistakably fake external recipient
and require relay rejection without transmitting externally. Verify the four
credentials are distinct using protected hash comparisons that emit only
pass/fail.

Reverify version, mount guard, authoritative paths, absence of
`/var/lib/stalwart`, listeners, relay/Fastmail state, guest health, domain
topology, VM autostart, and host storage/network health. Commit only sanitized
schema, semantic plan, and factual evidence.

If trusted TLS is the only remaining gate for Lab-10 submission/IMAPS, prepare
a separate TLS/DNS acceptance packet and finish with `TLS ISSUANCE REQUIRED`.
Otherwise issue exactly one authorized disposition.

## Rollback and stop conditions

Before declarative apply, rollback is removal of the runtime recovery unit,
environment, and private namespace after stopping its process; the accepted
permanent service remains stopped. After apply, preserve `/srv/stalwart` as
evidence and stop rather than deleting mail state.

Stop for namespace escape, inability to remove recovery access, state outside
`/srv/stalwart`, unsupported schema, credential exposure, destructive
ambiguity, or cross-system/public mutation.
