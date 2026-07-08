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
