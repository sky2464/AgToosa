---
name: agtoosa-review
mode: agent
description: "AgToosa: 4-persona parallel review (Security · Arch · Product · QA) + Simplifier pass"
tools: [codebase, terminal]
---

Read Docs/AgToosa_Review.md and execute the multi-persona review workflow.

Sub-command dispatch:
- No argument → full review: all 4 personas + Simplifier pass
- `security` → Security Officer only: OWASP + STRIDE audit
- `arch` → Engineering Manager only: 500-line limit, OOP, observability
- `debug` → Iron Law root-cause investigation for a failing test or bug
- `cross` → cross-platform second-opinion guidance
- `cross-model` → cross-model review gate (`Docs/AgToosa_CrossModelReview.md`)
