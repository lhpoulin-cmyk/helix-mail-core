# ws-matriarch KMail Admin account configuration packet

Status: execution authorized by the operator's request to configure KMail

Target: `ws-matriarch`, local user `louis`, KMail/Akonadi 26.04.1

## Objective

Configure two independent KMail identities, IMAP resources, and SMTP
transports:

- `admin@home.arpa`
- `cluster-admin@home.arpa`

Use the already accepted protected credentials under
`handoff/private/mail-endpoints/`. Do not generate, rotate, print, copy between
accounts, or place either credential in KMail's plaintext configuration.

## Fixed protocol state

| Function | Host | Port | Protection | Authentication |
| --- | --- | ---: | --- | --- |
| submission | `mail.home.arpa` | 587 | required STARTTLS | PLAIN after TLS |
| mailbox | `mail.home.arpa` | 993 | implicit TLS | PLAIN inside TLS |

The accepted Helix Lab X.509 root is the only new trust anchor. Its certificate
file SHA-256 is
`e94fba80cfe60beb62b6f2e9085eab6d4d8b8a92df521bfff1be890deec2c283` and its
certificate SHA-256 fingerprint is
`85:6A:08:1E:26:A3:57:CD:F1:DC:37:FF:40:9F:B3:70:CF:1D:44:B7:63:76:95:A8:27:56:A0:D0:73:DE:CD:A1`.

## Preflight

1. Confirm the host is `ws-matriarch` and the repository is clean.
2. Confirm both protected endpoint directories and credentials exist with mode
   0700/0600 and contain the expected identity values.
3. Confirm the two credentials differ using an in-process equality check that
   emits only match/no-match.
4. Confirm DNS resolves `mail.home.arpa` to `192.168.100.199`.
5. Confirm the supplied root certificates are identical and match the fixed
   fingerprints above.
6. Confirm KMail, Akonadi IMAP, KWallet, and the user D-Bus are available.
7. Stop if either identity, IMAP resource, or SMTP transport already exists;
   do not merge an unknown partial configuration.
8. Copy the current non-secret KMail configuration to a protected rollback
   directory before mutation.

## Exact mutation

1. Install the public root certificate as
   `/etc/pki/ca-trust/source/anchors/helix-lab-x509-root-ca.crt` and refresh the
   Fedora trust store. Do not install the issuing certificate as a trust root.
2. Recheck IMAPS and submission certificate validation with the system trust
   store.
3. Close KMail cleanly after confirming it can close.
4. Run `scripts/configure-kmail-local-accounts.py --apply` as `louis` in the
   graphical user session.
5. The helper creates exactly two Akonadi IMAP resources through the supported
   `AgentManager` and `/Settings` D-Bus interfaces, using SSL on 993 and binding
   each resource to its matching KMail identity.
6. The helper creates exactly two SMTP transports using STARTTLS on 587,
   authentication required, and one username per identity.
7. Store all four password uses in KWallet/QKeychain. No password may be
   written to `emailidentities`, `mailtransports`, an Akonadi rc file, an
   argument, environment variable, log, Git, or stdout.
8. Preserve the existing `louis` KMail identity and local-mail resource.

## Verification

- Both IMAP resources synchronize successfully and report no authentication or
  certificate error.
- KMail lists both identities and each identity names its own SMTP transport.
- `mailtransports` contains the fixed host, ports, TLS modes, authentication
  requirement, and usernames, but no password field.
- KWallet contains entries for both transports; values are never read into
  output.
- Independent protected tests authenticate each identity to submission and
  IMAPS using the system trust store.
- A wrong-account credential test fails without exposing either value.
- Existing KMail identity and Akonadi resources remain present.
- No server, DNS, firewall, router, certificate, or mail-policy mutation occurs.

## Rollback

Remove only the two newly created IMAP resources and their QKeychain entries,
remove only the two new SMTP KWallet entries, restore the captured KMail
configuration files atomically, and restart KMail. Remove the root trust anchor
only if this packet installed it and no other accepted local client depends on
it. Never remove or alter server-side identities or credentials during client
rollback.

## Stop conditions

Stop on a certificate fingerprint mismatch, failed system trust, unexpected
existing account, unavailable KWallet, KMail refusing a clean close, a
credential written outside KWallet, authentication failure, or any requested
change beyond this local client.
