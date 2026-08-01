# Fastmail best-effort bridge acceptance

Recorded: 2026-08-01 (America/Detroit)

Disposition: **FASTMAIL BEST-EFFORT BRIDGE ACCEPTED**

## Beta contract

The operator reclassified the feature as a best-effort external copy bridge.
Local Stalwart mail remains authoritative. Fastmail copies are notifications
and conveniences, not durable or exactly-once records. Planned Stalwart
restarts require a queue check; uncertain delivery is never replayed
automatically.

## Reactivation

The repository reclassification was committed before live work. Immediate
preflight confirmed:

- the Stalwart queue query returned no entries;
- relay object `i0uaggi1abaa` still pointed to `smtp.fastmail.com:465`;
- the Fastmail credential remained file-backed with mode `0640` and ownership
  `root:stalwart`;
- `/srv/stalwart` was mounted and Stalwart was active;
- the DATA-stage Fastmail selector was disabled;
- public SMTP port 25 was absent.

The checked-in four-object plan passed dry-run, applied without error, and was
loaded by one planned restart while the queue was empty. Read-back confirmed
the two exact Fastmail recipient routes, the local fail-closed fallback, and the
authenticated-port-587 DATA selector.

## Ordinary-path tests

Two unique ordinary probes passed:

- `cluster-admin@home.arpa` to `admin@home.arpa`: local retention passed and
  one copy reached `admin@poulin-arpa.com` with Fastmail SMTP 250 acceptance;
- `admin@home.arpa` to `cluster-admin@home.arpa`: local retention passed and
  one copy reached `cluster_admin@poulin-arpa.com` with Fastmail SMTP 250
  acceptance.

A separate `test-sender@home.arpa` to `test-receiver@home.arpa` probe remained
local and produced no Fastmail copy. An arbitrary external RCPT was rejected.
The post-test queue was empty. No interruption or post-queue restart test was
performed.

## Late recovery of the historical probe

After the earlier queue-diagnosis window, preserved queue ID
`321587534895251968` reappeared in service events. While the pre-bridge
fallback MX strategy was active, it received a temporary 451 response,
rescheduled for two minutes, then received SMTP 250. A read-only Fastmail
search found exactly one copy in Spam.

This late event supersedes the earlier time-bounded conclusion that the probe
was lost. It used direct MX rather than the intended authenticated Relay object,
so it does not establish restart-safe recovery for the active bridge. The
original diagnosis evidence remains unchanged.

## Preserved boundaries

- public SMTP port 25 remains absent;
- arbitrary external recipients and general relay remain rejected;
- the route is available only to the two generated exact recipients;
- the protected credential was neither printed nor changed;
- local authoritative messages were retained unchanged;
- the soak timestamp and beta release state were not changed.
