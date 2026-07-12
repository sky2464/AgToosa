# Test Plan: DEV-097 — Framework Supply-Chain Threat Model

> **Spec:** `docs/archived/spec-DEV-097.md`
> **Status:** 🟦 Planned — Rev4 Wave 2
> **Created:** 2026-07-12
> **Test prefix:** `FST`

## Scope

Documentation-contract tests for framework-level supply-chain threat model: required attack surfaces, STRIDE mapping, pack-injection cross-link without duplication, honest DEV-054 signing boundary, security README index, and forbidden fail-closed claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | FST-001 | Framework doc lists required attack surfaces | Docs/contract | Install chain, releases, catalog/registry, generator output, CI publish sections exist | ⬜ Planned `@smoke` |
| AC-002 | FST-002 | STRIDE table maps mitigations and residual risk | Docs/contract | Each STRIDE row has mitigation or explicit residual risk | ⬜ Planned |
| AC-003 | FST-003 | Pack injection cross-link without full duplicate | Docs | Link to `template-injection-threat-model.md`; AV catalog not duplicated verbatim | ⬜ Planned `@smoke` |
| AC-004 | FST-004 | Signing described as optional soft-warn only | Security/negative | No `fail-closed`, `blocks install`, or cosign enforcement claims | ⬜ Planned `@smoke` |
| AC-005 | FST-005 | Security README indexes both models | Docs | README lists framework + pack models with scope summaries | ⬜ Planned |
| AC-006 | FST-006 | DEV-097 filter and review pointer | Meta | Bats filter exists; spec references manual security review | ⬜ Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Doc claims SHA-256 prevents malicious pack author | FST-002 | Residual risk section states author-trust boundary |
| Framework doc copies AV-1..AV-3 verbatim | FST-003 | Duplicate-line threshold test fails |
| README missing framework entry | FST-005 | Grep fails |

## Smoke Set

- `@smoke FST-001` — attack surfaces present.
- `@smoke FST-003` — cross-link boundary.
- `@smoke FST-004` — no false signing enforcement claims.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-097|FST-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED doc contract | `bats tests/agtoosa.bats -f "DEV-097\|FST-"` | 1 | `not ok FST-001: framework-supply-chain-threat-model.md missing` |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 2. Author threat model | `bats tests/agtoosa.bats -f "DEV-097\|FST-"` | 0 | `ok 1` through `ok 6` |
| Review | Manual security doc review | — | Recorded in evidence at ship |
