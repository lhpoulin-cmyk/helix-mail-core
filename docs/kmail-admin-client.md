# KMail administrative client

KMail 26.04.1 on `ws-matriarch` is an approved internal client for the two
administrative mailboxes. It is a client, not a second source of mail identity.
Stalwart remains authoritative for accounts, mailboxes, policy, and message
state.

## Account contract

| Identity | Submission | Retrieval | Secret store |
| --- | --- | --- | --- |
| `admin@home.arpa` | `mail.home.arpa:587`, STARTTLS required | `mail.home.arpa:993`, implicit TLS | KWallet |
| `cluster-admin@home.arpa` | `mail.home.arpa:587`, STARTTLS required | `mail.home.arpa:993`, implicit TLS | KWallet |

The Helix Lab X.509 root is installed through Fedora's system trust mechanism.
Admin is the default compose identity. Cluster Admin remains separately
selectable and uses its own SMTP transport and credential.

Passwords do not belong in `emailidentities`, `mailtransports`, Akonadi resource
files, shell arguments, logs, or this document. The local configuration helper
reads the accepted protected endpoint files and writes password values only
through KWallet and Akonadi's Wallet D-Bus interface.

## Folder contract

Each identity must explicitly select its own IMAP folders:

| Identity | Drafts | Sent copy |
| --- | --- | --- |
| `admin@home.arpa` | Admin `Drafts` | Admin `Sent Items` |
| `cluster-admin@home.arpa` | Cluster Admin `Drafts` | Cluster Admin `Sent Items` |

Akonadi collection numbers are local database identifiers, not portable
inventory. Resolve them from the current resource and folder names whenever the
client is rebuilt. Do not hard-code a collection number from another profile,
and do not trust KMail's mutable `Identity #N` section ordering. Match identities
by exact email address and stable uoid.

This distinction was learned the useful way. Both IMAP resources could
authenticate while KMail still filed drafts and sent copies into Local Folders.
The accounts were connected, but the filing cabinet was in the wrong building.

## Acceptance test

For each administrative identity:

1. create and save a draft;
2. verify it appears in that identity's server-side Drafts folder;
3. send it to the other administrative identity over STARTTLS;
4. verify recipient delivery and retrieval;
5. verify the sender's server-side Sent Items copy;
6. verify Outbox is empty and the dispatcher is Ready;
7. verify the other identity's credential cannot authenticate as the sender.

Inspect server-side state independently over trusted IMAPS when the KMail view
looks stale. Refresh the exact collection before concluding that a message is
missing. A folder pane is a view of state, not the state itself.

The accepted execution and corrections are recorded in
[`../evidence/2026-08-01-ws-matriarch-kmail-admin-accounts-result.md`](../evidence/2026-08-01-ws-matriarch-kmail-admin-accounts-result.md).
