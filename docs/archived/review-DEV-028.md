# Review: DEV-028 — Plan-Mode Spec Interview for `/agtoosa-spec`

> **Story ID:** DEV-028
> **Reviewed:** 2026-05-24
> **Verdict:** ✅ PASS

## Summary

DEV-028 strengthens `/agtoosa-spec` with a **Plan-Mode Spec Interview Contract** in the canonical workflow: research before asking, infer-first, one question at a time with contextual options, adaptive cap **8** (quick cap **2**), a budget-exhaustion continue/proceed gate, and a decision-complete checklist before spec generation. Maintainer mirror `docs/AgToosa_Spec.md`, `template/Docs/AgToosa_Agent.md` question budgets, all nine native spec adapters, and bats **DEV-028 T-001–T-010** (plus W3/CS1 regressions) lock the behavior.

No unresolved 🔴 Critical findings. Ready for `/agtoosa-ship` (suggest **v5.2.0** template release; version wiring at ship).

## Validation

| Check | Result |
|---|---|
| DEV-028 targeted tests | ✅ `bats tests/agtoosa.bats -f "DEV-028"` — 10/10 passing |
| Spec approval | ✅ `docs/archived/spec-DEV-028.md` — explicit user approval; 13/13 build tasks complete |
| AC coverage (Must) | ✅ AC-001–AC-010 → DEV-028 T-001–T-010 (see `docs/AgToosa_TestPlan-DEV-028.md`) |
| Threat model | ✅ STRIDE table in spec § 2.3; shallow-dispatcher / adapter drift / auto-build risks mitigated in contract and W1 |
| Regression (spec adapters) | ✅ W1, W3, CS1–CS5, G4, CU1, WS1, GM1 — green on focused filters |
| Full generator suite | 🟡 Not re-run to completion in this review session; ship gate should run full `bats tests/agtoosa.bats` and align version pins per release checklist |

## Findings

| Severity | Persona | Finding | Disposition |
|---|---|---|---|
| 🟢 Passed | Security Officer | Template/docs-only change; no new executables or secrets. STRIDE mitigations: decision-complete gate (AC-007), no auto-build (AC-009), infer-first reduces prompt-injection surface from generic questions. | Accepted |
| 🟢 Passed | Engineering Manager | Scope matches spec: `template/Docs/AgToosa_Spec.md`, maintainer mirror, `AgToosa_Agent.md` budgets, spec adapters only; adapters remain thin routers without Part 1/2 duplication (T-008). | Accepted |
| 🟢 Passed | CEO / Product Owner | Goal Contract met: users get researched, interview-driven specs instead of shallow drafts. All Must user stories and ACs satisfied. Non-goals respected (no generator inventory change, no auto-build, init unchanged). | Accepted |
| 🟢 Passed | QA Lead | DEV-028 T-001–T-010 green; test plan evidence recorded; 10/10 Must ACs mapped; smoke set T-001–T-009 covered. | Accepted |
| 🟡 Warning | QA Lead | `quick` sub-command blurbs in Claude/GitHub/Gemini adapters still say “2–3” or “3 questions” while canonical contract caps quick at **2** (T-005 locks canonical doc only). | Accepted — optional adapter polish at ship |
| 🟡 Warning | Engineering Manager | Contract enforcement is markdown + grep bats only — no runtime guarantee agents comply (inherent to workflow template stories). | Accepted |
| 🟡 Warning | QA Lead | DEV-028 T-009 (nested `bats` invoking W1) intermittently failed when batched with other DEV-028 tests in one run; passed on immediate re-run and in isolation. | Accepted — monitor; consider inlining W1 grep in T-009 if flake recurs |
| 🟡 Warning | Engineering Manager | Working tree may include unshipped DEV-027 changes alongside DEV-028; ship should use a DEV-028-scoped commit or combined release with clear CHANGELOG. | Accepted — ship hygiene |

## Verdict

✅ Review passed — no unresolved 🔴 Critical findings.

**🔴 Critical: 0  🟡 Warning: 4  🟢 Passed: 4**

Next: `/agtoosa-ship` for DEV-028 — suggest **v5.2.0** (plan-mode spec interview contract + bats; bump `AGTOOSA_VERSION`, README badge, and bats version pin during ship).
