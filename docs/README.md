# Documentation map

The repository keeps five kinds of writing. They serve different readers, and
mixing them usually produces a document that is friendly to nobody.

## Public narrative

- [`../README.md`](../README.md) — what the project is, what runs, and what does
  not.
- [`project-story.md`](project-story.md) — the chronological construction
  story and its lessons.
- [`release-status.md`](release-status.md) — the current beta and soak gates.
- [`soak-start-manifest.md`](soak-start-manifest.md) — the accepted soak start,
  archive hashes, and endpoint deferrals.
- [`CHANGELOG.md`](../CHANGELOG.md) — repository milestones.

These documents describe the current project in a human voice. They link to
the records rather than duplicating every command.

## Architecture and policy

- [`architecture.md`](architecture.md)
- [`identity-model.md`](identity-model.md)
- [`security-boundary.md`](security-boundary.md)
- [`fastmail-boundary.md`](fastmail-boundary.md)
- [`known-limitations.md`](known-limitations.md)
- [`backup-and-restore.md`](backup-and-restore.md)
- [`appliance-export.md`](appliance-export.md)
- [`migration.md`](migration.md)
- [`soak-testing-and-promotion.md`](soak-testing-and-promotion.md)

These explain what the system means and why its boundaries exist. They should
remain readable, but precision wins any argument with personality.

## Operator runbooks

- [`operator-runbook.md`](operator-runbook.md)
- [`kmail-admin-client.md`](kmail-admin-client.md)
- [`foreman-worker-loop.md`](foreman-worker-loop.md)
- [`promotion-readiness-report.template.md`](promotion-readiness-report.template.md)

Runbooks use neutral operational language. A joke is not a rollback method.

## Implementation packets

[`../implementation/`](../implementation/) contains bounded proposals,
preflights, commands, stop conditions, and authorization records. A packet
describes the state and authority at its own date. Read its status and its
matching evidence before treating it as current.

`implementation-packet.md` and `matriarch-target-inventory.md` are early
construction-era navigation records. They are retained because the route to a
working system matters, but their unresolved values are not the current beta
state.

## Evidence and historical records

[`../evidence/`](../evidence/) contains sanitized results from accepted work,
failed gates, rollbacks, and corrections. Evidence stays in the tense in which
it was recorded. Later acceptance does not make an earlier blocker false; it
makes it resolved.

Raw evidence, credentials, private keys, certificates containing private
material, message content, and decrypted bundles remain outside Git.
