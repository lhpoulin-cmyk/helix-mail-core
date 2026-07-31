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

The worker is run as `codex exec --sandbox workspace-write --ephemeral`; no
dangerous bypass flags or network-enabling settings are used. Human approval
boundaries remain unchanged. The packet remains task authority.

After dispatch, use `scripts/wait-worker-result --timeout 1800 <RUN_ID>`. It
only verifies handoff integrity; it never accepts work. A stale active marker
must be removed manually only after confirming its tmux session no longer
exists and that no worker process remains. Do not kill an apparently active
worker automatically.
