# Mail-core Stalwart local-foundation gate

Disposition: **BLOCKED — OPERATOR INPUT REQUIRED**
Prerequisite data-layout result: **ACCEPTED** at `ad3035c`

## Current official evidence

Read-only review of the official Stalwart release and documentation established:

- `v0.16.4` remains the current official release, published 2026-05-05;
- the official Linux amd64 glibc artifact is
  `stalwart-x86_64-unknown-linux-gnu.tar.gz`, 37612912 bytes;
- its GitHub release API SHA-256 is
  `38d9be6707e603d80e50ce81c58ff24273f8e19a30f7ba1efb6983cb8ed8bf8a`;
- the protected downloaded artifact matched both size and digest;
- the release publishes a corresponding Sigstore bundle;
- the archive contains one `stalwart` binary.

The artifact and bundle are retained only in a protected temporary host
directory outside Git. They were not copied into the guest or executed.

## Blocking findings

1. Neither `cosign` nor another Sigstore verifier is installed. The published
   bundle therefore has not received the packet-required cryptographic
   verification. Matching the GitHub API digest over TLS is valuable evidence
   but does not silently replace the committed Sigstore-verification gate.
2. The current official installer is unsuitable for bounded execution: it
   downloads the moving `latest` artifact, uses `/var/lib/stalwart`, creates and
   enables a service, starts it immediately, and enters bootstrap HTTP mode.
   Those behaviors conflict with the pinned artifact, `/srv/stalwart` data
   ownership, mount guard, and no-public-listener requirements.
3. The committed foundation packet is explicitly a repository-only proposal,
   not an exact executable implementation. It does not yet contain the verified
   binary-install commands, a hardened systemd unit with
   `RequiresMountsFor=/srv/stalwart` plus an `ExecCondition` mount check, an
   exact configuration compatible with 0.16.4, or a safe mount-unavailable
   startup test.
4. No exact disposable local identities are authorized by that packet. No
   separate construction credentials may therefore be created.
5. The private-lab-CA leaf for `mail.home.arpa` has not been issued. The fixed
   security contract requires TLS for authenticated submission and IMAPS, so
   the requested local-delivery and mailbox-retrieval acceptance tests cannot
   be completed by exposing listeners or inventing temporary TLS.

## Required next packet

Create and review a bounded executable Stalwart foundation packet that:

- establishes an approved Sigstore verifier/trust path and verifies the pinned
  artifact;
- manually installs only that artifact without running the moving installer;
- proves the exact service UID/GID and creates `/srv/stalwart/data` only there;
- installs a systemd mount guard and tests failure with the mount unavailable;
- validates an exact 0.16.4 configuration while keeping listeners disabled or
  loopback-only;
- names the disposable sender/recipient identities and secret-safe credential
  procedure;
- either includes a separately authorized private-CA leaf or defers all
  TLS-dependent listener and mail acceptance tests to the TLS packet.

No Stalwart binary, account, directory, unit, configuration, identity,
credential, listener, DNS, TLS, Fastmail, firewall, or public-exposure mutation
occurred.
