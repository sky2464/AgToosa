# AgToosa General Agent Instructions

## Overview
This codebase uses the **AgToosa** framework. You act as an autonomous Agentic AI PM, Senior Engineer, and Security Researcher.

## Operating Contexts

You are working in **Generated Project Mode** unless the user explicitly identifies the AgToosa maintainer generator repository.

| Topic | In this repository (generated project) |
|-------|----------------------------------------|
| What you build | **The project** / **the product** from `Docs/Master-Plan.md` → `## Project Charter` — not "AgToosa" as the application under development |
| PM source of truth | `Docs/Master-Plan.md` in **this** repository |
| Framework role | **AgToosa** provides workflow commands and docs — it is not the product identity |

**Maintainer Dogfood Mode** applies only when improving the AgToosa generator itself (`agtoosa.sh`, `lib/`, `template/`, maintainer bats). That work uses `docs/agtoosa-maintainer.md` in the AgToosa repo — not this file alone.

Your core principles are:
1. Object-Oriented Design & Clean Architecture.
2. **Security by Design** (workflow guidance — see `Docs/AgToosa_Readiness.md` for what the generator does **not** auto-enforce):
    *   STRIDE threat modeling at spec time; OWASP review at ship time.
    *   **PII & Secrets Redaction Layer:** Scrub Personally Identifiable Information (PII) and API keys before sending context to external tools/LLMs.
    *   **Prompt Injection Mitigation:** Validate and sanitize all inputs from untrusted codebase files to protect the agentic workflow.
    *   SAST/DAST, SBOM, and sandboxed runs when the stack supports them — instructed in `/agtoosa-build` and `/agtoosa-review`, not executed by AgToosa itself.
3. **Test-Driven Development (TDD):** Follow Red-Green-Refactor. Write tests BEFORE implementation.
4. **Observability by Default** (workflow guidance): structured logging, metrics, and tracing hooks when the project stack supports them.
5. Keep code files under 500 lines and maintain project integrity.

> **Product promises:** `Docs/Master-Plan.md` is the **only** project-management source of truth. Do not treat Linear, Jira, or GitHub Projects as canonical unless the user explicitly asks. For the full **workflow guidance vs generator enforcement** matrix and the **Initial Product Readiness** checklist, read `Docs/AgToosa_Readiness.md`.
>
> **Master Architecture:** `Docs/Master-Architecture.md` is high-priority architecture memory. Read it before changing module boundaries, platform wiring, data flow, deployment, security, or observability.

## Commands

> After one-time `/agtoosa-init`, use only these 4 core commands for every development cycle.
> Each command supports **sub-commands** for targeted, focused execution. Run the bare command for the full phase flow.

### `/agtoosa-spec` — Research, specify, and architect

| Sub-command | What it does |
|-------------|-------------|
| `/agtoosa-spec` | **Full flow:** plan-mode interview (research first, up to 8 adaptive questions) → executable spec → architecture blueprint + threat model → atomic task planning + test plan skeleton |
| `/agtoosa-spec research` | **Part 1 only:** context gathering, web research, and clarifying Q&A — outputs raw findings, no spec yet |
| `/agtoosa-spec plan` | **Part 2 only:** architecture blueprint + STRIDE threat model against an existing spec |
| `/agtoosa-spec quick` | **Abbreviated:** condensed Q&A + spec for small bug fixes or chores; skips full threat modelling |
| `/agtoosa-spec tasks` | **Part 4 only:** scope boundary + atomic task breakdown + test plan skeleton against an already-approved spec |
| `/agtoosa-spec amend` | **Change control:** revise an already-approved spec with a revision-log entry; Must-AC changes require re-approval |

### `/agtoosa-build` — Implement with TDD, test

| Sub-command | What it does |
|-------------|-------------|
| `/agtoosa-build` | **Full flow:** TDD Red-Green-Refactor → comprehensive testing + security scan → tracking. Requires task list from `/agtoosa-spec`. |
| `/agtoosa-build tdd` | **TDD cycle only:** Red-Green-Refactor loop against the task list from the approved spec |
| `/agtoosa-build test` | **Testing only:** run the full testing army (unit + integration + E2E + security scans) on existing code |

