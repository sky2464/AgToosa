# Review: DEV-117 — Cycle Continuity Guard

> **Story:** DEV-117
> **Review date:** 2026-07-14
> **Implementation base:** `8c4c4ab`
> **Ship-gate follow-up:** `4873f68`
> **Risk tier:** Standard
> **Outcome:** ✅ PASS
> **Suggested release:** PATCH **5.3.28 → 5.3.29** (ADR-005 patch-first)

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 4 (accepted) |
| 🟢 Passed | 5 review lanes |

**Ship recommendation:** PASS. The core continuity behavior and all eight Must ACs are materially satisfied. The global suite remains an accepted, pre-existing red baseline rather than a clean gate.

## Persona Summary

| Lane | Outcome | Main conclusion |
|------|---------|-----------------|
| Security Officer | Pass with warnings | Project Charter parsing is section/key bounded and shell-safe; Idle value validation is broader than the documented reason form. |
| Engineering Manager | Pass with warnings | Architecture, mirror ownership, domain language, and ADR boundaries are sound; touched files remain above the pre-existing 500-line limit. |
| CEO / Product Owner | Pass with warnings | 8/8 ACs materially satisfy the user outcome at the declared generator/agent claim boundaries. |
| QA Lead | Pass | Five CCG smoke tests cover all eight Must ACs; focused and smoke-only filters pass 5/5. |
| Independent reviewer | Changes requested, merged as warnings | Confirmed the parser, traceability, mirror-proof, and baseline-evidence limitations. |

## Findings

| ID | Sev | Confidence | Finding | Disposition |
|----|-----|------------|---------|-------------|
| R-001 | 🟡 | both-models | `docs/agtoosa-verify.sh:297` and its template mirror accept bare `Idle` and any `Idle ` prefix, while the template/threat mitigation describe `Idle — <reason>`. | **Accepted for DEV-117.** The value is still an explicit, bounded Project Charter declaration and AC-001 names semantic `Idle`; follow-up should either require `Idle — <nonblank reason>` or relax the prose contract. |
| R-002 | 🟡 | both-models | Focused bats do not reject malformed Idle values, do not encode an independent-warning strict fixture, and use phrase-level checks for status mirror semantics. | **Accepted.** Happy-path, unmarked-empty, and strict behavior pass; Security manually confirmed independent warnings still promote under strict. Status remains agent-instructed, not runtime-enforced. |
| R-003 | 🟡 | both-models | Full bats is red at 918/973. The 55 failures are classified from the completed build run plus representative pre-story proof, not an exhaustive base-vs-HEAD failure-set comparison. | **Accepted baseline, not GREEN.** No `CCG-*` test failed; stale version pins, superseded intent-map assertions, and the pack helper issue are present at `8c4c4ab`. A clean-archive comparison attempt was stopped and its partial result was not used. |
| R-004 | 🟡 | virtual-persona-only | The verifier is 688 lines and `tests/agtoosa.bats` is 13,630 lines, above the 500-line review guideline. | **Accepted pre-existing debt.** DEV-117 adds 12 verifier lines and 96 focused fixture/test lines without introducing a new oversized module or architectural boundary. |

## Resolved During Review

| ID | Initial severity | Resolution | Proof |
|----|------------------|------------|-------|
| Q-001 | 🔴 | Corrected the published smoke regex and AC mappings during the initial review; follow-up `4873f68` then tagged `CCG-005` and marked AC-005/006/007 smoke coverage as `yes`, closing the per-Must ship gate without changing the test body. | Focused and smoke-only filters each pass 5/5; the committed-object mapping audit covers AC-001 through AC-008. |

## Ship-Gate Follow-Up Review

| Field | Result |
|-------|--------|
| Reviewed commit | `4873f68` (`WIP: DEV-117 task 5.1 smoke coverage gate`) |
| Scope | Test-title metadata plus test-plan, spec, Master Plan, and event traceability; no verifier, status, template, dependency, or deployment behavior changed |
| Persona verdicts | Security PASS · Engineering Manager PASS · Product Owner PASS · QA Lead PASS |
| New findings | 0 Critical · 0 Warning |
| Accepted baseline | R-001 through R-004 unchanged |
| Smoke readiness | 5 tagged CCG tests; all 8 Must ACs map to at least one tagged passing test |

