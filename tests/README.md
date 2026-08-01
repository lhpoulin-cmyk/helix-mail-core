# Test scope

Repository tests cover configuration syntax, obvious tracked secrets,
fail-closed relay and submission policy, Fastmail's disabled state, unresolved
production renders, backup-manifest structure, and the worker/evidence
handoff machinery.

The static suite does not retest the live beta appliance. Runtime acceptance is
recorded in [`../evidence/`](../evidence/): local delivery, trusted submission
and IMAPS, unauthorized machine-delivery rejection, external-relay rejection,
service and guest reboot persistence, mount-guard behavior, and physical
endpoint demonstrations have passed under their bounded packets.

`phase4-runtime-acceptance.sh` remains a guarded checklist and deliberately
does not discover or mutate a live target. A printed skip is not evidence that
the live tests are missing; it means this repository script has no standing
authorization to run them.

`test-worker-dispatch-static.sh` checks dispatcher and waiter guardrails without
contacting a real worker. `test-headless-finalization.sh` uses a disposable Git
clone with fake collector and Codex binaries. `test-host-evidence.sh` uses fake
observation commands to test fixed profiles, sanitization, hostile-PATH
resistance, path guards, failure retention, and evidence integrity.

`test-restore-structure.sh` checks only the manifest contract. An actual
appliance export and isolated restore are still unverified.
