# ADR-003: Multi-Agent Orchestration Patterns

**Status:** Accepted  
**Date:** 2026-05-01  
**Deciders:** AgToosa maintainers

---

## Context

AgToosa coordinates multiple AI personas across a 4-phase development lifecycle (Spec → Build → Review → Ship). Each persona has a distinct role, toolset, and decision scope. The orchestration layer must:

- Work without a dedicated orchestration server — the AI assistant is the runtime
- Pass state across sessions, platforms, and personas without a shared database
- Support both sequential phase gating (one phase must pass before the next starts) and parallel execution (4 reviewers running simultaneously in the Review phase)
- Allow partial re-runs (e.g., re-running only QA) without invalidating prior phase artifacts
- Remain platform-agnostic — the same workflow must run in Cursor, Claude Code, Gemini CLI, and GitHub Copilot

The current implementation (v3.0.0) uses **persona-based dispatch via slash commands with `Master-Plan.md` as shared state**. Parallel agents are used in the Review phase only (Claude Code `agtoosa-review` skill).

---

## Decision

**Use persona-based slash command dispatch with `Master-Plan.md` as the shared state document, Linear as the authoritative issue tracker, and a parallel sub-agent pattern for the Review phase only.**

Orchestration is intentionally kept at the markdown/file layer rather than in a process supervisor or workflow engine. The AI assistant itself is the orchestrator. Commands are composable sub-commands (e.g., `/agtoosa-spec research` for Part 1 only) rather than a monolithic pipeline. State synchronization happens through explicit file writes and Linear issue updates, not in-memory state.

### Amendment — DEV-107 (2026-07-12)

**Status:** Accepted amendment (spec approved; implementation after Wave 1a)

Parallel execution is **no longer Review-only**. When the host supports native subagent delegation (per `Docs/AgToosa_AgentCapability.md`) and lane ownership is safe (Work Package DAG / disjoint files), orchestrators **default to parallel fan-out** across Spec, Build, Review, Ship, and related sync/task read-only lanes.

Canonical algorithm: `Docs/AgToosa_Orchestration.md` (Orchestration Brain) — inventory platforms, skills, specialists, MCP needs, host plugins/tools, and Wave packages → lane plan → parallel or sequential fallback → orchestrator merge. The assistant remains the orchestrator; AgToosa still does **not** ship a process supervisor, hosted swarm, or auto-launch runtime (Rev4 “Do Not Build Yet”).

See: `docs/archived/spec-DEV-107.md`, `docs/AgToosa_TestPlan-DEV-107.md`.

---

## Options Considered

### Option A: Persona-Based Dispatch + Master-Plan.md State (current)

Each workflow phase is a slash command (`/agtoosa-spec`, `/agtoosa-build`, etc.) backed by a markdown workflow document (`Docs/AgToosa_*.md`). `Master-Plan.md` is the shared context document that every command reads before executing and updates after completing. Linear mirrors this state with Epic → Story → Task hierarchy and phase-comment protocol.

**Dispatch patterns:**
1. **Sequential sub-commands** — `/agtoosa-build scope`, `/agtoosa-build tdd`, `/agtoosa-build test` run parts independently
2. **Parallel agents** (Claude Code only) — `/agtoosa-review` launches 4 agents simultaneously (Security Officer, Eng Manager, CEO/PO, QA Lead)
3. **Conditional dispatch** — argument routing in command files sends to the right sub-workflow

**State machine:** Linear issue status (`Backlog → Todo → In Progress → In Review → Done`) is the authoritative state; `Master-Plan.md` is the local mirror.

| Dimension | Assessment |
|-----------|------------|
| Complexity | Low — markdown files + Linear API calls |
| Platform portability | High — works on all 6 platforms |
| Parallelism | Partial — Review phase only, Claude Code only |
| State durability | High — file-based, survives session restarts |
| Dependency DAG | ❌ None — phase order not enforced programmatically |
| Rollback | Manual — `/agtoosa-revert` is git-aware but not automatic |

**Pros:**
- Platform-agnostic: any AI assistant can read markdown and call Linear
- State survives session restarts and platform switches — `Master-Plan.md` provides full context
- Partial re-runs work naturally (commands are independent)
- Zero infrastructure required

**Cons:**
- No programmatic phase-order enforcement — a user can run `/agtoosa-review` before `/agtoosa-build`
- Parallelism limited to Claude Code's `Agent` tool — not available in Cursor or Gemini
- No sub-agent dependency DAG: task distribution within Build is sequential
- Context passing between commands relies on the AI reading files correctly — susceptible to context window limits on long sessions

