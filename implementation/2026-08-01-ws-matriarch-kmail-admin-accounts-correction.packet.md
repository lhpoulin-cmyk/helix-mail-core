# ws-matriarch KMail admin-account correction packet

Status: bounded correction authorized by the accepted KMail configuration work

## Observed stop

The first execution stopped because the helper called `setPassword` on
`org.kde.Akonadi.Imap.Settings`. KDEPIM 26.04.1 exposes that method on the
separate `org.kde.Akonadi.Imap.Wallet` interface at the same `/Settings`
object. No credential was printed or written to a plaintext configuration.

The interrupted run left one exact partial account:

- the `admin@home.arpa` KMail identity;
- its reviewed SMTP transport and KWallet entry;
- one admin IMAP resource whose non-secret setters persisted, but whose password
  call and explicit save did not complete;
- no `cluster-admin@home.arpa` identity, transport, or resource.

The system-wide Helix Lab root CA installation succeeded and both mail TLS
endpoints validate through the system trust store. It is not part of this
correction.

## Correction

Run:

```text
scripts/configure-kmail-local-accounts.py --apply --resume-admin-partial
```

The resume mode must fail closed unless it finds exactly the partial state
above. It verifies the existing admin identity and transport field by field,
requires exactly one IMAP resource matching all reviewed admin settings, and
refuses any existing
`cluster-admin@home.arpa` state.

It then:

1. stores the admin IMAP credential through
   `org.kde.Akonadi.Imap.Wallet` and saves the reviewed IMAP settings;
2. creates the separate cluster-admin identity and SMTP transport;
3. stores the cluster-admin SMTP credential in KWallet;
4. creates and configures its IMAP resource through the Settings and Wallet
   interfaces;
5. restarts and synchronizes only the two reviewed resources.

The prior local `louis` identity has no outgoing transport. Retain it, but make
`admin@home.arpa` and its matching SMTP transport the compose defaults so KMail
does not offer to create an unrelated outgoing account.

The existing `louis` identity and unrelated Akonadi resources remain unchanged.

## Verification

- Both identities bind to distinct SMTP transports.
- Both transports require STARTTLS on port 587 and contain no plaintext secret.
- Both IMAP resources use implicit TLS on port 993 and synchronize.
- KWallet contains the four required entries without displaying their values.
- Protected direct tests authenticate both identities over trusted TLS.
- Cross-account credentials fail, and external relay remains unchanged.

## Stop and rollback

Stop for any partial-state mismatch, duplicated resource, certificate error,
authentication failure, or plaintext credential residue. Rollback removes only
the newly reviewed account objects and restores the protected configuration
backup; it does not remove the system trust anchor or change the mail server.
