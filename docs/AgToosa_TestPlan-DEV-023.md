# Test Plan: DEV-023 — Workflow Native Slash Parity Audit

> **Spec:** `docs/archived/spec-DEV-023.md`
> **Coverage target:** 80%
> **Smoke filter:** `bats tests/agtoosa.bats -f "WP[1-5]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (WP1) | Unit | Each platform has 14 `agtoosa-*` native adapter files | yes |
| AC-002 | T-002 (WP2) | Unit | Adapters reference `Docs/AgToosa_` and forbid `/create-skill` for workflows | yes |
| AC-003 | T-003 (WP3) | Unit | Ship adapters mention `check` / Part 0 read-only where applicable | yes |
| AC-004 | T-004 (WP4) | Unit | `lib/config.sh` inventory paths exist on disk | yes |
| AC-005 | T-005 (WP5) | Unit | Codex `OPENCODE.md` / prompts reserve `agtoosa-*` | yes |

## Commands

```bash
bats tests/agtoosa.bats -f "WP[1-5]:"
```
