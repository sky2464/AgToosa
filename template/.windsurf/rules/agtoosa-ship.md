---
trigger: user_prompt
description: "AgToosa: deploy, archive spec → changelog, suggest next story"
---

When executing a ship or deploy workflow, follow `Docs/AgToosa_Ship.md` precisely.

## Key constraints

- All review BLOCKERs must be resolved before shipping.
- Archive the spec file to `Docs/archived/` after shipping.
- Update `Docs/AgToosa_Changelog.md` with a concise entry.
- Update the story status to `Done` in `Docs/Master-Plan.md` and suggest the next story from `Docs/Master-Plan.md`.
- On successful completion, print this line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
