# Master-Plan

> **Source of truth for active work.** Completed work lives in `docs/archived/` — see Completed This Cycle for links.
> **Last updated:** 2026-07-11 (DEV-051 shipped — v5.3.14 Tracker Sync Bridge)

## Project Charter

| Field | Value |
|-------|-------|
| Product | `AgToosa` |
| GitHub repo | `https://github.com/sky2464/AgToosa` |
| Current phase | v5.3.14 shipped — cycle parked (demand-gated backlog only) |
| Milestone | `v5.3.15` (next) — PATCH train per `docs/adr/ADR-005-release-cadence.md` |
| Active cycle | _(none — parked)_ |
| Cycle capacity | `8 story points` |

## Active Cycle

> Stories committed to the current sprint/cycle.

| ID | Title | Type | Estimate | Status | Tasks Done |
|----|-------|------|----------|--------|-----------|
| _(none — cycle parked)_ | | | | | |

<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.14.md -->

<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.13.md -->

<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.12.md -->

<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.11.md -->


<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.10.md -->
<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.9.md -->
<!-- Archived to docs/archived/cycle-2026-07-11-release-5.3.8.md -->
Status key: ⬜ Backlog · 🟦 Todo · 🟨 In Progress · ✅ Done · 🚫 Blocked · 🔧 Awaiting Manual · 🏁 Shipped

## Active Tasks

> Task breakdown for the current In Progress story. Created by `/agtoosa-spec` (Part 4).
> Updated by `/agtoosa-build` — each completed sub-task gets `- [x]`.

_(Empty — cycle parked. Next enrollment via `/agtoosa-spec` when demand un-gates a backlog story.)_

## Manual / Deferred Tasks

> Tasks that require a human action outside the agent. These are **not** counted against the health score.
> When you complete a step, run `/agtoosa-build` and choose (A) to mark it done.

| Story | Task # | Deferred Since | Description |
|-------|--------|----------------|-------------|
| DEV-080 | 4.2 | 2026-07-11 | Submit three official packs to external agtoosa-registry `[manual-deferred]` |
| DEV-080 | 4.3 | 2026-07-11 | Confirm accepted external registry records `[manual-deferred]` |
| DEV-084 | M-1 | 2026-07-11 | Confirm GitHub Sponsors for @sky2464 is active (OSS-007) `[manual-deferred]` |
| DEV-071 | M-1 | 2026-06-09 | Publish the npm wrapper: `cd npm && npm publish` (requires npm account/2FA) `[manual]` |
| DEV-062 | M-1 | 2026-06-09 | Optional: publish the gate as a GitHub Marketplace Action for discoverability `[manual]` |
| DEV-066 | M-1 | 2026-06-09 | Configure required reviewers on the `release` environment in repo settings `[manual]` |
| DEV-066 | M-2 | 2026-06-09 | Mirror the pinned `Formula/agtoosa.rb` to the `sky2464/homebrew-agtoosa` tap `[manual]` |
| DEV-060 | M-1 | 2026-06-09 | Execute benchmark tasks B1–B3 against Spec Kit/OpenSpec/BMAD and publish results under `docs/benchmarks/results/` `[manual]` |

## Blocked

> **Status:** 🟢 None blocked
> Update this section and change status pill if an issue is blocked during `/agtoosa-build`.

| ID | Title | Blocked by | Since |
|----|-------|-----------|-------|

*(Empty — good!)*

## Backlog

> Priority-ordered list of upcoming stories and issues. Updated by `/agtoosa-spec` and `/agtoosa-task`.
> Roadmap coverage and dependency gates: `docs/updates/roadmap-spec-index.md`. A “spec ready” row remains unapproved until explicitly enrolled through `/agtoosa-spec`.

