# Test Plan: DEV-150 — Corporate Runtime Release Asset

| AC | Test ID | Description | Type | Expected |
|----|---------|-------------|------|----------|
| AC-001 | RTA-001 | Pack script produces allowlisted members | Integration | Exact root: agtoosa.sh, agtoosa.ps1, lib/, template/ |
| AC-001 | RTA-003 | No extra paths in archive | Negative | tar -tf rejects unexpected members |
| AC-002 | RTA-004 | SHA256SUMS includes runtime digest | Integration | grep runtime in SHA256SUMS |
| AC-004 | RTA-002 | Size < source archive baseline | Regression | Byte count comparison |
| AC-005 | RTA-005 | readme-reference corporate path | Contract | Runtime URL documented |
| AC-006 | RTA-006 | Spike Phase 2 shipped marker | Contract | Phase 2 status shipped |

Smoke: `bats tests/agtoosa.bats -f "DEV-150|RTA-"`

## RED evidence — RTA-001–RTA-006

Command: `bats tests/agtoosa.bats -f 'RTA-00'`
Exit code: 1
Failure excerpt:

```
not ok 1 DEV-150 @smoke RTA-001: runtime pack contains exactly agtoosa.sh, agtoosa.ps1, lib/, template/ at root
not ok 2 DEV-150 RTA-002: runtime tarball is materially smaller than a full source archive
not ok 3 DEV-150 RTA-003: runtime archive rejects unexpected repo-only members
not ok 4 DEV-150 @smoke RTA-004: release workflow packs runtime tarball and appends its digest to SHA256SUMS
not ok 5 DEV-150 @smoke RTA-005: readme-reference corporate section prefers runtime tarball over source archive
not ok 6 DEV-150 RTA-006: install-corporate-edr-plan Phase 2 marked shipped
```

All 6 fail pre-implementation (scripts/pack-runtime.sh did not exist; workflow/docs not updated) — confirms each test exercises real, not-yet-built behavior.

## GREEN evidence — Task 1 (scripts/pack-runtime.sh) — RTA-001, RTA-002, RTA-003

Command: `bats tests/agtoosa.bats -f 'RTA-001|RTA-002|RTA-003'`
Exit code: 0

```
ok 1 DEV-150 @smoke RTA-001: runtime pack contains exactly agtoosa.sh, agtoosa.ps1, lib/, template/ at root
ok 2 DEV-150 RTA-002: runtime tarball is materially smaller than a full source archive
ok 3 DEV-150 RTA-003: runtime archive rejects unexpected repo-only members
```

Manual size check: `agtoosa-runtime-v5.3.62.tar.gz` = 414K vs `git archive HEAD` full source = ~17.1MB (≈41× smaller).

## GREEN evidence — Task 2 (release-advanced.yml pack + upload) — RTA-004

Command: `bats tests/agtoosa.bats -f 'RTA-004'`
Exit code: 0

```
ok 1 DEV-150 @smoke RTA-004: release workflow packs runtime tarball and appends its digest to SHA256SUMS
```

YAML validated with `ruby -ryaml -e "YAML.load_file(...)"` — valid.
