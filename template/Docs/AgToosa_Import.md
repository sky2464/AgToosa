# AgToosa /agtoosa-import Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-import` | Full flow: review external/async agent results against ACs before task closure |
| `/agtoosa-import check` | Checklist only — report gaps; do not update Master-Plan or test plan |

## Objective

Import PRs, branches, logs, screenshots, and test output from an external or async agent into **repo-local evidence**, map them to tasks and ACs, and **block checkbox closure** (agent-instructed) until verification commands pass.

> **Prerequisites:** Active story with approved spec. Optional: a handoff pack from `/agtoosa-handoff` (`Docs/archived/handoff-*.md`).
>
> **Claim Boundary:** This workflow is **agent-instructed** (not generator-enforced). It does **not** trust external agent claims without repo-local verification. Classify controls as generator-enforced, CI-enforced, agent-instructed, manual, or roadmap. Machine-checked import evidence is **roadmap** (future verifier WARN). Hosted webhook ingestion is out of scope.
>
> **Source of truth:** `Docs/Master-Plan.md` remains the repo-local source of truth. External agents, PRs, and dashboards are evidence sources only.

## Import Checklist

For each returned artifact, record:

| Field | Required | Notes |
|-------|----------|-------|
| Artifact type | Yes | `PR` · `branch` · `commit-range` · `test-log` · `screenshot` · `patch` · `other` |
| Pointer | Yes | URL, branch name, path under repo, or commit SHAs |
| Mapped tasks | Yes | Active Tasks IDs (e.g. `2.1`) |
| Mapped ACs | Yes | `AC-NNN` from the active spec |
| Verification command | Yes | Runnable in this repo |
| Exit code | Yes | Must be `0` to allow closure |
| Reviewer | Yes | Human or orchestrating agent name |

## Evidence Mapping Table

Append (or create) this table in the story test plan under `## Evidence`:

```markdown
### IMPORT evidence — [task-id or wave]

| Task | AC | Artifact | Verification | Exit | Reviewer |
|------|----|----------|--------------|------|----------|
| 2.1 | AC-001 | PR #N / branch `feat/…` | `bats tests/… -f "…"` | 0 | AgToosa |
```

Also record a Terminal Evidence Contract block (command, exit code, pass/fail, warnings, errors, changed files, next action) per `Docs/AgToosa_Agent.md`.

## Closure Gate (agent-instructed)

**Do not** mark `- [x]` on `Docs/Master-Plan.md` → `## Active Tasks` or the active spec task tree until:

1. Every imported task has a completed Import Checklist row.
2. Every Must AC touched by the import appears in the Evidence Mapping table.
3. Verification commands exit `0` (or are explicitly accepted as pre-existing with evidence).
4. Unresolved terminal warnings/errors are summarized and accepted or fixed.

Language to use when refusing premature closure:

> Never mark an imported task complete without recorded verification commands and mapped ACs. Imported claims are not evidence until repo-local verification passes.

## Workflow

1. **Collect returns** — Ask for or locate: handoff pack path (if any), PR/branch, logs, screenshots. Infer from recent git remotes when obvious.
2. **Map to tasks/ACs** — Fill the Evidence Mapping table; flag unmapped Must ACs as gaps.
3. **Verify locally** — Run verification commands; capture Terminal Evidence.
4. **If `/agtoosa-import check`** — Report pass/fail gaps only; stop.
5. **If full import and checklist green** — Update test plan Evidence section; then instruct the user that `/agtoosa-build` may tick the matching checkboxes (or tick them here only when the user explicitly asked import to close tasks).
6. **Phase event** — Append to `Docs/agtoosa-events.jsonl`:
   `{"ts":"[ISO-8601 UTC]","phase":"import","event":"complete","story":"[Story ID]","by":"AgToosa"}`
7. **Update Log** — Note import summary and artifact pointers.

## Relationship to Build / Ship

| Phase | Role |
|-------|------|
| `/agtoosa-build` | Before Tracking update, if work was done out-of-band / async, run this Import Checklist (or `/agtoosa-import`) first |
| `/agtoosa-ship check` | Soft row: when `[imported]` or IMPORT evidence exists, confirm verification commands were green — informational, not a verifier FAIL |

## Output

* Print the Evidence Mapping table and any gaps.
* On success, print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`
* If gaps remain, list them with *Fix with:* re-run verification or `/agtoosa-handoff` for a clearer pack.

## Rules

1. **No blind trust.** External “done” claims are never sufficient alone.
2. **Honest enforcement.** Describe this gate as agent-instructed, not generator- or CI-enforced, until a verifier check ships.
3. **Pair with handoff.** Prefer packs from `/agtoosa-handoff` so return contract fields match.
4. **Defer ledger.** Machine-readable evidence index is DEV-049 (roadmap) — do not invent a hosted ledger here.
5. **Secret safety.** When recording logs or screenshots, **redact** secrets, tokens, API keys, and private URLs; cite paths and command names only.
