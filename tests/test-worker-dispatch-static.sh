#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'status=$?; rm -rf "$scratch"; exit "$status"' EXIT HUP INT TERM
repo=$scratch/repo
git clone -q "$root" "$repo"
cp "$root/scripts/dispatch-worker" "$repo/scripts/dispatch-worker"
git -C "$repo" add scripts/dispatch-worker
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit --amend -q --no-edit
start=$(git -C "$repo" rev-parse HEAD)
prompt=$(cd "$repo" && "$repo/scripts/dispatch-worker" --dry-run implementation/2026-07-31-worker-result-format-correction.packet.md)
printf '%s\n' "$prompt" | grep -qx "Starting commit: $start"
printf '%s\n' "$prompt" | grep -Fqx 'Ending commit: <full 40-lowercase-hex ending commit>'
printf '%s\n' "$prompt" | grep -Fqx 'The result must contain exactly one plain, unbackticked, standalone full 40-lowercase-hex line for each commit, in these forms:'
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
rg -q 'parse_result_commit' "$root/scripts/wait-worker-result"
rg -q 'does not permit creation or mutation' "$root/scripts/dispatch-worker"
rg -q 'HOST_EVIDENCE_PROFILE' "$root/scripts/dispatch-worker"
rg -q 'verify_evidence' "$root/scripts/supervise-worker-headless"
rg -q 'manifest.sha256' "$root/scripts/collect-matriarch-readonly"
rg -q -- '--test-command-root' "$root/scripts/collect-matriarch-readonly"
rg -q 'Do not run host-inspection commands' "$root/scripts/dispatch-worker"
rg -q 'evidence is only at' "$root/scripts/dispatch-worker"
rg -q -- '--format=json' "$root/scripts/dispatch-worker"
rg -q 'test_command_root_enabled: false' "$root/scripts/dispatch-worker"
rg -q 'supervisor_argv' "$root/scripts/dispatch-worker"
! rg -q 'would launch detached headless codex exec' "$root/scripts/dispatch-worker"
"$root/tests/test-headless-finalization.sh"
"$root/tests/test-wait-worker-result.sh"
echo 'PASS headless worker static assertions'
