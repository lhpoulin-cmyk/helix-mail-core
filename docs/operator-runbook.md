# Operator runbook

## Render and review

1. Obtain fresh read-only Proxmox evidence: version, `qm list`, `pvesm
   status`, selected backup coverage, bridges/VLANs, guest address, DNS path,
   firewall policy, and CA practice.
2. Copy the production inventory example to ignored `values.env`; populate
   only observed, approved values.
3. Render, validate, and review `.rendered/deployment-report.md`.
4. Submit a bounded implementation packet. Passing render is not authorization.

## Deployment sequence after authorization

Create construction VMID 9000 with two disks (system and isolated data), internal interface
only, and a current supported Debian stable guest. Mount data at
`/srv/stalwart`; install the verified pinned Stalwart release; apply the
policy contract through Stalwart's supported management API/CLI; install local
CA material; create disposable test identities only. Do not enable Fastmail.

## Local checks

Produce machine-readable status covering service health, `df`, queue depth,
failed authentication, certificate expiry, delivery errors, backup freshness,
last local delivery, and last Fastmail relay once enabled. The future status
script must return nonzero on missing data or stale backup, without modifying
state.

Run the Phase 4 disposable test: authenticated sender -> authenticated
submission -> local recipient -> IMAPS retrieval; attempt unauthenticated
submission and external relay; restart service; repeat retrieval; reboot VM;
repeat health check. No external test mail.