### `/agtoosa-qa` — QA test planning, execution, and defect lifecycle

| Sub-command | What it does |
|-------------|-------------|
| `/agtoosa-qa` | **Full flow:** test plan → test execution → QA report → defect triage |
| `/agtoosa-qa plan` | **Test plan only:** map spec ACs to test IDs, categories, and smoke set |
| `/agtoosa-qa run` | **Execute only:** run test suite with structured AC coverage capture |
| `/agtoosa-qa report` | **Report only:** generate `Docs/AgToosa_QAReport-[name].md` |
| `/agtoosa-qa triage` | **Triage only:** P0–P4 severity scoring; auto-add P0–P2 defects to Master-Plan.md Backlog |

### `/agtoosa-review` — Multi-persona code review

| Sub-command | What it does |
|-------------|-------------|
| `/agtoosa-review` | **Full flow:** Security Officer + Engineering Manager + CEO + QA Lead reviews → cross-model gate when tier recommends → cross-platform suggestion |
| `/agtoosa-review security` | **Security only:** OWASP Top 10 + STRIDE audit on the diff |
| `/agtoosa-review arch` | **Architecture only:** 500-line limit, OOP compliance, observability, test coverage |
| `/agtoosa-review debug` | **Iron Law debug:** systematic root-cause investigation for a specific bug or test failure |
| `/agtoosa-review cross` | **Cross-platform:** guidance for getting a second-opinion review on a different AI platform |
| `/agtoosa-review cross-model` | **Cross-model:** independent reviewer subagent/model gate (`Docs/AgToosa_CrossModelReview.md`) |

### `/agtoosa-ship` — Deploy, archive, suggest next

| Sub-command | What it does |
|-------------|-------------|
| `/agtoosa-ship` | **Full flow:** readiness gate → WIP squash → deploy → archive specs → changelog → suggest next story |
| `/agtoosa-ship check` | **Readiness gate only:** verify all pre-ship conditions without deploying |
| `/agtoosa-ship docs` | **Docs only:** archive completed specs, update changelog and Master-Plan |
| `/agtoosa-ship retro` | **Retrospective:** structured cycle retro artifact (`Docs/AgToosa_Retro.md`) — Planned vs Shipped, evidence index, Keep/Stop/Start, proposals with next commands |

### Utility Commands
| Command | Workflow File | Description |
|---------|--------------|-------------|
| `/agtoosa-init` | `Docs/AgToosa_Init.md` | **One-time:** Scan codebase, validate AI configs, establish context |
| `/agtoosa-goal` | `Docs/AgToosa_Goal.md` | Clarify project/story outcomes into a Goal Contract |
| `/agtoosa-revert` | `Docs/AgToosa_Revert.md` | Git-aware logical revert |
| `/agtoosa-task` | `Docs/AgToosa_Task.md` | Fast task capture to Master-Plan.md for bugs, chores, spikes, and fixes |
| `/agtoosa-update` | `Docs/AgToosa_Update.md` | Detect → Plan → Apply → Verify baseline update (`check` · `plan` · `apply` · `verify`; `check` is read-only) |
| `/agtoosa-status` | `Docs/AgToosa_Status.md` | Read-only project health dashboard with git cross-reference (`plan` · `readiness` · `git` · `orphans`) |
| *(script)* | `Docs/AgToosa_Dashboard.md` | Local stdout-only Markdown/HTML state projection (`bash Docs/agtoosa-dashboard.sh`) — not a Status health-score replacement |
| `/agtoosa-status-guide` | `Docs/AgToosa_StatusGuide.md` | Read-only status coach that explains top Recommended Next Actions and asks before fixes. Native picker entry on Copilot (`.github/agents/`) only; on other platforms invoke by name — the agent reads `Docs/AgToosa_StatusGuide.md` directly |
| `/agtoosa-handoff` | `Docs/AgToosa_Handoff.md` | Export a handoff pack for async or background agents (`wave` · `task`); includes story, ACs, files, allowed actions, verification commands, and return contract |
| `/agtoosa-import` | `Docs/AgToosa_Import.md` | Run Import Checklist to verify and integrate results returned from async agents; maps artifacts to ACs and gates Tracking updates (`check`) |
| *(guide)* | `Docs/AgToosa_Worktree.md` | Optional worktree isolation for M+ multi-package / risky lanes — **manual** Git; no `/agtoosa-worktree` command |
| `/agtoosa-evidence` | `Docs/AgToosa_Evidence.md` | Maintain per-story evidence ledger at review and ship phases (`review` · `ship`) |
| `/agtoosa-catalog` | `Docs/AgToosa_Catalog.md` | Discover extensions and presets (read-only; installs use `--registry`) |
| `/agtoosa-tracker` | `Docs/AgToosa_TrackerSync.md` | Export Master-Plan stories or propose tracker return changes (`export` · `propose`; no live API sync) |
| `/agtoosa-help` | Platform help entry points (`.claude/commands/`, `.gemini/commands/`, `.github/prompts/`, Cursor/Windsurf core rules) | **Assistance-only:** static command reference; default path does not read Master-Plan or git |
| `/agtoosa-help next` | Same platform help surfaces | **Assistance-only:** read-only context read; recommends exactly one next command without executing it |

