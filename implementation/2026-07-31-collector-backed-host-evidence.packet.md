# Collector-backed host evidence correction packet

Status: approved repository-only implementation and test work

## Authority and boundaries

Implement and test repository scripts only. Do not collect real host evidence
in this packet. Do not create a VM, mutate a host, use SSH, sudo, su, pkexec,
polkit automation, package/service/network/DNS/certificate changes, privilege
or group changes. Preserve commits `50fd8a8` and its handoff result.

## Required implementation

Add `scripts/collect-matriarch-readonly` and refactor dispatch so a run with
the exact metadata-only profile `HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1`
creates `handoff/runs/<RUN_ID>/host-evidence/`, collects fixed local-user
evidence before Codex starts, verifies its hash manifest before launch and
again after Codex exits, then fails handoff on missing, changed, or added
evidence. The worker must treat collected evidence as authoritative and must
not retry host inspection.

The collector must accept no commands from packets, prompts, environment,
model output, or evidence. Use only a hard-coded allowlist, timeout every
observation, continue after individual failures, reject symlink/path escapes
and nonempty destinations, and write only under the run evidence directory.
Record command identifier, sanitized representation, start/finish UTC times,
exit status, stdout, stderr, and one of `observed`, `unavailable`,
`permission-denied`, `timed-out`, or `failed`. Write a manifest with hashes of
every evidence file. Raw evidence stays Git-ignored.

The initial fixed profile covers host/Fedora/kernel/time state, `/dev/kvm`,
`virsh --readonly` system and session version/list/network/pool queries,
unprivileged IP/bridge/NM/resolver/mount state, and libvirt service status.
Sanitize or fingerprint MACs, serials, UUIDs, and other unnecessary stable
identifiers. Never collect environment dumps, credentials, SSH material,
browser/process state, unrelated files, mail, or secrets.

Update `docs/foreman-worker-loop.md`, add the exact profile declaration to the
existing inventory packet, and retain all existing authorization boundaries.

## Tests and completion

Tests use fake commands and fake tmux/Codex only; they never inspect the real
host. Cover injection from packet/environment, no privilege executable,
timeouts, dry run, path/symlink escapes, retained partial failures, concurrent
runs, pre/post hash changes including worker replacement, nonzero Codex exit,
and the existing fail-closed inventory render. Run all repository validation,
commit one bounded implementation change, and write the normal structured
handoff result. Do not create another packet or approve the work.
