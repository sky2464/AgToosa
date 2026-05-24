# AgToosa /agtoosa-spec Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-spec` | Full flow: Parts 1 + 2 + 3 + 4 |
| `/agtoosa-spec research` | Part 1 only — context, web research, and Q&A; outputs findings, no spec file yet |
| `/agtoosa-spec plan` | Part 2 only — architecture blueprint + threat model against an already-written spec |
| `/agtoosa-spec quick` | Abbreviated — 2–3 targeted questions + spec + skip full threat model (use for small bugs/chores) |
| `/agtoosa-spec tasks` | Part 4 only — derive atomic tasks from an already-approved spec, generate test plan skeleton, update Master-Plan.md |
| `/agtoosa-spec to-issues` | Break the active spec or PRD into vertical-slice GitHub issues |

## Optional Sub-Commands

### /agtoosa-spec to-issues

Break the active spec (or a provided PRD or plan) into independently-grabbable GitHub issues using vertical slices.

**Vertical slice rule:** Each issue must deliver one complete user-facing behaviour change — never a horizontal slice ("write the tests" or "add the migration" are not valid issues on their own).

1. Read the active `AgToosa_Spec-*.md` file (or the provided description if no spec file exists).
2. Identify all user-facing behaviour changes. For each, create one GitHub issue with:
   - **Title:** `[Area] Short description of user-facing change`
   - **Acceptance criteria:** up to 5 AC items in checkbox format
   - **Story points:** 1 / 2 / 3 / 5 (Fibonacci)
   - **Labels:** feature / bug / chore / spike as appropriate
   - **Dependencies:** list any issues that must complete first
3. If no GitHub remote is configured, write issues to `Docs/issues/` as individual markdown files.
4. Update `Docs/Master-Plan.md` with all issue IDs under `## Active Tasks`.

## Objective
Transform a raw idea, feature, chore, or bug into a researched Specification with an architectural blueprint.

> **Generated Project Mode:** Specs describe work on **the project** or **the product** (`Docs/Master-Plan.md` → `## Project Charter`), not the AgToosa framework. Story entries and tasks belong in **this repository's** `Docs/Master-Plan.md`. See `Docs/AgToosa_Agent.md` → **Operating Contexts**.

## Phase Stop Contract

> See `Docs/AgToosa_Agent.md` → **Phase Stop Contract** for the full rules.

- `/agtoosa-spec` may run through Parts 1–4 (spec, architecture, tasks, test plan) but **must stop** at the approval gate below.
- Do **not** run `/agtoosa-build` automatically after the approval gate — wait for the user to invoke `/agtoosa-build` explicitly.
- Appending `## ✅ Spec Approved` marks readiness only; it does not start build.

## Workflow

### Part 1 — Research & Specification

1.  **Context Gathering & Domain Language Alignment:**
    *   Read `Docs/Context/product.md`, `tech-stack.md`, and `workflow.md` to align with project goals.
    *   Read `Docs/Master-Architecture.md` as the current solution architecture before proposing architecture changes. If it is missing or stale, record that as a context gap and include an update task when architecture is in scope.
    *   Scan the existing codebase to fully understand the impact surface of the proposed work.
    *   **Domain Language Alignment:** Read `Docs/Context/CONTEXT.md` (create it if missing using `Docs/CONTEXT-FORMAT.md` as a guide). For each key concept in the proposed feature:
        - "Is this the right term? What does the domain call this?"
        - "Is this a new concept or an existing one we're renaming?"
        - "Where does this term appear in the codebase today?"
    *   Update `Docs/Context/CONTEXT.md` with any new or corrected terms.
    *   Identify 2–3 architectural decisions implied by the feature; document each as a new ADR in `Docs/adr/` using `Docs/ADR-FORMAT.md`.
2.  **External Research (Web Research Agent):**
    *   Query online sources for the best solutions, libraries, APIs, and design patterns relevant to the task.
    *   **CRITICAL:** Verify all dependency versions against live sources (never assume from memory).
