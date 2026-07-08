# Spec: DEV-047 — Async Agent Handoff Packs

> **Story ID:** DEV-047
> **Epic:** DEV-002
> **Status:** 🏁 Shipped (v5.3.3)
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-08
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa ships wave-by-wave build (DEV-067), Terminal Evidence Contract, and phase events, but has no canonical way to export a bounded brief for Codex, Copilot cloud agent, Jules, Devin, Cursor, or Claude Code. DEV-047 adds that export surface as **agent-instructed** docs + adapters; launching external agents remains **manual**. Pair with DEV-048 for import/closure.

### Brownfield Spec Drift Baseline

| Field | Value |
|-------|-------|
| User outcome / proof | Users can export a handoff pack; bats prove dual-path docs + adapters + config registration |
| Repo evidence inventory | `docs/AgToosa_Build.md` Wave execution; `docs/AgToosa_Agent.md` Terminal Evidence; `docs/agtoosa-events.jsonl`; stub `docs/archived/spec-DEV-047.md` |
| Current-state baseline | No `AgToosa_Handoff.md`; Team Trust Roadmap lists DEV-047–048 as backlog |
| Intended change deltas | New Handoff workflow; Build/Agent/Quickref wiring; platform adapters; `lib/config.sh` registration; HO bats |
| Drift evidence | Stub meta-ACs → functional EARS ACs; roadmap text → shipped agent-instructed |
| Claim Boundary | agent-instructed (export); manual (launch); roadmap (capability matrix DEV-055, owned-files DAG DEV-045 remainder) |
| Source of truth | `docs/Master-Plan.md` remains the repo-local source of truth |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Export AgToosa-ready task briefs for Codex, Copilot cloud agent, Jules, Devin, Cursor, and Claude Code. |
| User outcome | Users can hand off a bounded AgToosa work package to a background agent with enough context and constraints. |
| Success condition | Handoff pack template includes story, ACs, files, allowed actions, verification commands, and return contract; `/agtoosa-handoff` is discoverable on major platforms. |
| Proof / evidence | `docs/AgToosa_Handoff.md` + template mirror; Build/Agent/Quickref wiring; platform adapters; HO bats; test-plan evidence. |
| Claim Boundary | Export workflow is **agent-instructed**; launching external agents is **manual**; import is DEV-048; no generator-enforced pack writer. Controls classified as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. |
| Non-goals | Does not claim external agents completed work unless imported evidence is present; no hosted agent orchestration; no DEV-049 ledger; no DEV-055 capability matrix. |
| Assumptions | AgToosa remains repo-native and markdown-first; Wave Plan + Terminal Evidence already exist. |
| Risks | Overpromising runtime handoff; adapter drift; packs that omit return contract fields. |
| Unresolved questions | None |

### 1.2 User Stories

**As a** maintainer, **I want** to export a handoff pack for a wave or task **so that** an async agent can work within AgToosa constraints.

