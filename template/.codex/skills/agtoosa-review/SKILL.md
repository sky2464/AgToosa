---
name: agtoosa-review
description: Run multi-persona code review — security, architecture, product alignment, and QA coverage.
---

# agtoosa-review

Use when the user asks for `/agtoosa-review`, `$agtoosa-review`, or post-build review before ship.

## Execute

1. Read `Docs/AgToosa_Review.md` in full and **run** its workflow precisely.
2. **Dispatch** `security`, `arch`, `debug`, `cross`, or `cross-model` when provided; otherwise run all reviewer personas.
3. Do not ship or merge — review outputs recommendations and findings only unless the user authorizes fixes.
4. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
