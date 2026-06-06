# Spec: DEV-032 — Patch-first release versioning (5.x line)

> **Story ID:** DEV-032
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** 🏁 Shipped (v5.2.2 — 2026-05-25)
> **Estimate:** S
> **Spec created:** 2026-05-25

## Context

AgToosa uses semver (`X.Y.Z`) per [ADR-004](adr/ADR-004-versioning-backward-compatibility.md). Maintainer practice has been **one story → one MINOR** (e.g. 5.1.0 → 5.2.0 for S-sized chores), which makes the public version line advance faster than users expect. The generator and CI already support PATCH releases; the gap is **documented policy** and **agent ship/review defaults**.

**Root cause:** Missing bump decision tree in ship, review, and maintainer release checklist. `docs/Master-Plan.md` Milestone skipped ahead to `v5.3.0 (next)` while `AGTOOSA_VERSION` is `5.2.0`.

**Fix direction:** Codify **patch-first** on the current 5.x MINOR train (5.2.0 → 5.2.1 → 5.2.2). MINOR bumps only for documented exceptions. No renumbering to 1.1.x; no `version_lt` / marker regex changes.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make default releases advance the **PATCH** segment on the current 5.x MINOR line unless a documented exception applies. |
| User outcome | Maintainers see predictable small steps (5.2.0 → 5.2.1) instead of jumping 5.1 → 5.2 → 5.3 per small story. |
| Success condition | Bump decision tree in maintainer + template ship/review docs; Milestone tracks next **patch**; bats VP1–VP5 green on canonical policy text. |
| Proof / evidence | `bats tests/agtoosa.bats -f "DEV-032"` green; next routine ship uses PATCH+1 on active MINOR. |
| Non-goals | Renumbering to 1.1.x; zero-padded display versions; gstack `/ship` VERSION slots; auto-bump CI; retroactive re-tag of past releases |
| Assumptions | Multiple stories may share one PATCH release when batched in one ship. Template-only, registry, and doc-only maintainer stories default to PATCH. Current `5.2.0` stays until the next ship under this policy. |
| Risks | Agents ignore docs and still suggest MINOR — mitigated by review/ship mandatory wording and bats greps. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** a written default to bump PATCH for routine stories **so that** release numbers grow slowly and predictably on the 5.2.x line.

**As an** agent running `/agtoosa-review` or `/agtoosa-ship`, **I want** explicit version bump rules **so that** I do not default to MINOR for every S-sized chore.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a maintainer ships a Fix, Chore, or docs-only story with estimate S THE SYSTEM SHALL default the next version to PATCH+1 on the current MINOR (e.g. 5.2.0 → 5.2.1) | Must |
| AC-002 | WHEN `docs/agtoosa-maintainer.md` Release Checklist is read THE SYSTEM SHALL include a bump decision tree with PATCH default and MINOR/MAJOR exceptions | Must |
| AC-003 | WHEN `template/Docs/AgToosa_Ship.md` full ship flow runs THE SYSTEM SHALL reference the bump decision tree before mutating `AGTOOSA_VERSION` or CHANGELOG version headings | Must |
| AC-004 | WHEN `template/Docs/AgToosa_Review.md` produces a review report THE SYSTEM SHALL instruct reviewers to suggest PATCH+1 unless a documented MINOR or MAJOR exception applies | Must |
| AC-005 | WHEN `docs/Master-Plan.md` Project Charter Milestone is updated for routine work THE SYSTEM SHALL track the next PATCH on the active MINOR (e.g. `v5.2.1 (next)` while shipped is 5.2.0) | Must |
| AC-006 | WHEN `docs/adr/ADR-005-release-cadence.md` exists THE SYSTEM SHALL define patch-first cadence and cross-reference ADR-004 semver semantics | Must |
| AC-007 | WHEN `tests/agtoosa.bats` runs DEV-032 coverage THE SYSTEM SHALL assert patch-first policy strings in canonical maintainer and ship docs | Must |
| AC-008 | WHEN a single S Feature ships without breaking changes and without opening a new MINOR train THE SYSTEM SHALL use PATCH not MINOR | Should |
| AC-009 | WHEN multiple stories ship in one release THE SYSTEM SHALL allow one shared PATCH bump | Could |

### 1.4 Out of Scope