### Option B: Workflow Engine (e.g., Temporal, Prefect, GitHub Actions)

A dedicated workflow engine defines the DAG explicitly. Each phase is a workflow step with explicit inputs, outputs, and retry logic.

| Dimension | Assessment |
|-----------|------------|
| Complexity | High — requires running infra |
| Platform portability | Low — agents must call the engine's API |
| Parallelism | High — native fan-out/fan-in |
| State durability | High — engine manages state |
| Dependency DAG | ✅ Native |
| Rollback | ✅ Built-in |

**Pros:**
- Explicit DAG prevents out-of-order execution
- Native parallelism and retry logic
- Workflow history and audit trail built in

**Cons:**
- Requires always-on server or cloud account
- Each AI platform must be adapted to call the engine's API
- Dramatically increases project setup complexity
- Incompatible with zero-dependency constraint for CLI use

### Option C: LLM-Native Orchestrator (e.g., a top-level `AgToosa` agent with tool use)

A single orchestrator agent has access to all workflow tools as function calls. It decides which sub-agents to invoke, in what order, and when to gate progress.

| Dimension | Assessment |
|-----------|------------|
| Complexity | High — requires agent-level tool definitions |
| Platform portability | Low — tool-use APIs differ across platforms |
| Parallelism | High — orchestrator can fan out |
| State durability | Medium — depends on LLM context window |
| Dependency DAG | ✅ Implicit in orchestrator reasoning |
| Rollback | ✅ Orchestrator can choose to re-invoke a phase |

**Pros:**
- Most flexible — orchestrator can handle exceptions dynamically
- Native parallelism via tool use
- Phase gating enforced by the orchestrator's reasoning

**Cons:**
- Tool definitions diverge across Claude, Gemini, and Copilot APIs — not portable
- Long sessions hit context window limits; state in-memory is fragile
- Debugging orchestrator decisions is opaque
- Ties AgToosa to a specific AI provider's tool-use implementation

---

## Trade-off Analysis

Option A is correct for the current phase. The zero-dependency and platform-portability constraints rule out Options B and C for v3.x. The core trade-off is **safety vs. flexibility**: Option A allows out-of-order phase execution, which is occasionally useful (re-running QA without repeating the full build cycle) but can also lead to reviews of un-built code.

The practical mitigation for phase-order safety in Option A is the **Linear status gate**: the Spec phase sets the issue to `Todo`, Build moves it to `In Progress`, and Review requires `In Progress`. If a user runs `/agtoosa-review` on a `Todo` issue, the workflow document instructs the AI to warn and abort. This is a soft gate enforced by the AI's instruction following, not a hard programmatic lock.

Parallel sub-agents in the Review phase (Claude Code only) is a high-value optimization: 4 parallel reviewers complete in roughly the same wall time as 1, with more thorough coverage. Extending this to other platforms is blocked on those platforms exposing an `Agent` tool equivalent.

---

## Context Passing: Master-Plan.md as Shared State

```
Session N                     Session N+1
/agtoosa-spec                  /agtoosa-build
  └─ Reads Master-Plan.md        └─ Reads Master-Plan.md
  └─ Creates Linear Story        └─ Reads Linear Story
  └─ Writes spec to Master-Plan  └─ Continues from known state
  └─ Posts "Spec ✅ Approved"
```

`Master-Plan.md` is the conversation handoff document. It contains the full project charter, epics table, active cycle, active tasks, backlog, and blocked items. Any command that runs in a new session reads this file first, giving the AI assistant sufficient context to continue without re-asking the user for background.

**Context window risk:** On large projects, `Master-Plan.md` can grow large. The `/agtoosa-concise` mode reduces token usage. A future compaction strategy (archiving completed cycles to `Docs/AgToosa_Changelog.md`) keeps the active document small.

---

## Phase Gate Protocol

| Phase transition | Gate condition | Enforcement |
|-----------------|---------------|-------------|
| Backlog → Todo | Spec approved by user | Linear status update in `/agtoosa-spec` |
| Todo → In Progress | Build started | Linear status update in `/agtoosa-build` |
| In Progress → In Review | All tasks ✅, tests passing | `/agtoosa-review` checks Linear task status |
| In Review → Done | Review verdict: Approved | `/agtoosa-ship` requires review ✅ |
| Any → Backlog | `/agtoosa-revert` invoked | Git rollback + Linear status reset |

