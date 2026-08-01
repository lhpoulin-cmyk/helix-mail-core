# Mail-core data layout XFS-label block

Disposition: **BLOCKED — OPERATOR INPUT REQUIRED**
Authorization baseline: `2a72940`
Target: `/dev/vdb1` in `mail-core-9000`

The complete post-GPT preflight passed. `/dev/vdb1` retained the exact reviewed
geometry and was the sole authorized target. Filesystem TYPE, filesystem UUID,
filesystem LABEL, wipefs signatures, mount, swap, LVM, RAID, and md ownership
were absent. `/dev/vda` remained the distinct installed system disk.

The exact reviewed command `mkfs.xfs -L stalwart-data /dev/vdb1` returned
nonzero before creating a filesystem. Immediate read-only inspection proved
that `/dev/vdb1` still contains only its expected GPT PARTLABEL/PARTUUID and has
no filesystem signature, fstab entry, mountpoint, or mount.

A subsequent `mkfs.xfs -N` no-modify diagnostic established the cause:
`stalwart-data` is 13 characters, while this XFS implementation permits a
maximum filesystem label length of 12 characters. The diagnostic performed no
write.

No retry, substitute label, format, fstab, mount, reboot, or Stalwart action
followed. An operator-approved XFS label of at most 12 characters is required.
The recommended smallest correction is `stalwartdata`, preserving the meaning
while removing only the unsupported hyphen.
