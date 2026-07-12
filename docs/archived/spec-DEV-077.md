# Spec: DEV-077 — Chore: Authoring Guide and Onboarding Surface

> **Story ID:** DEV-077
> **Type:** Chore
> **Epic:** DEV-003 — Ecosystem & Registry
> **Status:** ⬜ Backlog
> **Estimate:** S
> **Priority:** P2
> **Spec created:** 2026-07-11
> **Spec deepened:** 2026-07-11

## Context

`docs/extension-authoring-guide.md` already explains platform wiring, but it is difficult to discover and can become stale as platform surfaces evolve. Registry documentation has a short publication sequence but no canonical author checklist covering scope, tests, threat notes, compatibility, provenance, examples, and ownership. README and `/agtoosa-help` should expose these maintainer resources as links, not reproduce their content.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make platform-extension and registry-pack authoring guidance discoverable from README and help while keeping each guide canonical in one place. |
| User outcome | A contributor can find the correct authoring guide, complete a registry pack readiness checklist, and return to the owning handbook for detail. |
| Success condition | The extension guide is refreshed and linked; a canonical registry-pack authoring handbook/checklist exists; Registry, README, and all maintained help surfaces point to those owners without copying their substantive instructions. |
| Proof / evidence | AUTH tests cover guide inventory, checklist fields, supported help surfaces, valid links, static-help behavior, and non-duplication. |
| Non-goals | New registry commands, automatic pack generation or publication, marketplace behavior, or a new onboarding workflow. |
| Assumptions | `docs/extension-authoring-guide.md` remains the canonical platform-extension guide; public maintainer authoring docs are not generated-project workflow state. |
| Risks | Static help adapters drift, downstream help links use maintainer-only relative paths, or duplicated checklists diverge. |
| Unresolved questions | None. |

### 1.2 User Stories

**As a** platform contributor, **I want** the extension-authoring guide linked from obvious entry points **so that** I can wire every required generator surface.

**As a** registry pack author, **I want** one readiness checklist and handbook **so that** my pack includes test, threat, compatibility, provenance, example, and ownership evidence before review.

**As a** maintainer, **I want** README and help to route to canonical guides **so that** onboarding text does not drift across adapters.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a contributor opens the extension-authoring guide THE SYSTEM SHALL identify every currently supported platform-wiring surface, required parity checks, and the maintained examples to follow | Must |
| AC-002 | WHEN a pack author opens the registry-pack authoring handbook THE SYSTEM SHALL present a checkable readiness list for scoped spec template, test guidance, threat-model notes, version compatibility, provenance, worked example, and named maintenance owner | Must |
| AC-003 | WHEN Registry documentation explains pack creation THE SYSTEM SHALL link to the canonical pack-authoring handbook and SHALL NOT maintain a second full readiness checklist inline | Must |
| AC-004 | WHEN a reader opens README's contributor or documentation discovery area THE SYSTEM SHALL find concise links to the extension guide and registry-pack handbook without duplicated authoring steps | Must |
| AC-005 | WHEN `/agtoosa-help` renders on any maintained native help surface THE SYSTEM SHALL expose an authoring-resources pointer that resolves for generated-project users and SHALL preserve the static no-context-read default | Must |
| AC-006 | WHEN an authoring resource moves or is renamed THE SYSTEM SHALL fail focused link/inventory checks until README, Registry, and maintained help pointers are updated | Must |
| AC-007 | WHEN authoring guidance names enforcement THE SYSTEM SHALL distinguish repository checks, registry-review requirements, manual maintainer actions, and roadmap controls | Should |

### 1.4 Failure Modes

| ID | Maps to | Failure mode |
|----|---------|--------------|
| FM-001 | AC-001 | The extension guide omits a supported platform adapter or stale file-list surface. |
| FM-002 | AC-002 | A pack reaches review with no compatibility, provenance, or maintenance owner. |
| FM-003 | AC-003 | Registry and handbook carry two divergent checklists. |
| FM-004 | AC-004 | README contains a copied mini-guide that becomes stale. |
| FM-005 | AC-005 | A generated-project help adapter links to a local lowercase maintainer path that does not exist. |
| FM-006 | AC-006 | A renamed guide leaves silent broken discovery links. |
| FM-007 | AC-007 | Documentation calls manual registry review “CI-enforced.” |

### 1.5 Out of Scope

- Changing registry install, publish, verification, or trust behavior.
- Creating or publishing an official registry pack.
- Adding a contributor portal, wizard, or interactive onboarding command.
- Duplicating the handbook into generated projects.
- Reworking the full README or `/agtoosa-help` command table.
- Updating unrelated lifecycle adapters.

### 1.6 Claim Boundary

