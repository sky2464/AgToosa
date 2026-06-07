# Spec: DEV-035 — PSScriptAnalyzer CI gate for agtoosa.ps1

> **Story ID:** DEV-035
> **Epic:** DEV-004 — Testing & QA Harness
> **Status:** 🏁 Shipped (v5.2.6 — 2026-06-06)
> **Estimate:** XS
> **Spec created:** 2026-06-05

## Context

DEV-033 renamed three `agtoosa.ps1` helpers to approved PowerShell verbs and verified PSScriptAnalyzer locally, but explicitly deferred **CI integration** (see `docs/archived/spec-DEV-033.md` § 1.4 Out of Scope). Review DEV-033 accepted this gap with a 🟡 Warning: PSScriptAnalyzer is manual/IDE-only (AC-001 not automated in CI).

After DEV-034 shipped v5.2.5, the maintainer Active Cycle is empty — `/agtoosa-status` deducts Plan Completeness (−10) and recommends `/agtoosa-spec`. This story closes the DEV-033 verification gap with a minimal Windows CI step so verb regressions fail PRs before merge.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Automate PSScriptAnalyzer verification for `agtoosa.ps1` in CI so approved-verb compliance is enforced on every PR. |
| User outcome | Maintainers and contributors cannot merge PS1 verb regressions; DEV-033 AC-001 evidence is reproducible without a local IDE. |
| Success condition | `windows-smoke` (or equivalent Windows job) runs `Invoke-ScriptAnalyzer` on `agtoosa.ps1`; CI fails on `PSUseApprovedVerbs` violations for the DEV-033 rename set; bats PA-001–PA-003 green. |
| Proof / evidence | GitHub Actions Windows job log shows analyzer pass; `bats tests/agtoosa.bats -f "DEV-035"` green; focused full-suite regression green. |
| Non-goals | Analyzing `lib/*.sh` or bash entrypoints; enforcing all PSScriptAnalyzer rules at Error severity; refactoring PS1 beyond analyzer config; MINOR version bump |
| Assumptions | **XS** chore; **PATCH** bump on ship (`v5.2.6` per current Milestone). Analyzer runs on `windows-latest` where `agtoosa.ps1` is already smoke-tested. Only `PSUseApprovedVerbs` (or equivalent approved-verb grep) is gated — other informational rules may remain advisory. |
| Risks | PSScriptAnalyzer module install flakiness — pin module version in workflow. False positives from unrelated rules — scope analyzer to approved verbs or explicit exclude list. |

### 1.2 User Stories

**As an** AgToosa maintainer, **I want** PSScriptAnalyzer to run in CI on `agtoosa.ps1` **so that** approved-verb compliance from DEV-033 cannot regress silently.

**As a** contributor opening a PR, **I want** a clear CI failure when `agtoosa.ps1` uses non-approved verbs **so that** I fix naming before review.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN CI runs on a pull request or push to `main` THE SYSTEM SHALL execute PSScriptAnalyzer (or equivalent approved-verb check) against `agtoosa.ps1` on a Windows runner | Must |
| AC-002 | WHEN `agtoosa.ps1` contains a `PSUseApprovedVerbs` violation for script-private functions THE SYSTEM SHALL fail the CI job with a non-zero exit code | Must |
| AC-003 | WHEN `agtoosa.ps1` matches the DEV-033 approved rename map THE SYSTEM SHALL pass the analyzer CI step | Must |
| AC-004 | WHEN `tests/agtoosa.bats` runs DEV-035 coverage THE SYSTEM SHALL assert the CI workflow contains the analyzer step and documents the pinned module or invocation pattern | Must |
| AC-005 | WHEN maintainer test-plan docs are read THE SYSTEM SHALL map each Must AC to at least one test ID in `docs/AgToosa_TestPlan-DEV-035.md` | Must |
| AC-006 | WHEN the analyzer step fails THE SYSTEM SHALL print which rule and symbol violated **so that** contributors can fix without local IDE setup | Should |

### 1.4 Out of Scope

- ShellCheck or bash analyzer changes (already in `ci.yml` validate job)
- PSScriptAnalyzer on template or generated project files
- Renaming additional PS1 functions beyond DEV-033 scope
- Adding PSScriptAnalyzer to pre-commit hooks

## 2. Design

### 2.1 Architecture Blueprint

