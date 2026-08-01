# Fastmail queue-recovery correction packet

Status: diagnosis preserved; durable recovery deferred to a later milestone
Baseline: `8b983da483c358290a73404b4bdc26e35648de8f`
Target: `mail.home.arpa` / Stalwart `0.16.15`
Preserved queue entry: `321587534895251968`

## Purpose and boundary

Determine why the existing Fastmail test copy did not resume after its relay
was restored, then render the smallest supported correction. The bridge remains
disabled fail-closed while this diagnosis runs. No message reinjection,
database or queue-file edit, body inspection, queue deletion, public SMTP,
general relay, DNS, TLS, identity, sender, soak, or promotion mutation belongs
to this packet.

The operator accepted this diagnosis as a version 1.1.1-beta limitation. No
further exactly-once or active-attempt restart testing is required for beta.
The correction design remains a future durable-outbound milestone and does not
block the current soak or the best-effort bridge.

The existing queue entry must not be released or rescheduled until its state,
retry policy, route association, and duplicate-delivery risk are understood.

Late observation: after the diagnosis commit, Stalwart rediscovered the entry,
retried it through the then-active fallback MX route, received one temporary
451 response, rescheduled it for two minutes later, and completed delivery with
SMTP 250. Fastmail contained exactly one copy. This supersedes the time-bounded
conclusion that the test copy was lost, without rewriting the earlier evidence.
It does not prove restart-safe recovery through the intended authenticated
relay and does not reopen that beta gate.

## Observed diagnosis

The required object is no longer present. The supported command
`stalwart-cli get QueuedMessage 321587534895251968` returns `not found`, and a
queue query returns no entries. A read-only search of the Fastmail account finds
no copy bearing the corresponding non-secret probe identifier.

The complete Stalwart log contains only four events for this ID: queue creation,
attempt start, domain-attempt start, and TLSA lookup against the temporary
`192.0.2.1` next hop. It contains no connection result, temporary failure,
reschedule, SMTP acceptance, attempt end, or delivery completion. The entry
therefore disappeared without either supported delivery completion or a
recorded administrative disposition.

The relay object still has stable ID `i0uaggi1abaa` and the canonical
`smtp.fastmail.com:465` destination. Its ID did not change across the reviewed
upserts. Stalwart `0.16.15` source confirms that the outbound route expression
and named route are evaluated for each due recipient at attempt time; a queued
message does not retain a stale relay-object identifier or resolved next hop.

The accepted `remote` schedule points to virtual queue `b`, which remains
present with 50 threads. Other schedule and queue objects are healthy. There is
no evidence that the scheduler was globally stopped.

The disappearance correlates with the prior test forcibly restarting Stalwart
while its connection to `192.0.2.1` was still in progress and before the attempt
had emitted a terminal event. That test method is rejected. It does not prove
the behavior of a normally completed temporary failure or scheduled retry.

Because the operator explicitly required preservation of this entry, its
absence blocks a new real external test. The missing object cannot be safely
reconstructed: reinjection, cloning, database edits, and queue-file edits are
both unsafe and prohibited.

## Evidence sources

Use, in order:

1. Stalwart `0.16.15`'s live `QueuedMessage` management object;
2. the current service log and boot timeline;
3. current `MtaRoute`, `MtaOutboundStrategy`, delivery-schedule, and virtual
   queue objects;
4. Stalwart's official queue-management and scheduling documentation;
5. the prior sanitized execution record.

Official Stalwart documentation defines `QueuedMessage` as runtime management
state with per-recipient status, retry count, retry due time, error, and queue
name. It also documents CLI/JMAP inspection and an update-based requeue path.
The default retry schedule is measured after a completed temporary failure; an
attempt with no terminal event must not be called deferred merely because time
passed.

## Read-only collection

Collect only sanitized metadata for queue entry `321587534895251968`:

- object ID, created time, size, flags, received port, and envelope recipient;
- message-level `nextRetry` and notification time;
- recipient queue name, status, retry count, retry due time, expiry, flags,
  error class, remote hostname, and SMTP status where present;
- blob reference only as a one-way fingerprint if correlation requires it;
- no body, headers, credential, AUTH transcript, or unrelated queued content.

Also capture:

- all events carrying this queue ID;
- Stalwart boot, queue-start, relay-change, and restart times;
- the current relay object's stable ID and destination;
- whether that ID changed across each upsert recorded in the execution logs;
- the active scheduler and virtual queue configuration;
- a count and sanitized status summary of other queued objects;
- queue-lock or task-manager evidence relevant to recovery.

Classify unavailable observations explicitly. Do not infer a stale route ID
without evidence; outbound strategy can be evaluated at attempt time.

## Correction decision

Render one correction only after diagnosis. Preferred order:

1. leave the relay object at its stable identity and simulate a temporary
   transport failure without replacing or deleting it;
2. use the existing retry schedule when its state is healthy;
3. if the interrupted attempt retains a stale lock, use only a documented
   Stalwart lock-maintenance or queue-reschedule operation;
4. update only `QueuedMessage.nextRetry` if the live schema and official
   documentation establish that as the supported, idempotent requeue action.

The rendered correction is to replace the interruption method, not the bridge:

- retain the same relay object and ID;
- temporarily set only its destination to the guest's own non-listening
  address and port, `192.168.100.199:1465`, which yields a completed connection
  refusal rather than a permanent loopback classification or a hanging
  TEST-NET connection;
- wait for `delivery.failed`, `delivery.attempt-end`, and `queue.rescheduled`
  before any restart or route restoration;
- inspect the same `QueuedMessage` object and its `TemporaryFailure`, retry
  count, retry due time, and queue name;
- restore the canonical destination while preserving the relay object ID;
- prefer automatic retry; if necessary, use the documented update of that same
  object's `nextRetry`, after proving no prior SMTP acceptance and no Fastmail
  receipt;
- never restart or reboot while an outbound attempt lacks a terminal event.

This correction is repository-rendered only. It is not executed because the
required original preservation gate has already failed.

Before any administrative requeue, prove the recipient has not already been
accepted externally, its status is not completed, and the operation changes the
same object rather than creating another. Record the exact before/after object
ID and retry count. Never edit the datastore directly.

## Fake and local verification

Before a new real Fastmail message, use repository validation, schema dry-runs,
read-only queue inspection, and a local-only submission with the bridge disabled
to prove:

- local delivery does not depend on the relay;
- unrelated identities create no Fastmail recipient;
- bridge disablement remains fail-closed;
- a retained queue object survives service restart and guest reboot;
- restoring the same relay preserves its object ID;
- the scheduler or supported requeue operation sees the same entry without
  cloning it.

## Final external test gate

Only after the correction render is independently reviewed may one new unique
probe be sent. The bridge may be enabled only for that bounded window. Require
one local delivery, one generated external queue entry, a temporary transport
failure, persistence through the reviewed restart boundary, restoration of the
same relay, eventual SMTP `250`, exactly one Fastmail receipt, no duplicate
after one additional retry interval, and normal queue completion.

The original queue entry remains separately preserved until its supported safe
disposition is established.

## Acceptance

Accept only when automatic or documented administrative recovery is proven
without message loss, duplicate external delivery, secret exposure, or wider
relay. If accepted, re-enable only the exact-recipient bridge and commit a
sanitized execution record. Otherwise remain disabled and issue the exact
failed gate.
