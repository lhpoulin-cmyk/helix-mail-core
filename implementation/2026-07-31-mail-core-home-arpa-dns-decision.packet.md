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
