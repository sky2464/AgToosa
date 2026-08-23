# Test Plan: DEV-027 — Agentic `/agtoosa-update`

> **Spec:** `docs/archived/spec-DEV-027.md`
> **Coverage target:** 100% Must ACs (per `docs/Context/workflow.md`)

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001 | T-001 | Integration | Canonical update workflow defines Detect → Plan → Apply → Verify and default ask-then-apply behavior | yes |
| AC-002 | T-002 | Integration | Canonical workflow tells the agent to prepare `bash agtoosa.sh --update <project>` and show planned overwrites, merges, native refreshes, preserved files, and backups | yes |
| AC-003 | T-003 | Integration | Canonical workflow requires explicit approval before any mutating Apply command | yes |
| AC-004 | T-004 | Integration | Verification wording covers version marker, lock metadata when present, platform surfaces, preserved files, and duplicate marker safety | yes |
| AC-005 | T-005 | Integration | `/agtoosa-update check` remains read-only and produces a project briefing without shell commands or mutation | yes |
| AC-006 | T-006 | Integration | `plan`, `apply`, and `verify` sub-command stop conditions are documented | yes |
| AC-007 | T-007 | Integration | Claude, Cursor, Gemini, Copilot, Windsurf, and Codex/OpenCode adapters share the same canonical update contract and do not call the default read-only | yes |
| AC-008 | T-008 | Integration | Preflight wording covers dirty git state, malformed markers, backups, missing `Docs/`, lock-file issues, platform drift, and major-version migration risk | no |
| AC-009 | T-009 | Integration | Migration wording surfaces major-version and known breaking-change guidance before Apply | no |

## Negative / Edge Scenarios

| ID | Scenario | Expected |
|----|----------|----------|
| T-001-N | Remove Detect → Plan → Apply → Verify wording from `AgToosa_Update.md` | DEV-027 focused bats test fails |
| T-003-N | Remove explicit approval wording before Apply | Approval-gate assertion fails |
| T-005-N | Change `check` mode to allow shell commands or mutation | Read-only check assertion fails |
| T-007-N | Leave an adapter describing `/agtoosa-update` as pure read-only or unapproved sync | Adapter parity assertion fails |
| T-008-N | Remove malformed marker or dirty git state from preflight list | Preflight assertion fails |
| T-009-N | Remove major-version migration guidance | Migration assertion fails |

## Smoke Set

T-001, T-002, T-003, T-004, T-005, T-006, T-007

## Evidence (build)

| Test ID | Bats test name | Result |
|---------|----------------|--------|
| T-001 | `T-001: canonical update workflow defines Detect Plan Apply Verify and ask-then-apply` | pass |
| T-002 | `T-002: canonical update workflow documents CLI update and planned changes` | pass |
| T-003 | `T-003: canonical update workflow requires explicit approval before Apply` | pass |
| T-004 | `T-004: canonical update verification covers marker lock platform preserve duplicate` | pass |
| T-005 | `T-005: agtoosa-update check sub-command is read-only briefing only` | pass |
| T-006 | `T-006: agtoosa-update plan apply verify sub-command stop conditions documented` | pass |
| T-007 | `T-007: update adapters share Detect Plan Apply Verify and forbid default pure read-only` | pass |
| T-008 | `T-008: update preflight covers git markers backups Docs lock platform drift migration` | pass |
| T-009 | `T-009: update migration guidance surfaces breaking changes before Apply` | pass |

**Regression (AC-004 CLI):** existing `--update` bats (`--update preserves Docs/Context/`, `RG3: Case B second --update leaves one AgToosa START block`, MA4/MA5) — pass in filtered run except pre-existing `--update after fresh install shows real version not 'vunknown'` (version string drift unrelated to DEV-027).

**Command:** `bats tests/agtoosa.bats --filter 'T-00|agtoosa-update check mode|MA4:|--update'` → 28/29 pass (1 pre-existing version-display flake).
