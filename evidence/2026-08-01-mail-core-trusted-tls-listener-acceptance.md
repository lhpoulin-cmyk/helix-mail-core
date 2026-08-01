# Mail-core trusted TLS listener acceptance

Date: 2026-08-01  
Starting commit: `0106c5966d2f1500101a73b8b82c8b73123bf375`  
Target: `mail-core-9000` / `mail.home.arpa`  
Disposition: `ACCEPTED`

## Applied configuration

The committed declarative plan dry-run reported exactly one `Certificate`
create and two `NetworkListener` upserts (three objects total), with no update,
destroy, reconcile, or failure. The same plan applied successfully.

The accepted unit gained only `CAP_NET_BIND_SERVICE` in its bounding and
ambient capability sets so the non-root `stalwart` process can bind IMAPS port
993. Guest-side `systemd-analyze verify` passed before installation. The
service remains protected by the accepted `/srv/stalwart` mount guard.

Active Stalwart listeners are:

```text
127.0.0.1:8080       loopback management
127.0.0.1:1587       loopback submission test interface
127.0.0.1:1143       loopback IMAP test interface
192.168.100.199:587  internal authenticated submission with STARTTLS
192.168.100.199:993  internal IMAPS
```

No wildcard Stalwart bind, public administration, SMTP port 25, POP3, or
ManageSieve listener exists.

## Certificate and protocol verification

The guest-local ECDSA key matches the issued leaf. The leaf has exactly
`DNS:mail.home.arpa`, is not a CA, and verifies through the Helix Lab TLS
Issuing CA to the Helix Lab X.509 Root CA. Both network endpoints negotiated
TLS 1.3 from Matriarch with successful chain and hostname verification.

Before STARTTLS, submission advertised OAuth mechanisms only; password-bearing
PLAIN and LOGIN were absent. After trusted STARTTLS, the disposable sender
authenticated successfully. IMAP plaintext authentication remains disabled;
the disposable receiver authenticated over implicit trusted TLS.

## Acceptance tests

A real Matriarch client delivered a local-only message from
`test-sender@home.arpa` to `test-receiver@home.arpa` and retrieved it through
IMAPS. An unmistakably fake external recipient was rejected before DATA. The
same stored message remained retrievable after a Stalwart restart and after a
full guest reboot.

Stalwart returned active and enabled. `/srv/stalwart` remained the authoritative
XFS mount and `/var/lib/stalwart` remained absent. The VM retained two vCPUs,
4096 MiB RAM, one `br-lab10` NIC, and disabled autostart. Matriarch's dedicated
storage mount and bridge remained healthy, and its default route remained on
`eno1`.

No DNS, RouterOS, firewall, NetworkManager, libvirt definition, host-storage,
Fastmail, public SMTP, external-delivery, or unrelated identity mutation
occurred in this step. `SOAK_STATUS=NOT_STARTED` remains in force pending all
nine enrollment gates.
