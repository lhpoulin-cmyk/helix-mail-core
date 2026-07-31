#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
for f in scripts/collect-matriarch-readonly scripts/dispatch-worker scripts/run-worker-headless scripts/supervise-worker-headless scripts/wait-worker-result; do sh -n "$root/$f"; done
! rg -q 'send-keys|paste-buffer|pane_current_command' "$root/scripts"
rg -q 'tmux new-session -d' "$root/scripts/dispatch-worker"
rg -q -- '--sandbox workspace-write' "$root/scripts/run-worker-headless"
rg -q -- '--ephemeral' "$root/scripts/run-worker-headless"
rg -q 'scripts/supervise-worker-headless' "$root/scripts/dispatch-worker"
! rg -q 'collect-matriarch-readonly' "$root/scripts/run-worker-headless"
rg -q 'collect-matriarch-readonly' "$root/scripts/supervise-worker-headless"
rg -q 'codex-exit-status' "$root/scripts/supervise-worker-headless"
rg -q 'failure-stage' "$root/scripts/supervise-worker-headless"
rg -q 'worker-result.md' "$root/scripts/wait-worker-result"
rg -q 'invalid ending commit' "$root/scripts/wait-worker-result"
rg -q "tr -d" "$root/scripts/wait-worker-result"
rg -q 'does not permit creation or mutation' "$root/scripts/dispatch-worker"
rg -q 'HOST_EVIDENCE_PROFILE' "$root/scripts/dispatch-worker"
rg -q 'verify_evidence' "$root/scripts/supervise-worker-headless"
rg -q 'manifest.sha256' "$root/scripts/collect-matriarch-readonly"
"$root/tests/test-headless-finalization.sh"
echo 'PASS headless worker static assertions'
