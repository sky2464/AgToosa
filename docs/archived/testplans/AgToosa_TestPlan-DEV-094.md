# Test Plan: DEV-094 — Assistant Compatibility Contract

> **Spec:** `docs/archived/spec-DEV-094.md`
> **Status:** 🟩 GREEN — Wave 2 build
> **Created:** 2026-07-12
> **Test prefix:** `ACC`

## Scope

Documentation-contract and inventory tests for three-tier compatibility (Install/Render/Scenario), per-platform evidence rows, honest tier labeling, DEV-055 cross-link without merge, config registration, and no false Scenario claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | ACC-001 | Tier definitions are present and distinct | Docs/contract | Doc defines Install-tested, Render-tested, Scenario-tested with evidence rules | ✅ GREEN `@smoke` |
| AC-002 | ACC-002 | Every config platform has a compatibility row | Integration | Row per platform with tier, date, pointer, gaps | ✅ GREEN `@smoke` |
| AC-003 | ACC-003 | No Scenario label without Scenario evidence | Claim boundary | Rows without scenario pointer forbid `Scenario-tested` / `fully supported` | ✅ GREEN `@smoke` |
| AC-004 | ACC-004 | AgentCapability cross-links without duplicating table | Docs | Link present; full tier table absent from AgentCapability | ✅ GREEN |
| AC-005 | ACC-005 | Contract states DEV-055 routing authority | Docs | Explicit routing vs compatibility separation paragraph | ✅ GREEN |
| AC-006 | ACC-006 | Compatibility doc in template inventory | Bats | `--list-template-files` includes `AgToosa_Compatibility_Contract.md` | ✅ GREEN `@smoke` |
| AC-007 | ACC-007 | DEV-055 AM tests still pass unchanged | Regression | Matrix headers intact; AM suite green | ✅ GREEN |
| AC-008 | ACC-008 | DEV-094 filter and evidence boundary | Meta | Test plan filter exists; no all-platform Scenario claim in doc | ✅ GREEN |

## Smoke Set

- `@smoke ACC-001` — tier definitions.
- `@smoke ACC-002` — platform row coverage.
- `@smoke ACC-003` — no false Scenario claims.
- `@smoke ACC-006` — template inventory.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-094|ACC-"`

## RED Evidence

```
RED evidence — 1.1 / 1.2
Command: bats tests/agtoosa.bats -f "DEV-094|ACC-"
Exit code: 1
Failure excerpt: not ok ACC-001: [ -f "$f" ]' failed (AgToosa_Compatibility_Contract.md missing)
```

## GREEN Evidence

```
GREEN evidence — 2.1 / 2.2 / 2.3 / 3.1
Command: bats tests/agtoosa.bats -f "DEV-094|ACC-"
Exit code: 0
Pass excerpt: ok ACC-001–ACC-008

GREEN evidence — ACC-007 regression
Command: bats tests/agtoosa.bats -f "DEV-055"
Exit code: 0
Pass excerpt: AM-001–AM-007 green
```
