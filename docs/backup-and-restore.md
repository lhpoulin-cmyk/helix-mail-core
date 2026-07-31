# Backup and restore

Status: **unverified by design** until a backup is created and a restore
exercise passes. VM backup alone is insufficient unless it includes both disks,
configuration, and a controlled secret restoration plan.

Before backup, record Stalwart version, service state, data-disk identity,
configuration revision, queue count/IDs, identity export, certificate metadata,
and backup target receipt. Quiesce or use Stalwart-supported application
consistency procedures before copying `/srv/stalwart/data`; never assume a raw
live copy is consistent. Back up configuration, data/queue/identity state, TLS,
and separately protected secret recovery material. Encrypt restricted backups.

A non-destructive restore-check creates an isolated target, verifies backup
manifest/checksums and both disks, mounts recovered data read-only where
possible, verifies expected paths and database readability, inventories queued
message IDs without delivery, and records the result. Do not restore over a
live system. A full proof additionally boots an isolated recovered VM, verifies
local delivery, and compares pre/post queue IDs so queued messages are neither
lost nor duplicated.

