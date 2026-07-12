# Test Plan: DEV-082 — High-Assurance Signature Mode Validation

> **Spec:** `docs/archived/spec-DEV-082.md`
> **Status:** ✅ Evidence recorded (spike — no production implementation)
> **Test prefix:** HSV
> **Created:** 2026-07-11
> **Deepened:** 2026-07-11
> **Execution state:** RED then GREEN executed 2026-07-11; decision **Defer**.

## Coverage Target

Check that the spike validates demand and operations before implementation, preserves the DEV-054 baseline, uses synthetic keys safely, covers failure/migration/rollback, and ends with an honest decision rather than a wired fail-closed mode.

## AC Mapping and Named Tests

| AC | Priority | Test ID | Test name | Type | Planned assertion | Status |
|----|----------|---------|-----------|------|-------------------|--------|
| AC-001 | Must | HSV-001 | Demand and Decision Gate Completeness | Research/contract | Demand records include scenarios, workaround, surfaces, semantics, constraints, sources, and predefined outcome criteria | Pass `@smoke` |
| AC-002 | Must | HSV-002 | Layered Signature Trust Model | Docs/security | SHA-256, registry review, optional soft-warn, and proposed fail-closed policy remain distinct across both surfaces | Pass |
| AC-003 | Must | HSV-003 | Synthetic Key Lifecycle Operations | Security/tabletop | Generation, custody, separation, distribution, rotation, revocation, expiry, recovery, audit, and nonretention are covered | Pass `@smoke` |
| AC-003 | Must | HSV-004 | Private Key Nonretention Boundary | Security/negative | Spike artifacts and repository contain no private or production key material; no wired `AGTOOSA_REQUIRE_SIGNATURES` in production entrypoints | Pass |
| AC-004 | Must | HSV-005 | Fail-Closed Failure Matrix | Security/tabletop | Every required signature, key, tool, offline, cache, and rotation failure has a defined expected outcome | Pass `@smoke` |
| AC-005 | Must | HSV-006 | Existing Artifact Migration Safety | Compatibility | Unsigned and soft-warn artifacts have an explicit opt-in migration with unchanged defaults | Pass |
| AC-006 | Must | HSV-007 | Authorized Rollback and Restoration | Recovery/tabletop | Break-glass authorization, independent recovery material, audit, restoration, and return to safe default are testable | Pass `@smoke` |
| AC-007 | Must | HSV-008 | Require Signatures Pre-implementation Gate | Scope/regression | Decision exists and production surfaces contain no newly wired `AGTOOSA_REQUIRE_SIGNATURES` behavior | Pass |
| AC-008 | Must | HSV-009 | Signature Finding Confidence Labels | Docs/claim boundary | Observed, tabletop, assumed, and untested findings are distinct; no production readiness is claimed | Pass |

## Planned Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-082"
bats tests/agtoosa.bats -f "HSV-"
git diff --check
```

Security review of synthetic key handling and manual review of demand sources and rollback observations remain required; static checks cannot prove them.

## Smoke Set

- `HSV-001` — Demand and Decision Gate Completeness — **Pass**
- `HSV-003` — Synthetic Key Lifecycle Operations — **Pass**
- `HSV-005` — Fail-Closed Failure Matrix — **Pass**
- `HSV-007` — Authorized Rollback and Restoration — **Pass**

Smoke status: **Pass** (2026-07-11).

## TDD Evidence

| Task group | RED evidence | GREEN evidence |
|------------|--------------|----------------|
| 1. Baseline and decision gates | Recorded below | Recorded below |
| 2. Validation inputs | Recorded below | Recorded below |
| 3. Recovery and decision | Recorded below | Recorded below |
| 4. Pre-implementation gate | Recorded below | Recorded below |

### RED evidence — 2026-07-11

```text
Command: bats tests/agtoosa.bats -f "DEV-082"
Exit code: nonzero (9 failed)
Failure excerpt:
  not ok 1 DEV-082 HSV-001: … `[ -f "$f" ]' failed
  not ok 2–9 … spike docs missing under docs/spikes/DEV-082/
```

### GREEN evidence — 2026-07-11

```text
Command: bats tests/agtoosa.bats -f "DEV-082"
Exit code: 0
Passing excerpt:
  1..9
  ok 1–9 DEV-082 HSV-001 … HSV-009
```

### Decision recorded

**Defer** — see `docs/spikes/DEV-082/decision.md`. No `AGTOOSA_REQUIRE_SIGNATURES` wired; soft-warn default unchanged.
