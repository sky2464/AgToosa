# Test Plan: DEV-128 — Smart Upgrade Platform Selection & Version Guards

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | UPG-001 | Integration | Multi-platform upgrade + input `1` → lock `platforms` is `["cursor"]` only | yes |
| AC-003 | UPG-002 | Integration | Installed v5.3.36 + generator v5.3.34 → exit non-zero, mentions updating generator | yes |
| AC-005 | UPG-003 | Unit | Escape garbage in platform input treated as `1` | yes |
| AC-004 | UPG-004 | Integration | `--platforms cursor --yes` on multi-platform install → cursor only in lock | yes |
| AC-006 | UPG-005 | Integration | All platforms installed → change-platform prompt still emitted | yes |
| AC-003 | UPG-006 | Integration | Downgrade blocked on `--update` path | yes |

```bash
bats tests/agtoosa.bats -f "UPG-"
```

Pester mirrors: UPG-001, UPG-002 in `tests/pester/agtoosa-install.Tests.ps1`.