**As a** user of Cursor/Claude/Codex, **I want** a native `/agtoosa-handoff` entry **so that** I can discover the workflow without reading the full Agent doc.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-handoff` runs THE SYSTEM SHALL write a pack under `docs/archived/handoff-*` (or `Docs/archived/` in generated projects) containing story, ACs, files in scope, allowed actions, verification commands, and return contract sections. | Must |
| AC-002 | WHEN the handoff capability mentions enforcement THE SYSTEM SHALL classify export as agent-instructed, launch as manual, and avoid generator-enforced or CI-enforced claims for pack writing. | Must |
| AC-003 | WHEN external agents are mentioned THE SYSTEM SHALL preserve `docs/Master-Plan.md` / `Docs/Master-Plan.md` as the repo-local source of truth and forbid checkbox ticks from the handoff workflow alone. | Must |
| AC-004 | WHEN the template pack ships THE SYSTEM SHALL register `Docs/AgToosa_Handoff.md` in `lib/config.sh` `DOCS_FILES` and provide thin native adapters on Cursor, Claude, Gemini, Copilot, Windsurf, and Codex that route to the canonical doc. | Must |
| AC-005 | WHEN Build documents wave or parallel dispatch THE SYSTEM SHALL reference `/agtoosa-handoff` for exporting wave-scoped packs to async agents. | Must |
| AC-006 | WHEN shipping THE SYSTEM SHALL record HO bats evidence in the test plan without claiming hosted agent completion. | Should |

### 1.4 Out of Scope

- Launching or polling Codex/Jules/Devin/Copilot cloud agents
- Machine-checked verifier FAIL on missing handoff packs
- Evidence ledger (DEV-049) and signed provenance (DEV-054)
- Owned-files/inputs/outputs DAG schema remainder (DEV-045)

### Failure modes (Must ACs)

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | Pack missing return contract → import cannot map evidence |
| FM-002 | AC-002 | Docs claim generator-enforced handoff → dishonest positioning |
| FM-003 | AC-003 | Handoff ticks Master-Plan checkboxes → SoT corruption |
| FM-004 | AC-004 | Doc not in DOCS_FILES → installs miss the workflow |
| FM-005 | AC-005 | Build never mentions handoff → wave export undiscoverable |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:
- `template/Docs/AgToosa_Handoff.md` — canonical workflow
- `docs/AgToosa_Handoff.md` — maintainer mirror
- Platform adapters: `.claude/commands`, `.cursor/commands`+rules, `.gemini/commands`, `.github/prompts`, `.windsurf/workflows`+rules, `.codex/prompts`+skills

Files to change:
- `template/Docs/AgToosa_Build.md`, `docs/AgToosa_Build.md` — sub-command + wave/parallel notes
- `template/Docs/AgToosa_Agent.md`, `docs/AgToosa_Agent.md` — Commands table
- `template/Docs/AgToosa_Quickref.md`, `docs/AgToosa_Quickref.md` — utilities + optional handoff phase
- `docs/AgToosa_Readiness.md`, `template/Docs/AgToosa_Readiness.md` — enforcement row
- `docs/AgToosa_Team_Trust_Roadmap.md` (+ template if present) — matrix + backlog text
- `lib/config.sh` — DOCS_FILES + OPTIONAL adapter paths
- `tests/agtoosa.bats` — HO-001–HO-005
- Entry points: `CLAUDE.md`, `AGENTS.md`, `OPENCODE.md`, `.cursorrules`, `.github/copilot-instructions.md` (one-line command rows where command tables exist)

### 2.2 Data Flow

```
Active spec + Active Tasks + test plan
        │
        ▼
 /agtoosa-handoff ──► Docs/archived/handoff-*.md
        │
        ▼
 Manual launch (external agent)
        │
        ▼
 /agtoosa-import (DEV-048)
```

### 2.3 STRIDE Threat Model

| Threat | Risk | Mitigation |
|--------|------|------------|
| Spoofing | Fake “agent done” without import | Handoff forbids checkbox ticks; import gate required |
| Tampering | Pack instructs edits outside Build Scope | Allowed Actions + Files in Scope sections mandatory |
| Repudiation | No record of export | Update Log + `phase":"handoff"` event |
| Information Disclosure | Secrets in pack | Pack cites paths/process only; no secret values |
| Denial of Service | N/A (docs workflow) | — |
| Elevation of Privilege | Pack asks to modify CI/settings | Out of scope; denylist patterns unchanged |

### 2.4 Build Scope

**In scope:** files listed in §2.1.
**Out of scope:** `agtoosa.sh` install logic beyond config lists; verifier FAIL gates; npm/version bumps (unless ship requires PATCH).

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** RED contract bats (HO-001–HO-005) — _Requirements: AC-001–AC-005_
- [x] **2.** Canonical Handoff doc + maintainer mirror — _Requirements: AC-001, AC-002, AC-003_
- [x] **3.** Wire Build, Agent, Quickref, Readiness, Roadmap — _Requirements: AC-002, AC-005_
- [x] **4.** Register config + platform adapters + entry points — _Requirements: AC-004_
- [x] **5.** GREEN bats + test-plan evidence — _Requirements: AC-006_

### Wave Plan

**Wave 1 (parallel):** 1, 2
**Wave 2 (sequential after Wave 1):** 3, 4
**Wave 3 (sequential after Wave 2):** 5

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- No contradiction with Non-goals / Claim Boundary: yes
- Every Must AC maps to test-plan row: yes (HO-001–HO-005)
- Enforcement classified: yes
- SoT preserved: yes
- No TBD/TODO placeholders: yes

## ✅ Spec Approved

Approved: 2026-07-08 17:45
