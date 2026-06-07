# Test Plan: DEV-035 — PSScriptAnalyzer CI gate for agtoosa.ps1

> **Spec:** `docs/archived/spec-DEV-035.md`
> **Story ID:** DEV-035
> **Coverage target:** 80% (workflow + bats structural)

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | PA-001 | Integration | `ci.yml` `windows-smoke` job contains PSScriptAnalyzer / `Invoke-ScriptAnalyzer` step for `agtoosa.ps1` | yes |
| AC-002 | PA-002 | Integration | Analyzer step is blocking (no `continue-on-error: true` on that step) | yes |
| AC-003 | PA-003 | Unit | `agtoosa.ps1` retains DEV-033 approved names (`Copy-StageFiles`, `Initialize-PackQueueDir`, `Move-ShipPacksToQueue`) and excludes legacy names | yes |
| AC-004 | PA-001, PA-002 | Integration | DEV-035 bats PA-001–PA-003 exist and pass | yes |
| AC-005 | — | Manual | This test plan maps all Must ACs to test IDs | no |
| AC-006 | PA-001 | Integration | Workflow step references formatted failure output (`Format-Table` or explicit `exit 1` on findings) | no |

## Negative / Edge Scenarios

| Scenario | Test ID | Expected |
|----------|---------|----------|
| Reintroduce `Stage-Files` in `agtoosa.ps1` | Manual / CI | `windows-smoke` analyzer step fails |
| Remove analyzer step from workflow | PA-001 | bats fails — workflow drift caught |

## Evidence Log

| Date | Command | Result |
|------|---------|--------|
| 2026-06-06 | `bats tests/agtoosa.bats -f "DEV-035"` | ✅ 3/3 pass — PA-001, PA-002, PA-003 |
| 2026-06-06 | `bats tests/agtoosa.bats -f "^version parity:\|DEV-033\|MR5:"` | ✅ 6/6 pass — version parity, DEV-033, MR5, and matched DEV-034 shipped-disposition check |
| 2026-06-06 | `bats tests/agtoosa.bats` | ✅ 361/361 pass |
| 2026-06-06 | `pwsh -NoProfile -Command '$findings = Invoke-ScriptAnalyzer -Path ./agtoosa.ps1 -IncludeRule PSUseApprovedVerbs -Severity Error, Warning; ...'` | ✅ `agtoosa.ps1` clean |
| 2026-06-06 | Temporary `.ps1` with `function Ensure-PackQueueDir { }` + `Invoke-ScriptAnalyzer -IncludeRule PSUseApprovedVerbs` | ✅ Intentional violation detected as `PSUseApprovedVerbs` warning |
| _(pending merge)_ | GitHub Actions `windows-smoke` | — |
