# Master-Plan

> **Source of truth for active work.** Completed work lives in `Docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-05-24 (/agtoosa-ship DEV-015 — v4.9.0)

## Project Charter

| Field | Value |
|-------|-------|
| Product | `AgToosa` |
| GitHub repo | `https://github.com/sky2464/AgToosa` |
| Milestone | `v5.0.0` (planned) |
| Active cycle | Release 4.9 |
| Cycle capacity | `40 story points` |
| Current phase | 🏁 Shipped |

## Active Cycle

> Stories committed to the current sprint/cycle.
> **Progress:** `▱▱▱▱▱▱▱▱ 0/0` ← updated by `/agtoosa-build` after each task completes

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|

*(Empty — pick next story via `/agtoosa-spec`.)*

Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> Task breakdown for the current In Progress story. Created by `/agtoosa-spec` (Part 4).
> Updated by `/agtoosa-build` — each completed sub-task gets `- [x]`.

*(No active tasks — last shipped: DEV-015.)*

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

## Epics

> Created at `/agtoosa-init`. One row per product area. Changes rarely — see Active Cycle for what's in flight.

| ID | Title | Stories | Status |
|----|-------|---------|--------|
| DEV-001 | Epic: Core Generator Engine | 0 open / 0 total | ⬜ Backlog |
| DEV-002 | Epic: Workflow Templates | 0 open / 9 total | 🟦 Todo |
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

    *   **Last shipped:** DEV-015 — Windsurf slash command routing → `docs/archived/spec-DEV-015.md`
    *   **Current:** _(none — backlog empty)_
    *   **Next:** _(pick next story via `/agtoosa-spec` — e.g. Gemini routing parity or DEV-003 registry)_

*   **DEV-003 - Epic: Community Template Registry**
    *   **Goal:** Discoverable and secure package manager cache allowing developers to list, search, install, and publish community packs.
    *   **Scope:** Pack registry parsing, cached JSON validation, SHA-256 integrity rules, and command staging wrappers in `lib/registry.sh`.
    *   **Success Criteria:** Secure Offline/Online installation of approved community templates with zero path-traversal risk.

