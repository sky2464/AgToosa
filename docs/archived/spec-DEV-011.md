# Spec: DEV-011 — AgToosa Product vs Dogfood Boundary

> **Story ID:** DEV-011
> **Epic:** DEV-002 — Workflow Templates
> **Status:** ✅ Done (build complete — pending review/ship)
> **Estimate:** M
> **Spec created:** 2026-05-23

## Context

AgToosa is both a **shipped workflow solution** (installed into other apps) and a **maintainer dogfood environment** (this repository uses AgToosa to improve AgToosa). Today, template workflow docs and platform entry points do not consistently distinguish those contexts. Generated projects can inherit maintainer-only assumptions about project management, source of truth, and product identity (see audit UX-2, DEV-009 Linear PM cleanup, and `docs/agtoosa-maintainer.md` scope rules).

This story adds explicit terminology and documentation contracts so agents and humans know which mode they are in—without changing generator runtime behavior.

**Related:** ADR-008 (operating contexts), DEV-009 (PM/readiness honesty), DEV-010 (phase gates).

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Clarify AgToosa’s two operating contexts in canonical docs and maintainer guidance so generated projects do not inherit maintainer-only assumptions. |
| User outcome | Maintainers understand dogfood scope; downstream teams see workflow language scoped to *their* product. |
| Success condition | Named modes documented; maintainer guide + `AgToosa_Agent.md` + status/spec surfaces aligned; B1–B5 bats green; template inventory unchanged except touched docs. |
| Proof / evidence | `bats tests/agtoosa.bats -f "B[1-5]:"` green; full suite run recorded (targeted pass + any residual install failures noted separately). |
| Non-goals | New CLI flags; runtime mode switching; separate consumer template pack; rewriting all `docs/AgToosa_*.md` repo mirrors. |
| Assumptions | DEV-009/DEV-010 template baseline on branch; dirty worktree preserved during build. |
| Risks | Over-broad grep flags legitimate "AgToosa framework" references in generated docs. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** explicit Maintainer Dogfood Mode guidance **so that** agents do not treat this repository like a generic generated app.

**As a** team using AgToosa in their repo, **I want** Generated Project Mode language **so that** workflow docs refer to our product, not AgToosa itself.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `docs/agtoosa-maintainer.md` is read THE SYSTEM SHALL define **Generated Project Mode** and **Maintainer Dogfood Mode** with non-overlapping scope rules | Must |
| AC-002 | WHEN generated canonical workflow docs are installed THE SYSTEM SHALL include a **Generated Project Mode** section in `Docs/AgToosa_Agent.md` that refers to the target app as "the project" or "the product" and SHALL NOT imply the installed repo is AgToosa | Must |
| AC-003 | WHEN `AgToosa_Status.md` or `AgToosa_Spec.md` describe PM source of truth THE SYSTEM SHALL scope language to the user's project, not AgToosa maintainer identity | Must |
| AC-004 | WHEN platform spec/status adapters are installed THEY SHALL reference canonical operating-context wording or remain consistent with `template/Docs/` | Must |
| AC-005 | WHEN DEV-011 ships THE SYSTEM SHALL add B1–B5 bats tests and SHALL NOT change `lib/config.sh` inventory except to register newly added doc paths if any | Must |

### 1.4 Out of Scope

- `agtoosa.sh` / `agtoosa.ps1` runtime or new subcommands
- Community registry packs
- Hard enforcement of mode in the generator
- Full mirror of every change into `docs/AgToosa_*.md` (maintainer repo copies)
- Rewriting historical archived specs

## 2. Design

### 2.1 Architecture Blueprint

Documentation-only change (ADR-003 pattern). Layers:

| Layer | Files | Change |
|-------|-------|--------|
| **ADR** | `docs/adr/ADR-008-operating-contexts.md` | Accept terminology decision (Proposed → Accepted at ship) |
| **Maintainer** | `docs/agtoosa-maintainer.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/agents/agtoosa.agent.md` | Add Operating Contexts; reinforce dogfood surfaces |
| **Canonical template** | `template/Docs/AgToosa_Agent.md` | New `## Operating Contexts` — Generated Project Mode default |
| **Workflow docs** | `template/Docs/AgToosa_{Init,Spec,Status}.md` | Scrub maintainer-only product identity; add cross-links |
| **Platform adapters** | `template/.cursor/rules/agtoosa-core.mdc`, status + spec variants under `.cursor/`, `.claude/`, `.gemini/`, `.github/`, `.windsurf/`, `.codex/skills/` | Mirror minimal required strings only |
| **Domain language** | `docs/Context/CONTEXT.md`, `template/Docs/Context/CONTEXT.md` (if exists at init) | Add two terms |
| **Verification** | `tests/agtoosa.bats` | B1–B5 |

**No changes** unless inventory requires: `lib/config.sh`, `agtoosa.sh` behavior.

