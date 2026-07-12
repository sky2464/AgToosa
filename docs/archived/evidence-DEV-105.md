# Evidence Ledger — DEV-105

> **Story:** DEV-105 — PowerShell Maintain + Update Parity  
> **Claim Boundary:** bats greps generator-enforced; bash scripts remain authoritative for verify/doctor/update  
> **Updated:** 2026-07-12 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| build | AC-004,008,009 | test-log | docs/AgToosa_TestPlan-DEV-105.md | bats -f "DEV-105\|PSP-" GREEN 5/5 | 0 | AgToosa | 2026-07-12T15:53:00Z |
| build | AC-001–007 | test-log | tests/pester/agtoosa-maintain.Tests.ps1 | Invoke-Pester PassedCount 6 | 0 | AgToosa | 2026-07-12T15:53:00Z |
| build | AC-001–006 | other | agtoosa.ps1 | Invoke-AgToosaMaintain + UpdatePath gate | 0 | AgToosa | 2026-07-12T15:53:00Z |
| review | AC-001–009 | review | docs/archived/review-DEV-105.md | 4-persona + cross-model; 0 critical | 0 | AgToosa | 2026-07-12T16:10:00Z |
| review | AC-001–009 | test-log | docs/AgToosa_TestPlan-DEV-105.md | bats PSP 5/5 + Pester 6/6 | 0 | AgToosa | 2026-07-12T16:10:00Z |
| review | — | cross-model | docs/archived/review-DEV-105.md## Cross-Model Review | Independent subagent; Recommended tier | 0 | AgToosa | 2026-07-12T16:10:00Z |
| ship | AC-001–009 | test-log | docs/AgToosa_TestPlan-DEV-105.md | bats PSP + Pester smoke PASS | 0 | AgToosa | 2026-07-12T18:22:39Z |
| ship | AC-001–009 | release | CHANGELOG.md · agtoosa.sh AGTOOSA_VERSION | v5.3.17 Wave 1a; bash agtoosa.sh --version | 0 | AgToosa | 2026-07-12T18:22:39Z |
| ship | AC-001–009 | other | docs/Master-Plan.md | Ship complete — v5.3.17; Milestone v5.3.18 (next) | 0 | AgToosa | 2026-07-12T18:22:39Z |
