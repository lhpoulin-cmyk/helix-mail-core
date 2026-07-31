#!/bin/sh
# Run only in an explicitly authorized disposable test environment.
set -eu
echo "Required runtime assertions: authenticated local submission and IMAPS retrieval;"
echo "unauthenticated submission and external relay rejection; restart and VM reboot persistence;"
echo "Internet-outage local delivery; backup structural check. No external mail."
echo "SKIP: no authorized mail-core VM/test identities are present."
