# Test Plan: DEV-012 — GitHub Slash Command Routing

> **Spec:** `docs/archived/spec-DEV-012.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)
> **Generated:** 2026-05-23

## AC Coverage

| AC ID | Test ID | Category | Description | @smoke |
|-------|---------|----------|-------------|--------|
| AC-001 | T-001 (G1) | Integration | Every GitHub prompt adapter has explicit `name: agtoosa-*` matching its filename stem | yes |
| AC-002 | T-002 (G2) | Integration | GitHub instructions and AgToosa agent state `/agtoosa-*` must not route to `/create-skill` | yes |
| AC-003 | T-003 (G3) | Integration | Init/spec/skills docs reject generated project skills that duplicate `agtoosa-*` workflow names or triggers | yes |
| AC-004 | T-004 (G4) | Integration | `agtoosa-spec.prompt.md` points to `Docs/AgToosa_Spec.md` and preserves phase-stop wording | yes |
| AC-005 | T-005 (G5) | Integration | G-filter tests run as the focused regression suite | yes |

## Negative / Edge Scenarios

| Test ID | Scenario |
|---------|----------|
| T-001-N | Remove `name: agtoosa-spec` from the GitHub prompt file -> G1 fails |
| T-002-N | Remove the no-`/create-skill` routing rule from Copilot instructions -> G2 fails |
| T-003-N | Allow a generated skill named `agtoosa-review` -> G3 fails |
| T-004-N | Remove phase-stop text from `agtoosa-spec.prompt.md` -> G4 fails |

## Execution Commands

```bash
# Narrow DEV-012 filter first
bats tests/agtoosa.bats -f "G[1-5]:"

# Full suite when environment allows
bats tests/agtoosa.bats
```

**Evidence note:** If full install-style tests fail from environment-specific sandbox or TTY constraints, record G1-G5 separately and include the full-suite residual failure text in the review/ship notes.
