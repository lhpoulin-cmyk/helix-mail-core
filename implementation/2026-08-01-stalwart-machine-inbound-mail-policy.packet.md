# Stalwart machine-inbound mail policy

Status: authorized 1.1.1 release-blocker implementation  
Target: `mail-core-9000` / Stalwart `0.16.15`

## Policy boundary

Only authenticated `admin@home.arpa` and `cluster-admin@home.arpa` may deliver
to local parts matching `hv-*` or `ws-*` in `home.arpa`. Machine senders remain
able to deliver to both administrative mailboxes. Administrative mailboxes may
deliver to every authorized local mailbox.

The rule applies to non-deferred and deferred machine identities. It does not
create or delete identities, aliases, routes, credentials, or messages. It does
not enable external relay, Fastmail, port 25, public administration, or any new
listener. The canonical identity is `cluster-admin@home.arpa`; the underscore
variant is prohibited.

## Current evidence and supported mechanism

The live `MtaStageRcpt` singleton has `allowRelaying=false`, no recipient
rewrite, and no selected script. No `SieveSystemScript` object currently
exists. Stalwart's live v0.16.15 schema exposes a mutable RCPT `script`
expression and `SieveSystemScript` objects with `name`, `description`,
`isActive`, and `contents`.

Official Stalwart RCPT-stage documentation confirms that a selected trusted
system Sieve script runs before message body acceptance, has access to
`env.authenticated_as` and `envelope.to`, and may issue a permanent `reject`.

## Exact render and staged activation

1. Dry-run and create only
   `config/stalwart/machine-inbound-policy-script.plan.ndjson`.
2. Query the created object and require the exact name and active state.
3. Before selecting it, exercise a safe compilation/activation check and stop
   if Stalwart reports a Sieve syntax or runtime error.
4. Dry-run and apply only
   `config/stalwart/machine-inbound-policy-selector.plan.ndjson`.
5. Require Stalwart to remain active and the RCPT selector to equal exactly
   `'machine-inbound-admin-only'`.

The script matches only `home.arpa` recipients whose local part begins `hv-` or
`ws-`. It rejects unless the authenticated identity is exactly one of the two
canonical administrative addresses. The rejection is permanent `550 5.7.1`
and occurs at RCPT before DATA.

## Immediate verification before demonstrations

Using protected existing credentials and trusted TLS:

- require Admin and Cluster Admin RCPT acceptance to every required and
  deferred machine identity;
- require machine-to-administrator acceptance;
- reject `hv-lore -> hv-katra` at RCPT;
- reject `ws-matriarch -> ws-hadrian` at RCPT;
- reject `test-sender` to at least one `hv-*` and one `ws-*` recipient at RCPT;
- prove rejected messages are absent from target mailboxes;
- require authenticated external relay rejection;
- require password mechanisms absent before TLS.

Only after those invariants pass, run the fresh five-machine and two-admin
send/reply/retrieval release-blocker demonstrations.

## Rollback

On unexpected rejection, acceptance, script error, service failure, or scope
drift, apply only
`config/stalwart/machine-inbound-policy-rollback.plan.ndjson`, require the RCPT
script selector to return to `false`, and preserve the inactive policy object
for evidence. Do not delete mail or identities as implicit rollback.

## Stop conditions

Stop for a dry-run beyond one script create or one singleton update, an existing
same-name script, a selector other than the exact reviewed name, failure to
reject before DATA, any rejection of machine-to-administrator mail, any
external relay acceptance, a plaintext credential path, or any mutation beyond
Stalwart's reviewed script and RCPT selector.
