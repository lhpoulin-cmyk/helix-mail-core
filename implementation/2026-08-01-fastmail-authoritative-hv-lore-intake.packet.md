# Fastmail authoritative hv-lore intake implementation packet

Status: rendered for operator review; **not authorized for execution**

Repository baseline: `7c67831e60e13c18d02b6dbc5c210d46c8eb67b5`

Target: `hv-lore`

Initial admitted recipient: `hv-lore@home.arpa`

Authenticated account identity: `louis@poulin-arpa.com`

## Purpose and boundary

Install one pull-only service that reads the authenticated Fastmail account's
Sent mailbox over JMAP and converts a qualifying message into one durable,
structured, authoritative instruction record on `hv-lore`.

The service transports operator authority. It does not execute instructions,
invoke a shell, mutate a repository, approve its own work, or hold Proxmox,
Ceph, SSH, Stalwart, CA, or Fastmail-SMTP credentials.

This packet does not change Stalwart, the accepted outbound copy bridge, DNS,
RouterOS, NetworkManager, firewall policy, public listeners, mail identities,
or the soak clock. Public SMTP and port 25 remain disabled.

## Evidence basis

The read-only discovery is recorded in
[`../evidence/2026-08-01-fastmail-authoritative-intake-discovery.md`](../evidence/2026-08-01-fastmail-authoritative-intake-discovery.md).
Fastmail documents a read-only JMAP API token and the standard Mailbox/Email
methods. JMAP is selected; IMAP fallback is not used.

Live SSH discovery stopped on unverified host trust. Execution must not begin
until `hv-lore` is independently re-attested and strict host-key verification
succeeds.

## Proposed architecture

```text
Fastmail JMAP session (read-only token)
  -> Mailbox/get: resolve exactly one mailbox with role=sent
  -> Email/query: messages in that mailbox after bounded lookback/cursor
  -> Email/get: immutable ID, blobId, sender, recipients, subject, sentAt,
                Message-ID, body structure, attachments
  -> authenticated-account and exact-recipient qualification
  -> raw RFC 822 blob download and hash
  -> quarantine or durable evidence transaction
  -> one normalized instruction record in the local ready spool
  -> coder reads the record; bridge executes nothing
```

The initial implementation is a periodic oneshot service plus systemd timer.
It opens no listening socket. The poll interval is 60 seconds with randomized
delay, a single-process lock, a 30-second HTTPS timeout, bounded response and
attachment sizes, and exponential failure logging without message bodies.

## Exact proposed files and identities

Repository source to be added by this packet's implementation commit:

```text
src/fastmail_authoritative_intake.py
config/fastmail-intake/policy.json
config/fastmail-intake/instruction.schema.json
provisioning/guest/fastmail-authoritative-intake.service
provisioning/guest/fastmail-authoritative-intake.timer
tests/test-fastmail-authoritative-intake.py
tests/fixtures/fastmail-intake/       # fake JMAP/RFC822 fixtures only
docs/fastmail-authoritative-intake.md
```

Installed on `hv-lore`:

```text
account:  fastmail-intake (system, no home, shell /usr/sbin/nologin)
group:    fastmail-intake
program:  /usr/local/libexec/helix-fastmail-authoritative-intake
policy:   /etc/helix-fastmail-intake/policy.json
secret:   /etc/helix-fastmail-intake/jmap-token
state:    /var/lib/helix-fastmail-intake/state.sqlite3
lock:     /run/helix-fastmail-intake/poller.lock
evidence: /var/lib/helix-fastmail-intake/evidence/
ready:    /var/lib/helix-fastmail-intake/instructions/ready/
quarantine: /var/lib/helix-fastmail-intake/quarantine/
unit:     /etc/systemd/system/fastmail-authoritative-intake.service
timer:    /etc/systemd/system/fastmail-authoritative-intake.timer
```

Directories are root-owned and group-readable only where the local coder needs
read access. Exact initial modes:

```text
/etc/helix-fastmail-intake                 root:fastmail-intake 0750
/etc/helix-fastmail-intake/policy.json     root:fastmail-intake 0640
/etc/helix-fastmail-intake/jmap-token      root:fastmail-intake 0640
/var/lib/helix-fastmail-intake             fastmail-intake:fastmail-intake 0700
/run/helix-fastmail-intake                 fastmail-intake:fastmail-intake 0700
```

The operator/coder reads a sanitized instruction through a separately created
read-only group grant after the immediate preflight identifies the existing
`hv-lore` coder account. The packet must stop rather than guess that account or
change its groups. If no existing approved read-only handoff mechanism exists,
the bridge may be installed and tested through its protected fixture path but
must remain disabled until that one delivery ownership decision is reviewed.

## Policy configuration

Tracked policy contains no token:

