# Mail-core Stalwart local-mail foundation proposal

Status: repository-only proposal — not authorized for execution
Depends on: accepted guest baseline and mounted `/srv/stalwart` data filesystem

## Goal

Prepare the smallest secure Stalwart foundation for the construction and soak
VM while preserving the durable identity `mail.home.arpa`. This proposal does
not install software or mutate the guest.

## Fixed security and service boundary

- direct Debian installation; no container, orchestrator, or external database;
- authoritative only for local `home.arpa` identities;
- bind only to the guest's internal address `192.168.100.199`;
- authenticated, TLS-required submission on TCP 587;
- authenticated, TLS-required IMAPS on TCP 993;
- no TCP 25 listener, public MX, public ingress, router forward, POP3, JMAP,
  ManageSieve, direct Internet delivery, or arbitrary external recipients;
- Fastmail relay remains disabled;
- no mail content grants execution authority;
- VM autostart remains disabled during construction and soak;
- the accepted construction temporary-password SSH arrangement is unchanged.

## Repository contract

The committed intent currently pins Stalwart `0.16.4`, uses
`/etc/stalwart/config.json` as the bootstrap file, and places configuration,
identity, message, and queue state in `/srv/stalwart/data` through RocksDB.
Runtime secrets belong under `/etc/stalwart/secrets`; TLS material belongs under
`/etc/stalwart/tls`; neither belongs in Git.

The policy contract requires unknown local recipients, unauthenticated
submission, external recipients, and relaying to be rejected. It keeps
Fastmail disabled and port 25 absent.

## Required evidence before an executable install packet

1. Revalidate `0.16.4` against the current official Stalwart release source.
   If it is unsupported, vulnerable, replaced, or unavailable, stop for a
   reviewed version-pin correction; do not silently upgrade.
2. Acquire the exact amd64 artifact and its publisher-supported verification
   material through a documented trust path. Record filename, byte size, full
   digest, signature/provenance result, and acquisition time. Store artifacts
   outside Git.
3. Inspect the verified artifact's installer/package metadata without
   executing it. Determine the exact service account, systemd unit, binary
   path, configuration ownership/modes, and supported management interface.
4. Revalidate the live Stalwart configuration schema for the pinned release.
   Do not assume that repository policy JSON can be copied directly into the
   managed datastore.
5. Prove `/srv/stalwart` is the accepted XFS mount before creating any
   application directory. Create `/srv/stalwart/data` only for the verified
   service UID/GID and with the minimum required mode.
6. Confirm `mail.home.arpa` forward DNS publication and private-lab-CA issuance
   remain separate acceptance gates. A daemon may not expose 587 or 993 until
   a valid `mail.home.arpa` certificate and approved client trust path exist.

## Proposed implementation order

After those facts are captured, a separate executable packet may:

1. install only the checksum/signature-verified pinned Stalwart artifact;
2. create or verify only the vendor-defined service account and directories;
3. install the minimal RocksDB bootstrap configuration with restricted modes;
4. apply the policy contract through the pinned release's supported API/CLI;
5. keep every network listener disabled or loopback-only until TLS material is
   installed and validated;
6. enable only the Stalwart systemd unit, without enabling VM autostart;
7. prove no port 25 or public/wildcard listener exists and Fastmail is disabled;
8. create disposable local test identities only under a separately reviewed,
   secret-safe identity packet.

## Stop conditions

Stop before execution if the artifact trust path, service identity,
configuration schema, data ownership, bind behavior, or rollback method is
unresolved. Stop before enabling service listeners if DNS or TLS acceptance
gates are incomplete. Do not create credentials, certificates, mailboxes, or
relay secrets under this proposal.

`APPLIANCE_EXPORT_REFERENCE` remains unresolved and blocks promotion readiness,
not this construction-stage proposal. Production placement and migration remain
out of scope.
