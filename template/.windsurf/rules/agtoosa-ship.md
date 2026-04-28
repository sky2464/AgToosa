---
trigger: user_prompt
description: "AgToosa: deploy, archive spec → changelog, suggest next story"
---

When executing a ship or deploy workflow, follow `Docs/AgToosa_Ship.md` precisely.

## Key constraints

- All review BLOCKERs must be resolved before shipping.
- Archive the spec file to `Docs/archived/` after shipping.
- Update `Docs/AgToosa_Changelog.md` with a concise entry.
- Close the Linear issue and suggest the next story from `Docs/Master-Plan.md`.
