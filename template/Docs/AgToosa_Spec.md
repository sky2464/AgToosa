# AgToosa /agtoosa-spec Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-spec` | Full flow: Parts 1 + 2 + 3 |
| `/agtoosa-spec research` | Part 1 only — context, web research, and Q&A; outputs findings, no spec file yet |
| `/agtoosa-spec plan` | Part 2 only — architecture blueprint + threat model against an already-written spec |
| `/agtoosa-spec quick` | Abbreviated — 2–3 targeted questions + spec + skip full threat model (use for small bugs/chores) |

## Objective
Transform a raw idea, feature, chore, or bug into a fully researched Specification **with** an architectural blueprint — all in one phase. This combines spec and planning into a single command.

## Workflow

### Part 1 — Research & Specification

1.  **Context Gathering (Research Agent):**
    *   Read `Docs/Context/product.md`, `tech-stack.md`, and `workflow.md` to align with project goals.
    *   Scan the existing codebase to fully understand the impact surface of the proposed work.
2.  **External Research (Web Research Agent):**
    *   Query online sources for the best solutions, libraries, APIs, and design patterns relevant to the task.
    *   **CRITICAL:** Verify all dependency versions against live sources (never assume from memory).
3.  **Q&A — 6 Forcing Questions:**

    Ask these questions **sequentially**, building each answer on the previous one. Do not skip. For `/agtoosa-spec quick`, ask only questions 1, 2, and 6.

    1. **Status quo** — What is the exact current behavior users depend on? What breaks if we change it?
    2. **Narrowest scope** — What is the smallest version of this feature that still delivers real value?
    3. **Urgency signal** — Who specifically is blocked without this? What workaround are they using today?
    4. **10-star version** — If resources were unlimited, what would the ideal implementation look like?
    5. **Failure modes** — What are the three most likely ways this could break in production?
    6. **Security surface** — Does this touch auth, data storage, external APIs, or user-controlled input?

    Questions 1–4 sharpen scope. Questions 5–6 feed directly into STRIDE threat modelling in Part 2.
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

7.  **File Generation:**
    *   Generate a single file named `Docs/AgToosa_Spec-[short-name]-v[version].md`.
    *   This file contains BOTH the executable spec AND the architectural plan.
8.  **Master-Plan Update:**
    *   Link the newly generated Spec to the relevant Epic in Linear.
    *   Mirror the spec link in `Docs/Master-Plan.md` under "Active Specifications & Plans".

## Output
*   Present the generated Spec (with embedded plan) to the user.
*   Prompt the user to review and, if approved, run `/agtoosa-build` to start implementation.
