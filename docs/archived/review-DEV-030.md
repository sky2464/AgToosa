# Review: DEV-030 — Fix `/agtoosa-update` self-target uncertainty

> **Story ID:** DEV-030
> **Reviewed:** 2026-05-25
> **Verdict:** ✅ PASS

## Summary

DEV-030 adds **Stage 1a operating-context detection** to canonical `AgToosa_Update.md` (template + maintainer mirror), stops Maintainer Dogfood before Apply with an explicit report, preserves DEV-027 downstream flow for Generated Project Mode, and extends Bash/PowerShell self-target errors with maintainer-safe guidance. Bats **T-001–T-011** lock Must ACs; runtime self-target tests cover AC-006/AC-009.

During review, one **🔴 Critical** gap was found and **fixed in-repo**: interactive `agtoosa.sh` install blocked self-target without calling `_print_self_target_guidance()` (the `--update` path already did). Full suite is green after that one-line fix.

No unresolved 🔴 Critical findings. Ready for `/agtoosa-ship` — suggest **v5.2.2** (PATCH+1 on current `5.2.1` per ADR-005).

## Validation

| Check | Result |
|---|---|
| DEV-030 targeted tests | ✅ `bats tests/agtoosa.bats -f "DEV-030"` — 11/11 passing |
| Self-target runtime | ✅ Interactive install + `--update` guidance tests passing (after review fix) |
| DEV-027 regression | ✅ `bats tests/agtoosa.bats -f "T-00[1-9]:"` — green (DEV-027 contract preserved) |
| Spec approval | ✅ `docs/archived/spec-DEV-030.md` — approved 2026-05-25 |
| AC coverage (Must) | ✅ AC-001–AC-008 → T-001–T-009, T-011; see `docs/AgToosa_TestPlan-DEV-030.md` |
| AC coverage (Should) | ✅ AC-009, AC-010 — runtime + static grep tests passing post-fix |
| Threat model | ✅ STRIDE in spec § 2.3; doc stop-before-Apply + preserved CLI block |
| Build tasks | ✅ 5/5 groups complete per `docs/Master-Plan.md` Active Tasks |
| Full generator suite | ✅ `bats tests/agtoosa.bats` — 344/344 passing (`rm -rf ship` before run) |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🔴 Critical (resolved) | QA Lead | **Root cause:** Interactive install self-target guard in `agtoosa.sh` (lines 225–228) exited without `_print_self_target_guidance()` while `--update` path (lines 133–136) did. **Regression test:** `self-targeting interactive install includes maintainer guidance` (failed pre-fix). Violated AC-006 (Must) and AC-009 (Should). | **Fixed during review** — added `_print_self_target_guidance` to interactive path; test green |
| 🟢 Passed | Security Officer | Template/docs + error-text only; no new network surface. STRIDE mitigations: stop before Apply (AC-003), CLI block preserved (AC-006), no weakening self-target semantics. | Accepted |
| 🟢 Passed | Engineering Manager | Scope matches Build Scope: `template/Docs/AgToosa_Update.md`, `docs/AgToosa_Update.md`, `agtoosa.sh`, `agtoosa.ps1`, bats; `lib/update.sh` unchanged. PS1 parity on both install and `--update` paths. | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: dogfood agents get early context + stop; downstream DEV-027 flow unchanged; CLI failure path improved when doc is ignored. | Accepted |
| 🟢 Passed | QA Lead | T-001–T-011 green; Must ACs mapped; DEV-027 T-001–T-009 regression green; full suite 344/344. | Accepted |
| 🟡 Warning | QA Lead | T-001 asserts operating context with loose `grep 'before'` — brittle if wording shifts; consider anchoring on `Stage 1a` or `operating context` only. | Accepted — optional polish |
| 🟡 Warning | Engineering Manager | Contract enforcement remains markdown + grep (inherent for template stories); agents could still attempt Apply if they ignore canonical doc (CLI is backstop). | Accepted |
| 🟡 Warning | QA Lead | Test plan evidence table claimed runtime install test passed before review; re-run evidence after ship. | Accepted — corrected at review |

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0 (1 found and fixed during review)  🟡 Warning: 3  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-030 — suggest **v5.2.2** (PATCH+1; bump `AGTOOSA_VERSION`, `agtoosa.ps1`, bats pins, README badge per release checklist).
