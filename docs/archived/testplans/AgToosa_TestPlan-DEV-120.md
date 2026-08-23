# Test Plan: DEV-120 — Delivery Proof Fabric

> **Spec:** `docs/archived/spec-DEV-120.md`  
> **Status:** 🟦 Draft — ✅ Pass — DPF-001–DPF-012 green (12/12)  
> **Created:** 2026-07-26  
> **Test prefix:** `DPF`

## Scope

Evidence Provenance v2 contract, JSON schema, `local-hash` proof provider, standalone `agtoosa-proof-verify.sh`, pilot `proof-graph-DEV-119.json`, cross-links, and `lib/config.sh` registration. No Gate 8 / `agtoosa-verify.sh` changes. Network-free; fixture-based tamper cases.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | @smoke |
|----|---------|------------|------|-----------------|--------|
| AC-001 | DPF-001 | Provenance contract defines node and edge types | Docs contract | Six node types + three edge types + SoT boundary | yes |
| AC-002 | DPF-002 | Proof graph schema validates fixture | Schema | Valid fixture passes; invalid fixture fails | yes |
| AC-002 | DPF-003 | Tampered graph fails schema or verify | Security | Missing required fields → non-zero | — |
| AC-003 | DPF-004 | Provider interface documented with exit codes | Docs contract | Interface section + provider registry stub | — |
| AC-004 | DPF-005 | local-hash verifies content-of edges | Integration | SHA-256 match on fixture files | yes |
| AC-005 | DPF-006 | Verify script exits 0 on valid graph | Integration | Pilot or fixture graph PASS | yes |
| AC-006 | DPF-007 | Verify script fails on hash mismatch | Security | Tampered content → exit non-zero + diagnostic | yes |
| AC-006 | DPF-008 | Verify script fails on missing artifact path | Integration | Missing file → exit non-zero | — |
| AC-007 | DPF-009 | Strict snapshot mode fails on HEAD drift | Integration | Stale sha fails; `--allow-stale-snapshot` passes | — |
| AC-008 | DPF-010 | Evidence + Delivery cross-links present | Link contract | Bidirectional boundary language | — |
| AC-009 | DPF-011 | Gate 7 boundary preserved in docs | Claim contract | No Gate 8 wiring; Gate 7 text unchanged in verify.sh grep | — |
| AC-010 | DPF-012 | config.sh registers provenance surfaces | Inventory | Contract, schema, script in file lists | — |
| AC-011 | DPF-010 | Evidence workflow documents graph assembly | Docs contract | Optional assembly + verify command | — |
| AC-012 | DPF-006 | Pilot proof-graph-DEV-119 validates | E2E | Full verify on maintainer pilot graph | yes |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| Unknown node type in graph | DPF-003 | Non-zero with type error |
| Broken edge references unknown node id | DPF-007 | Non-zero naming missing node |
| Empty graph file | DPF-003 | Schema validation failure |
| Graph claims formal proof / Dafny | DPF-001 | Forbidden-claim grep fails |
| Verify script performs network I/O | DPF-006 | No curl/wget in script body |
| Gate 7 section modified for provenance | DPF-011 | `agtoosa-verify.sh` Gate 7 block unchanged |

## Fixtures

| Fixture | Purpose |
|---------|---------|
| `tests/fixtures/proof-graph/valid-minimal.json` | Minimal valid DAG for unit verify |
| `tests/fixtures/proof-graph/tampered-hash.json` | Wrong content-hash → DPF-007 |
| `tests/fixtures/proof-graph/missing-file.json` | Points to absent path → DPF-008 |
| `tests/fixtures/proof-graph/stale-snapshot.json` | HEAD mismatch → DPF-009 |
| `docs/archived/proof-graph-DEV-119.json` | End-to-end pilot (AC-012) |

## Smoke Set

```bash
bats tests/agtoosa.bats -f "DEV-120|DPF-"
```

Tagged smokes: `@smoke DPF-001`, `@smoke DPF-002`, `@smoke DPF-005`, `@smoke DPF-006`, `@smoke DPF-007`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| Pre-implement | `bats tests/agtoosa.bats -f "DEV-120\|DPF-"` | 1 | `not ok … DPF-001` / missing contract |

## GREEN Evidence

| Task group | Command | Exit | Pass excerpt |
|------------|---------|------|--------------|
| Full suite | `bats tests/agtoosa.bats -f "DEV-120\|DPF-"` | 0 | `1..12` all ok |

```
1..12
ok 1 DEV-120 @smoke DPF-001: Provenance contract defines node and edge types
ok 2 DEV-120 @smoke DPF-002: Proof graph schema exists and valid fixture parses
ok 3 DEV-120 DPF-003: Tampered or invalid graph structure fails validation
ok 4 DEV-120 DPF-004: Provider interface documented with exit codes
ok 5 DEV-120 @smoke DPF-005: local-hash verifies content-of edges
ok 6 DEV-120 @smoke DPF-006: Verify script exits 0 on valid graph and pilot
ok 7 DEV-120 @smoke DPF-007: Verify script fails on hash mismatch
ok 8 DEV-120 DPF-008: Verify script fails on missing artifact path
ok 9 DEV-120 DPF-009: Strict snapshot mode fails on HEAD drift
ok 10 DEV-120 DPF-010: Evidence and Delivery cross-links present
ok 11 DEV-120 DPF-011: Gate 7 boundary preserved in verifier
ok 12 DEV-120 DPF-012: config.sh registers provenance surfaces
```

Pilot verify: `bash docs/agtoosa-proof-verify.sh --root . --graph docs/archived/proof-graph-DEV-119.json --allow-stale-snapshot` → exit 0.

## Claim Boundary Notes

- Passing `agtoosa-proof-verify.sh` proves **local content-link integrity** at verification time — not semantic correctness, vulnerability absence, or hosted attestation.
- Stale `repo-snapshot` with `--allow-stale-snapshot` proves graph self-consistency only — not current repo state.
- DEV-121 behavioral certification and DEV-122 drift providers remain out of scope.
