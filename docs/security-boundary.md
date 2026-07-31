# Security boundary

The first release is internal only: no public MX, inbound SMTP, router
forwarding, public DNS dependency, direct Internet delivery, or arbitrary
external recipients. Bind Stalwart only to the approved internal guest
interface. Host and network firewall rules must allow only approved internal
sources to 587 and 993; no port 25 listener exists.

SMTP submission requires TLS and authentication. Each machine/service identity
has a distinct credential. Unknown local recipients are rejected, domain
split-delivery is disabled, and external recipients are rejected by default.
The Stalwart policy contract explicitly records these invariants; deployment
must configure equivalent live MTA-stage controls and verify them.

Use a local CA certificate for `mail.home.arpa`, with trust deployed only to
approved clients. The implementation packet must name the CA owner, issuance
method, certificate/key paths, renewal trigger, expiry alert, revocation or
replacement procedure, and client trust rollout. Private keys remain
root/service-readable only and are separately recoverable.

Email is communication only. No mail content grants operational authority or is
executed. A later parser/bridge may only classify and propose actions.

