# Review: DEV-121 — Behavioral Conformance Lab

> **Story:** DEV-121  
> **Review date:** 2026-07-26  
> **Implementation base:** working tree (uncommitted)  
> **Risk tier:** Recommended (user-controlled artifact paths, local file reads, behavioral claim boundary)  
> **Outcome:** ✅ PASS  
> **Suggested release:** PATCH **5.3.36 → 5.3.37** (ADR-005 patch-first; portfolio spike)

## Verdict

| Severity | Count |
|----------|-------|
| 🔴 Critical | 0 |
| 🟡 Warning | 4 |
| 🟢 Passed | 4 review lanes (+ Goal Contract) |

**Ship recommendation:** PASS — all 13 Must ACs have passing BCL evidence; DEV-094/096/101 boundaries preserved; STRIDE mitigations implemented; portfolio non-goals honored.

## Persona Summary

| Lane | Outcome | Main conclusion |
|------|---------|-----------------|
| Security Officer | Pass with warnings | Path traversal blocked (`..`, absolute paths); no network I/O in runner/verifier; platform allowlist enforced; claim boundaries forbid live-assistant CI claims. |
| Engineering Manager | Pass with warnings | ADR-021 Accepted; all new files under 500 lines; `lib/config.sh` + template parity; universal scenario × six platforms matches R1 amendment. |
| CEO / Product Owner | Pass | Goal Contract satisfied: corpus + runner + verifier + six platform fixtures + pack/compatibility hooks; DEV-122–124 scope not absorbed. |
| QA Lead | Pass with warnings | BCL-001–BCL-013 green (13/13); 100% Must AC mapping via bats; test plan doc stale vs R1 (warning only). |

## Findings

| ID | Sev | Confidence | Finding | Disposition |
|----|-----|------------|---------|-------------|
| R-121-001 | 🟡 | virtual-persona-only | `docs/AgToosa_TestPlan-DEV-121.md` still describes pre-R1 three-scenario / `behavioral-scenario` provider model; implementation uses `lifecycle-compass-proof` × six platforms + `agtoosa-scenario-run.sh`. | **Accepted.** Bats and spec are authoritative; sync test plan at ship `docs` step or follow-up chore. |
| R-121-002 | 🟡 | reviewer-only | Corpus/run validation uses structural Python checks, not JSON Schema draft validation against `contracts/scenario-*.schema.json`. | **Accepted for spike.** BCL-002/BCL-003 assert parseable JSON + required fields; full jsonschema gate deferred. |
| R-121-003 | 🟡 | virtual-persona-only | Pilot `scenario-run.json` fixtures exist for **cursor** and **claude** only; four platforms lack recorded run JSON (AC-013 requires ≥2). | **Accepted.** Minimum met; maintainer live runs remain manual per contract. |
| R-121-004 | 🟡 | virtual-persona-only | Semgrep/Gitleaks/CodeQL not run in review environment. | **Accepted.** Bats tamper/missing/marker cases + path guards substitute for maintainer generator repo. |

## Goal Contract Alignment

| Field | Alignment |
|-------|-----------|
| Goal | 🟢 Versioned scenario corpus, maintainer runner, scenario-run evidence, static verifier across six platforms. |
| User outcome | 🟢 Maintainers can run one universal proof task per platform and record comparable evidence bundles. |
| Success condition | 🟢 Contract, schemas, `lifecycle-compass-proof`, runner/verifier scripts, fixtures, BCL suite green. |
| Proof / evidence | 🟢 `docs/archived/review-DEV-121.md`, `docs/archived/evidence-DEV-121.md`, BCL-001–BCL-013. |
| Non-goals | 🟢 No hosted lab, live assistant CI, auto Scenario-tested labels, DEV-060 absorption. |

## AC Coverage

| AC | Proof | Status |
|----|-------|--------|
| AC-001 | BCL-001 | 🟢 |
| AC-002 | BCL-002 | 🟢 |
| AC-003 | BCL-003 | 🟢 |
| AC-004 | BCL-004 | 🟢 |
| AC-005 | BCL-005, BCL-006 | 🟢 |
| AC-006 | BCL-006, BCL-008 | 🟢 |
| AC-007 | BCL-007 | 🟢 |
| AC-008 | BCL-009 | 🟢 |
| AC-009 | BCL-010 | 🟢 |
| AC-010 | BCL-011 | 🟢 |
| AC-011 | BCL-012 | 🟢 |
| AC-012 | BCL-013 | 🟢 |
| AC-013 | BCL-004, fixture `scenario-run.json` | 🟢 |

## Cross-Model Review

| Field | Value |
|-------|-------|
| Tier | Recommended (`workflow.md`: `cross_model: recommended`; artifact paths + behavioral claim boundary) |
| Policy | `cross_model=recommended` · `reviewer_model=parent` |
| Proposed reviewer | Same session model — read-only independent pass |
| Outcome | completed (same-session read-only lane) |
| Consent | User invoked review via `do it`; parent-tier read-only pass executed |

**Reviewer-only additions:** R-121-002 (JSON Schema validation gap). No additional Critical findings.

## Security And Architecture (STRIDE)

| Threat | Mitigation | Evidence |
|--------|------------|----------|
| Spoofing (false Scenario-tested) | Contract + compatibility cross-link; BCL-001 forbidden-claim grep | BCL-001, BCL-010 |
| Tampering (weakened markers) | Verifier marker checks; fail fixtures | BCL-006, BCL-008 |
| Repudiation | `scenario-run.json` records `run_at`, `verifier_exit_code` | BCL-003, BCL-004 |
| Information disclosure | No secrets in fixtures; local reads only | code review, no network grep |
| Denial of service | Small fixture trees; bounded artifact lists | BCL-007 |
| Elevation (path escape) | Reject `..` and absolute artifact paths | `lib/scenario.sh` |

ADR-021 Accepted. DEV-120 proof-graph linkage documented as separate verify (BCL-011).

## Terminal Evidence

| Command | Exit | Result |
|---------|------|--------|
| `bats tests/agtoosa.bats -f 'DEV-121\|BCL-'` | 0 | 13/13 |
| `bats tests/agtoosa.bats -f 'BCL-013'` | 0 | ACC regression ok |

## Review Approval

Review ✅ Approved — 2026-07-26 — ready for `/agtoosa-ship DEV-121 v5.3.37`.
