# Spec: DEV-137 — Security Scanning CI Health (ShellCheck + Workflow Re-verify)

> **Story ID:** DEV-137  
> **Epic:** DEV-004 — Testing & QA Harness  
> **Type:** Chore  
> **Status:** 🏁 Shipped — v5.3.51  
> **Estimate:** XS  
> **Clarity:** `ready`  
> **Priority:** P1  
> **Parent / extends:** DEV-041 (security-scan workflow) · DEV-130 (BCL/CI wiring)  
> **Spec created:** 2026-07-28  
> **Ship target:** v5.3.51  
> **Note:** Catch-up formalization — ShellCheck fix landed in `5faf2fe` before lifecycle enrollment.

### Plan-Mode Spec Interview (findings)

#### Inferred (≥80% — no question asked)

| Checklist area | Finding |
|----------------|---------|
| Root cause | GitHub Security tab "Trivy workflow failing" is workflow-level; Trivy job passed; ShellCheck job failed (SC2207, SC2178) at `7bac0327` |
| Fix status | `5faf2fe` resolves ShellCheck in `lib/apply.sh` and `lib/catalog.sh`; local ShellCheck exits 0 |
| Workflow policy | `security-scan.yml` runs weekly cron + manual dispatch only — re-dispatch required to clear stale tab |
| Non-goals | No push/PR triggers; PTC-002 and PSScriptAnalyzer failures out of scope |

#### Confirmed (plan session)

| Q# | Question | Answer |
|----|----------|--------|
| Q1 | Scope | Enroll DEV-137 via spec → build → review → ship v5.3.51 |
| Q2 | Out of scope | PTC-002 product-truth drift; Windows PSScriptAnalyzer |

## 1. Requirements

### Goal Contract

| Field | Value |
|-------|-------|
| Goal | Clear the GitHub Security tab "workflow runs failing" alert for the Trivy/Security Scanning integration |
| User outcome | Security Scanning workflow completes green on current `main`; no false-positive Trivy config error |
| Success condition | `workflow_dispatch` of `security-scan.yml` exits 0 on post-fix `main`; ShellCheck step green; terminal evidence captured |
| Proof / evidence | `docs/AgToosa_TestPlan-DEV-137.md`; bats `SSC-001–004`; workflow run URL |
| Non-goals | Re-enable push/PR triggers on security-scan; fix unrelated CI failures (PTC-002, PSScriptAnalyzer) |

### 1.2 Acceptance Criteria (EARS)

| ID | Priority | Criterion |
|----|----------|-----------|
| AC-001 | Must | WHEN Security Scanning runs on current `main` THE workflow SHALL complete with exit 0 |
| AC-002 | Must | WHEN ShellCheck runs with project exclusions THE scan SHALL pass on `agtoosa.sh` + `lib/*.sh` |
| AC-003 | Must | WHEN the fix ships THE SYSTEM SHALL record terminal evidence (workflow run URL + exit codes) |
| AC-004 | Should | WHEN `lib/apply.sh` or `lib/catalog.sh` change THE bats guard SHALL prevent SC2207/SC2178 recurrence |

### 2.3 STRIDE (summary)

| Threat | Mitigation |
|--------|------------|
| Tampering (ShellCheck bypass) | Bats grep-negative for known anti-patterns; CI ShellCheck gate |
| Information disclosure | No secrets in workflow logs; evidence ledger redacts tokens |

### 2.4 Build Scope

- `lib/apply.sh` — verify `while IFS= read -r` sort pattern (fixed in `5faf2fe`)
- `lib/catalog.sh` — verify `platform_found` scalar (fixed in `5faf2fe`)
- `tests/agtoosa.bats` — SSC-001–004 regression guards
- `docs/AgToosa_TestPlan-DEV-137.md`
- Re-dispatch `.github/workflows/security-scan.yml` and capture run URL

## 3. Tasks

- [x] **1.** Verify ShellCheck fix in `lib/apply.sh` and `lib/catalog.sh` — _AC-002_
- [x] **2.** Add bats SSC-001–004 guards — _AC-004_
- [x] **3.** Re-dispatch Security Scanning workflow; capture evidence — _AC-001, AC-003_
- [x] **4.** Review + ship v5.3.51 — _AC-001–AC-003_

## 4. Test Plan

See `docs/AgToosa_TestPlan-DEV-137.md`.

---

## ✅ Spec Approved

Approved 2026-07-28 — catch-up formalization; ShellCheck fix in `5faf2fe`; shipped v5.3.51.
