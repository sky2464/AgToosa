# AgToosa /agtoosa-build Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-build` | Full flow: Parts 1 + 2 + 3 + 4 |
| `/agtoosa-build scope` | Part 1 only — scope declaration + task breakdown; stops before any code is written |
| `/agtoosa-build tdd` | Part 2 only — TDD Red-Green-Refactor loop against an already-declared scope and task list |
| `/agtoosa-build test` | Parts 3 + 4 — run the full testing army + security scans, then update tracking |

### Claude Code Parallel Pattern

On Claude Code, independent tasks within a phase can be dispatched to parallel sub-agents via the `Task` tool. Apply this when Part 1 produces tasks with no sequential dependency:

- Identify tasks in the breakdown that do not share state with other tasks in the same phase.
- Batch those tasks into parallel `Task` tool calls before starting the TDD loop (Part 2).
- Collect results when all parallel tasks complete; merge conflicts are resolved by the orchestrating agent.
- See `/agtoosa-review` for the reference parallel pattern (4 reviewer personas run simultaneously).

> **Note:** Parallel dispatch applies to Claude Code only. On other platforms, run tasks sequentially.

## Objective
Break down the Spec into atomic tasks, build with TDD, and rigorously test.

> **Prerequisites:** `/agtoosa-spec` must be complete. Verify that `Docs/archived/` contains an approved `spec-[story-id].md`, or that the active `AgToosa_Spec-*.md` has a `## ✅ Spec Approved` section. If not, run `/agtoosa-spec` first.

## Workflow

### Part 1 — Task Breakdown

1.  **Step 0 — Declare Scope Boundary (before any code is written):**

    > **Follow the Smart Interview Protocol** (`Docs/AgToosa_Agent.md` → `## Smart Interview Protocol`).
    > Maximum **2 questions** for this phase: scope confirm + task list confirm.

    Derive the scope boundary from the approved spec. Present it as a pre-filled approval gate — do not ask the user to define scope from scratch:

    ```
    ✅ Ready to proceed — Scope Boundary
    Files in scope      : [list specific files from the spec]
    Directories in scope: [list directories]
    Out of scope        : [list anything that must NOT be touched]
    → Approve scope  |  Correct anything below
    ```

    - Save the confirmed scope declaration under a `## Build Scope` heading at the top of the active `AgToosa_Spec-*.md`.
    - Any edit to a file **not** in the declared scope requires stopping and presenting:
      ```
      ❓ [filename] is outside the declared scope.
        → A) Include it in scope (I'll update the spec)
        → B) Skip this file
        → C) Create a separate /agtoosa-task for it
      ```
    - The scope check runs before every file write during the TDD cycle.
    - After user confirms scope, generate **`Docs/AgToosa_TestPlan-[name].md`** containing:
      - Spec reference (link to `AgToosa_Spec-*.md`)
      - AC coverage table — each `AC-NNN` from the spec mapped to test IDs (`T-001`, `T-002`, ...)
      - Test category per ID: Unit · Integration · E2E · Security · Performance
      - Coverage target from `Docs/Context/workflow.md` (`coverage_threshold`), default 80%
      - At least one negative/edge scenario per Must-priority AC
      - Smoke set — at least one test per Must-priority AC tagged `@smoke`
    - Present the task list and test plan together as a second approval gate:

      ```
      ✅ Ready to build — Task Breakdown & Test Plan
      [N] tasks derived from the spec. [N] test IDs mapped to [N] ACs.
      → Approve to start TDD  |  Remove, add, or reorder tasks below
      ```

    Wait for explicit approval before writing any code.

2.  **Dependency Validation:**
    *   **CRITICAL:** Never assume dependency versions from memory — verify via web search or terminal (`npm view`, `pip index`, `dart pub outdated`).
3.  **Atomic Task Breakdown:**
    *   Read the active `AgToosa_Spec-*.md` and translate it into atomic, clear, step-by-step actionable tasks.
4.  **Parallelization:** Identify tasks that can run in parallel or be handled by sub-agents.
5.  **Error Escalation:** If a critical flaw is found during task breakdown, stop and ask the user to re-run `/agtoosa-spec`.
6.  **Master-Plan.md Task Update:**
    *   For each atomic task, add a Task entry under the active Story in `Docs/Master-Plan.md`:
        - Title: `Task: [short description]`
        - Type: Chore
        - Status: `Todo`
    *   Record all Task titles in `Docs/Master-Plan.md` under `## Active Tasks`.
    *   Present the task list to the user for confirmation before proceeding.

