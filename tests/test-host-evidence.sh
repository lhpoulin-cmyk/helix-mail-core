#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'status=$?; rm -rf "$scratch"; exit "$status"' EXIT HUP INT TERM
fakebin=$scratch/fake-bin
fakeroot=$scratch/fake-command-root
mkdir -p "$fakebin" "$fakeroot/usr/bin"

for command in hostnamectl cat uname date test virsh ip bridge nmcli resolvectl findmnt systemctl; do
  cat >"$fakebin/$command" <<'EOF'
#!/bin/sh
printf '%s %s\n' "$(basename "$0")" "$*" >>"$FAKE_LOG"
case "$(basename "$0")" in
  virsh) [ "${FAKE_VIRSH_FAIL-}" != 1 ] || { echo 'permission denied' >&2; exit 1; };;
esac
[ "${FAKE_TIMEOUT_COMMAND-}" != "$(basename "$0")" ] || exit 124
printf 'sample 00:11:22:33:44:55 123e4567-e89b-12d3-a456-426614174000\n'
EOF
  chmod +x "$fakebin/$command"
done
cat >"$fakebin/timeout" <<'EOF'
#!/bin/sh
duration=$1
shift
if [ "${FAKE_TIMEOUT_COMMAND-}" = "$1" ]; then exit 124; fi
exec "$@"
EOF
chmod +x "$fakebin/timeout"
for command in hostnamectl cat uname date test virsh ip bridge nmcli resolvectl findmnt systemctl; do cp "$fakebin/$command" "$fakeroot/usr/bin/$command"; done

run_collector() {
  PATH="$fakebin:$PATH" FAKE_LOG="$scratch/commands.log" HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1 "$root/scripts/collect-matriarch-readonly" --test-command-root "$fakeroot" "$1"
}

mkdir "$scratch/evidence"
if HOST_EVIDENCE_PROFILE='packet; injected-command' "$root/scripts/collect-matriarch-readonly" --test-command-root "$fakeroot" "$scratch/evidence" >/dev/null 2>&1; then
  echo 'FAIL environment profile injection accepted' >&2; exit 1
fi
touch "$scratch/evidence/unexpected"
if HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1 "$root/scripts/collect-matriarch-readonly" --test-command-root "$fakeroot" "$scratch/evidence" >/dev/null 2>&1; then
  echo 'FAIL nonempty evidence destination accepted' >&2; exit 1
fi
rm -rf "$scratch/evidence"
mkdir "$scratch/real"; ln -s "$scratch/real" "$scratch/link"
if run_collector "$scratch/link" >/dev/null 2>&1; then
  echo 'FAIL symlink evidence destination accepted' >&2; exit 1
fi

FAKE_TIMEOUT_COMMAND=hostnamectl run_collector "$scratch/evidence-one" >/dev/null
grep -q 'outcome: timed-out' "$scratch/evidence-one/evidence-01-hostnamectl.txt"
grep -q 'outcome: observed' "$scratch/evidence-one/evidence-02-fedora-release.txt"
grep -q '\[MAC-REDACTED\]' "$scratch/evidence-one/evidence-02-fedora-release.txt"
grep -q 'evidence_mode: test-only' "$scratch/evidence-one/evidence-01-hostnamectl.txt"
! grep -Eq 'sudo|su |pkexec' "$scratch/commands.log"
FAKE_VIRSH_FAIL=1 run_collector "$scratch/evidence-two" >/dev/null
grep -q 'outcome: permission-denied' "$scratch/evidence-two/evidence-06-system-version.txt"
[ -f "$scratch/evidence-two/manifest.sha256" ]
(cd "$scratch/evidence-two" && sha256sum -c manifest.sha256 >/dev/null)
run_collector "$scratch/evidence-three" >/dev/null & first=$!
run_collector "$scratch/evidence-four" >/dev/null & second=$!
wait "$first"; wait "$second"
[ -f "$scratch/evidence-three/manifest.sha256" ] && [ -f "$scratch/evidence-four/manifest.sha256" ]
if HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1 "$root/scripts/collect-matriarch-readonly" --test-command-root relative "$scratch/nope" >/dev/null 2>&1; then echo 'FAIL relative test root accepted' >&2; exit 1; fi
mkdir "$scratch/test-root-target"; ln -s "$scratch/test-root-target" "$scratch/test-root-link"
if HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1 "$root/scripts/collect-matriarch-readonly" --test-command-root "$scratch/test-root-link" "$scratch/nope" >/dev/null 2>&1; then echo 'FAIL symlink test root accepted' >&2; exit 1; fi
rm "$fakeroot/usr/bin/virsh"
run_collector "$scratch/evidence-missing" >/dev/null
grep -q 'outcome: unavailable' "$scratch/evidence-missing/evidence-06-system-version.txt"

