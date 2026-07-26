# Handoff Pack — DEV-123 — minimal fixture

> **Story:** DEV-123 — Guarded Portable Execution spike
> **Exported:** 2026-07-26 20:00
> **Target agent:** Cursor
> **Claim Boundary:** agent-instructed export; manual launch; import via /agtoosa-import

## 1. Story & Goal

Validate portable execution capsules with scope, policy, budgets, and safe evidence return.

## 2. Acceptance Criteria

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN a capsule is authored THE SYSTEM SHALL conform to execution-capsule-v1 schema | Must |
| AC-002 | WHEN a return envelope is validated THE SYSTEM SHALL enforce scope, budgets, and policy | Must |

## 3. Files in Scope

- `lib/capsule.sh`
- `lib/capsule-exporters/manual-handoff.sh`
- `contracts/execution-capsule-v1.schema.json`

## 4. Allowed Actions

- Edit only files listed in §3
- Run verification commands in §5
- Do **not** modify `docs/Master-Plan.md` Active Cycle status without import review

## 5. Verification Commands

```bash
bats -f GPE
```

## 6. Return Contract

Return artifacts that `/agtoosa-import` can map to tasks and ACs:

- Changed file list
- Test log excerpt (command + exit code)
- Mapped ACs: AC-001 → evidence pointer, AC-002 → evidence pointer

## 7. Out of Scope

- Native sandbox claims
- Secret values in fixtures
- Default network access

## 8. Work Packages

| package_id | wave | depends_on | owned_files | verification |
|------------|------|------------|-------------|--------------|
| PKG-1.1 | 1 | — | lib/capsule.sh | bats -f GPE |

## 9. Applicable Policy

- `policy_path=none`
- no extra policy configured