### Part 2 — TDD Build Cycle

> **TDD Enforcement:**
> If `Docs/Context/workflow.md` has `tdd: true`, strictly follow the Red-Green-Refactor cycle below.
> If TDD is disabled, still write tests but the strict ordering is relaxed.

**Before starting the first TDD task:**
- Update `Docs/Master-Plan.md`: move the Story row from `## Backlog` to `## Active Cycle`, set status to `In Progress`.
- Add an Update Log entry to `Docs/Master-Plan.md`:

    ```
    Build 🏗️ Started
    Date: [YYYY-MM-DD HH:MM]

    Starting TDD cycle. [N] tasks declared. Scope: [list key files in scope].

    Next: Task 1/[N] — [task title].
    ```

6.  **For each atomic task, execute the TDD Cycle:**

    **🔴 RED — Write a Failing Test First:**
    *   Before writing ANY implementation code, write a test that describes the expected behavior.
    *   The test MUST fail initially (confirming it tests something real).
    *   Test types: unit tests, integration tests, or E2E tests as appropriate.
    *   **Test Data Rules:**
        - Use clearly fake values only — names like "Test User", emails like "test@example.com"
        - Never use real PII in test fixtures — 🔴 Critical finding in `/agtoosa-review` if found
        - Define fixtures and factories in `tests/fixtures/` or `tests/factories/`
        - Integration tests that touch a database must use isolated transactions or a dedicated test schema
        - Seed data scripts must be idempotent (safe to run multiple times)

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
    *   **Linear update (per task):** After the Refactor step passes:
        - Transition the Task sub-issue status to `Done` in Linear.
        - Update `Docs/Master-Plan.md`: increment the Tasks Done count for the Story row.
        - Post a Linear comment on the Story issue:

            ```
            Task 🟢 [N]/[M] complete
            Date: [YYYY-MM-DD HH:MM]

            Completed: Task [N] — [task title]. Tests: [X] new, all green.

            Next: Task [N+1]/[M] — [next task title].
            ```

7.  **Repeat** the Red-Green-Refactor cycle for every atomic task.

### Discovery Triage

Any bug, edge case, or out-of-scope requirement discovered during the TDD cycle must be triaged immediately — **never silently fixed or dropped**.

**Trigger conditions** (run triage when any of these are noticed):
- A bug in existing code not related to the current task
- An edge case not covered by the active spec's ACs
- A missing test for existing behavior
- A new requirement raised by the user mid-build
- Technical debt that would take > 30 min to fix now
- A dependency security issue found during SBOM/audit step

**Triage steps** (non-blocking — inline, < 2 min):
1. Classify: Bug / Chore / Feature / Security
2. Size: can it be fixed in < 15 min without scope creep? If yes → fix it now and note it in the build summary.
3. If not trivial — ask the user: "I found [brief description]. Should I: (A) add to Master-Plan.md Backlog for later, (B) add to current scope, or (C) ignore?"
4. **If A** — run `/agtoosa-task`, add `Discovered during /agtoosa-build on [Story ID] on [date]` to the description, record in `Docs/Master-Plan.md` under `## Backlog`.
5. **If B** — update the Scope Boundary in the active spec, create a new Task sub-issue under the Story, continue TDD.
6. Record the triage decision (fix now / issue created / ignored) in the build summary output.

### Part 3 — Comprehensive Testing

8.  **Unbiased Testing:**
    *   Drop prior assumptions about how the code should work; evaluate purely to find bugs and regressions.
    *   Run all unit, integration, and E2E tests; add browser QA (Playwright/Puppeteer) where applicable.
9.  **Security Scanning:** SAST (Semgrep/CodeQL), DAST (runtime checks), Secrets scanning (Gitleaks), IaC scanning (Checkov/tfsec).
10. **SBOM:** Generate a Software Bill of Materials; run dependency audits (`npm audit`, `pip-audit`).
11. **Feedback Loop:** Loop back to the TDD cycle for any issues found; record fixes in `Master-Plan.md`.

### Part 4 — Tracking

12. **Master-Plan Update:** Mark all completed tasks in `Docs/Master-Plan.md`; update story status.

## Output
*   Confirm build and test phases are complete and all tests pass.
*   Present a summary of test results and any security findings.
*   Prompt the user to run `/agtoosa-review`.
