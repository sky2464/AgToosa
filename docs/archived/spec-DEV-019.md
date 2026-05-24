# Spec: DEV-019 — Master Architecture Document

> **Story ID:** DEV-019
> **Epic:** DEV-002 — Workflow Templates
> **Status:** ✅ Done
> **Estimate:** M
> **Spec created:** 2026-05-24

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make `Docs/Master-Architecture.md` a first-class AgToosa context artifact created during setup and preserved during updates. |
| User outcome | Developers and agents start each project with a senior-architect view of the app or solution architecture, including diagrams and detailed system boundaries. |
| Success condition | Fresh installs include `Docs/Master-Architecture.md`; `/agtoosa-init`, `/agtoosa-update`, and core agent instructions tell agents to read and maintain it as a high-priority context file. |
| Proof / evidence | Bats coverage verifies template inventory, fresh install copy, update preservation, and instruction references. |
| Non-goals | Auto-generating a perfect architecture from source code without human review; introducing new diagram tooling dependencies; changing runtime behavior outside template/documentation copy/update wiring. |
| Assumptions | Markdown plus Mermaid diagrams is sufficient for portable architecture docs across supported AI platforms. C4-style context/container/component views are the right default visual language for most generated projects. |
| Risks | Agents may let the architecture doc drift; overly large diagrams may become stale; update behavior could overwrite user-authored architecture if preservation rules are wrong. |
| Unresolved questions | None. |

## Research Notes

- C4 model guidance favors hierarchical system context, container, component, and code diagrams. Source: https://c4model.com/diagrams
- arc42 positions architecture documentation as structured communication and documentation. Source: https://arc42.org/overview
- No new dependency versions are required; Mermaid fenced diagrams remain plain Markdown.

## 1. Requirements

### 1.1 User Stories

**As a** developer starting a project with AgToosa, **I want** a `Docs/Master-Architecture.md` file created during setup **so that** the architecture view is explicit from the beginning.

**As an** AI coding agent, **I want** core instructions to treat the master architecture document as required context **so that** design, spec, build, and review decisions stay aligned with the intended system architecture.

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN AgToosa stages or installs workflow docs THE SYSTEM SHALL include `Docs/Master-Architecture.md` in the core docs inventory. | Must |
| AC-002 | WHEN `/agtoosa-init` establishes project context THE SYSTEM SHALL instruct the agent to create or update `Docs/Master-Architecture.md` after the smart interview and codebase scan. | Must |
| AC-003 | WHEN `/agtoosa-update` refreshes project context THE SYSTEM SHALL read `Docs/Master-Architecture.md` as high-priority architecture memory and preserve user-authored contents. | Must |
| AC-004 | WHEN an agent starts AgToosa work THE SYSTEM SHALL list `Docs/Master-Architecture.md` in core references and tell the agent to consult it before architectural decisions. | Must |
| AC-005 | WHEN the template document is opened THE SYSTEM SHALL provide senior-architect sections for goals, constraints, C4-style diagrams, containers/components, data flow, deployment, security, observability, and decision links. | Must |
| AC-006 | WHEN `/agtoosa-spec` or `/agtoosa-review arch` runs THE SYSTEM SHOULD reference `Docs/Master-Architecture.md` as architecture input for specs and architecture review. | Should |
| AC-007 | WHEN DEV-019 ships THE SYSTEM SHALL include bats coverage for inventory listing, fresh install copy, update preservation, and instruction references. | Must |

### 1.3 Out of Scope

- Adding a new CLI command dedicated to architecture generation.
- Fetching or installing external diagram tools.
- Replacing `Docs/Context/` files, `Docs/Master-Plan.md`, ADRs, or story specs.

## 2. Design

### 2.1 Architecture Blueprint

Files created or changed:

- `template/Docs/Master-Architecture.md`
- `docs/Master-Architecture.md`
- `lib/config.sh`, `lib/install.sh`, `lib/update.sh`, `agtoosa.sh`, `agtoosa.ps1`
- `template/Docs/AgToosa_Agent.md`, `AgToosa_Init.md`, `AgToosa_Update.md`, `AgToosa_Spec.md`, `AgToosa_Review.md`
- `template/AGENTS.md`, `template/OPENCODE.md`
- `tests/agtoosa.bats`
- `docs/Context/CONTEXT.md`
- `docs/adr/ADR-009-master-architecture-context.md`

