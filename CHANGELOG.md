# Changelog

## Unreleased

- Established Phase 0/1 internal-mail-plane repository and fail-closed render.
- Defined the 1.1.1 alpha-to-beta physical endpoint mail demonstration gate;
  version remains `1.1.1-alpha` until all five non-deferred hosts and both
  administrative mailboxes pass.
- Satisfied the 1.1.1 alpha-to-beta mail blocker with fresh send/reply/retrieval
  demonstrations from all seven required participants; set
  `BETA_ELIGIBLE=true` while retaining the `1.1.1-alpha` release label.
- Replaced that blocker with a stricter machine-inbound policy requiring
  administrator-only delivery to every `hv-*` and `ws-*` mailbox; reset
  `BETA_ELIGIBLE=false` pending deployment and demonstration.
- Deployed and verified the restricted machine-inbound RCPT policy, completed
  fresh physical-endpoint and administrative send/reply/retrieval tests, proved
  the required unauthorized-local and external-relay rejections, and restored
  `BETA_ELIGIBLE=true` while retaining `VERSION=1.1.1-alpha`.
