# Mail-core home.arpa DNS ownership and mutation-path decision packet

**Status:** Read-only evidence and one operator decision required  
**Service identity:** `mail.home.arpa`

## Purpose

Determine the authoritative owner and reviewed mutation path for
`home.arpa` before any DNS record is created. This packet must not query a
resolver, create or change a record, modify Netbrain, alter DNS service
configuration, issue TLS material, or create VM 9000 without separately
authorized evidence collection and mutation packets.

## Required evidence

Using only approved read-only DNS and authority-plane evidence, establish or
leave unresolved:

1. The authoritative servers and zone owner for `home.arpa`.
2. Whether the current internal resolvers are authoritative, recursive-only,
   or forwarders for that zone.
3. The existing owner, change procedure, authentication boundary, review
   process, propagation/TTL practice, and rollback/removal method.
4. Whether `mail.home.arpa` or related forward/reverse records already
   exist, without exposing unrelated DNS data.
5. The eventual record types and target values required for local mail
   acceptance, kept separate from TLS and VM construction decisions.

## Required report

Render only evidence-supported values:

```text
HOME_ARPA_DNS_AUTHORITY=UNRESOLVED_HOME_ARPA_DNS_AUTHORITY
HOME_ARPA_DNS_MUTATION_PATH=UNRESOLVED_HOME_ARPA_DNS_MUTATION_PATH
MAIL_HOME_ARPA_RECORD_STATUS=UNRESOLVED_MAIL_HOME_ARPA_RECORD_STATUS
```

Present one practical ownership/mutation-path decision, including evidence,
recommended choice, alternatives, consequence, exact value to enter
inventory, and whether it is required before local mail acceptance or
promotion readiness.

## Boundaries

No DNS mutation, TLS issuance, router change, VM definition, public inbound
SMTP, Fastmail enablement, or credential creation is authorized. Stop after
the one DNS ownership decision.

## Repository-only decision result — 2026-07-31

**Evidence boundary:** This cycle used committed repository documentation only.
No resolver query, DNS service inspection, authority-plane access, collision
preflight, VM action, or DNS mutation was performed.

### Observed evidence

- Mail-core establishes the durable service identity as mail.home.arpa, but its
  target inventory explicitly records home.arpa DNS ownership/path as
  unresolved.
- Decision 4 freezes the guest address as 192.168.100.199/24, its Netbrain
  gateway, and the two internal resolver addresses. Those values identify
  consumers of DNS, not the owner or publisher of home.arpa.
- The committed Network Contract records an intended single reviewed
  publication source feeding two matching resolvers. It also records that
  resolver deployment remains separate. It does not name the authority,
  primary/secondary relationship, or mutation interface for home.arpa.
- No committed mail-core or control-plane record identifies a repository
  configuration, Pi-hole/dnsmasq configuration, API, local zone file,
  generated configuration, operator, authentication boundary, deployment
  procedure, TTL practice, or rollback path for home.arpa.

### Rendered values

~~~text
HOME_ARPA_DNS_AUTHORITY=UNRESOLVED_HOME_ARPA_DNS_AUTHORITY
HOME_ARPA_DNS_MUTATION_PATH=UNRESOLVED_HOME_ARPA_DNS_MUTATION_PATH
MAIL_HOME_ARPA_RECORD_STATUS=UNRESOLVED_MAIL_HOME_ARPA_RECORD_STATUS
~~~

The eventual forward proposal is:

~~~text
mail.home.arpa.  A  192.168.100.199
~~~

If a reverse zone for the Lab-10 subnet exists and its owner confirms the
change path, the corresponding proposal is:

~~~text
199.100.168.192.in-addr.arpa.  PTR  mail.home.arpa.
~~~

These are proposals only; neither is a DNS change request and neither proves
that the reverse zone exists.

### Decision and consequence

The authoritative owner, whether authority is primary/secondary or
independently duplicated, and the reviewed mutation interface remain
unresolved. Therefore validation, deployment, propagation, rollback, and
two-resolver consistency cannot be specified safely. A DNS mutation packet
cannot be created yet.

DNS publication is not required before VM construction, but the forward record
and two-resolver consistency are required before local mail-service acceptance.
The reverse record is required only if the confirmed reverse-zone owner and
the later accepted service practice require it.

**Disposition: BLOCKED — OPERATOR INPUT REQUIRED**

Provide the authoritative home.arpa owner and its current reviewed mutation
interface. Do not supply a record value or resolver address: those are already
frozen. After that ownership-path decision, prepare the separate bounded DNS
mutation packet and stop for its authorization. Construction TLS remains the
next decision only after DNS ownership is resolved.
