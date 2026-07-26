# Test Plan: DEV-123 — Guarded Portable Execution

> **Spec:** `docs/archived/spec-DEV-123.md`  
> **Status:** ✅ GREEN — shipped v5.3.39  
> **Created:** 2026-07-26  
> **Test prefix:** `GPE`

## Scope

Guarded Portable Execution contract, execution-capsule and capsule-evidence schemas, `local-guarded` provider, `agtoosa-capsule-pack.sh`, `agtoosa-capsule-verify.sh`, `agtoosa-capsule-export.sh`, policy violation fixtures, Handoff/Orchestration cross-links, and `lib/config.sh` registration. Network-free; no agent launch; no native sandbox claims.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | @smoke |
|----|---------|------------|------|-----------------|--------|
| AC-001 | GPE-001 | Contract defines policy matrix and claim boundaries | Docs contract | Metadata vs enforcement; fixture-only policy checks | yes |
| AC-002 | GPE-002 | Execution capsule schema validates fixture | Schema | capsule-v1.json passes | yes |
| AC-003 | GPE-003 | Capsule pack emits valid manifest on story fixture | Integration | scope, policy, ownership, budgets present | yes |
| AC-004 | GPE-004 | Policy checks cite fixture cases only | Docs contract | No live sandbox claims | yes |
| AC-005 | GPE-005 | Default verify exits 0 on policy warnings | Integration | non-strict mode suggest-only | yes |
| AC-006 | GPE-006 | Strict mode fails on high-severity violation fixture | Integration | `--strict` exit non-zero | — |
| AC-007 | GPE-007 | Capsule export emits handoff-compatible markdown | Integration | return contract + evidence schema fields | yes |
| AC-008 | GPE-008 | Export redacts secret-shaped patterns; proof verify separate | Link contract | No auto proof-graph pass | — |
| AC-009 | GPE-009 | Handoff and Orchestration cross-links present | Link contract | Optional pre-handoff steps | — |
| AC-010 | GPE-010 | Export does not mutate Master-Plan | Integration | Protected paths unchanged | yes |
| AC-011 | GPE-011 | config.sh registers GPE surfaces | Inventory | Contract, schemas, scripts | — |
| AC-012 | GPE-012 | Pilot execution-capsule validates | E2E | DEV-120 fixture story packs | yes |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Capsule scope path contains `..` | GPE-003 | Non-zero unsafe path |
| Default verify on policy warning fixture | GPE-005 | Exit 0 without `--strict` |
| Export with unverified capsule | GPE-007 | Warn or require `--force` per contract |
| Scripts perform network I/O | GPE-005 | No curl/wget in bodies |
| Docs claim native sandbox | GPE-001 | Forbidden-claim grep fails |
| Export attempts Master-Plan write | GPE-010 | Non-zero or no mutation |

## Fixtures

| Fixture | Purpose |
|---------|---------|
| `tests/fixtures/capsule/capsule-v1.json` | Valid minimal execution capsule |
| `tests/fixtures/capsule/policy-violation-high.json` | High-severity violation → GPE-006 |
| `tests/fixtures/capsule/policy-violation-low.json` | Low-severity warning → GPE-005 |
| `tests/fixtures/capsule/secret-shaped-content.txt` | Redaction case → GPE-008 |
| `tests/fixtures/capsule/tampered-hash.json` | Integrity failure → GPE-005 |
| `tests/fixtures/capsule/execution-capsule-DEV-120.json` | Pilot output → GPE-012 |

## Smoke Set

```bash
bats tests/agtoosa.bats -f "DEV-123|GPE-"
```

Tagged smokes: `@smoke GPE-001`, `@smoke GPE-002`, `@smoke GPE-003`, `@smoke GPE-004`, `@smoke GPE-005`, `@smoke GPE-007`, `@smoke GPE-010`, `@smoke GPE-012`

## RED Evidence

First run during `/agtoosa-build` (pre-implementation): `bats tests/agtoosa.bats -f "DEV-123|GPE-"` — 12 tests not found / failing (expected RED before implementation).

## GREEN Evidence

`bats tests/agtoosa.bats -f "DEV-123|GPE-"` — **12/12 PASS** (2026-07-26). Ship regression: `DEV-123 @smoke SR-001` (v5.3.39 pins).

## Spec Quality Analyzer

| Check | Result |
|-------|--------|
| Must ACs testable | ✅ Pass |
| Goal / non-goals / scope aligned | ✅ Pass |
| Must AC → test mapping | ✅ 12/12 |
| Claim boundaries classified | ✅ Pass |
| No TBD placeholders | ✅ Pass |
| Master-Plan SoT preserved | ✅ Pass |
