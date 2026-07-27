# Evidence: DEV-132 — Preserve Evidence JSONL on Re-install and Update

> **Story:** DEV-132  
> **Updated:** 2026-07-27 (ship v5.3.46)

| Phase | Kind | Surface | Artifact | Expectation | Result | Actor | Timestamp |
|-------|------|---------|----------|-------------|--------|-------|-----------|
| build | test | bats | EVJ-001–006 | 6/6 green | PASS | AgToosa | 2026-07-27T23:35:00Z |
| review | gate | review-DEV-132.md | 0 Critical | PASS | AgToosa | 2026-07-27T23:40:00Z |
| ship | test | bats | DEV-132 SR-001 | version pins 5.3.46 | PASS | AgToosa | 2026-07-27T23:55:00Z |
| ship | version parity | other | agtoosa.sh · agtoosa.ps1 · npm/package.json · Formula/agtoosa.rb | pins 5.3.46 | PASS | AgToosa | 2026-07-27T23:55:00Z |
| ship | all Must | other | docs/Master-Plan.md | Ship complete — v5.3.46 | PASS | AgToosa | 2026-07-27T23:55:00Z |
