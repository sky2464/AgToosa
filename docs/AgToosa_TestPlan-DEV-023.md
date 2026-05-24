# Test Plan: DEV-023 — Workflow Template Native Slash Parity Audit

> **Spec:** `docs/archived/spec-DEV-023.md`
> **Coverage target:** Matrix parity across six native surfaces
> **Smoke filter:** `bats tests/agtoosa.bats -f "WP[1-5]:"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 (WP1) | Integration | `lib/config.sh` inventory paths exist under `template/` and appear in `--list-template-files` | yes |
| AC-001 | T-002 (WP2) | Integration | Each surface has exactly 14 `agtoosa-*` native adapters | yes |
| AC-002 | T-003 (WP3) | Integration | Ship adapters on all six surfaces delegate `check` to read-only Part 0 | yes |
| AC-004 | T-004 (WP4) | Integration | Init/Spec/Skills collision guardrails reference all six adapter path patterns | yes |
| AC-004 | T-005 (WP5) | Integration | `OPENCODE.md` documents Codex prompts/skills and forbids `/create-skill` routing | yes |

## Regression slices (platform stories)

After WP green, spot-check prior platform filters still pass:

```bash
bats tests/agtoosa.bats -f "CU[1-5]:|WS[1-5]:|GM[1-5]:|CX[1-5]:|G[1-5]:"
```

## Commands

```bash
bats tests/agtoosa.bats -f "WP[1-5]:"
bats tests/agtoosa.bats
```
