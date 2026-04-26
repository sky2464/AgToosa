# AgToosa /agtoosa-review Workflow

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
    *   If any 🔴 Critical findings exist, block `/agtoosa-ship` and loop back to `/agtoosa-build` for fixes.

## Output
*   Present the review report to the user.
*   If all checks pass, prompt the user to run `/agtoosa-ship`.
*   If issues were found and fixed, confirm fixes and re-run the review automatically.
