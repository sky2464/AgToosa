# Review: DEV-084 — Open-Source Sustainability and Support Boundary

> **Story:** DEV-084  
> **Epic:** DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Estimate:** XS  
> **Date:** 2026-07-11  
> **Verdict:** ✅ PASS  
> **Suggested release:** PATCH+1 → **5.3.9** (chore / disclosure alignment; no breaking change)

## Summary

Public funding/support/security/contribution surfaces now share one canonical boundary in `.github/SUPPORT.md`: voluntary Sponsors (no entitlements), best-effort community support (no SLA), private vulnerability routing, sponsored-content disclosure, optional consulting as a separate agreement, and ungated open-source features. OSS bats OSS-001–OSS-007 green; live GitHub Sponsors account-control confirmation remains `[manual-deferred: 2026-07-11]`.

| Persona | 🔴 Critical | 🟡 Warning | 🟢 Passed |
|---------|-------------|------------|-----------|
| Security Officer | 0 | 1 | 7 |
| Engineering Manager | 0 | 2 | 5 |
| CEO / Product Owner | 0 | 0 | 7 |
| QA Lead | 0 | 2 | 8 |
| **Unresolved Critical** | **0** | — | — |

**Master-Plan note:** Per enrollment instruction, `docs/Master-Plan.md` was **not** edited during this review (status / Update Log left unchanged).

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Standard — chore/docs disclosure; STRIDE is claim-boundary focused; no auth/registry/secrets implementation |
| Reviewer identity | — |
| Model/platform | — |
| Outcome | skipped |
| Skip rationale | Standard-tier docs chore; four virtual personas + OSS contract bats + verifier sufficient; no production trust-boundary code changed |

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟡 | Security | `curl -sI https://github.com/sponsors/sky2464` → HTTP 302 to profile (`/sky2464`); Sponsors enablement / account control not proven live | **Accepted** — OSS-007 `[manual-deferred: 2026-07-11]`; static metadata in `FUNDING.yml` + `SUPPORT.md` consistent (`sky2464`) |
| 🟢 | Security | STRIDE mitigations reflected: one official destination, private security route, no entitlement/SLA language, no feature gates | Pass |
| 🟢 | Security | `SECURITY.md` removed unsupported fixed-time acknowledgement; intake is best-effort / non-SLA | Pass |
| 🟢 | Security | Vulns routed private only (`security@agtoosa.dev` / advisory); public issues prohibited | Pass |
| 🟢 | Security | No secrets, tokens, or payment/entitlement code introduced | Pass |
| 🟢 | Security | No sponsor-only gates, private releases, or feature-tier claims on public surfaces | Pass |
| 🟢 | Security | Spoofing mitigations: single `github: [sky2464]` in `.github/FUNDING.yml` mirrored in SUPPORT | Pass |
| 🟢 | Security | Elevation-of-privilege mitigations: sponsorship/consulting explicitly deny governance, roadmap, security-order, feature privilege | Pass |
| 🟡 | EM | Verifier WARN: DEV-084 — 6 of 12 AC rows lack EARS keywords (failure-mode table rows counted) | **Accepted** — main Must AC table is EARS-compliant |
| 🟡 | EM | Verifier WARN: no Active Tasks tree / `### Wave Plan` heading mismatch (`### 3.2 Wave Plan` present) | **Accepted** — cosmetic; wave plan content in archived spec |
| 🟢 | EM | In-scope files under 500 lines: SUPPORT (48), FUNDING (4), SECURITY (73), CONTRIBUTING (180) | Pass |
| 🟢 | EM | README pre-existing >500 (569); DEV-084 only added concise Support/sponsorship section | Pass — no new shallow modules |
| 🟢 | EM | Architecture match: docs-only boundary; no generator/template/payment/entitlement code | Pass |
| 🟢 | EM | No ADR required — disclosure/policy alignment, not a new architectural decision | Pass |
| 🟢 | EM | Domain language aligned: sponsorship, best effort, consulting, channel matrix | Pass |
| 🟢 | CEO | Goal Contract: consistent transparent boundary without feature gates or SLA overclaims | Pass |
| 🟢 | CEO | User outcome: channels, expectations, sponsorship limits, consulting separation clear | Pass |
| 🟢 | CEO | Success condition: static wording + cross-surface consistency + manual Sponsors deferred honestly | Pass |
| 🟢 | CEO | Non-goals honored: no SLA ops, no paid tiers, no payment processing, no consulting delivery | Pass |
| 🟢 | CEO | AC-001–AC-006 Must criteria satisfied by SUPPORT + aligned surfaces + OSS bats | Pass |
| 🟢 | CEO | Task 2.3 Sponsors live confirmation correctly marked manual-deferred (not claimed complete) | Pass |
| 🟢 | CEO | No SLA or feature-gate claims introduced in public copy | Pass |
| 🟡 | QA | OSS-007 live account-control still deferred; static metadata pass only | **Accepted** — documented in test plan + this review |
| 🟡 | QA | Verifier WARN noise on Active Tasks / Wave Plan for fan-out archived specs | **Accepted** — same class as sibling stories |
| 🟢 | QA | `bats tests/agtoosa.bats -f "DEV-084"` → 7/7, exit **0** | Pass |
| 🟢 | QA | All Must ACs AC-001–AC-006 mapped to OSS-001–OSS-007 | Pass |
| 🟢 | QA | Smoke set OSS-001, OSS-002, OSS-003, OSS-005 green | Pass |
| 🟢 | QA | No unsupported fixed-time / SLA / feature-gate greps on public surfaces (OSS-003, OSS-005) | Pass |
| 🟢 | QA | `bash agtoosa.sh --verify .` → PASS (0 fail); DEV-084 gates green | Pass |
| 🟢 | QA | RED→GREEN evidence recorded in `docs/AgToosa_TestPlan-DEV-084.md` | Pass |
| 🟢 | QA | Cross-links: README + CONTRIBUTING → SUPPORT.md + SECURITY.md | Pass |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Pass — one consistent disclosure across Sponsors, support, security, sponsored content, consulting |
| User outcome | 🟢 Pass — where to ask, what to expect, what sponsorship does/does not buy |
| Success condition | 🟢 Pass — static contracts + consistency review; live Sponsors deferred honestly |
| Proof / evidence | 🟢 Pass — OSS bats, test plan RED/GREEN, review + evidence ledgers |
| Non-goals | 🟢 Pass — no SLA, feature tiers, payment, or consulting ops |

