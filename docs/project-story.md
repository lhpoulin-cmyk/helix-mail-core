# Building a local mail plane

## The identity problem

This project began with a small question: if a machine needs to tell me
something, who is speaking? A shared cluster password could make SMTP work, but
it would erase the answer. I wanted `hv-lore`, `ws-matriarch`, and the rest of
the lab to authenticate as themselves, send local status mail, and receive an
administrative reply without depending on the public Internet.

That led to `home.arpa`, the durable service name `mail.home.arpa`, and one
credential per identity. It also led to an early rule that survived every later
revision: receiving an email does not authorize a command. Mail communicates;
it does not hold the keys to the machinery.

## Construction on Matriarch

The appliance was built on `ws-matriarch`, a Fedora 44 workstation acting as a
temporary libvirt construction host. Historical notes mentioned storage and
host names from older layouts, but they were treated as leads rather than
facts. Current read-only evidence established the modular libvirt stack, an
available domain name, and the actual disk geometry.

The operator allocated 256 GiB from the unallocated tail of `nvme1n1`. That
became an XFS filesystem labeled `mailcore-vm`, mounted at
`/var/lib/libvirt/mail-core`, with a directory-backed libvirt pool. The system
and mail-data disks are separate sparse qcow2 images: 32 GiB and 192 GiB. They
share a pool, not a purpose.

The network took a similar path. The existing 10 GbE interface `enp7s0` became
the sole port of `br-lab10`, while the host's default route stayed on `eno1`.
The change used a timed rollback because “the management path probably stays
up” is not a network design. The guest later received
`192.168.100.199/24`, gateway `192.168.100.1`, the two internal resolvers, and
MTU 1500.

## Debian and the untouched disk

The VM was defined with 2 vCPUs, 4096 MiB of memory, one bridge NIC, and the two
existing disks. Debian 13.6 came from an official signed netinst image whose
manifest signatures and hashes were verified before use.

The first headless installer had no useful console, so the installation was
re-run with a private injected preseed and serial automation. Automatic
partitioning named only `/dev/vda`. The 192 GiB `/dev/vdb` data disk was
supposed to remain empty, and a small qcow2 allocation-size change briefly made
that look doubtful. Offline `qemu-img` mapping and comparison showed the
guest-visible disk was still entirely zero. Container metadata had changed;
guest data had not. Recreating the image would have destroyed evidence to make
an accounting number prettier, which is backwards.

The data disk was then partitioned once, formatted as XFS with label
`stalwartdata`, and mounted by filesystem UUID at `/srv/stalwart`. A systemd
mount guard was tested with the filesystem unavailable. Stalwart stayed down
and wrote no fallback state to the root disk.

## Installing Stalwart without the convenient surprise

The official convenience installer did too much for this design: it selected
its own paths, enabled and started the service, and opened bootstrap
administration. The project instead verified pinned server and CLI artifacts,
installed them manually, created a non-login service account, and supplied a
repository-rendered hardened unit.

Recovery mode introduced the next useful failure. Stalwart 0.16.4 could not
prove its recovery listener was loopback-only, so the process was placed in a
temporary systemd network namespace containing only loopback—no veth, route,
NAT, bridge, or firewall exception. The CLI entered the same namespace. After
provisioning, the recovery process, credential, unit, and namespace were
removed.

The first 0.16.4 attempt also rejected `home.arpa`. Rather than patching around
the validator or quietly changing the mail domain, the project upgraded to the
verified 0.16.15 patch release and repeated the isolated compatibility test.
`home.arpa` was accepted. That test settled the architecture with evidence,
not optimism.

## Trust, DNS, and the firewall path

No approved X.509 lab CA existed, and the SSH CA was not volunteered for a
second career. A separate `helix-pki` workspace created an offline ECDSA P-256
root and issuing intermediate. Private CA material was generated in tmpfs,
encrypted to the approved age recipient, verified, and later placed on both
Foundation vaults. The root is the trust anchor; the intermediate is chain
material, not a second root.

The `mail.home.arpa` server key was generated inside the guest and never left
it. The offline issuer signed a 180-day leaf containing exactly that DNS SAN.

DNS publication crossed repository and host boundaries. The source of truth
lived in Infrastructure, deployment ran through network-cp, and the sequential
resolver path depended on SSH trust and a narrow firewall allowance. Those
dependencies were reconciled instead of bypassed. A first hosts-style record
created an unauthorized PTR, so it was rolled back. The accepted method
publishes one exact forward A record and no PTR, wildcard, or invented AAAA.

## Correspondents, bundles, and custody

The operational population became two administrators, three hypervisors, and
four workstations. Every identity received a separate random credential. The
accepted archive set covers all seven machines, Admin, and Louis; the current
manifest does not claim a separate Cluster-Admin onboarding archive.
`postmaster` and disposable test identities serve supporting roles.

Every bundle was decrypted in protected temporary space, checked against its
manifest, and copied independently to Foundation and Second Foundation. Both
encrypted filesystems returned to read-only after their write windows, and the
destination hashes matched the source. Encryption protected contents; the
hashes and remount checks established custody. Different questions need
different proofs.

Five physical endpoints and both administrative mailboxes completed the beta
demonstration. `ws-alpha` and `ws-wowzerwin` retain their independent identities
and bundles but remain explicitly deferred.

## The 1.1.1 gate

The first alpha-to-beta test proved general authenticated send and receive.
Then the policy became more precise: machines may report to Admin and Cluster
Admin, but only those administrators may deliver to machine mailboxes. A
Stalwart RCPT-stage system Sieve policy now rejects other local senders before
message data. Submission separately prevents a machine credential from using
an administrative envelope sender.

The first policy expression did not behave as expected. It was rolled back,
corrected, restarted, and tested again. The accepted matrix proved
administrator-to-machine delivery, machine-to-administrator reporting,
machine replies, SMTP 550 rejection for unauthorized machine delivery,
sender-impersonation rejection, external-relay rejection, and trusted TLS on
every credential-bearing connection.

That evidence satisfied the blocker, and the operator promoted the repository
to `1.1.1-beta`. The soak is running. Production is not. The remaining work is
less glamorous and more important: observe the system, create a consistent
appliance export, restore it in isolation, and decide where the durable
appliance will live.
