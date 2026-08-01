# Fastmail best-effort external copy bridge packet

Status: beta limitation accepted; ordinary-path reactivation authorized
Baseline: `d1471330ea7964d148f6960cd50e62c957de86c2`
Target: `mail.home.arpa` / Stalwart `0.16.15`

## Purpose

Add one narrow external copy path for mail delivered to the two administrative
mailboxes:

- `admin@home.arpa`
- `cluster-admin@home.arpa`

The original message stays in its local mailbox. One independently queued copy
may go to the corresponding alias: `admin@poulin-arpa.com` or
`cluster_admin@poulin-arpa.com`. Fastmail is transport and off-site
visibility, not the authoritative mailbox, an inbound route, or an identity
source.

## Beta reclassification

The operator accepted the queue diagnosis at
`b7feec017c669ec93e09430637aab9f6e0b8f9df` and reclassified this feature for
version 1.1.1-beta as a **best-effort external copy bridge**. The original
durability requirements below are retained as historical design and test
context, but they no longer describe the beta acceptance gate.

The beta bridge does not claim durable store-and-forward, exactly-once
delivery, or restart-safe outbound queueing. An external copy may be lost if
Stalwart is stopped or restarted while that copy is in an active delivery
attempt. Local authoritative delivery is unaffected.

Beta acceptance requires only:

- immediate and unchanged local delivery;
- one normal authenticated TLS copy from each administrative mailbox to its
  corresponding approved Fastmail alias, accepted with SMTP 250;
- no copy for another local identity;
- rejection of arbitrary external recipients and general relay;
- no public SMTP listener;
- the protected file-backed credential remains unchanged;
- no forced interruption or restart test.

Before planned Stalwart restart or guest reboot, inspect the outbound queue. If
it is nonempty, wait for completion or explicitly accept possible loss of the
non-authoritative copies. Never replay automatically from uncertainty.

This packet does not authorize public SMTP, Fastmail-to-home.arpa delivery,
arbitrary external recipients, new identities, DNS changes, listener changes,
or use of a normal Fastmail account password.

## Evidence and supported design

The read-only discovery record is
`evidence/2026-08-01-fastmail-bridge-schema-discovery.md`. The running service is
Stalwart `0.16.15`; its management interface is loopback-only. The live schema
supports:

- a trusted `SieveSystemScript` selected by `MtaStageData.script`;
- RFC 3894 `redirect :copy`, which preserves implicit local delivery;
- a recipient-specific `MtaOutboundStrategy.route` expression;
- a `Relay` `MtaRoute` with implicit TLS, certificate validation, SMTP
  authentication, and a `File` secret source.

Before this reactivation, the DATA-stage selector is disabled. The existing
`machine-inbound-admin-only` script is attached at a different SMTP stage and
is not modified. The stable Fastmail route object remains installed but cannot
receive new copies while the selector is disabled.

A 2026-07-26 Katra Postfix canary is useful historical evidence, not a reusable
configuration. It reached `smtp.fastmail.com` over verified TLS, then failed
before authentication because that Postfix installation lacked a PLAIN/LOGIN
SASL client mechanism. Its shared `cluster_node@poulin-arpa.com` identity,
credential map, sender rewriting, and Postfix settings were rolled back and are
outside this packet. Stalwart supplies its own SMTP AUTH client, so the missing
Postfix SASL module is not a mail-core package dependency. The canary does not
waive the guest-local TLS, AUTH, sender-compatibility, or rollback gates below.

## Exact proposed policy

The repository-rendered plan is
`config/stalwart/fastmail-store-forward.plan.ndjson.template`. It creates:

1. `fastmail-admin-copy`, a trusted Sieve script that runs only for
   authenticated submission on local port 587. It matches an exact envelope
   recipient of `admin@home.arpa` or `cluster-admin@home.arpa` and performs one
   `redirect :copy` to its corresponding `poulin-arpa.com` alias.
2. `fastmail-admin-copy`, a Relay route to `smtp.fastmail.com:465` using SMTP,
   implicit TLS, normal certificate validation, SMTP username
   `louis@poulin-arpa.com`, the two exact delivery aliases, and a secret read from
   `/etc/stalwart/secrets/fastmail-app-password`.
3. An outbound route expression that selects that relay only when the queued
   recipient is exactly `admin@poulin-arpa.com` or
   `cluster_admin@poulin-arpa.com`, selects `local` for local
   domains, and otherwise selects `local` as a deliberate fail-closed sink.
   The ordinary `mx` route remains defined but is not selected.
4. The existing DATA-stage configuration with only its script expression
   changed for authenticated port-587 sessions.

The script creates at most one external copy per matched administrative
recipient, and therefore at most two when both appear in one envelope. The existing
submission limit remains ten messages per SMTP session, so the bridge adds at
most ten copies per accepted session. That is the initial volume cap; this is
an administrative visibility path, not a bulk-mail system wearing a small hat.
Routine bulk generation is not authorized. A later request for a different
recipient, class, or rate requires a new packet.

There is no return pipe, so a bridge copy cannot naturally loop. The additional
guards—authenticated submission, exact original recipients, exact external
recipient, and an otherwise fail-closed route—make that boundary explicit.

