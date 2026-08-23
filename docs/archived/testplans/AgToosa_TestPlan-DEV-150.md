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
