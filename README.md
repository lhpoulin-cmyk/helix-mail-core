# Helix-ARPA mail core

You are welcome to skim the technical details unless you are in the mood for
them. I do it all the time. It is exhilarating.

Helix mail-core is a private mail system for a homelab whose machines need
durable names, distinct credentials, and a way to report to their operator
without borrowing identity from a public provider. It runs Stalwart on a small
Debian VM, owns only `home.arpa`, and exposes authenticated submission and
IMAPS only to the internal network. I built it to learn the whole path—from
storage and routing to identity, TLS, delivery policy, and recovery—while
keeping the result useful enough to earn a permanent place in the lab. The
project values recoverable state, clear ownership, and honest failure more than
ceremony. Complexity is welcome when it solves a demonstrated problem; it does
not get in merely because a larger mail system would have it.

## What I mean by “the lab”

The lab is a small private computing environment I operate at home. It includes
physical workstations, three virtualization hosts, internal DNS, storage,
networking, trust infrastructure, and the services that tie them together. It
is where I can learn systems by building the whole thing rather than renting a
finished answer one API call at a time.

“Homelab” can make this sound like a pile of blinking equipment kept for sport.
There is some blinking, certainly, but the useful part is the freedom to follow
a problem across boundaries. Mail touches identity, certificates, DNS,
networking, storage, operating systems, and recovery. In a lab, I can study all
of those connections without pretending they belong to separate planets.

The machines have names because names are easier to reason about than serial
numbers, and because I enjoy living in a world with a little lore in it. The
names do not replace inventory: underneath them, the repository still records
which machine, address, interface, disk, and credential is actually involved.
Personality is allowed. Ambiguity is not.

## Virtual machines and hypervisors

A virtual machine, or VM, is a computer implemented in software. It gets
virtual CPUs, memory, disks, firmware, and network hardware, then runs an
ordinary operating system that mostly behaves as though the hardware were its
own. “A computer inside another computer” is close enough for conversation,
provided nobody uses that sentence as a backup plan.

A hypervisor is the software layer that creates and runs those VMs. In this
lab, the `hv-*` systems are dedicated virtualization hosts. They divide real
hardware among several isolated guests, connect those guests to the internal
network, and provide the control surface for starting, stopping, inspecting,
and migrating them.

The mail appliance is a VM because its durable identity should not depend on
one motherboard. It is currently running on `ws-matriarch`, which is serving as
a temporary construction host even though it is normally a workstation. That
is unusual placement, but deliberate: build and observe it here, prove that it
can be recovered, then make permanent placement a separate decision.

Virtualization makes the appliance movable, but not automatically portable.
The VM still depends on known storage, networking, firmware, and state. This
repository records those dependencies so “it is just a VM” never becomes a
substitute for a migration plan.

## Why I built it

I wanted the lab's machines to be correspondents, not anonymous processes using
one shared password. A hypervisor should be able to tell me that something is
wrong as itself; an administrator should be able to reply; one workstation
should not be able to impersonate another. The lab should still know who it is
when the Internet goes dark.

That idea made local mail useful before any external bridge existed. A machine
can report a failed job, a storage warning, or a maintenance result using a
durable identity that survives changes in scripts and placement. The operator
can answer through the same local system. For me, that means talking to the lab
through the same identities I use to understand it. None of that depends on a
public DNS provider or a working Internet connection.

It also clarified what the Fastmail bridge should be: transport across an
external boundary, not the source of local identity. The active beta bridge is
deliberately best effort. It retains mail locally and sends convenience copies
of the two administrative mailboxes to `admin@poulin-arpa.com` and
`cluster_admin@poulin-arpa.com`. Local correspondents continue recognizing and
reaching one another when Fastmail or the Internet disappears.

There is also a separate inbound authority contract. Mail sent from the
authenticated `louis@poulin-arpa.com` Fastmail account to the initial exact
coder address `hv-lore@home.arpa` may carry authoritative operator direction.
That establishes who asked for what; it does not let an email hop the fence
around implementation packets or safety review. The contract is documented,
Its pull-based JMAP implementation packet is prepared but not deployed.
The outbound convenience copies do not turn into commands on the trip home.