| ID | Title | Type | Estimate | Epic | Priority | Status |
|----|-------|------|----------|------|----------|--------|
| DEV-044 | Feature: EARS-to-Test TDD Gate | Feature | M | DEV-004 | P0 | ✅ Done — delivered via DEV-061 (EARS lint + AC↔test check) and DEV-067 (RED/GREEN evidence gate) |
| DEV-045 | Feature: Work Package Wave DAG | Feature | M | DEV-002 | P1 | 🏁 Shipped — v5.3.9 |
| DEV-046 | Feature: Optional Worktree Isolation | Feature | M | DEV-001 | P1 | 🏁 Shipped — v5.3.10 |
| DEV-047 | Feature: Async Agent Handoff Packs | Feature | M | DEV-002 | P0 | 🏁 Shipped — v5.3.3 |
| DEV-048 | Feature: Agent Result Import Gate | Feature | M | DEV-002 | P0 | 🏁 Shipped — v5.3.3 |
| DEV-049 | Feature: Evidence Ledger | Feature | M | DEV-004 | P0 | 🏁 Shipped — v5.3.4 |
| DEV-050 | Feature: Cross-Model Review Gate | Feature | S | DEV-002 | P1 | 🏁 Shipped — v5.3.6 |
| DEV-051 | Feature: Tracker Sync Bridge | Feature | M | DEV-003 | P1 | 🏁 Shipped — v5.3.14 |
| DEV-052 | Feature: Hook Automation Pack | Feature | M | DEV-002 | P1 | 🏁 Shipped — v5.3.11 |
| DEV-053 | Feature: Extension and Preset Catalog | Feature | M | DEV-003 | P1 | 🏁 Shipped — v5.3.8 |
| DEV-054 | Feature: Signed Registry Provenance | Feature | M | DEV-003 | P0 | 🏁 Shipped — v5.3.5 |
| DEV-055 | Feature: Agent Capability Matrix | Feature | S | DEV-002 | P1 | 🏁 Shipped — v5.3.7 |
| DEV-056 | Feature: Retrospective Learning Loop | Feature | S | DEV-002 | P2 | 🏁 Shipped — v5.3.11 |
| DEV-057 | Feature: Multi-Repo Story Overlay | Feature | L | DEV-002 | P2 | ⬜ Backlog — demand-gated + DEV-045 |
| DEV-058 | Feature: Local Dashboard | Feature | M | DEV-004 | P2 | 🏁 Shipped — v5.3.12 |
| DEV-059 | Feature: Governance Policy-as-Code | Feature | M | DEV-004 | P1 | 🏁 Shipped — v5.3.10 |
| DEV-060 | Docs: Public Benchmark Suite | Docs | M | DEV-004 | P2 | ✅ Done — suite + scoring + claim boundary in `docs/benchmarks/`; competitor runs manual-deferred |
| DEV-075 | Docs: Subagent and Persona Guide Suite | Docs | M | DEV-002 | P1 | 🏁 Shipped — v5.3.8 |
| DEV-076 | Spike: Static Documentation Site Proof | Spike | S | DEV-004 | P2 | 🏁 Shipped — v5.3.9 |
| DEV-077 | Chore: Authoring Guide and Onboarding Surface | Chore | S | DEV-003 | P2 | 🏁 Shipped — v5.3.9 |
| DEV-078 | Chore: First-15-Minutes Maintenance Gate | Chore | XS | DEV-004 | P1 | 🏁 Shipped — v5.3.8 |
| DEV-079 | Docs: Verifier and CI Adoption Examples | Docs | S | DEV-004 | P2 | 🏁 Shipped — v5.3.9 |
| DEV-080 | Feature: Official Registry Pack Pilot | Feature | L | DEV-003 | P2 | 🏁 Shipped — v5.3.9 (external publish manual) |
| DEV-081 | Spike: Optional Local DX Add-on Validation | Spike | M | DEV-001 | P2 | 🏁 Shipped — v5.3.8 |
| DEV-082 | Spike: High-Assurance Signature Mode Validation | Spike | S | DEV-003 | P2 | 🏁 Shipped — v5.3.9 (Defer) |
| DEV-083 | Docs: Voluntary Workflow Metrics and Case Study Kit | Docs | S | DEV-004 | P2 | 🏁 Shipped — v5.3.9 |
| DEV-084 | Chore: Open-Source Sustainability and Support Boundary | Chore | XS | DEV-004 | P2 | 🏁 Shipped — v5.3.9 (Sponsors manual) |
| DEV-035 | Chore: Launch P0 publication and quickstart gate | Chore | M | DEV-004 | P0 | ✅ Done |
| DEV-036 | Fix: Windows and registry parity | Fix | M | DEV-001 / DEV-003 | P1 | ✅ Done |
| DEV-037 | Chore: Truthful launch documentation and positioning | Chore | M | DEV-002 | P1 | ✅ Done |
| DEV-038 | Chore: Distribution hardening and release readiness gate | Chore | M | DEV-004 | P1 | ✅ Done |
| DEV-039 | Docs: First 15 minutes proof and growth positioning | Docs | S | DEV-002 | P2 | ✅ Done |
| DEV-040 | Docs: Team trust roadmap | Docs | S | DEV-003 / DEV-004 | P2 | ✅ Done |
| DEV-031 | Feature: Project-specific specialist subagents | Feature | M | DEV-002 | High | 🏁 Shipped |
| DEV-032 | Chore: Patch-first release versioning (5.x line) | Chore | S | DEV-001 | High | 🏁 Shipped |
| DEV-030 | Fix: `/agtoosa-update` self-target uncertainty | Fix | S | DEV-002 | High | 🏁 Shipped |
| DEV-033 | Fix: agtoosa.ps1 PSScriptAnalyzer approved verbs | Fix | XS | DEV-001 | Medium | 🏁 Shipped |
| DEV-034 | Chore: Maintainer release-state reconciliation | Chore | S | DEV-004 | High | 🏁 Shipped |
| DEV-085 | Chore: Post-v5.3.12 release hygiene (bats restore + Master-Plan reconciliation) | Chore | XS | DEV-004 | High | 🏁 Shipped — v5.3.13 |

## Epics

> Created at `/agtoosa-init`. One row per product area. Changes rarely — see Active Cycle for what's in flight.

| ID | Title | Stories | Status | Next spec |
|----|-------|---------|--------|-----------|
| DEV-001 | Epic: Core Generator Engine | 0 open / 5 total | 🏁 Complete | — |
| DEV-002 | Epic: Workflow Templates | 1 open / 14 total | 🟨 Demand-gated | DEV-057 (demand-gated) |
| DEV-003 | Epic: Community Template Registry | 0 open / 7 total | 🏁 Complete | — |
| DEV-004 | Epic: Testing & QA Harness | 0 open / 11 total | 🏁 Complete | — |

### Epic Charters

*   **DEV-001 - Epic: Core Generator Engine**
    *   **Goal:** Core interactive CLI generator providing project scaffolding, version-pin checks, deep copy/merge paths, backups, and dry-run execution.
    *   **Scope:** `agtoosa.sh`, `agtoosa.ps1`, and all `lib/*.sh` core modules.
    *   **Success Criteria:** Zero-friction installation and error-free multi-platform scaffolding on clean or existing directories.
    *   **Last shipped:** DEV-046 — Optional Worktree Isolation → `docs/archived/spec-DEV-046.md`
    *   **Last shipped:** DEV-081 — Optional Local DX spike (defer all three options) → `docs/archived/spec-DEV-081.md`
    *   **Current:** All epic stories shipped — no open generator work

*   **DEV-002 - Epic: Workflow Templates**
    *   **Goal:** Comprehensive AI-native rule files, prompts, skills, and templates keeping AI agents fully aligned with the four-phase lifecycle.
    *   **Scope:** Markdown specifications and rules files across Claude, Gemini, Cursor, Windsurf, Copilot, and OpenCode under `template/`.
    *   **Success Criteria:** Perfect parity of phase commands and zero-drift version badges across all platform templates.
    *   **Last shipped:** DEV-055 — Agent Capability Matrix → `docs/archived/spec-DEV-055.md`
    *   **Last shipped:** DEV-050 — Cross-Model Review Gate → `docs/archived/spec-DEV-050.md`
    *   **Last shipped:** DEV-075 — Subagent and Persona Guide Suite → `docs/archived/spec-DEV-075.md`
    *   **Last shipped:** DEV-052 — Hook Automation Pack → `docs/archived/spec-DEV-052.md`
    *   **Last shipped:** DEV-056 — Retrospective Learning Loop → `docs/archived/spec-DEV-056.md`
    *   **Last shipped:** DEV-045 — Work Package Wave DAG → `docs/archived/spec-DEV-045.md`
    *   **Current:** Wave stories shipped; demand-gated DEV-057 remains in backlog

