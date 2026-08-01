# Local mail-to-workspace packet transcription packet

Status: operator-authorized for bounded implementation preparation; live activation requires reviewed render

Baseline: `7a63159`

Mail authority: `mail.home.arpa` / `home.arpa`

## Purpose

Turn mail delivered to local non-administrative identities into durable Markdown
work packets at the identity's destination workspace. For example:

```text
hv-katra@home.arpa
→ encrypted hidden transcription custody
→ sanitized Markdown copy in the destination workspace inbox
→ stop
```

The canonical address is `hv-katra@home.arpa`. `home.arpa.com` is not part of
the accepted mail namespace.

This packet authorizes repository implementation work: discovery, renderer and
validator development, fixtures with unmistakably fake content, and exact
deployment-plan preparation. It does not by itself authorize live mail-rule
activation, creation of credentials, access to message contents, or mutation of
destination machines.

## Recipient rule

Apply the transcription contract to mail delivered to any authorized local
mailbox except:

```text
admin@home.arpa
cluster-admin@home.arpa
```

Those two addresses remain ordinary human mailboxes and are not copied into a
coding-agent workspace by this rule.

Resolve the actual local recipient from Stalwart's accepted envelope and
directory identity. Do not infer a recipient from a display name, untrusted
header, plus-address, lookalike domain, or message body. The rule must reject
or quarantine a recipient that cannot be mapped unambiguously to one approved
destination.

## Required delivery result

For each accepted message, produce one canonical Markdown transcription. Store
the authoritative transcription in a hidden encrypted location owned by the
destination endpoint. Publish an atomic copy of the sanitized transcription to
that endpoint's reviewed workspace inbox.

The encrypted record must retain enough non-secret provenance to establish:

- canonical envelope sender and recipient;
- original `Message-ID`, when present;
- receipt timestamp;
- cryptographic hash of the received message and transcription;
- attachment names, media types, sizes, and hashes;
- transcription version and outcome;
- destination identity and workspace reference;
- `AUTHORITY=NONE`.

Preserve the original message in encrypted custody when the reviewed storage
design permits it. The workspace receives Markdown and separately validated
attachments only; it does not receive raw credentials, private keys, active
content, or an unreviewed MIME tree.

The workspace artifact is proposed work. Receipt of mail does not authorize a
coding agent to execute commands, change infrastructure, deploy, delete data,
rotate credentials, or approve its own proposal. Email remains remarkably bad
at carrying a signed change ticket merely by sounding confident.

## Destination discovery gate

Before rendering live commands for each endpoint, determine from current
committed doctrine and read-only evidence:

1. the mailbox-to-endpoint mapping;
2. the endpoint's authoritative workspace root;
3. the exact workspace inbox path;
4. the approved encryption mechanism and recipient;
5. the hidden custody path and filesystem ownership;
6. the service account permitted to write each location;
7. whether the workspace is local, mounted, synchronized, or generated;
8. retention, backup, and restore ownership.

Keep each unresolved value explicit. Do not invent a workspace path, encryption
recipient, key, mount, or account merely to finish a renderer.

## Implementation contract

The implementation must:

1. consume only mail already accepted for a canonical local mailbox;
2. identify each message by a stable digest plus recipient and process it
   idempotently;
3. transcribe through a fixed parser with resource limits and no shell or macro
   execution;
4. quarantine malformed mail and unsafe attachments without publishing a
   partial workspace task;
5. encrypt the authoritative record before ordinary-storage persistence;
6. write the workspace artifact to a temporary file on the same filesystem,
   validate it, then rename it atomically;
7. preserve restrictive ownership and modes;
8. record success, duplicate, quarantine, and failure without message bodies or
   credentials in operational logs;
9. acknowledge completion only after encrypted custody and workspace publication
   both verify;
10. retry bounded transient failures without duplicating packets;
11. stop at workspace publication and never email the transcription onward;
12. provide exact rollback that disables new ingestion without deleting
    encrypted originals or already published packets.

Suggested logical layout, pending endpoint-specific discovery:

```text
<approved-hidden-custody>/<recipient>/<message-key>.md.encrypted
<approved-workspace>/inbox/<message-key>.packet.md
```

These are semantic placeholders, not approved absolute paths or a selected
encryption format.

## Security and failure boundaries

- No received header or body may select an arbitrary filesystem path.
- No attachment is executable merely because its filename says it is useful.
- No plaintext transcription may remain in `/tmp`, logs, crash dumps, or an
  ordinary home-directory staging area.
- The encrypted custody copy and workspace copy must be independently hashed.
- A workspace write failure must retain or retry the encrypted record; it must
  not silently discard the message.
- An encryption failure must prevent workspace publication.
- Administrative mailbox behavior, machine inbound policy, public-listener
  state, Fastmail policy, DNS, TLS, and existing identities remain unchanged.

## Verification

Use fake fixture messages first, then a separately authorized local-mail test.
For every implemented endpoint, prove:

1. an eligible local recipient produces exactly one encrypted record and one
   Markdown workspace packet;
2. both administrator recipients produce neither artifact;
3. a duplicate message produces no duplicate packet;
4. lookalike and non-`home.arpa` recipients do not select a destination;
5. malformed MIME and unsafe attachments are quarantined;
6. encrypted custody can be decrypted through the approved recovery path;
7. plaintext staging residue is absent;
8. the workspace packet contains `AUTHORITY=NONE` and no secret;
9. no outbound email, command execution, or unrelated live mutation occurs;
10. restart and reboot do not lose accepted-but-unpublished work.

Run repository validation and secret scanning on the renderer, fixtures, and
documentation. Commit only sanitized implementation and factual evidence.

## Stop conditions

Stop before live activation if any endpoint lacks an authoritative workspace,
approved encryption recipient, protected custody path, safe parsing boundary,
idempotent delivery state, or rollback. Stop if the rendered rule would include
either administrator mailbox, forward mail onward, expose plaintext, or confer
execution authority.

## Next implementation stage

The authorized next stage is read-only destination discovery followed by
repository-only implementation of the parser, renderer, validators, fake
fixtures, and an exact activation/rollback proposal. Commit that work
separately and stop for live execution authorization.
