#!/bin/sh
# Operator-run only after review. Pin and verify the release artifact first.
set -eu
: "${STALWART_VERSION:?set an approved version, e.g. 0.16.4}"
: "${STALWART_SHA256:?set approved artifact checksum}"
echo "Install contract only: Stalwart ${STALWART_VERSION}; checksum supplied."
echo "Use the official documented installer or verified release artifact."
echo "Do not bootstrap accounts, TLS, or Fastmail credentials through cloud-init."

