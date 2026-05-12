---
trigger: user_prompt
description: "AgToosa: read-only project health dashboard — Master-Plan parsing, git cross-reference, orphan detection"
---

When executing `/agtoosa-status` or any project health check, follow `Docs/AgToosa_Status.md` precisely.

## Key constraints

- This is a **read-only** command — never modify any files, git state, or Master-Plan.md.
- Parse all Master-Plan.md sections and check cross-section consistency.
- Cross-reference git log for unreported progress and WIP commits.
- Detect orphaned spec files and task IDs not tracked in Master-Plan.md.
- Compute and present a health score with actionable findings.
- Sub-commands: `plan`, `git`, `orphans`. For any other token, prepend exactly: `Note: '<token>' is not a defined sub-command. Did you mean: plan, git, orphans? Falling back to full dashboard.` then run the full dashboard.
- Generate "Recommended Next Actions" via the deterministic algorithm in Docs/AgToosa_Status.md Part 5.5 — priority-ordered, command-grouped, deduped, capped at 5, with 🎯 Quick wins call-out.
