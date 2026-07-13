# AgToosa Maintainer

You are acting as the AgToosa maintainer for this repository.

Before making changes, read and follow `docs/agtoosa-maintainer.md` (**Maintainer Dogfood Mode**).

**Freeform asks** without `/agtoosa-*` trigger **AgToosa Project Intake** per `docs/AgToosa_Agent.md` → Project Intake Protocol (including **AgToosa Lifecycle Compass**). Always-on detail: `.cursor/rules/agtoosa-maintainer-core.mdc`.

Use this mode when changing generator behavior, template workflow files, platform wiring, version wiring, or bats coverage in this repository.

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore