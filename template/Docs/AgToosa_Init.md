# AgToosa /agtoosa-init Workflow

## Objective
One-time initialization that establishes project context, scans the codebase, validates AI assistant configs, and configures AgToosa for your development workflow. This combines setup and initialization into a single command.

> **Run once when first setting up AgToosa. Re-run only if a major architectural shift is needed.**

## Workflow

### Phase A — AI Assistant Config Validation

1.  **Detect AI Assistant Configs:**
    *   Scan the project root for existing AI assistant configuration files:
        *   `.cursorrules` (Cursor)
        *   `.windsurfrules` (Windsurf)
        *   `CLAUDE.md` (Claude Code)
        *   `AGENTS.md` (Gemini CLI / Jules)
        *   `.github/copilot-instructions.md` (GitHub Copilot)
        *   `.roo/` or `roo.md` (Roo)
        *   `.opencode/` (OpenCode)
        *   Any other memory, instructions, or rules files
    *   Check if each detected config file correctly references AgToosa's `Docs/AgToosa_Agent.md` and the `/agtoosa-*` commands.
    *   If a config file exists but is NOT wired to AgToosa, ask the user if they want to update it or leave it untouched.
    *   If a config file is MISSING for the AI tool the user selected during installation, create it with proper AgToosa references.

2.  **Platform-Specific Init Detection:**
    *   Understand that different AI platforms may have their own initialization mechanisms:
        *   Cursor → uses `.cursorrules` (auto-loaded)
        *   Claude Code → uses `CLAUDE.md` (auto-loaded) + may have `/init` custom command
        *   Gemini CLI → uses `AGENTS.md` (auto-loaded)
        *   Windsurf → uses `.windsurfrules` (auto-loaded)
        *   Copilot → uses `.github/copilot-instructions.md` (auto-loaded)
    *   If the AI platform supports a native `/init` or initialization command, explain to the user how AgToosa's `/agtoosa-init` integrates with or replaces it.

### Phase B — Context Establishment

3.  **Context Generation:**
    *   Ask the user about the core product, target audience, technical preferences, and workflow rules.
    *   Initialize the following core context files in `/Docs/Context/`:
        *   `product.md`: Defines project context, users, product goals, and high-level features.
        *   `product-guidelines.md`: Defines prose style, brand messaging, visual identity, and UX standards.
        *   `tech-stack.md`: Configures technical preferences (language, database, frameworks, deployment strategy).
        *   `workflow.md`: Sets team preferences (e.g., TDD enforcement, commit strategy, branch naming conventions, linting rules).
4.  **Validation:**
    *   Verify that these files exist and are populated.
    *   All subsequent `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, and `/agtoosa-ship` commands MUST read these files.

### Phase C — Codebase Onboarding

5.  **Codebase Scan:**
    *   Thoroughly scan the target codebase to understand the project structure, technology stack, dependencies, and architecture.
6.  **AI Doctor Consultation:**
    *   Ask the user a series of smart, sequential clarifying questions (like an Agentic AI doctor) to understand the app's full picture, core business logic, and overall Epics.
    *   Do not ask all questions at once; wait for answers and adapt.
7.  **Scaffolding:**
    *   If the `/Docs` directory does not exist, create it.
    *   If `Docs/archived/` does not exist, create it.
8.  **Dynamic Generation:**
    *   Based on the consultation and codebase scan, dynamically generate or update the core agent config files tailored to the specific project:
        *   `Docs/AgToosa_Agent.md` (Core instructions, rules, and commands)
        *   `Docs/AgToosa_Claude.md` (Claude-specific instructions, if applicable)
        *   `Docs/AgToosa_Gemini.md` (Gemini-specific instructions, if applicable)
9.  **Project Management Setup:**
    *   Initialize `Docs/Master-Plan.md` with the identified Epics and an empty state for Specs and Tasks.
    *   Initialize `Docs/AgToosa_Changelog.md`.

### Phase D — TDD Configuration

10. **TDD Preference:**
    *   Ask the user if they want to enforce Test-Driven Development (TDD) in their workflow.
    *   If yes, set `tdd: true` in `Docs/Context/workflow.md`.
    *   Explain the Red-Green-Refactor cycle that `/agtoosa-build` will enforce.
11. **Test Framework Detection:**
    *   Auto-detect the test framework in use (Vitest, Jest, pytest, Go test, RSpec, etc.).
    *   Record the detected framework in `Docs/Context/tech-stack.md`.

## Output
*   Confirm initialization is complete.
*   Present the updated `Master-Plan.md`.
*   Confirm all AI assistant config files are correctly wired to AgToosa.
*   Explain: "From now on, use only **4 commands**: `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, `/agtoosa-ship`."
*   Ask the user if they are ready to run `/agtoosa-spec` for their first task.
