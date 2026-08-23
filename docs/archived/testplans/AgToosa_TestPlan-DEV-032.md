# Test Plan: DEV-032 — Patch-first release versioning

> **Spec:** `docs/archived/spec-DEV-032.md`
> **Coverage target:** doc contract (structural bats)
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-032"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-002 | VP-001 | Integration | Maintainer Release Checklist contains bump decision tree and PATCH default | yes |
| AC-003 | VP-002, VP-003 | Integration | Canonical ship doc (template + maintainer mirror) references version bump / patch-first | yes |
| AC-004 | VP-004 | Integration | Canonical review doc instructs PATCH+1 default for ship suggestion | yes |
| AC-006 | VP-005 | Integration | ADR-005 exists and references patch-first cadence | yes |
| AC-005 | — | Manual | Master-Plan Milestone `v5.2.1 (next)` while AGTOOSA_VERSION 5.2.0 | no |
| AC-001, AC-008 | — | Manual | First ship after merge uses 5.2.1 for S chore | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-032"
bats tests/agtoosa.bats
```