The follow-up resolves only the ship-readiness classification gap. It does not broaden DEV-117 behavior or convert the accepted 918/973 full-suite baseline into a green claim.

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Explicitly Idle empty cycles are informational; unmarked empty cycles retain `G3-idle`. |
| User outcome | 🟢 Maintainers can intentionally pause without verifier/status empty-cycle score degradation. |
| Success condition | 🟢 Template contract, default/strict verifier behavior, status Info/no-deduction guidance, and independent-finding retention are present. |
| Proof / evidence | 🟢 CCG 5/5, three repeat runs, mirror/lint checks, corrected AC mapping, and this evidence ledger. |
| Non-goals | 🟢 No automatic enrollment, new CLI flag, runtime store, dependency, service, or unrelated scoring change. |

## AC Coverage

| AC | Proof | Status |
|----|-------|--------|
| AC-001 | CCG-001 | 🟢 |
| AC-002 | CCG-004 | 🟢 |
| AC-003 | CCG-001, CCG-002 | 🟢 |
| AC-004 | CCG-003 | 🟢 |
| AC-005 | CCG-005, agent-contract review | 🟢 |
| AC-006 | CCG-005, independent-warning probe | 🟢 |
| AC-007 | CCG-005, verifier `cmp`, semantic status mirror review | 🟢 |
| AC-008 | Test-plan RED/GREEN record with baseline qualification | 🟢 |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Standard |
| Reviewer identity | Independent Codex reviewer |
| Model/platform | GPT-5.4 / Codex desktop |
| Outcome | completed, read-only |
| Skip rationale | Not applicable |

The independent reviewer confirmed R-001 through R-003. Those findings were also found by the primary personas and are merged as `both-models`. No project specialist lanes ran because `docs/Context/specialists.md` is absent.

The Standard-tier `4873f68` follow-up did not require a second cross-model pass: its only test-file delta is an `@smoke` title tag, and four fresh read-only persona lanes independently confirmed no product-behavior change.

## Security And Architecture

- STRIDE mitigations are materially preserved: parsing is bounded to the Project Charter key, free-form mentions do not match, active stories still receive spec checks, and unrelated warnings retain strict promotion.
- Shell syntax, ShellCheck with the pre-existing `SC2034` excluded, verifier byte parity, and bounded secret-pattern checks passed.
- Gitleaks, Semgrep, Checkov, Syft, and Trivy were unavailable. DAST, dependency audit, IaC scan, and SBOM generation are not applicable because no dependency, service, package lock, or IaC surface changed.
- No ADR is required; DEV-117 extends the existing proof-engine and agent-workflow contracts without changing component, deployment, data-ownership, or trust boundaries.

## Terminal Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats -f 'DEV-117|CCG-'` | 0 | 5/5; corrected published filter discovers the complete focused suite |
| `bats tests/agtoosa.bats -f 'DEV-117'` ×3 | 0 | 15/15; no focused flake signal |
| `bats tests/agtoosa.bats -f '@smoke CCG-'` | 0 | 5/5; exact smoke-only set |
| Must-AC-to-smoke mapping audit | 0 | AC-001 through AC-008 mapped; 5 tagged CCG tests |
| `git diff --quiet 6475160 4873f68 --` verifier/status/template behavior files | 0 | No product-behavior file changed in the follow-up |
| `bash -n template/Docs/agtoosa-verify.sh docs/agtoosa-verify.sh` | 0 | Syntax pass |
| `shellcheck -e SC2034 template/Docs/agtoosa-verify.sh docs/agtoosa-verify.sh` | 0 | Lint pass; raw warning is pre-existing |
| `cmp -s template/Docs/agtoosa-verify.sh docs/agtoosa-verify.sh` | 0 | Verifier mirrors byte-identical |
| `git diff --check` | 0 | No whitespace errors in implementation or review artifacts |
| `bash agtoosa.sh --verify .` | 0 | 13 pass, 1 pre-existing `G2-log-bloat` warning, 0 fail |
| `bash docs/agtoosa-verify.sh --strict --root .` | 1 | Expected strict promotion of `G2-log-bloat`; 0 verifier failures |
| Full bats build run | 1 | 918/973; 55 accepted pre-existing failures, not claimed GREEN |
| Clean-archive base/HEAD comparison attempt | 130 | Stopped after concurrent runs stalled on an early interactive reinstall test; partial output excluded |

## Scope Check

Implementation changes stay within the approved Master Plan, verifier/status mirror, test-plan, events, and bats surfaces. The two DEV-088 expectation corrections are test-only and documented as stale assertions exposed during adjacent regression validation. Follow-up `4873f68` changes only smoke metadata and traceability.
