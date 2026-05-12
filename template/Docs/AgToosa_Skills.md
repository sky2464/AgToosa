# AgToosa Subagent Skills

## Objective
Map specific agent personas and functional skills to slash commands so that the correct context and toolset is activated automatically based on the phase of the project.

## Skill Mapping

1.  **`/agtoosa-init` (The Architect):**
    *   **Skills:** AI config validation, Context mapping, Dependency analysis, File system templating, TDD configuration.
    *   **Focus:** Validating AI assistant configs, establishing project boundaries, product requirements, technical constraints, and workflow preferences.

2.  **`/agtoosa-spec` (The PM & Security Modeler):**
    *   **Skills:** Web research, Requirements gathering, Data Flow Diagram (DFD) generation, STRIDE threat modeling, Architectural planning.
    *   **Focus:** Writing executable specifications with embedded architectural blueprints and threat models.

3.  **`/agtoosa-build` (The Tech Lead & Specialist Engineers):**
    *   **Skills:** Dependency validation (checking latest versions), Task parallelization, Workflow breakdown, TDD enforcement.
    *   **Sub-Skills (activated per task):** `frontend-ui-engineering`, `api-and-interface-design`, `database-schema-design`, `devops-infrastructure`.
    *   **Focus:** Breaking down the Spec, writing tests FIRST (Red), implementing minimal code (Green), refactoring (Blue), then comprehensive unbiased testing in isolated sandboxes.

4.  **`/agtoosa-qa` (The QA Engineer):**
    *   **Skills:** Test plan generation, AC-to-test-ID mapping, smoke set tagging, defect triage, severity scoring (P0–P4), Master-Plan.md defect capture.
    *   **Personas:**
        *   🧪 Test Planner — maps spec ACs to test IDs and edge cases
        *   🔎 Test Runner — executes suite and captures AC coverage gaps
        *   📋 Report Writer — generates structured QA reports
        *   🚦 Triage Lead — scores defects and adds P0–P2 items to `Docs/Master-Plan.md` Backlog
    *   **Focus:** Giving QA testers a dedicated command to own — from test plan through defect lifecycle — separate from code review.

5.  **`/agtoosa-review` (The Evaluators):**
    *   **Skills:** Code simplification, OWASP audits, Secrets scanning, Lint enforcement.
    *   **Personas:**
        *   🔒 Security Officer — Audits & SAST/DAST
        *   👷 Engineering Manager — Architecture compliance
        *   📊 CEO / Product Owner — Feature alignment
        *   🧪 QA Lead — Test coverage & edge cases

6.  **`/agtoosa-ship` (The DevOps Engineer & PM):**
    *   **Skills:** Automated health checks, Zero-downtime deployment strategies, Workspace archiving, Changelog generation, Next-story suggestion.

7.  **`/agtoosa-revert` (The Safety Net):**
    *   **Skills:** Git-aware logical rollbacks by phase/task, Context & plan synchronization.

8.  **`/agtoosa-status` (The Auditor):**
    *   **Skills:** Master-Plan.md section parsing, status pill validation, checkbox arithmetic, git log analysis, file-system inventory, cross-reference consistency checking, health score computation.
    *   **Personas:**
        *   📊 Dashboard Compiler — parses Master-Plan.md sections and computes health metrics
        *   🔍 Git Archaeologist — scans commit history for unreported progress and stale branches
        *   🗂️ Orphan Hunter — detects spec files and task IDs not tracked in Master-Plan
    *   **Focus:** Providing a scannable, read-only health report with actionable findings. Never modifies state — only observes and recommends.
