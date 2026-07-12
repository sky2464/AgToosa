# Test Plan: DEV-104 — --reinstall --clean (ADR-004 Option C)

> **Spec:** `docs/archived/spec-DEV-104.md`
> **Status:** ⬜ Proposed
> **Created:** 2026-07-12
> **Test prefix:** `RCL`
> **Prerequisite gate:** DEV-090 lock file path corrections

## Scope

Optional `--reinstall --clean`: confirmation gate, timestamped archive manifest, fresh regeneration, `Docs/agtoosa-lock.json` rewrite, unmarked-edit warning, idempotent second run, bash/PowerShell parity, and ADR-004 documentation positioning.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | RCL-001 | Confirmation Required | Integration/security | Without confirm flag, exit non-zero and no file changes | Planned `@smoke` |
| AC-002 | RCL-002 | Archive Manifest Written | Integration | Timestamped archive dir contains manifest of prior generated files | Planned |
| AC-003 | RCL-003 | Fresh Regeneration | Integration | Post-reinstall file set matches fresh install fixture | Planned `@smoke` |
| AC-004 | RCL-004 | Lock File Rewritten | Integration | `Docs/agtoosa-lock.json` updated with current version/platforms | Planned `@smoke` |
| AC-005 | RCL-005 | Unmarked Edit Warning | Docs/CLI | CLI warns clean reinstall may not preserve edits outside markers | Planned |
| AC-006 | RCL-006 | Idempotent Second Run | Integration | Second consecutive clean reinstall reports no effective change | Planned |
| AC-007 | RCL-007 | PowerShell Parity | Integration | `agtoosa.ps1 --reinstall --clean` matches bash outcomes | Planned |
| AC-008 | RCL-008 | Update Docs Positioning | Docs contract | `AgToosa_Update.md` lists `--update` default; clean reinstall optional | Planned |

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
| 1. RED reinstall contract | `bats tests/agtoosa.bats -f "DEV-104\|RCL-"` | 1 | `unknown option --reinstall` or all RCL tests fail pre-implementation |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Documentation and evidence | `bats tests/agtoosa.bats -f "DEV-104\|RCL-"` | 0 | All RCL tests pass; archive + lock paths verified |
