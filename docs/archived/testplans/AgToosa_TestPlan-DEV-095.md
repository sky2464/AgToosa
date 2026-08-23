# Test Plan: DEV-095 — Official Pack Expansion

> **Spec:** `docs/archived/spec-DEV-095.md`
> **Status:** 🟩 GREEN
> **Created:** 2026-07-12
> **Test prefix:** `OPE`
> **Prerequisite gate:** DEV-096 pack validation CI green on existing three pilots

## Scope

Five-pack official inventory, `official-react` and `official-security` manifest conformance, per-pack example-repo links, domain separation from `official-web`, isolated install fixtures, registry safety boundaries, maintenance ownership, and honest external-publication state.

## AC Mapping and Named Tests

| AC | Test ID | Named test | Type | Expected result | Status |
|----|---------|------------|------|-----------------|--------|
| AC-001 | OPE-001 | Five-Pack Official Inventory | Docs/contract | Inventory lists exactly five packs with distinct primary domains | 🟩 Pass `@smoke` |
| AC-001, AC-004 | OPE-002 | Web and React Domain Separation | Docs/contract | `official-web` remains stack-agnostic; `official-react` names React/Next/Vite explicitly | 🟩 Pass |
| AC-002 | OPE-003 | New Pack Manifest Conformance | Schema/integration | Both new manifests satisfy DEV-053 `schema_version` 1.0 fields | 🟩 Pass `@smoke` |
| AC-003 | OPE-004 | Per-Pack Example Repo Links | Docs/contract | EXAMPLES.md for each new pack links a reachable example repository | 🟩 Pass |
| AC-005 | OPE-005 | Security Pack Compatibility Honesty | Docs/contract | Security evidence expectations do not claim deterministic SAST enforcement | 🟩 Pass |
| AC-006 | OPE-006 | React Pack Clean Install | Integration | React fixture installs, queues, and merges with expected file set | 🟩 Pass `@smoke` |
| AC-006, AC-007 | OPE-007 | Security Pack Safe Install | Integration/security | Security fixture follows preview, consent, queue, and merge boundaries | 🟩 Pass `@smoke` |
| AC-007 | OPE-008 | Sixth Pack Rejected | Negative | Attempt to register a sixth official pilot pack fails inventory assertion | 🟩 Pass |
| AC-008 | OPE-009 | New Pack Maintenance Contract | Docs/contract | Each new pack records owner, cadence, policy, issue path, deprecation | 🟩 Pass |
| AC-009 | OPE-010 | External Publication State Honesty | Docs/manual boundary | New packs remain local candidate until manual external confirmation | 🟩 Pass |

## Negative and Edge Scenarios

| Scenario | Test ID | Expected result |
|----------|---------|-----------------|
| `official-web` README mentions React-specific hooks as primary guidance | OPE-002 | Non-zero or contract failure — React guidance belongs in `official-react` |
| Example repo URL missing or placeholder | OPE-004 | Non-zero with file and field diagnostics |
| Security pack claims "CI-enforced SAST" without command evidence | OPE-005 | Contract failure naming overclaim |
| Sixth pack directory added under `packs/official-*` | OPE-008 | Inventory assertion fails |
| Inventory text says "externally published" without confirmed record | OPE-010 | Honesty assertion fails |

## Smoke Set

- `@smoke OPE-001` — five-pack inventory ceiling.
- `@smoke OPE-003` — new manifest catalog conformance.
- `@smoke OPE-006` — react pack clean install.
- `@smoke OPE-007` — security pack safe install.

Planned smoke command: `bats tests/agtoosa.bats -f "DEV-095|OPE-"`

## RED Evidence

| Task group | Planned command | Exit code | Failure excerpt |
|------------|-----------------|-----------|-----------------|
| 1. Expansion contract and RED coverage | `bats tests/agtoosa.bats -f "DEV-095\|OPE-"` | 1 | `not ok` OPE-001–OPE-010 — missing `official-react`/`official-security`, count≠5 |
| 2–3. Pack authoring | `bats tests/agtoosa.bats -f "OPE-003\|OPE-006\|OPE-007"` | 1 | Missing `packs/official-react/` or `packs/official-security/` fixtures |

## GREEN Evidence

| Task group | Planned command | Exit code | Pass excerpt |
|------------|-----------------|-----------|--------------|
| 4. Inventory and evidence | `bats tests/agtoosa.bats -f "DEV-095\|OPE-"` | 0 | All 10 OPE tests pass; five-pack inventory documented |
| 4. Pack validation CI | `bash scripts/validate-official-packs.sh --mode private` | 0 | Pack validation passed for 5 official pack(s) |
| Regression | `bats tests/agtoosa.bats -f "OPP-\|PV-"` | 0 | OPP + DEV-096 PV remain green |
