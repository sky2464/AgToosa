# Review: DEV-113 — Cursor Intake Hardening + Fixture Parity

> **Story:** DEV-113  
> **Review date:** 2026-07-12  
> **Tier:** Standard (tests + template docs; no auth/secrets Must ACs)  
> **Outcome:** ✅ PASS  
> **Suggested release:** PATCH **5.3.24 → 5.3.25** (ADR-005 patch-first)

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 3 (accepted) |
| 🟢 Passed | 4 personas |

**Ship recommendation:** PASS.

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Standard |
| Outcome | skipped |
| Skip rationale | Docs + bats-only chore; virtual personas + focused bats sufficient per `docs/AgToosa_CrossModelReview.md` |

## Persona Summary

| Persona | 🔴 | 🟡 | 🟢 |
|---------|----|----|-----|
| Security Officer | 0 | 0 | 4 |
| Engineering Manager | 0 | 2 | 6 |
| CEO / Product Owner | 0 | 0 | 8 |
| QA Lead | 0 | 1 | 7 |

## Findings

| ID | Sev | Persona | Finding | Disposition |
|----|-----|---------|---------|-------------|
| R-001 | 🟡 | EM | `CIT-003` asserts fixture **source** (`grep` in script) not runtime install — weaker than AC-002 wording | **Accepted** — FIX-001 exercises full fixture path end-to-end; CIT-003 guards script regression |
| R-002 | 🟡 | EM | PS1 install tests (`DEV-033`, `DEV-074`) still `rm -rf` repo `ship/`; `agtoosa.ps1` does not honor `AGTOOSA_SHIP_DIR` | **Accepted** — out of scope v1; bash isolation fixes primary flake vector; PS1 parity is separate story |
| R-003 | 🟡 | QA | Test plan lists **CIT-001** alias; only CIT-002–004 implemented | **Accepted** — CIT-001 = FIX-001 by design; update test plan label optional at ship |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Pass — CI now runs `cursor-intake-fixture.sh`; entry-point parity closed |
| User outcome | 🟢 Pass — maintainer dogfood path = CI path; ship bats use isolated staging |
| Success condition | 🟢 Pass — FIX/CIT/NLM green; 950×3 full bats (build evidence) |
| Proof / evidence | 🟢 Pass — `docs/AgToosa_TestPlan-DEV-113.md` GREEN block |
| Non-goals | 🟢 Pass — no 19-command mirror; no runtime enforcer |

## AC Coverage (Must)

| AC | Test(s) | Status |
|----|---------|--------|
| AC-001 | FIX-001 | 🟢 |
| AC-002 | FIX-001 | 🟢 |
| AC-003 | CIT-004 | 🟢 |
| AC-004 | ship tests + `setup()` `AGTOOSA_SHIP_DIR` | 🟢 |
| AC-005 | build: full bats × 3 | 🟢 |
| AC-006 | CIT-002 | 🟢 |
| AC-007 | CIT-002–004, NLM-001–006 | 🟢 |
| AC-008 (Should) | `docs/agtoosa-maintainer.md` FIX-001 note | 🟢 |

## Security

Self-target guard on fixture mirrors `agtoosa.sh`; no new trust boundaries; no secrets or external APIs. STRIDE from spec §2.3 satisfied.

## Terminal Evidence — QA

```bash
bats tests/agtoosa.bats -f "FIX-001|CIT-|NLM-|declining copy|ship/ is cleaned"
# 14/14 PASS (2026-07-12 review re-run)

# Build-phase stability (AC-005)
for i in 1 2 3; do bats tests/agtoosa.bats || exit 1; done
# 950/950 PASS × 3 (2026-07-12 build)
```

## Scope Check

Changes confined to spec §2.4: `tests/agtoosa.bats`, `template/CLAUDE.md`, `docs/agtoosa-maintainer.md`, tracking docs. No generator logic changes beyond version pins already at 5.3.25 in working tree (ship will reconcile).
