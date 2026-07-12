# Test Plan: DEV-094 — Assistant Compatibility Contract

> **Spec:** `docs/archived/spec-DEV-094.md`
> **Status:** 🟦 Planned — Rev4 Wave 2
> **Created:** 2026-07-12
> **Test prefix:** `ACC`

## Scope

Documentation-contract and inventory tests for three-tier compatibility (Install/Render/Scenario), per-platform evidence rows, honest tier labeling, DEV-055 cross-link without merge, config registration, and no false Scenario claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | ACC-001 | Tier definitions are present and distinct | Docs/contract | Doc defines Install-tested, Render-tested, Scenario-tested with evidence rules | ⬜ Planned `@smoke` |
| AC-002 | ACC-002 | Every config platform has a compatibility row | Integration | Row per `lib/config.sh` platform with tier, date, pointer, gaps | ⬜ Planned `@smoke` |
| AC-003 | ACC-003 | No Scenario label without Scenario evidence | Claim boundary | Rows without scenario pointer forbid `Scenario-tested` / `fully supported` | ⬜ Planned `@smoke` |
| AC-004 | ACC-004 | AgentCapability cross-links without duplicating table | Docs | Link present; full tier table absent from AgentCapability | ⬜ Planned |
| AC-005 | ACC-005 | Contract states DEV-055 routing authority | Docs | Explicit routing vs compatibility separation paragraph | ⬜ Planned |
| AC-006 | ACC-006 | Compatibility doc in template inventory | Bats | `--list-template-files` includes `AgToosa_Compatibility_Contract.md` | ⬜ Planned `@smoke` |
| AC-007 | ACC-007 | DEV-055 AM tests still pass unchanged | Regression | `bats -f "DEV-055"` green; no matrix row edits beyond link | ⬜ Planned |
| AC-008 | ACC-008 | DEV-094 filter and evidence boundary | Meta | Test plan filter exists; no all-platform Scenario claim in doc | ⬜ Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| New platform added to config only | ACC-002 | ACC test fails until row added |
| README says "all platforms scenario-tested" | ACC-003 | Grep fails in contract or README cross-check |
| Duplicate tier table pasted into AgentCapability | ACC-004 | Line-count / header grep fails |

## Smoke Set

- `@smoke ACC-001` — tier definitions.
- `@smoke ACC-002` — platform row coverage.
- `@smoke ACC-003` — no false Scenario claims.
- `@smoke ACC-006` — template inventory.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-094|ACC-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED contract | `bats tests/agtoosa.bats -f "DEV-094\|ACC-"` | 1 | `not ok ACC-001: [ -f "$f" ]' failed` (doc missing) |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 2. Documentation kit | `bats tests/agtoosa.bats -f "DEV-094\|ACC-"` | 0 | `ok 1` through `ok 8` |
| Regression | `bats tests/agtoosa.bats -f "DEV-055"` | 0 | AM tests unchanged |