## Secret handling

Fastmail must supply a new mail-core-specific app password scoped to mail
access for SMTP login `louis@poulin-arpa.com`. The existing hypervisor fleet
uses a shared mail-only credential, but this packet does not read, copy, or
reuse it. Collect the new credential through the approved hidden local-entry
workflow. Do not put it in argv, environment variables, shell history, stdout,
chat, Git, evidence, or a plan file.

Install it through protected stdin into a temporary mode-0600 file, then
atomically install it in the guest as:

```text
/etc/stalwart/secrets/fastmail-app-password
owner=root
group=stalwart
mode=0640
```

The declarative object stores only the file path. Verify readability as the
`stalwart` service account without printing the file. A missing, empty,
misowned, or overly permissive file is a failed precondition; Stalwart must not
be reconfigured around it.

## Preflight and dry run

Before mutation:

1. Require the repository HEAD and clean worktree recorded by the eventual
   execution authorization.
2. Confirm Stalwart is exactly `0.16.15`, `/srv/stalwart` is mounted, the mount
   guard is effective, and authoritative state remains there.
3. Snapshot, without secrets, `SieveSystemScript`, `MtaRoute`,
   `MtaOutboundStrategy`, `MtaStageData`, and `SieveSystemInterpreter`.
4. Require the snapshot to match the sanitized discovery baseline: one existing
   machine-inbound script, only `local` and `mx` routes, DATA-stage scripting
   disabled, redirects limited to at least one, and no Fastmail object.
5. Confirm public port 25 and public administration remain absent; 587 and 993
   retain their accepted TLS-only behavior.
6. Confirm DNS and TLS health for `smtp.fastmail.com` from the guest without
   authenticating.
7. Collect the dedicated app password through hidden entry and install the
   protected secret file.
8. Run `stalwart-cli apply --dry-run` against a private rendered copy of the
   plan. Require exactly two creates and two singleton updates, with no delete,
   identity, listener, domain, certificate, or datastore operation.
9. Review the complete dry-run. A schema mismatch or larger delta stops.

## Compatibility gate

Fastmail may reject a transparently redirected message whose visible `From`
identity is not a verified Fastmail sending identity. Do not solve that by
silently rewriting the locally retained message or weakening Fastmail policy.

Before general activation, apply the plan under a bounded test window and send
one uniquely identified, non-secret local test message from
`admin@home.arpa` to `cluster-admin@home.arpa`. Require:

- immediate local delivery and retrieval;
- one queued copy addressed only to the matching `poulin-arpa.com` alias;
- successful authenticated TLS handoff to Fastmail;
- receipt in the intended Fastmail mailbox;
- no change to the local message's visible sender or content;
- no second copy and no loop.

If Fastmail rejects the original visible sender or another transparent-copy
property, roll back this plan and record the exact SMTP status. The correction
is a separately reviewed rewrapping bridge, not sender forgery disguised as a
quick fix.

## Historical apply, verification, and outage test

This section records the stronger original gate. Its forced-interruption and
restart portion is superseded for 1.1.1-beta by the beta reclassification
above.

After the compatibility gate passes:

1. Apply exactly the reviewed private plan and reload Stalwart through its
   supported management action.
2. Repeat one copy test for each source mailbox, using distinct non-secret test
   identifiers and only the approved Fastmail recipient.
3. Temporarily make the relay destination unavailable using a service-local,
   reversible test mechanism that changes neither DNS nor networking. Submit a
   local test message to an administrative mailbox.
4. Prove local delivery and retrieval complete while the external copy remains
   visible in Stalwart's persistent queue on `/srv/stalwart`.
5. Remove the test condition, prove retry delivers the queued copy, and confirm
   the queue drains without duplicate delivery.
6. Prove another local recipient causes no Fastmail copy, a direct submission
   to another external recipient is rejected, and sender impersonation remains
   rejected.
7. Prove public SMTP, Fastmail inbound transport, and all unapproved listeners
   remain absent.
8. Restart Stalwart and reboot the guest. Recheck the mount guard, local mail,
   route, secret-file permissions, queue, TLS listeners, and host health.

Queue failures must be observable by the operator. The execution record must
include queue identifiers, timestamps, SMTP status classes, retry state, and
final disposition, but no credentials, AUTH exchange, or message content.

## Rollback

Keep the pre-change secret-stripped snapshot and a private rollback plan.
Rollback performs only:

1. disable the Fastmail `MtaStageData` script selector so no new copies form;
2. preserve the recipient-specific route while any existing queue entry is
   unresolved; remove it only after the queue is empty or explicitly
   dispositioned;
3. reload and prove local delivery still works and all external delivery is
   rejected;
4. remove the Fastmail secret file only after configuration no longer
   references it;
5. retain or disposition already accepted external queue entries explicitly—do
   not silently discard them.

If local delivery, TLS verification, authentication, recipient restriction, or
rollback fails, stop with the bridge disabled. Restart-safe queue persistence
is a documented beta limitation rather than an acceptance requirement.

## Execution gate

The operator authorized ordinary-path reactivation after documentation review.
No forced outage or restart test is authorized under the beta gate.
