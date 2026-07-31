# Helix-ARPA mail core

Internal-only local mail plane for `home.arpa`, using Stalwart Mail Server.
It is a deployment contract and rendered proposal, not a declaration that a
mail service is live. Fastmail is disabled by design until a separate explicit
activation packet.

## Current state

- Phase 0 inventory: placement is unresolved. Historical `hv-matriarch`
  records map to a deployed `hv-matrix`, which is not silently substituted.
- Phase 1 foundation: complete and validation-ready.
- Phase 2: render only; live VM, DNS, firewall, identities, certificates, and
  relay remain uncreated.

Run `scripts/validate/all.sh` for static checks. Copy
`inventory/production/values.env.example` to the ignored `values.env`, replace
only values established by an approved packet, then run
`scripts/render/render.sh inventory/production/values.env`.

No runtime data belongs in this repository. See `docs/operator-runbook.md` and
`docs/backup-and-restore.md` before implementation.

