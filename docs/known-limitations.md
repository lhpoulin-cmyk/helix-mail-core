# Known limitations

## Fastmail copies during restart

The version 1.1.1-beta Fastmail feature is a **best-effort external copy
bridge**. It is not durable store-and-forward, exactly-once delivery, or
restart-safe outbound queueing.

> An external Fastmail copy may be lost if Stalwart is stopped or restarted
> while that copy is in an active delivery attempt. Local authoritative
> delivery is unaffected.

Normal authenticated copies from both administrative mailboxes have received
SMTP 250 acceptance from Fastmail. During a bounded interruption test, an
active generated copy temporarily disappeared from management queries and had
no terminal event during the original observation window. It later recovered
and delivered exactly once through the fallback MX route. That late recovery
does not prove restart safety for the intended authenticated relay path. No
local message was lost or changed.

For beta operations:

1. inspect the outbound queue before planned Stalwart restart or guest reboot;
2. do not deliberately restart while Fastmail entries are active;
3. if the queue is nonempty, wait or explicitly accept possible loss of those
   non-authoritative copies;
4. never resend automatically based only on uncertain delivery;
5. treat Fastmail as notification and convenience, never authority.

Durable outbound recovery is a later milestone. It does not block the current
beta or change the existing soak timestamp.

## Inbound operator-direction enforcement

The repository defines an authoritative operator-direction policy for
authenticated mail from `louis@poulin-arpa.com` to the two designated local
control mailboxes. It does not yet contain accepted evidence of a deployed
Fastmail-to-`home.arpa` transport or coder-intake service. Public SMTP remains
disabled. Until that implementation is separately reviewed and verified, the
policy is an authority contract, not a working command path.
