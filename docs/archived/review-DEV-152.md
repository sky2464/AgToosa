# Review: DEV-152 — Bats Cleanup & Version Pin Consolidation

> **Story ID:** DEV-152
> **Review date:** 2026-11-20
> **Verdict:** PASS
> **Critical findings:** 0
> **Host mode handoff:** HOST-MODE: plan complete → switching to agent for AgToosa artifacts

### Plan-Mode Review Briefing (findings)

| Subsection | Summary |
|------------|---------|
| **Persona synthesis** | **Security:** Test-harness only. Version pins moved to a fixture; changelog matching uses `grep -qF` so brackets stay literal. No credentials, network, or generator behavior change. **EM:** New helper is 78 lines; the bats file stays one file, which the spec lists as a non-goal to split. **CEO / PO:** Goal Contract met — stale `v5.3` / `v0.3` pins are gone from `tests/agtoosa.bats`, and CHANGELOG records the cleanup. **QA:** BCP-001–BCP-005 passed on `main` after the Bugbot pin fixes in `e60cd4e`. |
| **Iron Law hypotheses** | None. Contract tests passed; no failing test required a root-cause loop. |
| **Cross-model gate** | Skipped with rationale. `cross_model: recommended`, `reviewer_model: parent`. This story changes the bats harness only (STRIDE: test tampering / syntax integrity). Independent re-run of BCP-001–BCP-005 on `main` is the mitigation. No runtime, auth, or supply-chain surface. |
| **Host mode handoff** | Review executed in Agent mode after the build was already on `main`. Briefing recorded here before the artifact write. |

## Goal Contract Alignment

| Field | Status | Notes |
|-------|--------|-------|
| Goal | 🟢 Met | Historical ship versions live in `tests/fixtures/ship-regression-versions.tsv`; helpers live in `tests/lib/ship-regression.bash` |
| User outcome | 🟢 Met | New ship-regression checks call `ship_regression_ver` instead of embedding patch numbers in `tests/agtoosa.bats` |
| Success condition | 🟢 Met | `v5.3.[0-9]` pins in `tests/agtoosa.bats`: 0. `bats -c` exit 0 (1297 tests). BCP-001–BCP-005 exit 0 |
| Proof / evidence | 🟢 Met | This review, `docs/archived/evidence-DEV-152.md`, and the BCP run on `main` (`ab723b9`) |
| Non-goals | 🟢 Respected | Assertions were not rewritten into a different product behavior. The file was not split. Bugbot restored two dropped secondary pins (`0.3.20`, `0.3.61`) and corrected DEV-041 / DEV-110 / DEV-128 |

## Findings

| Severity | Persona | Finding | Disposition |
|----------|---------|---------|-------------|
| 🟢 Passed | Security | `ship_regression_changelog_has` uses `grep -qF`, so `## [0.3.x]` is a literal heading. B33-002 and RTA-005 greps are single-quoted. No secret material | Accepted |
| 🟢 Passed | Engineering | Helper and fixture are small. `tests/agtoosa.bats` remains far above 500 lines; splitting it is an explicit non-goal | Accepted |
| 🟡 Warning | Engineering | BCP-002 and BCP-003 prove `@regression` coverage by fixed line windows (`7570–7900`, `14900–15600`). Those windows will drift on the next edit | Accepted for this story. DEV-153 should key off test names, not line numbers |
| 🟢 Passed | CEO / PO | CHANGELOG Unreleased has the DEV-152 consolidation note. Maintainers can look up a story's ship version in the TSV | Accepted |
| 🟢 Passed | QA | BCP-001–BCP-005 passed (exit 0) on `main`. `grep -cE 'v5\.3\.[0-9]' tests/agtoosa.bats` is 0. `@regression` count is 107 | Accepted |
| 🟡 Warning | QA | Spec AC-004 names `bats --compile`. This bats-core rejects that flag. `bats -c tests/agtoosa.bats` counted 1297 tests (exit 0), and BCP-004 runs `bash -n` on the helper | Accepted. Parse gate is met; the spec flag name does not match this bats-core |

## Acceptance Criteria Verification

| AC | Description | Status | Evidence |
|----|-------------|--------|----------|
| AC-001 | Legacy `v5.3` pins ≤ 10 | 🟢 Pass | `grep -cE 'v5\.3\.[0-9]' tests/agtoosa.bats` → 0. BCP-001 also caps `v0.3` / `v5.3` hardcodes at 10 and passed |
| AC-002 | Wave 2–4 ship tests tagged `@regression` | 🟢 Pass | BCP-002 passed against the current wave block |
| AC-003 | DEV-119–124 ship tests tagged `@regression` | 🟢 Pass | BCP-003 passed (`@regression SR-` count in that window ≥ 3) |
| AC-004 | Bats file parses | 🟢 Pass | `bats -c tests/agtoosa.bats` → 1297, exit 0. BCP-004 `bash -n` exit 0. Literal `--compile` is not in this bats-core (see warning) |
| AC-005 | CHANGELOG summary | 🟢 Pass | BCP-005 passed. Unreleased Changed section names DEV-152 and `ship-regression-versions.tsv` |

## Verification Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats -f 'DEV-152\|BCP-'` | 0 | 5/5 ok on `main` after `e60cd4e` and `ab723b9` |
| `bats -c tests/agtoosa.bats` | 0 | 1297 tests counted |
| `grep -cE 'v5\.3\.[0-9]' tests/agtoosa.bats` | 1 | 0 matches (grep exit 1 means no hits) |
| `grep -c '@regression' tests/agtoosa.bats` | 0 | 107 |
| `bats tests/agtoosa.bats -f 'DEV-041 @regression SR-\|DEV-089 @regression SR-003\|DEV-110 @regression SR-001\|DEV-128 @regression\|DEV-147 @regression @smoke SR-001\|DEV-149 B33-002\|DEV-150 @smoke RTA-005'` | 0 | Run on the Bugbot fix before merge; same assertions are on `main` via `e60cd4e` |

## Cross-Model Review

**Skipped** — `docs/Context/workflow.md` sets `cross_model: recommended` and `reviewer_model: parent`. Skip rationale: DEV-152 does not change generator runtime, auth, registry, or release publishing. The threat model is loss or corruption of historical version assertions. That risk was checked by re-running BCP-001–BCP-005 on `main` and by the Bugbot fixes already merged in `e60cd4e` (literal greps, DEV-041 row, DEV-110 `0.3.22`, DEV-128 `0.3.42`, secondary `0.3.20` and `0.3.61` checks).

## Review Gate

```
✅ Review complete — Verdict: PASS
🔴 Critical: 0  🟡 Warning: 2  🟢 Passed: 4
No critical issues found. Ship-regression versions live in the fixture, and BCP-001–BCP-005 passed on main.
→ Approve to proceed to /agtoosa-ship
```

Served by `/agtoosa-next`: Review ✅ Approved. Do not start ship in this invocation.

---

Suggested release version: **v0.3.64** (PATCH on the shipped 0.3.63 line; chore, estimate S, ADR-005).
