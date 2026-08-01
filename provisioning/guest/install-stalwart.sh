#!/bin/sh
# Operator-run only after review. Pin and verify the release artifact first.
set -eu
: "${STALWART_VERSION:?set the approved version, currently 0.16.15}"
: "${STALWART_SHA256:?set approved artifact checksum}"
echo "Install contract only: Stalwart ${STALWART_VERSION}; checksum supplied."
echo "Use only the pinned, independently verified release artifact; do not run the convenience installer."
echo "Do not bootstrap accounts, TLS, or Fastmail credentials through cloud-init."
