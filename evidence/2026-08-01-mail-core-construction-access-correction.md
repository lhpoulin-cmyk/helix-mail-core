# Mail-core construction access correction

Status: **ACCEPTED**
Target: `louis@mail.home.arpa` (`mail-core-9000`)

The operator authorized replacement of the mismatched construction-stage
temporary password while retaining the existing password-based account model.
A local hidden-prompt helper used the Python libvirt API and QEMU guest agent;
the password was not placed in chat, command arguments, environment variables,
logs, evidence, or Git.

The helper atomically replaced only the ignored protected recovery file at:

`handoff/private/mail-core-9000-installer/temporary-password`

The directory remains mode `0700`; the file is mode `0600` and owned by the
local operator. Root SSH login remains disabled, password authentication
remains enabled for construction, and no SSH key was enrolled.

Independent behavioral checks passed:

- password authentication reached `mail.home.arpa` as UID 1000 `louis`;
- the account retained its expected `sudo` group membership;
- the same protected credential successfully authorized `sudo` to UID 0;
- no guest package, disk, network, DNS, TLS, mail, or service mutation occurred.

The reusable `operator-secret-entry` Codex skill was created outside this
repository and validated. Its helper was corrected after verification found
that an atomic file replacement initially inherited root ownership; intended
operator ownership was restored before access testing, and the helper now
preserves the destination owner on future replacements. No secret was exposed.
