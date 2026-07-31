#!/bin/sh
# Fake-only waiter tests. No command contacts tmux, Codex, or a host.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
scratch=$(mktemp -d)
trap 'status=$?; rm -rf "$scratch"; exit "$status"' EXIT HUP INT TERM
repo=$scratch/repo
fakebin=$scratch/fake-bin
mkdir "$fakebin"
printf '%s\n' '#!/bin/sh' 'exit 1' >"$fakebin/tmux"
chmod +x "$fakebin/tmux"
git clone -q "$root" "$repo"
cp "$root/scripts/wait-worker-result" "$repo/scripts/wait-worker-result"
git -C "$repo" add scripts/wait-worker-result
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit --amend -q --no-edit
git -C "$repo" -c user.name=test -c user.email=test@example.invalid commit --allow-empty -qm 'test ending commit'
start=$(git -C "$repo" rev-parse HEAD^)
end=$(git -C "$repo" rev-parse HEAD)
tree=$(git -C "$repo" write-tree)
unrelated=$(printf 'unrelated\n' | git -C "$repo" commit-tree "$tree")
runs=$repo/handoff/runs

make_run() {
  run=$runs/$1
  mkdir -p "$run"
  printf '%s\n' "$start" >"$run/start-commit"
  printf '%s\n' 2026-07-31T18:46:06Z >"$run/started-at"
  printf '%s\n' none >"$run/failure-stage"
  printf '%s\n' 0 >"$run/codex-exit-status"
  printf '%s\n' 2026-07-31T18:46:07Z >"$run/finished-at"
  printf '%s\n' 0 >"$run/exit-status"
}
write_result() { printf '%s\n' "$2" >"$runs/$1/worker-result.md"; }
expect_accept() {
  if ! (cd "$repo" && "$repo/scripts/wait-worker-result" --timeout 0 "$1") >/dev/null 2>&1; then
    echo "FAIL waiter rejected $1" >&2
    exit 1
  fi
}
expect_reject() {
  if (cd "$repo" && PATH="$fakebin:$PATH" "$repo/scripts/wait-worker-result" --timeout 0 "$1") >/dev/null 2>&1; then
    echo "FAIL waiter accepted $1" >&2
    exit 1
  fi
}
expect_vanished_session() {
  if (cd "$repo" && PATH="$fakebin:$PATH" "$repo/scripts/wait-worker-result" --timeout 1 "$1") >/dev/null 2>&1; then
    echo "FAIL waiter accepted vanished session" >&2
    exit 1
  fi
}
result() { printf 'Starting commit: %s\nEnding commit: %s\n' "$1" "$2"; }

make_run plain
write_result plain "$(result "$start" "$end")"
expect_accept plain
make_run indented
write_result indented "$(printf '  Starting commit: %s\n\t- Ending commit: %s' "$start" "$end")"
expect_accept indented
make_run list
write_result list "$(printf -- '- Starting commit: %s\n- Ending commit: %s' "$start" "$end")"
expect_accept list

for case in missing malformed abbreviated overlong embedded duplicate-identical duplicate-conflicting ambiguous; do
  make_run "$case"
done
write_result missing "Ending commit: $end"
write_result malformed "Starting commit: not-a-commit
Ending commit: $end"
write_result abbreviated "Starting commit: ${start%?}
Ending commit: $end"
write_result overlong "Starting commit: ${start}a
Ending commit: $end"
write_result embedded "Starting commit: $start completed
Ending commit: $end"
write_result duplicate-identical "Starting commit: $start
- Starting commit: $start
Ending commit: $end"
write_result duplicate-conflicting "Starting commit: $start
Starting commit: 0123456789abcdef0123456789abcdef01234567
Ending commit: $end"
write_result ambiguous "Starting commit: $start $end
Ending commit: $end"
for case in missing malformed abbreviated overlong embedded duplicate-identical duplicate-conflicting ambiguous; do expect_reject "$case"; done

for case in missing malformed abbreviated overlong embedded duplicate-identical duplicate-conflicting ambiguous; do
  make_run "ending-$case"
done
write_result ending-missing "Starting commit: $start"
write_result ending-malformed "Starting commit: $start
Ending commit: not-a-commit"
write_result ending-abbreviated "Starting commit: $start
Ending commit: ${end%?}"
write_result ending-overlong "Starting commit: $start
Ending commit: ${end}a"
write_result ending-embedded "Starting commit: $start
Ending commit: $end completed"
write_result ending-duplicate-identical "Starting commit: $start
Ending commit: $end
- Ending commit: $end"
write_result ending-duplicate-conflicting "Starting commit: $start
Ending commit: $end
Ending commit: 0123456789abcdef0123456789abcdef01234567"
write_result ending-ambiguous "Starting commit: $start
Ending commit: $end $start"
for case in missing malformed abbreviated overlong embedded duplicate-identical duplicate-conflicting ambiguous; do expect_reject "ending-$case"; done

make_run invalid-ending
write_result invalid-ending "$(result "$start" 0123456789abcdef0123456789abcdef01234567)"
expect_reject invalid-ending
make_run invalid-ancestry
write_result invalid-ancestry "$(result "$start" "$unrelated")"
expect_reject invalid-ancestry
make_run nonzero-status
write_result nonzero-status "$(result "$start" "$end")"
printf '%s\n' 1 >"$runs/nonzero-status/exit-status"
expect_reject nonzero-status
make_run missing-metadata
write_result missing-metadata "$(result "$start" "$end")"
rm "$runs/missing-metadata/finished-at"
expect_reject missing-metadata
make_run dirty-worktree
write_result dirty-worktree "$(result "$start" "$end")"
: >"$repo/dirty-file"
expect_reject dirty-worktree
rm "$repo/dirty-file"
mkdir "$runs/vanished-session"
printf '%s\n' "$start" >"$runs/vanished-session/start-commit"
expect_vanished_session vanished-session

echo 'PASS waiter commit parser assertions'