*   **DEV-004 - Epic: Testing & QA Harness**
    *   **Goal:** Comprehensive end-to-end integration and version verification suites validating the robustness of the entire framework.
    *   **Scope:** `tests/agtoosa.bats` and CI regression pipelines.
    *   **Success Criteria:** 100% green coverage on 228+ platform scenarios and version checks on every release step.
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
| DEV-009 | Feature: Initial product promise alignment and readiness gates | 2026-05-23 | [spec-DEV-009.md](archived/spec-DEV-009.md) · [review-DEV-009.md](archived/review-DEV-009.md) |
| DEV-010 | Feature: Workflow reliability (phase gates & terminal evidence) | 2026-05-24 | [spec-DEV-010.md](archived/spec-DEV-010.md) · [review-DEV-010.md](archived/review-DEV-010.md) |
| DEV-011 | Feature: AgToosa Product vs Dogfood Boundary | 2026-05-24 | [spec-DEV-011.md](archived/spec-DEV-011.md) · [review-DEV-011.md](archived/review-DEV-011.md) |
| DEV-012 | Feature: GitHub Slash Command Routing | 2026-05-24 | [spec-DEV-012.md](archived/spec-DEV-012.md) · [review-DEV-012.md](archived/review-DEV-012.md) |
| DEV-013 | Fix: /agtoosa-ship check cleanup | 2026-05-24 | [spec-DEV-013.md](archived/spec-DEV-013.md) · [review-DEV-013.md](archived/review-DEV-013.md) |
| DEV-014 | Fix: Cursor slash command routing | 2026-05-24 | [spec-DEV-014.md](archived/spec-DEV-014.md) · [review-DEV-014.md](archived/review-DEV-014.md) |
| DEV-015 | Fix: Windsurf slash command routing | 2026-05-24 | [spec-DEV-015.md](archived/spec-DEV-015.md) · [review-DEV-015.md](archived/review-DEV-015.md) |

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
| 2026-05-23 | 🚀 Release 4.2 shipped — v4.2.0 tagged; DEV-005–DEV-008 on main; 189/189 bats green | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-009 — promise alignment + readiness gates; 8 tasks; spec: docs/archived/spec-DEV-009.md | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-009; estimate M; Release 4.3 cycle | AgToosa |
| 2026-05-23 | 🏗️ Build 🏗️ Started — DEV-009, 8 tasks; scope: AgToosa_Readiness, Status, README, SECURITY, lib/config.sh, tests/agtoosa.bats | AgToosa |
| 2026-05-23 | Task 🟢 8/8 complete — DEV-009; R1–R8 + full suite 197/197 green | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-009 promise alignment implemented; validation R1–R8 8/8; full suite 178/197 (install bats pre-existing sandbox failures) | AgToosa |
| 2026-05-23 | 🔍 Review 🔍 Started — DEV-009 — 4-persona review | AgToosa |
| 2026-05-23 | Review ✅ Approved — DEV-009; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-009.md | AgToosa |
| 2026-05-23 | 🚀 Ship 🚀 Deployed — DEV-009; smoke R1–R8 + D3 10/10 green; v4.3.0; archived spec + review | AgToosa |
| 2026-05-23 | 🚀 Release 4.3 shipped — v4.3.0; DEV-009 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-010, 7 tasks; scope: template/Docs, platform adapters, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-010 phase gates + terminal evidence; W1–W5 bats green; full suite 202/202 green; version pins 4.3.0 | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-010 — 4-persona review running | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-010; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-010.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-010; smoke W1–W5 5/5 green; full suite 202/202; v4.4.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.4 shipped — v4.4.0; DEV-010 on main; version parity bash/ps1; Gemini TOML in W1/W5 | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-011 — product vs dogfood boundary; estimate M; enrolled Release 4.5; 14 tasks; ADR-008 proposed | AgToosa |
| 2026-05-23 | ✅ Spec approved — DEV-011; estimate M; Release 4.5; 14 tasks planned; test plan: docs/AgToosa_TestPlan-DEV-011.md | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-011; B1–B5 5/5 green; full suite 207/207 green; scope: maintainer guide, template docs, adapters, ADR-008 | AgToosa |
| 2026-05-23 | 🔍 Review 🔍 Started — DEV-011 — 4-persona review running | AgToosa |
| 2026-05-23 | Review ✅ Approved — DEV-011; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-011.md | AgToosa |
| 2026-05-23 | ✏️ /agtoosa-spec DEV-012 — GitHub slash command routing spec drafted; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-012.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-011; smoke B1–B5 5/5 green; full suite 207/207; v4.5.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.5 shipped — v4.5.0; DEV-011 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-012; estimate S; Release 4.6; 11 tasks; test plan: docs/AgToosa_TestPlan-DEV-012.md | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-012, 11 tasks; scope: template/.github/prompts, copilot-instructions, agtoosa.agent, AgToosa_Init/Spec/Skills, agtoosa-spec skill, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-012 GitHub slash routing; G1–G5 5/5 green; full suite 212/212 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-012 — 4-persona review running | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-012; 0 Critical, 5 Warnings (1 fixed, 4 accepted); report: docs/archived/review-DEV-012.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-012; smoke G1–G5 5/5 green; full suite 212/212; v4.6.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.6 shipped — v4.6.0; DEV-012 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-013 — /agtoosa-ship check cleanup; estimate S; enrolled Release 4.7; 14 tasks; test plan: docs/AgToosa_TestPlan-DEV-013.md | AgToosa |
| 2026-05-24 | 🚀 /agtoosa-init re-run — context refresh; milestone v4.6.0; AI configs validated (maintainer dogfood); Epics DEV-001–004 confirmed | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-014 — Cursor slash command routing bug spec drafted; added to Backlog; test plan: docs/AgToosa_TestPlan-DEV-014.md | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-014, 14 tasks; scope: template/.cursor/commands, .cursor/rules, AgToosa_Init/Spec/Skills, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-014 Cursor slash routing; CU1–CU5 5/5 green; full suite 223/223 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-014 — 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-014; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-014.md | AgToosa |
| 2026-05-23 | 🏗️ Build 🏗️ Started — DEV-013, 14 tasks; scope: AgToosa_Ship.md, template ship adapters, tests/agtoosa.bats | AgToosa |
| 2026-05-23 | 🏗️ Build complete — DEV-013 ship-check cleanup; C1–C6 6/6 green; full suite 218/218 green | AgToosa |
| 2026-05-23 | 🔍 Review 🔍 Started — DEV-013 — 4-persona review | AgToosa |
| 2026-05-23 | Review ✅ Approved — DEV-013; 0 Critical, 4 Warnings (accepted); report: docs/archived/review-DEV-013.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-013; smoke C1–C6 6/6 green; full suite 223/223; v4.7.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.7 shipped — v4.7.0; DEV-013 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-014; smoke CU1–CU5 5/5 green; full suite 223/223; v4.8.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.8 shipped — v4.8.0; DEV-014 on main; version parity bash/ps1 | AgToosa |
| 2026-05-24 | ✏️ /agtoosa-spec DEV-015 — Windsurf slash command routing; estimate S; enrolled Release 4.9; 14 tasks; test plan: docs/AgToosa_TestPlan-DEV-015.md | AgToosa |
| 2026-05-24 | ✅ Spec approved — DEV-015; estimate S; Release 4.9; 14 tasks planned | AgToosa |
| 2026-05-24 | 🏗️ Build 🏗️ Started — DEV-015, 14 tasks; scope: template/.windsurf/workflows, .windsurf/rules, AgToosa_Init/Spec/Skills, tests/agtoosa.bats | AgToosa |
| 2026-05-24 | 🏗️ Build complete — DEV-015 Windsurf slash routing; WS1–WS5 5/5 green; full suite 228/228 green | AgToosa |
| 2026-05-24 | 🔍 Review 🔍 Started — DEV-015 — 4-persona review (Security, Eng Manager, CEO, QA Lead) | AgToosa |
| 2026-05-24 | Review ✅ Approved — DEV-015; 0 Critical, 5 Warnings (accepted); report: docs/archived/review-DEV-015.md | AgToosa |
| 2026-05-24 | 🚀 Ship 🚀 Deployed — DEV-015; smoke WS1–WS5 5/5 green; full suite 228/228; v4.9.0; archived spec + review | AgToosa |
| 2026-05-24 | 🚀 Release 4.9 shipped — v4.9.0; DEV-015 on main; version parity bash/ps1 | AgToosa |
