# Security boundary

The current beta is internal only. Stalwart binds authenticated submission to
`192.168.100.199:587`, IMAPS to `192.168.100.199:993`, and management plus
construction test interfaces to loopback. There is no public MX, router
forward, public SMTP listener, wildcard listener, or direct external delivery.

Credential-bearing access requires trusted TLS. Submission does not advertise
password mechanisms before STARTTLS, IMAP plaintext authentication is off, and
each account has a distinct credential. Unknown local recipients, unauthorized
machine delivery, sender impersonation, external recipients, and domain
relaying are rejected. Fastmail remains disabled.

The Helix Lab X.509 root is distributed only as a public trust anchor. The root
and issuing private keys live in encrypted offline custody, not on the mail
appliance. The server's ECDSA private key was generated inside the guest, is
restricted to the Stalwart service, and never enters onboarding bundles or Git.
Encryption limits who can read material; fingerprints, custody checks, modes,
and tested restore procedures answer the other questions.

Authoritative mail state belongs only on the mounted `/srv/stalwart`
filesystem. The service must fail closed when that mount is absent. Runtime
secrets, private keys, mail content, decrypted bundles, and raw operational
evidence do not belong in this repository.

Email is communication, not authority. No message body may execute a command,
approve a deployment, rotate a credential, delete data, or change access. A
future parser may classify mail and propose work; another reviewed control
surface must authorize it.

The remaining security claims are intentionally modest. The project has not
proved an appliance export or isolated restore, enabled external transport, or
selected production placement. Beta records a tested construction system, not
an immunity certificate.
