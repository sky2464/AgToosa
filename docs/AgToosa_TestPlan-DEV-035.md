# Test Plan: DEV-035 - Launch P0 publication and quickstart gate

> **Spec:** `docs/archived/spec-DEV-035.md`
> **Coverage target:** private/public launch mode, quickstart truthfulness, support intake readiness
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-035"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-004 | LG-001 | Docs | README states private staging, labels public commands as launch-target, and places pinned release before `main` | yes |
| AC-002, AC-003 | LG-002 | Integration | Launch checker supports private and public modes and defaults to private mode | yes |
| AC-002 | LG-003 | Integration | Private mode validates local docs without requiring public URLs to return 2xx | yes |
| AC-003 | LG-004 | Static | Public mode URL list includes repo, releases, raw bootstrap, registry, issues, discussions, support, and Homebrew-if-advertised surfaces | no |
| AC-005 | LG-005 | Docs | Support templates request OS, shell, install command, AgToosa version, target project context, and affected surface | no |
| AC-006 | LG-006 | Integration | Focused DEV-035 Bats filter covers launch-gate regression checks | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-035"
bash scripts/check-launch-readiness.sh --mode private
git diff --check
```

Public launch verification after repo publication:

```bash
AGTOOSA_LAUNCH_MODE=public bash scripts/check-launch-readiness.sh
```

## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-035"
=> 6/6 passing

bash scripts/check-launch-readiness.sh --mode private
=> exit 0; local docs checked; public URL checks skipped
```
