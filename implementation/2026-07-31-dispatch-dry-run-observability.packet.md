# Dispatch dry-run observability correction packet

Status: repository changes and fake-only tests only

Do not collect host evidence, execute Codex, launch tmux, or make VM, sudo,
SSH, network, DNS, certificate, service, or Fastmail changes.

Refactor `scripts/dispatch-worker --dry-run` to compute and display a complete,
side-effect-free prospective plan. Support `--format=json`; no shell-assembled
launch command may be printed. The plan exposes packet, start commit, labeled
prospective run ID/session/root/run/evidence/manifest/prompt/result paths,
selected profile, test-command-root state, every authorization-sensitive flag,
and supervisor executable plus indexed argv. It prints the exact generated
prompt. A profiled prompt names authoritative supervisor-verified evidence and
manifest, forbids host retries/evidence modification, retains inconclusive
values, and preserves packet sole authority. An unprofiled plan must make no
false evidence claim.

Dry run must create no run/marker/prompt/metadata/evidence, reserve no ID,
launch no tmux/Codex, and change no Git state. Production output states
`test_command_root_enabled: false`; packets/environment cannot add arguments,
profile values, command roots, or secrets.

Use fake-only tests for no side effects, profiled/unprofiled JSON/text plans,
paths/manifest, argv representation, complete prompt restrictions, hostile
packet/environment injection, and no test root. Run all existing collector,
supervisor, waiter, policy, render, restore, validation, and whitespace checks.
Commit one bounded implementation change, write a factual result, and stop.
