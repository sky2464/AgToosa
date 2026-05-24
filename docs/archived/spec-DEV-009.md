# Spec: DEV-009 — Initial Product Promise Alignment and Readiness Gates

> **Story ID:** DEV-009
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (2026-05-23)
> **Estimate:** M
> **Spec created:** 2026-05-23

## Context

AgToosa's Spec → Build → Review → Ship model is sound, but public README copy, workflow docs, and status behavior still implied Linear PM sync and generator-enforced security scans. This story aligns promises with proof: `Docs/Master-Plan.md` as the only PM source of truth, workflow guidance vs generator enforcement documented, seven initial readiness gates on `/agtoosa-status readiness`, and R1–R8 bats coverage.

**Scope:** Claims + gates — maintainer surfaces only (`README`, `SECURITY`, `template/Docs/*`, platform status variants, `lib/config.sh`, `tests/agtoosa.bats`). No runtime, SDK, or external service dependency.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Align AgToosa's initial product promises with what generated workflows can actually enforce and verify. |
| User outcome | Maintainers and generated projects see honest security/PM claims and can audit initial readiness before build. |
| Success condition | No workflow doc claims Linear as canonical; README/Readiness separate guidance from enforcement; `/agtoosa-status readiness` flags seven gates with Fix-with commands; R1–R8 bats green. |
| Proof / evidence | 197/197 `bats tests/agtoosa.bats`; `agtoosa.sh --list-template-files` includes `Docs/AgToosa_Readiness.md`; drift grep clean for stale Linear PM claims. |
| Non-goals | Hard programmatic gates in `agtoosa.sh`; new CLI flags; external PM integrations. |
| Assumptions | DEV-009 builds on v4.2.0 template baseline (DEV-005–DEV-008 shipped). |
| Risks | Over-broad grep tests false-positive on "replaces Linear" negation text. |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN generated workflow docs are installed THE SYSTEM SHALL treat `Docs/Master-Plan.md` as the PM source of truth and SHALL NOT claim Linear as canonical | Must |
| AC-002 | WHEN README or `AgToosa_Readiness.md` describe security/observability THE SYSTEM SHALL distinguish workflow guidance from generator enforcement | Must |
| AC-003 | WHEN `/agtoosa-status readiness` runs THE SYSTEM SHALL audit seven initial readiness gates with deterministic Fix-with commands | Must |
| AC-004 | WHEN status platform variants are installed THE SYSTEM SHALL document the `readiness` sub-command and updated typo helper | Must |
| AC-005 | WHEN DEV-009 ships THE SYSTEM SHALL add R1–R8 bats tests and register `Docs/AgToosa_Readiness.md` in `lib/config.sh` | Must |

## 2. Design

### 2.1 Files in scope

- `template/Docs/AgToosa_Readiness.md` (new)
- `template/Docs/AgToosa_Status.md`, `AgToosa_Agent.md`, `AgToosa_{Init,Spec,Build,Review,Ship,Debug}.md`, `DEEPENING.md`, `AgToosa_Changelog.md`
- Status platform variants (Claude, Cursor, Gemini, Copilot, Windsurf, Codex skill)
- `README.md`, `SECURITY.md`, `lib/config.sh`, `tests/agtoosa.bats`, `CHANGELOG.md`

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Docs: promise alignment
  - [x] 1.1 Add `AgToosa_Readiness.md` checklist and enforcement matrix — _Requirements: AC-002_
  - [x] 1.2 Update README and SECURITY for honest workflow vs generator wording — _Requirements: AC-002_
  - [x] 1.3 Replace Linear PM language in template workflow docs — _Requirements: AC-001_
- [x] **2.** Status: readiness gates
  - [x] 2.1 Add Part 1.5 and `/agtoosa-status readiness` to `AgToosa_Status.md` — _Requirements: AC-003_
  - [x] 2.2 Update Part 5.5 mapping and typo helper (`plan, readiness, git, orphans`) — _Requirements: AC-003, AC-004_
  - [x] 2.3 Sync five status platform variants + Codex skill — _Requirements: AC-004_
- [x] **3.** Generator inventory and tests
  - [x] 3.1 Register `Docs/AgToosa_Readiness.md` in `lib/config.sh` — _Requirements: AC-005_
  - [x] 3.2 Add R1–R8 bats tests; update D3 typo helper assertions — _Requirements: AC-005_
  - [x] 3.3 Run full bats suite (197/197) — _Requirements: AC-005_

### Wave Plan

**Wave 1 (parallel):** 1.1, 1.3, 2.1
**Wave 2 (sequential):** 1.2, 2.2, 2.3, 3.1, 3.2, 3.3

## Build Scope

| In scope | Out of scope |
|----------|----------------|
| `template/Docs/*`, `template/.{claude,cursor,gemini,github,windsurf,codex}/**` status surfaces | `docs/AgToosa_*.md` repo mirrors (non-generated) |
| `README.md`, `SECURITY.md`, `lib/config.sh`, `tests/agtoosa.bats` | `.github/PROJECT.md`, `.wiki/`, historical root `CHANGELOG` bodies beyond `[Unreleased]` |
| `docs/Master-Plan.md`, `docs/archived/spec-DEV-009.md` | Runtime enforcement in `agtoosa.sh` |

## ✅ Spec Approved

Approved: 2026-05-23 22:00
