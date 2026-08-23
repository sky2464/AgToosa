# Test Plan: DEV-074 — PS1 non-interactive install parity

| AC ID | Priority | Test ID | Type | Description |
|-------|----------|---------|------|-------------|
| AC-001 | Must | PS-001 | bats grep | `agtoosa.ps1` defines `-Path`, `-Platforms`, `-Yes` parameters |
| AC-001 | Must | PS-002 | bats/pwsh smoke | Non-interactive install writes `Docs/AgToosa_Agent.md` without stdin |
| AC-002 | Must | PS-003 | bats/pwsh | Unknown platform in `-Platforms` exits non-zero |
| AC-003 | Must | PS-004 | pester | `-Yes` without `-Path` fails |
| AC-004 | Must | PS-005 | pwsh smoke | `Docs/.agtoosa-version` matches generator version |
| AC-005 | Must | PS-001 | bats grep | Usage documents new switches |
| AC-006 | Should | PE-001 | pester | `tests/pester/agtoosa-install.Tests.ps1` happy path |
| AC-006 | Should | PE-002 | pester | Unknown platform rejection |

## RED / GREEN evidence

| Test ID | RED (pre-build) | GREEN (post-build) |
|---------|-----------------|-------------------|
| CT-001 | missing `-Path`/`-Platforms`/`-Yes` in `param()` | grep pass |
| CT-002 | `Show-Usage` missing NI switches | grep pass |
| CT-003 | pwsh install required stdin | `pwsh -Path … -Platforms claude -Yes` exit 0 |
| CT-004 | unknown platform not rejected | exit non-zero + error text |
| NI-001 | Pester install fails | exit 0 + `CLAUDE.md` present |
| NI-002 | unknown platform accepted | exit non-zero |
| NI-003 | `-Yes` alone succeeds | exit non-zero |
| NI-004 | version file missing/wrong | matches `$AGTOOSA_VERSION` |
| NI-005 | `-DryRun` still copies | target docs absent after dry run |

**Verification (2026-07-08):** `bats tests/agtoosa.bats -f "DEV-074"` and `Invoke-Pester tests/pester/agtoosa-install.Tests.ps1` — all green when `pwsh` available.
