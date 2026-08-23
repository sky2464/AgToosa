# Test Plan: DEV-091 — Migration Wizard + Rollback Manifest

> **Spec:** `docs/archived/spec-DEV-091.md`
> **Status:** 🟨 In Progress — build GREEN (MWZ 10/10); pending review/ship
> **Created:** 2026-07-12
> **Test prefix:** `MWZ`

## Scope

Fixture-based coverage for MAJOR-version migration wizard: gate behavior, DEV-090 plan schema output, dry-run no-write semantics, rollback manifest creation, marker-outside preservation, `--accept-breaking`, JSON mode, and unchanged PATCH/MINOR paths.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | MWZ-001 | MAJOR update blocked without accept-breaking | Integration/negative | Non-interactive MAJOR `--update` exits non-zero; no files mutated | ✅ Pass `@smoke` |
| AC-002 | MWZ-002 | Dry-run plan uses DEV-090 action categories | Contract | Plan rows include `overwrite`, `merge`, `preserve`, `manual` | ✅ Pass `@smoke` |
| AC-003 | MWZ-003 | Apply writes timestamped rollback manifest | Integration | `.agtoosa/rollback/<ts>.json` exists with entries array | ✅ Pass `@smoke` |
| AC-004 | MWZ-004 | Content outside markers is preserved | Integration | User suffix outside `<!-- AgToosa` block survives apply | ✅ Pass |
| AC-005 | MWZ-005 | accept-breaking prints plan before apply | Integration | stdout contains plan summary even without prior dry-run | ✅ Pass |
| AC-006 | MWZ-006 | Dry-run makes no writes | Regression | No manifest, no backup dir, file mtimes unchanged | ✅ Pass `@smoke` |
| AC-007 | MWZ-007 | JSON mode emits valid plan object | Contract | `--json` stdout parses; no ANSI escapes | ✅ Pass |
| AC-008 | MWZ-008 | MINOR update skips MAJOR gate | Regression | PATCH/MINOR fixture applies without `--accept-breaking` | ✅ Pass |
| AC-009 | MWZ-009 | Update doc documents MAJOR wizard | Docs | `AgToosa_Update.md` references wizard, manifest, flag | ✅ Pass |
| AC-001, AC-003 | MWZ-010 | DEV-091 filter and manifest schema fields | Meta | Bats filter green; manifest has `schema_version`, versions, `entries` | ✅ Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| MAJOR with only manual-action rows | MWZ-002 | Plan lists `manual`; apply waits for confirm |
| Interrupted apply mid-backup | MWZ-003 | Partial manifest or clean abort documented in test |
| Same MAJOR re-run after success | MWZ-008 | No second wizard unless version still behind |
| JSON + dry-run combined | MWZ-007 | JSON plan emitted; zero writes |

## Smoke Set

- `@smoke MWZ-001` — MAJOR gate blocks silent apply.
- `@smoke MWZ-002` — categorized plan schema.
- `@smoke MWZ-003` — rollback manifest written.
- `@smoke MWZ-006` — dry-run is read-only.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-091|MWZ-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED fixtures | `bats tests/agtoosa.bats -f "DEV-091\|MWZ-"` | 1 (pre-impl) | filter unmatched / missing `lib/migrate.sh` before GREEN |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 2. Implementation | `bats tests/agtoosa.bats -f "DEV-091\|MWZ-"` | 0 | `ok 1` through `ok 10` (2026-07-12) |
| 3. Docs | `bats tests/agtoosa.bats -f "MWZ-009"` | 0 | Update doc contains `rollback` and `--accept-breaking` |
