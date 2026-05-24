---
name: agtoosa-status
mode: agent
description: "AgToosa: read-only health dashboard — Master-Plan parsing, git cross-ref, orphan detection"
tools: [codebase, terminal, githubRepo]
---

Read Docs/AgToosa_Status.md and execute the status workflow. **Generated Project Mode** — see Docs/AgToosa_Agent.md → **Operating Contexts**.

Sub-command dispatch:
- No argument → full status dashboard
- `plan` → Master-Plan.md health check only
- `readiness` → initial product readiness gates only (`Docs/AgToosa_Readiness.md`)
- `git` → git cross-reference only
- `orphans` → orphan detection only
- Any other token → prepend exactly: `Note: '<token>' is not a defined sub-command. Did you mean: plan, readiness, git, orphans? Falling back to full dashboard.` then run the full dashboard.

CRITICAL: This is a READ-ONLY command. Do NOT modify any files.

Generate "Recommended Next Actions" via the deterministic algorithm in Docs/AgToosa_Status.md Part 5.5 — priority-ordered, command-grouped, deduped, capped at 5, with 🎯 Quick wins call-out.