| File / area | Change |
|-------------|--------|
| `.github/workflows/ci.yml` | Add PSScriptAnalyzer step to `windows-smoke` job (after checkout, before or after existing PS1 smokes) — _AC-001, AC-002, AC-006_ |
| `tests/agtoosa.bats` | DEV-035 PA-001–PA-003 workflow grep / structure tests — _AC-004_ |
| `docs/AgToosa_TestPlan-DEV-035.md` | AC → test mapping — _AC-005_ |
| `docs/Master-Plan.md` | Active Cycle enrollment, Active Tasks, Update Log — bookkeeping |

**Proposed CI step (illustrative):**

```powershell
Install-Module PSScriptAnalyzer -RequiredVersion 1.21.0 -Force -Scope CurrentUser
$findings = Invoke-ScriptAnalyzer -Path agtoosa.ps1 -IncludeRule PSUseApprovedVerbs -Severity Error, Warning
if ($findings) { $findings | Format-Table; exit 1 }
```

Alternative: grep-based bats-only gate without live analyzer in CI — rejected; AC-001 requires runtime analyzer on Windows runner.

### 2.2 Data Flow

1. PR or push triggers `ci.yml` → `windows-smoke` job.
2. Checkout repo; install pinned `PSScriptAnalyzer` module.
3. `Invoke-ScriptAnalyzer` scans `agtoosa.ps1` with `PSUseApprovedVerbs` rule.
4. Non-empty findings → `exit 1` with formatted output (AC-006).
5. Empty findings → job continues to existing PS1 smoke steps (version, help, registry).

### 2.3 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Contributor merges non-approved verbs that break PS conventions | Tampering | AC-001, AC-002 — CI gate on every merge |
| CI step silently skipped (workflow drift) | Repudiation | AC-004 — bats grep locks workflow step |
| Analyzer module supply-chain compromise | Spoofing | Pin `PSScriptAnalyzer` version in workflow; use `Install-Module -RequiredVersion` |
| False CI failures from unrelated analyzer rules | Denial of Service | Scope to `PSUseApprovedVerbs` only (AC-002) |
| Maintainer bypasses gate via `continue-on-error` | Elevation of Privilege | AC-004 bats assert step is blocking (no `continue-on-error: true`) |

### 2.4 Build Scope

```
Files in scope      : .github/workflows/ci.yml, tests/agtoosa.bats, docs/AgToosa_TestPlan-DEV-035.md
Directories in scope: .github/workflows/
Out of scope        : agtoosa.ps1 renames (already shipped DEV-033), agtoosa.sh, lib/*.sh, template/, version wiring until ship
```

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** CI workflow — PSScriptAnalyzer step
  - [x] 1.1 Add pinned `PSScriptAnalyzer` install + `Invoke-ScriptAnalyzer` step to `windows-smoke` — _AC-001, AC-002, AC-006_
  - [x] 1.2 Scope analyzer to `PSUseApprovedVerbs` (or approved-verb-only severity) — _AC-002_
  - [x] 1.3 Verify step fails on intentional violation (local or dry-run) — _AC-002_
- [x] **2.** Regression coverage
  - [x] 2.1 Add DEV-035 bats PA-001–PA-003 — _AC-003, AC-004_
  - [x] 2.2 Finalize `docs/AgToosa_TestPlan-DEV-035.md` evidence table — _AC-005_
- [x] **3.** Validation
  - [x] 3.1 Run `bats tests/agtoosa.bats -f "DEV-035"` — _AC-004_
  - [x] 3.2 Confirm `windows-smoke` job structure locally (workflow YAML review) — _AC-001_

### 3.2 Wave Plan

**Wave 1 (sequential):** 1.1, 1.2
**Wave 2 (parallel):** 1.3, 2.1, 2.2
**Wave 3 (sequential):** 3.1, 3.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-035.md`

## 4. Story skills

| Skill | Decision |
|-------|----------|
| _(none)_ | **Do not generate** — CI wiring is one-off maintainer chore. |

## 5. Build Evidence

| Date | Evidence |
|------|----------|
| 2026-06-06 | `bats tests/agtoosa.bats -f "DEV-035"` — 3/3 pass |
| 2026-06-06 | `bats tests/agtoosa.bats -f "^version parity:\|DEV-033\|MR5:"` — 6/6 pass |
| 2026-06-06 | `bats tests/agtoosa.bats` — 361/361 pass |
| 2026-06-06 | Local PSScriptAnalyzer `PSUseApprovedVerbs` check clean on `agtoosa.ps1`; temporary `.ps1` with `Ensure-PackQueueDir` reported the expected warning |

## ✅ Spec Approved

Approved: 2026-06-06 (implicit via `/agtoosa-build`)
