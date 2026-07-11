# Test Plan: DEV-053 — Extension and Preset Catalog

> **Spec:** `docs/archived/spec-DEV-053.md`
> **Future smoke filter:** `bats tests/agtoosa.bats -f "DEV-053"`
> **Status:** ⬜ Backlog
> **Evidence state:** Not executed

## Coverage Target

Prove that Catalog discovery and preset planning are useful, deterministic, and safe while the existing Registry remains authoritative for pack metadata and installation.

All Must acceptance criteria are mapped below. Test IDs PC-001–PC-008 are planned names, not existing or passing tests.

| AC | Test ID | Type | Planned assertion | Automation state |
|----|---------|------|-------------------|------------------|
| AC-001, AC-002 | PC-001 | Bats / schema | Valid extension and preset entries require identity, ownership, compatibility, trust, provenance, examples, and exact registry pins; missing or duplicate fields fail. | planned @smoke |
| AC-003 | PC-002 | Bats / compatibility | Version, platform, capability, conflict, and deprecation inputs produce reasoned `compatible`, `incompatible`, or `unknown` results. | planned @smoke |
| AC-004 | PC-003 | Docs / output | Curation tier, registry verification, checksum, and signature state render separately with no security-guarantee language. | planned |
| AC-005 | PC-004 | Bats / authority | Registry/catalog version, URL, hash, verification, or signature drift marks an entry stale and prevents a ready plan; registry values win. | planned @smoke |
| AC-006, AC-007 | PC-005 | Bats / behavior | `list`, `search`, and `info` are read-only; `plan` resolves ordered pinned members and prints commands without download, queue, merge, or install. | planned @smoke |
| AC-008 | PC-006 | Integration / evidence | At least three production entries—not fixtures—have owners and pass schema, compatibility, registry-reference, offline install-fixture, provenance, and maintenance-contact checks. | planned @smoke |
| AC-009 | PC-007 | Bats / security | Unknown command fields, traversal, duplicate IDs, cycles, invalid ranges, injection tokens, and unbounded text fail before plan generation. | planned @smoke |
| AC-010, AC-011, AC-012 | PC-008 | Integration / evidence | Config and thin adapters route to canonical Catalog docs, Registry is cross-linked rather than duplicated, RED/GREEN is captured, and claims stay within v1. | planned |

## Fixture Matrix

| Fixture | Purpose | Expected result |
|---------|---------|-----------------|
| `tests/fixtures/catalog/valid-extension.json` | Complete pinned extension | Schema valid; evaluated against registry fixture |
| `valid-preset.json` | Ordered preset with two pinned members | Ready plan only when both members reconcile |
| `registry.json` | Offline current registry metadata | Authoritative install metadata for tests |
| `stale-provenance.json` | Catalog hash/version differs from registry | `stale`; no ready plan |
| `incompatible-platform.json` | Requires an absent platform | `incompatible` with reason |
| `unknown-version.json` | Unparseable current project version | `unknown`; no false compatible claim |
| `cyclic-preset.json` | Members form a dependency cycle | Validation failure before expansion |
| `conflicting-preset.json` | Members declare overlapping destinations/capabilities | Conflict report; no ready plan |
| `injection-entry.json` | Command field, shell metacharacters, or traversal path | Rejected without command generation |
| `oversized-entry.json` | Text or member count exceeds documented bound | Bounded validation failure |

## Three-Entry Shipping Gate

Fixture coverage cannot satisfy AC-008. Populate this table only after production entries are selected and executed checks exist.

| Slot | Production entry ID | Owner confirmed | Registry reference | Compatibility | Offline install fixture | Provenance | Evidence pointer |
|------|---------------------|-----------------|--------------------|---------------|-------------------------|------------|------------------|
| 1 | Not selected | Not executed | Not executed | Not executed | Not executed | Not executed | Not recorded |
| 2 | Not selected | Not executed | Not executed | Not executed | Not executed | Not executed | Not recorded |
| 3 | Not selected | Not executed | Not executed | Not executed | Not executed | Not executed | Not recorded |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected |
|----------|---------|----------|
| Catalog says `official`; registry says `verified: false` | PC-003, PC-004 | Fields remain separate; plan is not allowed to bypass the verified-pack gate. |
| Signature snapshot says valid; registry signature is absent or changed | PC-004 | Entry is stale; no ready plan. |
| Preset contains one compatible and one incompatible member | PC-002, PC-005 | Whole plan is not ready; incompatible member and reason are listed. |
| Preset stores a raw shell command | PC-007 | Schema rejects the field; commands are generated only from validated pins. |
| Registry cache is unavailable | PC-004 | Discovery may display catalog metadata as unconfirmed; ready plan is withheld. |
| Catalog command runs twice against identical inputs | PC-005 | Ordered output is identical. |
| Three fixture entries validate | PC-006 | Does not satisfy the production-entry shipping gate. |
| Registry safety wording changes | PC-008 | Catalog links the canonical Registry doc and does not maintain a copied rule set. |

## Future Validation Commands

These commands are the intended build-time checks. They have **not** been run for this backlog spec.

```bash
bats tests/agtoosa.bats -f "DEV-053|PC-"
bash agtoosa.sh --catalog validate catalog/catalog.json
bash agtoosa.sh --catalog list
bash agtoosa.sh --catalog info valid-extension
bash agtoosa.sh --catalog plan valid-preset
bats tests/agtoosa.bats
git diff --check
```

PowerShell parity command to exercise after implementation:

```powershell
.\agtoosa.ps1 -Catalog validate -CatalogPath catalog\catalog.json
```

## Evidence

The blocks below are placeholders required for future TDD capture. `Not executed` is not proof of behavior or catalog quality.

### RED evidence — Task 1

| Field | Placeholder |
|-------|-------------|
| Command | `bats tests/agtoosa.bats -f "DEV-053|PC-"` |
| Exit code | Not executed |
| Failure excerpt | Not captured |
| Fixture inventory | Not captured |
| Recorded | Not recorded |

### GREEN evidence — Tasks 2 and 3

| Field | Placeholder |
|-------|-------------|
| Command | `bats tests/agtoosa.bats -f "DEV-053|PC-"` |
| Exit code | Not executed |
| Pass/fail | Not captured |
| Read-only mutation check | Not captured |
| Registry delegation check | Not captured |
| Warnings/errors | Not captured |
| Recorded | Not recorded |

### Production-entry evidence — Task 3.3

| Field | Placeholder |
|-------|-------------|
| Entries tested | Not selected |
| Registry snapshot source | Not captured |
| Offline install-fixture results | Not executed |
| Provenance comparison | Not executed |
| Owner review | Not recorded |

### Regression and claim review — Task 4

| Field | Placeholder |
|-------|-------------|
| Full regression command | `bats tests/agtoosa.bats` |
| Exit code | Not executed |
| `git diff --check` | Not executed |
| Direct catalog installation | Must remain `none` in v1 |
| Claim-boundary reviewer | Not assigned |
| Evidence ledger pointer | Not created |
