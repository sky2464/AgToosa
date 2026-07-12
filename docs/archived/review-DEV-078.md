# Review: DEV-078 — First-15-Minutes Maintenance Gate

> **Story ID:** DEV-078
> **Reviewed:** 2026-07-11
> **Verdict:** ✅ PASS

## Summary

DEV-078 adds a deterministic first-15 maintenance gate to `scripts/check-launch-readiness.sh`: canonical `vX.Y.Z` pins are derived from `AGTOOSA_VERSION`, scoped release pins and relative proof links are validated read-only, proof-repository URLs are normalized across README and proof docs, and private mode exits before any `curl` calls. Fixture-based F15-001–F15-008 bats cover all six Must ACs; scoped doc pins were repaired to `v5.3.7`.

## Validation

| Check | Command | Exit | Result |
|---|---|---|---|
| DEV-078 F15 suite | `bats tests/agtoosa.bats -f "DEV-078"` | 0 | ✅ 8/8 |
| Maintainer verifier | `bash agtoosa.sh --verify .` | 0 | ✅ PASS (27 pass, 5 warn) |
| Spec approval | `docs/archived/spec-DEV-078.md` | — | ✅ `## ✅ Spec Approved` |
| AC coverage (Must) | AC-001–AC-006 | — | ✅ F15-001–F15-008 |
| STRIDE threat model | spec §2.3 | — | ✅ Present |
| TDD evidence | `docs/AgToosa_TestPlan-DEV-078.md` | — | ✅ RED then GREEN recorded |
| Version parity | `agtoosa.sh` / scoped docs | — | ✅ `5.3.7` / `v5.3.7` aligned |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | STRIDE mitigations hold: version truth from `agtoosa.sh` only; markdown parsed without evaluation; private mode performs no HTTP (F15-006 curl shim); read-only gate (F15-008) | Accepted |
| 🟢 Passed | Engineering Manager | `check-launch-readiness.sh` 264 lines; scope limited to checker, two proof docs, README proof link, bats; maintenance runs before private/public split (F15-007) | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: stale scoped pins and broken proof links fail with file + observed + expected; no onboarding flow changes | Accepted |
| 🟢 Passed | QA Lead | All Must ACs covered; smoke F15-001/F15-003/F15-006 green; RED→GREEN cycle documented | Accepted |
| 🟡 Warning | Engineering Manager | `check_scoped_release_pin` accepts unused `label` parameter — harmless but could be removed in a future cleanup | Accepted |
| 🟡 Warning | QA Lead | F15-007 asserts structural ordering via line-number grep rather than exercising public-mode HTTP — sufficient regression guard given network-dependent public checks remain out of deterministic scope | Accepted |

## Goal Contract Alignment

| Field | Status |
|---|---|
| Goal — fail on stale release pins / proof links | ✅ `run_first15_maintenance_gate` accumulates failures and exits non-zero |
| User outcome — discover drift before release | ✅ Actionable `not ok` lines name file, observed, and expected values |
| Success condition — private deterministic checks | ✅ F15-001–F15-006 green on current repo |
| Proof / evidence | ✅ F15 fixture RED/GREEN in test plan; review validation table above |
| Non-goals — no new walkthrough, no auto rewrites | ✅ Doc step order unchanged (F15-008); no write paths in checker |

## Cross-Model Review

| Field | Value |
|---|---|
| Tier | **Standard** — routine Chore; Must ACs are documentation maintenance, not auth/registry/secrets surfaces |
| Reviewer identity | Orchestrator (Composer) — virtual personas sequential |
| Model/platform | Cursor / Composer 2.5 |
| Outcome | **skipped** (Standard tier optional) |
| Skip rationale | Chore XS with scoped read-only bash checks; threat model is defensive depth only; four virtual personas completed with terminal evidence (bats 0, verifier 0); no independent second-model lane delegated |

### Cross-model evidence: orchestrator

- **Reviewer identity:** Review orchestrator (virtual personas)
- **Model/platform:** Composer 2.5 / Cursor
- **Findings:** No additional issues beyond virtual persona table; implementation matches spec scoped-pin boundary (README install pins outside gate by design)
- **Files read:** `scripts/check-launch-readiness.sh`, `docs/examples/first-15-minutes.md`, `docs/examples/public-launch-proof.md`, `tests/agtoosa.bats` (DEV-078 section), `docs/archived/spec-DEV-078.md`
- **Commands:** `bats tests/agtoosa.bats -f "DEV-078"` (0); `bash agtoosa.sh --verify .` (0)
- **Warnings/errors:** Verifier WARN on missing `### Wave Plan` in spec (pre-existing pattern; spec has `### 3.2 Wave Plan`)
- **Recommendations:** Proceed to ship as PATCH+1
- **Spec sections affected:** Goal Contract, ACs, Architecture, Threat model, Test plan
- **Confidence tier:** virtual-persona-only

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 2  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-078 as **v5.3.8** (PATCH+1 per ADR-005).
