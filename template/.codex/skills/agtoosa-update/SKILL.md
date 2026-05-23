---
name: agtoosa-update
description: Refresh AgToosa workflow files and project context to the latest template version.
---

# agtoosa-update

Use when the user asks for `/agtoosa-update`, `$agtoosa-update`, or wants to sync workflow docs from the generator.

## Execute

1. Read `Docs/AgToosa_Update.md` in full and **run** its workflow precisely.
2. Preserve user-owned project content; follow merge/backup rules in the workflow doc.
3. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
