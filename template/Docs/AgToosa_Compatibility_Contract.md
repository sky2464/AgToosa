# AgToosa Assistant Compatibility Contract

## Objective

Define what **Install-tested**, **Render-tested**, and **Scenario-tested** mean for each assistant platform — distinct from lifecycle **routing** in `Docs/AgToosa_AgentCapability.md` (DEV-055).

> **Authority split:** Lifecycle routing (handoff / review / cross-model / specialists) remains in `AgToosa_AgentCapability.md`. Compatibility tiers and evidence live **only** in this document. Do not merge the tier table into AgentCapability.

## Tier Definitions

| Tier | Meaning | Evidence required |
|------|---------|-------------------|
| **Install-tested** | Generator creates/merges expected files for the platform | Install/update bats or fixture pointers; last_evidence date |
| **Render-tested** | Target assistant recognizes commands/rules/entry files | Maintainer render check notes or scheduled probe pointer |
| **Scenario-tested** | Fixed proof task yields required workflow artifacts | Scenario fixture/command pointer **and** last_evidence date — required before any Scenario-tested label |

**Rules**

- A platform **must not** be labeled Scenario-tested (or “fully supported”) without a scenario evidence pointer.
- Gaps column is mandatory: record what is missing even when Install-tested is green.
- Scheduled scenario cadence may be documented; this does not imply universal Scenario-tested status.

## Platform Compatibility Table

| Platform | Install-tested | Render-tested | Scenario-tested | last_evidence | proof / pointer | gaps |
|----------|----------------|---------------|-----------------|---------------|-----------------|------|
| Cursor | yes | partial | no | 2026-07-12 | `tests/agtoosa.bats` Cursor install paths; AgentCapability sentinels | Scenario proof not claimed |
| Claude Code | yes | partial | no | 2026-07-12 | Claude command/skill install bats | Scenario proof not claimed |
| Codex / OpenCode | yes | partial | no | 2026-07-12 | Codex skill/prompt inventory bats | Scenario proof not claimed |
| GitHub Copilot | yes | partial | no | 2026-07-12 | `.github/prompts` / agents install coverage | Scenario proof not claimed |
| VS Code | yes | partial | no | 2026-07-12 | Shared Copilot instruction path | Scenario proof not claimed |
| Windsurf | yes | partial | no | 2026-07-12 | Windsurf rules/workflows inventory | Scenario proof not claimed |
| Gemini | yes | partial | no | 2026-07-12 | Gemini command toml inventory | Scenario proof not claimed |

## Claim Boundary

| Control | Classification |
|---------|----------------|
| This compatibility contract doc | generator-enforced install via `lib/config.sh` |
| Install-tested tier | CI-enforced-able via existing install bats |
| Render-tested tier | manual / scheduled maintainer evidence |
| Scenario-tested tier | manual / scheduled — explicit date + pointer required |
| Lifecycle routing | DEV-055 AgentCapability — unchanged |

## Related

- Lifecycle routing matrix: `Docs/AgToosa_AgentCapability.md`
- Proof product journey: README / first-15 examples (DEV-086)
