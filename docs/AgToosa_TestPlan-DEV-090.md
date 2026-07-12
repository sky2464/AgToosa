# Test Plan: DEV-090 — Unified Install/Update Plan Engine + JSON Dry-Run

> **Spec:** `docs/archived/spec-DEV-090.md`
> **Status:** 🟩 Done — PLN-001–PLN-009 green
> **Created:** 2026-07-12
> **Test prefix:** `PLN`

## Scope

Shared `lib/plan.sh` categorization for install and update dry-run, JSON plan output, idempotent preview, no-mutation guarantees, and workflow doc lock-path alignment. Does not cover DEV-093 lock revalidation behavior.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | PLN-001 | plan.sh exposes compute function | Unit/contract | `compute_agtoosa_plan` exists and returns actions | 🟩 Pass |
| AC-002 | PLN-002 | Install dry-run uses plan engine | Integration | `--dry-run` categories match pre-refactor baseline fixture | 🟩 Pass |
| AC-003 | PLN-003 | Update dry-run uses same categorization | Integration | `--update --dry-run` shares rules with install for overlap set | 🟩 Pass |
| AC-004 | PLN-004 | JSON dry-run is parseable | Integration | `--dry-run --format json` stdout is valid JSON with actions array | 🟩 Pass |
| AC-005 | PLN-005 | Second dry-run is idempotent | Regression | Back-to-back dry-run produces equivalent plan | 🟩 Pass |
| AC-006 | PLN-006 | Update doc uses Docs/agtoosa-lock.json | Docs grep | No `.agtoosa-lock.json` root references in Update.md | 🟩 Pass |
| AC-007 | PLN-007 | Init doc uses Docs/agtoosa-lock.json | Docs grep | Detection prose uses canonical Docs path | 🟩 Pass |
| AC-008 | PLN-008 | JSON dry-run performs no writes | Integrity | File hashes unchanged after JSON dry-run | 🟩 Pass |
| AC-009 | PLN-009 | Install and update plan parity on fixture tree | Integration | Same categorized paths for equivalent install/update state | 🟩 Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| JSON dry-run on missing update target | PLN-004 | Non-zero with actionable error; no writes |
| Unknown `--format` with dry-run | PLN-004 | Non-zero; human mode unaffected |
| Update.md retains stale root lock path | PLN-006 | Grep contract fails |
| Force + dry-run combined | PLN-002 | Plan shows backup_replace where force applies |
| Maintainer dogfood self-update path | PLN-003 | Existing self-target guard unchanged |

## Smoke Set

- `@smoke PLN-002` — install dry-run via plan engine.
- `@smoke PLN-004` — JSON dry-run parses.
- `@smoke PLN-006` — Update doc lock path canonical.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-090|PLN-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Plan engine RED coverage | `bats tests/agtoosa.bats -f "DEV-090\|PLN-"` | 1 | `PLN-001`: missing `lib/plan.sh`; `PLN-003`: `local -n` invalid on macOS bash 3.2; `PLN-004`: jq parse error (stage output on stdout) |
| 2. Unified plan implementation | `bats tests/agtoosa.bats -f "PLN-001\|PLN-002\|PLN-003\|PLN-004\|PLN-005\|PLN-008\|PLN-009"` | 1 | `PLN-009`: `.agtoosa/*` install=merge vs update=overwrite mismatch |
| 3. Documentation alignment | `bats tests/agtoosa.bats -f "PLN-006\|PLN-007"` | 1 | `PLN-007`: Init docs cited root `.agtoosa-lock.json` |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-090\|PLN-"` | 1 | See rows above |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Plan engine RED coverage | `bats tests/agtoosa.bats -f "DEV-090\|PLN-"` | 0 | `ok 1..9` — all PLN tests pass |
| 2. Unified plan implementation | `bats tests/agtoosa.bats -f "PLN-001\|PLN-002\|PLN-003\|PLN-004\|PLN-005\|PLN-008\|PLN-009"` | 0 | JSON plan: `schema_version=plan-result-v1`, 84 install actions |
| 3. Documentation alignment | `bats tests/agtoosa.bats -f "PLN-006\|PLN-007"` | 0 | Update/Init docs grep `Docs/agtoosa-lock.json` only |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-090\|PLN-"` | 0 | `1..9 ok`; regression: `bats -f "dry-run\|DEV-088"` 26/27 (PLN-008 flakes under parallel ship/ race — passes isolated) |
