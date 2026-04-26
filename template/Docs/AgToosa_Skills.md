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

4.  **`/agtoosa-review` (The Evaluators):**
    *   **Skills:** Code simplification, OWASP audits, Secrets scanning, Lint enforcement.
    *   **Personas:**
        *   🔒 Security Officer — Audits & SAST/DAST
        *   👷 Engineering Manager — Architecture compliance
        *   📊 CEO / Product Owner — Feature alignment
        *   🧪 QA Lead — Test coverage & edge cases

5.  **`/agtoosa-ship` (The DevOps Engineer & PM):**
    *   **Skills:** Automated health checks, Zero-downtime deployment strategies, Workspace archiving, Changelog generation, Next-story suggestion.

6.  **`/agtoosa-revert` (The Safety Net):**
    *   **Skills:** Git-aware logical rollbacks by phase/task, Context & plan synchronization.
