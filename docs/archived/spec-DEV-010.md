# Spec: DEV-010 — Workflow Reliability (Phase Gates & Terminal Evidence)

> **Story ID:** DEV-010
> **Epic:** DEV-002 — Workflow Templates
> **Status:** 🏁 Shipped (v4.4.0 — 2026-05-24)
> **Estimate:** S
> **Spec created:** 2026-05-23

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Strengthen soft phase boundaries and terminal-evidence guardrails so agents do not auto-chain workflows or mark tasks done without command proof. |
| User outcome | Maintainers and generated projects get consistent stop-at-approval spec behavior and prerequisite-failure guidance across platforms. |
| Success condition | W1–W5 bats green; full generator suite green; Phase Stop and Terminal Evidence contracts in canonical docs and adapters. |
| Proof / evidence | `bats tests/agtoosa.bats -f "W[1-5]:"` + 202/202 full suite (review + ship). |

### 1.2 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `/agtoosa-spec` completes THE SYSTEM SHALL stop at the approval gate and SHALL NOT auto-run `/agtoosa-build` | Must |
| AC-002 | WHEN `/agtoosa-build` prerequisites fail THE SYSTEM SHALL stop and instruct the user without auto-running `/agtoosa-spec` | Must |
| AC-003 | WHEN build/review/QA execute commands THE SYSTEM SHALL require terminal evidence before marking work complete | Must |
| AC-004 | WHEN DEV-010 ships THE SYSTEM SHALL add W1–W5 bats tests locking adapter and canonical contract parity | Must |

## Context

AgToosa phase boundaries are soft (ADR-003): agents may chain `/agtoosa-spec` into `/agtoosa-build`, auto-run prerequisite phases, or mark tasks done without terminal proof. This story adds text guardrails and bats parity so spec stops at approval, build/review/QA capture terminal evidence, and adapters stay aligned with canonical docs.

## 2. Design

### 2.1 Architecture Blueprint

| Layer | Change |
|-------|--------|
| **Canonical** | `AgToosa_Agent.md` — shared Phase Stop + Terminal Evidence contracts |
| **Workflow docs** | `AgToosa_Spec.md`, `AgToosa_Build.md`, `AgToosa_Review.md`, `AgToosa_QA.md` — phase-specific sections referencing canonical rules |
| **Platform adapters** | Codex skills, Cursor rules/commands, Claude/Copilot/Gemini/Windsurf spec+build entry points |
| **Verification** | W1–W5 bats in `tests/agtoosa.bats` |

No generator/runtime changes — markdown-only guardrails per ADR-003.

### 2.2 STRIDE Threat Model

| Threat | Category | Mitigation |
|--------|----------|------------|
| Agent auto-runs build before user approval | Elevation of Privilege | Phase Stop Contract; approval gate copy; W1 bats |
| Agent auto-runs spec when build prereqs fail | Tampering | Prerequisite **stop and instruct** wording; W2 bats |
| Tasks marked done despite failing tests/lint | Repudiation | Terminal Evidence Contract; blocking rules on exit/warnings |
| Parallel subagents hide failures from orchestrator | Information Disclosure | Subagent must return full evidence block; orchestrator summary before checkboxes |
| Cursor rule contradicts canonical interview cap | Spoofing (wrong behavior) | W3 aligns question budget and `Docs/archived/spec-[story-id].md` path |

### 2.3 Build Scope

| In scope | Out of scope |
|----------|----------------|
| `template/Docs/AgToosa_{Agent,Spec,Build,Review,QA}.md` | Hard workflow engine in `agtoosa.sh` |
| Spec/build platform adapters under `template/.{codex,cursor,claude,github,gemini,windsurf}/**` | `docs/AgToosa_*.md` repo mirrors (non-generated) |
| `tests/agtoosa.bats` W1–W4 | New CLI flags |

## 3. Tasks

### 3.1 Task Tree

- [x] **1.** Canonical contracts
  - [x] 1.1 Add Phase Stop + Terminal Evidence to `AgToosa_Agent.md`
  - [x] 1.2 Wire into Spec, Build, Review, QA workflow docs
- [x] **2.** Platform parity
  - [x] 2.1 Spec adapters: phase stop (no auto-build)
  - [x] 2.2 Build adapters: prerequisite stop + terminal evidence
  - [x] 2.3 Cursor spec rule: Smart Interview cap + archived path
- [x] **3.** Tests
  - [x] 3.1 Add W1–W5 bats; run full suite

### Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.3
**Wave 2 (sequential):** 1.2, 2.2, 3.1

## ✅ Spec Approved

Approved: 2026-05-24 01:50
