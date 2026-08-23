# Test Plan: DEV-097 — Framework Supply-Chain Threat Model

> **Spec:** `docs/archived/spec-DEV-097.md`
> **Status:** 🟩 GREEN — Wave 2 build
> **Created:** 2026-07-12
> **Test prefix:** `FST`

## Scope

Documentation-contract tests for framework-level supply-chain threat model: required attack surfaces, STRIDE mapping, pack-injection cross-link without duplication, honest DEV-054 signing boundary, security README index, and forbidden fail-closed claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | FST-001 | Framework doc lists required attack surfaces | Docs/contract | Install chain, releases, catalog/registry, generator output, CI publish sections exist | ✅ GREEN `@smoke` |
| AC-002 | FST-002 | STRIDE table maps mitigations and residual risk | Docs/contract | Each STRIDE row has mitigation or explicit residual risk | ✅ GREEN |
| AC-003 | FST-003 | Pack injection cross-link without full duplicate | Docs | Link to `template-injection-threat-model.md`; AV catalog not duplicated verbatim | ✅ GREEN `@smoke` |
| AC-004 | FST-004 | Signing described as optional soft-warn only | Security/negative | No `fail-closed`, `blocks install`, or cosign enforcement claims | ✅ GREEN `@smoke` |
| AC-005 | FST-005 | Security README indexes both models | Docs | README lists framework + pack models with scope summaries | ✅ GREEN |
| AC-006 | FST-006 | DEV-097 filter and review pointer | Meta | Bats filter exists; spec references manual security review | ✅ GREEN |

## Smoke Set

- `@smoke FST-001` — attack surfaces present.
- `@smoke FST-003` — cross-link boundary.
- `@smoke FST-004` — no false signing enforcement claims.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-097|FST-"`

## RED Evidence

```
RED evidence — 1.1 / 1.2
Command: bats tests/agtoosa.bats -f "DEV-097|FST-"
Exit code: 1
Failure excerpt: not ok FST-001: [ -f "$f" ]' failed (framework-supply-chain-threat-model.md missing)
```

## GREEN Evidence

```
GREEN evidence — 2.1 / 2.2 / 3.1
Command: bats tests/agtoosa.bats -f "DEV-097|FST-"
Exit code: 0
Pass excerpt: ok 1–6 FST-001–FST-006
```
