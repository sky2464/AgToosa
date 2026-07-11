# Test Plan: DEV-082 — High-Assurance Signature Mode Validation

> **Spec:** `docs/archived/spec-DEV-082.md`
> **Status:** ⬜ Backlog
> **Test prefix:** HSV
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** Not run; this plan contains no demand, key-operation, rollback, or signature evidence.

## Coverage Target

Check that the future spike validates demand and operations before implementation, preserves the DEV-054 baseline, uses synthetic keys safely, covers failure/migration/rollback, and ends with an honest decision rather than a wired fail-closed mode.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | HSV-001 | Demand and Decision Gate Completeness | Research/contract | Demand records include scenarios, workaround, surfaces, semantics, constraints, sources, and predefined outcome criteria | Planned — not run `@smoke` |
| AC-002 | Must | HSV-002 | Layered Signature Trust Model | Docs/security | SHA-256, registry review, optional soft-warn, and proposed fail-closed policy remain distinct across both surfaces | Planned — not run |
| AC-003 | Must | HSV-003 | Synthetic Key Lifecycle Operations | Security/tabletop | Generation, custody, separation, distribution, rotation, revocation, expiry, recovery, audit, and nonretention are covered | Planned — not run `@smoke` |
| AC-003 | Must | HSV-004 | Private Key Nonretention Boundary | Security/negative | Spike artifacts and repository contain no private or production key material | Planned — not run |
| AC-004 | Must | HSV-005 | Fail-Closed Failure Matrix | Security/tabletop | Every required signature, key, tool, offline, cache, and rotation failure has a defined expected outcome | Planned — not run `@smoke` |
| AC-005 | Must | HSV-006 | Existing Artifact Migration Safety | Compatibility | Unsigned and soft-warn artifacts have an explicit opt-in migration with unchanged defaults | Planned — not run |
| AC-006 | Must | HSV-007 | Authorized Rollback and Restoration | Recovery/tabletop | Break-glass authorization, independent recovery material, audit, restoration, and return to safe default are testable | Planned — not run `@smoke` |
| AC-007 | Must | HSV-008 | Require Signatures Pre-implementation Gate | Scope/regression | Decision exists and production surfaces contain no newly wired `AGTOOSA_REQUIRE_SIGNATURES` behavior | Planned — not run |
| AC-008 | Must | HSV-009 | Signature Finding Confidence Labels | Docs/claim boundary | Observed, tabletop, assumed, and untested findings are distinct; no production readiness is claimed | Planned — not run |

## Planned Validation Commands

These commands are illustrative future commands only; they were not executed while creating this plan.

```bash
bats tests/agtoosa.bats -f "DEV-082"
bats tests/agtoosa.bats -f "HSV-"
git diff --check
```

Security review of synthetic key handling and manual review of demand sources and rollback observations remain required; static checks cannot prove them.

## Smoke Set

- `HSV-001` — Demand and Decision Gate Completeness
- `HSV-003` — Synthetic Key Lifecycle Operations
- `HSV-005` — Fail-Closed Failure Matrix
- `HSV-007` — Authorized Rollback and Restoration

Smoke status: **Planned — not run**.

## TDD Evidence Placeholders

| Future task group | RED evidence | GREEN evidence |
|-------------------|--------------|----------------|
| 1. Baseline and decision gates | Not run; no failing output recorded | Not run; no passing output recorded |
| 2. Validation inputs | Not run; no failing output recorded | Not run; no passing output recorded |
| 3. Recovery and decision | Not run; no failing output recorded | Not run; no passing output recorded |
| 4. Pre-implementation gate | Not run; no failing output recorded | Not run; no passing output recorded |

### RED evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Failure excerpt: Not recorded
- Required future action: add HSV contract checks before finalizing spike findings.

### GREEN evidence — unexecuted

- Command: Not run
- Exit code: Not recorded
- Passing excerpt: Not recorded
- Required future action: record exact checks and reviewed observations only after the complete decision package exists.

No evidence may be inferred from the existence of this test plan.
