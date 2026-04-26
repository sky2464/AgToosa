# AgToosa /agtoosa-build Workflow

## Objective
Break down the Spec into atomic tasks, build the code using Test-Driven Development, and rigorously test — all within a single phase. This combines task breakdown, building, and testing into one command.

## Workflow

### Part 1 — Task Breakdown

1.  **Dependency Validation:**
    *   **CRITICAL RULE:** Never assume the latest stable version of any language, package, or dependency from memory.
    *   Use web search or local terminal queries (e.g., `npm view`, `pip index`, `dart pub outdated`) to check and lock in the latest stable versions.
2.  **Atomic Task Breakdown:**
    *   Read the active `AgToosa_Spec-*.md` and translate it into atomic, clear, step-by-step actionable tasks.
3.  **Parallelization Strategy:**
    *   Identify which tasks can be run in parallel or by different sub-agents simultaneously (e.g., writing documentation alongside developing independent components).
4.  **Error Escalation:**
    *   If a critical flaw or blocker is identified in the Spec during task breakdown, immediately report it.
    *   Pause task generation and prompt the user to run `/agtoosa-spec` again to resolve the issue.
5.  **Master-Plan Update:**
    *   Record all generated tasks under "Active Tasks" in Linear.
    *   Mirror the current tasks in `Docs/Master-Plan.md`.
    *   Present the task list to the user for confirmation before proceeding.

### Part 2 — TDD Build Cycle

> **TDD Enforcement** (inspired by [tdd-guard](https://github.com/nizos/tdd-guard)):
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

    **🔵 REFACTOR — Clean Up:**
    *   With all tests green, refactor the code for clarity, readability, and maintainability.
    *   Apply linting rules (from `workflow.md` config).
    *   Ensure no file exceeds 500 lines of code.
    *   Ensure OpenTelemetry observability hooks are present (structured logging, metrics, tracing).
    *   Run the full test suite again to confirm nothing broke.

7.  **Repeat** the Red-Green-Refactor cycle for every atomic task.

### Part 3 — Comprehensive Testing

8.  **Unbiased Testing Army:**
    *   After all tasks are built, adopt a completely unbiased testing mindset.
    *   Drop prior assumptions about how the code *should* work.
    *   Evaluate the codebase purely to find bugs, edge cases, and regressions.
9.  **Rigorous Testing Suite:**
    *   Run all unit, integration, and E2E tests.
    *   Implement automated **Real Browser QA Testing** where applicable (e.g., Playwright/Puppeteer).
10. **Security Scanning:**
    *   **SAST** (Static Application Security Testing): Semgrep, CodeQL.
    *   **DAST** (Dynamic Application Security Testing): Runtime vulnerability checks.
    *   **Secrets Scanning**: Gitleaks or equivalent.
    *   **IaC Scanning** (if applicable): Checkov, tfsec for cloud infrastructure.
11. **SBOM Generation:**
    *   Automatically generate a Software Bill of Materials (SBOM) for supply chain security.
    *   Run continuous dependency vulnerability audits (e.g., `npm audit`, `pip-audit`).
12. **Feedback Loop:**
    *   If any issues are found, loop back to the TDD cycle (step 6) to fix them.
    *   Record all fixes in Linear and mirror them in `Docs/Master-Plan.md`.

### Part 4 — Tracking

13. **Master-Plan Update:**
    *   Record all progress and completed steps in Linear.
    *   Mirror the completed state in `Docs/Master-Plan.md`.
    *   Mark each atomic task as complete.

## Output
*   Confirm build and test phases are complete and all tests pass.
*   Present a summary of test results and any security findings.
*   Prompt the user to run `/agtoosa-review`.
