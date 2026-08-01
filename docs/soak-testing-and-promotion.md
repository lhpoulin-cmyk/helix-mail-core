# Construction, soak testing, and promotion

The current appliance is `mail-core-9000` on Fedora 44 Matriarch. Its durable
identity is `mail.home.arpa`; its lifecycle is beta construction soak, not
production.

## Accepted soak start

The soak began at `2026-08-01T14:06:05-04:00` after forward DNS, trusted TLS,
local-mail acceptance, nine distinct onboarding bundles, dual Foundation
placement, all currently serviceable endpoint enrollments, and two explicit
endpoint deferrals. The minimum fourteen-day review point is
`2026-08-15T14:06:05-04:00`.

`ws-alpha` and `ws-wowzerwin` remain deferred. Their identities, credentials,
bundles, and custody records exist; their physical endpoint tests are not
claimed. The exact starting state is in
[`soak-start-manifest.md`](soak-start-manifest.md).

The later 1.1.1 release blocker added a stricter machine-delivery policy and
fresh demonstrations from five physical endpoints plus Admin and Cluster
Admin. That work made the repository beta-eligible and the operator promoted
it to `1.1.1-beta`. It did not restart the soak clock.

## What to observe

For at least fourteen continuous calendar days, retain real internal mail
traffic and record:

1. authenticated submission and mailbox retrieval;
2. machine-to-administrator reporting and administrative replies;
3. rejection of unauthorized machine delivery and external relay;
4. service and planned VM restart recovery;
5. queue depth, retries, and delivery failures;
6. disk, database, and mailbox growth;
7. failed authentication and unexpected listener changes;
8. certificate validity and renewal timing;
9. DNS consistency across both resolvers;
10. configuration changes and their evidence.

A significant safety fault, data-loss risk, material configuration redesign,
or unresolved relay behavior extends or restarts the relevant acceptance
period. A quiet calendar is useful; it is not, by itself, a test result.

## Gates that remain open

The current soak does not establish:

- enrollment of the two deferred physical endpoints;
- a consistent portable appliance export;
- an isolated import and restore proof;
- `APPLIANCE_EXPORT_REFERENCE`;
- durable or restart-safe Fastmail queue behavior;
- permanent hypervisor or production VM identity;
- migration, promotion readiness, or production readiness.

The active Fastmail bridge is a best-effort convenience path and is not part of
the authoritative local-mail soak. Its known restart limitation is not
backdated into the soak and does not block version 1.1.1-beta.

## Promotion-readiness report

At or after the minimum review point, create a private-evidence-backed report
covering dates, versions, identities exercised, message and queue activity,
restarts and outages, failures, changes, export/restore status, deferred hosts,
known limitations, and a recommendation to promote, extend, or reject.

The report is an input to a decision. It is not the decision.

## Handoff boundary

A promotion candidate requires a portable state artifact that preserves
`mail.home.arpa`, identities, mailboxes, queues, TLS, protected
secret-restoration references, versions, checksums, and restore instructions.
Production host selection, VM identifier, network attachment, and cutover are
separate work. Two active appliances must never share the same authoritative
mail state or service identity.
