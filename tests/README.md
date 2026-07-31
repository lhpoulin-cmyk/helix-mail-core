# Test scope

Static tests cover configuration syntax, obvious tracked secrets, fail-closed
relay/submission policy, Fastmail disabled state, and rejection of unresolved
production renders. Runtime results remain unpassed until an authorized VM and
disposable identities exist: local delivery, unauthorized relay rejection,
restart persistence, backup structure validation, and reboot recovery.

`test-worker-dispatch-static.sh` checks dispatcher and waiter guardrails without
contacting tmux.

`test-headless-finalization.sh` uses a disposable Git clone with fake collector
and Codex binaries to cover finalization, evidence failures, signals, atomic
metadata, and missing-result rejection. It never invokes host observation
commands or a real Codex service.

`test-host-evidence.sh` uses only fake observation commands and a fake Codex
binary to verify the fixed collector profile, failure retention, path guards,
concurrent destinations, and pre/post evidence integrity checks.

`phase4-runtime-acceptance.sh` is the guarded runtime checklist; it deliberately
skips until its explicitly authorized target exists. `test-restore-structure.sh`
checks the backup-manifest contract non-destructively.
