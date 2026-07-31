# Appliance export contract

The construction acceptance artifact is a portable, internally consistent
`mail-core` export—not a Matriarch disaster-recovery design or host backup.

The export manifest must identify, checksum, and version the following state:

- Stalwart startup configuration and managed configuration datastore;
- local identities, mailbox/message store, and outbound queue inventory;
- TLS certificates and keys;
- service-secret restoration reference (not the secret itself);
- Stalwart and guest software versions; and
- restore instructions plus source shutdown/quiesce state.

Create the export only after a controlled service quiesce or documented
Stalwart-consistent procedure. Record pre/post queue IDs and prevent delivery
while collecting the queue state. Validate by importing the artifact into an
isolated disposable target; do not overwrite a working appliance. Success is
readable state, known identity/mailbox counts, queue reconciliation, and no
delivery from the isolated target.

The export location is a protected operator-provided destination represented by
an opaque inventory reference. This repository neither selects the destination
nor configures Matriarch backup schedules.
