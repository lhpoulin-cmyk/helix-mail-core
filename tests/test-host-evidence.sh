#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'status=$?; rm -rf "$scratch"; exit "$status"' EXIT HUP INT TERM
fakebin=$scratch/fake-bin
mkdir "$fakebin"

for command in hostnamectl cat uname date test virsh ip bridge nmcli resolvectl findmnt systemctl; do
  cat >"$fakebin/$command" <<'EOF'
#!/bin/sh
printf '%s %s\n' "$(basename "$0")" "$*" >>"$FAKE_LOG"
case "$(basename "$0")" in
  virsh) [ "${FAKE_VIRSH_FAIL-}" != 1 ] || { echo 'permission denied' >&2; exit 1; };;
esac
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

run_collector() {
  PATH="$fakebin:$PATH" FAKE_LOG="$scratch/commands.log" HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1 "$root/scripts/collect-matriarch-readonly" "$1"
}

mkdir "$scratch/evidence"
if HOST_EVIDENCE_PROFILE='packet; injected-command' "$root/scripts/collect-matriarch-readonly" "$scratch/evidence" >/dev/null 2>&1; then
  echo 'FAIL environment profile injection accepted' >&2; exit 1
fi
touch "$scratch/evidence/unexpected"
if HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1 "$root/scripts/collect-matriarch-readonly" "$scratch/evidence" >/dev/null 2>&1; then
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
! grep -Eq 'sudo|su |pkexec' "$scratch/commands.log"
FAKE_VIRSH_FAIL=1 run_collector "$scratch/evidence-two" >/dev/null
grep -q 'outcome: permission-denied' "$scratch/evidence-two/evidence-06-system-version.txt"
[ -f "$scratch/evidence-two/manifest.sha256" ]
(cd "$scratch/evidence-two" && sha256sum -c manifest.sha256 >/dev/null)
run_collector "$scratch/evidence-three" >/dev/null & first=$!
run_collector "$scratch/evidence-four" >/dev/null & second=$!
wait "$first"; wait "$second"
[ -f "$scratch/evidence-three/manifest.sha256" ] && [ -f "$scratch/evidence-four/manifest.sha256" ]

# Exercise the runner in a clean disposable clone, with fake Codex and fake
# observations. This covers pre/post manifest checks and worker exit behavior.
repo=$scratch/repo
git clone -q "$root" "$repo"
cp "$root/scripts/collect-matriarch-readonly" "$repo/scripts/collect-matriarch-readonly"
cp "$root/scripts/run-worker-headless" "$repo/scripts/run-worker-headless"
cp "$root/scripts/dispatch-worker" "$repo/scripts/dispatch-worker"
cp "$root/implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md" "$repo/implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md"
git -C "$repo" add scripts/collect-matriarch-readonly scripts/run-worker-headless scripts/dispatch-worker implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit -qm 'test collector harness'
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
if (cd "$repo" && PATH="$fakebin:$PATH" FAKE_LOG="$scratch/runner.log" FAKE_CODEX_ACTION=replace-evidence HELIX_RUN_DIR="$scratch/run-changed" "$repo/scripts/run-worker-headless"); then
  echo 'FAIL worker evidence replacement accepted' >&2; exit 1
fi
make_run "$scratch/run-nonzero"
if (cd "$repo" && PATH="$fakebin:$PATH" FAKE_LOG="$scratch/runner.log" FAKE_CODEX_STATUS=7 HELIX_RUN_DIR="$scratch/run-nonzero" "$repo/scripts/run-worker-headless"); then
  echo 'FAIL nonzero Codex exit accepted' >&2; exit 1
fi
[ "$(cat "$scratch/run-nonzero/exit-status")" = 7 ]

# Dispatcher dry-run accepts only the exact declaration and creates no run.
if (cd "$repo" && HOST_EVIDENCE_PROFILE='attacker-value' "$repo/scripts/dispatch-worker" --dry-run implementation/2026-07-31-matriarch-local-readonly-inventory.packet.md >/dev/null); then :; else
  echo 'FAIL exact packet profile was not accepted' >&2; exit 1
fi
packet=$scratch/injected.packet.md
printf '%s\n' 'HOST_EVIDENCE_PROFILE=matriarch-libvirt-readonly-v1; evil' >"$packet"
cp "$packet" "$repo/implementation/test-injected-profile.packet.md"
git -C "$repo" add implementation/test-injected-profile.packet.md
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit -qm 'test invalid profile packet'
if (cd "$repo" && "$repo/scripts/dispatch-worker" --dry-run implementation/test-injected-profile.packet.md >/dev/null 2>&1); then
  echo 'FAIL packet path injection accepted' >&2; exit 1
fi
echo 'PASS collector-backed host evidence assertions'
