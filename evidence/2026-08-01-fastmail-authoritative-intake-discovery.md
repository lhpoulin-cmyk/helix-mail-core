# Fastmail authoritative-intake discovery

Date: 2026-08-01

Scope: read-only repository, protocol, and host-access discovery. No Fastmail
token was created, no API request was authenticated, and no live service or
mail configuration changed.

## Fastmail/JMAP findings

Fastmail's current official documentation establishes:

- the JMAP session resource is `https://api.fastmail.com/jmap/session`;
- an API token is presented as a Bearer token;
- a JMAP token can be created with **Read-only access**, which can view and
  download data but cannot change it;
- the JMAP mail capability exposes Mailbox and Email methods;
- the Sent mailbox can be identified by its standard mailbox role;
- an Email object has a stable JMAP ID and blob reference, and the session
  supplies the download URL needed to obtain original message content.

Primary references:

- <https://www.fastmail.com/dev/>
- <https://www.fastmail.help/hc/en-us/articles/5254602856719-API-tokens>
- <https://www.rfc-editor.org/rfc/rfc8620>
- <https://www.rfc-editor.org/rfc/rfc8621>

JMAP is therefore suitable and IMAP fallback is not justified for the initial
implementation. A separate read-only API token can avoid reusing the existing
Stalwart SMTP relay credential and cannot submit or mutate mail.

## Repository findings

The accepted outbound bridge is deployed and separate. Its protected SMTP
credential is file-backed on the mail guest, and its exact-recipient policy is
validated by `scripts/validate/all.sh`. This discovery proposes no change to
that bridge.

The historical local-mail transcription packet does not define an accepted
absolute coder-inbox path on `hv-lore`; it also applies `AUTHORITY=NONE` to its
broad ordinary-mailbox proposal. It cannot be reused as authority enforcement.
The new intake requires a separate exact sender, exact recipient, and
authenticated-account contract.

## Live discovery status

Strict read-only SSH discovery of `mail.home.arpa` stopped before connection
because host-key verification failed. The chained `hv-lore` query therefore
did not run. No host key was accepted, removed, or bypassed.

Before deployment, the executable packet must independently re-attest the
target host identity and capture the current account, filesystem, service,
listener, and mount state. A changed or unavailable trusted access path is a
hard stop, not a reason to use `StrictHostKeyChecking=no`.

## Recommended placement

Run the initial recipient-specific poller locally on `hv-lore`, not on the mail
guest. It needs outbound HTTPS to Fastmail and local writes to a narrowly owned
state/evidence tree. It needs no SSH credential, Proxmox API access, Ceph
access, Stalwart mailbox credential, public listener, or remote coder endpoint.

This placement is a proposal until the packet is approved and the immediate
host preflight passes.
