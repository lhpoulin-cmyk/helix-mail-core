# Helix-ARPA mail core

Helix mail-core is a private mail system for a homelab whose machines need
durable names, distinct credentials, and a way to report to their operator
using literary triggers that anchor the machine's use to my thinking. It runs
Stalwart, an open source software e-mail platform, on a small
Debian VM, a computer in a computer if you will, owns only `home.arpa`, and exposes
authenticated submission and IMAPS (E-Mail Administrators shop talk)only to the internal network.
The project is deliberately more interested in recoverable state and honest failure than in looking
like a tiny enterprise mail department. Nobody needs that much role-play before breakfast. Except me,
my setup can accomodate over 3,000 simultaneous users. I set it up. Before breakfast. Literally.

## What is a Hypervisor
fill this out plz. **lhp2

## Why I built it

I wanted the lab's machines to be correspondents, not anonymous processes using
one shared password. A hypervisor should be able to tell me that something is
wrong as itself; an administrator should be able to reply; one workstation
should not be able to impersonate another. The lab should still know who it is
when the Internet goes dark.

That made local mail useful even before any external bridge existed. It also
made the boundaries clearer: Fastmail can later carry selected messages across
the Internet, but it is not the source of local identity and it is not required
for local delivery.

## Current release

```text
VERSION=1.1.1-beta
SOAK_STATUS=STARTED
BETA_ELIGIBLE=true
```

The construction appliance is in its two-week soak on Fedora 44 Matriarch as
the system-libvirt domain `mail-core-9000`. The soak began
`2026-08-01T14:06:05-04:00`; its minimum review point is
`2026-08-15T14:06:05-04:00`. Beta means the alpha mail-policy blocker passed.
It does not mean production placement, migration, export, or restore readiness.

See [the release status](docs/release-status.md) and
[the soak manifest](docs/soak-start-manifest.md) for the exact gates and
deferrals.

This means this project went super sayian

## Architecture in one screen

This is wild and exactly how your email works, more or less.

```text
approved internal client
        |
        | trusted TLS + authenticated submission (587)
        v
mail.home.arpa / 192.168.100.199
Stalwart 0.16.15 on Debian 13
        |
        +---- local home.arpa mailbox ---- IMAPS (993) ---- approved client
        |
        +---- external route: disabled

authoritative state: /srv/stalwart on the separate 192 GiB data disk
construction host:   ws-matriarch / qemu:///system / mail-core-9000
durable identity:    mail.home.arpa
```
## Party like it's 2005

The VM has 2 vCPUs, 4096 MiB of RAM, a 32 GiB system disk, a separate
192 GiB mail-data disk, and one NIC on `br-lab10`. The host bridge uses the
10 GbE parent `enp7s0`; the guest deliberately uses MTU 1500. The data
filesystem is mounted at `/srv/stalwart`, and the systemd unit refuses to start
if that mount is missing. That guard exists because a perfectly healthy daemon
quietly writing authoritative mail into the root filesystem would be a very
tidy disaster.

DNS is forward-only: both internal resolvers answer
`mail.home.arpa A 192.168.100.199`. No PTR was invented. A leaf certificate for
exactly `DNS:mail.home.arpa` chains to the offline Helix Lab X.509 root through
its issuing intermediate. The server key was generated inside the guest and did
not join the CA custody packages on their travels.

## Correspondents and mail policy

The initial operational correspondents are:

### Administrators

- `admin@home.arpa`
- `cluster-admin@home.arpa`

### Hypervisors

- `hv-lore@home.arpa` - obvs Star Trek reference. It's deep actually.
- `hv-katra@home.arpa` - same. not so.
- `hv-matrix@home.arpa` - matrix is a darker, grittier, more consequential reality and where i have evolved to

### Workstations

- `ws-matriarch@home.arpa`
- `ws-alpha@home.arpa`
- `ws-hadrian@home.arpa`
- `ws-wowzerwin@home.arpa`

Each has a distinct credential. Seven machine bundles and the Admin bundle are
in dual Foundation custody; the ninth archived bundle belongs to
`louis@home.arpa`. The accepted manifest does not record a separate
Cluster-Admin onboarding archive, so this README does not pretend otherwise.
There is no shared cluster password, because identity that cannot be
distinguished is not much of an identity. Supporting local accounts include
`postmaster`, `louis`, and the disposable `test-sender` and `test-receiver`
identities. The canonical administrative name is
`cluster-admin@home.arpa`; the underscore variant does not exist.

Machine mailboxes accept delivery only from `admin@home.arpa` and
`cluster-admin@home.arpa`. Machines may send status mail to either
administrator, and the administrators may reply. Machine-to-machine delivery
and other local-to-machine delivery are rejected before message data with SMTP
550. Submission also rejects sender impersonation, and external relay remains
off. The policy was tested from all five non-deferred physical endpoints and
both administrative mailboxes.

