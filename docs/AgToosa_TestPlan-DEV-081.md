# Test Plan: DEV-081 — Optional Local DX Add-on Validation

> **Spec:** `docs/archived/spec-DEV-081.md`
> **Status:** ⬜ Backlog
> **Test prefix:** DXV
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** Not run; this plan contains no research or validation evidence.

## Coverage Target

Check that the future spike uses one shared rubric, evaluates all three candidates independently, records three traceable decisions, and makes no production implementation or shipped-capability claim.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | DXV-001 | Shared Baseline Rubric Completeness | Docs/contract | Rubric covers value, friction, portability, security, maintenance, accessibility, recovery, and fallback | Planned — not run |
| AC-002 | Must | DXV-002 | Thin Wrapper Delegation Boundary | Spike review | Wrapper report evaluates delegation, distribution, updates, parity, and errors without creating a second core | Planned — not run `@smoke` |
| AC-003 | Must | DXV-003 | Editor Extension Trust and Fallback Review | Spike/security | Extension report covers discovery, trust, permissions, updates, accessibility, offline use, uninstall, and CLI fallback | Planned — not run `@smoke` |
| AC-004 | Must | DXV-004 | CI Template Gap Evidence | Spike/security | CI report names provider/use-case gaps, permissions, duplication risk, owner, and copy/generation boundary | Planned — not run `@smoke` |
| AC-005 | Must | DXV-005 | Three Independent DX Decisions | Docs/decision | Wrapper, extension, and CI each receive an independent adopt/defer/reject outcome | Planned — not run `@smoke` |
| AC-005 | Must | DXV-006 | Decision Evidence and Trigger Traceability | Docs/decision | Every outcome cites observations, confidence, costs, risks, and a reconsideration trigger | Planned — not run |
| AC-006 | Must | DXV-007 | Spike Has No Production Implementation | Scope/regression | Spike diff is limited to research/decision artifacts; adopt recommendations point to separate proposals | Planned — not run |
| AC-007 | Must | DXV-008 | Evidence Assumption Claim Separation | Docs/claim boundary | Reports distinguish observations, assumptions, and untested conditions and do not claim shipment | Planned — not run |

## Planned Validation Commands

These commands are illustrative future commands only; they were not executed while creating this plan.

```bash
bats tests/agtoosa.bats -f "DEV-081"
bats tests/agtoosa.bats -f "DXV-"
git diff --check
```

Manual review of cited sources and representative environments remains necessary; static checks alone cannot establish the spike conclusions.

## Smoke Set

- `DXV-002` — Thin Wrapper Delegation Boundary
- `DXV-003` — Editor Extension Trust and Fallback Review
- `DXV-004` — CI Template Gap Evidence
- `DXV-005` — Three Independent DX Decisions

Smoke status: **Planned — not run**.

## TDD Evidence Placeholders

| Future task group | RED evidence | GREEN evidence |
|-------------------|--------------|----------------|
| 1. Evidence contract | Not run; no failing output recorded | Not run; no passing output recorded |
| 2. Candidate evaluations | Not run; no failing output recorded | Not run; no passing output recorded |
| 3. Decisions and review | Not run; no failing output recorded | Not run; no passing output recorded |
| 4. Spike boundary | Not run; no failing output recorded | Not run; no passing output recorded |

### RED evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Failure excerpt: Not recorded
- Required future action: add DXV contract checks before finalizing spike artifacts.

### GREEN evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Passing excerpt: Not recorded
- Required future action: record exact validation and review results only after all three independent decisions exist.

No evidence may be inferred from the existence of this test plan.
