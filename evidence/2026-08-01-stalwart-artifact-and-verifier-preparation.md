# Stalwart artifact and verifier preparation

Status: artifact verification **ACCEPTED**; no Stalwart installation performed

- Debian stable `cosign` 2.5.0-2+b4 was installed after an exact simulation
  showed one new package and no upgrades, removals, or downgrades.
- The pinned official Stalwart v0.16.4 Linux amd64 glibc artifact matched its
  official size and SHA-256.
- Offline Sigstore bundle verification passed with the exact tagged Stalwart CI
  identity and GitHub Actions OIDC issuer. SCT and transparency verification
  were not disabled.
- Safe archive inspection found exactly one regular `stalwart` payload. Its
  protected temporary extraction reports version 0.16.4.
- Official CLI release `stalwartlabs/cli v1.0.12` was selected and pinned. Its
  Linux amd64 artifact matched official size/SHA-256 and passed GitHub artifact
  attestation verification against `stalwartlabs/cli`, tag `v1.0.12`, and its
  official release workflow. The temporary binary reports 1.0.12.
- The official convenience installers were inspected but never executed.
- Artifacts remain in protected temporary paths outside Git and were not
  installed into the guest.
- No Stalwart account, binary, CLI, configuration, directory, unit, service,
  listener, identity, credential, DNS, TLS, Fastmail, or public exposure was
  created.
