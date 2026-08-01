# Mail-core guest baseline and data-layout partial execution

Disposition: **CORRECTION REQUIRED**
Authorization baseline: `64ea3c0`
Target: `mail-core-9000` on `ws-matriarch`, `qemu:///system`

## Completed authorized mutation

The immediate repository, host, domain, network, storage, account, and empty
`/dev/vdb` gates passed. Debian repositories were only the installed official
Trixie, Trixie security, and Trixie updates sources. The fresh simulation
matched the reviewed baseline: one new security kernel, one kernel metapackage
upgrade, and zero removals.

The following reviewed package actions completed:

- `linux-image-6.12.100+deb13-amd64` 6.12.100-1 installed;
- `linux-image-amd64` upgraded to 6.12.100-1;
- `gdisk` 1.0.10-2 installed;
- `xfsprogs` 6.13.0-2+b1 installed with its Debian dependencies.

The `xfsprogs` package preset enabled and activated its standard
`xfs_scrub_all.timer`. No reboot-required marker was present, so the packet did
not reboot at this stage; the running kernel remained 6.12.94. A later reboot
verification remains required before acceptance.

## Fail-closed stop

Immediately before the first disk write, the repeated disk-identity checks
passed but the required-tool check established that `partprobe` is unavailable.
The packet did not authorize installing `parted`, and substituting a command
during live execution was prohibited. Execution therefore stopped before
`sgdisk`.

Current read-only evidence still shows:

- `/dev/vda` is the distinct 32 GiB installed system disk;
- `/dev/vdb` is exactly 206158430208 bytes with no partition, filesystem,
  label, mount, LVM, RAID, or swap ownership;
- `/srv/stalwart` and its fstab entry do not exist;
- `blockdev --rereadpt` and `partx` are installed; `partprobe` is not;
- SSH and QEMU guest agent are active, password SSH remains usable, root SSH
  remains disabled, and the accepted construction account model is unchanged;
- host libvirt storage, `br-lab10`, and the `eno1` management/default route
  remain healthy.

No disk, fstab, mount, network, DNS, TLS, mail, libvirt, or host mutation
occurred. Stalwart execution was not started.

## Rendered correction

The implementation packet now substitutes the installed util-linux command:

```sh
blockdev --rereadpt /dev/vdb
```

for the unavailable `partprobe /dev/vdb`. The following `udevadm settle`, block
device existence, exact geometry, and `sgdisk --verify` gates are unchanged.
This adds no package and does not change the approved disk layout or target.
The corrected render requires operator review before disk execution resumes.