*   **DEV-003 - Epic: Community Template Registry**
    *   **Goal:** Discoverable and secure package manager cache allowing developers to list, search, install, and publish community packs.
    *   **Scope:** Pack registry parsing, cached JSON validation, SHA-256 integrity rules, and command staging wrappers in `lib/registry.sh`.
    *   **Success Criteria:** Secure Offline/Online installation of approved community templates with zero path-traversal risk.
    *   **Last shipped:** DEV-054 — Signed Registry Provenance → `docs/archived/spec-DEV-054.md`
    *   **Last shipped:** DEV-022 — publish PS1 + offline cache → `docs/archived/spec-DEV-022.md`
    *   **Last shipped:** DEV-053 — Extension and Preset Catalog → `docs/archived/spec-DEV-053.md`
    *   **Last shipped:** DEV-077 — Authoring Guide and Onboarding Surface → `docs/archived/spec-DEV-077.md`
    *   **Last shipped:** DEV-080 — Official Registry Pack Pilot → `docs/archived/spec-DEV-080.md`
    *   **Last shipped:** DEV-082 — High-Assurance Signature Mode Validation → `docs/archived/spec-DEV-082.md`
    *   **Last shipped:** DEV-051 — Tracker Sync Bridge → `docs/archived/spec-DEV-051.md`
    *   **Current:** All epic stories shipped; DEV-080 external registry publish remains [manual-deferred]

*   **DEV-004 - Epic: Testing & QA Harness**
    *   **Goal:** Comprehensive end-to-end integration and version verification suites validating the robustness of the entire framework.
    *   **Scope:** `tests/agtoosa.bats` and CI regression pipelines.
    *   **Success Criteria:** 100% green coverage on 340+ bats scenarios and version checks on every release step.
    *   **Last shipped:** DEV-005 — M1–M4 bats + CHANGELOG hygiene → `docs/archived/spec-DEV-005.md`
    *   **Last shipped:** DEV-078 — First-15-Minutes Maintenance Gate → `docs/archived/spec-DEV-078.md`
    *   **Last shipped:** DEV-058 — Local Dashboard → `docs/archived/spec-DEV-058.md`
    *   **Last shipped:** DEV-059 — Governance Policy-as-Code → `docs/archived/spec-DEV-059.md`
    *   **Last shipped:** DEV-076 — Static Documentation Site Proof → `docs/archived/spec-DEV-076.md`
    *   **Last shipped:** DEV-079 — Verifier and CI Adoption Examples → `docs/archived/spec-DEV-079.md`
    *   **Last shipped:** DEV-083 — Voluntary Workflow Metrics and Case Study Kit → `docs/archived/spec-DEV-083.md`
    *   **Last shipped:** DEV-084 — Open-Source Sustainability and Support Boundary → `docs/archived/spec-DEV-084.md`
    *   **Last shipped:** DEV-085 — Post-v5.3.12 release hygiene → `docs/archived/spec-DEV-085.md`
    *   **Current:** All epic stories shipped — no open harness work

## Completed This Cycle

> Detail lives in `docs/archived/`. This section shows pointer rows only — links to archived spec files.
> Updated by `/agtoosa-ship`.

