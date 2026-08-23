# Test Plan: DEV-101 — Verified vs Community Pack Labeling

> **Spec:** `docs/archived/spec-DEV-101.md`
> **Status:** 🟩 GREEN — Wave 3 build
> **Created:** 2026-07-12
> **Test prefix:** `TRUST`

## Scope

Registry trust-surface documentation: verified, community, and official pilot labels; allowed and forbidden claims; manifest field mapping; publication-state honesty; install-safety reminder; forbidden marketing phrases.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | TRUST-001 | Pack Class Definitions Present | Docs contract | Verified, community, and official pilot classes defined | ✅ GREEN `@smoke` |
| AC-002 | TRUST-002 | Allowed and Forbidden Claims | Docs contract | Each class lists allowed and forbidden user-facing claims | ✅ GREEN |
| AC-003 | TRUST-003 | Manifest Field Mapping | Docs contract | Labels map to existing DEV-053 trust fields only | ✅ GREEN `@smoke` |
| AC-004 | TRUST-004 | Publication State Machine Preserved | Docs contract | local candidate / submitted / published rules match DEV-080 | ✅ GREEN |
| AC-005 | TRUST-005 | Install Safety Reminder | Docs contract | Labeling does not bypass preview, consent, or integrity gates | ✅ GREEN |
| AC-006 | TRUST-006 | Forbidden Marketing Phrases | Negative | Phrases like "security certified" for verified packs fail check | ✅ GREEN |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Doc says community packs are "maintainer-approved" | TRUST-006 | Forbidden-phrase assertion fails |
| Invented manifest field `verified_by_agtoosa_cloud` | TRUST-003 | Mapping test fails — unknown schema key as authoritative row |
| "Submitted" described as "available in registry" | TRUST-004 | Publication honesty fails |

## Smoke Set

- `@smoke TRUST-001` — pack class definitions.
- `@smoke TRUST-003` — manifest field mapping.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-101|TRUST-"`

## RED Evidence

```
RED evidence — 1.1 / 1.2
Command: bats tests/agtoosa.bats -f "DEV-101|TRUST-"
Exit code: 1
Failure excerpt: not ok TRUST-001…TRUST-006 — `grep -q "## Trust surface" "$f"' failed
(Trust surface section missing from AgToosa_Registry.md)
```

## GREEN Evidence

```
GREEN evidence — 2.1 / 3.1
Command: bats tests/agtoosa.bats -f "DEV-101|TRUST-"
Exit code: 0
Pass excerpt: ok 1–6 TRUST-001–TRUST-006
```