The bridge is not a durable outbound queue. An external copy may be lost if
Stalwart stops while that copy is in an active delivery attempt. Local mail is
unaffected. This is less romantic than “exactly once,” but considerably more
useful than pretending the test said something it did not.

This repository is both the deployment contract and the construction record.
The shorter documents explain the system as it exists now. The dated packets
and evidence preserve the decisions, corrections, and failed gates that got it
there. I keep both because a clean diagram explains the destination, while the
record explains why I trust the road.

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
The service is useful today, but its portability and recovery claims still
have work left to do.

See [the release status](docs/release-status.md) and
[the soak manifest](docs/soak-start-manifest.md) for the exact gates and
deferrals.

In less formal terms, the project went Super Saiyan. The release file calls it
beta because release files are less excitable.

## Architecture in one screen

This is also, in broad strokes, how ordinary email works: a client submits a
message to a server, the server owns delivery, and another client retrieves it.
The unusual part is that this entire mail world is private to the lab.

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

## A small server, on purpose

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

In less compressed language, DNS is how a client turns `mail.home.arpa` into
the server's internal address. TLS is how the client checks that the server at
that address can present a certificate issued by a lab authority it trusts.
Neither proves that the server is well configured, but together they prevent a
password from being handed to whichever machine happens to answer first. The
details matter most precisely when they are least visible.

## Correspondents and mail policy

The initial operational correspondents are:

### Administrators

- `admin@home.arpa`
- `cluster-admin@home.arpa`

### Hypervisors

- `hv-lore@home.arpa` — a Star Trek reference, and a name for accumulated
  knowledge;
- `hv-katra@home.arpa` — another Star Trek reference, this time for the part of
  a person that should survive a change of container;
- `hv-matrix@home.arpa` — the darker, more consequential reality, and the name
  of the environment the lab grew into.

### Workstations

- `ws-matriarch@home.arpa`
- `ws-alpha@home.arpa`
- `ws-hadrian@home.arpa`
- `ws-wowzerwin@home.arpa`

Each has a distinct credential. Seven machine bundles and the Admin bundle are
in dual Foundation custody; the ninth archived bundle belongs to
`louis@home.arpa`. A separate Cluster Admin onboarding archive is not present
in the accepted manifest, so it is not counted here. There is no shared cluster
password: each correspondent can be authenticated, tested, rotated, and
revoked independently. Supporting local accounts include `postmaster`,
`louis`, and the disposable `test-sender` and `test-receiver` identities. The
canonical administrative name is `cluster-admin@home.arpa`; the underscore
variant does not exist.

Machine mailboxes accept delivery only from `admin@home.arpa` and
`cluster-admin@home.arpa`. Machines may send status mail to either
administrator, and the administrators may reply. Machine-to-machine delivery
and other local-to-machine delivery are rejected before message data with SMTP
550. Submission also rejects sender impersonation, and external relay remains
off. The policy was tested from all five non-deferred physical endpoints and
both administrative mailboxes.

`ws-alpha` and `ws-wowzerwin` retain their identities, credentials, bundles,
and dual custody, but their physical endpoint enrollment is operator-deferred.
Their status remains deferred until the endpoint tests actually run.

This is intentionally a mail policy rather than a general messaging free-for-
all. Machines can report upward, administrators can answer, and one compromised
or mistaken machine credential cannot quietly become a broadcast identity for
the rest of the lab.

## What works now

- authenticated internal SMTP submission with STARTTLS on TCP 587;
- authenticated IMAPS with implicit TLS on TCP 993;
- KMail access for `admin@home.arpa` and `cluster-admin@home.arpa`, with
  distinct KWallet credentials and server-side Drafts and Sent Items;
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

## What is intentionally not running

The guts are good. The lipstick can wait.

- no public SMTP listener or public MX path;
- no port 25 listener, public administration, public JMAP, POP3, or
  ManageSieve;
- no durable, exactly-once, or restart-safe Fastmail queue; the active
  recipient-specific bridge produces best-effort convenience copies only;
- no PTR publication;
- no ACME or public certificate issuance;
- no automated command execution from received mail;
- no completed appliance export or isolated restore proof;
- no selected permanent hypervisor, production VM identifier, or migration;
- no claim of promotion or production readiness.