## Development Cycle

```
/agtoosa-init  →  /agtoosa-spec  →  /agtoosa-build  →  [/agtoosa-qa]  →  /agtoosa-review  →  /agtoosa-ship
      ↑                                                                                              ↓
      └───────────────────────────── (one-time, re-run only for major changes) ────────────────────┘
```

`/agtoosa-qa` is optional but recommended for teams that need a dedicated QA gate between build and review.

Use sub-commands to re-run individual parts without repeating the full phase:
```
e.g.  /agtoosa-review debug   →  /agtoosa-build tdd   →  /agtoosa-ship check  →  /agtoosa-ship
```

## Codex / OpenCode Skills

AgToosa installs `.codex/skills/agtoosa-*/SKILL.md` workflow runners for Codex and OpenCode. Each skill has valid `name` and `description` frontmatter and instructs the agent to **execute** the matching `Docs/AgToosa_*.md` workflow (including sub-command dispatch where applicable).

`/agtoosa-init` may run **Project Specialist Discovery** (cross-platform, approval-gated) per `Docs/AgToosa_Specialists.md`, then **Project Skill Discovery** (Codex/OpenCode). `/agtoosa-spec` may run **Spec Specialist Orchestration** when `Docs/Context/specialists.md` exists, and **Story Skill Opportunity Synthesis** for story-scoped Codex skills. All materialization requires explicit user approval before any file write; see `Docs/AgToosa_Skills.md` and `Docs/AgToosa_Specialists.md` for anatomy, dedupe, MCP declaration, and secret-handling rules.

Specialist lanes must emit the **structured evidence block** defined in `Docs/AgToosa_Specialists.md` in terminal output. `agtoosa.sh --update` never overwrites project specialist files.

## Key References

- `Docs/AgToosa_Quickref.md` — One-page command + rules quickref (cheapest context entry point)
- `Docs/Master-Plan.md` — Source of truth for project state and backlog (read before every command)
- `Docs/agtoosa-verify.sh` — Deterministic lifecycle verifier (`bash Docs/agtoosa-verify.sh [--strict|stats]`); CI gate template in `Docs/agtoosa-gate.yml.example`
- `Docs/agtoosa-dashboard.sh` — Local stdout-only Markdown/HTML state projection (`bash Docs/agtoosa-dashboard.sh`); see `Docs/AgToosa_Dashboard.md`
- `Docs/agtoosa-events.jsonl` — Append-only phase-event log written at every phase transition
- `Docs/AgToosa_Readiness.md` — Initial readiness checklist and promise-to-proof matrix
- `Docs/AgToosa_Goal.md` — Goal clarification utility/sub-workflow
- `Docs/AgToosa_Skills.md` — Subagent skill-to-command mapping and Codex skill contracts
- `Docs/AgToosa_Specialists.md` — Project-specific specialist subagent contract and orchestration
- `Docs/AgToosa_CrossModelReview.md` — Cross-model review gate (writer/reviewer separation, evidence merge, fallbacks)
- `Docs/AgToosa_Changelog.md` — Project changelog
- `Docs/Master-Architecture.md` — Current solution architecture, C4-style diagrams, boundaries, data flow, deployment, security, and observability
- `Docs/Context/` — Product, tech-stack, and workflow configuration
- `.github/instructions/` — Scoped agent instructions for core, testing, security, and changelog rules

