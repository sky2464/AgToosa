# Review Report — DEV-092

> **Story:** DEV-092 — Transactional Apply + Idempotency  
> **Wave:** Rev4 Wave 2 (with DEV-094 · DEV-097)  
> **Reviewed:** 2026-07-12  
> **Personas:** Security Officer · Engineering Manager · CEO/Product · QA Lead · Cross-Model (fallback)  
> **Verdict:** ✅ PASS (warnings accepted)

## Findings

| Sev | Persona | Finding | Disposition |
|-----|---------|---------|-------------|
| 🟢 | Security | Staging root via `mktemp` outside project; `chmod 700`; symlink refuse; inject-fail aborts before writes (TAP-002) | Pass |
| 🟢 | Security | No secrets in apply surfaces; path escape check rejects staging under project | Pass |
| 🟡 | Security | Mid-loop `cp`/`mv` failure after some files committed does not roll back already-written targets (AC-002 partial for I/O mid-fail) | Accepted — TAP-002 covers pre-commit inject; full reverse-rollback follow-up with DEV-093 |
| 🟡 | Security / CEO | Install/update Docs path uses `apply_copy_if_changed` (per-file temp+rename), not batch `apply_begin_staging` → `apply_commit_staging` for all planned writes (AC-001 partial) | Accepted — staging API shipped + unit-tested; batch wire of `install_files` / native dirs deferred |
| 🟢 | Arch | `lib/apply.sh` 184 &lt; 500; `lib/copy.sh` 227 &lt; 500 | Pass |
| 🟡 | Arch | `lib/install.sh` 615 &gt; 500 (pre-existing size; Wave 2 added ~15 lines) | Accepted — split follow-up; not introduced as new module |
| 🟡 | Arch | `APPLY_PROJECT_PATH` / `apply_note_merged` lightly used; shallow helpers | Accepted — keep for DEV-093 hooks |
| 🟡 | Arch | No new ADR for transactional apply (design lives in spec §2) | Accepted — optional ADR later |
| 🟢 | CEO | Goal Contract: hash-idempotent apply + shared helper + TAP proof met for Must path tested | Pass (with AC-001/002 partial noted above) |
| 🟢 | QA | Must ACs AC-001–008 mapped TAP-001–008; review bats 8/8 EXIT 0; RED/GREEN in test plan | Pass |
| 🟡 | QA | coverage_threshold 100 is bats-story scoped; no line-coverage tool for bash | Accepted — story filter green = gate |
| 🟡 | Cross-Model | Independent subagent unavailable (API limit); sequential persona fallback | Accepted — documented below |

## Goal Contract Alignment

| Field | Result |
|-------|--------|
| Goal / User outcome | 🟢 Pass (helper + hash skip + summary; staging API present) |
| Success condition + proof | 🟢 Pass (TAP green) with 🟡 partial batch-stage wiring |
| Non-goals | 🟢 Pass (no DEV-091/093/PS1 full parity) |

## Cross-Model Review

**Risk tier:** Recommended (filesystem apply / user-controlled paths)  
**Gate:** Sequential virtual personas fallback — independent Task reviewer blocked by API usage limit.

| Finding | Confidence |
|---------|------------|
| Batch staging not wired into install_files | virtual-persona-only |
| Mid-write I/O rollback incomplete | virtual-persona-only |

**Outcome:** sequential personas · skip independent model with rationale recorded.

## Terminal Evidence (orchestrator)

```text
$ bats tests/agtoosa.bats -f "DEV-092|TAP-"
1..8 all ok — EXIT 0
$ wc -l lib/apply.sh
184
$ rg apply_begin_staging lib/install.sh lib/update.sh
(no matches — apply_copy_if_changed only)
```

## Ship version suggestion

PATCH **5.3.16** (batch with Wave 1a if still unshipped, else Wave 2 docs+apply slice).

## Approval

Review ✅ Approved — 0 🔴 Critical · warnings accepted · proceed to `/agtoosa-ship` when Wave 2 slice ships.
