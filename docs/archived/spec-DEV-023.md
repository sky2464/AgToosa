# Spec: DEV-023 — Workflow Template Native Slash Parity Audit

> **Story ID:** DEV-023
> **Epic:** DEV-002 — Workflow Templates
> **Status:** ✅ Spec approved (pending build)
> **Estimate:** M
> **Spec created:** 2026-05-24

## Context

DEV-014 through DEV-017 added native `/agtoosa-*` discoverability per platform (Cursor, Windsurf, Gemini, GitHub, Codex). There is no **cross-platform matrix test** proving all 14 workflow commands exist on every supported native surface and that adapters delegate correctly (including `/agtoosa-ship check`).

Separately, **DEV-019** (Master Architecture document) is already specced under DEV-002 — it is documentation inventory work, not slash parity. This story is the **routing parity audit** the ship retro meant by “workflow template parity.”

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Guarantee every AgToosa workflow command is discoverable on every supported AI platform with consistent routing guardrails. |
| User outcome | Developers on any platform can type `/agtoosa-spec` (etc.) and get the workflow doc, never `/create-skill` drift. |
| Success condition | Inventory in `lib/config.sh` matches on-disk adapters; bats **WP1–WP5** (or expanded set) pass; any gaps fixed in `template/`. |
| Proof / evidence | `bats tests/agtoosa.bats -f "WP[1-5]:"` green; parity report in spec or review artifact. |
| Non-goals | New workflow commands; changing workflow prose; Master Architecture doc (DEV-019); runtime generator behavior beyond template files. |
| Assumptions | 14 commands remain canonical set from existing platform stories. |
| Risks | Large touch surface if many files drift — contain fixes to missing adapters only. |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN the generator inventory lists a native adapter path THE SYSTEM SHALL have that file present under `template/` for each supported platform (Claude commands, Cursor commands, Gemini TOML, GitHub prompts, Windsurf workflows, Codex prompts) | Must |
| AC-002 | WHEN a user opens any native `agtoosa-*` adapter THE SYSTEM SHALL route to the matching `Docs/AgToosa_*.md` workflow and SHALL NOT instruct `/create-skill` for AgToosa workflows | Must |
| AC-003 | WHEN `/agtoosa-ship` supports `check` THE SYSTEM SHALL have native adapters that document read-only Part 0 (per DEV-013 pattern) on platforms that ship ship adapters | Must |
| AC-004 | WHEN DEV-023 ships THE SYSTEM SHALL add bats **WP1–WP5**: inventory parity, per-platform file counts, ship-check delegation grep, collision guardrail grep, Codex/OPENCODE reservation | Must |
| AC-005 | WHEN gaps are found THE SYSTEM SHALL fix template adapters in-scope (minimal diff per platform) | Should |

### 1.3 Out of Scope

- DEV-019 Master-Architecture.md (separate story)
- OpenClaw/Hermes/Factory native formats unless already in `lib/config.sh`
- Rewriting workflow content

## 2. Design

### 2.1 Architecture Blueprint

| Platform | Native path pattern | Count check |
|----------|---------------------|-------------|
| Claude | `.claude/commands/agtoosa-*.md` | 14 |
| Cursor | `.cursor/commands/agtoosa-*.md` | 14 |
| Gemini | `.gemini/commands/agtoosa-*.toml` | 14 |
| GitHub | `.github/prompts/agtoosa-*.prompt.md` | 14 |
| Windsurf | `.windsurf/workflows/agtoosa-*.md` | 14 |
| Codex | `.codex/prompts/agtoosa-*.md` | 14 |

Reference implementation: DEV-014 `CU1–CU5` pattern extended to matrix.

Files: `lib/config.sh` (verify only), `template/**/agtoosa-*`, `tests/agtoosa.bats`, `template/Docs/AgToosa_Init.md` / `AgToosa_Spec.md` collision sections.

### 2.2 Build Scope

In scope: `template/`, `lib/config.sh` (inventory alignment), `tests/agtoosa.bats`

Out of scope: `agtoosa.sh` runtime, `docs/archived/spec-DEV-019.md` implementation

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** Audit matrix
  - [ ] 1.1 Script or bats helper: expected 14 commands × 6 surfaces — _AC-001_
  - [ ] 1.2 Document gaps in spec or review note — _AC-005_
- [ ] **2.** Fix drift (if any)
  - [ ] 2.1 Add missing adapters / ship-check wording — _AC-002, AC-003, AC-005_
- [ ] **3.** Bats WP1–WP5 + test plan
  - [ ] 3.1 Implement WP suite — _AC-004_
  - [ ] 3.2 `docs/AgToosa_TestPlan-DEV-023.md` — _AC-004_

### 3.2 Wave Plan

**Wave 1:** 1.1, 3.1 (may fail until Wave 2)

**Wave 2:** 2.1

**Wave 3:** 1.2, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-023.md`

## ✅ Spec Approved

Approved: 2026-05-24
