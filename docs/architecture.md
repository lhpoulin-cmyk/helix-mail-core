# Architecture

## Current accepted system

`mail.home.arpa` is one internal Stalwart 0.16.15 server authoritative only for
`home.arpa`. It runs on Debian 13 in the system-libvirt domain
`mail-core-9000` on Fedora 44 Matriarch. Clients submit authenticated mail over
trusted STARTTLS on TCP 587 and retrieve it over trusted IMAPS on TCP 993.
Management and the construction test listeners remain on guest loopback.

```text
authenticated internal client -> submission/587 -> Stalwart -> local mailbox
                                                            |
approved internal client <- IMAPS/993 -----------------------+
                                                            |
                                                            +-> best-effort Fastmail copy
```

The outward arrow is not the whole Fastmail story. A separate approved policy
allows authenticated direction from `louis@poulin-arpa.com` into the initial
exact coder address `hv-lore@home.arpa`. When its future pull-based JMAP
transport and intake enforcement validate account, recipient, and scope,
that local message can record authoritative operator intent for a coder. It
still cannot bypass the repository's packet and safety gates. The inbound path
is policy-defined but not deployed; public SMTP remains disabled.

The durable identity is `mail.home.arpa`; Matriarch is temporary construction
and soak placement. No configuration may make the host name part of the mail
identity or require Matriarch for a later restore.

## VM, storage, and network

The current domain has 2 vCPUs, 4096 MiB RAM, one virtio NIC on `br-lab10`,
and autostart disabled. The guest uses `192.168.100.199/24`, gateway
`192.168.100.1`, resolvers `192.168.10.251` and `192.168.10.252`, and MTU
1500. The host bridge uses only `enp7s0` as its port and retains host MTU 9000;
the host default route remains on `eno1`.

The construction pool is an XFS filesystem labeled `mailcore-vm`, mounted at
`/var/lib/libvirt/mail-core`. It contains separate sparse qcow2 images:

- `mail-core-9000-system.qcow2`: 32 GiB virtual system disk;
- `mail-core-9000-data.qcow2`: 192 GiB virtual data disk.

Inside the guest, the data disk is XFS labeled `stalwartdata` and mounted by
UUID at `/srv/stalwart`. The Stalwart unit has three independent mount checks:
`RequiresMountsFor`, `ConditionPathIsMountPoint`, and `mountpoint` before
start. If the data filesystem is missing, the service stays down instead of
turning the root disk into an accidental mail store.

## Stalwart state ownership

Stalwart was installed manually from a pinned, Sigstore-verified GNU x86_64
release artifact. The convenience installer was not used because it selected
paths and activation behavior that crossed the reviewed mount and listener
boundaries.

| State | Authoritative path | Treatment |
| --- | --- | --- |
| Bootstrap datastore object | `/etc/stalwart/config.json` | root-owned configuration |
| Managed configuration and mailbox database | `/srv/stalwart/data` | application-consistent export required |
| Blob data | `/srv/stalwart/blobs` | application-consistent export required |
| Local logs | `/srv/stalwart/log` | non-authoritative operational record |
| Temporary application state | `/srv/stalwart/tmp` | not an identity source |
| TLS key and chain | `/etc/stalwart/tls` | restricted; key remains guest-local |
| Runtime secrets | `/etc/stalwart/secrets` and protected private state | never Git |

`/var/lib/stalwart` is absent and must remain unused.

## DNS and trust

The Infrastructure source of truth publishes one forward record:

```text
mail.home.arpa. A 192.168.100.199
```

Both internal resolvers return that answer. No PTR, wildcard, or invented AAAA
record is published.

The Helix Lab X.509 CA is a separate offline authority: an ECDSA P-256 root
with path length 1 and an ECDSA P-256 issuing intermediate with path length 0.
The issuing CA signed a 180-day server leaf containing exactly
`DNS:mail.home.arpa`. The root public certificate is the endpoint trust anchor;
the issuing certificate is chain material only. Encrypted CA custody packages
are held on Foundation and Second Foundation. No CA private key belongs in
this repository, the mail VM, or an onboarding bundle.

## Identity and delivery policy

Every machine and human correspondent has a distinct account and credential.
Machine mailboxes (`hv-*` and `ws-*`) accept delivery only from
`admin@home.arpa` and `cluster-admin@home.arpa`. Machines may send to those
administrators. Other local-to-machine delivery is rejected at RCPT before
DATA; submission sender matching prevents a machine from borrowing an
administrator's envelope address.

Stalwart's domain relaying is false. Public SMTP port 25, public
administration, POP3, ManageSieve, public JMAP, and arbitrary external
recipients are disabled. One exact-recipient outbound bridge copies Admin and
Cluster Admin mail to their corresponding Fastmail aliases. It is best effort
and does not change which mailbox is authoritative. It is separate from the
inbound operator-direction contract and cannot confer authority by reply or
inference.

## Recovery design

Normal service startup is mount-guarded and hardened by systemd. Recovery
provisioning used a temporary systemd network namespace with loopback only:
no physical interface, veth, route, DNS, forwarding, bridge, or NAT. The CLI
entered that same namespace. Recovery credentials and runtime machinery were
removed before ordinary service activation.

The next recovery proof is the appliance export and isolated restore. A raw
copy of a live database is not accepted merely because it has a reassuring
file extension. The export must capture configuration, mail and queue state,
TLS metadata, version information, and protected secret-recovery references,
then survive an isolated import without delivering mail.

## Deliberate exclusions

The project uses a direct Debian installation with RocksDB and filesystem blob
storage. It does not use Kubernetes, Nomad, containers, an external database,
or a Postfix/Dovecot assembly. Those are valid tools; they do not improve this
single-node recovery proof enough to pay their persistence and operational
cost here.

Primary technical records are in
[`../evidence/`](../evidence/) and the exact bounded procedures in
[`../implementation/`](../implementation/). See
[`README.md`](README.md) for how those historical layers should be read.
