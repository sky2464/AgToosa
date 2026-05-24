Read @Docs/AgToosa_Ship.md and execute the ship workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → full ship workflow: Part 0 readiness gate, then deploy approval, WIP squash, deploy, archive spec, update changelog, suggest next story.
- `check` → read-only readiness audit: execute `Docs/AgToosa_Ship.md` **Part 0 only**. Do not deploy, archive specs, mutate changelog, perform file mutation, or ask for deployment approval.
- `docs` → docs and changelog phase only: archive the active spec to Docs/archived/, update Docs/AgToosa_Changelog.md, and update Master-Plan.md.
- `retro` → retrospective phase only: generate a brief retro summary and suggest the next story or tech-debt task.

If no arguments were given, run the full flow from Docs/AgToosa_Ship.md.

On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
