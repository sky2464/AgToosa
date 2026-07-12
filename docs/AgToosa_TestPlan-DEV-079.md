# Test Plan: DEV-079 — Verifier and CI Adoption Examples

> **Spec:** `docs/archived/spec-DEV-079.md`
> **Status:** 🟨 In Progress — GREEN VCA recorded
> **Created:** 2026-07-11
> **Test prefix:** `VCA`

## Scope

Documentation and checked-in workflow contract coverage for local verifier use, safe GitHub Actions copy-in, honest enforcement states, provider-maintenance policy, operating-context paths, discovery, mirror parity, and gate security. No CI provider is contacted.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | VCA-001 | Generated-project verifier example is complete | Docs contract | `Docs/agtoosa-verify.sh`, strict mode, and exit `0/1/2` meanings are present | ✅ Pass |
| AC-001, AC-005 | VCA-002 | Maintainer verifier example uses lowercase context | Docs contract | Maintainer block uses `docs/` consistently and is separately labeled | ✅ Pass |
| AC-002 | VCA-003 | GitHub gate copy-in is reviewable and non-destructive | Docs/security | Sequence inspects destination, copies explicitly, reviews diff, pushes, and observes a run | ✅ Pass |
| AC-003 | VCA-004 | Adoption states have honest enforcement labels | Claim contract | Local check, uncopied template, and running CI gate are distinct | ✅ Pass |
| AC-004 | VCA-005 | Provider-specific support requires maintained evidence | Policy/docs | Only checked-in, owned, tested provider examples are called copy-ready | ✅ Pass |
| AC-005 | VCA-006 | Command blocks never mix operating-context paths | Regression | Each runnable block is labeled and uses only `Docs/` or only `docs/` | ✅ Pass |
| AC-006 | VCA-007 | Discovery surfaces route to one adoption owner | Link/non-duplication | README, Quickref, and Readiness link without copying the full procedure | ✅ Pass |
| AC-007 | VCA-008 | Maintained gate is immutable-pinned and least privilege | Security/workflow | Action SHAs are pinned; permissions are `contents: read`; no secret/write step exists | ✅ Pass |
| AC-007 | VCA-009 | Gate mirrors fail closed and remain identical | Mirror/integration | Template/docs examples match, preserve verifier exit, and fail when verifier is absent | ✅ Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Existing `.github/workflows/agtoosa-gate.yml` would be overwritten | VCA-003 | Guide requires stop/inspect instead of silent overwrite |
| Guide calls the shipped `.example` CI-enforced before copy | VCA-004 | Claim-boundary test fails |
| A GitLab snippet appears without a checked-in maintained artifact | VCA-005 | Provider-policy test fails |
| One command uses `Docs/` and `docs/` alternatives without context | VCA-006 | Path-context test fails |
| Checkout uses a floating tag or workflow requests write access | VCA-008 | Gate-security test fails |
| Missing verifier returns success | VCA-009 | Fail-closed contract test fails |

## Smoke Set

- `@smoke VCA-003` — safe manual gate copy-in.
- `@smoke VCA-004` — honest local/template/CI labels.
- `@smoke VCA-008` — pinned least-privilege maintained gate.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-079|VCA-"`

## RED Evidence — Recorded

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Adoption contract tests | `bats tests/agtoosa.bats -f '^DEV-079'` | 1 | VCA-001–007: `[ -f "$guide" ]` failed (guide missing); VCA-009: `grep -qiE 'inspect'` failed on gate comments; VCA-008 already green |
| 2. Canonical adoption guide | `bats tests/agtoosa.bats -f '^DEV-079'` | 1 | Same missing-guide failures for VCA-001–006 |
| 3. Maintained gate and boundary surfaces | `bats tests/agtoosa.bats -f '^DEV-079'` | 1 | VCA-009 missing inspect/review comments before gate header update |
| 4. Discovery without procedural duplication | `bats tests/agtoosa.bats -f '^DEV-079'` | 1 | VCA-007: guide path absent from README/Quickref/Readiness |
| 5. Evidence | `bats tests/agtoosa.bats -f '^DEV-079'` | 1 | Pre-implementation RED baseline |

## GREEN Evidence — Recorded

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 1. Adoption contract tests | `bats tests/agtoosa.bats -f '^DEV-079'` | 0 | `1..9` / all `ok` (VCA-001–VCA-009) |
| 2. Canonical adoption guide | `bats tests/agtoosa.bats -f '^DEV-079'` | 0 | VCA-001–006 pass against `docs/examples/verifier-ci-adoption.md` |
| 3. Maintained gate and boundary surfaces | `bats tests/agtoosa.bats -f '^DEV-079'` | 0 | VCA-004, VCA-008, VCA-009 pass; gate mirrors `diff` identical |
| 4. Discovery without procedural duplication | `bats tests/agtoosa.bats -f '^DEV-079'` | 0 | VCA-005–007 pass |
| 5. Evidence | `bats tests/agtoosa.bats -f '^DEV-079'` | 0 | `ok 1` … `ok 9` |

Focused GREEN run: 2026-07-12 — `bats tests/agtoosa.bats -f '^DEV-079'` → exit 0, 9/9 pass.
