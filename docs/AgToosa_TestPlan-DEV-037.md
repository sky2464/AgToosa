# Test Plan: DEV-037 - Truthful launch documentation and positioning

> **Spec:** `docs/archived/spec-DEV-037.md`
> **Coverage target:** dependency truth, enforcement boundaries, competitor decision guide, current security policy, macOS guidance
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-037"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-002 | TD-001 | Docs | README distinguishes generator prerequisites, target-app runtime, and agent-instructed workflow guidance | yes |
| AC-003, AC-004, AC-007 | TD-002 | Docs | README contains dated decision guide and right-fit/wrong-fit positioning for named competitors | yes |
| AC-005 | TD-003 | Docs | `SECURITY.md` no longer supports only `2.x` or lists deprecated `install.sh` as active surface | yes |
| AC-006 | TD-004 | Docs/Shell | `bootstrap.sh` no longer claims "macOS 26+ ships with bash 5.2+" and shellcheck remains clean | no |
| AC-001-AC-007 | TD-005 | Regression | Focused docs checks and `git diff --check` pass | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-037"
shellcheck -x -S warning --exclude=SC2002,SC2046,SC2086,SC1091,SC2034 bootstrap.sh
git diff --check
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-037"
=> 5/5 passing

shellcheck bootstrap.sh
=> exit 0 through full shellcheck command
```