# Exercise the runner in a clean disposable clone, with fake Codex and fake
# observations. This covers pre/post manifest checks and worker exit behavior.
repo=$scratch/repo
git clone -q "$root" "$repo"
cp "$root/scripts/collect-matriarch-readonly" "$repo/scripts/collect-matriarch-readonly"
cp "$root/scripts/run-worker-headless" "$repo/scripts/run-worker-headless"
cp "$root/scripts/supervise-worker-headless" "$repo/scripts/supervise-worker-headless"
cp "$root/scripts/dispatch-worker" "$repo/scripts/dispatch-worker"
cp "$root/implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md" "$repo/implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md"
git -C "$repo" add scripts/collect-matriarch-readonly scripts/run-worker-headless scripts/supervise-worker-headless scripts/dispatch-worker implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md
if ! git -C "$repo" diff --cached --quiet; then git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit -qm 'test collector harness'; fi
cat >"$fakebin/codex" <<'EOF'
#!/bin/sh
if [ "${FAKE_CODEX_ACTION-}" = replace-evidence ]; then
  printf 'replacement\n' >"$HELIX_RUN_DIR/host-evidence/evidence-01-hostnamectl.txt"
fi
exit "${FAKE_CODEX_STATUS-0}"
EOF
chmod +x "$fakebin/codex"
make_run() {
  run=$1
  mkdir "$run"
  git -C "$repo" rev-parse HEAD >"$run/start-commit"
  printf '%s\n' matriarch-libvirt-readonly-v1 >"$run/host-evidence-profile"
  : >"$run/prompt.txt"
}
make_run "$scratch/run-changed"
if (cd "$repo" && PATH="$fakebin:$PATH" FAKE_LOG="$scratch/runner.log" FAKE_CODEX_ACTION=replace-evidence HELIX_RUN_DIR="$scratch/run-changed" "$repo/scripts/supervise-worker-headless"); then
  echo 'FAIL worker evidence replacement accepted' >&2; exit 1
fi
make_run "$scratch/run-nonzero"
if (cd "$repo" && PATH="$fakebin:$PATH" FAKE_LOG="$scratch/runner.log" FAKE_CODEX_STATUS=7 HELIX_RUN_DIR="$scratch/run-nonzero" "$repo/scripts/supervise-worker-headless"); then
  echo 'FAIL nonzero Codex exit accepted' >&2; exit 1
fi
[ "$(cat "$scratch/run-nonzero/exit-status")" = 7 ]

