# Construction, soak testing, and promotion

Construction placement is `hv-matriarch / mail-core / VMID 9000`. Its
lifecycle state is **construction / soak testing**. This placement is temporary;
the durable identity is always `mail.home.arpa`.

## Soak-entry gate

The two-week clock begins only after the appliance has passed and recorded all
initial local acceptance tests: authenticated submission and local IMAPS
retrieval with disposable identities, rejected unauthorized relay, service and
VM reboot recovery, queue persistence, Internet-outage local delivery, and a
documented backup/restore status. A passing test does not authorize promotion.

During at least fourteen continuous calendar days, retain real internal mail
traffic and observe authenticated submission, mailbox delivery, identity
isolation, service/VM reboot recovery, queues, disk/mailbox growth, failed
authentication, certificates, backup freshness, restore viability, Internet
outages, and (only if later authorized) Fastmail relay behavior. Significant
faults, data-loss risk, unresolved relay behavior, or a configuration redesign
restarts or extends the period.

## Promotion-readiness report

At soak completion create a private-evidence-backed report containing:

1. soak start and end dates;
2. software versions;
3. identities exercised;
4. message and queue activity;
5. outages and restarts tested;
6. failures or unexpected behavior;
7. changes made during testing;
8. backup and restore status;
9. known limitations; and
10. recommendation: promote, extend, or reject.

## Promotion change

A separately approved change selects the permanent hypervisor and production
VMID; transfers or restores all persistent state; preserves `mail.home.arpa`;
places it on approved storage/networking; verifies identities, mailboxes,
queues, TLS, and backups; proves local delivery and no lost/duplicated
messages; then archives or removes VM 9000 only after success.
