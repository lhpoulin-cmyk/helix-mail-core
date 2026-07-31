# Headless run finalization correction packet

Status: repository-only repair and fake-run tests

Implement a trusted outer supervisor separate from `codex exec`. It must collect
approved host evidence before Codex launch; the Codex execution path must never
invoke the collector. No real host collection, VM action, sudo, SSH, su, pkexec,
polkit, package/service/network/DNS/certificate change, or Codex service call is
authorized while implementing or testing this packet.

The supervisor writes `started-at` before any fallible operation, records a
failure stage, captures exact child status in `codex-exit-status`, and writes
overall `exit-status` plus `finished-at` with temporary-file atomic renames on
every ordinary or handled exit. Handle TERM and INT; never claim completion
after SIGKILL, host loss, or another unknown-status condition. A zero Codex exit
without `worker-result.md` is an overall nonzero failure. A vanished tmux
session without final metadata remains invalid. Do not infer or manufacture
completion state.

Add fake-only tests for successful valid results, missing results, nonzero
Codex, collector/preflight and evidence pre/post failures, TERM during
collection/Codex, INT, atomic metadata, exact child-status preservation,
missing-metadata rejection, and absence of real host commands, privilege tools,
SSH, and real Codex calls. Update documentation. Commit one bounded repair and
write the structured result; do not create further packets or approve work.
