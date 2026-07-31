# Waiter commit parser correction packet

Status: repository-only and fake-test-only

Do not call real Codex, tmux, collectors, or Matriarch interfaces, and make no
VM, host, privilege, network, DNS, certificate, service, credential, or
Fastmail change.

Correct `scripts/wait-worker-result` to accept exactly one full 40-lowercase-
hex starting and ending commit line in either plain or `- ` list form, with
ordinary leading whitespace. Reject missing, malformed, abbreviated, overlong,
embedded-prose, duplicate-identical, duplicate-conflicting, and ambiguous
values; never silently select first/last matches. Preserve finalized metadata,
zero supervisor status, result presence, commit existence, ancestry, clean
worktree, evidence integrity, and vanished-session rejection.

Add fake-only regressions for all valid forms and invalid cases, valid/invalid
ancestry, and existing waiter behavior. Run full validation and whitespace
checks, commit one bounded repair, write a factual result, and stop.