### 2.2 Data Flow

1. The generator inventory lists `Docs/Master-Architecture.md`.
2. Fresh installs copy the template into the project.
3. Update mode reads and preserves an existing user-authored architecture file.
4. Agent instructions load it as high-priority architecture context before architecture-affecting work.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| Architecture text steers future agents into unsafe changes | Tampering | Treat architecture docs as context, not executable instruction. |
| Architecture document captures secrets | Information Disclosure | Template warns not to store secrets, keys, or credentials. |
| Update overwrites project-specific architecture decisions | Tampering | Update path skips existing `Docs/Master-Architecture.md`; MA5 verifies preservation. |
| Agents ignore the file and make inconsistent architecture changes | Repudiation | Core instructions and review guidance require checking the file. |

### 2.4 Build Scope

✅ Ready to proceed — Scope Boundary

Files in scope      : `template/Docs/Master-Architecture.md`, `docs/Master-Architecture.md`, `lib/config.sh`, `lib/install.sh`, `lib/update.sh`, `agtoosa.sh`, `agtoosa.ps1`, `template/Docs/AgToosa_Agent.md`, `template/Docs/AgToosa_Init.md`, `template/Docs/AgToosa_Update.md`, `template/Docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Review.md`, `template/AGENTS.md`, `template/OPENCODE.md`, `tests/agtoosa.bats`, `docs/Context/CONTEXT.md`, `docs/adr/ADR-009-master-architecture-context.md`, `docs/Master-Plan.md`

Directories in scope: `template/Docs/`, `docs/`, `docs/Context/`, `docs/adr/`, `tests/`

Out of scope        : External diagram tooling; historical archived specs; release version bumps.

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Master architecture template: add the first-class architecture document.
  - [x] 1.1 Create `template/Docs/Master-Architecture.md` with senior-architect sections and Mermaid C4-style diagrams — _Requirements: AC-005_
  - [x] 1.2 Create maintainer mirror `docs/Master-Architecture.md` for this repository — _Requirements: AC-005_
- [x] **2.** Generator inventory and lifecycle guidance: wire the document into setup/update/spec/review context.
  - [x] 2.1 Add `Docs/Master-Architecture.md` to `DOCS_FILES` — _Requirements: AC-001_
  - [x] 2.2 Update `/agtoosa-init` guidance to create/update the document after smart interview and codebase scan — _Requirements: AC-002_
  - [x] 2.3 Update `/agtoosa-update` guidance to read it as high-priority architecture memory and preserve contents — _Requirements: AC-003_
  - [x] 2.4 Update `AgToosa_Agent`, root platform instructions, spec, and arch review guidance to consult the document — _Requirements: AC-004, AC-006_
- [x] **3.** Domain and ADR records: document the new architecture context contract.
  - [x] 3.1 Add Master Architecture domain language to `Docs/Context/CONTEXT.md` — _Requirements: AC-004_
  - [x] 3.2 Add ADR-009 for first-class master architecture context — _Requirements: AC-001, AC-003, AC-004_
- [x] **4.** Tests and evidence: lock the behavior with focused bats coverage.
  - [x] 4.1 Add bats coverage for `--list-template-files` and fresh install copy — _Requirements: AC-001, AC-007_
  - [x] 4.2 Add bats coverage for update preservation and instruction references — _Requirements: AC-003, AC-004, AC-006, AC-007_
  - [x] 4.3 Run DEV-019 filter and relevant install/update smoke tests — _Requirements: AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 3.1, 3.2

**Wave 2 (sequential after Wave 1):** 2.1, 2.2, 2.3, 2.4

**Wave 3 (sequential after Wave 2):** 4.1, 4.2

**Wave 4 (sequential after Wave 3):** 4.3

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-019.md`

AC coverage: 7 ACs mapped to 8 test IDs

Smoke set: 6 tests tagged @smoke

## ✅ Spec Approved

Approved: 2026-05-24 12:35
