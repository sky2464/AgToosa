# AgToosa /agtoosa-update

Re-read all project state files and get fully up to speed on the current project context.

## When to Run

- Resuming work after a break and need to catch up on what changed
- The AI's understanding of the project feels stale or out of sync
- Starting a new session before diving into `/agtoosa-spec` or `/agtoosa-build`
- Something feels off — specs, Master-Plan, or context files may have been edited

## What This Command Does

This is a pure read command. The AI reads the project's current state and produces a concise briefing. No bash commands, no external tools.

## Workflow

1. **Read project context**

   Read all files in `Docs/Context/`:
   - `product.md` — what the product is and who it's for
   - `tech-stack.md` — languages, frameworks, and infra
   - `workflow.md` — team process, branching, deploy flow
   - `product-guidelines.md` — design principles and conventions

   If any file is missing or empty, note it without asking the user to fill it in now (suggest `/agtoosa-init` for that).

2. **Read Master-Plan**

   Read `Docs/Master-Plan.md`. Extract:
   - Project Goal Contract from `## Project Charter`
   - Active cycle and its goal
   - Stories currently In Progress
   - Blocked items
   - What shipped most recently

3. **Read recent Changelog entries**

   Read `Docs/AgToosa_Changelog.md`. Surface the last 1–2 releases so the current sprint is in context.

4. **Scan active specs**

   List any `Docs/AgToosa_Spec-*.md` files that are not in `Docs/archived/`. Read their Status field and Goal Contract. Note which specs are Approved, In Progress, or Draft.

5. **Check goal clarity**

   This step is read-only. Do not ask goal questions and do not update files.

   Report:
   - **Goal summary:** project goal, active story goal, success condition, and proof/evidence if present.
   - **Goal clarity gaps:** missing or vague Goal Contract fields in `Docs/Master-Plan.md` or active specs.
   - **Suggested fix:** recommend `/agtoosa-goal project`, `/agtoosa-goal story`, or `/agtoosa-spec` when goal state is missing or at risk.

6. **Produce a project briefing**

   Output a concise summary in this structure:

   ```
   ## Project Update

   **Product:** [one-line summary from product.md]
   **Stack:** [key stack items from tech-stack.md]

   **Active cycle:** [cycle name/goal from Master-Plan]
   **In Progress:** [list of active stories/tasks]
   **Blocked:** [anything blocked, or "none"]
   **Recently shipped:** [last release summary from Changelog]

   **Open specs:** [list of non-archived specs and their status]
   **Goal summary:** [project/story goal and success condition, or "missing"]

   **Context gaps:** [any missing/empty context files — suggest /agtoosa-init if significant]
   **Goal clarity gaps:** [missing/vague fields — suggest /agtoosa-goal if significant]
   ```

7. **Ask what's next**

   End with:

   > Ready. Which command do you want to run — `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-qa`, `/agtoosa-review`, or `/agtoosa-ship`?

## What Gets Updated

| Category | Action |
|----------|--------|
| `Docs/AgToosa_*.md` workflow files | Overwritten with latest version |
| Platform entry-points (`CLAUDE.md`, `.cursorrules`, etc.) | Smart merge — only if already installed |
| Platform native dirs (`.claude/commands/`, `.cursor/rules/`, etc.) | Overwritten — only AgToosa-owned files |
| `.claude/settings.json` hooks | Deep-merged, deduplicated |

## What Is Preserved

| Category | Action |
|----------|--------|
| `Docs/Context/` | Never touched (your product/tech/workflow config) |
| `Docs/Master-Plan.md` | Never touched (your project management source of truth) |
| `Docs/AgToosa_Changelog.md` | Never touched (your project changelog) |
| `Docs/archived/` | Never touched (completed specs) |
| User files in platform dirs | Never touched (only AgToosa-owned files overwritten) |
