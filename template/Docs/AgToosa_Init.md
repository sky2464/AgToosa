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

> **Follow the Smart Interview Protocol** (`Docs/AgToosa_Agent.md` → `## Smart Interview Protocol`).
> Maximum 6 questions across all context files combined. Infer first; only ask about genuine gaps.

3.  **Populate-Check Gate:**

    Before asking anything, check whether `Docs/Context/` files already exist and are populated:

    - **Fully populated** (all key fields have real non-placeholder values):
      Present a summary of each file's content and ask:
      > "Your context files are already filled in. Review below — confirm to proceed, or call out anything to update."

    - **Partially populated** (some fields are `""` or placeholder stubs):
      Present the filled fields, skip asking about them, and run the interview only for the gaps.

    - **Empty or missing** (files missing, or all fields are `""` / placeholder):
      Run the full discovery interview below.

    **Greenfield / empty-repo branch:** If no source files, no `README.md`, and no package manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.) are detected → skip Phase C (codebase scan) entirely. Note: "We'll profile the codebase as you build." Run the full discovery interview, then jump directly to Phase D.

4.  **Discovery Interview (Smart Interview):**

    Conduct the interview one question at a time. Before each question, scan the codebase and any existing context for clues — pre-populate options from what you find. Do not ask questions whose answers are already clear from codebase evidence.

    **Product context** (`Docs/Context/product.md`):

    ```
    ❓ What type of app is this?
      → A) [type inferred from codebase structure, e.g., "Web SaaS (Next.js + API)"] ← recommended
      → B) Mobile App
      → C) CLI Tool / API Service
      Or describe it yourself.
    ```

    Wait for the answer, then ask (if still unclear):

    ```
    ❓ Who is the primary user and what is the single most important problem this solves?
      Or type your own answer.
    ```

    **Tech stack** (`Docs/Context/tech-stack.md`):

    ```
    ❓ Confirm the tech stack — does this look right?
      → [Language, framework, DB, deployment target — inferred from package manifests and config files]
      → Correct it below if anything is wrong.
    ```

    Only ask about deployment target separately if it cannot be inferred.

    **Workflow** (`Docs/Context/workflow.md`):

    ```
    ❓ Should we enforce strict TDD (Red-Green-Refactor) during /agtoosa-build?
      → A) Yes — enforce TDD ← recommended for new features
      → B) No — write tests but don't enforce ordering
    ```

    Only ask about commit strategy or branch naming if the project has no existing conventions detectable in git config or CI files.

    **Product guidelines** (`Docs/Context/product-guidelines.md`):

    Infer from any existing UI, README tone, or brand assets. Only ask if nothing is detectable:

    ```
    ❓ Any specific brand, UX, or prose style guidelines to record?
      → A) Skip for now — fill in later
      → B) Type them here
    ```

    After each answer, write or update the relevant context file immediately. Ask at most one follow-up per answer.

5.  **Phase B → Phase C Gate:**

    > **STOP — Do NOT proceed to Phase C until all Context files are confirmed by the user.**

    Present the approval gate (see `## Smart Interview Protocol` → Approval Gate Format):

    ```
    ✅ Ready to proceed
    Context established: product type, users, core problem, tech stack, and workflow preferences captured.
    → Approve to continue to codebase scan  |  Comment or make changes below
    ```

    Wait for explicit approval before proceeding.

### Phase C — Codebase Onboarding

6.  **Codebase Scan:** Scan the project for structure, stack, dependencies, and architecture. Use findings to pre-populate Phase D Epics — do not ask about things the codebase already reveals.

7.  **AI Doctor Consultation (Smart Interview):** Ask clarifying questions to understand the app's core logic and product areas. Follow the Smart Interview Protocol:
    - Ask **one question at a time**. Wait for each answer before asking the next.
    - Infer Epic candidates from the codebase (e.g., Auth, Billing, API, Dashboard). Present them as options — do not ask the user to name Epics from scratch.
    - At most one follow-up per answer. Stop when product areas are clear.

    ```
    ❓ These look like the main product areas from the codebase — does this list look right?
      → A) [Inferred Epic 1]
      → B) [Inferred Epic 2]
      → C) [Inferred Epic 3]
      Add, remove, or rename any below.
    ```

8.  **Scaffolding:** Create `Docs/`, `Docs/archived/`, and `Docs/Context/` if they don't exist.

9.  **Dynamic Generation:** Based on the consultation, update or create:
    *   `Docs/AgToosa_Agent.md` (tailored rules and commands)
    *   `Docs/AgToosa_Claude.md` (Claude-specific, if applicable)
    *   `Docs/AgToosa_Gemini.md` (Gemini-specific, if applicable)

10. **Project Management Setup:**

    > `Docs/Master-Plan.md` is the single source of truth for all project management — it replaces Linear, Jira, GitHub Projects, Trello, or any external tracker. Do NOT create issues in external tools unless the user explicitly asks.

    *   For each Epic confirmed in the consultation, add an entry to `Docs/Master-Plan.md` under `## Epics`:
        - **Name:** `Epic: [product area name]` (e.g., `Epic: Authentication`)
        - **Status:** `Backlog`
        - **Charter:** one-paragraph goal, scope, and success criteria for this product area
    *   Mirror the full current state in `Docs/Master-Plan.md` using the structured template (Charter, Epics table, empty Backlog, Update Log first entry).
    *   Initialize `Docs/AgToosa_Changelog.md`.

### Phase D — TDD Configuration

11. **Test Framework:** Auto-detect the test framework (Vitest, Jest, pytest, etc.) from package manifests and config files. Record it in `tech-stack.md`. Only ask if auto-detection is ambiguous.

> **Note:** TDD preference was captured in Phase B (Step 4). If `tdd: true` is already set in `workflow.md`, skip this step.

## Output

Present the approval gate:

```
✅ Initialization complete
[2–3 sentence summary: what was scanned, what context was set, which Epics were created.]
AI configs confirmed. Use 4 commands: /agtoosa-spec → /agtoosa-build → /agtoosa-review → /agtoosa-ship.
→ Approve and run /agtoosa-spec when ready  |  Comment or adjust below
```

Then print the closure line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
