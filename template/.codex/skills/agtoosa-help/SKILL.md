---
name: agtoosa-help
description: Assistance-only AgToosa command reference; optional read-only next-command recommendation.
---

# agtoosa-help

Use when the user asks for `/agtoosa-help`, `$agtoosa-help`, or AgToosa command orientation.

## Execute

1. **Default (no argument):** show the static command reference from `Docs/AgToosa_Agent.md` without reading `Docs/Master-Plan.md` or git state.
2. Include **Authoring resources** (static links only; do not fetch):
   - Platform extensions: https://github.com/sky2464/AgToosa/blob/main/docs/extension-authoring-guide.md
   - Registry packs: https://github.com/sky2464/AgToosa/blob/main/docs/registry-pack-authoring.md
3. **Dispatch `next`:** read-only context review — inspect Master-Plan, active cycle, and git hints; recommend exactly one next AgToosa command as a **suggestion only** (do not auto-run mutating workflows).
4. This skill is assistance-only — not a lifecycle phase gate.
5. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
