# Test scope

Static tests cover configuration syntax, obvious tracked secrets, fail-closed
relay/submission policy, Fastmail disabled state, and rejection of unresolved
production renders. Runtime results remain unpassed until an authorized VM and
disposable identities exist: local delivery, unauthorized relay rejection,
restart persistence, backup structure validation, and reboot recovery.

`phase4-runtime-acceptance.sh` is the guarded runtime checklist; it deliberately
skips until its explicitly authorized target exists. `test-restore-structure.sh`
checks the backup-manifest contract non-destructively.
