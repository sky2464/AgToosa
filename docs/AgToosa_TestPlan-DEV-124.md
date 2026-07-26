# Test Plan: DEV-124 — Cross-Framework Interchange

> **Spec:** `docs/archived/spec-DEV-124.md`  
> **Status:** ✅ GREEN — shipped v5.3.40  
> **Created:** 2026-07-26  
> **Test prefix:** `CFI`

## Scope

Cross-Framework Interchange contract, interchange-manifest and interchange-loss-report schemas, four fixture-based providers (Spec Kit, OpenSpec, BMAD, Kiro-style), `agtoosa-interchange-export.sh`, `agtoosa-interchange-import.sh`, `agtoosa-interchange-assess.sh`, loss-report fixtures, Import/Spec cross-links, and `lib/config.sh` registration. Network-free; no live framework installs; no perfect round-trip claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | @smoke |
|----|---------|------------|------|-----------------|--------|
| AC-001 | CFI-001 | Contract defines manifest, loss-report, and authority boundaries | Docs contract | Derived interchange vs Master-Plan SoT; fixture-only loss semantics | yes |
| AC-002 | CFI-002 | Interchange manifest schema validates fixture | Schema | `manifest-v1.json` passes | yes |
| AC-003 | CFI-003 | Export emits manifest and framework artifact on story fixture | Integration | `story_id`, `source_ids`, target artifact present; no network I/O | yes |
| AC-004 | CFI-004 | Import emits manifest and loss report on framework fixture | Integration | Both schemas validate; source IDs preserved | yes |
| AC-005 | CFI-005 | Loss report records unmappable fields with severity | Integration | Fixture-labeled cases only; no perfect round-trip language | yes |
| AC-006 | CFI-006 | Default assess exits 0 on low-severity loss warnings | Integration | non-strict mode suggest-only | yes |
| AC-007 | CFI-007 | Strict mode fails on high-severity loss fixture | Integration | `--strict` exit non-zero | — |
| AC-008 | CFI-008 | Export proof pointer requires separate verify; no auto valid | Link contract | No auto proof-graph pass | — |
| AC-009 | CFI-009 | Import and Spec cross-links present | Link contract | Optional pre-import/export steps; not verifier gates | — |
| AC-010 | CFI-010 | Interchange scripts do not mutate Master-Plan | Integration | Protected paths unchanged | yes |
| AC-011 | CFI-011 | config.sh registers CFI surfaces | Inventory | Contract, schemas, scripts, fixtures | — |
| AC-012 | CFI-012 | Pilot interchange manifest validates | E2E | DEV-120 fixture story exports | yes |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Fixture path contains `..` | CFI-003 | Non-zero unsafe path |
| Default assess on low-severity loss fixture | CFI-006 | Exit 0 without `--strict` |
| Import with high-severity authority gap | CFI-007 | Non-zero with `--strict` only |
| Scripts perform network I/O | CFI-006 | No curl/wget in bodies |
| Docs claim perfect round-trip | CFI-001 | Forbidden-claim grep fails |
| Export attempts Master-Plan write | CFI-010 | Non-zero or no mutation |
| Broken proof graph on export | CFI-008 | Export does not mark graph valid |

## Fixtures

| Fixture | Purpose |
|---------|---------|
| `tests/fixtures/interchange/manifest-v1.json` | Valid minimal interchange manifest → CFI-002 |
| `tests/fixtures/interchange/speckit/minimal.json` | Spec Kit representative → CFI-003, CFI-004 |
| `tests/fixtures/interchange/openspec/minimal.json` | OpenSpec representative → CFI-004 |
| `tests/fixtures/interchange/bmad/minimal.json` | BMAD representative → CFI-004 |
| `tests/fixtures/interchange/kiro/minimal.json` | Kiro-style representative → CFI-004 |
| `tests/fixtures/interchange/loss-low.json` | Low-severity loss → CFI-006 |
| `tests/fixtures/interchange/loss-high.json` | High-severity loss → CFI-007 |
| `tests/fixtures/interchange/interchange-manifest-DEV-120.json` | Pilot output → CFI-012 |

## Smoke Set

```bash
bats tests/agtoosa.bats -f "DEV-124|CFI-"
```

Tagged smokes: `@smoke CFI-001`, `@smoke CFI-002`, `@smoke CFI-003`, `@smoke CFI-004`, `@smoke CFI-005`, `@smoke CFI-006`, `@smoke CFI-010`, `@smoke CFI-012`

## RED Evidence

First run during `/agtoosa-build` (pre-implementation): `bats tests/agtoosa.bats -f "DEV-124|CFI-"` — 12 tests not found / failing (expected RED before implementation).

## GREEN Evidence

`bats tests/agtoosa.bats -f "DEV-124|CFI-"` — **12/12 PASS** (2026-07-26). Ship regression: `DEV-124 @smoke SR-001` (v5.3.40 pins).

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | ✅ Pass |
| Goal / non-goals / scope aligned | ✅ Pass |
| Must AC → test mapping | ✅ 12/12 |
| Claim boundaries classified | ✅ Pass |
| No TBD placeholders | ✅ Pass |
| Master-Plan SoT preserved | ✅ Pass |
