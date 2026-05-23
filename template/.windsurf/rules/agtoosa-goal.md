---
trigger: user_prompt
description: "AgToosa: clarify project or story goals into a Goal Contract"
---

When executing `/agtoosa-goal` or clarifying project/story intent, follow `Docs/AgToosa_Goal.md` precisely.

Key constraints:
- `/agtoosa-goal` is an optional utility/sub-workflow, not a main lifecycle phase.
- Goal state lives in `Docs/Master-Plan.md` for project goals and the active spec Goal Contract for story goals.
- Ask one question at a time and build follow-up questions from prior answers.
- `/agtoosa-goal check` is read-only and must not update files.
