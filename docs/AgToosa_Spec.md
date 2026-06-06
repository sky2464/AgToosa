# AgToosa /agtoosa-spec Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-spec` | Full flow: Parts 1 + 2 + 3 + 4 |
| `/agtoosa-spec research` | Part 1 only — context, web research, and Q&A; outputs findings, no spec file yet |
| `/agtoosa-spec plan` | Part 2 only — architecture blueprint + threat model against an already-written spec |
| `/agtoosa-spec quick` | Abbreviated — max **2** targeted questions + spec + skip full threat model (use for small bugs/chores) |
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
3. If no GitHub remote is configured, write issues to `docs/issues/` as individual markdown files.
4. Update `docs/Master-Plan.md` with all issue IDs under `## Active Tasks`.

## Objective
Transform a raw idea, feature, chore, or bug into a researched Specification with an architectural blueprint.

> **Generated Project Mode:** Specs describe work on **the project** or **the product** (`docs/Master-Plan.md` → `## Project Charter`), not the AgToosa framework. Story entries and tasks belong in **this repository's** `docs/Master-Plan.md`. See `docs/AgToosa_Agent.md` → **Operating Contexts**.

## Phase Stop Contract

> See `docs/AgToosa_Agent.md` → **Phase Stop Contract** for the full rules.

- `/agtoosa-spec` may run through Parts 1–4 (spec, architecture, tasks, test plan) but **must stop** at the approval gate below.
- Do **not** run `/agtoosa-build` automatically after the approval gate — wait for the user to invoke `/agtoosa-build` explicitly.
- Appending `## ✅ Spec Approved` marks readiness only; it does not start build.

## Plan-Mode Spec Interview Contract

> Applies to full `/agtoosa-spec` (not `research`, `plan`, or `tasks` alone). `/agtoosa-spec quick` uses the same principles with a **2-question** cap.

Before writing or finalizing the spec file, run a **Plan-Mode Spec Interview**:

1. **Research first** — Read `docs/Context/`, `docs/Master-Plan.md`, active `docs/archived/spec-*.md`, `docs/Master-Architecture.md`, and scan the codebase; use external research when platform or dependency behavior matters.
2. **Gap list** — Compare findings against the **Decision-complete checklist** below. Ask only about genuine gaps.
3. **Infer, don't re-ask** — If an answer is inferable with high confidence (≥80%), state it as a **finding** and do not ask that question.
4. **One question at a time** — Wait for each answer before the next question.
5. **Contextual options** — Derive 2–3 concrete options from repo/research when possible; mark one **recommended** default; always allow free-text override (see **Question Format** in `docs/AgToosa_Agent.md` → Smart Interview Protocol).
6. **Adaptive sequencing** — Let each answer shape the next question; use the six forcing questions (Part 1 step 4) as a **candidate pool**, not a mandatory script.
7. **Adaptive cap** — Full flow: at most **8 core interview questions**. `/agtoosa-spec quick`: at most **2** questions.
8. **Budget exhaustion** — If decision-complete clarity is still missing after 8 core questions, stop and ask:

    ```
    ❓ Interview budget reached (8 questions). How should we proceed?
      → A) Continue the interview (up to 4 more questions) ← only if critical gaps remain
      → B) Proceed with documented assumptions in the spec ← recommended when momentum matters
      Or type your own answer.
    ```

9. **Write gate** — Do **not** generate the final spec file until the Decision-complete checklist is satisfied **or** the user explicitly accepts documented assumptions under `### 1.1 Goal Contract` → Assumptions / Unresolved questions.

### Decision-complete checklist

Before spec generation, confirm coverage (as findings or interview answers) for:

| Area | Must capture |
|------|----------------|
| Goal Contract | Goal, user outcome, success condition, proof/evidence |
| Non-goals | What is explicitly out of scope |
| Acceptance criteria | EARS table with Must-priority ACs |
| Scope boundary | Files/directories in and out of scope |
| Affected surfaces | Generator, template, docs, tests, platforms, etc. |
| Risk / failure modes | Top production failure modes for Must ACs |
| Security / trust boundaries | Auth, data, external APIs, user input, secrets |
| Test evidence | How ACs will be verified (bats, manual, etc.) |
| Rollout / compatibility | Upgrade path, breaking changes, parity surfaces |
| Unresolved assumptions | Anything still assumed; user acceptance when required |

## Workflow

### Part 1 — Research & Specification

