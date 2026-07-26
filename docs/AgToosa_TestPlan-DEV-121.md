# Test Plan: DEV-121 — Behavioral Conformance Lab

> **Spec:** `docs/archived/spec-DEV-121.md`  
> **Status:** ✅ Pass — BCL-001–BCL-013 green (13/13)  
> **Created:** 2026-07-26  
> **Test prefix:** `BCL`

## Scope

Behavioral Conformance contract, scenario corpus + scenario-run schemas, `agtoosa-scenario-run.sh`, `agtoosa-scenario-verify.sh`, universal `lifecycle-compass-proof` × six platforms, registry/compatibility cross-links, and `lib/config.sh` registration. No live assistant execution in CI. Network-free.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | @smoke |
|----|---------|------------|------|-----------------|--------|
| AC-001 | BCL-001 | Behavioral conformance contract defines runner and claim boundaries | Docs contract | Runner + verifier + forbidden claims | yes |
| AC-002 | BCL-002 | Scenario corpus schema and index validate | Schema | `corpus-v1.json` validates | yes |
| AC-003 | BCL-003 | Scenario-run schema validates pilot fixture JSON | Schema | cursor `scenario-run.json` validates | — |
| AC-004 | BCL-004 | Scenario runner writes scenario-run JSON on fixture | Integration | Runner emits JSON | yes |
| AC-005 | BCL-005 | Scenario verifier passes valid platform fixture | Integration | windsurf fixture exit 0 | yes |
| AC-006 | BCL-006 | Scenario verifier fails on marker mismatch | Security | fail-marker exit 1 | yes |
| AC-007 | BCL-007 | Universal scenario lists six platform fixture trees | Fixture | six platform dirs | yes |
| AC-006 | BCL-008 | Scenario verifier fails on missing required artifact | Integration | fail-missing exit 1 | — |
| AC-008 | BCL-009 | Pack behavioral binding documented in registry trust docs | Link contract | DEV-096/DEV-101 refs | — |
| AC-009 | BCL-010 | Compatibility contract cross-links behavioral corpus | Link contract | BCL cross-link; no false Scenario-tested | — |
| AC-010 | BCL-011 | Provenance doc notes separate proof-graph verify | Docs contract | scenario-run vs proof-verify boundary | — |
| AC-011 | BCL-012 | config.sh registers BCL surfaces | Inventory | contract + runner + verifier in config | — |
| AC-012 | BCL-013 | ACC regression requires scenario corpus pointer language | Regression | pointer language per platform row | — |
| AC-013 | BCL-004 | Pilot scenario-run.json for cursor + claude | Fixture | ≥2 platform run JSON | yes |

## Smoke Set

```bash
bats tests/agtoosa.bats -f "DEV-121|BCL-"
```

Tagged smokes: `@smoke BCL-001`, `@smoke BCL-002`, `@smoke BCL-004`, `@smoke BCL-005`, `@smoke BCL-006`, `@smoke BCL-007`

## GREEN Evidence

`bats tests/agtoosa.bats -f 'DEV-121|BCL-'` → 13/13 exit 0 (2026-07-26)
