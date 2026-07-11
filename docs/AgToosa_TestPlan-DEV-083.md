# Test Plan: DEV-083 — Voluntary Workflow Metrics and Case Study Kit

> **Spec:** `docs/archived/spec-DEV-083.md`
> **Status:** ⬜ Backlog
> **Test prefix:** MET
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** Not run; this plan contains no metric result, user data, or case-study evidence.

## Coverage Target

Check that the future kit is voluntary and local-only, defines a complete common schema and case-study boundary, covers all six requested measures, installs as documentation, and introduces no collection or reporting path.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | MET-001 | Voluntary Local-Only Boundary | Docs/security | Kit requires opt-in, local source control, redaction/withdrawal, and no hooks, network sender, background analytics, or auto-reporting | Planned — not run `@smoke` |
| AC-002 | Must | MET-002 | Common Metric Schema Completeness | Docs/contract | Every required purpose, population, formula/unit, window, source, exclusion, missing-data, privacy, evidence, limitation, and consent field exists | Planned — not run |
| AC-002 | Must | MET-003 | Evidence-Bounded Case Study Template | Docs/claim boundary | Case-study template separates context, method, evidence, synthetic/observed state, limits, consent, and publication review | Planned — not run `@smoke` |
| AC-003 | Must | MET-004 | Install Success Definition | Docs/contract | Template distinguishes attempts, completion, post-install check, failure stage, platform/version, and retry | Planned — not run `@smoke` |
| AC-004 | Must | MET-005 | Verifier Adoption Definition | Docs/contract | Template distinguishes eligibility, availability, actual runs, mode, result, follow-up, and window | Planned — not run |
| AC-005 | Must | MET-006 | Handoff Import Outcome Definition | Docs/privacy | Template distinguishes export/import outcomes and target without collecting handoff content | Planned — not run |
| AC-006 | Must | MET-007 | Cross-Model Finding State Definition | Docs/safety | Template distinguishes proposed, confirmed, duplicate, rejected, and resolved findings and prohibits individual scoring | Planned — not run |
| AC-007 | Must | MET-008 | Cycle Time Boundary Definition | Docs/contract | Template defines events, pauses, deferred intervals, incomplete cycles, timezone, aggregation, and sample size | Planned — not run |
| AC-008 | Must | MET-009 | Pack Maintenance No-SLA Definition | Docs/claim boundary | Template records population, review age, open items, response state, deprecation, and date without SLA language | Planned — not run |
| AC-001, AC-002 | Must | MET-010 | Metrics Kit Inventory and Mirror Contract | Bats/integration | Canonical kit and case-study template install/update correctly, mirrors align, and only documentation artifacts are added | Planned — not run `@smoke` |

## Planned Validation Commands

These commands are illustrative future commands only; they were not executed while creating this plan.

```bash
bats tests/agtoosa.bats -f "DEV-083"
bats tests/agtoosa.bats -f "MET-"
git diff --check
```

A human privacy and claims review remains required. Contract tests cannot prove that a future user voluntarily consents or interprets a measure correctly.

## Smoke Set

- `MET-001` — Voluntary Local-Only Boundary
- `MET-003` — Evidence-Bounded Case Study Template
- `MET-004` — Install Success Definition
- `MET-010` — Metrics Kit Inventory and Mirror Contract

Smoke status: **Planned — not run**.

## TDD Evidence Placeholders

| Future task group | RED evidence | GREEN evidence |
|-------------------|--------------|----------------|
| 1. Voluntary measurement contract | Not run; no failing output recorded | Not run; no passing output recorded |
| 2. Six metric templates | Not run; no failing output recorded | Not run; no passing output recorded |
| 3. Documentation kit | Not run; no failing output recorded | Not run; no passing output recorded |
| 4. Documentation contract proof | Not run; no failing output recorded | Not run; no passing output recorded |

### RED evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Failure excerpt: Not recorded
- Required future action: add MET contract assertions before creating or wiring the kit.

### GREEN evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Passing excerpt: Not recorded
- Required future action: record exact checks and privacy/claims review only after the complete kit is implemented.

No evidence may be inferred from the existence of this test plan.
