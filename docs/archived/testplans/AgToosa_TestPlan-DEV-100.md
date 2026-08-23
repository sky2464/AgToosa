# Test Plan: DEV-100 — Shared JSON Output for Install/Registry

> **Spec:** `docs/archived/spec-DEV-100.md`
> **Status:** 🟩 GREEN — Rev4 Wave 2
> **Created:** 2026-07-12
> **Test prefix:** `JIO`

## Scope

Contract tests for shared JSON output: DEV-090 plan schema on catalog plan and dry-run, registry info JSON envelope, no ANSI on stdout, unchanged default human output, and `schema_version` presence.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | JIO-001 | Catalog plan emits DEV-090 JSON schema | Integration | `jq` parse OK; required plan fields present | 🟩 Pass `@smoke` |
| AC-002 | JIO-002 | Dry-run plan matches catalog plan schema shape | Contract | Same top-level keys and action row shape as JIO-001 | 🟩 Pass `@smoke` |
| AC-003 | JIO-003 | Catalog info JSON includes metadata fields | Integration | `id`, `name`, `version`, `platforms`, `sha256` when in catalog | 🟩 Pass |
| AC-004 | JIO-004 | JSON stdout contains no ANSI escapes | Regression | No `\x1b[` sequences in stdout | 🟩 Pass `@smoke` |
| AC-005 | JIO-005 | Default output remains human tables | Regression | Without `--format json`, output lacks leading `{` JSON document | 🟩 Pass |
| AC-006 | JIO-006 | Plan JSON includes schema_version | Contract | Field present (`plan-result-v1`) per DEV-090 | 🟩 Pass |
| AC-007 | JIO-007 | DEV-100 filter documents evidence | Meta | Bats filter `DEV-100` exists | 🟩 Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Unknown catalog entry with `--format json` | JIO-003 | Non-zero exit; stderr message; no partial JSON |
| Empty preset plan | JIO-001 | Valid JSON with empty `actions` array |
| Combined `--format json` and `--dry-run` on update | JIO-002 | Plan only; no apply |
| Legacy `--json` flag alone | JIO-005 | Unrecognized or unused — Must path is `--format json` (R1) |

## Smoke Set

- `@smoke JIO-001` — catalog plan JSON schema.
- `@smoke JIO-002` — dry-run schema parity.
- `@smoke JIO-004` — no ANSI on stdout.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-100|JIO-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED JSON contract | `bats tests/agtoosa.bats -f "DEV-100\|JIO-"` | 1 | `not ok 1 … JIO-001` — `jq: parse error` (human text, no plan JSON); `not ok 3 … JIO-003` — info JSON incomplete; `not ok 7` — Catalog docs missing `--format json` |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 2. Implementation | `bats tests/agtoosa.bats -f "DEV-100\|JIO-"` | 0 | `ok 1` through `ok 7`; JIO-004 no ANSI; `schema_version == plan-result-v1` |
