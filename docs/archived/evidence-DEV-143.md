# Evidence Ledger — DEV-143

> **Story:** DEV-143 — Tracker Unlinked Status Finding  
> **Updated:** 2026-07-28 (ship)

| Phase | AC | Artifact | Pointer | Verification | Exit |
|-------|----|----------|---------|--------------|------|
| build | AC-001 | CLI | `agtoosa.sh --tracker status-check` | TUS-001 | 0 |
| build | AC-002 | cache | `.agtoosa/tracker/gh-issues.json` merge | TUS-002 | 0 |
| build | AC-003 | JSON | `unlinked_external[]` + `finding.emit` | TUS-003 | 0 |
| build | AC-004 | classify | mirror skip + closed_external | TUS-004 | 0 |
| build | AC-005 | fixture | greenfield silent skip | TUS-005 | 0 |
| build | AC-006 | severity | `finding.severity` == info | TUS-006 | 0 |
| build | AC-007 | docs | `AgToosa_Status.md` Part 1.9 | TUS-007 | 0 |
| build | — | bats | TUS-001–TUS-008 | filter suite | 0 |
| review | — | review | docs/archived/review-DEV-143.md | PASS 0 critical | 0 |
| ship | — | ship-check | docs/archived/ship-check-DEV-143.md | v5.3.57 | 0 |
| ship | — | release | CHANGELOG 5.3.57 | version parity | 0 |
