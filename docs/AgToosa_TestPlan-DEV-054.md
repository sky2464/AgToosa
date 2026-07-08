# Test Plan: DEV-054 - Signed Registry Provenance

> **Spec:** `docs/archived/spec-DEV-054.md`
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-054"`
> **Status:** 🏁 Shipped (v5.3.5)

## Coverage Target

Prove optional soft-warn minisign provenance for packs and release docs without claiming fail-closed signatures, SBOM, or completed keygen (M-1).

| AC | Test ID | Type | Description | Automated |
|----|---------|------|-------------|-----------|
| AC-001 | SP-001 | Docs | Provenance schema documents packs + releases; minisign primary; cosign alternate | ✅ |
| AC-002 | SP-002 | Bats | Present invalid `.minisig` → warning emitted; install still succeeds when SHA-256 (+ verified) pass | ✅ |
| AC-002 | SP-003 | Bats | Missing `minisign` binary → warning; continue | ✅ |
| AC-003 | SP-004 | Bats | No signature artifact → behavior unchanged (no new failure) | ✅ |
| AC-004 | SP-005 | Docs | Readiness/Trust/Registry classify soft-warn / manual / roadmap; Master-Plan SoT | ✅ |
| AC-005 | SP-002–SP-004 | Bats | Soft-warn contract coverage | ✅ |
| AC-006 | SP-006 | Docs/Integration | Pubkey path + provenance helper + config registration | ✅ |
| AC-007 | SP-007 | Evidence | Ship evidence recorded; M-1 still Manual/Deferred | pending ship |

Adjacent (existing): `DEV-054 CW-017`, `DEV-054 PS-001`–`PS-003` remain regression anchors.

## Negative / edge (Must ACs)

| Scenario | Expected |
|----------|----------|
| Invalid signature + good SHA-256 | WARN, continue |
| Missing minisign binary | WARN, continue |
| Unsigned pack | no new WARN required; existing gates only |
| `AGTOOSA_MINISIGN_PUBKEY` override | used when set |
| Private key file in tree | must not be required or committed for GREEN |

## Validation Commands

```bash
bats tests/agtoosa.bats -f "DEV-054 SP-"
bats tests/agtoosa.bats -f "DEV-054"
git diff --check
```

## Evidence

### RED evidence — Task 1 (contract bats)

Command: `bats tests/agtoosa.bats -f "DEV-054 SP-"` (pre-implementation intent: soft-warn path absent)
Note: Implementation and SP bats landed in the same build wave; GREEN run below is authoritative for soft-warn semantics.

### GREEN evidence — Task 5

```
Command: bats tests/agtoosa.bats -f "DEV-054 SP-"
Exit code: 0
Result: 6/6 ok (SP-001–SP-006)
Date: 2026-07-08
```

Adjacent: `bats tests/agtoosa.bats -f "DEV-054|DEV-065 SC-002|DEV-066 SC-006"` — recorded in build session.

| Phase | Result | Notes |
|-------|--------|-------|
| RED | contract written | SP-001–SP-006 |
| GREEN | ✅ 6/6 | soft-warn path |
| IMPORT | n/a | |
| Review/Ship | pending | evidence ledger at review/ship; M-1 remains Manual/Deferred |
