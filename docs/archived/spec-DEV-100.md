# Spec: DEV-100 — Feature: Shared JSON Output for Install/Registry

> **Story ID:** DEV-100
> **Type:** Feature
> **Epic:** DEV-001 — Core Generator & Install
> **Status:** 🟦 Todo — Rev4 Wave 2 (enrolled; R1 amend approved)
> **Estimate:** S
> **Priority:** P2
> **Depends on:** DEV-090 (install/update plan schema); sequential after/with DEV-092 (shared `lib/dryrun.sh` / `agtoosa.sh`)
> **Spec created:** 2026-07-12
> **Spec deepened:** 2026-07-12

## Context

Rev4 calls for machine-readable output on doctor, verify, update dry-run, registry info, and install paths. DEV-090 defines the shared plan schema for non-executing install/update preview and already emits dry-run JSON via `--format json` / `emit_plan_json`. DEV-100 extends that same flag to **catalog plan** and **`--catalog info`** using the DEV-090 plan schema and a stable registry-info envelope.

Human-colored tables remain default; JSON mode is opt-in for automation.

## Spec Revision Log

| Rev | Date | What changed | Why | Approved-by |
|-----|------|--------------|-----|-------------|
| R1 | 2026-07-12 | Align Must ACs and design to reuse DEV-090 `--format json` (not a second `--json` flag); note sequential ownership vs DEV-092 | Wave 2 enrollment deepen — avoid dual JSON flags and file conflict with transactional apply | user |

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Emit shared JSON for install/update plan and registry info commands reusing DEV-090 schema. |
| User outcome | CI and fleet scripts parse install plans and registry metadata without scraping ANSI tables. |
| Success condition | `--format json` on plan/dry-run paths emits DEV-090 plan object; `--catalog info <id> --format json` emits registry info schema; stderr stays human diagnostics only; JIO bats green. |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-100.md`; JIO-001–JIO-007 bats; schema fixture validation. |
| Non-goals | A separate `--json` flag; JSON for every subcommand; breaking existing text output; new registry protocol; doctor/verify JSON (DEV-088 shipped). |
| Assumptions | DEV-090 `schema_version` (`plan-result-v1`) is stable; `jq` or python available in tests for parse validation. |
| Risks | Schema drift between catalog plan and update dry-run; ANSI leak into stdout; merge conflict with DEV-092 on dry-run/CLI wiring. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** CI maintainer, **I want** JSON install plans **so that** pipelines gate on categorized actions programmatically.

**As a** registry consumer, **I want** JSON registry info **so that** I can inspect pack metadata without parsing help text.

**As an** AgToosa engineer, **I want** one plan schema reused **so that** DEV-090 and DEV-100 do not fork.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `bash agtoosa.sh --catalog plan <preset> --format json` runs THE SYSTEM SHALL print a single JSON document conforming to the DEV-090 plan schema on stdout `(modified R1)` | Must |
| AC-002 | WHEN `bash agtoosa.sh --dry-run` or non-executing install plan runs with `--format json` THE SYSTEM SHALL emit the same DEV-090 plan schema shape as catalog plan JSON `(modified R1)` | Must |
| AC-003 | WHEN `bash agtoosa.sh --catalog info <entry> --format json` runs THE SYSTEM SHALL print a JSON object with `id`, `name`, `version`, `platforms`, `sha256`, `compatibility`, and `signature` fields when present in catalog metadata `(modified R1)` | Must |
| AC-004 | WHEN `--format json` is active THE SYSTEM SHALL emit no ANSI color codes on stdout `(modified R1)` | Must |
| AC-005 | WHEN `--format json` is absent THE SYSTEM SHALL retain existing human-readable tables and SHALL NOT change default output format `(modified R1)` | Must |
| AC-006 | WHEN JSON parsing fails in tests THE SYSTEM SHALL include `schema_version` in plan output for forward compatibility | Must |
| AC-007 | WHEN shipping THE SYSTEM SHALL record JIO RED/GREEN evidence | Must |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001, AC-002 | Plan and catalog JSON use different field names for actions. |
| FM-002 | AC-004 | Color codes break `jq` pipelines. |
| FM-003 | AC-005 | Default output switches to JSON. |
| FM-004 | AC-003 | Info JSON omits sha256 when catalog provides it. |
| FM-005 | AC-006 | Missing `schema_version` prevents safe evolution. |
| FM-006 | AC-001–AC-005 | A second `--json` flag forks from DEV-090 `--format json` (R1). |

### 1.5 Out of Scope

- A separate `--json` alias (use `--format json` only)
- `--format json` for full `--update` apply summary (roadmap)
- Changing catalog network fetch behavior
- DEV-090 schema authorship (already shipped)
- PowerShell JSON parity in v1 (bash primary)

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| JSON plan output | generator-enforced when flag set |
| JSON registry info | generator-enforced when flag set |
| Schema stability | versioned via `schema_version` — minor additive fields allowed |
| Default human output | unchanged |

## 2. Design

### 2.1 Architecture Blueprint

Files to change:

- `lib/dryrun.sh` — reuse `emit_plan_json` / DEV-090 schema (coordinate merge with DEV-092)
- `lib/catalog.sh` — `plan` and `info` `--format json` branches
- `agtoosa.sh` — plumb existing `--format json` into catalog plan/info (no new `--json` flag)
- `docs/AgToosa_Catalog.md` — document `--format json` examples
- `tests/agtoosa.bats` — JIO tests
- `tests/fixtures/json/plan-schema.json` — JSON Schema or jq assert template from DEV-090

### 2.2 Data Flow

1. User invokes plan or info with `--format json`.
2. Generator builds in-memory plan/metadata structure (shared with human renderer / DEV-090).
3. `emit_plan_json` (or catalog info encoder) serializes to stdout; logs/diagnostics on stderr.
4. Exit code matches non-JSON command semantics.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| JSON includes unescaped user path secrets | Information Disclosure | Emit basenames in examples; document path fields |
| Schema breaks consumers silently | Tampering | `schema_version`; bats parse contract |
| ANSI injection via crafted catalog name | Spoofing | JSON encoder escapes strings; no raw echo |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)

Files in scope      : `lib/dryrun.sh`, `lib/catalog.sh`, `agtoosa.sh`, Catalog doc, JIO bats/fixtures
Depends on          : DEV-090 plan schema; sequential vs DEV-092 on shared CLI/dry-run files
Out of scope        : separate `--json` flag, doctor/verify JSON, PS1 parity, Master-Plan edits

## 3. Tasks

### 3.1 Task Tree

- [ ] **1.** RED JSON contract tests
  - [ ] 1.1 Plan JSON schema parity catalog vs dry-run (`--format json`) — _Requirements: AC-001, AC-002, AC-006_
  - [ ] 1.2 Info JSON fields and no ANSI — _Requirements: AC-003, AC-004_
  - [ ] 1.3 Default output unchanged without `--format json` — _Requirements: AC-005_
- [ ] **2.** Implementation
  - [ ] 2.1 Reuse `emit_plan_json` + catalog plan/info `--format json` branches — _Requirements: AC-001, AC-002, AC-003_
  - [ ] 2.2 Flag plumbing and Catalog docs — _Requirements: AC-004, AC-005_
- [ ] **3.** Evidence
  - [ ] 3.1 JIO RED/GREEN — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3
**Wave 2 (sequential):** 2.1 → 2.2 → 3.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-100.md`
AC coverage: 7 ACs mapped to 7 planned JIO test IDs
Smoke set: 3 tests tagged `@smoke`

## Spec Quality Analyzer

- Must ACs unambiguous and testable: yes
- Unresolved questions: none

## ✅ Spec Approved

Approved: 2026-07-12 09:56
Enrollment: Rev4 Wave 2 Active Cycle (2026-07-12) — sequential vs DEV-092; R1 `--format json` amend approved

## ✅ Amendment R1 Approved

Approved: 2026-07-12 13:20 — user (“approve all”) — Must ACs use `--format json` only (no second `--json` flag).