| ID | Title | Shipped | Archived Spec |
|----|-------|---------|--------------|
| DEV-051 | Feature: Tracker Sync Bridge | 2026-07-11 | [spec-DEV-051.md](archived/spec-DEV-051.md) · [review-DEV-051.md](archived/review-DEV-051.md) · [evidence-DEV-051.md](archived/evidence-DEV-051.md) |
| DEV-085 | Chore: Post-v5.3.12 release hygiene (bats restore + Master-Plan reconciliation) | 2026-07-11 | [spec-DEV-085.md](archived/spec-DEV-085.md) · [review-DEV-085.md](archived/review-DEV-085.md) · [evidence-DEV-085.md](archived/evidence-DEV-085.md) |
| DEV-058 | Feature: Local Dashboard | 2026-07-11 | [spec-DEV-058.md](archived/spec-DEV-058.md) · [review-DEV-058.md](archived/review-DEV-058.md) · [evidence-DEV-058.md](archived/evidence-DEV-058.md) |
| DEV-052 | Feature: Hook Automation Pack | 2026-07-11 | [spec-DEV-052.md](archived/spec-DEV-052.md) · [review-DEV-052.md](archived/review-DEV-052.md) · [evidence-DEV-052.md](archived/evidence-DEV-052.md) |
| DEV-056 | Feature: Retrospective Learning Loop | 2026-07-11 | [spec-DEV-056.md](archived/spec-DEV-056.md) · [review-DEV-056.md](archived/review-DEV-056.md) · [evidence-DEV-056.md](archived/evidence-DEV-056.md) |
| DEV-046 | Feature: Optional Worktree Isolation | 2026-07-11 | [spec-DEV-046.md](archived/spec-DEV-046.md) · [review-DEV-046.md](archived/review-DEV-046.md) · [evidence-DEV-046.md](archived/evidence-DEV-046.md) |
| DEV-059 | Feature: Governance Policy-as-Code | 2026-07-11 | [spec-DEV-059.md](archived/spec-DEV-059.md) · [review-DEV-059.md](archived/review-DEV-059.md) · [evidence-DEV-059.md](archived/evidence-DEV-059.md) |
| DEV-045 | Feature: Work Package Wave DAG | 2026-07-11 | [spec-DEV-045.md](archived/spec-DEV-045.md) · [review-DEV-045.md](archived/review-DEV-045.md) · [evidence-DEV-045.md](archived/evidence-DEV-045.md) |
| DEV-076 | Spike: Static Documentation Site Proof | 2026-07-11 | [spec-DEV-076.md](archived/spec-DEV-076.md) · [review-DEV-076.md](archived/review-DEV-076.md) · [evidence-DEV-076.md](archived/evidence-DEV-076.md) |
| DEV-077 | Chore: Authoring Guide and Onboarding Surface | 2026-07-11 | [spec-DEV-077.md](archived/spec-DEV-077.md) · [review-DEV-077.md](archived/review-DEV-077.md) · [evidence-DEV-077.md](archived/evidence-DEV-077.md) |
| DEV-079 | Docs: Verifier and CI Adoption Examples | 2026-07-11 | [spec-DEV-079.md](archived/spec-DEV-079.md) · [review-DEV-079.md](archived/review-DEV-079.md) · [evidence-DEV-079.md](archived/evidence-DEV-079.md) |
| DEV-080 | Feature: Official Registry Pack Pilot | 2026-07-11 | [spec-DEV-080.md](archived/spec-DEV-080.md) · [review-DEV-080.md](archived/review-DEV-080.md) · [evidence-DEV-080.md](archived/evidence-DEV-080.md) |
| DEV-082 | Spike: High-Assurance Signature Mode Validation | 2026-07-11 | [spec-DEV-082.md](archived/spec-DEV-082.md) · [review-DEV-082.md](archived/review-DEV-082.md) · [evidence-DEV-082.md](archived/evidence-DEV-082.md) |
| DEV-083 | Docs: Voluntary Workflow Metrics and Case Study Kit | 2026-07-11 | [spec-DEV-083.md](archived/spec-DEV-083.md) · [review-DEV-083.md](archived/review-DEV-083.md) · [evidence-DEV-083.md](archived/evidence-DEV-083.md) |
| DEV-084 | Chore: Open-Source Sustainability and Support Boundary | 2026-07-11 | [spec-DEV-084.md](archived/spec-DEV-084.md) · [review-DEV-084.md](archived/review-DEV-084.md) · [evidence-DEV-084.md](archived/evidence-DEV-084.md) |
| DEV-075 | Docs: Subagent and Persona Guide Suite | 2026-07-11 | [spec-DEV-075.md](archived/spec-DEV-075.md) · [review-DEV-075.md](archived/review-DEV-075.md) · [evidence-DEV-075.md](archived/evidence-DEV-075.md) |
| DEV-053 | Feature: Extension and Preset Catalog | 2026-07-11 | [spec-DEV-053.md](archived/spec-DEV-053.md) · [review-DEV-053.md](archived/review-DEV-053.md) · [evidence-DEV-053.md](archived/evidence-DEV-053.md) |
| DEV-078 | Chore: First-15-Minutes Maintenance Gate | 2026-07-11 | [spec-DEV-078.md](archived/spec-DEV-078.md) · [review-DEV-078.md](archived/review-DEV-078.md) · [evidence-DEV-078.md](archived/evidence-DEV-078.md) |
| DEV-081 | Spike: Optional Local DX Add-on Validation | 2026-07-11 | [spec-DEV-081.md](archived/spec-DEV-081.md) · [review-DEV-081.md](archived/review-DEV-081.md) · [evidence-DEV-081.md](archived/evidence-DEV-081.md) |
| DEV-055 | Feature: Agent Capability Matrix | 2026-07-11 | [spec-DEV-055.md](archived/spec-DEV-055.md) · [review-DEV-055.md](archived/review-DEV-055.md) · [evidence-DEV-055.md](archived/evidence-DEV-055.md) |
| DEV-050 | Feature: Cross-Model Review Gate | 2026-07-11 | [spec-DEV-050.md](archived/spec-DEV-050.md) · [review-DEV-050.md](archived/review-DEV-050.md) · [evidence-DEV-050.md](archived/evidence-DEV-050.md) |
| DEV-054 | Feature: Signed Registry Provenance | 2026-07-08 | [spec-DEV-054.md](archived/spec-DEV-054.md) · [review-DEV-054.md](archived/review-DEV-054.md) · [evidence-DEV-054.md](archived/evidence-DEV-054.md) |
| DEV-049 | Feature: Evidence Ledger | 2026-07-08 | [spec-DEV-049.md](archived/spec-DEV-049.md) · [review-DEV-049.md](archived/review-DEV-049.md) · [evidence-DEV-049.md](archived/evidence-DEV-049.md) |
| DEV-047 | Feature: Async Agent Handoff Packs | 2026-07-08 | [spec-DEV-047.md](archived/spec-DEV-047.md) · [review-DEV-047-048.md](archived/review-DEV-047-048.md) |
| DEV-048 | Feature: Agent Result Import Gate | 2026-07-08 | [spec-DEV-048.md](archived/spec-DEV-048.md) · [review-DEV-047-048.md](archived/review-DEV-047-048.md) |
| DEV-074 | Feature: PS1 non-interactive install parity (`-Path -Platforms -Yes`) + Pester suite | 2026-07-08 | [spec-DEV-074.md](archived/spec-DEV-074.md) · [review-DEV-074.md](archived/review-DEV-074.md) |
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
| DEV-003 | Fix: Registry prod-readiness (audit closure) | 2026-05-24 | [spec-DEV-003.md](archived/spec-DEV-003.md) · [review-DEV-003.md](archived/review-DEV-003.md) |
| DEV-016 | Fix: Gemini slash command routing | 2026-05-24 | [spec-DEV-016.md](archived/spec-DEV-016.md) · [review-DEV-016.md](archived/review-DEV-016.md) |
| DEV-017 | Fix: Codex AgToosa slash discoverability | 2026-05-24 | [spec-DEV-017.md](archived/spec-DEV-017.md) · [review-DEV-017.md](archived/review-DEV-017.md) |
| DEV-018 | Fix: Registry pack queue | 2026-05-24 | [spec-DEV-018.md](archived/spec-DEV-018.md) · [review-DEV-018.md](archived/review-DEV-018.md) |
| DEV-020 | Fix: Registry install version pinning | 2026-05-24 | [spec-DEV-020.md](archived/spec-DEV-020.md) · [review-DEV-020.md](archived/review-DEV-020.md) |
| DEV-021 | Fix: E2E pinned registry install test (RV6) | 2026-05-24 | [spec-DEV-021.md](archived/spec-DEV-021.md) · [review-DEV-021.md](archived/review-DEV-021.md) |
| DEV-022 | Fix: Registry publish PS1 + offline cache hardening | 2026-05-24 | [spec-DEV-022.md](archived/spec-DEV-022.md) · [review-DEV-022.md](archived/review-DEV-022.md) |
| DEV-019 | Feature: Master Architecture document | 2026-05-24 | [spec-DEV-019.md](archived/spec-DEV-019.md) · [review-DEV-019.md](archived/review-DEV-019.md) |
| DEV-023 | Fix: Workflow Template Native Slash Parity Audit | 2026-05-24 | [spec-DEV-023.md](archived/spec-DEV-023.md) · [review-DEV-023.md](archived/review-DEV-023.md) |
| DEV-024 | Fix: Maintainer status readiness doc parity | 2026-05-24 | [spec-DEV-024.md](archived/spec-DEV-024.md) · [review-DEV-024.md](archived/review-DEV-024.md) |
| DEV-025 | Chore: Maintainer docs path normalization | 2026-05-24 | [spec-DEV-025.md](archived/spec-DEV-025.md) · [review-DEV-025.md](archived/review-DEV-025.md) |
| DEV-026 | Fix: Codex agent mode spec workflow execution | 2026-05-24 | [spec-DEV-026.md](archived/spec-DEV-026.md) · [review-DEV-026.md](archived/review-DEV-026.md) |
| DEV-027 | Feature: Agentic `/agtoosa-update` | 2026-05-24 | [spec-DEV-027.md](archived/spec-DEV-027.md) · [review-DEV-027.md](archived/review-DEV-027.md) |
| DEV-028 | Feature: Plan-mode spec interview for `/agtoosa-spec` | 2026-05-24 | [spec-DEV-028.md](archived/spec-DEV-028.md) · [review-DEV-028.md](archived/review-DEV-028.md) |
| DEV-029 | Chore: Stop branch-protection workflow failure emails | 2026-05-25 | [spec-DEV-029.md](archived/spec-DEV-029.md) · [review-DEV-029.md](archived/review-DEV-029.md) |
| DEV-032 | Chore: Patch-first release versioning (5.x line) | 2026-05-25 | [spec-DEV-032.md](archived/spec-DEV-032.md) · [review-DEV-032.md](archived/review-DEV-032.md) |
| DEV-031 | Feature: Project-specific specialist subagents | 2026-05-25 | [spec-DEV-031.md](archived/spec-DEV-031.md) · [review-DEV-031.md](archived/review-DEV-031.md) |
| DEV-030 | Fix: `/agtoosa-update` self-target uncertainty | 2026-06-05 | [spec-DEV-030.md](archived/spec-DEV-030.md) · [review-DEV-030.md](archived/review-DEV-030.md) |
| DEV-033 | Fix: agtoosa.ps1 PSScriptAnalyzer approved verbs | 2026-06-05 | [spec-DEV-033.md](archived/spec-DEV-033.md) · [review-DEV-033.md](archived/review-DEV-033.md) |
| DEV-034 | Chore: Maintainer release-state reconciliation | 2026-06-05 | [spec-DEV-034.md](archived/spec-DEV-034.md) · [review-DEV-034.md](archived/review-DEV-034.md) |
| DEV-041 | Chore: Public launch publication proof | 2026-06-08 | [spec-DEV-041.md](archived/spec-DEV-041.md) · [review-DEV-041.md](archived/review-DEV-041.md) |
| DEV-042 | Feature: Spec Quality Analyzer | 2026-06-10 | [spec-DEV-042.md](archived/spec-DEV-042.md) · [review-DEV-042-043.md](archived/review-DEV-042-043.md) |
| DEV-043 | Feature: Brownfield Spec Drift Baseline | 2026-06-10 | [spec-DEV-043.md](archived/spec-DEV-043.md) · [review-DEV-042-043.md](archived/review-DEV-042-043.md) |
| DEV-061 | Feature: Deterministic lifecycle verifier | 2026-06-10 | [spec-DEV-061.md](archived/spec-DEV-061.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-062 | Feature: AgToosa Gate CI template | 2026-06-10 | [spec-DEV-062.md](archived/spec-DEV-062.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-063 | Feature: Phase-event log + Update Log rotation | 2026-06-10 | [spec-DEV-063.md](archived/spec-DEV-063.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-064 | Fix: Safe tar extraction | 2026-06-10 | [spec-DEV-064.md](archived/spec-DEV-064.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-065 | Feature: Pack containment | 2026-06-10 | [spec-DEV-065.md](archived/spec-DEV-065.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-066 | Fix: Pinned install chain | 2026-06-10 | [spec-DEV-066.md](archived/spec-DEV-066.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-067 | Fix: Executable workflows | 2026-06-10 | [spec-DEV-067.md](archived/spec-DEV-067.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-068 | Fix: Adapter drift | 2026-06-10 | [spec-DEV-068.md](archived/spec-DEV-068.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-069 | Fix: Governance wiring | 2026-06-10 | [spec-DEV-069.md](archived/spec-DEV-069.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-070 | Feature: Token diet | 2026-06-10 | [spec-DEV-070.md](archived/spec-DEV-070.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-071 | Feature: Non-interactive CLI + npm wrapper | 2026-06-10 | [spec-DEV-071.md](archived/spec-DEV-071.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-072 | Feature: Spec change control + living specs | 2026-06-10 | [spec-DEV-072.md](archived/spec-DEV-072.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |
| DEV-073 | Feature: Doctor + uninstall + README | 2026-06-10 | [spec-DEV-073.md](archived/spec-DEV-073.md) · [review-DEV-061-073.md](archived/review-DEV-061-073.md) |

## Update Log

> Append a row at every phase transition. Never delete rows.

| Date | Event | By |
|------|-------|----|
<!-- Older rows through 2026-06-10: docs/archived/updatelog-2026.md -->
| 2026-07-07 | 🏗️ Merged v5.3.x fix batch — pack lock provenance, re-install data loss, multi-root tarball smuggle, npm pack queue, PowerShell hooks/merge containment (PRs #36–#48, #61–#63) | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.1 patch; Unreleased fixes + bootstrap durable pack queue (PR #64); focused SR bats green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.1 shipped — v5.3.1; version parity bash/ps1/npm; Milestone v5.3.2 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-074 enrolled — PS1 non-interactive install parity; spec approved; test plan `docs/AgToosa_TestPlan-DEV-074.md` | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-074 — Task 🟢 12/12 complete — PS1 `-Path`/`-Platforms`/`-Yes` parity; bats DEV-074 CT-001–CT-004; Pester NI-001–NI-005 green | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-074 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-074; 0 🔴 Critical, 2 🟡 Warning (accepted); report: `docs/archived/review-DEV-074.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.2 — DEV-074 PS1 non-interactive install parity; bats DEV-074 SR-001–SR-003 green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.2 shipped — v5.3.2; version parity bash/ps1/npm; Milestone v5.3.3 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-047 + DEV-048 enrolled — deepened executable specs; Spec ✅ Approved; estimate M each; Active Cycle | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-047 + DEV-048 — Task 🟢 5/5 + 5/5 — Handoff/Import docs, adapters, Build/Ship wiring, HO/IR bats | AgToosa |
| 2026-07-08 | 🏗️ Build complete — DEV-047 + DEV-048; next: `/agtoosa-review` then `/agtoosa-ship` | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-047 + DEV-048 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-047 + DEV-048; 0 🔴 Critical, 4 🟡 Warning accepted (1 fixed); report: `docs/archived/review-DEV-047-048.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.3 — DEV-047 + DEV-048 handoff/import; bats DEV-047/048 HO/IR green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.3 shipped — v5.3.3; version parity bash/ps1/npm; Milestone v5.3.4 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-049 enrolled — Evidence Ledger deepened (markdown + optional JSONL); estimate M; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-08 | /agtoosa-spec — Spec ✅ Approved — DEV-049 — spec-DEV-049.md; estimate M; enrolled in cycle | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-049 Started — 5 tasks; scope: AgToosa_Evidence.md, Review/Ship wiring, JSONL seed, EL bats, config/adapters | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-049 — Task 🟢 5/5 complete — Evidence ledger docs, Review/Ship wiring, adapters, EL-001–EL-005 green | AgToosa |
| 2026-07-08 | 🏗️ Build complete — DEV-049; next: `/agtoosa-review` then `/agtoosa-ship` | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-049 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-049; 0 🔴 Critical, 5 🟡 Warning accepted; report: `docs/archived/review-DEV-049.md`; evidence: `docs/archived/evidence-DEV-049.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.4 — DEV-049 Evidence Ledger; bats DEV-049 EL/SR green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.4 shipped — v5.3.4; version parity bash/ps1/npm; Milestone v5.3.5 (next) | AgToosa |
| 2026-07-08 | ✏️ /agtoosa-spec DEV-054 enrolled — Signed Registry Provenance deepened (minisign soft-warn, packs+releases); estimate M; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-08 | /agtoosa-spec — Spec ✅ Approved — DEV-054 — spec-DEV-054.md; estimate M; enrolled in cycle | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-054 Started — 5 tasks; scope: registry soft-warn minisign, provenance docs, ADR-011, pubkey path, SP bats | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build DEV-054 — Task 🟢 5/5 complete — provenance soft-warn, ADR-011, SP-001–SP-006 green; M-1 remains Manual/Deferred | AgToosa |
| 2026-07-08 | 🏗️ Build complete — DEV-054; next: `/agtoosa-review` then `/agtoosa-ship` | AgToosa |
| 2026-07-08 | 🔍 Review 🔍 Started — DEV-054 — 4-persona review running | AgToosa |
| 2026-07-08 | 🔍 Review ✅ Approved — DEV-054; 0 🔴 Critical, 6 🟡 Warning accepted; report: `docs/archived/review-DEV-054.md`; evidence: `docs/archived/evidence-DEV-054.md` | AgToosa |
| 2026-07-08 | 🚀 Ship complete — v5.3.5 — DEV-054 Signed Registry Provenance; bats DEV-054 SP/SR green | AgToosa |
| 2026-07-08 | 🚀 Release 5.3.5 shipped — v5.3.5; version parity bash/ps1/npm; Milestone v5.3.6 (next) | AgToosa |
| 2026-07-08 | 🏗️ /agtoosa-build — DEV-054 M-1 `[manual-done]` — maintainer minisign key + pubkey (`4a64308`) + release sidecars (`c4f240b`, `48f3f90`); verify green on bootstrap.sh and agtoosa.sh | AgToosa |
| 2026-07-11 | ✏️ /agtoosa-spec DEV-050 enrolled — Cross-Model Review Gate deepened (subagent-friendly writer/reviewer separation); spec `docs/archived/spec-DEV-050.md`; test plan `docs/AgToosa_TestPlan-DEV-050.md`; estimate S; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-11 | /agtoosa-spec — Spec ✅ Approved — DEV-050 — spec-DEV-050.md; estimate S; enrolled in cycle | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — DEV-050 — TDD cycle; 5 tasks; scope: AgToosa_CrossModelReview.md, Review, Specialists, Evidence, config, adapters, bats CM-001–CM-006; Wave 1: RED bats + canonical doc | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-050 — Task 🟢 2/5 — Wave 1 complete: CM bats RED (3 fail / 3 pass); `template/Docs/AgToosa_CrossModelReview.md` + `docs/` mirror | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-050 — Task 🟢 4/5 — Wave 2 complete: Review Part 5 + Specialists review hook + Evidence cross-model row + config + GitHub agent + adapters; CM-001–CM-006 green | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-050 — Task 🟢 5/5 — Wave 3 complete: CM-007 Agent/Skills/Quickref cross-links + GREEN evidence in test plan; DEV-050 filter 8/8 green; build complete — next: `/agtoosa-review` | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — DEV-050 — 4-persona + cross-model review running | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-050; 0 🔴 Critical, 5 🟡 Warning (4 fixed, 1 accepted); report: `docs/archived/review-DEV-050.md`; evidence: `docs/archived/evidence-DEV-050.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.6 — DEV-050 Cross-Model Review Gate; bats DEV-050 CM/SR green; smoke PASS | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.6 shipped — v5.3.6; version parity bash/ps1/npm; Milestone v5.3.7 (next) | AgToosa |
| 2026-07-11 | ✏️ /agtoosa-spec DEV-055 enrolled — Agent Capability Matrix deepened (lifecycle routing matrix post-DEV-050); spec `docs/archived/spec-DEV-055.md`; test plan `docs/AgToosa_TestPlan-DEV-055.md`; estimate S; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-11 | /agtoosa-spec — Spec ✅ Approved — DEV-055 — spec-DEV-055.md; estimate S; enrolled in cycle | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — DEV-055 — TDD cycle; 5 tasks; scope: AgToosa_AgentCapability.md, Handoff/Review/Build/Help, Specialists cross-link, config, bats AM-001–AM-007; Wave 1: RED bats + canonical doc | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-055 — Task 🟢 2/5 — Wave 1 complete: AM bats RED (5 fail / 3 pass); `template/Docs/AgToosa_AgentCapability.md` + `docs/` mirror | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-055 — Task 🟢 4/5 — Wave 2 complete: Handoff/Review/Build/Help + CrossModelReview + Specialists + config; AM-001–AM-007 green | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-055 — Task 🟢 5/5 — Wave 3 complete: GREEN evidence in test plan; DEV-055 filter 8/8 green; build complete — next: `/agtoosa-review` | AgToosa |
| 2026-07-11 | ✏️ Roadmap intake split complete — DEV-045/046/051/052/053/056/057/058/059 deepened to executable backlog specs; DEV-075–DEV-084 specs and test plans added; coverage index: `docs/updates/roadmap-spec-index.md`; no stories enrolled or approved | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — DEV-055 — 4-persona review running | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-055; 0 🔴 Critical, 3 🟡 Warning (2 accepted, 1 fixed); report: `docs/archived/review-DEV-055.md`; evidence: `docs/archived/evidence-DEV-055.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.7 — DEV-055 Agent Capability Matrix; bats DEV-055 AM/SR green; smoke PASS | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.7 shipped — v5.3.7; version parity bash/ps1/npm; Milestone v5.3.8 (next) | AgToosa |
| 2026-07-11 | ✏️ /agtoosa-spec — Four-epic parallel enrollment — DEV-075 (DEV-002), DEV-053 (DEV-003), DEV-078 (DEV-004), DEV-081 (DEV-001); specs approved; parallel `/agtoosa-build` via subagents | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-075 — Task 🟢 5/5 — ADP-001–ADP-009 green; guide suite + README links | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-078 — Task 🟢 4/4 — F15-001–F15-008 green; launch-readiness maintenance gate | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-081 — Task 🟢 4/4 — DXV-001–DXV-008 green; spike evidence doc (no production code) | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-053 — Task 🟡 1/4 — PC-001–PC-008 RED; `lib/catalog.sh` + fixtures; GREEN pending | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-053 — Task 🟢 4/4 — PC-001–PC-008 green; `--catalog` CLI + 3 entries + adapters | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — DEV-075 + DEV-053 + DEV-078 + DEV-081 — 4-persona parallel review via subagents | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-075; 0 🔴 Critical, 2 🟡 Warning accepted; report: `docs/archived/review-DEV-075.md`; evidence: `docs/archived/evidence-DEV-075.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-078; 0 🔴 Critical; report: `docs/archived/review-DEV-078.md`; evidence: `docs/archived/evidence-DEV-078.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-081; 0 🔴 Critical; report: `docs/archived/review-DEV-081.md`; evidence: `docs/archived/evidence-DEV-081.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-053; 0 🔴 Critical, 8 🟡 Warning accepted; cross-model Recommended tier; report: `docs/archived/review-DEV-053.md`; evidence: `docs/archived/evidence-DEV-053.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.8 — DEV-075 + DEV-053 + DEV-078 + DEV-081 batched; bats ADP/PC/F15/DXV + SR green; smoke PASS | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.8 shipped — v5.3.8; version parity bash/ps1/npm; Milestone v5.3.9 (next); active cycle archived | AgToosa |
| 2026-07-11 | ✏️ /agtoosa-spec DEV-045 enrolled — Work Package Wave DAG deepened (schema + Spec/Build/Handoff/Import wiring); spec `docs/archived/spec-DEV-045.md`; test plan `docs/AgToosa_TestPlan-DEV-045.md`; estimate M; Active Cycle Todo; awaiting Spec Approved | AgToosa |
| 2026-07-11 | ✅ /agtoosa-spec — Spec ✅ Approved — remaining-specs fan-out wave 1: DEV-045/076/077/079/080/082/083/084; demand-gated DEV-051/057 parked; dependents DEV-046/059/052/056/058 deferred to later waves | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — remaining-specs fan-out wave 1 — 8 parallel subagents; orchestrator owns Master-Plan | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-082 — Task 🟢 4/4 — HAS bats green; spike decision Defer; no production flags | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-083 — Task 🟢 4/4 — MET-001–010 green; metrics kit + case-study template; no telemetry | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-080 — Task 🟢 3/4 automated (OPP-001–010); 4.2/4.3 external publish [manual-deferred]; local candidates only | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-079 — Task 🟢 5/5 — VCA-001–009 green; verifier-ci-adoption guide + gate/Quickref/Readiness alignment | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-084 — Task 🟢 3/4 automated (OSS-001–007); Sponsors live enablement [manual-deferred]; SUPPORT boundary aligned | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-077 — Task 🟢 5/5 — AUTH-001–008 green; authoring guides + Registry/README/help discovery | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-045 — Task 🟢 4/4 — DAG-001–007 green; Work Package schema + Spec/Build/Handoff/Import wiring | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-076 — Task 🟢 4/4 — SITE-001–008 green; Pages build-only proof; optional owner enablement | AgToosa |
| 2026-07-11 | 🏗️ Build complete — wave 1 (DEV-045/076/077/079/080/082/083/084); next: parallel /agtoosa-review | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — remaining-specs wave 1 — 8-story parallel review via subagents | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-077; 0 🔴 Critical, 4 🟡 Warning accepted; report: `docs/archived/review-DEV-077.md`; evidence: `docs/archived/evidence-DEV-077.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-084; 0 🔴 Critical, 5 🟡 Warning accepted; Sponsors live [manual-deferred]; report: `docs/archived/review-DEV-084.md`; evidence: `docs/archived/evidence-DEV-084.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-082; 0 🔴 Critical, 5 🟡 Warning accepted; Defer preserved; report: `docs/archived/review-DEV-082.md`; evidence: `docs/archived/evidence-DEV-082.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-079; 0 🔴 Critical; report: `docs/archived/review-DEV-079.md`; evidence: `docs/archived/evidence-DEV-079.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-076; 0 🔴 Critical, 4 🟡 Warning accepted; report: `docs/archived/review-DEV-076.md`; evidence: `docs/archived/evidence-DEV-076.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-083; 0 🔴 Critical, 4 🟡 Warning accepted; report: `docs/archived/review-DEV-083.md`; evidence: `docs/archived/evidence-DEV-083.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-080; 0 🔴 Critical, 5 🟡 Warning accepted; 4.2/4.3 [manual-deferred]; report: `docs/archived/review-DEV-080.md`; evidence: `docs/archived/evidence-DEV-080.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-045; 0 🔴 Critical, 6 🟡 Warning accepted; report: `docs/archived/review-DEV-045.md`; evidence: `docs/archived/evidence-DEV-045.md` | AgToosa |
| 2026-07-11 | 🔍 Review complete — remaining-specs wave 1 all PASS (0 critical); next: `/agtoosa-ship` v5.3.9 | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.9 — remaining-specs wave 1 (DEV-045/076/077/079/080/082/083/084); smoke PASS; cycle archived | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.9 shipped — v5.3.9; version parity bash/ps1/npm; Milestone v5.3.10 (next) | AgToosa |
| 2026-07-11 | ✅ /agtoosa-spec — Spec ✅ Approved — wave 2: DEV-046 · DEV-059; enrolled post v5.3.9 | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — wave 2 — DEV-046 · DEV-059 parallel subagents | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-046 — Task 🟢 4/4 — WT-001–006 green; AgToosa_Worktree.md + Build/Handoff/Import wiring | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-059 — Task 🟢 4/4 — GP-001–009 green; GovernancePolicy + checker + Handoff Applicable Policy | AgToosa |
| 2026-07-11 | 🏗️ Build complete — wave 2 (DEV-046 · DEV-059); next: parallel /agtoosa-review | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — wave 2 DEV-046 · DEV-059 | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-059; 0 🔴 Critical, 4 🟡 Warning accepted; report: `docs/archived/review-DEV-059.md`; evidence: `docs/archived/evidence-DEV-059.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-046; 0 🔴 Critical, 4 🟡 Warning accepted; report: `docs/archived/review-DEV-046.md`; evidence: `docs/archived/evidence-DEV-046.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.10 — wave 2 DEV-046 · DEV-059; smoke PASS; cycle archived | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.10 shipped — v5.3.10; version parity bash/ps1/npm; Milestone v5.3.11 (next) | AgToosa |
| 2026-07-11 | ✅ /agtoosa-spec — Spec ✅ Approved — wave 3: DEV-052 · DEV-056 | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — wave 3 — DEV-052 · DEV-056 parallel subagents | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-052 — Task 🟢 4/4 — HK-001–007 green; Hooks pack + Init/Update preview; no silent install | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-056 — Task 🟢 4/4 — RL-001–008 green; AgToosa_Retro.md + ship retro wiring | AgToosa |
| 2026-07-11 | 🏗️ Build complete — wave 3 (DEV-052 · DEV-056); next: parallel /agtoosa-review | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — wave 3 DEV-052 · DEV-056 | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-056; 0 🔴 Critical; report: `docs/archived/review-DEV-056.md`; evidence: `docs/archived/evidence-DEV-056.md` | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-052; 0 🔴 Critical, 4 🟡 Warning accepted; report: `docs/archived/review-DEV-052.md`; evidence: `docs/archived/evidence-DEV-052.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.11 — wave 3 DEV-052 · DEV-056; smoke PASS; cycle archived | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.11 shipped — v5.3.11; version parity bash/ps1/npm; Milestone v5.3.12 (next) | AgToosa |
| 2026-07-11 | ✅ /agtoosa-spec — Spec ✅ Approved — wave 4: DEV-058 | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — wave 4 — DEV-058 | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-058 — Task 🟢 4/4 — DB-001–008 green; agtoosa-dashboard.sh Markdown/HTML stdout-only | AgToosa |
| 2026-07-11 | 🏗️ Build complete — wave 4 (DEV-058); next: /agtoosa-review | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — wave 4 DEV-058 | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-058; 0 🔴 Critical, 3 🟡 Warning accepted; report: `docs/archived/review-DEV-058.md`; evidence: `docs/archived/evidence-DEV-058.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.12 — wave 4 DEV-058; smoke PASS; cycle archived | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.12 shipped — v5.3.12; version parity bash/ps1/npm; Milestone v5.3.13 (next); all unblocked remaining specs complete | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-085 — Task 🟢 1/1 — bats restore (bb8a8bd) + Master-Plan reconciliation after v5.3.12 ship drift | AgToosa |
| 2026-07-11 | ✏️ DEV-085 — Master-Plan Update Log / Completed This Cycle / Epics reconciled; roadmap-spec-index note added | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-085; 0 🔴 Critical; report: `docs/archived/review-DEV-085.md`; evidence: `docs/archived/evidence-DEV-085.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.13 — DEV-085; smoke PASS; cycle archived | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.13 shipped — v5.3.13; version parity bash/ps1/npm; Milestone v5.3.14 (next); post-ship hygiene complete | AgToosa |
| 2026-07-11 | ✏️ /agtoosa-spec DEV-051 enrolled — Tracker Sync Bridge; demand un-gated; GitHub Issues first adapter; spec `docs/archived/spec-DEV-051.md`; test plan `docs/AgToosa_TestPlan-DEV-051.md`; estimate M; Active Cycle Todo | AgToosa |
| 2026-07-11 | /agtoosa-spec — Spec ✅ Approved — DEV-051 — spec-DEV-051.md; estimate M; enrolled in v5.3.14 cycle | AgToosa |
| 2026-07-11 | 🏗️ Build 🏗️ Started — DEV-051 — TDD cycle; 10 tasks; scope: lib/tracker.sh, AgToosa_TrackerSync.md, --tracker CLI, TS-001–TS-008 bats | AgToosa |
| 2026-07-11 | 🏗️ /agtoosa-build DEV-051 — Task 🟢 10/10 — TS-001–TS-008 green; export/propose local-only; Master-Plan mutation guard PASS | AgToosa |
| 2026-07-11 | 🏗️ Build complete — DEV-051; next: `/agtoosa-review` | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-review — Review 🔍 Started — DEV-051 — 4-persona review running | AgToosa |
| 2026-07-11 | 🔍 Review ✅ Approved — DEV-051; 0 🔴 Critical, 2 🟡 Warning (accepted); report: `docs/archived/review-DEV-051.md`; evidence: `docs/archived/evidence-DEV-051.md` | AgToosa |
| 2026-07-11 | 🚀 Ship complete — v5.3.14 — DEV-051 Tracker Sync Bridge; smoke PASS; cycle archived | AgToosa |
| 2026-07-11 | 🚀 Release 5.3.14 shipped — v5.3.14; version parity bash/ps1/npm; Milestone v5.3.15 (next); all unblocked remaining specs complete | AgToosa |
| 2026-07-11 | 🔍 /agtoosa-spec triage — no enrollable stories; DEV-057 demand gate unmet (7/7 fields); competitive wave complete; cycle remains parked | AgToosa |
