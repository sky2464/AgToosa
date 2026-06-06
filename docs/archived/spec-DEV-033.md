# Spec: DEV-033 — agtoosa.ps1 approved PowerShell verbs

> **Story ID:** DEV-033
> **Epic:** DEV-001 — Core Generator Engine
> **Status:** ✅ Done
> **Estimate:** XS
> **Spec created:** 2026-05-26

## Context

PSScriptAnalyzer rule `PSUseApprovedVerbs` reports three internal helper functions in `agtoosa.ps1` that use non-approved verbs (`Stage`, `Ensure`, `Salvage`). These are **severity 4** (informational) but clutter the maintainer IDE and obscure real issues. The bash entrypoint already uses snake_case helpers (`stage_files`, `_ensure_pack_queue_dir`, `_salvage_ship_packs_to_queue`) that are not subject to this rule.

**Root cause:** Early PS1 port chose descriptive English verbs without mapping to [approved PowerShell verbs](https://learn.microsoft.com/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands).

**Fix direction:** Rename the three functions and all call sites in `agtoosa.ps1` only. No behavior change. Optional doc string updates where function names are cited.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Clear all `PSUseApprovedVerbs` findings for the three reported helpers in `agtoosa.ps1`. |
| User outcome | Maintainers editing `agtoosa.ps1` see zero `PSUseApprovedVerbs` diagnostics on those symbols; generator behavior unchanged. |
| Success condition | Renamed functions use approved verbs; all in-file references updated; bats smoke greps pass; manual PSScriptAnalyzer run shows no findings on renamed symbols. |
| Proof / evidence | `bats tests/agtoosa.bats -f "DEV-033"` green; IDE diagnostics cleared on lines 252, 325, 339 (or equivalent after edit). |
| Non-goals | Renaming other PS1 helpers (`Show-*`, `Merge-*` already compliant); adding PSScriptAnalyzer to CI; changing `agtoosa.sh` / `lib/*.sh` names; public exported module surface |
| Assumptions | **S → XS** chore; **PATCH** bump on next ship (`5.2.4` per current Milestone). No active-cycle enrollment unless user requests. Rename map below is accepted without API compatibility promise (functions are script-private). |
| Risks | Missed call site leaves runtime error — mitigated by grep + existing bats install/registry smoke paths. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** `agtoosa.ps1` internal functions to use approved PowerShell verbs **so that** PSScriptAnalyzer stays quiet and the file matches PowerShell conventions.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `agtoosa.ps1` is analyzed with PSScriptAnalyzer THE SYSTEM SHALL report zero `PSUseApprovedVerbs` violations for the former `Stage-Files`, `Ensure-PackQueueDir`, and `Salvage-ShipPacksToQueue` symbols | Must |
| AC-002 | WHEN the generator runs `registry install` or full interactive install via `agtoosa.ps1` THE SYSTEM SHALL behave identically to pre-rename (staging, pack queue, salvage paths) | Must |
| AC-003 | WHEN `agtoosa.ps1` is searched THE SYSTEM SHALL contain no definitions or calls using the old function names `Stage-Files`, `Ensure-PackQueueDir`, or `Salvage-ShipPacksToQueue` | Must |
| AC-004 | WHEN `tests/agtoosa.bats` runs DEV-033 coverage THE SYSTEM SHALL assert approved-verb function names exist and legacy names are absent | Must |
| AC-005 | WHEN maintainer docs cite the old `Stage-Files` symbol THE SYSTEM SHALL update those references to the new name | Should |

### 1.4 Out of Scope

- CI integration of PSScriptAnalyzer
- Refactoring unrelated PS1 functions
- Version bump in this spec phase (ship handles `AGTOOSA_VERSION`)

## 2. Design

### 2.1 Architecture Blueprint

| Bash (`agtoosa.sh` / `lib/`) | Current PS1 | Proposed PS1 | Approved verb |
|------------------------------|-------------|--------------|---------------|
| `stage_files` | `Stage-Files` | `Copy-StageFiles` | Copy |
| `_ensure_pack_queue_dir` | `Ensure-PackQueueDir` | `Initialize-PackQueueDir` | Initialize |
| `_salvage_ship_packs_to_queue` | `Salvage-ShipPacksToQueue` | `Move-ShipPacksToQueue` | Move |

| File / area | Change |
|-------------|--------|
| `agtoosa.ps1` | Rename three `function` blocks and all call sites (~lines 252, 325, 332, 339, 342, 797, 801, 892, 899) |
| `docs/audit-v3.1.0-prod-readiness.md` | Update `Stage-Files` citation if still present — _AC-005_ |
| `tests/agtoosa.bats` | DEV-033 PV1–PV3 grep tests — _AC-003, AC-004_ |

### 2.2 Data flow

No change. `Copy-StageFiles` still copies template docs/platform files into `ship/`. `Initialize-PackQueueDir` still creates `.agtoosa/pack-queue/`. `Move-ShipPacksToQueue` still moves legacy `ship/packs/*` into the queue before `ship/` wipe.

### 2.3 STRIDE Threat Model

**N/A — refactor only.** No trust boundaries, auth, or data classification changes. Failure mode: broken rename → install/regression test failure (AC-002).

### 2.4 Build Scope

```
Files in scope      : agtoosa.ps1, tests/agtoosa.bats, docs/audit-v3.1.0-prod-readiness.md (if cited)
Directories in scope: (none beyond repo root files above)
Out of scope        : agtoosa.sh, lib/*.sh, template/, version wiring, platform adapters
```

## 3. Tasks

### 3.1 Task tree

- [x] **1.** Rename helpers in `agtoosa.ps1`
  - [x] 1.1 `Stage-Files` → `Copy-StageFiles`; update call sites — _AC-001, AC-003_
  - [x] 1.2 `Ensure-PackQueueDir` → `Initialize-PackQueueDir`; update call sites — _AC-001, AC-003_
  - [x] 1.3 `Salvage-ShipPacksToQueue` → `Move-ShipPacksToQueue`; update call sites — _AC-001, AC-003_
- [x] **2.** Docs + tests
  - [x] 2.1 Update audit doc reference to `Copy-StageFiles` — _AC-005_
  - [x] 2.2 Add DEV-033 bats PV1–PV3 — _AC-004_
- [x] **3.** Verify
  - [x] 3.1 Run `bats tests/agtoosa.bats -f "DEV-033"` and focused registry/install smoke — _AC-002, AC-004_
  - [x] 3.2 Confirm PSScriptAnalyzer clean on `agtoosa.ps1` (IDE or `Invoke-ScriptAnalyzer`) — _AC-001_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 1.2, 1.3 (single file — implement sequentially in practice)
**Wave 2 (sequential):** 2.1, 2.2
**Wave 3 (sequential):** 3.1, 3.2

## 4. Story skills

| Skill | Decision |
|-------|----------|
| _(none)_ | **Do not generate** — one-off rename; no repeated workflow. |

## ✅ Spec Approved

Approved: 2026-05-26 (user approved rename map; XS chore on 5.2.x PATCH train)