- Changing `lib/version.sh` comparison or marker regex
- GitHub release workflow structural changes
- Generated-project `Docs/Master-Plan.md` Milestone automation

## 2. Design

### 2.1 Architecture Blueprint

| File / area | Change |
|-------------|--------|
| `docs/adr/ADR-005-release-cadence.md` | New ADR: patch-first maintainer cadence, exceptions, Milestone rule |
| `docs/adr/ADR-004-versioning-backward-compatibility.md` | Cross-link to ADR-005 for release cadence |
| `docs/agtoosa-maintainer.md` | Release Checklist: bump tree + parity pins |
| `template/Docs/AgToosa_Ship.md` | New **Version bump (maintainer)** subsection before/after Part 3 |
| `docs/AgToosa_Ship.md` | Maintainer mirror (`docs/` paths) |
| `template/Docs/AgToosa_Review.md` | Review report / ship handoff: PATCH-first suggestion line |
| `docs/AgToosa_Review.md` | Maintainer mirror |
| `template/Docs/AgToosa_Readiness.md` | Gate 7: align Milestone with next PATCH on active MINOR |
| `docs/AgToosa_Readiness.md` | Mirror if gate 7 exists |
| `docs/Master-Plan.md` | DEV-032 backlog → done after build; Milestone `v5.2.1 (next)` |
| `tests/agtoosa.bats` | DEV-032 VP1–VP5 |
| `docs/AgToosa_TestPlan-DEV-032.md` | AC → test mapping |

### 2.2 Bump decision tree

| Story profile | Bump | Example (from 5.2.0) |
|---------------|------|----------------------|
| Fix, Chore, docs-only, estimate **S** | **PATCH** | 5.2.1 |
| Feature **S**, same MINOR train, non-breaking | **PATCH** | 5.2.1 |
| New MINOR train, multi-story release, cycle close | **MINOR** (Z=0) | 5.3.0 |
| Breaking per ADR-004 | **MAJOR** | 6.0.0 |

**Milestone rule:** Project Charter **Milestone** = next PATCH on active MINOR, not skip-ahead MINOR unless a planned MINOR release is enrolled.

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Wrong version in release tag | Tampering | Unchanged CI tag == `AGTOOSA_VERSION`; checklist requires all parity pins |
| Undocumented version skip | Repudiation | CHANGELOG `## [X.Y.Z]` + git tag remain source of truth |
| Agent suggests incorrect MINOR | Denial of service (process) | Mandatory PATCH-first wording in review/ship; bats grep |

### 2.4 Build Scope

**Files in scope:** table in §2.1  
**Directories:** `docs/`, `docs/adr/`, `template/Docs/`, `tests/`  
**Out of scope:** `agtoosa.sh`, `lib/version.sh`, `.github/workflows/` (unless tag policy gap found)

## 3. Tasks

### Task tree

- [x] **1.** Policy ADR and maintainer checklist
  - [x] 1.1 Add `docs/adr/ADR-005-release-cadence.md` — _AC-006_
  - [x] 1.2 Cross-link ADR-004 → ADR-005 — _AC-006_
  - [x] 1.3 Extend `docs/agtoosa-maintainer.md` Release Checklist — _AC-002_
- [x] **2.** Template + maintainer workflow mirrors
  - [x] 2.1 `template/Docs/AgToosa_Ship.md` version bump section — _AC-003_
  - [x] 2.2 `docs/AgToosa_Ship.md` mirror — _AC-003_
  - [x] 2.3 `template/Docs/AgToosa_Review.md` PATCH-first ship suggestion — _AC-004_
  - [x] 2.4 `docs/AgToosa_Review.md` mirror — _AC-004_
  - [x] 2.5 Readiness gate 7 wording (template + docs) — _AC-005_
- [x] **3.** Master-Plan and regression tests
  - [x] 3.1 Milestone `v5.2.1 (next)` + DEV-032 row — _AC-005_
  - [x] 3.2 DEV-032 bats VP1–VP5 — _AC-007_

### Wave Plan

**Wave 1 (parallel):** 1.1, 1.3, 2.1, 2.3  
**Wave 2 (sequential):** 1.2, 2.2, 2.4, 2.5, 3.1, 3.2

## ✅ Spec Approved

Approved: 2026-05-25 (user approved plan implementation; patch-first 5.x policy)