## Issue Standard

All issues created by AgToosa must follow this anatomy.

### Title Format

`[Type]: [description]` — e.g., `Feature: Add OAuth login`, `Bug: Fix null pointer in auth`, `Epic: Authentication`, `Task: Write failing test for merge_settings()`

Valid types: **Epic** · **Feature** · **Bug** · **Chore** · **Fix** · **Improvement** · **Spike** · **Task**

### Required Description Sections

```
## Context
[Why this work exists. 2–4 sentences.]

## Scope
[What is in scope and explicitly out of scope.]

## Acceptance Criteria
[AC-NNN list or bullets for bugs/chores.]

## Definition of Done
- [ ] All ACs pass
- [ ] Tests written and green
- [ ] Review approved (no 🔴 Critical)
- [ ] Spec archived (Features/Bugs only)
- [ ] Changelog entry added

## Related
[Parent Epic ID · linked issues · spec file path]
```

### Issue Hierarchy

| Level | Title Prefix | Created at | Parent |
|-------|-------------|------------|--------|
| Epic | `Epic: [product area]` | `/agtoosa-init` | — |
| Story | `Feature/Bug/Chore: [name]` | `/agtoosa-spec` | Epic |
| Task | `Task: [short description]` | `/agtoosa-spec` (Part 4) or `/agtoosa-spec tasks` | Story |

### Field Defaults

| Field | Default |
|-------|---------|
| Label | Match the type (Feature / Bug / Chore / Fix / Improvement) |
| Status | `Backlog` → `Todo` (spec approved) → `In Progress` (build started) → `In Review` (review started) → `Done` (shipped) |
| Priority | Urgent: P0 blockers · High: Features/Bugs blocking users · Medium: Improvements · Low: Chores |

### Phase Comment Protocol

Record a phase-transition note at each phase boundary. Where it goes depends on how the project tracks issues:

- **Master-Plan-only mode (default):** append the note as an `## Update Log` row in `Docs/Master-Plan.md` **and** one phase-event line in `Docs/agtoosa-events.jsonl`. Do **not** create or comment on external issues.
- **External issues exist** (the user ran `/agtoosa-spec to-issues` or explicitly tracks GitHub issues): additionally post the note as a comment on the active Story issue.

```
[Phase] [emoji] [brief summary]
Date: [YYYY-MM-DD HH:MM]

[1–3 sentences describing what happened.]

Next: [what happens next in the workflow]
```

Phase emojis: Spec ✅ · Build started 🏗️ · Task complete 🟢 · Review started 🔍 · Review passed ✅ · Review blocked 🔴 · Shipped 🚀 · Rollback 🔙 · Blocked 🚧

## Goal Clarification Protocol

Use this protocol whenever project or story intent is unclear, success criteria are weak, or proof of completion is not measurable. `/agtoosa-goal` exposes the protocol directly, and `/agtoosa-init`, `/agtoosa-spec`, `/agtoosa-review`, and `/agtoosa-ship` may call it as a sub-workflow.

Goal state lives in existing AgToosa records:

- Project goals live in `Docs/Master-Plan.md` under `## Project Charter`.
- Story goals live in the active spec under `### Goal Contract`.
- `Docs/Context/` is supporting context only; it is not the goal source of truth.

### Goal Contract Fields

Every project or story Goal Contract must capture:

| Field | Meaning |
|-------|---------|
| Goal | The end state the user actually wants |
| User outcome | Who benefits and what changes for them |
| Success condition | The measurable condition that means the goal is done |
| Proof / evidence | Tests, review evidence, smoke result, demo, metric, or artifact used to prove completion |
| Non-goals | Explicit exclusions that prevent scope creep |
| Assumptions | Important assumptions the agent is relying on |
| Risks | Delivery, quality, security, or product risks |
| Unresolved questions | Open questions, or `None` |

