# Evidence: DEV-128 — Smart Upgrade Platform Selection & Version Guards

> **Story:** DEV-128  
> **Updated:** 2026-07-26 (ship v5.3.41)

| Phase | Kind | Surface | Artifact | Expectation | Result | Actor | Timestamp |
|-------|------|---------|----------|-------------|--------|-------|-----------|
| build | test | bats | UPG-001–UPG-006 | 6/6 green | PASS | AgToosa | 2026-07-26T22:35:00Z |
| build | test | pester | DEV-128 UPG-001 + UPG-002 | 2/2 green | PASS | AgToosa | 2026-07-26T22:35:00Z |
| review | gate | review-DEV-128.md | 0 Critical | PASS | AgToosa | 2026-07-26T22:36:00Z |
| ship | release | other | CHANGELOG.md | `## [5.3.41]` DEV-128 entry | PASS | AgToosa | 2026-07-26T22:37:00Z |
| ship | release | other | CHANGELOG.md | `## [5.3.42]` hotfix entry | PASS | AgToosa | 2026-07-26T22:50:00Z |
| ship | version parity | other | agtoosa.sh · agtoosa.ps1 · npm/package.json · Formula/agtoosa.rb | pins 5.3.42 | PASS | AgToosa | 2026-07-26T22:50:00Z |
| ship | all Must | other | docs/Master-Plan.md | Ship complete — v5.3.41 | 0 | AgToosa | 2026-07-26T22:37:00Z |
