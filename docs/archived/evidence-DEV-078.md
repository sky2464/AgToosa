# Evidence Ledger — DEV-078

> **Story:** DEV-078 — First-15-Minutes Maintenance Gate  
> **Claim Boundary:** agent-instructed index; Master-Plan remains SoT  
> **Updated:** 2026-07-11 20:55 (review)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|-----|----------|---------|--------------|------|----------|-----|
| build | AC-001, AC-004 | test-log | `docs/AgToosa_TestPlan-DEV-078.md#RED-Evidence` | `bats tests/agtoosa.bats -f "DEV-078\|F15-"` RED — stale pins, no gate, 6/8 fail | 1 | AgToosa | 2026-07-11 |
| build | AC-002, AC-003, AC-005, AC-006 | test-log | `docs/AgToosa_TestPlan-DEV-078.md#RED-Evidence` | F15-002–F15-008 RED during checker bring-up | 1 | AgToosa | 2026-07-11 |
| build | AC-001–AC-006 | test-log | `docs/AgToosa_TestPlan-DEV-078.md#GREEN-Evidence` | `bats tests/agtoosa.bats -f "DEV-078\|F15-"` exit 0, 8/8 | 0 | AgToosa | 2026-07-11 |
| build | AC-001, AC-003 | spec | `docs/examples/first-15-minutes.md`, `docs/examples/public-launch-proof.md`, `README.md` | Scoped pins aligned to `v5.3.7`; proof URL canonical | PASS | AgToosa | 2026-07-11 |
| build | AC-001–AC-006 | other | `scripts/check-launch-readiness.sh` | `run_first15_maintenance_gate` before private/public split | PASS | AgToosa | 2026-07-11 |
| review | cross-model | cross-model | `docs/archived/review-DEV-078.md## Cross-Model Review` | Standard tier; outcome skipped; virtual personas sufficient | PASS | AgToosa | 2026-07-11 |
| review | AC-001–AC-006 | review | `docs/archived/review-DEV-078.md` | 4 virtual personas; verdict PASS; 0 unresolved Critical | PASS | AgToosa | 2026-07-11 |
| review | AC-001–AC-006 | test-log | `docs/AgToosa_TestPlan-DEV-078.md#GREEN-Evidence` | `bats tests/agtoosa.bats -f "DEV-078"` exit 0, 8/8 | 0 | AgToosa | 2026-07-11 |
| review | AC-001–AC-006 | verifier | `docs/agtoosa-verify.sh` | `bash agtoosa.sh --verify .` — DEV-078 Gate 3 PASS; 5 WARN accepted | 0 | AgToosa | 2026-07-11 |
