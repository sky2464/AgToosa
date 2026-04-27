# AgToosa /agtoosa-build Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-build` | Full flow: Parts 1 + 2 + 3 + 4 |
| `/agtoosa-build scope` | Part 1 only — scope declaration + task breakdown; stops before any code is written |
| `/agtoosa-build tdd` | Part 2 only — TDD Red-Green-Refactor loop against an already-declared scope and task list |
| `/agtoosa-build test` | Parts 3 + 4 — run the full testing army + security scans, then update tracking |

## Objective
Break down the Spec into atomic tasks, build with TDD, and rigorously test.

## Workflow

### Part 1 — Task Breakdown

1.  **Step 0 — Declare Scope Boundary (before any code is written):**

    Output the following scope declaration and wait for user confirmation before proceeding:

    ```
    📌 Scope Boundary for this Build
    Files in scope      : [list specific files from the spec]
    Directories in scope: [list directories]
    Out of scope        : [list anything that must NOT be touched]
    ```

    - Save the scope declaration under a `## Build Scope` heading at the top of the active `AgToosa_Spec-*.md`.
    - Any edit to a file **not** in the declared scope requires stopping and asking: _"This file is outside the declared scope. Include it? (Yes / No / Update scope)"_
    - The scope check runs before every file write during the TDD cycle.

2.  **Dependency Validation:**
    *   **CRITICAL:** Never assume dependency versions from memory — verify via web search or terminal (`npm view`, `pip index`, `dart pub outdated`).
3.  **Atomic Task Breakdown:**
    *   Read the active `AgToosa_Spec-*.md` and translate it into atomic, clear, step-by-step actionable tasks.
4.  **Parallelization:** Identify tasks that can run in parallel or be handled by sub-agents.
5.  **Error Escalation:** If a critical flaw is found during task breakdown, stop and ask the user to re-run `/agtoosa-spec`.
6.  **Master-Plan Update:**
    *   Record all generated tasks under "Active Tasks" in Linear.
    *   Mirror the current tasks in `Docs/Master-Plan.md`.
    *   Present the task list to the user for confirmation before proceeding.

### Part 2 — TDD Build Cycle

> **TDD Enforcement:**
> If `Docs/Context/workflow.md` has `tdd: true`, strictly follow the Red-Green-Refactor cycle below.
> If TDD is disabled, still write tests but the strict ordering is relaxed.

6.  **For each atomic task, execute the TDD Cycle:**

    **🔴 RED — Write a Failing Test First:**
    *   Before writing ANY implementation code, write a test that describes the expected behavior.
    *   The test MUST fail initially (confirming it tests something real).
    *   Test types: unit tests, integration tests, or E2E tests as appropriate.

    **🟢 GREEN — Minimal Implementation:**
    *   Write the MINIMUM code necessary to make the failing test pass.
    *   Do NOT add features, optimizations, or abstractions beyond what the test requires.
    *   Run the test suite to confirm the new test passes and no existing tests break.
    *   **WIP Micro-Commit:** once green, immediately commit progress:
        ```
        git add -p && git commit -m "WIP: [task-id] [short description]"
        ```
        This preserves progress and allows context restoration if the session is interrupted.

    **🔵 REFACTOR — Clean Up:**
    *   With all tests green, refactor the code for clarity, readability, and maintainability.
    *   Apply linting rules (from `workflow.md` config).
    *   Ensure no file exceeds 500 lines of code.
    *   Ensure OpenTelemetry observability hooks are present (structured logging, metrics, tracing).
    *   Run the full test suite again to confirm nothing broke.

7.  **Repeat** the Red-Green-Refactor cycle for every atomic task.

### Part 3 — Comprehensive Testing

8.  **Unbiased Testing:**
    *   Drop prior assumptions about how the code should work; evaluate purely to find bugs and regressions.
    *   Run all unit, integration, and E2E tests; add browser QA (Playwright/Puppeteer) where applicable.
9.  **Security Scanning:** SAST (Semgrep/CodeQL), DAST (runtime checks), Secrets scanning (Gitleaks), IaC scanning (Checkov/tfsec).
10. **SBOM:** Generate a Software Bill of Materials; run dependency audits (`npm audit`, `pip-audit`).
11. **Feedback Loop:** Loop back to the TDD cycle for any issues found; record fixes in Linear and `Master-Plan.md`.

### Part 4 — Tracking

12. **Master-Plan Update:** Mark all completed tasks in Linear and mirror in `Docs/Master-Plan.md`.

## Output
*   Confirm build and test phases are complete and all tests pass.
*   Present a summary of test results and any security findings.
*   Prompt the user to run `/agtoosa-review`.