| Control | Classification |
|---------|----------------|
| Canonical extension and pack-authoring guidance | documentation |
| README, Registry, and help discovery pointers | generator-enforced only for installed adapter files; content remains documentation |
| Focused inventory and link checks | CI-enforced when repository CI runs them |
| Registry approval and maintenance-owner confirmation | manual maintainer review |
| Pack containment and hash checks | existing generator-enforced controls; referenced, not changed |
| Automatic pack compliance certification | out of scope |

## 2. Design

### 2.1 Architecture Blueprint

File to create:

- `docs/registry-pack-authoring.md` — canonical readiness checklist and handbook.

Files to change:

- `docs/extension-authoring-guide.md` — refresh current surfaces, parity checks, and maintained examples.
- `template/Docs/AgToosa_Registry.md` and `docs/AgToosa_Registry.md` — concise handbook pointer only.
- `README.md` — concise authoring-resource links.
- Maintained help adapters under `template/.claude/`, `template/.cursor/`, `template/.gemini/`, `template/.github/prompts/`, `template/.windsurf/`, and `template/.codex/` — one stable authoring-resources pointer.
- `tests/agtoosa.bats` — AUTH inventory, link, parity, and non-duplication checks.

The extension guide and registry-pack handbook own substantive instructions. README, Registry, and help own discovery only.

### 2.2 Data Flow

1. A contributor enters through README or `/agtoosa-help`.
2. The discovery surface selects either platform-extension authoring or registry-pack authoring.
3. A stable repository URL resolves to the canonical maintainer guide.
4. The contributor follows the owning guide and runs its named checks.
5. Registry documentation links pack authors back to the same handbook before publication review.
6. AUTH checks fail if a canonical file, supported adapter pointer, required checklist field, or link target drifts.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A look-alike external handbook is presented as canonical | Spoofing | Link to the repository-owned canonical path and name it consistently. |
| A duplicated checklist is changed in only one location | Tampering | Keep one full checklist; discovery surfaces contain links and one-line descriptions only. |
| A pack author disputes which checklist version applied | Repudiation | Guide is versioned with the repository; review cites its commit or release. |
| Author examples include tokens, private registry URLs, or signing keys | Information Disclosure | Examples use placeholders and describe provenance without secret values. |
| Broken links prevent contributor onboarding | Denial of Service | Focused inventory/link tests cover every maintained discovery surface. |
| A guide implies pack markdown may write protected settings or CI | Elevation of Privilege | Handbook reiterates current allowlist/denylist and manual authorization boundaries. |

### 2.4 Build Scope

⬜ Backlog — Proposed Scope Boundary (not build authorization)
Files in scope      : `docs/registry-pack-authoring.md`, `docs/extension-authoring-guide.md`, `template/Docs/AgToosa_Registry.md`, `docs/AgToosa_Registry.md`, `README.md`, maintained `agtoosa-help` adapters, `tests/agtoosa.bats`
Directories in scope: `docs/`, `template/.claude/`, `template/.cursor/`, `template/.gemini/`, `template/.github/prompts/`, `template/.windsurf/`, `template/.codex/`
Out of scope        : registry implementation, pack publication, new onboarding command, unrelated workflow adapters

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Authoring discovery contract
  - [x] 1.1 Add RED AUTH checks for canonical files, checklist fields, links, adapter parity, and static-help behavior — _Requirements: AC-002, AC-004, AC-005, AC-006_
  - [x] 1.2 Define the one-line discovery copy and stable link policy — _Requirements: AC-003, AC-004, AC-005_
- [x] **2.** Canonical authoring content
  - [x] 2.1 Refresh the extension guide against current platform wiring and parity surfaces — _Requirements: AC-001, AC-007_
  - [x] 2.2 Create the registry-pack handbook and readiness checklist — _Requirements: AC-002, AC-007_
- [x] **3.** Registry and README discovery
  - [x] 3.1 Replace expanded pack-readiness duplication with a canonical handbook pointer in Registry mirrors — _Requirements: AC-003, AC-006_
  - [x] 3.2 Add concise README links to both authoring owners — _Requirements: AC-004, AC-006_
- [x] **4.** Help discovery parity
  - [x] 4.1 Add the stable authoring-resources pointer to every maintained help adapter — _Requirements: AC-005, AC-006_
  - [x] 4.2 Confirm default help remains static and performs no context read — _Requirements: AC-005_
- [x] **5.** Evidence
  - [x] 5.1 Run focused AUTH checks and record RED/GREEN evidence without changing registry behavior — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 2.1, 2.2  
**Wave 2 (parallel after Wave 1):** 3.1, 3.2, 4.1  
**Wave 3 (sequential after Wave 2):** 4.2  
**Wave 4 (sequential after Wave 3):** 5.1

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-077.md`
AC coverage: 7 ACs mapped to 8 AUTH test IDs
Smoke set: 3 tests tagged `@smoke`

## ✅ Spec Approved

Approved: 2026-07-11 21:25
Enrollment: remaining-specs fan-out wave 1 (build/review/ship)
