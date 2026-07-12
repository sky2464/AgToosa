---
name: agtoosa-update
description: Agentic AgToosa baseline update — Detect, Plan, explicit approval, CLI Apply, Verify. check sub-command is read-only.
---

# agtoosa-update

Use when the user asks for `/agtoosa-update`, `$agtoosa-update`, or wants to update the installed AgToosa baseline.

## Contract

**Detect → Plan → Apply → Verify** (default: ask-then-apply). Sub-commands: `check` (read-only briefing), `plan`, `apply`, `verify`. Mutation source of truth: `bash agtoosa.sh --update <project>` after explicit approval — not hand-edited sync.

## Execute

1. Read `Docs/AgToosa_Update.md` in full and **run** its workflow precisely (including sub-command dispatch).
2. Run preflight and migration guidance before Apply when drift or major-version risk exists.
3. Preserve user-owned project content per the workflow doc (including `Docs/Context/specialists.md` and project specialist native files); run **Specialist Compatibility Check** on `check`/`plan`; optional post-Verify materialization per `Docs/AgToosa_Specialists.md` with separate approval.
4. Verify version marker, lock metadata, platform surfaces, preserved files, and duplicate marker safety after Apply.
5. On successful completion, print verbatim: `Next: /agtoosa-<command> — <rationale>` plus `SYNC:` pulse (see Lifecycle Next-Step Contract)
