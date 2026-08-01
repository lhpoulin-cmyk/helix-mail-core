# Mail-core trusted TLS listener activation

Status: authorized continuation after accepted forward-only DNS  
Target: `mail-core-9000` / `192.168.100.199`  
Stalwart: `0.16.15`

## Boundary

Install the already issued guest-local certificate into Stalwart's live
configuration and add only authenticated internal submission and IMAPS. Keep
the existing loopback listeners, mount guard, local domain, accounts, and relay
policy unchanged.

Do not add port 25, POP3, ManageSieve, public HTTP/JMAP, wildcard binds,
Fastmail, external routes, ACME, identities, DNS records, firewall rules, or
host/network/libvirt changes.

## Proven inputs

- Both configured resolvers return only
  `mail.home.arpa A 192.168.100.199`; PTR, AAAA, and wildcard probes have no
  answer.
- `/etc/stalwart/tls/mail.home.arpa.key` is guest-local, mode 0600,
  `stalwart:stalwart`, and its public key matches the issued leaf.
- `/etc/stalwart/tls/mail.home.arpa.fullchain.crt` contains the leaf and issuing
  chain. The leaf has serial `2000`, exactly `DNS:mail.home.arpa`, CA false,
  and validity through 2027-01-28.
- The accepted Helix Lab root trust anchor is
  `helix-pki/public/helix-lab-x509-root-ca.crt` at PKI commit `417a185`.
- Live v0.16.15 schema confirms `Certificate` supports file-backed public and
  secret text and that `NetworkListener` supports explicit binds, TLS, and
  implicit TLS.
- IMAP plaintext authentication is disabled. SMTP exposes password mechanisms
  only when TLS is active and requires authentication on non-port-25 listeners.

## Exact render

Use `config/stalwart/trusted-internal-tls.plan.ndjson` unchanged. It creates one
certificate object backed by the reviewed guest paths and upserts exactly:

```text
submission-lab10  SMTP  192.168.100.199:587  STARTTLS required
imaps-lab10       IMAP  192.168.100.199:993  implicit TLS
```

Because 993 is privileged, replace only these two lines in the accepted
repository-rendered unit and installed unit:

```diff
-CapabilityBoundingSet=
-AmbientCapabilities=
+CapabilityBoundingSet=CAP_NET_BIND_SERVICE
+AmbientCapabilities=CAP_NET_BIND_SERVICE
```

No other capability is granted. Re-run `systemd-analyze verify`, compare the
installed unit to the repository render, and daemon-reload before service
restart.

## Apply

1. Reconfirm guest identity, mount, version, certificate/key match, DNS answer,
   listener inventory, relay policy, and clean repository render.
2. Copy the exact plan to the existing protected private Stalwart state,
   mode 0600.
3. Use the existing protected cluster-admin credential through the reviewed
   TTY helper; never place it in argv or output.
4. Run `stalwart-cli apply --dry-run --file ...` and require one Certificate
   create and two NetworkListener upserts with no destroy or unrelated update.
5. Apply the same file only after the dry-run matches.
6. Install the two-line capability correction, daemon-reload, restart Stalwart,
   and require the service to remain active and mount-guarded.

## Verification

- Query the live Certificate and NetworkListener objects without secret fields.
- Require exact binds on `.199:587` and `.199:993`; require no port 25,
  wildcard, public management, POP3, or ManageSieve listener.
- Validate both TLS endpoints from Matriarch with the accepted root CA,
  hostname verification, and TLS 1.2 or newer.
- Require submission to advertise password authentication only after STARTTLS
  and require IMAPS to present the same trusted leaf.
- Use the protected disposable test credentials to deliver and retrieve one
  local-only message; reject an unmistakably fake external recipient before
  DATA.
- Restart and reboot persistence tests follow after protocol acceptance.
- Reconfirm `/srv/stalwart`, `/var/lib/stalwart` absence, guest health, and host
  network/storage health.

## Rollback and stop conditions

On listener, trust, bind, or protocol failure, stop Stalwart exposure and use a
reviewed declarative change that removes only the two Lab-10 listener objects
and certificate object. Restore the empty capability bounds only after port
993 is removed. Preserve mail data and existing loopback objects.

Stop on a changed certificate/key, unexpected dry-run operation, wildcard or
port-25 bind, untrusted chain, plaintext credential path, failed relay
rejection, mount-guard failure, or any mutation outside this packet.