3.  **Story Goal Contract:**

    Before asking forcing questions, verify that the story goal is clear enough to build, review, and ship against.

    *   Read the project Goal Contract in `Docs/Master-Plan.md` `## Project Charter`.
    *   Infer the story goal from the user's request, codebase scan, active specs, backlog, and `Docs/Context/`.
    *   If the goal, user outcome, measurable success condition, proof/evidence, non-goals, assumptions, risks, or unresolved questions are unclear, call the `/agtoosa-goal story` sub-workflow.
    *   Write the final Story Goal Contract into the spec under `## 1. Requirements` before User Stories.
    *   Story goals must be stored in the active spec, not in `Docs/Context/`.

4.  **Q&A — Forcing Questions (Smart Interview):**

    > **Follow the Smart Interview Protocol** (`Docs/AgToosa_Agent.md` → `## Smart Interview Protocol`).
    > Maximum **4 questions** for the full flow; max **2** for `/agtoosa-spec quick`.
    > Before each question, check whether the answer is already clear from the codebase scan or Context files. If it is, state your finding and move on — do not ask.

    The six forcing questions below are the candidate pool. Ask only the ones where the answer is a genuine gap. Present options derived from codebase findings and research. One question at a time; at most one follow-up per answer.

    1. **Status quo** — What is the exact current behavior users depend on? What breaks if we change it?
    2. **Narrowest scope** — What is the smallest version of this feature that still delivers real value?
    3. **Urgency signal** — Who specifically is blocked without this? What workaround are they using today?
    4. **10-star version** — If resources were unlimited, what would the ideal implementation look like?
    5. **Failure modes** — What are the three most likely ways this could break in production?
    6. **Security surface** — Does this touch auth, data storage, external APIs, or user-controlled input?

    Questions 1–4 sharpen scope. Questions 5–6 feed directly into STRIDE threat modelling in Part 2. Always ask question 6 if the feature touches any trust boundary — it is rarely fully inferable.

    For `/agtoosa-spec quick`, ask only questions 1, 2, and 6 (abbreviated).
5.  **Executable Spec Generation:**
    *   Synthesize all findings into a clean, comprehensive **Executable Specification**.
    *   Specs must act as direct programmatic inputs for the `/agtoosa-build` phase (e.g., BDD syntax, strict preconditions/postconditions, or explicit acceptance criteria).

### Part 2 — Architectural Planning & Threat Modeling

6.  **Constraints Enforcement & Threat Modeling:**
    *   **Proactive Threat Modeling:** Generate Data Flow Diagrams (DFDs) and apply the STRIDE methodology (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) before any code is written.
    *   Embed "Security by Design" into the plan.
    *   Validate that the proposed plan adheres to Object-Oriented Design (OOP) principles (if applicable).
    *   Enforce the rule: No code file shall exceed 500 lines of code. Plan for modularity.
7.  **Architecture Blueprint:**
    *   Outline the architecture, file structure changes, and logic flow.
    *   Identify dependencies and their latest stable versions.
    *   Map out which tasks can be parallelized during `/agtoosa-build`.

### Part 3 — Output

8.  **Acceptance Criteria:**
    *   Before writing the spec file, generate a `## 1.2 Acceptance Criteria (EARS)` table using EARS notation:

    ```
    ## 1.2 Acceptance Criteria (EARS)

    | ID | EARS | Priority |
    |----|------|----------|
    | AC-001 | WHEN [condition] THE SYSTEM SHALL [behavior] | Must |
    | AC-002 | WHILE [state] WHEN [event] THE SYSTEM SHALL [behavior] | Should |
    | AC-003 | IF [optional feature] THEN WHEN [event] THE SYSTEM SHALL [behavior] | Could |
    ```

    *   IDs use `AC-NNN` format. Priority: **Must** / **Should** / **Could** (MoSCoW).
    *   Every Must-priority AC must have at least one explicit failure mode from question 5.
    *   This table is required by `/agtoosa-qa plan` and `/agtoosa-ship check`.

