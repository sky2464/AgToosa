# Spec: DEV-144 — Operational Gitignore Auto-Merge

> **Story ID:** DEV-144
> **Epic:** DEV-001 — Core Generator & Install
> **Status:** 🏁 Shipped — v5.3.58
> **Estimate:** S
> **Clarity:** `ready`
> **Spec created:** 2026-07-28
> **Extends:** DEV-093 — Install State File · DEV-119 — Recoverable Project Transaction

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Gap | `template/.gitignore` exists but is not installed; install only prints advisory backup hints |
| Provenance model | rev4 §5 unchanged — version marker and lock stay committed; only `.agtoosa/` operational surface gitignored |
| Project-owned | Master-Plan, archived, Context, Master-Architecture, Changelog, evidence remain tracked per `lib/config.sh` |
| Maintainer pattern | Blanket `.agtoosa/`, `.worktrees/`, `*.bak.*` in maintainer `.gitignore` |
| Parity | Bash authoritative; PowerShell delegates install/update to bash |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | What should remain tracked after auto-gitignore? | **A** — Operational-only: ignore `.agtoosa/`, `*.bak.*`, `.worktrees/`; keep workflow + platform files committed |
| Q2 | When should AgToosa merge the ignore block? | **C** — Install + update + doctor (doctor surfaces missing rules on brownfield) |
| Q3 | Brownfield repos with tracked operational paths? | **A** — Ignore-only; doctor prints `git rm --cached` guidance; no auto git mutations |

#### Documented assumptions

- **Non-git projects** — merge still writes `.gitignore`; doctor tracked-path check skipped when `.git/` absent.
- **Marker idempotency** — re-run replaces inner block only; user rules outside markers preserved.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Ensure downstream projects automatically gitignore AgToosa operational artifacts |
| User outcome | Install/update add ignore rules without manual editing; doctor flags gaps and tracked operational leaks |
| Success condition | Idempotent marker block in project `.gitignore`; GIG bats green; doctor JSON findings GIG-003/GIG-004 |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-144.md`; bats GIG-001–GIG-008 |
| Non-goals | Ignoring workflow docs or platform adapters; ignoring version/lock markers; auto git mutations |
| Risks | Clobbering user `.gitignore`; duplicate rules on re-run |
| Unresolved questions | None |

### 1.2 User Stories

**As a** downstream adopter, **I want** AgToosa to add operational ignore rules on install **so that** `.agtoosa/` state and backups do not enter version control.

**As a** brownfield maintainer, **I want** doctor to flag missing ignore rules and tracked operational paths **so that** I can fix git hygiene without auto git mutations.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN install completes THE SYSTEM SHALL merge the AgToosa operational marker block into project `.gitignore` | Must |
| AC-002 | WHEN update apply succeeds THE SYSTEM SHALL refresh the same marker block idempotently | Must |
| AC-003 | WHEN marker block exists THE SYSTEM SHALL replace only content between markers without duplicating rules | Must |
| AC-004 | WHEN `.gitignore` is absent THE SYSTEM SHALL create it with the operational block | Must |
| AC-005 | WHEN doctor runs on an installed project without the marker THE SYSTEM SHALL emit GIG-003 warn finding | Must |
| AC-006 | WHEN doctor detects tracked `.agtoosa/` or `*.bak.*` paths THE SYSTEM SHALL emit GIG-004 with `git rm --cached` guidance and SHALL NOT mutate git | Must |
| AC-007 | WHEN verified THE SYSTEM SHALL pass GIG-001–GIG-008 bats | Must |
| AC-008 | WHEN merge runs THE SYSTEM SHALL NOT add workflow docs, platform trees, or provenance markers to ignore rules | Must |

### 1.4 Claim Boundary

| Surface | Classification | Boundary |
|---------|----------------|----------|
| `gitignore_merge_operational` | generator-enforced | Marker block only; no user rules outside markers |
| Doctor GIG-003/004 | generator-enforced | Read-only git inspection |
| Workflow docs / lock / version | committed contract | Unchanged per DEV-093 rev4 |

## 2. Design

### 2.1 Architecture Blueprint

| Surface | Change |
|---------|--------|
| `lib/gitignore.sh` | New — marker merge, doctor helpers |
| `agtoosa.sh` | Source `gitignore.sh` |
| `lib/install.sh` | Call merge after state write |
| `lib/apply.sh` | Call merge after `apply_commit_staging` success |
| `lib/maintain.sh` | GIG-003/GIG-004 doctor findings |
| `template/.gitignore` | Full operational marker block |
| `docs/AgToosa_Update.md` | Operational gitignore subsection |
| `template/Docs/AgToosa_Update.md` | Mirror |
| `docs/agtoosa-maintainer.md` | Downstream gitignore merge note |
| `tests/agtoosa.bats` | GIG-001–GIG-008 |

### 2.2 Threat Model (STRIDE)

| Threat | Mitigation |
|--------|------------|
| Tampering — marker injection | Fixed begin/end markers; generator-only writes between them |
| Information disclosure — doctor lists paths | Local-only; same trust as existing doctor |
| DoS — huge `.gitignore` | Replace bounded marker section only |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Gitignore merge core
  - [x] 1.1 `lib/gitignore.sh` marker merge — _AC-001–AC-004, AC-008_
  - [x] 1.2 Wire install + apply — _AC-001, AC-002_
- [x] **2.** Doctor findings
  - [x] 2.1 GIG-003/GIG-004 in `run_doctor` — _AC-005, AC-006_
- [x] **3.** Docs + template
  - [x] 3.1 `template/.gitignore` + Update doc mirrors — _AC-008_
- [x] **4.** Bats GIG-001–GIG-008 — _AC-007_

### 3.2 Test Plan

- `docs/AgToosa_TestPlan-DEV-144.md`

## ✅ Spec Approved

Approved: 2026-07-28 — served by plan confirmation (interview Q1–Q3 complete).
