# Matriarch evidence profile completeness and sanitization correction

Status: repository changes and fake-only tests only

Do not collect real host evidence or mutate any VM, domain, host, service,
network, DNS, certificate, credential, or privilege state.

Extend `matriarch-libvirt-readonly-v1` with fixed, timed, controlled-candidate
`virsh --readonly --connect qemu:///system dominfo mail-core-9000` and separate
`qemu:///session` dominfo evidence. Record identifier, timestamps, stdout,
stderr, status, and distinct observed/absent/unavailable/connection-denied/
permission-denied/timed-out/failure outcomes. Domain absence applies only to
the queried scope and never to a numeric runtime ID. No mutation command may
exist.

Sanitize every 32-hex Machine ID before evidence/model consumption, replacing
it with `Machine ID: [REDACTED]`; it must not remain in evidence, summaries,
prompts, manifests except through sanitized-file hashes, or documentation.
Keep hostname, Fedora version, kernel, architecture, and KVM facts intact.

Use fake-only tests for fixed readonly URIs, all dominfo classifications,
hostile PATH resistance, no mutation commands, complete Machine-ID removal,
and preservation of unrelated hostnamectl fields. Run all existing collector,
injection, timeout, integrity, supervisor, and repository validation tests.
Commit one bounded change, provide a factual result, and stop without a next
packet or self-approval.
