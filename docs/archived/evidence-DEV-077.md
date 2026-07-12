# Evidence Ledger — DEV-077

> **Story:** DEV-077 — Authoring Guide and Onboarding Surface  
> **Claim Boundary:** agent-instructed index; Master-Plan remains SoT  
> **Updated:** 2026-07-11 21:30 (review)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|-----|----------|---------|--------------|------|----------|-----|
| build | AC-001–AC-007 | test-log | `docs/AgToosa_TestPlan-DEV-077.md` | `bats tests/agtoosa.bats -f "DEV-077\|AUTH-"` exit 0, 8/8 AUTH-001–AUTH-008 GREEN | 0 | AgToosa | 2026-07-11T21:25:00-05:00 |
| build | AC-001 | spec | `docs/extension-authoring-guide.md` | Platform inventory + parity checks + maintained examples | PASS | AgToosa | 2026-07-11T21:25:00-05:00 |
| build | AC-002, AC-007 | spec | `docs/registry-pack-authoring.md` | Seven-field readiness checklist + Claim Boundary | PASS | AgToosa | 2026-07-11T21:25:00-05:00 |
| build | AC-003 | spec | `docs/AgToosa_Registry.md`, `template/Docs/AgToosa_Registry.md` | Handbook pointer only; no `## Readiness Checklist` | PASS | AgToosa | 2026-07-11T21:25:00-05:00 |
| build | AC-004 | spec | `README.md` | Concise links to extension + pack authoring | PASS | AgToosa | 2026-07-11T21:25:00-05:00 |
| build | AC-005 | spec | `template/**/agtoosa-help*` | Authoring resources GitHub URLs; static default path | PASS | AgToosa | 2026-07-11T21:25:00-05:00 |
| review | cross-model | cross-model | `docs/archived/review-DEV-077.md## Cross-Model Review` | Standard tier; outcome skipped; virtual personas + AUTH bats sufficient | PASS | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-001 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-001` | `bats tests/agtoosa.bats -f "AUTH-001"` extension guide inventory | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-002 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-002` | `bats tests/agtoosa.bats -f "AUTH-002"` @smoke readiness checklist | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-003 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-003` | `bats tests/agtoosa.bats -f "AUTH-003"` Registry non-duplication | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-004 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-004` | `bats tests/agtoosa.bats -f "AUTH-004"` README discovery | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-005 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-005` | `bats tests/agtoosa.bats -f "AUTH-005\|AUTH-006"` @smoke help parity + static help | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-006 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-006` | `bats tests/agtoosa.bats -f "AUTH-007"` @smoke link fail-closed | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-007 | test-log | `docs/AgToosa_TestPlan-DEV-077.md#AC-007` | `bats tests/agtoosa.bats -f "AUTH-008"` enforcement honesty | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-001–AC-007 | review | `docs/archived/review-DEV-077.md` | 4 virtual personas; verdict PASS; 0 unresolved Critical | PASS | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-001–AC-007 | verifier | `docs/agtoosa-verify.sh` | Gate 3 DEV-077 PASS; Wave Plan / Active Tasks WARNs accepted | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
| review | AC-001–AC-007 | test-log | `bats tests/agtoosa.bats -f "DEV-077"` | Full AUTH filter re-run at review | 0 | AgToosa | 2026-07-11T21:30:00-05:00 |
