# Debian 13.6 installation-image acquisition evidence reference

Status: verified acquisition; sanitized factual record.

| Field | Value |
| --- | --- |
| Target host | `ws-matriarch` |
| Artifact | `debian-13.6.0-amd64-netinst.iso` |
| Release / architecture | Debian 13.6 (trixie) / amd64 |
| Acquisition timestamp | `2026-08-01T00:47:27Z` |
| Byte size | `791674880` |
| SHA-256 | `65273beed27b2df543b68b65630ba525cfbad8df2b12035732b2dff87d6664e7` |
| SHA-512 | `ce0eeee7b51fdcdbed1e5116668c1fee27e528767bdf488e5f115a67b225e5dfd0afca1d456aaa9408ceb6b8527521ff7b6b5d62fdbe6f8c5faaf8df56a96292` |
| Official source | `https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/` |
| Manifest-signature result | PASS for both SHA-256 and SHA-512 manifests; signer fingerprint `DF9B9C49EAA9298432589D76DA87E80D6294BE9B`, pinned to Debian's documented CD key before use |
| Local reference | `/var/lib/libvirt/boot/debian-13.6.0-amd64-netinst.iso` |
| Local verification | Post-copy SHA-256 and SHA-512 matched; mode `0444`; SELinux context `virt_content_t` |

No VM was defined, started, or installed. No network, DNS, TLS, storage-volume,
or resolver mutation occurred during this acquisition.
