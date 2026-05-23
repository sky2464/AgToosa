# Master-Plan

> **Source of truth for active work.** Completed work lives in `Docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-05-23 20:00

## Project Charter

| Field | Value |
|-------|-------|
| Product | `AgToosa` |
| GitHub repo | `https://github.com/sky2464/AgToosa` |
| Milestone | `v4.2.0` |
| Active cycle | `Release 4.2` |
| Cycle capacity | `40 story points` |
| Current phase | ✏️ Spec · 🏗️ Build · 🔍 Review · 🚢 Ship (Active) |

## Active Cycle

> Stories committed to the current sprint/cycle.
> **Progress:** `▱▱▱▱▱▱▱▱ 0/0` ← updated by `/agtoosa-build` after each task completes

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|

*(Empty — run `/agtoosa-spec` to enroll the next story in Release 4.2 or start a new cycle.)*

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> Task breakdown for the current In Progress story. Created by `/agtoosa-spec` (Part 4).
> Updated by `/agtoosa-build` — each completed sub-task gets `- [x]`.

*(Empty — completed work for DEV-008 archived; run `/agtoosa-spec` to populate tasks for the next story.)*

## Manual / Deferred Tasks

> Tasks that require a human action outside the agent. These are **not** counted against the health score.
> When you complete a step, run `/agtoosa-build` and choose (A) to mark it done.

| Story | Task # | Deferred Since | Description |
|-------|--------|----------------|-------------|

*(Empty — no manual tasks deferred.)*

## Blocked

> **Status:** 🟢 None blocked
> Update this section and change status pill if an issue is blocked during `/agtoosa-build`.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|

*(Empty — good!)*

## Backlog

> Priority-ordered list of upcoming stories and issues. Updated by `/agtoosa-spec` and `/agtoosa-task`.

| ID | Title | Type | Estimate | Epic | Priority | Status |
|----|-------|------|----------|------|----------|--------|

*(Empty — run `/agtoosa-spec` to add the next story.)*

## Epics

> Created at `/agtoosa-init`. One row per product area. Changes rarely — see Active Cycle for what's in flight.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-001 | Epic: Core Generator Engine | 0 open / 0 total | ⬜ Backlog |
| DEV-002 | Epic: Workflow Templates | 0 open / 4 total | ⬜ Backlog |
| DEV-003 | Epic: Community Template Registry | 0 open / 0 total | ⬜ Backlog |
| DEV-004 | Epic: Testing & QA Harness | 0 open / 1 total | ⬜ Backlog |

### Epic Charters

*   **DEV-001 - Epic: Core Generator Engine**
    *   **Goal:** Core interactive CLI generator providing project scaffolding, version-pin checks, deep copy/merge paths, backups, and dry-run execution.
    *   **Scope:** `agtoosa.sh`, `agtoosa.ps1`, and all `lib/*.sh` core modules.
    *   **Success Criteria:** Zero-friction installation and error-free multi-platform scaffolding on clean or existing directories.

*   **DEV-002 - Epic: Workflow Templates**
    *   **Goal:** Comprehensive AI-native rule files, prompts, skills, and templates keeping AI agents fully aligned with the four-phase lifecycle.
    *   **Scope:** Markdown specifications and rules files across Claude, Gemini, Cursor, Windsurf, Copilot, and OpenCode under `template/`.
    *   **Success Criteria:** Perfect parity of phase commands and zero-drift version badges across all platform templates.

    *   **Last shipped:** DEV-008 — workflow skill synthesis → `docs/archived/spec-DEV-008.md`

*   **DEV-003 - Epic: Community Template Registry**
    *   **Goal:** Discoverable and secure package manager cache allowing developers to list, search, install, and publish community packs.
    *   **Scope:** Pack registry parsing, cached JSON validation, SHA-256 integrity rules, and command staging wrappers in `lib/registry.sh`.
    *   **Success Criteria:** Secure Offline/Online installation of approved community templates with zero path-traversal risk.

*   **DEV-004 - Epic: Testing & QA Harness**
    *   **Goal:** Comprehensive end-to-end integration and version verification suites validating the robustness of the entire framework.
    *   **Scope:** `tests/agtoosa.bats` and CI regression pipelines.
    *   **Success Criteria:** 100% green coverage on 155+ platform scenarios and version checks on every release step.
    *   **Last shipped:** DEV-005 — M1–M4 bats + CHANGELOG hygiene → `docs/archived/spec-DEV-005.md`

## Completed This Cycle

