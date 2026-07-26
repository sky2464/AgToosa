# Spec: DEV-125 — /agtoosa-next Lifecycle Dispatcher

> **Story ID:** DEV-125  
> **Epic:** DEV-002 — Workflow Templates  
> **Status:** 🟦 Todo — Spec ready  
> **Estimate:** M  
> **Clarity:** ready  
> **Spec created:** 2026-07-26  
> **ADR:** `docs/adr/ADR-019-agtoosa-next-dispatcher.md`  
> **Parent:** DEV-109 (`--status-line`) · DEV-007 (`/agtoosa-help next`) · DEV-116 (Lifecycle Compass)

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | One smart slash command that reads Master-Plan state and runs the correct AgToosa lifecycle workflow |
| User outcome | User types `/agtoosa-next` (or says "next") and the agent executes the right phase without manual routing |
| Success condition | All platform adapters install; routing dispatches one phase; idle cycle offers backlog or recommendations; bats NXT-001–NXT-008 green |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-125.md`; bats `NXT-*`; manual dry-run on maintainer repo |
| Non-goals | Auto-chaining phases; replacing Lifecycle Compass; replacing `/agtoosa-status`; generator `spec_approved` JSON field (optional build follow-up) |
| Assumptions | `--route-hint --format json` available (DEV-116); Phase Stop contract remains authoritative |
| Risks | Agents confuse `/agtoosa-next` with `/agtoosa-help next`; build dispatched before spec approval |
| Unresolved questions | None |

### 1.1 User Stories

**As a** developer using AgToosa, **I want** `/agtoosa-next` to run the correct lifecycle workflow for my current project state **so that** I can advance work with one command and repeat "next" after each phase.

**As a** developer between cycles, **I want** `/agtoosa-next` to start the next backlog spec or offer recommendations **so that** I do not stall when Active Cycle is empty.

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN `/agtoosa-next` is invoked THE SYSTEM SHALL run `agtoosa.sh --status-line [path] --route-hint --format json` (or equivalent) before dispatch |
| AC-002 | Must | WHEN dispatch target is build AND active spec lacks `## ✅ Spec Approved` THE SYSTEM SHALL override to `/agtoosa-spec` approval gate — not build |
| AC-003 | Must | WHEN `/agtoosa-next` completes a dispatch THE SYSTEM SHALL execute exactly one lifecycle workflow and honor that workflow's Phase Stop |
| AC-004 | Must | WHEN Active Cycle is idle THE SYSTEM SHALL scan Backlog for highest-priority non-shipped spec candidate and dispatch `/agtoosa-spec` for it |
| AC-005 | Must | WHEN idle and no backlog candidate THE SYSTEM SHALL invite user idea OR present up to 3 backlog recommendations before spec |
| AC-006 | Must | WHEN `/agtoosa-next dry` is invoked THE SYSTEM SHALL print dispatch decision without executing any mutating workflow |
| AC-007 | Must | WHEN platform adapters install THE SYSTEM SHALL expose `/agtoosa-next` on Claude, Cursor, Gemini, Copilot, Windsurf, and Codex per product-truth inventory |
| AC-008 | Must | WHEN `/agtoosa-help next` runs THE SYSTEM SHALL remain read-only and distinct from `/agtoosa-next` (no regression) |
| AC-009 | Should | WHEN dispatch executes THE SYSTEM SHALL print `AgToosa Next → /agtoosa-<command> (<story-id>) — <rationale>` plus SYNC pulse before workflow execution |
| AC-010 | Should | WHEN phase completes THE SYSTEM SHALL remind user to run `/agtoosa-next` again to advance |

### 1.3 Scope Boundary

**In scope:** `template/Docs/AgToosa_Next.md`, `docs/AgToosa_Next.md`, platform adapters, `contracts/product-truth-v1.json`, `lib/config.sh`, Agent.md, Quickref, core rules, bats NXT-*, ADR-019.

**Out of scope:** Changing `--status-line` parse logic (optional follow-up); new generator CLI flags; replacing Compass or help-next.

## 2. Design

### 2.1 Architecture Blueprint

```
User → /agtoosa-next [dry|pick]
         ↓
    --status-line --route-hint --format json
         ↓
    Approval override? → spec (not build)
         ↓
    Active cycle? → dispatch anchor (spec|build|review|ship)
    Idle?         → backlog scan → spec OR cold-start recommendations
    Unclear?      → /agtoosa-status → stop
         ↓
    Execute ONE Docs/AgToosa_<Phase>.md workflow
         ↓
    Phase Stop + dual-line close
```

### 2.2 Threat Model

See `Docs/AgToosa_Next.md` → Threat Model (STRIDE summary). Key control: build guard checks spec approval marker.

## 3. Tasks

### 3.1 Task tree

- [ ] **1.** Canonical workflow + ADR
  - [ ] 1.1 `template/Docs/AgToosa_Next.md` + `docs/` mirror — _Requirements: AC-001–AC-006_
  - [ ] 1.2 ADR-019 — _Requirements: AC-001_
- [ ] **2.** Platform adapters + product-truth
  - [ ] 2.1 `command.next` in product-truth contract — _Requirements: AC-007_
  - [ ] 2.2 Six-target adapters (Claude, Cursor, Gemini, Copilot, Windsurf, Codex) — _Requirements: AC-007_
  - [ ] 2.3 `lib/config.sh` file lists — _Requirements: AC-007_
- [ ] **3.** Docs integration
  - [ ] 3.1 Agent.md + Quickref + core rules — _Requirements: AC-008_
  - [ ] 3.2 Maintainer `.cursor/commands/agtoosa-next.md` — _Requirements: AC-007_
- [ ] **4.** Tests
  - [ ] 4.1 Bats NXT-001–NXT-008 — _Requirements: AC-001–AC-008_
- [ ] **5.** Optional build follow-up
  - [ ] 5.1 Add `spec_approved` to route-hint JSON in `run_status_line` — _Requirements: AC-002 (enhancement)_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-125.md`.

---

## ✅ Spec Approved

Approved 2026-07-26 for `/agtoosa-build`.