9.  **File Generation:**
    *   Generate a single file named `Docs/archived/spec-[story-id].md` (e.g., `Docs/archived/spec-DEV-15.md`).
    *   The file must follow the section order defined in `Docs/SPEC-FORMAT.md`:
        - `## 1. Requirements` (Goal Contract, User Stories, EARS ACs, Out of Scope)
        - `## 2. Design` (Architecture Blueprint, Data Flow, STRIDE Threat Model, Build Scope)
        - `## 3. Tasks` (Task Tree, Wave Plan, Test Plan — populated in Part 4)
        - `## ✅ Spec Approved` (appended on approval)
    *   Refer to `Docs/SPEC-FORMAT.md` for the full format reference.
    *   The `Docs/archived/` directory is created automatically by `/agtoosa-init`. If it is missing, create it with `mkdir -p Docs/archived`.
10. **Master-Plan.md Story Entry:**
    *   Add a Story entry to `Docs/Master-Plan.md`:
        - Title: `Feature: [spec short name]` (use `Bug:` / `Chore:` / `Fix:` as appropriate)
        - Type: Feature (or Bug / Chore / Fix as appropriate)
        - Status: `Todo`
        - Priority: derived from the urgency signal (Q3 answer)
        - Parent Epic: link to the relevant Epic from `/agtoosa-init`
        - Summary: paste the spec's Goal Contract + ACs table + Definition of Done checklist
    *   Record the Story ID in the spec file header.
    *   Update `Docs/Master-Plan.md`: add the Story row to `## Backlog` (or `## Active Cycle` if enrolling now).

11. **Estimation & Cycle Enrollment:**
    *   Ask the user: "How big is this Story? T-shirt size: **XS** (< 4 h) / **S** (1 d) / **M** (2–3 d) / **L** (4–5 d) / **XL** (6+ d)"
    *   If the user picks **L** or **XL**, prompt: "This is large. Should we split it into smaller Stories now, or proceed as one?"
    *   Record the estimate in `Docs/Master-Plan.md` on the Story row.
    *   Ask: "Enroll this Story in the current active cycle/sprint? (Yes / No)"
    *   If Yes: add the Story to `Docs/Master-Plan.md` under `## Active Cycle` and record enrollment in the **Update Log**.

### Part 4 — Task Planning

> **Skip this part** if running `/agtoosa-spec research` or `/agtoosa-spec plan`. Run this part standalone with `/agtoosa-spec tasks` against an already-approved spec.

12. **Scope Boundary Declaration:**

    Derive the scope boundary from the spec. Present it as a pre-filled summary — do not ask the user to define scope from scratch:

    ```
    ✅ Ready to proceed — Scope Boundary
    Files in scope      : [list specific files from the spec]
    Directories in scope: [list directories]
    Out of scope        : [list anything that must NOT be touched]
    ```

    Save the scope declaration under a `## Build Scope` heading at the top of the active `AgToosa_Spec-*.md`.

13. **Atomic Task Breakdown:**
    *   Read the spec and translate it into atomic, clear, step-by-step actionable tasks.
    *   Identify tasks that can run in parallel during `/agtoosa-build`.
    *   If a critical flaw is found during task breakdown, stop and ask the user to revise the spec before continuing.
    *   Emit a **hierarchical checkbox tree** in `## Active Tasks` in `Docs/Master-Plan.md` (follow the format in `Docs/SPEC-FORMAT.md` § 3.1):
        - Top-level items: `- [ ] **N.** [Group]: [description]`
        - Sub-tasks: `  - [ ] N.M [description] — _Requirements: AC-NNN_`
    *   After generating the task tree, identify groups of sub-tasks that can run in parallel (no shared state, no data dependency). Add a `### Wave Plan` subsection in the spec's `## 3. Tasks` section using:

        ```
        **Wave 1 (parallel):** [list sub-task IDs]
        **Wave 2 (sequential after Wave 1):** [list sub-task IDs]
        ```

    *   Mirror the task tree into `Docs/Master-Plan.md` under `## Active Tasks` (replacing the flat table format).

