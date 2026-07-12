# Evidence Ledger — DEV-104

> **Story:** DEV-104 — `--reinstall --clean` (ADR-004 Option C)  
> **Claim Boundary:** bats RCL generator-enforced; archive is local filesystem evidence; user-edit preservation not guaranteed  
> **Updated:** 2026-07-12 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| build | AC-001–008 | test-log | docs/AgToosa_TestPlan-DEV-104.md | RED: `bats tests/agtoosa.bats -f "DEV-104\|RCL-"` — unknown option / missing switches pre-impl | 1 | AgToosa | 2026-07-12T19:05:00Z |
| build | AC-001–008 | test-log | docs/AgToosa_TestPlan-DEV-104.md | GREEN: `bats tests/agtoosa.bats -f "DEV-104\|RCL-"` 8/8 | 0 | AgToosa | 2026-07-12T19:11:30Z |
| build | AC-001–006 | other | lib/reinstall.sh · agtoosa.sh | `--reinstall --clean` archive + regen + lock rewrite + `--yes` gate | 0 | AgToosa | 2026-07-12T19:11:30Z |
| build | AC-007 | other | agtoosa.ps1 | `-Reinstall -Clean` → bash `--reinstall --clean` | 0 | AgToosa | 2026-07-12T19:11:30Z |
| build | AC-008 | other | docs/AgToosa_Update.md · template/Docs/AgToosa_Update.md | `--update` default; `--reinstall --clean` optional Option C | 0 | AgToosa | 2026-07-12T19:11:30Z |
| review | AC-001–008 | review | docs/archived/review-DEV-104.md | 4-persona + cross-model; 0 critical | 0 | AgToosa | 2026-07-12T20:30:00Z |
| review | AC-001–008 | test-log | docs/AgToosa_TestPlan-DEV-104.md | bats -f "DEV-104\|RCL-" 8/8 | 0 | AgToosa | 2026-07-12T20:28:00Z |
| review | — | cross-model | docs/archived/review-DEV-104.md## Cross-Model Review | Independent subagent completed | 0 | AgToosa | 2026-07-12T20:30:00Z |

## Terminal Evidence

### RED (pre-implementation)

```
1..8
ok 1 DEV-104 @smoke RCL-001: Confirmation Required   # false-positive on Unknown option + help --yes (tightened)
not ok 2–6  # status≠0 — unknown option --reinstall
not ok 7 DEV-104 RCL-007: PowerShell Parity  # missing [switch]$Reinstall
not ok 8 DEV-104 RCL-008: Update Docs Positioning  # missing --reinstall --clean
```

### GREEN

```
1..8
ok 1 DEV-104 @smoke RCL-001: Confirmation Required
ok 2 DEV-104 RCL-002: Archive Manifest Written
ok 3 DEV-104 @smoke RCL-003: Fresh Regeneration
ok 4 DEV-104 @smoke RCL-004: Lock File Rewritten
ok 5 DEV-104 RCL-005: Unmarked Edit Warning
ok 6 DEV-104 RCL-006: Idempotent Second Run
ok 7 DEV-104 RCL-007: PowerShell Parity
ok 8 DEV-104 RCL-008: Update Docs Positioning
EXIT:0
```

Command: `bats tests/agtoosa.bats -f "DEV-104|RCL-"` (elapsed ~49s)

| ship | AC-001+ | test-log | docs/AgToosa_TestPlan-DEV-104.md | bats -f "DEV-104|RCL-" smoke PASS | 0 | AgToosa | 2026-07-12T21:45:00Z |
| ship | AC-001+ | release | CHANGELOG.md · AGTOOSA_VERSION | v5.3.20 Wave 3; bash agtoosa.sh --version | 0 | AgToosa | 2026-07-12T21:45:00Z |
| ship | AC-001+ | other | docs/Master-Plan.md | Ship complete — v5.3.20; Milestone v5.3.21 (next) | 0 | AgToosa | 2026-07-12T21:45:00Z |
