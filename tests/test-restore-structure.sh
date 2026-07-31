#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
"$root/scripts/restore-check/restore-check.sh" "$root/tests/fixtures/backup-manifest.example"