```json
{
  "jmap_session_url": "https://api.fastmail.com/jmap/session",
  "authenticated_account": "louis@poulin-arpa.com",
  "sent_mailbox_role": "sent",
  "approved_recipients": ["hv-lore@home.arpa"],
  "require_exactly_one_recipient": true,
  "allow_forwarded": false,
  "allow_attachments": true,
  "attachments_are_inert": true,
  "max_message_bytes": 26214400,
  "max_attachment_bytes": 10485760,
  "poll_lookback_seconds": 604800
}
```

`to`, `cc`, and `bcc` are combined for admission. There must be exactly one
address total and it must equal `hv-lore@home.arpa` after conservative mailbox
syntax parsing. Display names do not affect the comparison. Empty, malformed,
group, multiple, or non-allowlisted recipients quarantine the message.

The authenticated JMAP session account and Sent mailbox role establish account
context. The RFC `From` value must additionally equal
`louis@poulin-arpa.com`, but it is never sufficient by itself. A message copied
or forwarded into Sent without validated account context and exact metadata is
not admitted.

## Secret entry

Create a new Fastmail JMAP API token named descriptively for the hv-lore
authoritative intake and grant **Read-only access only**. Do not grant Email,
Email submission, contacts, Masked Email, or MCP write/send access.

Collect it through the approved hidden operator-secret-entry workflow. Write
it directly to `/etc/helix-fastmail-intake/jmap-token` using a root-controlled
0600 staging file and atomic install to final `root:fastmail-intake 0640` mode.
The value must never appear in argv, environment dumps, stdout, journal,
repository state, evidence, or chat. It is separate from
`/etc/stalwart/secrets/fastmail-app-password` and may be revoked independently.

Before service activation, use the protected file through a fixed validator to
fetch only the JMAP session. Record only HTTP status, advertised capabilities,
authenticated username, account count, and token access class. Stop if the
account is not exactly `louis@poulin-arpa.com` or the API permits mutation in a
safe negative capability check.

## Evidence and instruction schema

Each observed object receives an append-only event row. An accepted message has
an immutable directory named by its generated instruction ID containing:

```text
original.eml                    # mode 0600, never copied to coder spool
metadata.json                   # JMAP ID/blob ID, Message-ID, sentAt, account,
                                # recipients, subject, attachment metadata
normalized.txt                  # normalized plain text, mode 0600
decision.json                   # qualification decision and reason
manifest.sha256
```

The coder-ready JSON/Markdown record contains:

```text
schema_version
instruction_id
authority=OPERATOR_DIRECTION
authority_basis=FASTMAIL_AUTHENTICATED_SENT_MAILBOX
source_evidence_reference
approved_recipient
sent_at
intake_at
subject
normalized_instruction
explicit_scope                 # verbatim section or UNRESOLVED_REQUIRES_REVIEW
attachment references only
governance reminder
```

It contains neither the API token nor raw active attachment bytes. Attachments
remain immutable evidence, mode 0600, with filename, media type, size, and
SHA-256 metadata. No archive is extracted and no file is executed.

## Deduplication and transaction model

SQLite is opened with foreign keys, WAL, `synchronous=FULL`, and a single
writer. Unique constraints cover:

```text
(account_id, jmap_email_id, approved_recipient)
(rfc_message_id, content_sha256, approved_recipient)
instruction_id
```

Processing order:

1. acquire the process lock;
2. fetch metadata and the raw blob without changing Fastmail state;
3. write evidence files into a same-filesystem temporary directory;
4. fsync each file and directory, then atomically rename evidence into place;
5. write and fsync the coder-ready record in a temporary path;
6. begin the SQLite transaction, insert evidence and instruction rows, and
   atomically rename the ready record;
7. fsync the ready directory and commit the database transaction;
8. advance the durable JMAP query state/cursor only after commit.

On restart, any temporary directory is reconciled against SQLite and hashes.
An existing unique key records a duplicate event and creates no instruction.
A lost cursor causes bounded replay, not duplicate delivery. Acknowledgment is
outside this transaction and cannot change accepted/deduplicated state.

## Service hardening

The oneshot unit uses:

```ini
User=fastmail-intake
Group=fastmail-intake
UMask=0077
NoNewPrivileges=yes
PrivateTmp=yes
PrivateDevices=yes
ProtectSystem=strict
ProtectHome=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
ProtectClock=yes
ProtectHostname=yes
RestrictSUIDSGID=yes
LockPersonality=yes
RestrictRealtime=yes
SystemCallArchitectures=native
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
ReadOnlyPaths=/etc/helix-fastmail-intake
ReadWritePaths=/var/lib/helix-fastmail-intake /run/helix-fastmail-intake
```

No capability is granted. `ExecStart` has fixed absolute arguments only. The
token path is read by the program; it is not an environment variable. Network
egress is HTTPS only at the application layer. If host firewall egress
restriction would require changing accepted `hv-lore` firewall policy, stop
for a separate packet rather than broadening it here.

Logs are structured and limited to timestamps, poll result, counts, JMAP ID
fingerprints, instruction IDs, decision codes, and latency. Subjects, bodies,
recipient lists beyond the admitted configured recipient, attachment names,
tokens, HTTP authorization headers, and raw server responses are not logged.
Health is the last successful poll timestamp stored in SQLite and exposed by a
fixed `--health` command.

