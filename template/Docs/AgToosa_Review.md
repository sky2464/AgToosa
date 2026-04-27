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
Ensure code quality, security, and simplicity through multi-persona review and automated code simplification.

## Workflow

### Part 1 — Virtual Specialist Reviews

To ensure comprehensive quality and security, the agent must simulate the following roles:

1.  **Security Officer (Audits & SAST/DAST):**
    *   Conduct OWASP Top 10 and STRIDE security audits on the implemented code.
    *   Integrate SAST, DAST, and Secrets Scanning (e.g., Semgrep, CodeQL, Gitleaks) to block vulnerabilities and secret leaks.
    *   Verify that the implementation matches the threat model from the Spec.

2.  **Engineering Manager (Architecture):**
    *   Perform a final compliance check: Ensure no file exceeds the 500-line limit.
    *   Verify strict adherence to Object-Oriented principles and architectural guidelines.
    *   Fix any lingering code smells and ensure OpenTelemetry observability is present.
    *   Confirm test coverage meets acceptable thresholds.

3.  **CEO / Product Owner (Alignment):**
    *   Review the completed work against the Linear project charter and the initial Spec to ensure feature completeness and user value.
    *   Verify the feature delivers on the promised acceptance criteria.

4.  **QA Lead:**
    *   Ensure all tests (including browser QA where applicable) pass and edge cases are covered.
    *   Verify the TDD cycle was followed (if enabled) — every feature has a corresponding test.

    **🔬 Iron Law — Bug Root Cause Protocol** (`/agtoosa-review debug` runs this exclusively):

    When a test failure or bug is found, follow this protocol before writing any fix:
    1. State a **hypothesis** — which specific code path or assumption is causing this?
    2. Write a **targeted reproduction test** that isolates the failure
    3. If the test confirms the hypothesis → document the root cause in one sentence, then fix it
    4. If the test disproves the hypothesis → document why it was wrong, form a new hypothesis, repeat
    5. After **3 failed hypotheses** → stop and escalate to the user with the hypothesis log; do NOT apply a blind fix

    The root cause must appear in the review report alongside every 🔴 Critical finding.

### Part 2 — Code Simplification

5.  **Code Simplification:**
    *   Implement review strategies inspired by [agent-skills](https://github.com/addyosmani/agent-skills).
    *   Identify complex, repetitive, or overly verbose code.
    *   Refactor for ultimate simplicity, readability, and maintainability.
    *   **Principle: Clarity over Cleverness.**
    *   Run linting rules from `Docs/Context/workflow.md`.
    *   Run the full test suite after every refactor to ensure nothing breaks.

### Part 3 — Final Verdict

6.  **Review Summary:**
    *   Generate a structured review report with findings from all 4 personas.
    *   Categorize findings as: 🔴 Critical, 🟡 Warning, 🟢 Passed.
    *   For every 🔴 Critical finding, include the documented root cause (from Iron Law protocol).
    *   If any 🔴 Critical findings exist, block `/agtoosa-ship` and loop back to `/agtoosa-build` for fixes.

### Part 4 — Cross-Platform Second Opinion (`/agtoosa-review cross`)

AgToosa is installed on multiple AI platforms simultaneously. Different models surface different classes of bugs — a second platform review is a free, high-signal quality gate.

7.  **Cross-Platform Review:**
    *   If this project has AgToosa installed on more than one AI platform, run `/agtoosa-review` on a second platform for an independent perspective.
    *   To get a second opinion:
        1. Open your secondary AI platform (e.g., if primary is Claude Code, open Cursor or GitHub Copilot)
        2. Run `/agtoosa-review` on the same branch
        3. Compare findings — issues flagged by **both** platforms are high-confidence; issues flagged by only one warrant investigation
    *   Merge findings from both review reports before running `/agtoosa-ship`.
    *   For security-sensitive changes, cross-platform review is **strongly recommended**.

## Output
*   Present the review report to the user.
*   If all checks pass, prompt the user to run `/agtoosa-ship`.
*   If issues were found and fixed, confirm fixes and re-run the review automatically.
