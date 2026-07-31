# Foreman / worker loop

The foreman and worker never edit concurrently. The foreman reviews a committed packet, dispatches it, and waits. The worker makes only packet-authorized changes, commits, writes a factual ignored result, and stops. The foreman reviews only that committed result.

`scripts/dispatch-worker` accepts exactly one packet path (or `--dry-run` plus one path). It refuses a dirty worktree, absent packet, missing worker pane, or a pane that does not appear to be running Codex. It uses a temporary tmux buffer and sends only the fixed worker instruction plus the packet path; it never sends approvals, confirmations, secrets, passwords, or permission grants.

The worker result is ignored and must use this minimum form:

```text
Starting commit: <full commit hash reported by dispatch>
Ending commit: <full committed hash>
Packet: implementation/<packet>.packet.md
Validation: <commands and factual outcomes>
Changed files: <factual list>
Live mutation: none | <explicitly authorized action>
```

`handoff/dispatch-state.env` and `handoff/worker-result.md` are the only ignored handoff state. They must never contain secrets or private raw evidence.

After operator review, first prove the action without sending it:

```sh
scripts/dispatch-worker --dry-run implementation/<approved-packet>.packet.md
```

With a clean worktree and an approved packet, dispatch and wait:

```sh
scripts/dispatch-worker implementation/<approved-packet>.packet.md
scripts/wait-worker-result --timeout 1800
```

The waiter requires a result newer than the dispatch state, a matching starting commit, and an ending commit that exists locally. Timeout is a clean failure; it never sends input to the worker.