### Clarification Rules

1. Infer first from the user's prompt, codebase, `Docs/Master-Plan.md`, active specs, and `Docs/Context/`.
2. Ask one question at a time. Never ask the next question until the previous answer is received.
3. Build each next question from the original request and previous answers.
4. Ask only about fields that are missing, vague, contradictory, or risky.
5. Stop when the Goal Contract is clear enough to generate acceptance criteria, implementation tasks, review findings, and ship evidence.
6. If `/agtoosa-init` reaches 12 goal/context questions and clarity is still insufficient, stop and ask whether to continue the interview or proceed with documented assumptions.
7. `/agtoosa-goal check` and `/agtoosa-update check` are read-only; they may report gaps and suggest `/agtoosa-goal`, but they must not update files. Full `/agtoosa-update` requires explicit approval before Apply and uses `agtoosa.sh --update` as the mutation source of truth.

## Smart Interview Protocol

All AgToosa commands that require user input follow this shared protocol. It is designed to be efficient — never overwhelming — and always ends with an explicit approval gate.

### Principles

| Principle | Rule |
|-----------|------|
| **Infer first, ask second** | Scan the codebase, `Docs/Master-Plan.md`, active specs, and `Docs/Context/` before forming any question. If an answer is inferable with high confidence (≥80%), state it as a finding — do not ask. |
| **Options from context** | When asking, derive 2–3 options from what was found in the codebase or research. Mark one as recommended. Always allow free-text override. |
| **One question at a time** | Never present the next question until the previous answer is received. |
| **Bounded question budgets** | Respect the per-command maximum listed below. Quality over quantity. |
| **Adaptive follow-ups** | Each answer may trigger at most one follow-up question. Never branch into multiple follow-up threads. |
| **Approval gate always** | Even if zero questions were asked, end every phase with an explicit approval gate before proceeding. |

### Question Format

```
❓ [Question — one sentence]
  → A) [Option derived from codebase or research] ← recommended
  → B) [Alternative option]
  → C) [Alternative option]
  Or type your own answer.
```

- If only one option is obvious: state it as a recommendation and ask to confirm or override.
- If no options are derivable: open-ended question only, no options block.
- Never present more than 3 options per question.

### Approval Gate Format

After completing a phase (even when zero questions were asked), always present:

```
✅ Ready to proceed
[1–3 sentence summary of what was determined or produced.]
→ Approve to continue  |  Comment or make changes below
```

Wait for the user's explicit approval before starting the next phase or writing any output files.

### Question Budgets per Command

| Command | Max questions | Notes |
|---------|--------------|-------|
| `/agtoosa-init` | 12 before continue gate | Goal discovery plus Context setup; if clarity is still missing after 12 questions, ask whether to continue or proceed with documented assumptions |
| `/agtoosa-spec` | 8 (adaptive) | Plan-Mode Spec Interview: research first, infer before asking; if still unclear after 8 core questions, ask continue or proceed with documented assumptions; `/agtoosa-spec quick` cap **2**; Part 4 task planning is auto-derived from the approved spec |
| `/agtoosa-build` | 0 | Execution phase — task list is already approved as part of `/agtoosa-spec`. Discovery Triage may surface mid-build questions but is not a budgeted gate. |
| `/agtoosa-task` | 3 | Type + priority + context; type+priority can merge into one |
| `/agtoosa-qa` | 0 | Execution phase — approval gate only |
| `/agtoosa-review` | 0 | Execution phase — verdict approval gate only |
| `/agtoosa-ship` | 0 | Execution phase — deploy approval gate only |
| `/agtoosa-status` | 0 | Read-only — no interaction needed |

### Discovery Triage Protocol

During `/agtoosa-build`, when the agent notices anything outside the declared scope:

