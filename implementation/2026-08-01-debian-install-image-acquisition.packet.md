# Debian 13.6 netinst installation-image acquisition

Status: operator-authorized bounded acquisition
Target: `ws-matriarch` local libvirt boot-image directory

## Fixed artifact and destination

```text
GUEST_INSTALL_IMAGE=debian-13.6.0-amd64-netinst.iso
GUEST_INSTALL_IMAGE_REFERENCE=/var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso
GUEST_INSTALL_IMAGE_SHA512=record only after successful signed-manifest verification
```

The target is the existing local libvirt boot-image directory. The previously
observed OS-slinger ISO namespace is read-only NFS artifact storage, not the
local image attachment path for this construction host.

## Official source and trust path

Use only these official Debian HTTPS resources under the current amd64 CD
directory:

```text
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS.sign
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS
https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS.sign
```

The host does not have `debian-archive-keyring` installed. Use Debian's
documented CD-signing public key as the alternate trust path:

```text
https://www.debian.org/CD/key-988021A964E6EA7D.txt
required fingerprint: 10460DAD76165AD81FBC0CE9988021A964E6EA7D
```

This is the Debian CD signing key documented by Debian's image-verification
guidance. No key is trusted merely because it arrived over HTTPS: its full
fingerprint must match before `gpgv` verifies either detached manifest
signature.

## Exact bounded procedure

1. Confirm the target host, the existing `/var/lib/libvirt/boot` directory,
   and that the exact target filename does not exist. Stop rather than replace
   an existing file.
2. Create a restrictive temporary directory under `/tmp` and download only the
   five fixed official URLs above.
3. Require the exact filename in both signed manifests. If it is absent, stop
   and report the currently published stable point release; do not substitute
   any image.
4. Obtain the documented public key, check its full fingerprint, make a
   temporary keyring, and verify both `SHA256SUMS.sign` and
   `SHA512SUMS.sign` with `gpgv`.
5. Verify the ISO against both verified manifest entries. Record byte size,
   SHA-256, SHA-512, release `Debian 13.6 (trixie)`, architecture `amd64`,
   acquisition timestamp, official-source classification, and signature result.
6. Copy only the verified ISO to the fixed local target with `root:root` mode
   `0444`, then apply its normal SELinux context. Do not create or change a
   libvirt pool, disk volume, network, domain, or guest.
7. Rehash the installed target and require exact SHA-256/SHA-512 equality with
   the verified temporary file. Remove the temporary directory.
8. Commit only sanitized acquisition evidence and the immutable SHA-512 value;
   do not commit the ISO, a key, or a raw GnuPG home.

## Rendered commands

```bash
set -euo pipefail
image=debian-13.6.0-amd64-netinst.iso
base=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd
target=/var/lib/libvirt/boot/$image
key_url=https://www.debian.org/CD/key-988021A964E6EA7D.txt
key_fingerprint=10460DAD76165AD81FBC0CE9988021A964E6EA7D

hostnamectl --static | grep -Fx ws-matriarch
test -d /var/lib/libvirt/boot
test ! -e "$target"
work=$(mktemp -d /tmp/mail-core-debian-iso.XXXXXX)
trap 'rm -rf "$work"' EXIT
chmod 0700 "$work"
cd "$work"

curl --fail --location --proto '=https' --tlsv1.2 --remote-name "$base/$image"
curl --fail --location --proto '=https' --tlsv1.2 --remote-name "$base/SHA256SUMS"
curl --fail --location --proto '=https' --tlsv1.2 --remote-name "$base/SHA256SUMS.sign"
curl --fail --location --proto '=https' --tlsv1.2 --remote-name "$base/SHA512SUMS"
curl --fail --location --proto '=https' --tlsv1.2 --remote-name "$base/SHA512SUMS.sign"
curl --fail --location --proto '=https' --tlsv1.2 --output debian-cd-signing-key.asc "$key_url"

actual_fingerprint=$(gpg --batch --show-keys --with-colons debian-cd-signing-key.asc | awk -F: '$1 == "fpr" { print $10; exit }')
test "$actual_fingerprint" = "$key_fingerprint"
gpg --batch --yes --dearmor --output debian-cd-signing-key.gpg debian-cd-signing-key.asc
gpgv --keyring "$PWD/debian-cd-signing-key.gpg" SHA256SUMS.sign SHA256SUMS
gpgv --keyring "$PWD/debian-cd-signing-key.gpg" SHA512SUMS.sign SHA512SUMS
grep -F "  $image" SHA256SUMS | sha256sum --check --strict --status -
grep -F "  $image" SHA512SUMS | sha512sum --check --strict --status -

size=$(stat -c %s "$image")
sha256=$(sha256sum "$image" | awk '{print $1}')
sha512=$(sha512sum "$image" | awk '{print $1}')
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sudo -n install -o root -g root -m 0444 "$image" "$target"
sudo -n restorecon -v "$target"
test "$(sha256sum "$target" | awk '{print $1}')" = "$sha256"
test "$(sha512sum "$target" | awk '{print $1}')" = "$sha512"
printf 'filename=%s\nbytes=%s\nsha256=%s\nsha512=%s\nacquired_utc=%s\n' "$image" "$size" "$sha256" "$sha512" "$timestamp"
```

## Stop conditions

Stop without a copy if Debian current no longer lists the exact 13.6 image,
the key fingerprint or either signature fails, either manifest does not contain
the exact filename, either checksum differs, the target already exists, the
local target cannot be rehashed, or any command attempts a non-HTTPS or
non-Debian source.

Do not install the guest, define/start VM 9000, modify networking/DNS/TLS,
or touch the existing mail-core storage volumes. A later construction packet
must require this exact local path and full SHA-512 immediately before domain
definition.