### 2.2 Data Flow

1. Maintainer or agent opens repo → reads `docs/agtoosa-maintainer.md` → sees **Maintainer Dogfood Mode** and allowed surfaces.
2. User runs `agtoosa.sh` install → `template/Docs/AgToosa_Agent.md` copied → agent reads **Generated Project Mode** → uses "the project/product" in status/spec/build narratives.
3. `/agtoosa-status` and `/agtoosa-spec` adapters point to canonical docs; bats grep canonical + representative adapters.
4. Ship: ADR-008 status → Accepted; B1–B5 + full bats evidence recorded.

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent treats user app as AgToosa and edits wrong charter | Spoofing | AC-002 product language; B2 bats |
| Maintainer applies generated-project init assumptions to generator | Tampering | AC-001 dogfood scope; B1 bats |
| Status dashboard implies AgToosa repo health for all installs | Information Disclosure | AC-003 status/spec wording; B3 bats |
| Platform adapter drifts from canonical mode definitions | Repudiation | AC-004 adapter parity; B4 bats |
| Bats too broad and block valid "AgToosa framework" mentions | Denial of Service (CI) | Assert required phrases + forbidden patterns scoped to identity sections only |

### 2.4 Build Scope

| In scope | Out of scope |
|----------|----------------|
| `docs/agtoosa-maintainer.md`, `docs/adr/ADR-008-operating-contexts.md` | `install.sh` |
| `template/Docs/AgToosa_{Agent,Init,Spec,Status}.md` | Generator copy/merge logic in `lib/*.sh` |
| Spec/status platform adapters (minimal mirror) | `docs/AgToosa_*.md` mirrors unless needed for dogfood |
| `docs/Context/CONTEXT.md` | Version bump / CHANGELOG (ship phase) |
| `tests/agtoosa.bats` B1–B5 | New CLI flags |

### 2.5 Documentation Contract (Public Interface)

| Surface | Generated Project Mode | Maintainer Dogfood Mode |
|---------|------------------------|-------------------------|
| Product reference | "the project", "the product", `[Product]` from Master-Plan charter | "AgToosa", "the generator", "this repository" |
| PM source of truth | `Docs/Master-Plan.md` in **the user's repo** | `docs/Master-Plan.md` for AgToosa development |
| Agent entry | `Docs/AgToosa_Agent.md` | `docs/agtoosa-maintainer.md` + native entry files |
| Status/spec identity | Must not say "AgToosa is the product under development" | May say AgToosa is the product |

**Required canonical strings (bats-locked):**

- `Generated Project Mode`
- `Maintainer Dogfood Mode`

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Terminology and ADR
  - [x] 1.1 Finalize ADR-008 (Accepted at ship) — _Requirements: AC-001_
  - [x] 1.2 Add terms to `docs/Context/CONTEXT.md` — _Requirements: AC-001_
- [x] **2.** Maintainer dogfood guidance
  - [x] 2.1 Add `## Operating Contexts` to `docs/agtoosa-maintainer.md` — _Requirements: AC-001_
  - [x] 2.2 Align native entry files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/agents/agtoosa.agent.md`) with one-line mode pointer — _Requirements: AC-001_
- [x] **3.** Generated project canonical docs
  - [x] 3.1 Add `## Operating Contexts` to `template/Docs/AgToosa_Agent.md` — _Requirements: AC-002_
  - [x] 3.2 Update `AgToosa_Init.md`, `AgToosa_Spec.md`, `AgToosa_Status.md` for project-scoped identity — _Requirements: AC-002, AC-003_
- [x] **4.** Platform parity (minimal)
  - [x] 4.1 Update `agtoosa-core.mdc` and spec/status adapters — _Requirements: AC-004_
  - [x] 4.2 Verify `agtoosa.sh --list-template-files` still includes touched paths — _Requirements: AC-005_
- [x] **5.** Tests
  - [x] 5.1 Add B1–B5 to `tests/agtoosa.bats` — _Requirements: AC-005_
  - [x] 5.2 Run `bats tests/agtoosa.bats -f "B[1-5]:"` then full suite; record evidence — _Requirements: AC-005_

### Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 2.1, 3.1  
**Wave 2 (sequential):** 2.2, 3.2, 4.1, 4.2, 5.1, 5.2

### 3.2 Test Plan

See `docs/AgToosa_TestPlan-DEV-011.md`.

| Test ID | AC | Description |
|---------|-----|-------------|
| B1 | AC-001 | Maintainer guide defines both modes |
| B2 | AC-002 | `AgToosa_Agent.md` has Generated Project Mode without maintainer-only identity |
| B3 | AC-003 | Status/Spec canonical docs use project-scoped PM language |
| B4 | AC-004 | Representative spec/status adapters reference canonical modes |
| B5 | AC-005 | `--list-template-files` includes touched workflow docs |

## ✅ Spec Approved

Approved: 2026-05-23
