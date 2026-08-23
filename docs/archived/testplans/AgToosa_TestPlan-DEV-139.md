# Test Plan: DEV-139 — GitHub Issues PM Bridge (Phased B)

| AC | Test ID | Type | Expectation | Smoke |
|----|---------|------|-------------|-------|
| AC-001 | GIS-001 | Unit | `--tracker publish` emits `agtoosa.github-issues-manifest/v1` deterministically from fixture | yes |
| AC-002 | GIS-002 | Unit | Issue titles use `feat:`/`chore:` prefix; no `DEV-` title prefix | yes |
| AC-003 | GIS-003 | Unit | Manifest labels include `agtoosa:DEV-XXX`, `source:agtoosa-sync`, status label | yes |
| AC-004 | GIS-004 | Unit | Upsert key `story_id` stable; HTML comment in body | no |
| AC-005 | GIS-005 | Unit | Shipped active-cycle fixture row → `state: closed` in manifest | no |
| AC-006 | GIS-006 | Unit | `--tracker intake` leaves Master-Plan byte-unchanged | yes |
| AC-007 | GIS-007 | Unit | Intake proposal contains backlog draft row + `/agtoosa-task` hint | no |
| AC-008 | GIS-008 | Unit | README `AGTOOSA-ROADMAP` block round-trip via `--readme` | no |
| AC-009 | GIS-009 | Unit | Unsafe intake body redacted in proposal | no |
| AC-010 | GIS-010 | Docs | Template `agtoosa-issues-sync.yml.example` exists + TrackerSync publish docs | yes |

### Negative cases

| Test ID | Mutation | Expected |
|---------|----------|----------|
| GIS-006 | Intake with credential in body | Redacted; Master-Plan unchanged |
| GIS-002 | Story title containing DEV id | Title still has no leading `DEV-XXX:` prefix |

## RED evidence

```
# Awaiting /agtoosa-build RED phase
```

## GREEN evidence

```
bats tests/agtoosa.bats --filter 'DEV-139 GIS' → 10/10 PASS (2026-07-28)
```
