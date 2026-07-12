---
name: agtoosa-task
description: Fast-capture bugs, chores, spikes, and fixes into Docs/Master-Plan.md backlog.
---

# agtoosa-task

Use when the user asks for `/agtoosa-task`, `$agtoosa-task`, or wants to add a small item without a full spec.

## Execute

1. Read `Docs/AgToosa_Task.md` in full and **run** its workflow precisely.
2. Update `Docs/Master-Plan.md` only — do not start implementation unless the user then runs `/agtoosa-build`.
3. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
