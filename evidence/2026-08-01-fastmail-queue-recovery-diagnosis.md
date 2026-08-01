# Fastmail queue-recovery diagnosis

Recorded: 2026-08-01 (America/Detroit)

Disposition: **CORRECTION REQUIRED**

## Preserved identifier

The requested queue identifier was `321587534895251968`. No message body,
header set, authentication material, or unrelated queue content was inspected.

## Current state

- `stalwart-cli get QueuedMessage 321587534895251968 --json`: not found.
- `stalwart-cli query QueuedMessage --json`: no live queue objects returned.
- Fastmail read-only search for the probe identifier: no receipt found.
- Complete Stalwart event correlation: queue creation, attempt start,
  domain-attempt start, and TLSA lookup only.
- Missing events: connection result, temporary failure, reschedule, attempt end,
  SMTP acceptance, and delivery completion.

The entry is therefore neither administratively held nor waiting for a future
retry. It no longer exists. It was not deleted or rescheduled during this
diagnostic cycle.

## Route and scheduler correlation

The Fastmail relay remains object `i0uaggi1abaa`, pointing to
`smtp.fastmail.com:465` with implicit TLS and file-backed authentication. The
object ID remained stable through the earlier destination changes. Stalwart
`0.16.15` evaluates the outbound route and named route for each due recipient
at attempt time, so queued state does not retain the relay object's ID or the
previous resolved next hop.

The `remote` delivery schedule still targets virtual queue `b`; queue `b`
exists with 50 threads. Local, DSN, and report queues also remain present.
There is no evidence of a global scheduler failure or unrelated queued item.

## Failure classification

The prior test restarted Stalwart while the TEST-NET connection attempt was
still active. The attempt never reached a temporary-failure or reschedule
state. After restart, the runtime management object was absent without a
terminal delivery event. This is a failed test boundary and apparent loss of a
generated test copy, not a normal deferred-delivery result.

The earlier loopback test is separately unsuitable because Stalwart explicitly
classifies a loopback relay target as a permanent configuration failure.

## Supported correction

For a later reviewed test, preserve the relay object and use the guest's own
non-listening `192.168.100.199:1465` endpoint. Wait until Stalwart records a
completed connection failure, `delivery.attempt-end`, and queue rescheduling
before restarting anything. Then verify the live `QueuedMessage` object,
restore `smtp.fastmail.com:465`, and allow automatic retry. Stalwart's supported
`QueuedMessage.nextRetry` update is a fallback only after duplicate-delivery
preflight and only against the same live object.

No new real Fastmail message was sent during this correction cycle. The bridge
remains disabled fail-closed; public SMTP remains absent.
