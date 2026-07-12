---
name: agtoosa-import
description: Import external agent results and map to tasks/ACs before allowing task closure.
---

# agtoosa-import

Use when the user asks for `/agtoosa-import`, `$agtoosa-import`, or wants to review async/external agent results against ACs before marking tasks complete.

## Execute

1. Read `Docs/AgToosa_Import.md` in full and **run** its workflow precisely.
2. **Dispatch** `check` when provided (report gaps only, do not update Master-Plan or test plan); otherwise run the full import flow.
3. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
