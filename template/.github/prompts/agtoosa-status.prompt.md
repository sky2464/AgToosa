---
mode: agent
description: "AgToosa: read-only health dashboard — Master-Plan parsing, git cross-ref, orphan detection"
tools: [codebase, terminal, githubRepo]
---

Read Docs/AgToosa_Status.md and execute the status workflow.

Sub-command dispatch:
- No argument → full status dashboard
- `plan` → Master-Plan.md health check only
- `git` → git cross-reference only
- `orphans` → orphan detection only
- Any other token → prepend exactly: `Note: '<token>' is not a defined sub-command. Did you mean: plan, git, orphans? Falling back to full dashboard.` then run the full dashboard.

CRITICAL: This is a READ-ONLY command. Do NOT modify any files.

Generate "Recommended Next Actions" via the deterministic algorithm in Docs/AgToosa_Status.md Part 5.5 — priority-ordered, command-grouped, deduped, capped at 5, with 🎯 Quick wins call-out.
