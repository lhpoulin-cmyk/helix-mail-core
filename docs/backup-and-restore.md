# Backup and restore

Status: **unverified by design** until a consistent appliance export and an
isolated import/restore exercise pass. Matriarch backup architecture is outside
scope; the appliance export is the construction acceptance artifact.

Before export, record Stalwart version, service state, data-disk identity,
configuration revision, queue count/IDs, identity export, certificate metadata,
and export manifest receipt. Quiesce or use Stalwart-supported application
consistency procedures before copying `/srv/stalwart/data`; never assume a raw
live copy is consistent. Export configuration, data/queue/identity state, TLS,
version information, and separately protected secret recovery material.
Encrypt restricted artifacts.

A non-destructive restore-check creates an isolated target, verifies export
manifest/checksums and both disks, mounts recovered data read-only where
possible, verifies expected paths and database readability, inventories queued
message IDs without delivery, and records the result. Do not restore over a
live system. A full proof additionally imports/boots an isolated recovered
appliance, verifies
local delivery, and compares pre/post queue IDs so queued messages are neither
lost nor duplicated.
