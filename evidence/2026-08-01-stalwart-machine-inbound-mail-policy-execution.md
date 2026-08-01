# Stalwart machine-inbound mail policy execution

Completed: `2026-08-01T14:45:42-04:00`  
Target: `mail.home.arpa` / Stalwart `0.16.15`  
Repository control points: `885719e`, `4f974d6`, `dbf3f2b`

## Applied state

- Created one active system Sieve object named
  `machine-inbound-admin-only`.
- Selected only that object at `MtaStageRcpt.script`.
- Retained `MtaStageRcpt.allowRelaying=false`.
- The policy matches `hv-*` and `ws-*` recipients in `home.arpa` and rejects
  every envelope sender except `admin@home.arpa` and
  `cluster-admin@home.arpa` before DATA.
- Submission independently rejects a machine credential attempting to use an
  administrative envelope sender; this is a required companion invariant.

## Corrective execution

The initial script was created while Stalwart was already running. Live tests
established that system Sieve additions require a service restart before the
new object is executed. The selector was rolled back to `false` after the first
failed negative test.

After compilation, the script rejected both machine and administrative
senders because `env.authenticated_as` did not provide a stable comparison
value for this stage. Both attempted authenticated-name forms failed the Admin
positive gate and were rolled back. No rejected test message proceeded to
DATA.

The final correction uses canonical envelope senders together with the proven
submission sender-impersonation rejection. It was applied with the selector
disabled, compiled by restart, selected through a one-update dry-run, and
reloaded before testing.

## Acceptance evidence

- Admin and Cluster Admin: accepted to all seven `hv-*` and `ws-*` mailboxes,
  including deferred identities.
- Machines: accepted to Admin and Cluster Admin.
- `hv-lore -> hv-katra`: rejected at RCPT with SMTP 550.
- `ws-matriarch -> ws-hadrian`: rejected at RCPT with SMTP 550.
- `test-sender -> hv-lore`: rejected at RCPT with SMTP 550.
- `test-sender -> ws-matriarch`: rejected at RCPT with SMTP 550.
- machine authentication with Admin envelope sender: rejected with SMTP 501.
- authenticated external relay: rejected at RCPT.
- all five required physical endpoints completed trusted-TLS submission,
  administrative delivery/reply, and IMAPS retrieval using their own protected
  credential.
- Admin and Cluster Admin each sent to and retrieved replies from all five
  required machines, and exchanged mail with each other in both directions.

## Independent live review

The permanent service is active and enabled. `/srv/stalwart` is a real mount;
`/var/lib/stalwart` remains absent. Management is loopback-only on TCP 8080.
Submission and IMAPS listen only on `192.168.100.199` at TCP 587 and 993. No
SMTP 25, POP3, plaintext IMAP, or ManageSieve listener exists. The exact RCPT
selector is active, external relay remains disabled, and no
`cluster_admin@home.arpa` identity exists.

No DNS, certificate, listener, Fastmail, host-network, RouterOS, libvirt,
storage, identity, or credential mutation occurred under this packet.

```text
1.1.1 ALPHA-TO-BETA BLOCKER SATISFIED
BETA_ELIGIBLE=true
VERSION=1.1.1-alpha
```
