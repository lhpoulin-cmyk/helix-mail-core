# ws-matriarch KMail admin-account result

Disposition: **ACCEPTED**

Completed: `2026-08-01T17:09:56-04:00`

## Result

KMail 26.04.1 on `ws-matriarch` now has separate identities, SMTP
transports, and Akonadi IMAP resources for:

- `admin@home.arpa`
- `cluster-admin@home.arpa`

The existing `louis` identity remains present and was not altered. It has no
outgoing transport, so `admin@home.arpa` and its matching SMTP transport are the
compose defaults. This prevents KMail from opening its unrelated account wizard
when sending. The two new identities bind to distinct transport identifiers and
distinct protected credentials.

Both IMAP resources report Akonadi status `0` (`Ready`). Their durable labels
are `IMAP (admin@home.arpa)` and `IMAP (cluster-admin@home.arpa)`.

Later interactive acceptance found two client details that protocol-only tests
did not expose. Admin was made the default compose identity because the older
local `louis` identity has no outgoing transport. Each administrative identity
was then bound to its own server-side IMAP Drafts and Sent Items collections.
KMail may renumber its `Identity #N` sections, so the bindings were verified by
email address and stable identity uoid rather than by section number.

Both administrative identities subsequently passed interactive draft save,
authenticated send, receive, retrieval, and server-side Sent Items checks.
Admin's test message was independently found in a recipient mailbox by its
original Message-ID. Cluster Admin exchanged mail with Admin in both directions.

## Trust and protocol verification

The public Helix Lab X.509 root was installed system-wide at:

`/etc/pki/ca-trust/source/anchors/helix-lab-x509-root-ca.crt`

It is owned by `root:root`, mode 0644, with file SHA-256:

`e94fba80cfe60beb62b6f2e9085eab6d4d8b8a92df521bfff1be890deec2c283`

System-trust validation passed for implicit TLS on IMAPS port 993 and STARTTLS
on submission port 587. Both identities passed protected login-only tests on
both protocols. Cross-account IMAP credential tests were rejected for both
identities.

KMail is configured to establish STARTTLS before submission authentication.
No credential was sent during the observed plaintext SMTP capability check.

## Secret handling

SMTP and IMAP credential entries exist in KWallet for each account. Verification
listed entry names only; values were not read into output. No password,
credential, or secret field appears in the KMail transport, identity, or IMAP
resource configuration files.

Protected rollback state is under:

`handoff/private/kmail-admin-accounts/`

That path remains ignored and contains no committed secret material.

## Correction record

The initial helper stopped safely because Akonadi's password setter belongs to
`org.kde.Akonadi.Imap.Wallet`, not
`org.kde.Akonadi.Imap.Settings`. The reviewed resume path recognized the exact
partial admin state, completed that resource, and then created cluster-admin.
No duplicate identity, transport, or resource was created.

No server, DNS, firewall, router, listener, identity, or mail-policy state was
changed by this client configuration.
