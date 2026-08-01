# Stalwart verified hardened foundation execution

Date: 2026-08-01  
Authorized repository state: `275883aa1cc916fcc8147d846baad0be0f5e8b94`  
Target: `mail-core-9000` (`mail.home.arpa`)  
Result: **BLOCKED — OPERATOR INPUT REQUIRED**

## Completed preflight

- The repository HEAD and clean worktree matched the authorization before mutation.
- Debian's installed `cosign` package remained version `2.5.0-2+b4`.
- Offline Sigstore verification of the pinned Stalwart server archive passed
  again with the exact v0.16.4 workflow identity and GitHub Actions issuer
  recorded in the packet.
- The server archive and bundle retained their committed sizes and SHA-256
  digests. Safe archive inspection still showed one regular relative payload.
- The extracted server reported `0.16.4`.
- The separately attested CLI retained its committed digest and reported
  `stalwart-cli 1.0.12`.
- `/srv/stalwart` was and remains the accepted XFS filesystem mounted from
  `/dev/vdb1`; its observed UUID correlated with the accepted UUID-backed fstab
  entry. Post-execution available capacity was `202077245440` bytes.
- No pre-existing Stalwart account, installation, unit, listener, configuration,
  or `/var/lib/stalwart` state existed.
- The official convenience installer was not executed and no replacement or
  moving-release artifact was downloaded.

## Authorized mutations completed

- Created system account and group `stalwart` with UID/GID 988, home
  `/nonexistent`, shell `/usr/sbin/nologin`, and no sudo grant.
- Installed the verified server at `/usr/local/bin/stalwart` and the verified
  CLI at `/usr/local/bin/stalwart-cli`, both root-owned mode 0755.
- Created root-owned, `stalwart`-group-readable configuration paths under
  `/etc/stalwart`, including protected `tls` and `secrets` directories.
- Created only `/srv/stalwart/data`, `/srv/stalwart/blobs`,
  `/srv/stalwart/log`, and `/srv/stalwart/tmp` as the writable application
  paths, owned by `stalwart:stalwart` mode 0750.
- Installed the current-schema minimal RocksDB bootstrap configuration at
  `/etc/stalwart/config.json`, pointing to `/srv/stalwart/data`, root-owned and
  mode 0640.
- Installed the repository-rendered hardened unit at
  `/etc/systemd/system/stalwart.service`, reloaded systemd, and left the unit
  disabled and stopped.

No credential or identity was created. No Stalwart datastore was opened.

## Mount-guard verification

With all four data directories empty, the dedicated filesystem was unmounted
and its generated mount unit was runtime-masked. Starting `stalwart.service`
did not activate the service because `ConditionPathIsMountPoint=/srv/stalwart`
was false. systemd reports `ConditionResult=no`; no process, listener, or
fallback state appeared on the guest root filesystem.

The test harness originally expected `systemctl start` itself to return
nonzero. systemd treats a failed `Condition...` as a clean skipped start and
returned zero. This is a representation difference, not a safety failure: the
required semantic invariant held. The runtime mask was removed and the
accepted filesystem was restored successfully before any later step.

Post-test verification found:

- `/srv/stalwart` mounted from `/dev/vdb1` as XFS;
- all approved state directories empty;
- `stalwart.service` disabled, inactive, and `ConditionResult=no` from the
  guarded attempt;
- `/var/lib/stalwart` absent;
- no listeners except the existing SSH service;
- SSH and qemu-guest-agent active.

## Recovery-mode stop

The next authorized phase required the v0.16.4 recovery management socket to
be loopback-only before generating or using a recovery credential. Current
upstream v0.16.4 evidence shows the recovery listener binding to the IPv6
unspecified address (`::`) on port 8080. The documented recovery environment
controls expose enablement, port, and administrator credential, but no supported
bind-address control was established.

The packet explicitly requires a stop when recovery port 8080 binds beyond
loopback and prohibits improvising a firewall change. Therefore recovery mode
was not started. No recovery secret, identity credentials, declarative plan,
domain, or mail listener was created or applied.

A separately reviewed correction is required before provisioning. The narrow
recommended design is a temporary recovery-only systemd network namespace with
only loopback available, plus a reviewed method for running the CLI inside that
same namespace. It must prove `192.168.100.199:8080` unreachable and be removed
before normal activation. This is not authorized by the current unit or packet.

## Boundary and health verification

- Stalwart remains disabled and stopped.
- Fastmail, external relay, public SMTP, submission, IMAPS, JMAP, and recovery
  administration remain inactive.
- No DNS, RouterOS, firewall, NetworkManager, libvirt configuration, VM
  autostart, TLS, or credential mutation occurred.
- `mail-core-9000` remains running with 2 vCPU, 4096 MiB RAM, SELinux enforcing,
  and autostart disabled.
- The host pool filesystem remains mounted from `/dev/nvme1n1p5` with
  `267427844096` bytes available.
- `br-lab10` remains active; `enp7s0` remains its port. The host default route
  remains through `eno1` via `192.168.10.1`.

## Disposition

**BLOCKED — OPERATOR INPUT REQUIRED**
