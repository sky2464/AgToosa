# AgToosa /agtoosa-init Workflow

> **Run once when setting up AgToosa. Re-run only for major architectural shifts.**

## Objective
One-time initialization: establish project context, scan the codebase, validate AI configs, and configure the AgToosa workflow.

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-init` | Full initialization workflow (run once) |
| `/agtoosa-init zoom-out` | Codebase zoom-out: broader context when agent is zoomed in on a specific file or function |

### /agtoosa-init zoom-out

Use when the AI agent is focused on a specific file or function and needs broader context to make a good decision.

1. **Call graph:** Show what calls this function/module and what it calls in turn.
2. **Module boundaries:** Identify which architectural layer owns this code (UI / API / domain / data).
3. **Usage sites:** Find all references to this symbol or module across the codebase.
4. **Impact analysis:** Answer: "What would break if this changed?"
5. **Context update:** Update `Docs/Master-Plan.md` with the codebase mental model if any new understanding emerged.

## Workflow

### Phase A — AI Config Validation

1.  **Detect AI Configs:**
    *   Scan the project root for AI config files: `.cursorrules`, `.windsurfrules`, `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `OPENCODE.md`, and any other rules/memory files.
    *   Scan `.github/instructions/` for `*.instructions.md` scoped instruction files.
    *   Check each config correctly references `Docs/AgToosa_Agent.md` and the `/agtoosa-*` commands.
    *   If a config exists but is NOT wired to AgToosa, ask the user whether to update it.
    *   If a config for the selected AI tool is missing, create it with proper AgToosa references.
    *   If `.github/instructions/` is missing, create it and scaffold baseline files: `agtoosa-core.instructions.md`, `agtoosa-testing.instructions.md`, `agtoosa-security.instructions.md`, and `agtoosa-changelog.instructions.md`.

2.  **Platform Notes:**
    *   All supported platforms auto-load their config (`.cursorrules`, `CLAUDE.md`, `AGENTS.md`, etc.).
    *   If the platform has a native `/init` command, explain how `/agtoosa-init` integrates with it.

### Phase B — Context Establishment

3.  **Context Files:**
    Ask the user about product, tech preferences, and workflow rules. Create these in `Docs/Context/`:
    *   `product.md` — project context, users, goals, high-level features
    *   `product-guidelines.md` — prose style, brand, UX standards
    *   `tech-stack.md` — language, database, frameworks, deployment
    *   `workflow.md` — TDD enforcement, commit strategy, branch naming, linting

4.  **Validation:** Verify all context files exist and are populated before proceeding.

### Phase C — Codebase Onboarding

5.  **Codebase Scan:** Scan the project for structure, stack, dependencies, and architecture.

6.  **AI Doctor Consultation:** Ask sequential clarifying questions to understand the app's core logic and Epics. Wait for each answer before asking the next.

7.  **Scaffolding:** Create `Docs/`, `Docs/archived/`, and `Docs/Context/` if they don't exist.

8.  **Dynamic Generation:** Based on the consultation, update or create:
    *   `Docs/AgToosa_Agent.md` (tailored rules and commands)
    *   `Docs/AgToosa_Claude.md` (Claude-specific, if applicable)
    *   `Docs/AgToosa_Gemini.md` (Gemini-specific, if applicable)

9.  **Project Management Setup:**
    *   For each Epic identified in Phase B, create a Linear **Epic issue**:
        - Title: `Epic: [product area name]` (e.g., `Epic: Authentication`)
        - Label: Feature
        - Status: `Backlog`
        - Description: one-paragraph charter — goal, scope, and success criteria for this product area
    *   Record all Epic IDs (e.g., `DEV-12`) in `Docs/Master-Plan.md` under `## Epics`.
    *   Mirror the full current state in `Docs/Master-Plan.md` using the structured template (Charter, Epics table, empty Backlog, Update Log first entry).
    *   Initialize `Docs/AgToosa_Changelog.md`.

### Phase D — TDD Configuration

10. **TDD Preference:** Ask whether to enforce TDD. If yes, set `tdd: true` in `workflow.md` and explain Red-Green-Refactor.

11. **Test Framework:** Auto-detect the test framework (Vitest, Jest, pytest, etc.) and record it in `tech-stack.md`.

## Output
*   Confirm initialization complete; present the Linear record and `Master-Plan.md`.
*   Confirm all AI configs are wired to AgToosa.
*   Tell the user: "Use **4 commands**: `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, `/agtoosa-ship`."
*   Ask if they're ready to run `/agtoosa-spec`.
