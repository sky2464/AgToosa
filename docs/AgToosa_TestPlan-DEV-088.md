# Test Plan: DEV-088 — Verifier and Doctor Machine Output

> **Spec:** `docs/archived/spec-DEV-088.md`
> **Status:** 🟦 Todo — spec approved; build not started
> **Created:** 2026-07-12
> **Test prefix:** `VFJ`

## Scope

JSON emitter, JSON Schema conformance, Problem/Impact/Fix human format, doctor provenance labels, CLI passthrough, and gate template JSON step. No new verifier gates. Default human mode must remain compatible with existing VF-* expectations aside from enriched finding text.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | VFJ-001 | Verifier JSON mode emits valid document | Integration | `--format json` stdout parses; exit codes preserved | ⬜ Pending |
| AC-001, AC-003 | VFJ-002 | JSON conforms to verify-result-v1 schema | Schema | Required fields present on pass and fail fixtures | ⬜ Pending |
| AC-002 | VFJ-003 | Human findings use Problem Impact Fix | Docs/output | Each finding includes three labeled sections | ⬜ Pending |
| AC-004 | VFJ-004 | Doctor JSON labels provenance surfaces | Integration | version_marker, lock_file, state_file with authority text | ⬜ Pending |
| AC-005 | VFJ-005 | Findings include assurance classification | Contract | `guided`/`evidenced`/`enforced` metadata where applicable | ⬜ Pending |
| AC-006 | VFJ-006 | Gate example runs verifier JSON step | Workflow contract | Template invokes `--format json` and fails on non-zero exit | ⬜ Pending |
| AC-006 | VFJ-007 | Gate preserves verifier exit status | Regression | JSON parse success does not mask verifier failure | ⬜ Pending |
| AC-007 | VFJ-008 | Default human mode remains usable | Regression | No `--format json` still exits correctly on fixtures | ⬜ Pending |
| AC-008 | VFJ-009 | agtoosa.sh passes format flag to verify and doctor | CLI contract | `--verify --format json` and `--doctor --format json` dispatch | ⬜ Pending |
| AC-009 | VFJ-010 | Schema file installed in template and docs | Inventory | `docs/schemas/verify-result-v1.json` registered | ⬜ Pending |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Verifier fails with multiple findings | VFJ-002 | JSON lists all findings; exit non-zero |
| Doctor run on repo without state.json | VFJ-004 | Reports absent with correct authority label |
| Invalid `--format` value | VFJ-009 | Non-zero with actionable error |
| Gate JSON step when verifier missing | VFJ-006 | Job fails closed (existing DEV-062 behavior) |
| Human mode regression on VF-001 fixture | VFJ-008 | Exit semantics unchanged |

## Smoke Set

- `@smoke VFJ-001` — JSON mode happy path on maintainer repo.
- `@smoke VFJ-003` — Problem/Impact/Fix present on forced failure fixture.
- `@smoke VFJ-006` — gate template includes JSON verifier step.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-088|VFJ-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Schema and contract RED coverage | `bats tests/agtoosa.bats -f "DEV-088\|VFJ-"` | — | _Pending — record during `/agtoosa-build`_ |
| 2. Verifier machine output | `bats tests/agtoosa.bats -f "VFJ-001\|VFJ-002\|VFJ-003\|VFJ-005\|VFJ-008"` | — | _Pending — record during `/agtoosa-build`_ |
| 3. Doctor machine output | `bats tests/agtoosa.bats -f "VFJ-004\|VFJ-009"` | — | _Pending — record during `/agtoosa-build`_ |
| 4. CI adoption | `bats tests/agtoosa.bats -f "VFJ-006\|VFJ-007\|VFJ-010"` | — | _Pending — record during `/agtoosa-build`_ |
| 5. Evidence | `bats tests/agtoosa.bats -f "DEV-088\|VFJ-"` | — | _Pending — record during `/agtoosa-build`_ |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Schema and contract RED coverage | `bats tests/agtoosa.bats -f "DEV-088\|VFJ-"` | — | _Pending — record during `/agtoosa-build`_ |
| 2. Verifier machine output | `bats tests/agtoosa.bats -f "VFJ-001\|VFJ-002\|VFJ-003\|VFJ-005\|VFJ-008"` | — | _Pending — record during `/agtoosa-build`_ |
| 3. Doctor machine output | `bats tests/agtoosa.bats -f "VFJ-004\|VFJ-009"` | — | _Pending — record during `/agtoosa-build`_ |
| 4. CI adoption | `bats tests/agtoosa.bats -f "VFJ-006\|VFJ-007\|VFJ-010"` | — | _Pending — record during `/agtoosa-build`_ |
| 5. Evidence | `bats tests/agtoosa.bats -f "DEV-088\|VFJ-"` | — | _Pending — record during `/agtoosa-build`_ |