## Immediate preflight

Before any mutation:

1. confirm the authoritative repository is clean at the separately approved
   implementation commit;
2. independently re-attest `hv-lore` host identity and strict SSH trust;
3. confirm hostname, operating system, time synchronization, and management
   fallback;
4. capture current accounts, groups, `/usr/local/libexec`, `/etc/systemd/system`,
   `/var/lib`, ACL, SELinux/AppArmor, mount, and filesystem capacity state;
5. prove no `fastmail-intake` account, files, units, listeners, or state exist;
6. prove the approved coder account and a narrow read-only handoff mechanism;
7. capture current listeners and firewall fingerprints;
8. confirm DNS and HTTPS reachability to `api.fastmail.com` without a token;
9. reconfirm mail-core public port 25 is absent and the existing outbound
   bridge policy/hash remains accepted;
10. render all files, hashes, modes, ownership, package dependencies, and the
    complete systemd security assessment;
11. stop on any mismatch, invented account/group, package installation,
    firewall delta, or unavailable rollback.

No live package installation is planned. The implementation uses Debian's or
the host distribution's installed Python 3 standard library plus SQLite. Stop
if the required Python, SQLite module, TLS trust, or systemd version is absent;
do not add packages under this packet.

## Exact deployment sequence

After the implementation commit and a passing preflight:

1. install the fixed program, policy, schema, units, and timer from their
   committed hashes into protected staging paths;
2. create the system account and directories with the exact ownership/modes;
3. run offline fixture tests as the service account with networking denied;
4. collect the read-only API token through hidden local entry and atomically
   install it;
5. run the fixed JMAP session/capability validator without message retrieval;
6. run a dry poll that records metadata counts only and writes no evidence;
7. enable the timer only after dry-poll review;
8. send one new bounded Fastmail test message with a unique non-secret marker
   to exactly `hv-lore@home.arpa`;
9. require one evidence record and one ready instruction;
10. restart the oneshot/timer and poll repeatedly; require no second record;
11. run the negative fixtures and live tests below;
12. verify host and mail-core fingerprints remain unchanged.

The token is not used to mark or move Fastmail messages. Consumption exists
only in the durable local transaction state.

## Required tests

Automated fake-fixture tests must prove:

1. valid account/Sent/single-recipient input creates exactly one record;
2. repeat, cursor loss, crash after evidence rename, crash before database
   commit, and acknowledgment failure create no duplicate instruction;
3. an unapproved recipient quarantines;
4. a correct visible From with the wrong authenticated account quarantines;
5. multiple recipients quarantine;
6. malformed JMAP, MIME, address, body, and date values fail closed;
7. attachments are hashed and retained but never extracted or executed;
8. content without unambiguous plain text is quarantined;
9. unsupported or scope-ambiguous content is marked for review and never
   execution-capable;
10. logs and evidence reports contain no token or Authorization header.

Bounded live acceptance must prove one valid message is retrieved exactly once,
original and normalized evidence verify, the local ready record is readable by
only the approved coder handoff, restart/replay does not duplicate it, and an
unapproved-recipient message is quarantined. A forged visible From test must
use fixtures unless the operator separately authorizes another real message.

Also reconfirm:

- mail-core has no port 25/public SMTP listener;
- outbound Admin and Cluster Admin copies retain their accepted configuration;
- no other local recipient triggers the outbound bridge;
- no Fastmail SMTP credential or Stalwart configuration changed;
- the new service opens no listener and owns no broad credential.

## Rollback and recovery

Disable and stop only the new timer/service, then remove the token and installed
program/config/unit files. Remove the system account only after proving no
process owns it. Preserve `/var/lib/helix-fastmail-intake` as immutable evidence
unless a separate destruction packet authorizes removal.

Rollback does not delete or replay instructions. Reinstallation imports the
preserved SQLite database and evidence tree, verifies manifests, and performs a
bounded replay query; unique constraints prevent duplicate ready records.

Fastmail revocation is performed in Settings -> Privacy & Security -> Manage
API tokens by removing only this dedicated token. Revocation stops polling but
does not alter the existing SMTP relay credential.

## Stop conditions

Stop without improvisation if:

- `hv-lore` identity or strict SSH trust cannot be proven;
- the approved local coder account/read-only handoff is unresolved;
- Fastmail session identity or Sent role differs;
- a read-only API token is unavailable;
- raw RFC 822 download or required JMAP metadata is unavailable;
- the proposed service needs package, firewall, Proxmox, Ceph, SSH, Stalwart,
  public-listener, or group-policy changes not rendered here;
- any secret reaches argv, logs, Git, evidence, or chat;
- deduplication/crash tests fail;
- the outbound bridge or public-SMTP state changes.

## Execution authority required

This packet is not executable until the operator approves the later
implementation commit containing the program, fixtures, units, and resolved
coder handoff. Approval of this design alone does not create the token or alter
`hv-lore`.