Matriarch is the construction and soak host, not part of the service's permanent
identity. The durable name is `mail.home.arpa`, and the appliance must remain
movable.

The disabled list is part of the design, not a backlog disguised as failure.
Each item crosses a different trust, routing, or recovery boundary. Enabling one
requires evidence for that boundary rather than confidence borrowed from the
parts that already work.

## Construction and soak

Changes were built as small, reviewed packets: observe, render, validate, ask
for authority, mutate one bounded surface, and verify independently. This is
slower than improvising, but it leaves every destructive target and rollback
path visible before execution. The project prefers a clean stop over a clever
guess.

That process is not ceremony for its own sake. It is how the project handled a
real sequence of uncertain disk geometry, an empty qcow2 image whose allocation
metadata changed, recovery administration that needed stronger isolation, a
mail-domain validator disagreement, and a DNS method that produced an unwanted
reverse record. The process changed when evidence showed a better answer; the
safety boundary stayed put.

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
- [KMail administrative client](docs/kmail-admin-client.md) records the local
  client configuration and the folder-binding trap that was surprisingly good
  at impersonating a successful setup.
- [`implementation/`](implementation/) contains exact reviewed proposals and
  execution boundaries. Their status lines matter; many are historical.
- [`evidence/`](evidence/) contains sanitized factual results, including
  corrections and stops. A failed gate is part of the technical record, not a
  formatting problem to hide.

Run `scripts/validate/all.sh` for the repository checks. No runtime secret,
mail data, private key, or decrypted onboarding material belongs in Git.

If you are new to the repository, start with the project story and architecture,
then read the runbook. Open an implementation packet when you need the exact
change boundary or want to understand why a particular choice exists. Evidence
is the final word on whether that packet merely proposed something or actually
proved it.

## Lessons from the blockers

- Historical device names are clues, not storage authority. The 256 GiB host
  allocation was made only after current geometry proved the tail was free.

  Modern storage tooling is powerful enough that nostalgia for simpler disk
  layouts is understandable. It is still better to prove the sector range.

- qcow2 allocation metadata is not guest-visible data. Comparing the data disk
  to a fresh zero image resolved that distinction without recreating evidence.
- Stalwart recovery mode needed its own loopback-only network namespace. A
  firewall workaround would have hidden the design mistake instead of fixing
  it.

  Most of my VM habits came from Proxmox. Local modular libvirt has different
  control surfaces, so the familiar assumptions had to be tested again.

- `home.arpa` support was tested against Stalwart 0.16.15 rather than assumed
  from either documentation or the earlier 0.16.4 failure.

  The first attempt used the pinned version already under review. The current
  patch release changed the answer, which was a useful reminder to separate a
  product limitation from a version-specific result.

- A hosts-style DNS entry synthesized a PTR, so it was rolled back and replaced
  with an exact forward-only record.

  My DNS had accumulated enough history to qualify as archaeology. The fix was
  not to hide that history, but to identify the current source of truth and
  reconcile the deployment path.

- Encryption answered “who can read this archive?” It did not answer who owned
  the CA, whether both vault copies matched, or whether either vault returned
  to read-only. Those required separate proofs.

The recurring lesson was simple: representation is not the same as meaning. A
device name is not ownership, allocated qcow2 bytes are not necessarily guest
data, an encrypted file is not automatically well-custodied, and a running
daemon is not proof that its state lives on the intended disk. Tests became
much more useful once they measured the invariant I actually cared about.

## Next gates

The immediate work is to finish and review the soak without confusing elapsed
time with evidence while building the separately gated Fastmail bridge. After
that come the appliance export, isolated restore, deferred endpoint enrollment,
and a separate promotion decision. Permanent placement and migration remain
later projects with their own authorization boundaries.

The intended destination is deliberately modest: a local mail appliance whose
identity survives a host move, whose state can be restored without guesswork,
and whose external dependencies can fail without taking local communication
with them. If it reaches that point, it will be because each claim was tested at
the boundary where it matters—not because the README learned to sound certain.

In plain language: make sure it works. Then make sure I can explain why it
works, recover it when it does not, and move it without changing who it is.
