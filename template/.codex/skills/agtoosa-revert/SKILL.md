---
name: agtoosa-revert
description: Git-aware rollback of AgToosa phase or task work with Master-Plan synchronization.
---

# agtoosa-revert

Use when the user asks for `/agtoosa-revert`, `$agtoosa-revert`, or wants to undo AgToosa-driven changes safely.

## Execute

1. Read `Docs/AgToosa_Revert.md` in full and **run** its workflow precisely.
2. Confirm scope with the user before destructive git operations.
3. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