# Prompt construction is tested with a fake tmux that never launches a worker.
tmuxbin=$scratch/tmux-bin
mkdir "$tmuxbin"
cat >"$tmuxbin/tmux" <<'EOF'
#!/bin/sh
printf 'tmux %s\n' "$*" >>"$FAKE_LOG"
exit 0
EOF
chmod +x "$tmuxbin/tmux"
(cd "$repo" && PATH="$tmuxbin:$PATH" FAKE_LOG="$scratch/dispatch.log" "$repo/scripts/dispatch-worker" implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md >/dev/null)
profiled=$(find "$repo/handoff/runs" -mindepth 1 -maxdepth 1 -type d | head -1)
grep -q 'This is a profiled evidence run' "$profiled/prompt.txt"
grep -q 'Do not run host-inspection commands' "$profiled/prompt.txt"
rm -f "$repo/handoff/active-run"
(cd "$repo" && PATH="$tmuxbin:$PATH" FAKE_LOG="$scratch/dispatch.log" "$repo/scripts/dispatch-worker" implementation/2026-07-31-headless-run-finalization.packet.md >/dev/null)
unprofiled=$(find "$repo/handoff/runs" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
! grep -q 'This is a profiled evidence run' "$unprofiled/prompt.txt"
rm -f "$repo/handoff/active-run"

# Dispatcher dry-run is a complete plan only: fake-only inspection proves it
# creates no handoff state, launches no fake tmux, and never enables a test root.
before_runs=$(find "$repo/handoff/runs" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
before_status=$(git -C "$repo" status --porcelain --untracked-files=all)
: >"$scratch/dispatch.log"
if ! (cd "$repo" && HOST_EVIDENCE_PROFILE='attacker-value' "$repo/scripts/dispatch-worker" --dry-run --format=json implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md >"$scratch/profiled-plan.json"); then
  echo 'FAIL exact packet profile was not accepted' >&2; exit 1
fi
jq -e '.dry_run == true and .selected_profile == "matriarch-libvirt-readonly-v1" and .test_command_root_enabled == false' "$scratch/profiled-plan.json" >/dev/null
jq -e '.paths.run | test("/handoff/runs/[^/]+$")' "$scratch/profiled-plan.json" >/dev/null
jq -e '.paths.evidence | endswith("/host-evidence")' "$scratch/profiled-plan.json" >/dev/null
jq -e '.paths.manifest | endswith("/host-evidence/manifest.sha256")' "$scratch/profiled-plan.json" >/dev/null
jq -e '.supervisor.executable | endswith("/scripts/supervise-worker-headless")' "$scratch/profiled-plan.json" >/dev/null
jq -e '.supervisor.argv[0] == "env" and (.supervisor.argv[1] | startswith("HELIX_RUN_DIR=")) and (.supervisor.argv[2] == .supervisor.executable)' "$scratch/profiled-plan.json" >/dev/null
jq -e '.authorization_sensitive_flags.run_directory_creation_enabled == false and .authorization_sensitive_flags.active_marker_creation_enabled == false and .authorization_sensitive_flags.evidence_collection_enabled == false and .authorization_sensitive_flags.tmux_launch_enabled == false and .authorization_sensitive_flags.codex_invocation_enabled == false and .authorization_sensitive_flags.git_mutation_enabled == false' "$scratch/profiled-plan.json" >/dev/null
jq -e '.prompt | contains("authoritative, supervisor-verified host\nevidence") and contains("Do not run host-inspection commands") and contains("Do not modify evidence, retry or supplement collection") and contains("or resolve inconclusive evidence") and contains("packet is the sole task authority")' "$scratch/profiled-plan.json" >/dev/null
after_runs=$(find "$repo/handoff/runs" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)
[ "$before_runs" = "$after_runs" ] || { echo 'FAIL dry run created a run' >&2; exit 1; }
[ "$before_status" = "$(git -C "$repo" status --porcelain --untracked-files=all)" ] || { echo 'FAIL dry run changed Git state' >&2; exit 1; }
[ ! -s "$scratch/dispatch.log" ] || { echo 'FAIL dry run invoked fake tmux' >&2; exit 1; }

if ! (cd "$repo" && HOST_EVIDENCE_PROFILE='attacker-value' "$repo/scripts/dispatch-worker" --dry-run implementation/2026-07-31-headless-run-finalization.packet.md >"$scratch/unprofiled-plan.txt"); then
  echo 'FAIL unprofiled dry run was rejected' >&2; exit 1
fi
grep -q '^selected_profile: none$' "$scratch/unprofiled-plan.txt"
grep -q '^test_command_root_enabled: false$' "$scratch/unprofiled-plan.txt"
grep -q '^supervisor_argv:$' "$scratch/unprofiled-plan.txt"
grep -q '^prompt:$' "$scratch/unprofiled-plan.txt"
! grep -q 'authoritative, supervisor-verified host' "$scratch/unprofiled-plan.txt"
! grep -q 'tmux new-session\|codex exec\|--test-command-root' "$scratch/unprofiled-plan.txt"

packet=$scratch/injected.packet.md
printf '%s\n' 'HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1; evil' >"$packet"
cp "$packet" "$repo/implementation/test-injected-profile.packet.md"
git -C "$repo" add implementation/test-injected-profile.packet.md
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit -qm 'test invalid profile packet'
if (cd "$repo" && "$repo/scripts/dispatch-worker" --dry-run implementation/test-injected-profile.packet.md >/dev/null 2>&1); then
  echo 'FAIL packet path injection accepted' >&2; exit 1
fi
echo 'PASS collector-backed host evidence assertions'
