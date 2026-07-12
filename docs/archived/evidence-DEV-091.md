# Evidence Ledger — DEV-091

> **Story:** DEV-091 — Migration Wizard + Rollback Manifest  
> **Claim Boundary:** generator-enforced MAJOR gate + dry-run plan; rollback manifest is evidenced artifact (manual restore)  
> **Updated:** 2026-07-12 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| build | AC-001–008 | test-log | docs/AgToosa_TestPlan-DEV-091.md | bats -f "DEV-091\|MWZ-" RED then GREEN 10/10 | 0 | AgToosa | 2026-07-12T18:40:00Z |
| build | AC-001–007 | other | lib/migrate.sh | MAJOR gate, plan categories, rollback manifest | 0 | AgToosa | 2026-07-12T18:40:00Z |
| build | AC-007 | other | agtoosa.sh `--json` | AC-007 literal `--json` alias of `--format json` on update migration path | 0 | AgToosa | 2026-07-12T18:40:00Z |
| build | AC-009 | other | template/Docs/AgToosa_Update.md · docs/AgToosa_Update.md | MAJOR wizard section + rollback docs | 0 | AgToosa | 2026-07-12T18:40:00Z |
| build | AC-009 | test-log | MWZ-001–010 | `bats tests/agtoosa.bats -f "DEV-091\|MWZ-"` → 10/10 ok | 0 | AgToosa | 2026-07-12T18:40:00Z |
| review | all Must | review | docs/archived/review-DEV-091.md | 4-persona; 0 critical | 0 | AgToosa | 2026-07-12T18:32:07Z |
| ship | all Must | test-log | docs/AgToosa_TestPlan-DEV-091.md | MWZ-001–010 10/10 smoke PASS | 0 | AgToosa | 2026-07-12T18:32:07Z |
| ship | all Must | release | CHANGELOG.md · AGTOOSA_VERSION | v5.3.18; bash agtoosa.sh --version | 0 | AgToosa | 2026-07-12T18:32:07Z |