1.  **Context Gathering & Domain Language Alignment:**
    *   Read `docs/Context/product.md`, `tech-stack.md`, and `workflow.md` to align with project goals.
    *   Read `docs/Master-Architecture.md` as the current solution architecture before proposing architecture changes. If it is missing or stale, record that as a context gap and include an update task when architecture is in scope.
    *   Scan the existing codebase to fully understand the impact surface of the proposed work.
    *   **Domain Language Alignment:** Read `docs/Context/CONTEXT.md` (create it if missing using `docs/CONTEXT-FORMAT.md` as a guide). For each key concept in the proposed feature:
        - "Is this the right term? What does the domain call this?"
        - "Is this a new concept or an existing one we're renaming?"
        - "Where does this term appear in the codebase today?"
    *   Update `docs/Context/CONTEXT.md` with any new or corrected terms.
    *   Identify 2–3 architectural decisions implied by the feature; document each as a new ADR in `docs/adr/` using `docs/ADR-FORMAT.md`.
1a. **Spec Specialist Orchestration:**

    > Canonical contract: `docs/AgToosa_Specialists.md`. Run after context scan, before external research when a roster exists or specialists were approved during init.

    *   If `docs/Context/specialists.md` is missing, skip this step (record "no approved specialists").
    *   Load the roster; select specialists where `phase_hooks` includes **`spec`** and **trigger** matches the active story (title, paths, epic, or user-stated scope).
    *   For each selected specialist, run a lane that reads declared **inputs** and returns the **structured evidence block** (findings, files read, commands, warnings/errors, recommendations, spec sections affected).
    *   **Parallel:** when the host supports native subagent delegation (e.g. Claude Code Agent tool), run matching lanes in parallel.
    *   **Sequential fallback:** otherwise run the same lanes one at a time and print an explicit note: `Specialist lanes ran sequentially (platform does not support parallel subagents).`
    *   **Merge** evidence into draft Goal Contract, ACs, architecture notes, STRIDE inputs, task tree hints, and test plan skeleton **before** finalizing Part 1 executable spec and Part 2 threat model.
    *   Do not run specialists that fail trigger match or lack approval in the roster.
2.  **External Research (Web Research Agent):**
    *   Query online sources for the best solutions, libraries, APIs, and design patterns relevant to the task.
    *   **CRITICAL:** Verify all dependency versions against live sources (never assume from memory).
3.  **Story Goal Contract:**

    Before asking forcing questions, verify that the story goal is clear enough to build, review, and ship against.

    *   Read the project Goal Contract in `docs/Master-Plan.md` `## Project Charter`.
    *   Infer the story goal from the user's request, codebase scan, active specs, backlog, and `docs/Context/`.
    *   If the goal, user outcome, measurable success condition, proof/evidence, non-goals, assumptions, risks, or unresolved questions are unclear, call the `/agtoosa-goal story` sub-workflow.
    *   Write the final Story Goal Contract into the spec under `## 1. Requirements` before User Stories.
    *   Story goals must be stored in the active spec, not in `docs/Context/`.

4.  **Q&A — Plan-Mode Spec Interview (Smart Interview):**

    > **Follow the Plan-Mode Spec Interview Contract** (above) and the **Smart Interview Protocol** (`docs/AgToosa_Agent.md` → `## Smart Interview Protocol`).
    > Full flow: adaptive cap **8** core questions; `/agtoosa-spec quick`: cap **2**.
    > Before each question, check whether the answer is already clear from research or Context files. If it is, state your finding and move on — do not ask.

    The six forcing questions below are the **candidate pool**. Ask only where the Decision-complete checklist still has a genuine gap. Present options derived from codebase findings and research. One question at a time; at most one follow-up per answer.

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
    *   Generate a single file named `docs/archived/spec-[story-id].md` (e.g., `docs/archived/spec-DEV-15.md`).
    *   The file must follow the section order defined in `docs/SPEC-FORMAT.md`:
        - `## 1. Requirements` (Goal Contract, User Stories, EARS ACs, Out of Scope)
        - `## 2. Design` (Architecture Blueprint, Data Flow, STRIDE Threat Model, Build Scope)
        - `## 3. Tasks` (Task Tree, Wave Plan, Test Plan — populated in Part 4)
        - `## ✅ Spec Approved` (appended on approval)
    *   Refer to `docs/SPEC-FORMAT.md` for the full format reference.
    *   The `docs/archived/` directory is created automatically by `/agtoosa-init`. If it is missing, create it with `mkdir -p docs/archived`.
10. **Master-Plan.md Story Entry:**
    *   Add a Story entry to `docs/Master-Plan.md`:
        - Title: `Feature: [spec short name]` (use `Bug:` / `Chore:` / `Fix:` as appropriate)
        - Type: Feature (or Bug / Chore / Fix as appropriate)
        - Status: `Todo`
        - Priority: derived from the urgency signal (Q3 answer)
        - Parent Epic: link to the relevant Epic from `/agtoosa-init`
        - Summary: paste the spec's Goal Contract + ACs table + Definition of Done checklist
    *   Record the Story ID in the spec file header.
    *   Update `docs/Master-Plan.md`: add the Story row to `## Backlog` (or `## Active Cycle` if enrolling now).

