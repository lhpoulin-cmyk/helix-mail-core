#!/bin/sh
# Fake-only supervisor tests. No command observes the real host or calls Codex.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'status=$?; rm -rf "$scratch"; exit "$status"' EXIT HUP INT TERM
repo=$scratch/repo; fakebin=$scratch/fake-bin
mkdir "$fakebin"
git clone -q "$root" "$repo"
cp "$root/scripts/supervise-worker-headless" "$root/scripts/run-worker-headless" "$root/scripts/wait-worker-result" "$repo/scripts/"
cat >"$repo/scripts/collect-matriarch-readonly" <<'EOF'
#!/bin/sh
printf 'collector\n' >>"$FAKE_LOG"
case ${FAKE_COLLECTOR_MODE-success} in collection-fail) exit 23;; term) kill -TERM "$PPID"; sleep 1; exit 42;; esac
mkdir -p "$1"; printf 'fake evidence\n' >"$1/evidence-01-fake.txt"
case ${FAKE_COLLECTOR_MODE-success} in evidence-pre-fail) printf 'not-a-hash\n' >"$1/manifest.sha256";; *) (cd "$1" && sha256sum evidence-01-fake.txt >manifest.sha256);; esac
EOF
chmod +x "$repo/scripts/collect-matriarch-readonly"
cat >"$fakebin/codex" <<'EOF'
#!/bin/sh
printf 'codex\n' >>"$FAKE_LOG"
case ${FAKE_CODEX_MODE-success} in missing) exit 0;; nonzero) exit 37;; evidence-post-fail) printf 'changed\n' >"$HELIX_RUN_DIR/host-evidence/evidence-01-fake.txt";; term) trap 'exit 43' INT; kill -INT "$PPID"; sleep 1; exit 43;; esac
printf '%s\n' 'fake result' >"$HELIX_RUN_DIR/worker-result.md"
EOF
chmod +x "$fakebin/codex"
git -C "$repo" add scripts/collect-matriarch-readonly scripts/run-worker-headless scripts/supervise-worker-headless scripts/wait-worker-result
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit --amend -q --no-edit
make_run() { run=$1; profile=${2-}; mkdir "$run"; git -C "$repo" rev-parse HEAD >"$run/start-commit"; : >"$run/prompt.txt"; [ -z "$profile" ] || printf '%s\n' "$profile" >"$run/host-evidence-profile"; }
run_supervisor() { (cd "$repo" && PATH="$fakebin:$PATH" FAKE_LOG="$scratch/calls.log" HELIX_RUN_DIR="$1" "$repo/scripts/supervise-worker-headless"); }
assert_metadata() { run=$1; expected=$2; stage=$3; codex=$4; [ "$(cat "$run/exit-status")" = "$expected" ]; [ "$(cat "$run/failure-stage")" = "$stage" ]; [ "$(cat "$run/codex-exit-status")" = "$codex" ]; [ -f "$run/started-at" ] && [ -f "$run/finished-at" ]; ! find "$run" -maxdepth 1 -name '.*.tmp' -print -quit | grep -q .; }
make_run "$scratch/success" matriarch-libvirt-readonly-v1
run_supervisor "$scratch/success"
assert_metadata "$scratch/success" 0 none 0
grep -qx collector "$scratch/calls.log"; grep -qx codex "$scratch/calls.log"
make_run "$scratch/missing"
if FAKE_CODEX_MODE=missing run_supervisor "$scratch/missing"; then echo 'FAIL missing result accepted' >&2; exit 1; fi
assert_metadata "$scratch/missing" 1 worker-result 0
make_run "$scratch/nonzero"
if FAKE_CODEX_MODE=nonzero run_supervisor "$scratch/nonzero"; then echo 'FAIL nonzero Codex accepted' >&2; exit 1; fi
assert_metadata "$scratch/nonzero" 37 codex 37
make_run "$scratch/collector-fail" matriarch-libvirt-readonly-v1
if FAKE_COLLECTOR_MODE=collection-fail run_supervisor "$scratch/collector-fail"; then echo 'FAIL collector failure accepted' >&2; exit 1; fi
assert_metadata "$scratch/collector-fail" 23 collection not-started
make_run "$scratch/evidence-pre" matriarch-libvirt-readonly-v1
if FAKE_COLLECTOR_MODE=evidence-pre-fail run_supervisor "$scratch/evidence-pre"; then echo 'FAIL bad preflight evidence accepted' >&2; exit 1; fi
assert_metadata "$scratch/evidence-pre" 1 evidence-preflight not-started
make_run "$scratch/evidence-post" matriarch-libvirt-readonly-v1
if FAKE_CODEX_MODE=evidence-post-fail run_supervisor "$scratch/evidence-post"; then echo 'FAIL changed evidence accepted' >&2; exit 1; fi
assert_metadata "$scratch/evidence-post" 1 evidence-postflight 0
make_run "$scratch/term-collection" matriarch-libvirt-readonly-v1
if FAKE_COLLECTOR_MODE=term run_supervisor "$scratch/term-collection"; then echo 'FAIL TERM during collection accepted' >&2; exit 1; fi
assert_metadata "$scratch/term-collection" 143 TERM-collection not-started
make_run "$scratch/int-codex"
if FAKE_CODEX_MODE=term run_supervisor "$scratch/int-codex"; then echo 'FAIL INT during Codex accepted' >&2; exit 1; fi
assert_metadata "$scratch/int-codex" 130 INT-codex 43
mkdir -p "$repo/handoff/runs/missing-meta"
git -C "$repo" rev-parse HEAD >"$repo/handoff/runs/missing-meta/start-commit"
printf '%s\n' 0 >"$repo/handoff/runs/missing-meta/exit-status"
if (cd "$repo" && "$repo/scripts/wait-worker-result" --timeout 0 missing-meta) >/dev/null 2>&1; then echo 'FAIL waiter accepted missing metadata' >&2; exit 1; fi
! rg -q 'collect-matriarch-readonly|sudo|ssh|su |pkexec|polkit' "$root/scripts/run-worker-headless"
! rg -q 'sudo|ssh|su |pkexec|polkit|codex service' "$root/scripts/supervise-worker-headless"
echo 'PASS headless finalization assertions'