14. **Test Plan Skeleton:**
    *   Generate **`Docs/AgToosa_TestPlan-[name].md`** containing:
        - Spec reference (link to `AgToosa_Spec-*.md`)
        - AC coverage table — each `AC-NNN` from the spec mapped to test IDs (`T-001`, `T-002`, ...)
        - Test category per ID: Unit · Integration · E2E · Security · Performance
        - Coverage target from `Docs/Context/workflow.md` (`coverage_threshold`), default 80%
        - At least one negative/edge scenario per Must-priority AC
        - Smoke set — at least one test per Must-priority AC tagged `@smoke`

15. **Story Skill Opportunity Synthesis (Codex / OpenCode):**

    After the test plan skeleton exists, derive story-specific skill candidates from the Goal Contract, acceptance criteria, architecture blueprint, and test plan.

    *   Propose skills only when they clearly support repeated implementation, review, QA, or release evidence for **this story** (not one-off chat instructions).
    *   Check for **duplicate** triggers against existing AgToosa workflow skills, platform adapters, and project skills under `.codex/skills/`. Prefer **Update existing** or **Do not generate** over creating a near-duplicate.
    *   **Reserved workflow names:** reject candidates named `agtoosa-*`, triggered by `/agtoosa-*`, or that would shadow `.cursor/commands/agtoosa-*.md`, `.windsurf/workflows/agtoosa-*.md`, `.gemini/commands/agtoosa-*.toml`, `.github/prompts/agtoosa-*.prompt.md`, `.codex/prompts/agtoosa-*.md`, or `.codex/skills/agtoosa-*` unless updating an installed AgToosa workflow adapter — those names are reserved for AgToosa lifecycle commands, not generated project skills.
    *   Reject candidates without validation (command, checklist, or artifact review).
    *   **Secret safety:** exclude secret values from generated skills; reference file paths and process steps only. Add a safety note when credentials or tokens are relevant.
    *   Present the same candidate table shape as `/agtoosa-init` Project Skill Discovery (Skill name, Trigger description, Purpose, Inputs, Optional resources, Validation, Decision).
    *   Require **explicit user approval** before writing any `.codex/skills/<skill-name>/SKILL.md` file.
    *   Record accepted and declined decisions in the active spec file or `Docs/Master-Plan.md` **Update Log**.

## Output
*   Present the generated Spec (with Goal Contract and embedded plan), task list, and test plan skeleton to the user.
*   Print the closure line verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
*   Present the approval gate:

    ```
    ✅ Ready to proceed
    Spec [name] generated: Goal Contract clear, [N] ACs, [N] Must-priority, threat model complete.
    [N] atomic tasks derived. Test plan skeleton: [N] test IDs mapped to [N] ACs.
    → Approve — I'll mark the spec approved; run /agtoosa-build when you are ready
    → Comment or request changes below
    ```

*   **Stop here** after presenting the approval gate. Do not invoke `/agtoosa-build` until the user explicitly runs it.

*   When the user approves, **append the following section verbatim** to the spec file:

```
## ✅ Spec Approved

Approved: [YYYY-MM-DD HH:MM]
```

This approval marker is required by `/agtoosa-ship check` to verify the spec was signed off before deployment. Do not proceed to `/agtoosa-build` without appending it.

*   **Master-Plan Update Log:** Immediately after appending the approval marker, add a timestamped entry to `Docs/Master-Plan.md` `## Update Log`:

    `YYYY-MM-DD HH:MM — /agtoosa-spec — Spec ✅ Approved — [Story ID] — [spec filename]; estimate [XS/S/M/L/XL]; [enrolled in cycle / backlog only].`

    Keep the Active Cycle row at `Todo` until `/agtoosa-build` starts the first TDD task (then status → `In Progress` per `Docs/AgToosa_Governance.md`).
