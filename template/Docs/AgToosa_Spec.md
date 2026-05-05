# AgToosa /agtoosa-spec Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-spec` | Full flow: Parts 1 + 2 + 3 |
| `/agtoosa-spec research` | Part 1 only — context, web research, and Q&A; outputs findings, no spec file yet |
| `/agtoosa-spec plan` | Part 2 only — architecture blueprint + threat model against an already-written spec |
| `/agtoosa-spec quick` | Abbreviated — 2–3 targeted questions + spec + skip full threat model (use for small bugs/chores) |
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

## Workflow

### Part 1 — Research & Specification

1.  **Context Gathering & Domain Language Alignment:**
    *   Read `Docs/Context/product.md`, `tech-stack.md`, and `workflow.md` to align with project goals.
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
3.  **Q&A — Forcing Questions (Smart Interview):**

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
4.  **Executable Spec Generation:**
    *   Synthesize all findings into a clean, comprehensive **Executable Specification**.
    *   Specs must act as direct programmatic inputs for the `/agtoosa-build` phase (e.g., BDD syntax, strict preconditions/postconditions, or explicit acceptance criteria).

### Part 2 — Architectural Planning & Threat Modeling

5.  **Constraints Enforcement & Threat Modeling:**
    *   **Proactive Threat Modeling:** Generate Data Flow Diagrams (DFDs) and apply the STRIDE methodology (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) before any code is written.
    *   Embed "Security by Design" into the plan.
    *   Validate that the proposed plan adheres to Object-Oriented Design (OOP) principles (if applicable).
    *   Enforce the rule: No code file shall exceed 500 lines of code. Plan for modularity.
6.  **Architecture Blueprint:**
    *   Outline the architecture, file structure changes, and logic flow.
    *   Identify dependencies and their latest stable versions.
    *   Map out which tasks can be parallelized during `/agtoosa-build`.

### Part 3 — Output

7.  **Acceptance Criteria:**
    *   Before writing the spec file, generate a `## Acceptance Criteria` table using Given/When/Then format:

    ```
    ## Acceptance Criteria

    | ID | Scenario | Given | When | Then | Priority |
    |----|----------|-------|------|------|----------|
    | AC-001 | ... | ... | ... | ... | Must |
    | AC-002 | ... | ... | ... | ... | Should |
    ```

    *   IDs use `AC-NNN` format. Priority: **Must** / **Should** / **Could** (MoSCoW).
    *   Every Must-priority AC must have at least one explicit failure mode from question 5.
    *   This table is required by `/agtoosa-qa plan` and `/agtoosa-ship check`.

8.  **File Generation:**
    *   Generate a single file named `Docs/archived/spec-[story-id].md` (e.g., `Docs/archived/spec-DEV-15.md`).
    *   This file contains the executable spec, architectural plan, AND the acceptance criteria table.
    *   The `Docs/archived/` directory is created automatically by `/agtoosa-init`. If it is missing, create it with `mkdir -p Docs/archived`.
9.  **Master-Plan.md Story Entry:**
    *   Add a Story entry to `Docs/Master-Plan.md`:
        - Title: `Feature: [spec short name]` (use `Bug:` / `Chore:` / `Fix:` as appropriate)
        - Type: Feature (or Bug / Chore / Fix as appropriate)
        - Status: `Todo`
        - Priority: derived from the urgency signal (Q3 answer)
        - Parent Epic: link to the relevant Epic from `/agtoosa-init`
        - Summary: paste the spec's Context section + ACs table + Definition of Done checklist
    *   Record the Story ID in the spec file header.
    *   Update `Docs/Master-Plan.md`: add the Story row to `## Backlog` (or `## Active Cycle` if enrolling now).

10. **Estimation & Cycle Enrollment:**
    *   Ask the user: "How big is this Story? T-shirt size: **XS** (< 4 h) / **S** (1 d) / **M** (2–3 d) / **L** (4–5 d) / **XL** (6+ d)"
    *   If the user picks **L** or **XL**, prompt: "This is large. Should we split it into smaller Stories now, or proceed as one?"
    *   Record the estimate in `Docs/Master-Plan.md` on the Story row.
    *   Ask: "Enroll this Story in the current active cycle/sprint? (Yes / No)"
    *   If Yes: add the Story to the active cycle in Linear and update `Docs/Master-Plan.md` under `## Active Cycle`.

## Output
*   Present the generated Spec (with embedded plan) to the user.
*   Present the approval gate:

    ```
    ✅ Ready to proceed
    Spec [name] generated: [N] ACs, [N] Must-priority, threat model complete.
    → Approve — I'll mark the spec approved and queue /agtoosa-build
    → Comment or request changes below
    ```

*   When the user approves, **append the following section verbatim** to the spec file before running `/agtoosa-build`:

```
## ✅ Spec Approved

Approved: [YYYY-MM-DD HH:MM]
```

This approval marker is required by `/agtoosa-ship check` to verify the spec was signed off before deployment. Do not proceed to `/agtoosa-build` without appending it.

*   **Linear Comment (Spec Approved):** Immediately after appending the approval marker, post a progress comment on the Story issue:

    ```
    Spec ✅ Approved
    Date: [YYYY-MM-DD HH:MM]

    Spec [AgToosa_Spec-[name]-v[N].md] approved. Estimate: [XS/S/M/L/XL]. [Enrolled in cycle / Not yet enrolled].

    Next: /agtoosa-build to break down tasks and start TDD.
    ```

*   Transition the Story issue status from `Todo` to `Todo` (no change yet — status moves to `In Progress` when `/agtoosa-build` starts the first TDD task).
