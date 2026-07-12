# Evidence Ledger — DEV-113

> **Story:** DEV-113 — Cursor Intake Hardening + Fixture Parity  
> **Claim Boundary:** CI fixture parity + template entry-point + bats ship isolation  
> **Updated:** 2026-07-12 (review)

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|-----|----------|---------|--------------|------|----------|-----|
| build | AC-001–AC-007 | test-log | `docs/AgToosa_TestPlan-DEV-113.md` | `bats -f "FIX-001|CIT-|NLM-"` 10/10 | 0 | AgToosa | 2026-07-12 |
| build | AC-005 | test-log | `docs/AgToosa_TestPlan-DEV-113.md` | full bats 950×3 | 0 | AgToosa | 2026-07-12 |
| review | AC-001–AC-008 | review | `docs/archived/review-DEV-113.md` | PASS; 0 Critical; 3 Warning accepted | PASS | AgToosa | 2026-07-12 |
| review | AC-001–AC-007 | test-log | review re-run | `bats -f "FIX-001|CIT-|NLM-|declining copy|ship/ is cleaned"` 14/14 | 0 | AgToosa | 2026-07-12 |
| ship | AC-001–AC-007 | test-log | `docs/AgToosa_TestPlan-DEV-113.md` | `bats -f "FIX-001|CIT-|NLM-|DEV-113"` smoke PASS | 0 | AgToosa | 2026-07-12 |
| ship | release | other | `CHANGELOG.md` | `## [5.3.26]` DEV-113 entry | PASS | AgToosa | 2026-07-12 |
| ship | version parity | other | `agtoosa.sh` · `agtoosa.ps1` · `npm/package.json` | pins 5.3.26; DEV-113 SR-001 | PASS | AgToosa | 2026-07-12 |
