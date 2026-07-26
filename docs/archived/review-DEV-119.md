# Review: DEV-119 — Recoverable Project Transaction

> **Story:** DEV-119
> **Review date:** 2026-07-26
> **Implementation base:** working tree (uncommitted)
> **Risk tier:** Recommended (filesystem mutation, operator trust boundary)
> **Outcome:** ✅ PASS
> **Suggested release:** PATCH **5.3.31 → 5.3.32** (ADR-005 patch-first; generator feature)

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 4 |
| 🟢 Passed | 3 review lanes (+ Goal Contract) |

**Ship recommendation:** PASS — all 12 Must ACs have passing RPT evidence; STRIDE mitigations implemented and tested; no blocking security or architecture violations.

## Persona Summary

| Lane | Outcome | Main conclusion |
|------|---------|-----------------|
| Security Officer | Pass with warnings | Path containment (`transaction_rel_safe`, restore guard), symlink refusal, gitignored journals with `chmod 700`, no git/Master-Plan mutation on recover. Snapshot disclosure risk documented and mitigated. |
| Engineering Manager | Pass with warnings | ADR-018 Accepted; Master-Architecture install-flow note present; `lib/transaction.sh` (318) and `lib/apply.sh` (449) under 500 lines; hooks only on `apply_commit_staging` per spec. |
| QA Lead (AC coverage) | Pass | RPT-001–RPT-012 green; DEV-092 TAP-004 and DEV-093 STF-001 regressions green; 100% Must AC mapping in test plan. |
| Cross-model | Skipped | User scoped review to security + architecture + AC coverage in-session; see Cross-Model section. |

## Findings

| ID | Sev | Confidence | Finding | Disposition |
|----|-----|------------|---------|-------------|
| R-119-001 | 🟡 | virtual-persona-only | `agtoosa.sh` (~732 lines) exceeds 500-line guideline. | **Pre-existing debt.** DEV-119 adds CLI flags only; split deferred. |
| R-119-002 | 🟡 | virtual-persona-only | Journal retention/compaction is manual in v1 (ADR-018 Negative). | **Accepted.** Documented in `AgToosa_Update.md`; non-goal for v1. |
| R-119-003 | 🟡 | virtual-persona-only | `apply_copy_if_changed` install paths are not journaled — only `apply_commit_staging`. | **Accepted.** Matches spec scope boundary (§2.4). |
| R-119-004 | 🟡 | virtual-persona-only | Semgrep/Gitleaks/CodeQL not run in review environment. | **Accepted.** Bats fault-injection + path guards substitute for maintainer generator repo. |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Recoverable project transaction journal with rollback, recovery CLI, fault-injection proof. |
| User outcome | 🟢 Failed apply leaves restorable tree; operators use `--transaction-recover` deterministically. |
| Success condition | 🟢 Late-commit rollback, recover CLI, zero-delta rerun, RPT suite green. |
| Proof / evidence | 🟢 `docs/AgToosa_TestPlan-DEV-119.md`, RPT-001–RPT-012, this review, evidence ledger. |
| Non-goals | 🟢 No DB, no agent journaling (DEV-123), no PS parity in v1. |

## AC Coverage

| AC | Proof | Status |
|----|-------|--------|
| AC-001 | RPT-001 | 🟢 |
| AC-002 | RPT-002 | 🟢 |
| AC-003 | RPT-003 | 🟢 |
| AC-004 | RPT-004 | 🟢 |
| AC-005 | RPT-005 | 🟢 |
| AC-006 | RPT-006 + TAP-004 | 🟢 |
| AC-007 | RPT-007 | 🟢 |
| AC-008 | RPT-008 | 🟢 |
| AC-009 | RPT-009 | 🟢 |
| AC-010 | RPT-010 | 🟢 |
| AC-011 | RPT-011 | 🟢 |
| AC-012 | RPT-012 | 🟢 |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Recommended (`workflow.md`: `cross_model: recommended`) |
| Outcome | skipped |
| Skip rationale | User explicitly requested security + architecture + AC coverage lanes in one session; no second-model subagent launched. Virtual personas + terminal evidence satisfy ship bar for this generator-local feature. |

## Security And Architecture (STRIDE)

| Threat | Mitigation | Evidence |
|--------|------------|----------|
| Information disclosure (journal snapshots) | `.agtoosa/transactions/` gitignored; `chmod 700` on journal dir | RPT-008 |
| Elevation (path escape) | `transaction_rel_safe`; restore rejects `..` and absolute paths | RPT-002, code review |
| Tampering (partial apply) | Pre-image + rollback on late failure | RPT-003, RPT-007 |
| Repudiation | Journal status + timestamps | RPT-004, RPT-010 |
| DoS (disk fill) | Documented manual retention | R-119-002 |
| Spoofing | N/A (local CLI) | — |

ADR-018 Accepted. DEV-091 rollback manifest paths remain distinct (RPT-009).

## Terminal Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats -f 'DEV-119\|RPT-'` | 0 | 12/12 |
| `bats tests/agtoosa.bats -f 'DEV-092.*TAP-004'` | 0 | 1/1 |
| `bats tests/agtoosa.bats -f 'DEV-093.*STF-001'` | 0 | 1/1 |

## Review Approval

Review ✅ Approved — 2026-07-26 — ready for `/agtoosa-ship`.
