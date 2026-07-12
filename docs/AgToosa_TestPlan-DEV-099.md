# Test Plan: DEV-099 — Core vs Optional Pack Boundary

> **Spec:** `docs/archived/spec-DEV-099.md`
> **Status:** ✅ Evidence recorded (build)
> **Created:** 2026-07-12
> **Test prefix:** `CORE`

## Scope

`AgToosa_Core_Contract.md` presence, seven core lifecycle commands, array-derived inventories from `lib/config.sh`, parity tests on drift, enforcement-class honesty, and README discovery link without inventory duplication.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | CORE-001 | Core Lifecycle Command Inventory | Docs contract | Init, Spec, Build, Review, Ship, Verify, Doctor named; packs optional for specialty | Pass `@smoke` |
| AC-002 | CORE-002 | Docs Files Array Parity | Contract/integration | `DOCS_FILES` entries match contract `Docs/` inventory section | Pass `@smoke` |
| AC-003 | CORE-003 | Optional Template Array Parity | Contract/integration | `OPTIONAL_TEMPLATE_FILES` entries match contract optional section | Pass |
| AC-004 | CORE-004 | Context Files Array Parity | Contract/integration | `CONTEXT_FILES` entries match contract context section | Pass |
| AC-005 | CORE-005 | Array Drift Fails Until Doc Update | Negative fixture | Added config path without doc update fails parity test | Pass `@smoke` |
| AC-006 | CORE-006 | Enforcement Class Honesty | Docs contract | Contract distinguishes core, optional, pack, and manual controls | Pass |
| AC-007 | CORE-007 | README Discovery Link | Docs contract | README links to core contract without full inventory copy | Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| New file added to `DOCS_FILES` only | CORE-005 | Parity failure names missing path |
| Contract invents path not in any array | CORE-002 | Parity failure names orphan path |
| README duplicates full `DOCS_FILES` list | CORE-007 | Non-duplication assertion fails |

## Smoke Set

- `@smoke CORE-001` — core lifecycle command inventory.
- `@smoke CORE-002` — `DOCS_FILES` parity.
- `@smoke CORE-005` — drift detection.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-099|CORE-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED parity contract | `bats tests/agtoosa.bats -f "DEV-099\|CORE-"` | 1 | `not ok 1 DEV-099 @smoke CORE-001` — `[ -f "$f" ]' failed` (AgToosa_Core_Contract.md missing); CORE-007 `grep -q 'docs/AgToosa_Core_Contract.md'` failed |

```
1..7
not ok 1 DEV-099 @smoke CORE-001: Core Lifecycle Command Inventory
#   `[ -f "$f" ]' failed
not ok 2 DEV-099 @smoke CORE-002: Docs Files Array Parity
#   `[ -f "$f" ]' failed
not ok 3 DEV-099 CORE-003: Optional Template Array Parity
#   `[ -f "$f" ]' failed
not ok 4 DEV-099 CORE-004: Context Files Array Parity
#   `[ -f "$f" ]' failed
not ok 5 DEV-099 @smoke CORE-005: Array Drift Fails Until Doc Update
#   `[ -f "$doc" ]' failed
not ok 6 DEV-099 CORE-006: Enforcement Class Honesty
#   `[ -f "$f" ]' failed
not ok 7 DEV-099 CORE-007: README Discovery Link
#   `grep -q 'docs/AgToosa_Core_Contract.md' "$readme"' failed
```

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-099"` | 0 | All 7 CORE tests pass; arrays and doc in parity |

```
1..7
ok 1 DEV-099 @smoke CORE-001: Core Lifecycle Command Inventory
ok 2 DEV-099 @smoke CORE-002: Docs Files Array Parity
ok 3 DEV-099 CORE-003: Optional Template Array Parity
ok 4 DEV-099 CORE-004: Context Files Array Parity
ok 5 DEV-099 @smoke CORE-005: Array Drift Fails Until Doc Update
ok 6 DEV-099 CORE-006: Enforcement Class Honesty
ok 7 DEV-099 CORE-007: README Discovery Link
```
