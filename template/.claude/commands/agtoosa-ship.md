Read @Docs/AgToosa_Ship.md and execute the ship workflow.

Arguments provided: $ARGUMENTS

Dispatch rules based on arguments:
- No argument → execute the full ship workflow: pre-flight checks, deploy, archive spec, update changelog, suggest next story.
- `check` → pre-flight checks only: verify all quality gates pass, stories are marked Done or approved in `Docs/Master-Plan.md`, and no 🔴 Critical review findings remain.
- `docs` → docs and changelog phase only: archive the active spec to Docs/archived/, update Docs/AgToosa_Changelog.md, and update Master-Plan.md.
- `retro` → retrospective phase only: generate a brief retro summary and suggest the next story or tech-debt task.

If no arguments were given, run the full flow from Docs/AgToosa_Ship.md.
