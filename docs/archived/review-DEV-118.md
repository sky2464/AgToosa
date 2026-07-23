# Review: DEV-118 — Product Truth & Adapter Contract

> **Story:** DEV-118
> **Review date:** 2026-07-23
> **Implementation base:** `b543a4a` (working tree; uncommitted)
> **Risk tier:** Recommended (user-controlled contract JSON, supply-chain/public-claims surfaces)
> **Outcome:** ✅ PASS
> **Suggested release:** PATCH **5.3.29 → 5.3.30** (ADR-005 patch-first; aligns with Master-Plan milestone)

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 5 |
| 🟢 Passed | 5 review lanes |

**Ship recommendation:** PASS after resolving one ship-blocker found during review (adjacent CI regressions). PTC Must ACs, inert checker/renderer, and Goal Contract are materially satisfied.

## Persona Summary

| Lane | Outcome | Main conclusion |
|------|---------|-----------------|
| Security Officer | Pass with warnings | Closed JSON schema, no subprocess/network in checker; STRIDE mitigations for tampering and overclaiming are exercised by PTC-001/008/010/011. |
| Engineering Manager | Pass with warnings | ADR-015–017 present; Master Architecture and CONTEXT domain terms updated; `agtoosa.ps1` remains above 500-line guideline (pre-existing). |
| CEO / Product Owner | Pass | Goal Contract and 12/12 Must ACs satisfied at declared claim boundaries; non-goals (DEV-120/121) preserved. |
| QA Lead | Pass | PTC 12/12 ×3 stable; AC 1:1 mapped; adjacent PN/WP2/ACC/NET/PSP/CORE 32/32 after review fixes. |
| Independent reviewer | Changes requested → resolved | Found pre-existing adjacent regression failures exposed by new CI gate; fixed in review session. |

## Findings

| ID | Sev | Confidence | Finding | Disposition |
|----|-----|------------|---------|-------------|
| R-001 | 🔴→🟢 | both-models | New CI step `bats … -f 'PN\|WP2\|ACC\|NET\|PSP\|CORE'` failed 29/32 (WP2 18≠19, PSP-004 pinned `5.3.26`, CORE-002 missing `Docs/AgToosa_Orchestration.md` in maintainer Core Contract inventory). | **Resolved during review.** WP2→19, PSP-004 uses `AGTOOSA_VERSION` from `agtoosa.sh`, `docs/AgToosa_Core_Contract.md` inventory synced. Re-run 32/32 exit 0. |
| R-002 | 🟡 | both-models | Large uncommitted import (~161 paths) from `codex/dev-118` with no wave micro-commits; harder to bisect. | **Accepted for this cycle.** Commit as logical chunks before ship recommended. |
| R-003 | 🟡 | virtual-persona-only | Verifier G2 log bloat + G3 EARS wording on DEV-118 spec (9/24 AC rows). | **Pre-existing / non-blocking.** |
| R-004 | 🟡 | virtual-persona-only | `agtoosa.ps1` (~1634 lines) exceeds 500-line review guideline. | **Pre-existing debt.** DEV-118 touches bootstrap/ref paths only. |
| R-005 | 🟡 | reviewer-only | `bootstrap.ps1` `Test-ReleaseRef` skipped when `-Archive` is set (local offline path). | **Accepted.** Documented low-risk; PTC-008 covers published install path. |
| R-006 | 🟡 | virtual-persona-only | Gitleaks/Semgrep/CodeQL not available in review environment. | **Accepted.** Python inert parse + PTC adversarial fixtures substitute for this maintainer-only tool. |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Single Product Truth Contract repairs casing, adapters, Windows/dependency truth, and public claims. |
| User outcome | 🟢 Maintainers get one authority; downstream gets `Docs/` casing, lifecycle parity, honest Windows facts, bounded claims. |
| Success condition | 🟢 19×6 inventory, managed blocks, governed claims, PTC-001–012 + adjacent regressions green in CI wiring. |
| Proof / evidence | 🟢 Test plan RED/GREEN, this review, evidence ledger, verifier PASS. |
| Non-goals | 🟢 No new adapters, Scenario lab, DEV-120/121 absorption, or Master-Plan replacement. |

## AC Coverage

| AC | Proof | Status |
|----|-------|--------|
| AC-001 | PTC-001 | 🟢 |
| AC-002 | PTC-002 | 🟢 |
| AC-003 | PTC-003 | 🟢 |
| AC-004 | PTC-004 | 🟢 |
| AC-005 | PTC-005 | 🟢 |
| AC-006 | PTC-006 | 🟢 |
| AC-007 | PTC-007 | 🟢 |
| AC-008 | PTC-008 | 🟢 |
| AC-009 | PTC-009 | 🟢 |
| AC-010 | PTC-010 | 🟢 |
| AC-011 | PTC-011 | 🟢 |
| AC-012 | PTC-012 + adjacent 32/32 | 🟢 |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Recommended |
| Reviewer identity | Independent Cursor subagent (read-only) |
| Model/platform | Claude Sonnet / Cursor |
| Outcome | completed, read-only |
| Skip rationale | Not applicable |

Independent reviewer surfaced R-001 (`both-models` with QA persona). Security inert-contract properties corroborated by static read + PTC execution.

## Security And Architecture

- STRIDE: contract tampering, renderer overwrite, stale claims, and marketing static checks as behavioral proof are mitigated per spec table; PTC exercises negative paths.
- Checker uses stdlib JSON only; path resolution is `relative_to` bounded; `render --apply` uses atomic replace.
- ADR-015–017 accepted and implemented; no new ADR required beyond those.
- `workflow.md` `coverage_threshold: 100` interpreted as **Must AC coverage** (12/12), not line coverage — generator repo has no unified coverage gate.

## Terminal Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/product-truth.bats` | 0 | 12/12 |
| `bats tests/product-truth.bats` ×3 | 0 | 36/36; no flake signal |
| `python3 scripts/product-truth.py check --root . --contract contracts/product-truth-v1.json --as-of 2026-07-22` | 0 | All stages PASS |
| `bash docs/agtoosa-verify.sh` | 0 | 12 pass · 2 warn · 0 fail |
| `bats tests/agtoosa.bats -f 'PN\|WP2\|ACC\|NET\|PSP\|CORE'` (before fix) | 1 | 29/32; WP2, PSP-004, CORE-002 |
| Same (after review fix) | 0 | 32/32 |
| `python3 -m py_compile scripts/product-truth.py scripts/product_truth_*.py` | 0 | Syntax OK |

## Review fixes applied (authorized as review gate remediation)

- `tests/agtoosa.bats` — WP2 expects 19 adapters; PSP-004 version tracks `agtoosa.sh`.
- `docs/AgToosa_Core_Contract.md` — `Docs/AgToosa_Orchestration.md` added to `DOCS_FILES` inventory block.
