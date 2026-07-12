---
name: agtoosa-evidence
description: Create or finalize the per-story evidence ledger at review and ship phases.
---

# agtoosa-evidence

Use when the user asks for `/agtoosa-evidence`, `$agtoosa-evidence`, or wants to create or update the per-story evidence ledger (review-phase or ship-phase).

## Execute

1. Read `Docs/AgToosa_Evidence.md` in full and **run** its workflow precisely.
2. **Dispatch** based on argument: `review` (review-phase update only), `ship` (ship-phase finalize only); otherwise run the full evidence ledger flow.
3. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
