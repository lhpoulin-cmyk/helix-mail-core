# Identity model

The server owns `home.arpa` identity and local mailbox resolution. Seed only
after Phase 5 approval:

- `cluster-admin@home.arpa`
- `postmaster@home.arpa`
- `hv-matriarch@home.arpa`
- `hv-lore@home.arpa`
- `hv-katra@home.arpa`

Document-only future identities: `b70-encode`, `b70-compute`, `backup`,
`security`, and `storage` at `home.arpa`.

Create every account with a unique generated credential through a protected,
interactive operator procedure. Deliver each credential only to its owner,
store it in the approved runtime secret mechanism, and record only an opaque
enrollment receipt. Never reuse an SMTP password or use an administrator
account for IMAP/JMAP access. Account changes are administrative operations and
must be captured as reviewed, bounded changes.