## Scope Verification

| Artifact | Role |
|----------|------|
| `.github/SUPPORT.md` | Canonical channel matrix + sponsorship/consulting boundary |
| `.github/FUNDING.yml` | Official Sponsors destination (`sky2464`) |
| `SECURITY.md` | Private route + non-SLA intake |
| `README.md` | Concise Support and sponsorship + Security pointers |
| `CONTRIBUTING.md` | Contributor channel matrix pointer |
| `tests/agtoosa.bats` (DEV-084) | OSS-001–OSS-007 |

Out of scope confirmed: generator/template behavior, payment/entitlement code, support operations, consulting delivery. **No edits to `docs/Master-Plan.md`.**

## Terminal Evidence — QA

| Field | Value |
|-------|--------|
| Command | `bats tests/agtoosa.bats -f "DEV-084"` |
| Exit code | **0** |
| Pass/fail | PASS — 7/7 (OSS-001–OSS-007) |
| Verifier | `bash agtoosa.sh --verify .` → PASS (39 pass · 21 warn · 0 fail) |
| Manual-deferred | OSS-007 live Sponsors enablement / account control — `[manual-deferred: 2026-07-11]`; HEAD 302 → profile |
| Next | `/agtoosa-ship` when ready (PATCH 5.3.9 suggested); confirm Sponsors live before treating destination as enabled |

## ✅ Review Approved

Approved: 2026-07-11 21:30  
Unresolved 🔴 Critical: 0
