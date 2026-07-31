#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
for f in scripts/dispatch-worker scripts/run-worker-headless scripts/wait-worker-result; do sh -n "$root/$f"; done
! rg -q 'send-keys|paste-buffer|pane_current_command' "$root/scripts"
rg -q 'tmux new-session -d' "$root/scripts/dispatch-worker"
rg -q -- '--sandbox workspace-write' "$root/scripts/run-worker-headless"
rg -q -- '--ephemeral' "$root/scripts/run-worker-headless"
rg -q 'starting commit mismatch' "$root/scripts/run-worker-headless"
rg -q 'worker-result.md' "$root/scripts/wait-worker-result"
rg -q 'invalid ending commit' "$root/scripts/wait-worker-result"
rg -q "tr -d" "$root/scripts/wait-worker-result"
rg -q 'does not permit creation or mutation' "$root/scripts/dispatch-worker"
echo 'PASS headless worker static assertions'
