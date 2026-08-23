# Test Plan: DEV-136 — IDE Host Mode Bridge for Spec and Review

> Spec reference: [spec-DEV-136.md](archived/spec-DEV-136.md) (pending archive on ship)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | IDE-001, IDE-007 | Integration | Canonical spec + adapters require native plan mode before interview | yes |
| AC-002 | IDE-001, IDE-012 | Integration | Plan mode forbids spec artifact writes; no mid-interview auto-switch | yes |
| AC-003 | IDE-003, IDE-006, IDE-010 | Integration | HOST-MODE handoff + product-truth host_mode_policy on spec | yes |
| AC-004 | IDE-002, IDE-008 | Integration | Review workflow + adapters use plan mode for briefing | yes |
| AC-005 | IDE-002, IDE-008 | Integration | Review adapters switch to agent for verdict writes | yes |
| AC-006 | IDE-003, IDE-011, NLM-001 | Integration | Compass prefers native plan mode (supersedes block rule) | yes |
| AC-007 | IDE-007, IDE-008 | Integration | All declared spec/review adapters include Host Mode Execution | yes |
| AC-008 | IDE-001–IDE-012 | Regression | DEV-136 bats section green | yes |

## Bats Mapping

| Test ID | bats name |
|---------|-----------|
| IDE-001 | `IDE-001: canonical spec workflow contains IDE Host Mode Bridge` |
| IDE-002 | `IDE-002: canonical review workflow contains IDE Host Mode Bridge` |
| IDE-003 | `IDE-003: Agent mirrors prefer native IDE plan mode for spec and review` |
| IDE-004 | `IDE-004: AgentCapability documents IDE Host Mode Matrix` |
| IDE-005 | `IDE-005: ADR-020 IDE Host Mode Bridge exists` |
| IDE-006 | `IDE-006: maintainer Agent mirror contains IDE Host Mode Bridge` |
| IDE-007 | `IDE-007: native spec adapters reference Host Mode Execution` |
| IDE-008 | `IDE-008: native review adapters reference Host Mode Execution` |
| IDE-009 | `IDE-009: product-truth spec and review declare host_mode_policy` |
| IDE-010 | `IDE-010: rendered spec adapter includes host mode product-truth lines` |
| IDE-011 | `IDE-011: agtoosa-core and maintainer-core reference IDE Host Mode Bridge` |
| IDE-012 | `IDE-012: contract forbids mid-interview auto-switch` |

## Regression

- NLM-001 updated: greps `IDE Host Mode Bridge` instead of `Do not use Cursor native Plan mode`
- DEV-028 T-001–T-010, DEV-126 T-001–T-008, CS1–CS5 unchanged
