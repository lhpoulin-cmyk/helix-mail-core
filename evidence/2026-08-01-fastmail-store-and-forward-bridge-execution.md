# Fastmail store-and-forward bridge execution

Recorded: 2026-08-01 (America/Detroit)

Disposition: **CORRECTION REQUIRED**

## What worked

The dedicated Fastmail app password was entered through protected local state
and installed at `/etc/stalwart/secrets/fastmail-app-password` without exposing
its value. The committed Stalwart plan passed declarative dry-run and applied
without schema errors. After the required Stalwart service reload, both bounded
compatibility probes passed:

- `cluster-admin@home.arpa` retained local delivery to `admin@home.arpa`, and
  one copy reached `admin@poulin-arpa.com`;
- `admin@home.arpa` retained local delivery to `cluster-admin@home.arpa`, and
  one copy reached `cluster_admin@poulin-arpa.com`.

Stalwart handed both copies to `smtp.fastmail.com:465` over verified implicit
TLS and received SMTP `250` acceptance. No public SMTP listener, inbound
Fastmail route, or unrelated listener was introduced.

## Reload correction

The first compatibility probes remained local because the declarative objects
had been stored but the running Stalwart process had not reloaded them. No
Fastmail copy or queued retry was created. Restarting the service loaded the
reviewed configuration; fresh probes then passed. The old probes were not
resent.

## Outage test and unresolved queue entry

The first service-local outage simulation used loopback as the temporary relay
target. Stalwart correctly classified that target as a permanent configuration
error and discarded only the generated test copy after a double bounce. The
authoritative local message was delivered. This simulation did not prove retry
persistence and was rejected as a test method.

The corrected simulation used the documentation-only address `192.0.2.1`.
Local delivery again passed, and Stalwart created remote queue entry
`321587534895251968` for only `cluster_admin@poulin-arpa.com`. The canonical
Fastmail route was restored and the guest was rebooted. The entry remained
recorded, but Stalwart did not produce a later retry or completion event during
the monitored interval. No administrative force-retry or deletion was used.

## Fail-closed result

Because queue recovery was not proven, the DATA-stage Sieve selector and
Fastmail-specific outbound strategy were restored to their accepted pre-bridge
values. Stalwart was restarted and read-back confirmed:

- `MtaStageData.script` is `false`;
- outbound routing is the accepted local/MX baseline;
- no new Fastmail copies can be generated;
- local mail remains active;
- the relay object, protected secret, and queue evidence remain available for
  a separately reviewed correction;
- public SMTP remains absent.

The bridge is therefore **disabled**, despite successful normal-path Fastmail
delivery. A correction must establish supported queue inspection and recovery
for an interrupted relay attempt before activation can be accepted.
