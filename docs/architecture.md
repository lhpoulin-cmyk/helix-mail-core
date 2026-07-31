# Architecture

`mail.home.arpa` is a single internal Stalwart Mail Server VM authoritative
for `home.arpa`. Local agents authenticate to SMTP submission, messages are
stored locally, and IMAPS is the initial retrieval protocol. JMAP is deferred
until internal HTTPS/TLS and client requirements are approved. Port 25 is not
enabled in the first release.

```
authenticated cluster agent -> TLS SMTP submission -> Stalwart -> local mailbox
                                                        |
                                                        +-> disabled, policy-gated Fastmail route
```

Direct installation in Debian is selected: it keeps service ownership, data
paths, systemd behavior, package/version verification, backup, and recovery
visible. Kubernetes, Nomad, an external database, and a traditional multi-daemon
Postfix/Dovecot stack are rejected as unnecessary complexity. Containers are
also deferred because they do not improve the first recovery proof enough to
justify an extra persistence boundary.

Stalwart 0.16.4 is the initial recorded release pin (official release observed
2026-07-31). Revalidate the release and checksum immediately before deployment.
Stalwart's documented startup file is a single datastore object; other
configuration belongs in its managed configuration datastore/API. The repository
therefore treats `bootstrap-config.json` as a real startup-file template and
the policy contract as the declarative intent to apply through the supported
CLI/API, rather than pretending hand-edited daemon configuration is live.

Primary references: [Stalwart configuration](https://stalw.art/docs/configuration/),
[Linux installation](https://stalw.art/docs/install/platform/linux/), and
[outbound routing](https://stalw.art/docs/mta/outbound/routing/).

Persistent-state ownership is intentionally separated from the system disk:

| Class | Authoritative path | Backup treatment |
| --- | --- | --- |
| Bootstrap configuration | `/etc/stalwart/config.json` | configuration backup |
| Runtime configuration / identity database | `/srv/stalwart/data` | application-consistent backup |
| Message store | `/srv/stalwart/data` | application-consistent backup |
| Outbound queue | `/srv/stalwart/data` | application-consistent backup |
| TLS material | `/etc/stalwart/tls` | encrypted restricted backup |
| Runtime secrets | `/etc/stalwart/secrets` | protected separately; never Git |
| Logs | `/var/log/stalwart` | retention-defined, non-authoritative |
| Reconstructable cache | none initially | exclude unless vendor requires it |
| VM backup metadata | selected Proxmox backup target | retain with VM backup record |

The data virtual disk is mounted at `/srv/stalwart`; it must be a selected
durable Proxmox datastore covered by a tested VM backup path, never host root,
scratch, GPU storage, or an undocumented path.
