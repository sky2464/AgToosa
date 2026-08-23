# Test Plan: DEV-122 — Change-Aware Adaptive Delivery

> **Spec:** `docs/archived/spec-DEV-122.md`  
> **Status:** ✅ Build complete — pending review  
> **Created:** 2026-07-26  
> **Test prefix:** `DIA`

## Scope

Change-Aware Adaptive Delivery contract, drift baseline/report and context-compilation schemas, `git-inventory` provider, `agtoosa-drift-assess.sh`, `agtoosa-context-compile.sh`, measured-error fixtures, Build/Orchestration cross-links, and `lib/config.sh` registration. Network-free; no default strict blocking.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | @smoke |
|----|---------|------------|------|-----------------|--------|
| AC-001 | DIA-001 | Contract defines rigor matrix and claim boundaries | Docs contract | Suggest vs enforce; fixture-only measurement | yes |
| AC-002 | DIA-002 | Drift baseline schema validates fixture | Schema | baseline-v1.json passes | yes |
| AC-003 | DIA-003 | Drift assess emits valid report on unchanged fixture | Integration | added/removed/modified lists correct | yes |
| AC-004 | DIA-004 | Suggested rigor follows impact matrix | Integration | low impact → light rigor | — |
| AC-005 | DIA-005 | Default assess exits 0 on drift | Integration | non-strict mode suggest-only | yes |
| AC-006 | DIA-006 | Strict mode fails on high impact fixture | Integration | `--strict` exit non-zero | — |
| AC-007 | DIA-007 | Measurement block cites fixture cases only | Docs contract | No live accuracy claims | yes |
| AC-008 | DIA-008 | Context compile emits valid JSON | Integration | Required fields present | yes |
| AC-009 | DIA-009 | Provenance cross-link requires separate verify | Link contract | No auto proof-graph pass | — |
| AC-010 | DIA-010 | Build and Orchestration cross-links present | Link contract | Optional pre-build steps | — |
| AC-011 | DIA-011 | config.sh registers DIA surfaces | Inventory | Contract, schemas, scripts | — |
| AC-012 | DIA-012 | Pilot context-compilation validates | E2E | DEV-120 fixture story compiles | yes |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Baseline path contains `..` | DIA-003 | Non-zero unsafe path |
| Default assess on high drift | DIA-005 | Exit 0 without `--strict` |
| Context compile without drift report | DIA-008 | Valid JSON with empty drift summary |
| Scripts perform network I/O | DIA-005 | No curl/wget in bodies |
| Docs claim mandatory drift gate | DIA-001 | Forbidden-claim grep fails |

## Fixtures

| Fixture | Purpose |
|---------|---------|
| `tests/fixtures/drift-assess/baseline-v1.json` | Frozen allowlist baseline |
| `tests/fixtures/drift-assess/unchanged/` | No drift → DIA-003 |
| `tests/fixtures/drift-assess/modified/` | Modified hash → impact + rigor |
| `tests/fixtures/drift-assess/high-impact/` | Strict mode failure → DIA-006 |
| `tests/fixtures/drift-assess/measurement-labels.json` | FP/FN fixture cases → DIA-007 |
| `tests/fixtures/drift-assess/context-compilation-DEV-120.json` | Pilot output → DIA-012 |

## Smoke Set

```bash
bats tests/agtoosa.bats -f "DEV-122|DIA-"
```

Tagged smokes: `@smoke DIA-001`, `@smoke DIA-002`, `@smoke DIA-003`, `@smoke DIA-005`, `@smoke DIA-007`, `@smoke DIA-008`, `@smoke DIA-012`

## RED Evidence

First run during `/agtoosa-build` (pre-implementation): `bats tests/agtoosa.bats -f "DEV-122|DIA-"` — 12 tests not found / failing (expected RED before implementation).

## GREEN Evidence

`bats tests/agtoosa.bats -f "DEV-122|DIA-"` — **12/12 PASS** (2026-07-26 build).

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | ✅ Pass |
| Goal / non-goals / scope aligned | ✅ Pass |
| Must AC → test mapping | ✅ 12/12 |
| Claim boundaries classified | ✅ Pass |
| No TBD placeholders | ✅ Pass |
| Master-Plan SoT preserved | ✅ Pass |
