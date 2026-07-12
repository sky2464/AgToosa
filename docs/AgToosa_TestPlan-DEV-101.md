# Test Plan: DEV-101 — Verified vs Community Pack Labeling

> **Spec:** `docs/archived/spec-DEV-101.md`
> **Status:** ⬜ Proposed
> **Created:** 2026-07-12
> **Test prefix:** `TRUST`

## Scope

Registry trust-surface documentation: verified, community, and official pilot labels; allowed and forbidden claims; manifest field mapping; publication-state honesty; install-safety reminder; forbidden marketing phrases.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | TRUST-001 | Pack Class Definitions Present | Docs contract | Verified, community, and official pilot classes defined | Planned `@smoke` |
| AC-002 | TRUST-002 | Allowed and Forbidden Claims | Docs contract | Each class lists allowed and forbidden user-facing claims | Planned |
| AC-003 | TRUST-003 | Manifest Field Mapping | Docs contract | Labels map to existing DEV-053 trust fields only | Planned `@smoke` |
| AC-004 | TRUST-004 | Publication State Machine Preserved | Docs contract | local candidate / submitted / published rules match DEV-080 | Planned |
| AC-005 | TRUST-005 | Install Safety Reminder | Docs contract | Labeling does not bypass preview, consent, or integrity gates | Planned |
| AC-006 | TRUST-006 | Forbidden Marketing Phrases | Negative | Phrases like "security certified" for verified packs fail check | Planned |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Doc says community packs are "maintainer-approved" | TRUST-006 | Forbidden-phrase assertion fails |
| Invented manifest field `verified_by_agtoosa_cloud` | TRUST-003 | Mapping test fails — unknown schema key |
| "Submitted" described as "available in registry" | TRUST-004 | Publication honesty fails |

## Smoke Set

- `@smoke TRUST-001` — pack class definitions.
- `@smoke TRUST-003` — manifest field mapping.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-101|TRUST-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. RED trust vocabulary | `bats tests/agtoosa.bats -f "DEV-101\|TRUST-"` | 1 | Trust surface section missing from `AgToosa_Registry.md` |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 3. Evidence | `bats tests/agtoosa.bats -f "DEV-101\|TRUST-"` | 0 | All TRUST tests pass |
