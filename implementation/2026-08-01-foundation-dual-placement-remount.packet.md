# Foundation dual-placement temporary remount

Status: render-and-review only — no write/remount authority  
Observed: 2026-08-01 on `ws-matriarch`

## Targets and sanitized identity

| Role | Mapper and mount | Filesystem | Filesystem UUID SHA-256 | LUKS UUID SHA-256 | Capacity / available |
| --- | --- | --- | --- | --- | --- |
| Foundation | `/dev/mapper/luks-f28aa6f4-6234-4f06-a762-f62ee3b001bc` at `/run/media/louis/LAB_ROOT_TRUST` | ext4 `LAB_ROOT_TRUST` | `f5abe13daa5d35f270f18b66e873cd72195a5fb2df5a2225a3e243f6b086435c` | `5e9fcb4eab2a04d89061e4253e6f97e74c684ad83eed268fa35711557ef97d99` | 30,353,002,496 / 28,721,295,360 bytes |
| Second Foundation | `/dev/mapper/lab-vault` at `/run/media/louis/FOUNDATION-2` | ext4 `FOUNDATION-2` | `e5272bbe7a38494ac5911b644535f4dc364f25cb34c41ffbc2af0661b70bc1d2` | `069b2b19c0827df9672da95bda60848e3aaa8a9aaf2fab5c1b478443f8a80d31` | 33,618,149,376 / 31,819,517,952 bytes |

The mappings use distinct LUKS2 containers, block devices, device-mapper
devices, ext4 UUIDs, and filesystems. UDisks2 owns both active mounts
(`uhelper=udisks2`); neither is an fstab or persistent systemd mount.

The mount directories are owned by UID/GID 1000. Foundation `credentials/` is
mode 0700 and owned by UID/GID 1000. Second Foundation `credentials/` was
observed mode 0755 and owned by UID/GID 65534; do not silently change it. Render
the exact restrictive target subdirectory ownership separately before copying.

## Material live-state discrepancy

The unprivileged sandbox view initially reported both mounts read-only. The
privileged host view subsequently and authoritatively reported both `rw`.
No command in this inspection changed mount state. One user shell held its
current directory on Foundation; Second Foundation had no user process reported
beyond the kernel mount.

This violates the assumed read-only starting state and blocks execution. Before
any later write window, identify the cause, leave both mounts read-only, and
prove no process has a working directory or open writable file on either vault.

## Exact proposed files

Copy only these ciphertext archives and one non-secret manifest describing
their names and SHA-256 values:

```text
hv-lore-mail-onboarding.tar.gz.age
hv-katra-mail-onboarding.tar.gz.age
hv-matrix-mail-onboarding.tar.gz.age
ws-matriarch-mail-onboarding.tar.gz.age
ws-alpha-mail-onboarding.tar.gz.age
ws-hadrian-mail-onboarding.tar.gz.age
ws-wowzerwin-mail-onboarding.tar.gz.age
machine-mail-onboarding.manifest.json
```

The target subdirectory name must be reviewed before execution. No plaintext
bundle or credential file may be copied directly.

## Rendered management method

The current UDisks2 mount remains registered while Linux performs a bounded
in-place ext4 remount. The future execution uses only:

```text
sudo mount -o remount,rw <exact-mountpoint>
sudo mount -o remount,ro <exact-mountpoint>
```

No unlock, unmount, filesystem repair, automount change, or mapper change is
part of this method. Immediately query `findmnt` after every remount. Stop if
UDisks2 no longer reports the same mapper, mountpoint, label, filesystem, or
fingerprinted UUID.

## Future bounded procedure — independently per vault

1. Re-read `blkid`, `cryptsetup status`, UDisks2 block properties, `findmnt`,
   `df`, directory `stat`, and `fuser` under the privileged host view.
2. Hash the observed filesystem and LUKS UUID strings locally and compare them
   with the committed fingerprints above without logging raw identifiers.
3. Require the exact mapper, ext4 label, mountpoint, read-only option, adequate
   free space, distinct device number, and no active user process.
4. Require all eight source files to be regular files with exact reviewed
   names, restrictive modes, and a verified local manifest. Reject symlinks,
   devices, FIFOs, sockets, hard-link surprises, or extra files.
5. If the reviewed target subdirectory is absent, create only that directory
   with the separately approved UID/GID and mode 0700. If present, verify it is
   a real directory on the expected filesystem and not a symlink or mount.
6. Run `sudo mount -o remount,rw <exact-mountpoint>` and require `findmnt` to
   show `rw` on the same fingerprinted filesystem.
7. For each archive, stop if the destination exists with a different hash. If
   it exists with the same hash, leave it unchanged. Otherwise install it with
   mode 0600 and the reviewed owner. Install the manifest mode 0600.
8. Run `sync -f <target-subdirectory>` followed by `sync` and verify every
   destination SHA-256 against the source manifest.
9. Run `sudo mount -o remount,ro <exact-mountpoint>` even after a copy failure.
10. Require `findmnt` to show `ro`; revalidate mapper, fingerprints, label,
    filesystem, mountpoint, and distinct device number.
11. Re-hash all eight files after the read-only remount and require exact
    source matches.
12. Record only filenames, hashes, the non-secret Foundation role, timestamps,
    and pass/fail status.

Execute Foundation and Second Foundation as separate transactions. The first
must be back to verified read-only before opening the second write window.

## Failure and rollback

On any failure, stop copying, flush what was successfully written, and attempt
only the reviewed `remount,ro` on that same verified mount. Do not delete or
replace a pre-existing differing file. Preserve any newly copied matching
ciphertext for operator review; deletion requires separate authority. If
read-only restoration fails, stop immediately, report the exact vault role,
and keep all further vault and soak work blocked.

## Stop conditions

Stop for writable pre-state, mismatched source/mapper/fingerprint/label,
same-device resolution, active users, unsupported remount, insufficient space,
unreviewed target ownership, filename collision, copy/hash/decryption failure,
failure to restore read-only, secret exposure, or any unrelated credential
mutation.

No remount, directory creation, copy, deletion, or other vault write was
performed by this packet.