11. **Estimation & Cycle Enrollment:**
    *   Ask the user: "How big is this Story? T-shirt size: **XS** (< 4 h) / **S** (1 d) / **M** (2–3 d) / **L** (4–5 d) / **XL** (6+ d)"
    *   If the user picks **L** or **XL**, prompt: "This is large. Should we split it into smaller Stories now, or proceed as one?"
    *   Record the estimate in `docs/Master-Plan.md` on the Story row.
    *   Ask: "Enroll this Story in the current active cycle/sprint? (Yes / No)"
    *   If Yes: add the Story to `docs/Master-Plan.md` under `## Active Cycle` and record enrollment in the **Update Log**.

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
    *   Emit a **hierarchical checkbox tree** in `## Active Tasks` in `docs/Master-Plan.md` (follow the format in `docs/SPEC-FORMAT.md` § 3.1):
        - Top-level items: `- [ ] **N.** [Group]: [description]`
        - Sub-tasks: `  - [ ] N.M [description] — _Requirements: AC-NNN_`
    *   After generating the task tree, identify groups of sub-tasks that can run in parallel (no shared state, no data dependency). Add a `### Wave Plan` subsection in the spec's `## 3. Tasks` section using:

        ```
        **Wave 1 (parallel):** [list sub-task IDs]
        **Wave 2 (sequential after Wave 1):** [list sub-task IDs]
        ```

    *   Mirror the task tree into `docs/Master-Plan.md` under `## Active Tasks` (replacing the flat table format).

14. **Test Plan Skeleton:**
    *   Generate **`docs/AgToosa_TestPlan-[name].md`** containing:
        - Spec reference (link to `AgToosa_Spec-*.md`)
        - AC coverage table — each `AC-NNN` from the spec mapped to test IDs (`T-001`, `T-002`, ...)
        - Test category per ID: Unit · Integration · E2E · Security · Performance
        - Coverage target from `docs/Context/workflow.md` (`coverage_threshold`), default 80%
        - At least one negative/edge scenario per Must-priority AC
        - Smoke set — at least one test per Must-priority AC tagged `@smoke`

15. **Story Skill Opportunity Synthesis (Codex / OpenCode):**

    After the test plan skeleton exists, derive story-specific skill candidates from the Goal Contract, acceptance criteria, architecture blueprint, and test plan.

    *   Propose skills only when they clearly support repeated implementation, review, QA, or release evidence for **this story** (not one-off chat instructions).
    *   Check for **duplicate** triggers against existing AgToosa workflow skills, platform adapters, and project skills under `.codex/skills/`. Prefer **Update existing** or **Do not generate** over creating a near-duplicate.
    *   **Reserved workflow names:** reject candidates named `agtoosa-*`, triggered by `/agtoosa-*`, or that would shadow `.claude/commands/agtoosa-*.md`, `.cursor/commands/agtoosa-*.md`, `.windsurf/workflows/agtoosa-*.md`, `.gemini/commands/agtoosa-*.toml`, `.github/prompts/agtoosa-*.prompt.md`, `.codex/prompts/agtoosa-*.md`, or `.codex/skills/agtoosa-*` unless updating an installed AgToosa workflow adapter — those names are reserved for AgToosa lifecycle commands, not generated project skills.
    *   Reject candidates without validation (command, checklist, or artifact review).
    *   **Secret safety:** exclude secret values from generated skills; reference file paths and process steps only. Add a safety note when credentials or tokens are relevant.
    *   Present the same candidate table shape as `/agtoosa-init` Project Skill Discovery (Skill name, Trigger description, Purpose, Inputs, Optional resources, Validation, Decision).
    *   Require **explicit user approval** before writing any `.codex/skills/<skill-name>/SKILL.md` file.
    *   Record accepted and declined decisions in the active spec file or `docs/Master-Plan.md` **Update Log**.

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

*   **Master-Plan Update Log:** Immediately after appending the approval marker, add a timestamped entry to `docs/Master-Plan.md` `## Update Log`:

    `YYYY-MM-DD HH:MM — /agtoosa-spec — Spec ✅ Approved — [Story ID] — [spec filename]; estimate [XS/S/M/L/XL]; [enrolled in cycle / backlog only].`

    Keep the Active Cycle row at `Todo` until `/agtoosa-build` starts the first TDD task (then status → `In Progress` per `docs/AgToosa_Governance.md`).
