# Test Plan: DEV-104 — --reinstall --clean (ADR-004 Option C)

> **Spec:** `docs/archived/spec-DEV-104.md`
> **Status:** 🟩 GREEN — Wave 3 build
> **Created:** 2026-07-12
> **Test prefix:** `RCL`
> **Prerequisite gate:** DEV-090 lock file path corrections

## Scope

Optional `--reinstall --clean`: confirmation gate, timestamped archive manifest, fresh regeneration, `Docs/agtoosa-lock.json` rewrite, unmarked-edit warning, idempotent second run, bash/PowerShell parity, and ADR-004 documentation positioning.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | RCL-001 | Confirmation Required | Integration/security | Without confirm flag, exit non-zero and no file changes | 🟩 GREEN `@smoke` |
| AC-002 | RCL-002 | Archive Manifest Written | Integration | Timestamped archive dir contains manifest of prior generated files | 🟩 GREEN |
| AC-003 | RCL-003 | Fresh Regeneration | Integration | Post-reinstall file set matches fresh install fixture | 🟩 GREEN `@smoke` |
| AC-004 | RCL-004 | Lock File Rewritten | Integration | `Docs/agtoosa-lock.json` updated with current version/platforms | 🟩 GREEN `@smoke` |
| AC-005 | RCL-005 | Unmarked Edit Warning | Docs/CLI | CLI warns clean reinstall may not preserve edits outside markers | 🟩 GREEN |
| AC-006 | RCL-006 | Idempotent Second Run | Integration | Second consecutive clean reinstall reports no effective change | 🟩 GREEN |
| AC-007 | RCL-007 | PowerShell Parity | Integration | `agtoosa.ps1 -Reinstall -Clean` matches bash outcomes | 🟩 GREEN |
| AC-008 | RCL-008 | Update Docs Positioning | Docs contract | `AgToosa_Update.md` lists `--update` default; clean reinstall optional | 🟩 GREEN |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| `--reinstall --clean` without confirmation in CI fixture | RCL-001 | Non-zero; file hashes unchanged |
| Lock written to `.agtoosa-lock.json` wrong path | RCL-004 | Failure — must use `Docs/agtoosa-lock.json` |
| Update doc claims clean reinstall preserves custom edits | RCL-008 | Contract failure |

## Smoke Set

- `@smoke RCL-001` — confirmation required.
- `@smoke RCL-003` — fresh regeneration.
- `@smoke RCL-004` — lock file rewrite.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-104|RCL-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED reinstall contract | `bats tests/agtoosa.bats -f "DEV-104\|RCL-"` | 1 | `Unknown option '--reinstall'`; PS1 missing `$Reinstall`; Update docs missing `--reinstall --clean` |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Documentation and evidence | `bats tests/agtoosa.bats -f "DEV-104\|RCL-"` | 0 | 8/8 RCL pass; archive + lock paths verified (~49s) |

Ledger: `docs/archived/evidence-DEV-104.md`
