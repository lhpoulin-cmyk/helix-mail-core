# Foreman / worker loop

Each packet gets a fresh, disposable headless Codex worker. Tmux is only the
process supervisor and observation surface; no interactive TUI or keystroke
injection is used. The foreman dispatches only from a clean worktree, then
waits and reviews only committed results.

`scripts/dispatch-worker [--dry-run] implementation/<packet>.packet.md` creates
an ignored `handoff/runs/<RUN_ID>/` with the packet path, start commit, prompt,
log, worker result, exit status, and timestamps. A real dispatch starts
`mail-worker-<RUN_ID>`. Inspect it with `tmux attach -t mail-worker-<RUN_ID>`;
detaching does not terminate the worker.

The tmux command is the trusted outer supervisor, not Codex itself. It writes
`started-at` before preflight, collects any approved evidence before Codex is
launched, and atomically records `failure-stage`, `codex-exit-status`,
`finished-at`, and overall `exit-status` on ordinary and TERM/INT exits.
`scripts/run-worker-headless` is deliberately the Codex-only execution path:
it cannot invoke the collector. A zero Codex exit without `worker-result.md`
is a failed run. SIGKILL, host loss, and any unknown completion state are never
accepted as completion.

Packets that declare the exact metadata-only line
`HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1` receive a fresh
`host-evidence/` directory before Codex starts. The fixed collector uses only
its hard-coded, timed, unprivileged read-only allowlist; packets, prompts,
environment values, and model output cannot add commands. It records sanitized
per-command results and hashes every evidence file in `manifest.sha256`. The
worker verifies that manifest before launch and after exit, and fails the
handoff if evidence is missing, changed, symlinked, or added. Evidence is
authoritative for that run; the worker must not repeat host inspection. Raw
evidence is ignored and remains local.

The worker is run as `codex exec --sandbox workspace-write --ephemeral`; no
dangerous bypass flags or network-enabling settings are used. Human approval
boundaries remain unchanged. The packet remains task authority.

After dispatch, use `scripts/wait-worker-result --timeout 1800 <RUN_ID>`. It
rejects missing or malformed finalization metadata and only verifies handoff
integrity; it never accepts work. A stale active marker
must be removed manually only after confirming its tmux session no longer
exists and that no worker process remains. Do not kill an apparently active
worker automatically.