`ws-alpha` and `ws-wowzerwin` retain their identities, credentials, bundles,
and dual custody, but their physical endpoint enrollment is operator-deferred.
The repository does not upgrade “deferred” to “verified” by improving the
adjective.

## What works now

- authenticated internal SMTP submission with STARTTLS on TCP 587;
- authenticated IMAPS with implicit TLS on TCP 993;
- forward DNS from both internal resolvers;
- trusted private-CA validation for `mail.home.arpa`;
- local delivery and retrieval across service restart and guest reboot;
- distinct machine and human identities, with nine verified onboarding
  bundles for the seven machines, Admin, and Louis;
- verified copies of all nine bundles on Foundation and Second Foundation;
- administrator-only inbound delivery to every `hv-*` and `ws-*` mailbox;
- rejection of unauthenticated submission, sender impersonation, unknown or
  unauthorized machine delivery, and external relay;
- a mount-guarded data path on the separate guest disk; and
- an auditable packet/evidence trail for the construction work.

## The guts are good, but no lipstick on this pig

- no public SMTP listener or public MX path;
- no port 25 listener, public administration, public JMAP, POP3, or
  ManageSieve;
- no Fastmail relay or real external-delivery test;
- no PTR publication;
- no ACME or public certificate issuance;
- no automated command execution from received mail;
- no completed appliance export or isolated restore proof;
- no selected permanent hypervisor, production VM identifier, or migration;
- no claim of promotion or production readiness.

Matriarch is a construction and soak surface, not a constitutional amendment.
The durable service identity is `mail.home.arpa`, and the appliance must remain
movable.

## Construction and soak

Changes were built as small, reviewed packets: observe, render, validate, ask
for authority, mutate one bounded surface, and verify independently. This is
slower than improvising until the first time improvisation points `mkfs` at the
wrong disk. The project prefers a clean stop over a clever guess.

The soak keeps normal internal traffic on the appliance while watching service
and VM restarts, queue behavior, disk growth, authentication failures,
certificate lifetime, and recovery work. Its clock is already running; a later
material redesign or safety fault may extend it. Completion still requires the
opaque appliance-export destination, a consistent export, and an isolated
restore exercise.

## Finding your way around

- [Project story](docs/project-story.md) explains how the system reached beta
  and what the false starts taught me.
- [Documentation map](docs/README.md) separates narrative, architecture,
  runbooks, implementation packets, and evidence.
- [Architecture](docs/architecture.md), [identity model](docs/identity-model.md),
  and [security boundary](docs/security-boundary.md) describe the current
  design.
- [Operator runbook](docs/operator-runbook.md) and
  [soak and promotion](docs/soak-testing-and-promotion.md) describe current
  operations and remaining gates.
- [`implementation/`](implementation/) contains exact reviewed proposals and
  execution boundaries. Their status lines matter; many are historical.
- [`evidence/`](evidence/) contains sanitized factual results, including
  corrections and stops. A failed gate is part of the technical record, not a
  formatting problem to hide.

Run `scripts/validate/all.sh` for the repository checks. No runtime secret,
mail data, private key, or decrypted onboarding material belongs in Git.

## Lessons from the blockers

- Historical device names are clues, not storage authority. The 256 GiB host
  allocation was made only after current geometry proved the tail was free.

  This isn't MS-DOS or Windows 95. You need to be careful here.

- qcow2 allocation metadata is not guest-visible data. Comparing the data disk
  to a fresh zero image resolved that distinction without recreating evidence.
- Stalwart recovery mode needed its own loopback-only network namespace. A
  firewall workaround would have hidden the design mistake instead of fixing
  it.

  We are used to Proxmox, not local VMs.
  
- `home.arpa` support was tested against Stalwart 0.16.15 rather than assumed
  from either documentation or the earlier 0.16.4 failure.

  I was lazy and didn't check the latest version
  
- A hosts-style DNS entry synthesized a PTR, so it was rolled back and replaced
  with an exact forward-only record.

  What I have done with DNS is a war-crime.
  
- Encryption answered “who can read this archive?” It did not answer who owned
  the CA, whether both vault copies matched, or whether either vault returned
  to read-only. Those required separate proofs.

  And I sure won't talk about it here. 

## Next gates

The immediate work is to finish and review the soak without confusing elapsed
time with evidence. After that come the appliance export, isolated restore,
deferred endpoint enrollment, and a separate promotion decision. Fastmail
bridging, permanent placement, and migration remain later projects with their
own authorization boundaries.

Make sure it works. Yep. That's it.
