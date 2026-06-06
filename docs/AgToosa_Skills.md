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

3.  **`/agtoosa-goal` (The Prompt Strategist):**
    *   **Skills:** Goal clarification, ambiguity detection, success-condition design, evidence mapping, scope boundary capture.
    *   **Focus:** Acting as an optional sub-workflow called directly or by init/spec/review/ship when intent or proof of completion is unclear.

4.  **`/agtoosa-build` (The Tech Lead & Specialist Engineers):**
    *   **Skills:** Dependency validation (checking latest versions), Task parallelization, Workflow breakdown, TDD enforcement.
    *   **Sub-Skills (activated per task):** `frontend-ui-engineering`, `api-and-interface-design`, `database-schema-design`, `devops-infrastructure`.
    *   **Focus:** Breaking down the Spec, writing tests FIRST (Red), implementing minimal code (Green), refactoring (Blue), then comprehensive unbiased testing in isolated sandboxes.

5.  **`/agtoosa-qa` (The QA Engineer):**
    *   **Skills:** Test plan generation, AC-to-test-ID mapping, smoke set tagging, defect triage, severity scoring (P0–P4), Master-Plan.md defect capture.
    *   **Personas:**
        *   🧪 Test Planner — maps spec ACs to test IDs and edge cases
        *   🔎 Test Runner — executes suite and captures AC coverage gaps
        *   📋 Report Writer — generates structured QA reports
        *   🚦 Triage Lead — scores defects and adds P0–P2 items to `docs/Master-Plan.md` Backlog
    *   **Focus:** Giving QA testers a dedicated command to own — from test plan through defect lifecycle — separate from code review.

6.  **`/agtoosa-review` (The Evaluators):**
    *   **Skills:** Code simplification, OWASP audits, Secrets scanning, Lint enforcement.
    *   **Personas:**
        *   🔒 Security Officer — Audits & SAST/DAST
        *   👷 Engineering Manager — Architecture compliance
        *   📊 CEO / Product Owner — Feature alignment
        *   🧪 QA Lead — Test coverage & edge cases

7.  **`/agtoosa-ship` (The DevOps Engineer & PM):**
    *   **Skills:** Automated health checks, Zero-downtime deployment strategies, Workspace archiving, Changelog generation, Next-story suggestion.

8.  **`/agtoosa-revert` (The Safety Net):**
    *   **Skills:** Git-aware logical rollbacks by phase/task, Context & plan synchronization.

9.  **`/agtoosa-status` (The Auditor):**
    *   **Skills:** Master-Plan.md section parsing, status pill validation, checkbox arithmetic, git log analysis, file-system inventory, cross-reference consistency checking, health score computation.
    *   **Personas:**
        *   📊 Dashboard Compiler — parses Master-Plan.md sections and computes health metrics
        *   🔍 Git Archaeologist — scans commit history for unreported progress and stale branches
        *   🗂️ Orphan Hunter — detects spec files and task IDs not tracked in Master-Plan
    *   **Focus:** Providing a scannable, read-only health report with actionable findings. Never modifies state — only observes and recommends.

10. **`/agtoosa-status-guide` (The Auditor + Coach):**
    *   **Skills:** Status dashboard interpretation, Part 5.5 Recommended Next Actions ranking, finding-to-command mapping, authorization gating.
    *   **Personas:**
        *   📊 Auditor — runs `/agtoosa-status` without modifying files or git state
        *   🧭 Coach — presents the top three recommended actions with finding IDs and rationale
    *   **Focus:** Helping the user choose the next fix command while preserving the read-only status guarantee until the user explicitly authorizes a command.

## Codex Workflow Prompts And Skills

AgToosa installs one Codex slash prompt per lifecycle command under `template/.codex/prompts/agtoosa-*.md` and one Codex skill under `template/.codex/skills/agtoosa-*/SKILL.md`. Prompt files make `/agtoosa-*` visible in Codex slash-command pickers; skill files execute the matching workflow in `template/Docs/AgToosa_*.md` (installed as `Docs/` in host repos). In **Maintainer Dogfood Mode**, use `docs/AgToosa_*.md` mirrors. Sub-command skills must **Dispatch** without duplicating the full doc inline.

## Project Specialists (cross-platform v1)

`/agtoosa-init` runs **Project Specialist Discovery**; `/agtoosa-update` runs a read-only **Specialist Compatibility Check** and may propose post-Verify materialization; `/agtoosa-spec` runs **Spec Specialist Orchestration** when `docs/Context/specialists.md` exists.

| Topic | Rule |
|-------|------|
| Canonical doc | `docs/AgToosa_Specialists.md` (mirror of `template/Docs/AgToosa_Specialists.md`) |
| Roster | `docs/Context/specialists.md` in generated projects only — not in template pack |
| Reserved names | No `agtoosa-*` specialist ids or `/agtoosa-*` triggers |
| Evidence | Structured block required in terminal output (see Specialists doc) |
| Parallel | Claude Code native; other platforms sequential with explicit fallback note |
| CLI update | `agtoosa.sh --update` never overwrites project specialist files |

Do not duplicate discovery tables in platform adapters — route to `docs/AgToosa_Specialists.md`.

## Generated Project Skills

`/agtoosa-init` (**Project Skill Discovery**, Phase F) and `/agtoosa-spec` (**Story Skill Opportunity Synthesis**) may propose `.codex/skills/<skill-name>/SKILL.md` files after explicit user approval. Generated skills use concise bodies, optional `references/`/`scripts/`/`assets/` only when needed, dedupe against existing workflow skills, exclude secret values, and record decisions in the spec or Master-Plan Update Log. Do not generate README or other auxiliary docs by default.
