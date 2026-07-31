#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
dispatch=$root/scripts/dispatch-worker
waiter=$root/scripts/wait-worker-result
sh -n "$dispatch" "$waiter"
grep -q 'mail-worker:0.0' "$dispatch"
if grep -q 'HELIX_WORKER_TMUX_TARGET' "$dispatch"; then
  echo 'dispatcher permits a non-dedicated tmux target' >&2
  exit 1
fi
grep -q 'load-buffer' "$dispatch"
grep -q 'paste-buffer' "$dispatch"
grep -q 'send-keys.*Enter' "$dispatch"
grep -q 'git status --porcelain --untracked-files=all' "$dispatch"
grep -q -- '--ignored=matching' "$dispatch"
grep -q 'START_COMMIT=' "$dispatch"
grep -q 'Starting commit:' "$waiter"
grep -q 'Ending commit:' "$waiter"
grep -q -- '--timeout' "$waiter"
echo 'PASS worker dispatch static assertions'
