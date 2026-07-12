# Evidence Ledger — DEV-098

> **Story:** DEV-098 — Navigation by User Job  
> **Claim Boundary:** docs + bats NAV contract  
> **Updated:** 2026-07-12 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| build | AC-001–006 | test-log | docs/AgToosa_TestPlan-DEV-098.md | bats -f "DEV-098\|NAV-" GREEN 8/8 | 0 | AgToosa | 2026-07-12 |
| build | AC-001–004 | other | docs/index.md | Start/Use/Trust/Adapt/Maintain job nav | PASS | AgToosa | 2026-07-12 |
| review | AC-001–006 | review | docs/archived/review-DEV-098.md | 4-persona; 0 critical | 0 | AgToosa | 2026-07-12T20:30:00Z |
| review | AC-001–006 | test-log | docs/AgToosa_TestPlan-DEV-098.md | bats -f "DEV-098\|NAV-" 8/8 | 0 | AgToosa | 2026-07-12T20:28:00Z |

| ship | AC-001+ | test-log | docs/AgToosa_TestPlan-DEV-098.md | bats -f "DEV-098|NAV-" smoke PASS | 0 | AgToosa | 2026-07-12T21:45:00Z |
| ship | AC-001+ | release | CHANGELOG.md · AGTOOSA_VERSION | v5.3.20 Wave 3; bash agtoosa.sh --version | 0 | AgToosa | 2026-07-12T21:45:00Z |
| ship | AC-001+ | other | docs/Master-Plan.md | Ship complete — v5.3.20; Milestone v5.3.21 (next) | 0 | AgToosa | 2026-07-12T21:45:00Z |
