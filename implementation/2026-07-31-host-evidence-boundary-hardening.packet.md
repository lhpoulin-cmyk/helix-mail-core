# Host evidence boundary hardening packet

Status: repository changes and fake-only tests

Do not collect real host evidence or perform VM, privilege, SSH, polkit,
package, service, network, DNS, certificate, or Fastmail changes.

For profiled runs, generate a worker prompt naming the explicit evidence and
manifest paths; declare evidence authoritative and already supervisor-verified;
forbid host-inspection commands, evidence modification, retry/supplementation,
historical-state inference, and resolving inconclusive evidence. Require each
conclusion to cite evidence items. Do not make such claims for unprofiled runs.

Harden the collector before any external command with
`PATH=/usr/sbin:/usr/bin:/sbin:/bin; export PATH`. Use a repository-controlled
absolute-candidate map for every observation and utility. Never resolve through
inherited PATH; missing candidates are `unavailable`.

Provide only an explicit `--test-command-root /absolute/path` fake-test option.
Production dispatch, packet text, prompts, and environment cannot enable it.
Reject missing, nonabsolute, traversal, and symlink roots. Test resolution maps
the same identifiers beneath that root and marks evidence test-only; document
that it is never valid host evidence.

Use fake-only tests for hostile PATH/environment injection, fixed candidate
resolution, missing binaries, explicit test-root use, packet nonselection,
profiled/unprofiled prompts, and all existing supervisor integrity/finalization
tests. Run full validation and whitespace checks, commit one bounded change,
write a factual result, and stop without self-approval or a next packet.
