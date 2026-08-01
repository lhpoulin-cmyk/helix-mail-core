# Mail-core TLS and DNS acceptance gate review

Date: 2026-08-01  
Reviewed baseline: `372b5642511747065bff82f3e68ca99ab3100cec`  
Reviewed packet: `implementation/2026-08-01-mail-core-tls-dns-acceptance.packet.md`

## Scope disposition

The packet is limited to the accepted DNS and trusted-TLS gates for
`mail.home.arpa`: one forward record, one private-lab-CA leaf, protected
certificate installation, authenticated submission on the Lab-10 address,
IMAPS, and internal acceptance tests. It preserves the prohibitions on public
SMTP and administration, POP3, ManageSieve, public JMAP, Fastmail, external
delivery, public ACME, PTR invention, new identities, network redesign, and
promotion/export work.

The operator's current authorization therefore covers the packet's intended
mutation surface, but its mandatory preconditions are not satisfied.

## DNS gate

The clean network-cp worktree at commit
`71968778f8f80886183d6ebb0da634afe364e90b` documents:

- authoritative input: `/home/louis/infrastructure/standards/IP_ADDRESSING.md`;
- proposed record: `mail.home.arpa -> 192.168.100.199`;
- generated sequential deployment through
  `nodes/hv-lore/scripts/dns-sync-katra-to-lore-hosts.sh`;
- resolver order: `dns-lore`, then `dns-katra`;
- no reviewed reverse-zone mutation path and therefore no PTR proposal.

The authoritative Infrastructure checkout was not clean during immediate
review. Its changes include `standards/IP_ADDRESSING.md`, the exact DNS source
file this packet would edit. Those changes were not altered, stashed, reset,
cleaned, or committed. The packet requires a current clean source and an exact
single-record generated diff, so DNS mutation did not proceed.

The final collision preflight was not treated as waived. It must pass from
current RouterOS, DHCP, ARP/neighbor, DNS, and committed Infrastructure evidence
immediately before a later authorized publication/listener activation.

## Trusted-TLS gate

Committed Infrastructure documentation records a preference for a private lab
CA and manual client trust, but it does not establish an operating issuance
path. Read-only host and repository inspection did not identify:

- an approved CA owner or issuer host/service;
- an installed supported CA issuance tool or reviewed issuance command/API;
- a protected leaf-key delivery interface;
- a current trust-root distribution inventory for approved clients;
- renewal ownership and the 30-day review procedure;
- revocation/reissue and rollback procedure.

No new CA may be created under this packet. Certificate issuance and trusted
client validation therefore cannot proceed safely.

## Live-state result

No DNS record was published. No certificate or private key was created or
installed. No Stalwart listener or configuration was changed. No service was
restarted. No RouterOS, bridge, firewall, libvirt, Fastmail, identity, or mail
delivery mutation occurred.

## Required resolution

Resume only after both conditions are independently established:

1. a clean, current Infrastructure source state whose rendered DNS diff is
   limited to `mail.home.arpa -> 192.168.100.199`; and
2. an existing approved private-CA owner and exact supported issuance,
   protected delivery, client trust, renewal, revocation, and rollback path.

Disposition: `BLOCKED — OPERATOR INPUT REQUIRED`
