# Mail-core forward-only DNS acceptance

Date: 2026-08-01  
Service: `mail.home.arpa`  
Disposition: `ACCEPTED`

## Authoritative records

- Infrastructure source commit: `b1686e4b8bf738a58f9de97cbf39be8032421cb8`
- network-cp execution record: `e8549c14ae8e16fe2da098ebaf95e2accb57a06f`
- The accepted Infrastructure address source from `ca48ed3` remained
  byte-identical during the correction.
- Publication uses the reviewed exact forward-only dnsmasq RR overlay, not a
  hosts-style source and not a wildcard `address=` rule.

## Applied result

The reviewed sequential deployment updated `dns-lore` first and `dns-katra`
second. Both resolvers run Pi-hole FTL `v6.6.2` with embedded dnsmasq
`pi-hole-v2.92.2`. Syntax validation and service restart succeeded at each
stage. Automatic rollback remained armed for any semantic verification
failure and was not required.

Independent queries to both `192.168.10.252` and `192.168.10.251` proved:

```text
mail.home.arpa A             192.168.100.199
mail.home.arpa AAAA          no answer
test.mail.home.arpa A        no answer
192.168.100.199 PTR          no answer
```

Representative existing records continued to resolve unchanged. Both
resolvers remained healthy after an additional sequential restart. Sanitized
configuration comparison found only the intended `misc.dnsmasq_lines` semantic
change.

## Collision and scope checks

The immediate collision preflight found no conflicting RouterOS interface,
DHCP pool, reservation, lease, Infrastructure assignment, forward record, or
reverse record. The observed ARP and local-neighbor MAC for
`192.168.100.199` matched the sole `mail-core-9000` NIC on `br-lab10`.

No PTR was published. No RouterOS, bridge, libvirt, firewall, TLS, mail
identity, Fastmail, or public-listener mutation occurred in this DNS step.

DNS publication is accepted. `SOAK_STATUS=NOT_STARTED` remains in force.
