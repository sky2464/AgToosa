# Test Plan: DEV-144 — Operational Gitignore Auto-Merge

> **Spec:** `docs/archived/spec-DEV-144.md`
> **Status:** ✅ GREEN
> **Created:** 2026-07-28
> **Test prefix:** `GIG`

## Scope

Fixture-based coverage for idempotent operational `.gitignore` marker merge on install/update, doctor findings for missing markers and tracked operational paths, and contract that workflow surfaces remain committed.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | GIG-001 | Clean install creates .gitignore with marker | Integration | `.gitignore` contains marker + `.agtoosa/` | ✅ GREEN `@smoke` |
| AC-002 | GIG-002 | Update re-run replaces inner block without duplication | Integration | Single `BEGIN AgToosa operational` marker after re-install | ✅ GREEN |
| AC-003 | GIG-003 | Pre-existing user rules outside markers preserved | Integration | `node_modules/` survives merge | ✅ GREEN |
| AC-004 | GIG-004 | Install into repo with no .gitignore | Integration | `.gitignore` created with block | ✅ GREEN `@smoke` |
| AC-005 | GIG-005 | Doctor warns when marker missing | Integration | `--doctor` JSON includes GIG-003 | ✅ GREEN |
| AC-006 | GIG-006 | Doctor warns with rm --cached when state tracked | Integration | `--doctor` JSON includes GIG-004 | ✅ GREEN |
| AC-007 | GIG-008 | GIG smoke subset green | Meta | Section header + test plan present | ✅ GREEN `@smoke` |
| AC-008 | GIG-007 | Ignore block excludes Docs/ and .cursor/ | Contract | Marker block has no workflow paths | ✅ GREEN |

## Smoke Set

- `@smoke GIG-001` — install writes marker block.
- `@smoke GIG-004` — creates `.gitignore` when absent.
- `@smoke GIG-008` — meta regression grep.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-144|GIG-"`
