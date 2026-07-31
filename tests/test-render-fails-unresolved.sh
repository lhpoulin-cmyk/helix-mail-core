#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
if "$root/scripts/render/render.sh" "$root/inventory/production/values.env.example" >/dev/null 2>&1; then
  echo "render unexpectedly accepted unresolved production values" >&2
  exit 1
fi
echo "PASS unresolved render rejected"

