# Stalwart recovery namespace execution

Date: 2026-08-01  
Starting commit: `cd301e837d87e4b9225bbce532f92dc8ca13ff6f`  
Target: `mail-core-9000` / `mail.home.arpa`  
Disposition: **BLOCKED — OPERATOR INPUT REQUIRED**

## Repository preparation

The bounded continuation packet was created, reviewed, validated, and committed
as `4517087`. It preserves the accepted permanent unit and uses a temporary
systemd `PrivateNetwork=yes` recovery unit only.

## Recovery isolation

Preflight reconfirmed the pinned server `0.16.4`, CLI `1.0.12`, accepted
`/dev/vdb1` XFS mount, disabled/inactive permanent service, empty initial state
directories, absent `/var/lib/stalwart`, and no mail or recovery listeners.

The temporary recovery process started in a distinct network namespace:

- host namespace: `net:[4026531840]`;
- recovery namespace: `net:[4026532466]`;
- only interface: loopback, up;
- no non-loopback address, veth, bridge, default route, forwarding, NAT, or DNS;
- only listener: port 8080 inside the isolated namespace;
- connection to `192.168.100.199:8080` failed from the ordinary guest
  namespace;
- route lookup to an external documentation address failed inside recovery;
- no SMTP, submission, IMAP, POP3, or ManageSieve listener existed.

The verified CLI entered the same namespace using `nsenter` and supplied the
recovery credential through a protected pseudoterminal. No secret entered an
argument, output, repository file, or evidence record.

## Live schema and reviewed plan

The CLI downloaded the live v0.16.4 management schema. Its sanitized cache had
SHA-256 `d5fca6243afe0bafd4858c01537034e8911bccd80b7a97f4cdee6e7cdada2705`.
Schema discovery confirmed the current forms used by the committed placeholder
plan:

- `Domain` with manual certificate, DKIM, and DNS management and relaying off;
- `SystemSettings.defaultHostname` and `defaultDomainId`;
- RocksDB at `/srv/stalwart/data` and `BlobStore/FileSystem` at
  `/srv/stalwart/blobs`;
- log tracer at `/srv/stalwart/log`;
- loopback-only HTTP, SMTP, and IMAP `NetworkListener` objects;
- `Account/User` with `Credential/Password` and schema-supported User/Admin
  roles.

Four distinct account credentials were generated under protected ignored guest
state. Equality checks passed without emitting values. The declarative plan
dry-run passed:

```text
Plan: 0 destroy, 2 update, 1 create, 3 upsert, 0 reconcile (9 objects)
(dry run: no changes will be made)
```

The plan performs no reconcile or destroy operation. The Git-safe version uses
only explicit placeholders.

## Apply stop

The real apply stopped on its first operation:

```text
Domain: create failed for `dom-home`: invalidPatch | Invalid domain name |
Properties: name
```

The summary reported zero updates, zero creates, and one failure. No Domain,
Account, NetworkListener, Tracer, BlobStore change, or SystemSettings change was
applied. The Stalwart v0.16 upgrade documentation describes this error as the
hostname validator rejecting a domain without a public TLD. That behavior is
materially incompatible with the repository's fixed authoritative domain
`home.arpa`; substituting another domain is not authorized.

## Fail-closed teardown

The recovery service was stopped. The runtime unit, root-only environment, and
transient secret-bearing plan copy were removed, followed by daemon reload.
The temporary recovery password was removed from protected private state so it
cannot be reused accidentally. The four unapplied mailbox construction
credentials remain protected for a future reviewed retry.

Independent verification found:

- permanent `stalwart.service` disabled and inactive;
- no recovery unit, environment, process, namespace, or listener;
- no listener on ports 25, 587, 993, 8080, 1587, or 1143;
- `/var/lib/stalwart` absent;
- accepted permanent unit unchanged;
- `/srv/stalwart` still mounted from `/dev/vdb1`, with `202076061696` bytes
  available;
- SSH and qemu-guest-agent active;
- guest address and default route unchanged;
- VM remains 2 vCPU, 4096 MiB, running, and autostart-disabled;
- Matriarch storage mount, bridge connections, and eno1 default route healthy.

No DNS, RouterOS, firewall, NetworkManager, libvirt, host storage, TLS,
Fastmail, external mail, or public-exposure mutation occurred.

## Required decision

Proceeding requires evidence of a supported Stalwart method or upstream change
that permits the RFC-designated `home.arpa` local domain, or an explicit
operator-approved architectural change. The agent must not bypass domain
validation, patch the binary, or substitute a public-style domain silently.

**BLOCKED — OPERATOR INPUT REQUIRED**
