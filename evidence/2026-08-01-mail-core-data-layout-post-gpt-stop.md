# Mail-core data layout post-GPT stop

Disposition: **CORRECTION REQUIRED**
Authorization baseline: `1304b4a`
Target: `/dev/vdb` in `mail-core-9000`

## Live mutation and stop point

The repeated immediate preflight proved `/dev/vda` was the distinct installed
32 GiB system disk and `/dev/vdb` was the distinct empty 192 GiB data disk. The
authorized GPT operation then created only `/dev/vdb1` with the reviewed
geometry:

```text
start sector: 2048
end sector:   402653150
size:         206157364736 bytes
type:         8300 Linux filesystem
name:         stalwart-data
```

The kernel reread succeeded, `/dev/vdb1` appeared, the exact start and sector
count checks passed, and `sgdisk --verify` reported no problems. Its warning
that the last-usable-sector end is not a 2048-sector boundary is a consequence
of the explicitly reviewed end sector; no encryption layout is being created.

Execution then stopped before `mkfs.xfs`. The packet incorrectly required all
`blkid /dev/vdb1` output to be empty. A GPT partition legitimately reports
`PARTLABEL` and `PARTUUID` even when it has no filesystem. Read-only inspection
confirmed that only those expected partition fields exist: filesystem `TYPE`,
filesystem `UUID`, and filesystem `LABEL` are absent, and `wipefs -n` reports
no filesystem signature.

No filesystem, `/etc/fstab` entry, `/srv/stalwart` directory, or mount was
created. No repartition, retry, formatting, repair, or Stalwart action followed.

## Required correction

Resume from the preserved exact GPT state. Replace the over-broad assertion
with explicit absence checks for filesystem `TYPE`, `UUID`, and `LABEL`, retain
the empty `wipefs` check, then execute the already reviewed XFS, UUID-fstab,
mount, and reboot-verification stages. Do not rerun `sgdisk`.
