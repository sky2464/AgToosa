# AgToosa /agtoosa-review Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-review` | Full flow: all 4 personas + cross-platform suggestion |
| `/agtoosa-review security` | Security Officer persona only — OWASP + STRIDE audit |
| `/agtoosa-review arch` | Engineering Manager persona only — architecture, 500-line limit, observability |
| `/agtoosa-review debug` | Iron Law root-cause investigation for a specific bug or failing test |
| `/agtoosa-review cross` | Cross-platform second-opinion guidance (switch to another installed AI platform and re-run review) |

## Objective
Ensure code quality, security, and simplicity through multi-persona review.

> **Prerequisites:** `/agtoosa-build` must be complete. Verify that the full test suite passes and the Story status is `In Progress` in Linear (not `Todo`). If tests are failing or no build artifact exists, run `/agtoosa-build test` first.

### Part 1 — Virtual Specialist Reviews

**Before starting reviews:**
- Transition the Story issue status to `In Review` in Linear.
- Update `Docs/Master-Plan.md`: set the Story row status to `In Review`.
- Post a Linear comment on the Story issue:

    ```
    Review 🔍 Started
    Date: [YYYY-MM-DD HH:MM]

    Code review started. Running 4-persona review (Security, Eng Manager, CEO, QA Lead).

    Next: Review verdict — pass unblocks /agtoosa-ship; any 🔴 Critical blocks it.
    ```

1.  **Security Officer:** OWASP Top 10 + STRIDE audit; SAST/DAST/Secrets scanning (Semgrep, CodeQL, Gitleaks); verify threat model from Spec.

2.  **Engineering Manager (`/agtoosa-review arch`):** Confirm no file exceeds 500 lines; check OOP compliance, observability hooks, and test coverage thresholds. When running the `arch` sub-command, additionally:

    **Deep Module Analysis** (see `Docs/DEEPENING.md`):
    - Identify shallow modules: pass-through functions, one-line service methods, "Manager/Handler/Helper" classes with no domain meaning.
    - For each shallow module found: flag as 🟡 Warning with specific refactor suggestion.
    - Check that interfaces reveal WHAT the module does, not HOW it does it.

    **Domain Language Alignment** (see `Docs/LANGUAGE.md` + `Docs/Context/CONTEXT.md`):
    - Verify that variable names, function names, error messages, and API endpoints use terms from `Docs/Context/CONTEXT.md`.
    - Flag any inconsistency (e.g., `userId` when domain says `accountId`) as 🟡 Warning.
    - If `Docs/Context/CONTEXT.md` doesn't exist, note it as 🟡 Warning and suggest running `/agtoosa-spec` to establish domain language alignment.

    **ADR Coverage:**
    - Identify any significant architectural decisions made in this change that lack a corresponding ADR in `Docs/adr/`.
    - Create missing ADRs using `Docs/ADR-FORMAT.md` as a template, or flag as 🟡 Warning if creation is out of scope.

3.  **CEO / Product Owner:** Verify feature completeness against the Goal Contract, Linear charter, and acceptance criteria.

    **Goal Contract Alignment:**
    - Read the active spec's `### Goal Contract`.
    - Confirm the implemented behavior satisfies the stated Goal and User outcome.
    - Confirm the Success condition is measurable and has Proof / evidence in tests, review artifacts, demo notes, or product behavior.
    - Flag missing, vague, or contradicted Goal Contract fields as 🟡 Warning.
    - Flag implementation that meets isolated ACs but fails the Goal Contract as 🔴 Critical.

