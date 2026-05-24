# Spec: DEV-017 — Codex AgToosa Slash Discoverability

> **Story ID:** DEV-017
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.11.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-24

## Context

DEV-008 shipped Codex workflow **skills** under `.codex/skills/agtoosa-*/`, but Codex slash-command pickers discover **project prompts** under `.codex/prompts/`. Without prompt adapters, users typing `/agtoosa-status` could be misrouted to generic skill creation instead of the AgToosa status workflow. DEV-012–016 fixed GitHub, Cursor, Windsurf, and Gemini native entry points; Codex prompts were the remaining gap called out in `docs/agtoosa-maintainer.md`.

This story adds 14 `.codex/prompts/agtoosa-*.md` adapters with explicit `/agtoosa-*` routing and no-`/create-skill` guardrails, wires them through `lib/config.sh` / `generate.sh` / `install.sh` / `update.sh`, updates `OPENCODE.md` and skill-synthesis reserved-name language, and locks the contract with CX1–CX5 bats.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make Codex route `/agtoosa-*` workflow names to installed AgToosa prompt files and workflow docs instead of generic skill creation. |
| User outcome | A Codex user sees `/agtoosa-*` in the slash picker and receives the matching AgToosa workflow when invoked. |
| Success condition | Generator installs `.codex/prompts/agtoosa-*.md`, prompts declare workflow routing, synthesis docs reserve prompt paths, and CX1–CX5 bats are green. |
| Proof / evidence | `bats tests/agtoosa.bats -f "CX[1-5]:"` green; platform 7 install contains `.codex/prompts/agtoosa-status.md` with routing guardrails. |
| Non-goals | Replacing or removing Codex workflow skills; changing other platform adapters; Codex application internals. |
| Assumptions | Codex discovers project prompts from `.codex/prompts/*.md` alongside existing `.codex/skills/` workflow runners. |

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa installs Codex prompt files THE SYSTEM SHALL include explicit routing that `/agtoosa-*` executes AgToosa workflow docs and SHALL NOT route to `/create-skill` | Must |
| AC-002 | WHEN a user invokes `/agtoosa-status` in Codex THE SYSTEM SHALL read `Docs/AgToosa_Status.md`, run read-only, and preserve sub-command dispatch | Must |
| AC-003 | WHEN `OPENCODE.md` is installed THE SYSTEM SHALL document both `.codex/prompts/` slash prompts and `.codex/skills/` workflow runners | Must |
| AC-004 | WHEN `/agtoosa-init` or `/agtoosa-spec` proposes generated project skills THE SYSTEM SHALL reject candidates that shadow `.codex/prompts/agtoosa-*.md` | Must |
| AC-005 | WHEN DEV-017 ships THE SYSTEM SHALL add focused bats coverage CX1–CX5 and register prompts in generator file inventory | Must |

### 1.4 Out of Scope

- Gemini, Cursor, GitHub, or Windsurf adapter changes (already shipped)
- New AgToosa workflow commands beyond the existing 14 lifecycle commands

## 2. Design

### 2.4 Build Scope

Template/docs/generator only:

- `template/.codex/prompts/agtoosa-*.md`
- `template/OPENCODE.md`, `template/Docs/AgToosa_Init.md`, `AgToosa_Spec.md`, `AgToosa_Skills.md`
- `lib/config.sh`, `lib/generate.sh`, `lib/install.sh`, `lib/update.sh`, `lib/dryrun.sh`
- `tests/agtoosa.bats` (CX1–CX5)

## ✅ Spec Approved

Approved: 2026-05-24 (build authorized via `/agtoosa-build DEV-017`)

Test plan: `docs/AgToosa_TestPlan-DEV-017.md`
