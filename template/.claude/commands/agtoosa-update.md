Read @Docs/AgToosa_Update.md and execute the `/agtoosa-update` workflow.

**Contract:** Detect → Plan → Apply → Verify (default: ask-then-apply). Sub-commands: `check` (read-only briefing), `plan`, `apply`, `verify`.

Arguments provided: $ARGUMENTS

If $ARGUMENTS is a sub-command (`check`, `plan`, `apply`, `verify`), run only that stage per the canonical doc. Otherwise run the full flow. Optional focus hints (e.g. "show only breaking changes") narrow the summary but do not skip approval or CLI Apply when drift exists.