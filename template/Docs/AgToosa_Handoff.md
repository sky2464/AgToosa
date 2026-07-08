# AgToosa /agtoosa-handoff Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-handoff` | Full flow: build a handoff pack for the active story or selected wave |
| `/agtoosa-handoff wave` | Export only the current Wave Plan wave (from the active spec) |
| `/agtoosa-handoff task` | Export a single Active Tasks row (by ID or title fragment) |

## Objective

Export an **AgToosa-ready handoff pack** — a bounded work brief for Codex, Copilot cloud agent, Jules, Devin, Cursor background agents, or Claude Code — so an async/external agent can execute a wave or task with enough context and a clear return contract.

> **Prerequisites:** An approved active spec (`## ✅ Spec Approved`) and tasks under `Docs/Master-Plan.md` → `## Active Tasks`. If missing, **stop** and instruct the user to run `/agtoosa-spec` (or `/agtoosa-spec tasks`). Do **not** auto-run those commands.
>
> **Claim Boundary:** This workflow is **agent-instructed**. Writing the pack file is instructed; launching an external agent is **manual**. Importing results is `/agtoosa-import` (DEV-048). AgToosa does **not** claim external agents completed work unless imported evidence is present.
>
> **Source of truth:** `Docs/Master-Plan.md` remains the repo-local source of truth. External agents are integrations, not authorities.

## Pack Template

Write the pack to `Docs/archived/handoff-[story-id]-[YYYYMMDD-HHMM].md` (create `Docs/archived/` if missing). Use this structure verbatim:

```markdown
# Handoff Pack — [Story ID] — [wave or task label]

> **Story:** [ID] — [title]
> **Exported:** [YYYY-MM-DD HH:MM]
> **Target agent:** [Codex | Copilot | Jules | Devin | Cursor | Claude Code | other]
> **Claim Boundary:** agent-instructed export; manual launch; import via /agtoosa-import

## 1. Story & Goal
[Paste Goal Contract rows: Goal, User outcome, Success condition, Non-goals]

## 2. Acceptance Criteria
[Paste Must (and relevant Should) AC-NNN rows from the active spec]

## 3. Files in Scope
[From spec ### 2.4 Build Scope — owned files / directories only]

## 4. Allowed Actions
- Edit only files listed in §3
- Run verification commands in §5
- Do **not** modify `Docs/Master-Plan.md` Active Cycle status without import review
- Do **not** claim ship or mark tasks complete — return evidence for `/agtoosa-import`

## 5. Verification Commands
```bash
[commands from the story test plan smoke set / wave]
```

## 6. Return Contract
Return artifacts that `/agtoosa-import` can map to tasks and ACs:
- Branch name and/or PR URL (if any)
- Commit range or patch summary
- Test log excerpt (command + exit code)
- Changed file list
- Terminal Evidence Contract fields (see `Docs/AgToosa_Agent.md`)
- Mapped ACs: AC-NNN → evidence pointer

## 7. Out of Scope
[From spec §1.3 / Non-goals]
```

## Workflow

1. **Resolve target** — Active Cycle story; if multiple In Progress, ask which ID. For `wave` / `task`, resolve against the active spec Wave Plan or Active Tasks.
2. **Assemble pack** — Fill every section from the approved spec, Master-Plan Active Tasks, and test plan. Prefer inference; ask at most one clarifying question (target agent) if unknown.
3. **Write file** — Create `Docs/archived/handoff-…md`. Do not overwrite prior packs.
4. **Phase event** — Append to `Docs/agtoosa-events.jsonl`:
   `{"ts":"[ISO-8601 UTC]","phase":"handoff","event":"export","story":"[Story ID]","by":"AgToosa"}`
5. **Update Log** — Append a row to `Docs/Master-Plan.md` → `## Update Log` noting the pack path.
6. **Print next step** — Tell the user to launch the external agent **manually**, then run `/agtoosa-import` when results return.

## Platform Notes

| Surface | How to use the pack |
|---------|---------------------|
| Cursor / Claude Code | Paste pack path or contents into a new agent/chat; keep Master-Plan as SoT |
| Codex / Copilot / Jules / Devin | Attach or paste the pack markdown; run verification commands in the target repo clone |
| All | Return evidence per §6; do not tick Master-Plan checkboxes until `/agtoosa-import` |

## Output

* Print the pack path and a one-line summary of story + wave/task.
* Print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
* Remind: launch is **manual**; closure requires `/agtoosa-import`.

## Rules

1. **Read-mostly.** May write the handoff file, one events line, and one Update Log row — nothing else.
2. **No auto-launch.** Never start external cloud agents or claim they finished.
3. **No checkbox ticks.** Task completion stays with `/agtoosa-build` after `/agtoosa-import`.
4. **Honest claims.** Never describe handoff as generator-enforced or CI-enforced.
5. **Secret safety.** Cite file paths and process steps only — never paste tokens, API keys, passwords, or private URLs into the pack. Sanitize `story-id` to `[A-Za-z0-9._-]+` (no `/` or `..`) before writing the pack filename.
