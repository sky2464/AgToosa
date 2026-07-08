Read @Docs/AgToosa_Import.md and execute the external agent result import workflow.

Arguments provided: $ARGUMENTS

Use $ARGUMENTS to resolve the target sub-command (`check`) and any artifact pointers. If no argument is provided, run the full import flow (Step 1: Collect returns). If `check` is provided, report gaps only and stop without updating Master-Plan.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
