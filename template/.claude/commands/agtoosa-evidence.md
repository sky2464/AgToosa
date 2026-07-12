Read @Docs/AgToosa_Evidence.md and execute the evidence ledger workflow.

Arguments provided: $ARGUMENTS

Use $ARGUMENTS to resolve the target sub-command (`review` or `ship`) and any story ID. If no argument is provided, run the full evidence ledger update flow. If `review` is provided, run the review-phase update only. If `ship` is provided, run the ship-phase finalize only.

On successful completion, print this line verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
