---
name: agtoosa-status
description: Read-only AgToosa project health dashboard — Master-Plan, git cross-check, and findings.
---

# agtoosa-status

Use when the user asks for `/agtoosa-status`, `$agtoosa-status`, or wants a health report without mutating state.

## Execute

1. Read `Docs/AgToosa_Status.md` in full and **run** its read-only workflow precisely — never modify Master-Plan, specs, or git state.
2. **Dispatch** `plan`, `git`, or `orphans` when provided; otherwise run the full dashboard flow.
3. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
