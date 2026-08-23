# Test Plan: DEV-039 - First 15 minutes proof and growth positioning

> **Spec:** `docs/archived/spec-DEV-039.md`
> **Coverage target:** proof walkthrough, README link, artifact clarity
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-039"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-002 | FG-001 | Docs | Walkthrough starts from clean repo and names expected spec/test-plan/review/ship artifacts | yes |
| AC-003 | FG-002 | Docs | Walkthrough distinguishes generator output from agent-instructed work | yes |
| AC-004 | FG-003 | Docs | Walkthrough includes cleanup/reset guidance | no |
| AC-005 | FG-004 | Docs | README links to first-15-minutes proof near quickstart | yes |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-039"
rg -n "first 15 minutes|generator created|agent instructed|cleanup|reset" README.md docs
git diff --check
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-039"
=> 4/4 passing
```
