---
name: agtoosa-ship
description: Verify ship readiness, deploy, archive specs, update changelog, and suggest the next story.
---

# agtoosa-ship

Use when the user asks for `/agtoosa-ship`, `$agtoosa-ship`, or wants to close out the active story.

## Execute

1. Read `Docs/AgToosa_Ship.md` in full and **run** its workflow precisely.
2. **Dispatch** `check` → `Docs/AgToosa_Ship.md` **Part 0 only** as a **read-only readiness audit** (no deploy, archive, changelog mutation, or deployment approval); otherwise run the full ship flow starting with Part 0.
3. Enforce readiness gates (spec approval, tests, review) before any deploy or archive step in the full flow.
4. On successful completion, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