Gates are **soft** (enforced by AI instruction following) in v3.x. Hard programmatic gates are a v4 consideration tied to Option C (LLM-native orchestrator).

---

## Consequences

**Easier:**
- Partial re-runs: any phase can be re-entered independently
- Platform portability: same workflow runs in all 6 platforms
- Session continuity: `Master-Plan.md` provides cold-start context across sessions
- Debugging: state is human-readable in markdown and Linear

**Harder:**
- Phase-order enforcement is soft — relies on AI following workflow instructions
- Parallelism beyond Review phase requires Claude Code (or future platform API parity)
- Long projects accumulate large `Master-Plan.md` files — need compaction strategy
- No automatic rollback on review failure — user must explicitly run `/agtoosa-revert`

**Will need to revisit:**
- Sub-agent dependency DAG + auto-rollback on gate failure (v4)
- Parallel task distribution within the Build phase (currently sequential)
- Cross-platform parallel agent support (blocked on Cursor/Gemini exposing Agent tool)
- `Master-Plan.md` compaction and archiving strategy for long-running projects

---

## Action Items

1. [x] Ship sequential persona dispatch via slash commands (v3.0.0)
2. [x] Ship parallel 4-reviewer pattern in agtoosa-review skill (v3.0.0)
3. [x] Document the Linear phase-gate protocol formally in `Docs/AgToosa_Governance.md`
4. [x] Add explicit phase-order warning to workflow docs — `> **Prerequisites:**` blockquotes added to `Docs/AgToosa_Build.md`, `Docs/AgToosa_Review.md`, and `Docs/AgToosa_Ship.md` (v3.1.0)
5. [x] Design `Master-Plan.md` compaction — Part 6 "Compact Master-Plan.md" step added to `Docs/AgToosa_Ship.md` with archive-to-`Docs/archived/cycle-YYYY-MM-DD.md` protocol; trigger: >200 lines or cycle close (v3.1.0)
6. [x] Evaluate parallel task distribution in Build phase for Claude Code — "Claude Code Parallel Pattern" subsection added to `Docs/AgToosa_Build.md`; pattern is opt-in for independent Part 1 tasks (v3.1.0)
7. [ ] [planned/v4] Specify sub-agent dependency DAG and auto-rollback interface — see `## Future: Sub-Agent Dependency DAG (v4)` section below

---

## Future: Sub-Agent Dependency DAG (v4)

**Status:** Design stub — not yet implemented. Target: v4.0.0.

### Motivation

The current orchestration model is sequential within each phase and parallel only in the
Review phase. For the Build phase, tasks are executed one-at-a-time even when they are
independent (e.g., writing three separate modules that share no state). A dependency DAG
would allow the orchestrator to fan out independent tasks and collect results, reducing
wall time on large stories.

Additionally, the current phase gate is soft (the AI follows workflow instructions). A
v4 hard gate would automatically roll back if a gate condition is not met — for example,
if smoke tests fail in `/agtoosa-ship`, the orchestrator would invoke `/agtoosa-revert`
without requiring a manual user command.

### Design Sketch

**Per-task dependency declarations:**

Each task in the Build phase breakdown would include an optional `deps` field:

```
Task: Write UserRepository
  deps: [DatabaseSchema]   ← must complete before this task starts
  
Task: Write AuthService
  deps: []                 ← no deps, can run in parallel with UserRepository
```

**Orchestrator DAG resolution:**

The orchestrating agent (Claude Code `Task` tool) resolves the DAG topologically:
1. Launch all tasks with no unmet dependencies in parallel
2. As each task completes, mark its dependents as unblocked
3. Continue until all tasks complete or a task fails
4. On failure: propagate failure to all dependents, collect results, surface to user

**Auto-rollback protocol:**

On gate failure (e.g., smoke tests fail in Part 2 of `/agtoosa-ship`):
1. The orchestrator automatically invokes `/agtoosa-revert` with the last known good commit
2. Linear status is reset to `In Review`
3. A failure report is appended to `Docs/Master-Plan.md` with the failing test and rollback SHA
4. User is notified with a structured summary: what failed, what was rolled back, next steps

**Platform scope:** Claude Code only (requires `Task` tool with parallel sub-agent support).
Other platforms continue with sequential execution and manual rollback.

**Implementation prerequisites:**
- Task dependency format added to `/agtoosa-build scope` output
- `AgToosa_Build.md` updated with DAG orchestration instructions for Claude Code
- `AgToosa_Ship.md` Part 2 updated with auto-rollback trigger condition
- `Docs/AgToosa_Governance.md` updated with v4 gate protocol