4.  **QA Lead:**

    a. **Test suite** — Confirm all unit, integration, E2E, and browser QA tests pass; verify TDD cycle was followed if enabled.

    b. **Coverage gate** — Read `coverage_threshold` from `Docs/Context/workflow.md`; flag below-threshold as 🔴 Critical.

    c. **AC coverage** — Verify every `AC-NNN` (Must-priority) in the active spec has at least one passing test in the test plan. Any uncovered AC is 🔴 Critical.

    d. **Regression check** — If this is a bug fix, confirm a regression test exists and passes (name pattern: `regression_[bug-id]_*`).

    e. **Accessibility** — For web/mobile: run axe-core or Playwright a11y checks; flag WCAG 2.1 AA violations as 🟡 Warning.

    f. **Performance baseline** — For web: verify Core Web Vitals are not regressed vs. prior run; flag regressions as 🟡 Warning.

    g. **Browser/device matrix** — Check the `browser_matrix` list in `Docs/Context/tech-stack.md`; flag untested combinations as 🟡 Warning.

    h. **Flaky test detection** — Run test suite 3× and flag any test that passes/fails non-deterministically as 🟡 Warning.

    **🔬 Iron Law — Bug Root Cause Protocol** (`/agtoosa-review debug` runs this exclusively):

    When a test failure or bug is found, follow this protocol before writing any fix:
    1. State a **hypothesis** — which specific code path or assumption is causing this?
    2. Write a **targeted reproduction test** that isolates the failure
    3. Once the hypothesis is confirmed, write a **regression test** named `regression_[bug-id]_[short-desc]`:
       - The regression test MUST fail on the unfixed code
       - The regression test MUST pass after the fix
       - The regression test MUST NOT be deleted or skipped
       - Record the regression test ID in the 🔴 Critical finding row
    4. If the reproduction test disproves the hypothesis → document why it was wrong, form a new hypothesis, repeat
    5. After **3 failed hypotheses** → stop and escalate to the user with the hypothesis log; do NOT apply a blind fix

    The root cause AND regression test ID must appear in the review report alongside every 🔴 Critical finding.

### Part 2 — Code Simplification

5.  **Simplify:** Identify complex or repetitive code and refactor for clarity. **Principle: Clarity over Cleverness.** Apply linting rules from `workflow.md`; re-run tests after every refactor.

### Part 3 — Final Verdict

6.  **Review Report:** Structured findings from all 4 personas — 🔴 Critical / 🟡 Warning / 🟢 Passed. Every 🔴 Critical must include the Iron Law root cause. Include a Goal Contract alignment row. Block `/agtoosa-ship` if any 🔴 Critical findings remain.

    **Linear update (after verdict):**
    - If **all clear** (no unresolved 🔴 Critical): post a comment on the Story issue:

        ```
        Review ✅ Passed
        Date: [YYYY-MM-DD HH:MM]

        All 4 personas passed. No 🔴 Critical findings. [N] 🟡 Warnings (accepted / fixed — list them).

        Next: /agtoosa-ship to deploy.
        ```

    - If **blocked** (unresolved 🔴 Critical): post a comment and transition the Story back to `In Progress`:

        ```
        Review 🔴 Blocked
        Date: [YYYY-MM-DD HH:MM]

        [N] 🔴 Critical finding(s) must be resolved before shipping: [brief list]. Story reset to In Progress.

        Next: /agtoosa-build tdd to address findings, then re-run /agtoosa-review.
        ```

### Part 4 — Cross-Platform Second Opinion (`/agtoosa-review cross`)

Different AI models surface different classes of bugs — a second platform review is a free, high-signal quality gate.

7.  **Cross-Platform Review:**
    1. Open a secondary AI platform (e.g., if primary is Claude Code, open Cursor or GitHub Copilot)
    2. Run `/agtoosa-review` on the same branch
    3. Compare findings — issues flagged by **both** platforms are high-confidence; issues flagged by only one warrant investigation
    *   Merge findings from both reports before running `/agtoosa-ship`. Cross-platform review is **strongly recommended** for security-sensitive changes.

## Output
*   Save the review report to `Docs/archived/review-[story-id].md` (e.g., `Docs/archived/review-DEV-15.md`). This file is required by `/agtoosa-ship check`. The file must contain the structured findings table with all 🔴 / 🟡 / 🟢 items.
*   Present the approval gate:

    ```
    ✅ Review complete — Verdict: [PASS / BLOCKED]
    🔴 Critical: [N]  🟡 Warning: [N]  🟢 Passed: [N]
    [One sentence summarising the biggest finding, or "No critical issues found."]
    → Approve to proceed to /agtoosa-ship  |  Address findings and re-run review
    ```

    If any 🔴 Critical findings remain, the gate shows `BLOCKED`. Do not proceed to `/agtoosa-ship` without explicit user override. Wait for the user's response.
