#!/bin/sh
set -eu
[ "$#" -eq 1 ] || { echo "usage: restore-check.sh BACKUP_MANIFEST" >&2; exit 2; }
[ -f "$1" ] || { echo "missing manifest" >&2; exit 2; }
grep -q 'application_consistency=' "$1"
grep -q 'queue_inventory=' "$1"
grep -q 'data_disk=' "$1"
echo "STRUCTURAL RESTORE-CHECK PASS: manifest fields present."
echo "Not a restore proof; mount and boot only in an isolated target."

