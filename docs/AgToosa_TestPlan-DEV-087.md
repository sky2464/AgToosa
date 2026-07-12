# Test Plan: DEV-087 — Delivery Evidence Contract + Profiles

> **Spec:** `docs/archived/spec-DEV-087.md`
> **Status:** ✅ Pass — DEC-001–DEC-009 green
> **Created:** 2026-07-12
> **Test prefix:** `DEC`

## Scope

Documentation, example YAML, config index, schema-only checker, `lib/config.sh` registration, and cross-link coverage. No Gate 7 verifier enforcement (DEV-089). Terminal Evidence Contract must remain unchanged in purpose.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | DEC-001 | Delivery contract defines assurance taxonomy | Docs contract | Guided, Evidenced, Enforced levels with examples | ✅ Pass |
| AC-002 | DEC-002 | Standard security-sensitive and release profiles documented | Docs contract | Three profile names with required artifact classes | ✅ Pass |
| AC-003 | DEC-003 | evidence.yml.example matches contract | Fixture/YAML | Example parses; required keys documented | ✅ Pass |
| AC-004 | DEC-004 | .agtoosa README indexes policy and evidence configs | Docs contract | policy.yaml + evidence.yml purposes; Gate 6→7→lifecycle order | ✅ Pass |
| AC-005 | DEC-005 | Schema checker accepts valid YAML | Integration | Valid fixture exits 0; invalid fixture exits non-zero | ✅ Pass |
| AC-005 | DEC-006 | Schema checker does not claim full compliance | Claim contract | Output states schema-only; no artifact existence assertions | ✅ Pass |
| AC-006 | DEC-007 | Terminal Evidence cross-link preserved | Link/non-duplication | Agent.md links Delivery contract; Terminal section intact | ✅ Pass |
| AC-007, AC-008 | DEC-008 | Config registration and enforcement labels | Inventory | `lib/config.sh` lists contract, example, index, checker | ✅ Pass |
| AC-009 | DEC-009 | Evidence ledger cross-link present | Link contract | `AgToosa_Evidence.md` references delivery profiles | ✅ Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Unknown profile key in evidence.yml | DEC-005 | Non-zero with actionable schema error |
| Missing `profiles` root key | DEC-005 | Non-zero exit |
| Contract doc titled `AgToosa_Evidence_Contract.md` | DEC-001 | Wrong title fails inventory test |
| Config index omits Gate 7 deferral to DEV-089 | DEC-004 | Gate order test fails |
| Checker script validates artifact files on disk | DEC-006 | Claim-boundary test fails |

## Smoke Set

- `@smoke DEC-001` — assurance taxonomy present.
- `@smoke DEC-003` — example YAML valid.
- `@smoke DEC-005` — schema checker happy path.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-087|DEC-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Contract and schema RED coverage | `bats tests/agtoosa.bats -f "DEV-087\|DEC-"` | 1 (pre-implement) | `not ok … DEC-001` / missing `AgToosa_Delivery_Evidence_Contract.md` before surfaces landed |
| 2. Delivery Evidence Contract surfaces | `bats tests/agtoosa.bats -f "DEC-001\|DEC-002\|DEC-003\|DEC-004\|DEC-005\|DEC-006"` | 1 (partial) | DEC-004 failed until README gate-order one-liner: `grep -qiE "policy \(Gate 6\).*evidence profile \(Gate 7|…"` |
| 3. Wiring and registration | `bats tests/agtoosa.bats -f "DEC-007\|DEC-008\|DEC-009"` | — | Covered in full suite after wiring |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-087\|DEC-"` | 1 | Intermediate: `not ok 4 DEV-087 DEC-004` (gate-order grep) |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Contract and schema RED coverage | `bats tests/agtoosa.bats -f "DEV-087\|DEC-"` | 0 | `ok 1 DEV-087 DEC-001` … `ok 9 DEV-087 DEC-009` / `1..9` |
| 2. Delivery Evidence Contract surfaces | `bats tests/agtoosa.bats -f "DEC-001\|DEC-002\|DEC-003\|DEC-004\|DEC-005\|DEC-006"` | 0 | All six ok |
| 3. Wiring and registration | `bats tests/agtoosa.bats -f "DEC-007\|DEC-008\|DEC-009"` | 0 | `ok … DEC-007` `DEC-008` `DEC-009` |
| 4. Evidence | `bats tests/agtoosa.bats -f "DEV-087\|DEC-"` | 0 | Full excerpt below |

```
1..9
ok 1 DEV-087 DEC-001: Delivery contract defines assurance taxonomy
ok 2 DEV-087 DEC-002: Standard security-sensitive and release profiles documented
ok 3 DEV-087 DEC-003: evidence.yml.example matches contract
ok 4 DEV-087 DEC-004: .agtoosa README indexes policy and evidence configs
ok 5 DEV-087 DEC-005: Schema checker accepts valid YAML and rejects invalid
ok 6 DEV-087 DEC-006: Schema checker does not claim full compliance
ok 7 DEV-087 DEC-007: Terminal Evidence cross-link preserved
ok 8 DEV-087 DEC-008: Config registration and enforcement labels
ok 9 DEV-087 DEC-009: Evidence ledger cross-link present
```
