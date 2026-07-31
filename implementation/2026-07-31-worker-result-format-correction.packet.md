# Worker result commit-line format correction

Status: repository-only and fake-only

Do not collect host evidence or mutate live systems. Update the generated
worker prompt and tests so every worker result contains exactly plain,
unbackticked full 40-hex lines `Starting commit: <hash>` and `Ending commit:
<hash>`, matching the hardened waiter grammar. Add fake-only coverage that the
prompt requires this format and result writers satisfy it. Preserve parser
strictness; do not weaken it to accept Markdown formatting. Run validation,
commit one bounded change, write a conforming factual result, and stop.
