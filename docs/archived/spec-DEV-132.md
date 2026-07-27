# Spec: DEV-132 — Preserve Evidence JSONL on Re-install and Update

> **Story ID:** DEV-132  
> **Epic:** DEV-001 — Generator & Install · DEV-004 — Testing & QA Harness  
> **Type:** Fix  
> **Status:** 🟦 Todo — Spec Approved  
> **Estimate:** XS  
> **Clarity:** `ready`  
> **Priority:** P0  
> **Parent / extends:** DEV-049 (Evidence Ledger) · DEV-071 (project-owned Docs preservation)  
> **Spec created:** 2026-07-27  
> **Ship target:** v5.3.46

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Goal boundary | `Docs/agtoosa-evidence.jsonl` is append-only project-owned evidence mirror (DEV-049); re-install/update currently overwrites it because only Master-Plan, Changelog, and Master-Architecture are preserved |
| Status quo | 17 duplicate Cursor PRs (#66–#85) implemented the same fix; none merged; pattern exists in `lib/install.sh` hard-coded trio |
| Narrowest scope | Centralize project-owned Docs list in `lib/config.sh`; wire install, update, reinstall, uninstall, plan, and PowerShell `Copy-FileWithGuard` |
| Failure modes | Silent data loss on `--update` / re-install; inconsistent Bash vs PS1 parity |
| Security | No new trust boundary — prevents accidental tampering with user evidence ledger |
| Non-goals | Making JSONL authoritative over markdown ledger; auto-migrating empty seed to populated file |

#### Asked & confirmed

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Cold-start pick from `/agtoosa-next` | **DEV-132** — preserve `Docs/agtoosa-evidence.jsonl` on reinstall/update |

#### Documented assumptions

- User confirmed story via `/agtoosa-next` cold-start pick (equivalent to explicit enrollment).
- XS estimate — single helper + parity surfaces + bats; no template generator changes beyond shipped docs contract.

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Treat `Docs/agtoosa-evidence.jsonl` as project-owned append-only state; never overwrite on install, update, or reinstall when the file already exists |
| User outcome | Downstream projects keep evidence ledger rows across AgToosa upgrades |
| Success condition | EVJ-001–EVJ-006 bats green; Bash + PowerShell parity; preserve banner shows "your evidence ledger" |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-132.md`; bats `EVJ-001–EVJ-006` |
| Non-goals | JSONL authority over markdown; seeding empty file on first install when absent; changing Evidence workflow semantics |
| Assumptions | DEV-049 shipped; existing preservation pattern for Master-Plan is the reference implementation |
| Risks | Drift if new install paths bypass `agtoosa_is_project_owned_doc` helper |
| Unresolved questions | None |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN `install` copies Docs workflow files IF `Docs/agtoosa-evidence.jsonl` already exists in the project THE SYSTEM SHALL preserve the file and print the evidence-ledger preserve reason |
| AC-002 | Must | WHEN `--update` refreshes Docs files THE SYSTEM SHALL skip overwriting an existing `Docs/agtoosa-evidence.jsonl` |
| AC-003 | Must | WHEN `--reinstall` replaces Docs files THE SYSTEM SHALL skip overwriting an existing `Docs/agtoosa-evidence.jsonl` |
| AC-004 | Must | WHEN `--uninstall` removes AgToosa-owned Docs files THE SYSTEM SHALL retain `Docs/agtoosa-evidence.jsonl` |
| AC-005 | Must | WHEN PowerShell install/update copies Docs files THE SYSTEM SHALL preserve an existing `Docs/agtoosa-evidence.jsonl` via `Copy-FileWithGuard` |
| AC-006 | Must | WHEN the install plan engine classifies paths THE SYSTEM SHALL mark `Docs/agtoosa-evidence.jsonl` as `preserve` when present |
| AC-007 | Must | WHEN DEV-132 ships THE SYSTEM SHALL pass bats EVJ-001–EVJ-006 |

### 1.3 Scope Boundary

**In scope:** `lib/config.sh`, `lib/install.sh`, `lib/update.sh`, `lib/reinstall.sh`, `lib/maintain.sh`, `lib/plan.sh`, `agtoosa.ps1`, `tests/agtoosa.bats`.

**Out of scope:** Evidence workflow docs, JSONL schema, verifier enforcement of ledger content, template-only doc mirrors.

## 2. Design

### 2.1 Project-owned Docs helper

Introduce `_AGTOOSA_PROJECT_OWNED_DOCS` and `agtoosa_is_project_owned_doc()` in `lib/config.sh`, including `Docs/agtoosa-evidence.jsonl` alongside Master-Plan, Changelog, and Master-Architecture.

Replace hard-coded trio checks in install/update/reinstall/maintain/plan with the helper.

### 2.2 PowerShell parity

Extend `Copy-FileWithGuard` in `agtoosa.ps1` with evidence JSONL preserve branch and reason string.

### 2.3 STRIDE (summary)

| Threat | Mitigation |
|--------|------------|
| Tampering (data loss) | Preserve on all mutating install paths |
| Repudiation | Bats assert file content survives re-install |

### 2.4 Build Scope

| Surface | Change |
|---------|--------|
| `lib/config.sh` | Project-owned docs array + helper |
| `lib/install.sh` | Use helper; evidence preserve reason |
| `lib/update.sh` | Skip overwrite for helper match |
| `lib/reinstall.sh` | Skip overwrite for helper match |
| `lib/maintain.sh` | Uninstall skip list includes evidence jsonl |
| `lib/plan.sh` | Plan category `preserve` for evidence jsonl |
| `agtoosa.ps1` | `Copy-FileWithGuard` evidence branch |
| `tests/agtoosa.bats` | EVJ-001–EVJ-006 |

## 3. Tasks

- [x] **1.** Add `agtoosa_is_project_owned_doc` helper — _AC-001, AC-006_
- [x] **2.** Wire Bash install/update/reinstall/uninstall/plan preservation — _AC-001–AC-004, AC-006_
- [x] **3.** Wire PowerShell `Copy-FileWithGuard` parity — _AC-005_
- [x] **4.** Add bats EVJ-001–EVJ-006 — _AC-007_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-132.md`.

---

## ✅ Spec Approved

Approved via `/agtoosa-next` Sequential Approval — 2026-07-27 — ready for `/agtoosa-build`.
