---
name: agtoosa-debug
description: Systematic root-cause debugging using the AgToosa Iron Law debug workflow.
---

# agtoosa-debug

Use when the user asks for `/agtoosa-debug`, `$agtoosa-debug`, or structured investigation of a failure.

## Execute

1. Read `Docs/AgToosa_Debug.md` in full and **run** its workflow precisely.
2. **Dispatch** `quick`, `deep`, or `feedback-loop` when provided; otherwise follow the default depth in the doc.
3. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