> Detail lives in `Docs/archived/`. This section shows pointer rows only — links to archived spec files.
> Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| DEV-005 | Chore: v4.2.0 release hygiene (M1–M4 bats + CHANGELOG) | 2026-05-22 | [spec-DEV-005.md](archived/spec-DEV-005.md) · [review-DEV-005.md](archived/review-DEV-005.md) |
| DEV-006 | Feature: AgToosa Status Guide sub-agent | 2026-05-23 | [spec-DEV-006.md](archived/spec-DEV-006.md) · [review-DEV-006.md](archived/review-DEV-006.md) |
| DEV-007 | Feature: /agtoosa-help next on-demand assistance helper | 2026-05-23 | [spec-DEV-007.md](archived/spec-DEV-007.md) · [review-DEV-007.md](archived/review-DEV-007.md) |
| DEV-008 | Feature: Workflow skill synthesis for AgToosa projects | 2026-05-23 | [spec-DEV-008.md](archived/spec-DEV-008.md) · [review-DEV-008.md](archived/review-DEV-008.md) |

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
| 2026-05-21 | 🚀 /agtoosa-init workspace initialized | AgToosa |
| 2026-05-22 | ✏️ /agtoosa-spec DEV-005 — v4.2.0 release hygiene spec + tasks enrolled in Release 4.2 | AgToosa |
| 2026-05-22 | 🏗️ Build started — DEV-005, 8 tasks, scope: tests/agtoosa.bats, CHANGELOG.md | AgToosa |
| 2026-05-22 | 🏗️ Build complete — M1–M4 added, CHANGELOG backlog moved to [Unreleased], 15/15 validation tests green | AgToosa |
| 2026-05-22 | 🔍 Review started — 4-persona review on DEV-005 | AgToosa |
| 2026-05-22 | 🔍 Review passed — 0 Critical, 3 Warnings (accepted); report: docs/archived/review-DEV-005.md | AgToosa |
| 2026-05-22 | 🚀 Ship complete — DEV-005 closed; smoke/validation 15/15 green; archived spec + review | AgToosa |
| 2026-05-22 | ✏️ /agtoosa-spec DEV-006 — Status Guide sub-agent spec + 11 tasks enrolled in Release 4.2 | AgToosa |
| 2026-05-22 | ✅ Spec approved — DEV-006; estimate M; enrolled in Release 4.2; 11 tasks planned | AgToosa |
| 2026-05-23 | 🏗️ Build started — DEV-006, 11 tasks, scope: StatusGuide docs, Copilot agent, config registration, bats parity | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-006 Status Guide implemented; 161/161 bats validation tests green | AgToosa |
| 2026-05-23 | 🔍 Review started — 4-persona review on DEV-006 | AgToosa |
| 2026-05-23 | 🔍 Review passed — 0 Critical, 2 Warnings (accepted); report: docs/archived/review-DEV-006.md | AgToosa |
| 2026-05-23 | 🚀 Ship complete — DEV-006 closed; smoke/validation 161/161 green; archived spec + review | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-007 — /agtoosa-help next on-demand assistance helper spec + 15 tasks enrolled in Release 4.2 | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-007; estimate S; enrolled in Release 4.2; 15 tasks planned | AgToosa |
| 2026-05-23 | 🏗️ Build started — DEV-007, 18 tasks, scope: help variants, core fallbacks, Agent docs, tests/agtoosa.bats, CHANGELOG.md | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-007 help-next wired; H1–H7 bats green; 178/180 full suite (S2 install pre-existing fail) | AgToosa |
| 2026-05-23 | 🔍 Review started — 4-persona review on DEV-007 | AgToosa |
| 2026-05-23 | 🔍 Review passed — 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-007.md | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-008 — workflow skill synthesis spec drafted and added to Backlog (not enrolled) | AgToosa |
| 2026-05-23 | 🚀 Ship complete — DEV-007 closed; smoke H1–H7 7/7 green; archived spec + review | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-008 — workflow skill synthesis enrolled in Release 4.2; estimate M; 15 tasks planned | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-008; estimate M; enrolled in Release 4.2; 15 tasks planned | AgToosa |
| 2026-05-23 | 🏗️ Build started — DEV-008, 15 tasks, scope: template/.codex/skills, AgToosa_Init/Spec/Skills/Agent, OPENCODE, tests/agtoosa.bats | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-008 workflow skill synthesis; K1–K7 bats green; 189/189 full suite green | AgToosa |
| 2026-05-23 | 🔍 Review started — 4-persona review on DEV-008 | AgToosa |
| 2026-05-23 | 🔍 Review passed — 0 Critical, 3 Warnings (accepted); report: docs/archived/review-DEV-008.md | AgToosa |
| 2026-05-23 | 🚀 Ship complete — DEV-008 closed; smoke K1–K7 7/7 green; 189/189 validation; archived spec + review | AgToosa |
