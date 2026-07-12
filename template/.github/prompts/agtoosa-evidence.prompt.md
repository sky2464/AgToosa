---
name: agtoosa-evidence
mode: agent
description: "AgToosa: create or finalize the per-story evidence ledger at review and ship phases"
tools: [codebase]
---

Read `Docs/AgToosa_Evidence.md` and execute the `/agtoosa-evidence` workflow.

Dispatch based on any sub-command provided: `review` (review-phase update only) or `ship` (ship-phase finalize only). If no argument, run the full evidence ledger flow.

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
