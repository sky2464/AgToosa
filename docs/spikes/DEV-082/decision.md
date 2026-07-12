# DEV-082 Decision — High-Assurance Signature Mode

> **Story:** DEV-082 · Spike S · Epic DEV-003  
> **Evidence date:** 2026-07-11  
> **Spike evidence only — no production implementation**  
> **Does not ship** fail-closed enforcement or `AGTOOSA_REQUIRE_SIGNATURES`

## Decision

| Field | Value |
|-------|-------|
| **Outcome** | **Defer** |
| **Confidence** | High |
| **Reviewed** | Demand, trust model, synthetic key ops, failure matrix, migration, rollback tabletop |

---

## Rationale

1. **Demand (AC-001):** No representative high-assurance user/org enrolled. Evidence is maintainer roadmap language + ADR-002 pack-count trigger. Per AC-001 failure mode, hypothetical personas are **not** an adoption signal → **Defer**.  
2. **Ecosystem trigger unmet:** ADR-002 says re-evaluate fail-closed when community pack count **>10**; pack count remains near zero.  
3. **Baseline adequate:** DEV-054 soft-warn + SHA-256 fail-closed + verified-flag already provide layered assurance without availability lockout.  
4. **Operability:** Synthetic key lifecycle is operable (Observed), but production custody, dual-control, and expiry policy remain Tabletop/Assumed — insufficient for Adopt.  
5. **Rollback:** Independent recovery material exists in principle (pubkey + SHA-256), but no fail-closed mode exists to roll back from; Adopt would authorize a proposal only after demand + ops mature.  
6. **Defaults:** Any Adopt path must remain **opt-in**; designs that break unsigned installs by default are rejected (AC-005).

---

## Prerequisites before reconsidering Adopt

| # | Prerequisite |
|---|--------------|
| 1 | Named high-assurance adopter(s) with documented surfaces, blocking semantics, and constraints |
| 2 | Community pack count >10 **or** equivalent documented supply-chain incident justifying L4 |
| 3 | Production-ready key ops runbook (generation, custody, rotation, revocation, audit) with dual-control where required — still no private keys in git |
| 4 | Authorized security reviewer sign-off on failure matrix + rollback |
| 5 | Separate approved **implementation** spec (not this spike) before any `AGTOOSA_REQUIRE_SIGNATURES` wiring |

---

## Rejected alternatives

| Alternative | Why rejected now |
|-------------|------------------|
| Adopt + implement flag in this story | Violates AC-007 / spike boundary |
| Silent default-on fail-closed | Violates AC-005 migration safety |
| Replace SHA-256 / verified flag with signatures | Violates layered trust model (AC-002) |

---

## Follow-on

- **No** implementation proposal opened from this spike.  
- Revisit when prerequisites 1–2 fire; then open a new story for an implementation proposal only.  
- Soft-warn default and production surfaces remain unchanged.

## Evidence links

| Artifact | Path |
|----------|------|
| Demand | `docs/spikes/DEV-082/demand.md` |
| Trust model | `docs/spikes/DEV-082/trust-model.md` |
| Key operations | `docs/spikes/DEV-082/key-operations.md` |
| Failure matrix | `docs/spikes/DEV-082/failure-matrix.md` |
| Rollback | `docs/spikes/DEV-082/rollback-runbook.md` |
| Test plan | `docs/AgToosa_TestPlan-DEV-082.md` |

## Claim boundary reminder

Labels in linked artifacts distinguish **Observed**, **Tabletop**, **Assumed**, and **Untested**. This decision does **not** claim production key operations or fail-closed enforcement exist.
