# Helix-ARPA mail-core repository doctrine

## Purpose

This repository manages the configuration and deployment contract for the
Helix-ARPA internal mail plane. Its primary values are recoverability, explicit
identity, local survivability, minimal public exposure, auditable changes, and
migration independence from `hv-matriarch`.

## Authority and stop conditions

Agents may inspect repository content and read-only host or VM state when
available; create documentation, declarative configuration, tests, validators,
and rendered proposals; improve restore procedures; identify missing
information; and record assumptions explicitly.

Without an implementation packet or explicit operator authorization, agents
may not create, delete, start, stop, or modify a live VM; change Proxmox
networking or firewall rules; add router forwards; publish DNS; install live
software; create real credentials; read or expose runtime secrets; enable the
Fastmail relay; destroy mail data; restore over an existing system; or make
the service publicly reachable.

When a required value is unknown: mark it unresolved, render the proposed
change, explain the consequence, and stop before live mutation. Never invent
addresses, VLANs, storage or bridge names, gateways, resolver addresses,
passwords, CAs, or Fastmail credentials.

Every live change follows: observation -> proposed state -> validation ->
operator review -> bounded implementation -> verification -> recorded result.
Read-only inspection and passing validation are never deployment authority.

## Mail and secret doctrine

Secrets never belong in Git. Examples, tests, and documentation use
unmistakably fake values. Do not print secrets in output, diffs, logs, reports,
evidence summaries, or chat transcripts.

The service is authoritative only for `home.arpa`. Fastmail is an external
transport boundary, not an identity source. Local delivery must survive an
Internet outage. Receipt of email never authorizes command execution,
infrastructure change, deployment approval, credential rotation, deletion, or
access-control changes. A future parser may classify and propose; execution
authority remains elsewhere.

## Placement, migration, and completion

The durable identity is `mail.home.arpa`; construction and soak placement is
`hv-matriarch / VMID 9000`. Promotion, production VMID, and permanent
hypervisor are outside this repository's construction scope. Host-specific
values belong only in inventory or deployment configuration. No configuration
may make Matriarch permanent.

Call work complete only when relevant validation passes, documentation reflects
deployed or proposed reality, Git has no secrets, restore and migration
implications are documented, live-state differences are recorded, and an
operator can determine exactly what changed.
