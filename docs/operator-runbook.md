# Operator runbook

This page describes the current beta appliance. Construction commands remain
in their dated implementation packets and must not be replayed as routine
operations.

## Current identity

```text
service:       mail.home.arpa
guest address: 192.168.100.199/24
domain:        mail-core-9000 on qemu:///system
host:          ws-matriarch
data mount:    /srv/stalwart
release:       1.1.1-beta
soak:          started 2026-08-01T14:06:05-04:00
```

Matriarch is temporary construction placement. Do not encode it into mailbox
identity, certificates, or restoration assumptions.

## Routine read-only checks

Confirm the guest is running in `qemu:///system`, autostart remains disabled,
and its CPU, memory, disks, and sole `br-lab10` NIC still match the accepted
domain. Inside the guest, check:

- `mail.home.arpa` hostname and `192.168.100.199/24` addressing;
- active `stalwart`, SSH, and QEMU guest-agent services;
- `/srv/stalwart` is a real XFS mount from the data disk;
- `/var/lib/stalwart` remains absent;
- free space and mailbox/queue growth;
- exact Stalwart listeners: loopback management/test interfaces plus internal
  587 and 993, with no port 25 or wildcard bind;
- certificate chain, SAN, expiry, and the 30-day renewal review threshold;
- `allowRelaying=false`, Fastmail absent, and the machine RCPT policy selected;
- both resolvers return the same forward A record and no invented PTR.

Read-only health is evidence, not authorization to repair forward. When a
check differs, record the difference and use a bounded correction packet.

## Mail acceptance checks

Use a disposable local correlation identifier and the protected credential
belonging to the client under test. Verify:

1. no password authentication is offered before STARTTLS;
2. authenticated submission succeeds over trusted TLS;
3. the local recipient receives the message;
4. trusted IMAPS retrieves it;
5. the message survives a service restart and, when scheduled, a guest reboot;
6. an external recipient is rejected before DATA;
7. an unauthorized local sender to an `hv-*` or `ws-*` recipient receives
   SMTP 550;
8. an administrative sender can deliver to that same machine;
9. a machine can report to Admin or Cluster Admin and retrieve the reply.

Do not use a real external recipient. Do not copy one endpoint's credential to
another endpoint to make a test convenient.

## Administrative KMail client

`ws-matriarch` has separate KMail identities and transports for
`admin@home.arpa` and `cluster-admin@home.arpa`. The Helix Lab root certificate
is in the Fedora system trust store, credentials remain in KWallet, and Admin
is the default compose identity. See
[`kmail-admin-client.md`](kmail-admin-client.md) for the exact account and
folder contract.

For each identity, Drafts and Sent Items must name that identity's IMAP
collections. A working IMAP login is not enough: without these bindings KMail
quietly files drafts and sent copies under Local Folders, which is technically
storage and operationally the wrong mailbox.

## Restart and reboot

Before restarting Stalwart, prove `/srv/stalwart` is mounted and record queue
state. After restart, verify the mount, listeners, certificate, relay policy,
and a known local message. A guest reboot adds checks for the UUID-backed mount,
network, SSH, guest agent, and VM autostart state.

The mount-guard test that deliberately removes `/srv/stalwart` is not routine
maintenance. It is destructive to availability and requires a reviewed packet
with a verified restoration path.

## Soak observations

Record service and VM restarts, queue behavior, local delivery failures, failed
authentication, disk/mailbox growth, certificate lifetime, endpoint behavior,
and any configuration change. The canonical clock is in
[`soak-start-manifest.md`](soak-start-manifest.md). A material redesign or
safety failure may extend the soak; do not edit its start time to improve the
story.

## Export and recovery

No appliance export or isolated restore has passed yet. Follow
[`appliance-export.md`](appliance-export.md) and
[`backup-and-restore.md`](backup-and-restore.md) when the opaque export
destination is authorized. Never copy a live RocksDB tree and call the presence
of files a restore test.

## Disabled boundaries

Do not enable Fastmail, port 25, public administration, public JMAP, POP3,
ManageSieve, ACME, public DNS, PTR publication, VM autostart, or external
delivery through routine operation. Each crosses a separately reviewed gate.
The accepted Fastmail store-and-forward design is documented, but it remains
disabled until its bounded implementation packet is executed and accepted.