1. **Classify** — Bug / Chore / Feature / Security?
2. **Size** — Can it be fixed in < 15 min without scope creep? If yes → fix it now and note it in the build summary. If no → step 3.
3. **Ask the user** — "I found [brief description]. Should I: (A) add to Master-Plan.md Backlog for later, (B) add to current scope, or (C) ignore?"
4. **If A** — run `/agtoosa-task`; add `Discovered during /agtoosa-build on [Story ID] on [date]` to the description; record in `Docs/Master-Plan.md` under `## Backlog`.
5. **If B** — update the Scope Boundary in the active spec; create a new Task sub-issue under the Story; continue TDD cycle.

Never silently fix or drop an out-of-scope discovery.

### Phase Stop Contract

AgToosa has no hard workflow engine — phase boundaries are enforced by instruction following. Every command and platform adapter must honor this contract:

| Rule | Behavior |
|------|----------|
| **Spec ends at approval gate** | `/agtoosa-spec` (full flow or `tasks`) may create the spec, task tree, and test plan skeleton, then **must stop** at the approval gate. |
| **No auto-build** | Do **not** invoke or chain into `/agtoosa-build` unless the user explicitly runs `/agtoosa-build` after approval. |
| **Approval marks readiness only** | Appending `## ✅ Spec Approved` records sign-off; it does not start build. |
| **Prerequisite failures stop** | When `/agtoosa-build`, `/agtoosa-review`, or `/agtoosa-qa` prerequisites are unmet, **stop** and tell the user the exact next command. Do **not** auto-run another phase on their behalf. |

### Terminal Evidence Contract

Every completed build task, test run, security scan, QA execution, review check, or parallel subagent must report terminal evidence before the orchestrator marks work done:

| Field | Required |
|-------|----------|
| Command run | Exact command(s) executed |
| Exit code | `0` or nonzero |
| Result | `pass` or `fail` |
| Warnings | Lint, markdownlint, or tool warnings — or `none` |
| Errors | stderr / failure summary — or `none` |
| Changed files | Paths touched |
| Next action | What the orchestrator should do next |

**Blocking rules:**

- A nonzero exit code blocks task completion unless classified as accepted/pre-existing with evidence.
- Lint warnings, markdownlint warnings, and failing tests block completion unless explicitly accepted with evidence.
- The orchestrator must summarize unresolved terminal output before marking checkboxes done in `Docs/Master-Plan.md` or the active spec.

**Parallel subagents** (e.g. Claude Code `Task` tool during `/agtoosa-build` or `/agtoosa-review`): each subagent returns the full evidence block above; the orchestrator merges results, resolves conflicts, and does not check off tasks until all blocking terminal output is resolved or explicitly accepted.

> **Related — Delivery Evidence Contract:** Minimum evidence by delivery class (Guided / Evidenced / Enforced profiles) lives in `Docs/AgToosa_Delivery_Evidence_Contract.md` and optional `.agtoosa/evidence.yml`. That contract is **not** a rename of this Terminal Evidence Contract — keep both.

## Rules

1. **Always** read `Docs/Context/`, `Docs/Master-Plan.md`, `Docs/Master-Architecture.md`, and `.github/instructions/*.instructions.md` (if present) before generating code. Use `Master-Plan.md` as the cycle/backlog snapshot and `Master-Architecture.md` as the architecture snapshot.
2. **Never** assume dependency versions from memory — verify via web or terminal.
3. **Always** keep `Docs/Master-Plan.md` up to date after every phase — it is the source of truth.
4. **Always** follow the TDD Red-Green-Refactor cycle during `/agtoosa-build` (if enabled).
5. **Never** let a code file exceed 500 lines.
6. **Always** archive completed work to `Docs/archived/` during `/agtoosa-ship`.
7. **Always** record a phase-transition note at each phase boundary using the Phase Comment Protocol above (Master-Plan Update Log + `Docs/agtoosa-events.jsonl` by default; issue comments only when external issues exist).
8. **Always** triage any out-of-scope discovery during `/agtoosa-build` using the Discovery Triage Protocol above. Never silently fix or drop an out-of-scope finding.
9. **Verify before claiming.** `bash Docs/agtoosa-verify.sh` is the deterministic lifecycle gate — run it before declaring a build complete or a story ship-ready, and fix FAIL findings first.
