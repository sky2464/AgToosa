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

### Part 1 — Virtual Specialist Reviews

1.  **Security Officer:** OWASP Top 10 + STRIDE audit; SAST/DAST/Secrets scanning (Semgrep, CodeQL, Gitleaks); verify threat model from Spec.

2.  **Engineering Manager:** Confirm no file exceeds 500 lines; check OOP compliance, observability hooks, and test coverage thresholds.

3.  **CEO / Product Owner:** Verify feature completeness against the Linear charter and acceptance criteria.

4.  **QA Lead:** Confirm all tests pass (including browser QA); verify TDD cycle was followed if enabled.

    **🔬 Iron Law — Bug Root Cause Protocol** (`/agtoosa-review debug` runs this exclusively):

    When a test failure or bug is found, follow this protocol before writing any fix:
    1. State a **hypothesis** — which specific code path or assumption is causing this?
    2. Write a **targeted reproduction test** that isolates the failure
    3. If the test confirms the hypothesis → document the root cause in one sentence, then fix it
    4. If the test disproves the hypothesis → document why it was wrong, form a new hypothesis, repeat
    5. After **3 failed hypotheses** → stop and escalate to the user with the hypothesis log; do NOT apply a blind fix

    The root cause must appear in the review report alongside every 🔴 Critical finding.

### Part 2 — Code Simplification

5.  **Simplify:** Identify complex or repetitive code and refactor for clarity. **Principle: Clarity over Cleverness.** Apply linting rules from `workflow.md`; re-run tests after every refactor.

### Part 3 — Final Verdict

6.  **Review Report:** Structured findings from all 4 personas — 🔴 Critical / 🟡 Warning / 🟢 Passed. Every 🔴 Critical must include the Iron Law root cause. Block `/agtoosa-ship` if any 🔴 Critical findings remain.

### Part 4 — Cross-Platform Second Opinion (`/agtoosa-review cross`)

Different AI models surface different classes of bugs — a second platform review is a free, high-signal quality gate.

7.  **Cross-Platform Review:**
    1. Open a secondary AI platform (e.g., if primary is Claude Code, open Cursor or GitHub Copilot)
    2. Run `/agtoosa-review` on the same branch
    3. Compare findings — issues flagged by **both** platforms are high-confidence; issues flagged by only one warrant investigation
    *   Merge findings from both reports before running `/agtoosa-ship`. Cross-platform review is **strongly recommended** for security-sensitive changes.

## Output
*   Save the review report to `Docs/AgToosa_Review-[spec-short-name]-v[version].md`. This file is required by `/agtoosa-ship check`. The file must contain the structured findings table with all 🔴 / 🟡 / 🟢 items.
*   If all checks pass (no unresolved 🔴 Critical findings), prompt `/agtoosa-ship`.
*   If issues were found and fixed, confirm and re-run the review.
