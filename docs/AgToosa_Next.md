# AgToosa /agtoosa-next Workflow

## Objective

Advance the project by **one lifecycle phase per invocation**. `/agtoosa-next` reads `docs/Master-Plan.md` (via the generator status pulse), picks the correct AgToosa workflow for the current state, and **executes** it — unlike `/agtoosa-help next`, which is read-only assistance.

> **Maintainer Dogfood Mode:** This repository uses `docs/` paths. Generated projects use `Docs/`. See `docs/agtoosa-maintainer.md`.

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-next` | **Full dispatch:** state pulse → route → execute exactly one lifecycle workflow |
| `/agtoosa-next dry` | **Preview only:** same routing logic; print dispatch decision; do **not** execute |
| `/agtoosa-next pick` | **Idle cold-start:** when no active cycle work remains, present backlog recommendations; user picks one → run `/agtoosa-spec` for that story |

## Distinction from `/agtoosa-help next`

| Surface | Mutates project? | Executes workflows? |
|---------|------------------|---------------------|
| `/agtoosa-help next` | No | No — suggestion only |
| `/agtoosa-next` | Yes (via dispatched workflow) | Yes — runs one phase |
| `/agtoosa-next dry` | No | No — preview only |

## Phase Stop Contract

- `/agtoosa-next` dispatches **one** lifecycle command per invocation.
- It **never** auto-chains Spec → Build → Review → Ship in a single run.
- Inner workflows honor their own phase stops (e.g. `/agtoosa-spec` stops at the approval gate).
- When the user says **"next"** again after a phase completes, run `/agtoosa-next` to advance to the following phase.

## Routing Algorithm

### Step 0 — State pulse (mandatory)

```bash
bash agtoosa.sh --status-line [path] --route-hint --format json
```

On Windows: `agtoosa.ps1 -StatusLine -RouteHint` with JSON output when available.

Parse: `anchor`, `story_id`, `tasks_done`, `tasks_total`, `next`, `sync`.

If CLI unavailable, read `docs/Master-Plan.md` read-only and apply the same rules as `lib/maintain.sh` → `run_status_line`.

### Step 1 — Approval override (build guard)

When `anchor` is `build` (or `next` is `/agtoosa-build`):

1. Load `docs/archived/spec-<story_id>.md` for the active story.
2. If `## ✅ Spec Approved` is **missing**, override dispatch to `/agtoosa-spec` — present the spec for approval; do **not** start build.
3. Rationale line: `Spec ready but not approved — approval gate before build`.

### Step 2 — Active cycle dispatch

When Active Cycle has an In Progress, In Review, or Todo story (`story_id` ≠ `none`):

| `anchor` / `next` | Dispatch | Notes |
|-------------------|----------|-------|
| `spec` | `/agtoosa-spec` | Target active `story_id` when enrolled |
| `build` | `/agtoosa-build` | After approval override passes |
| `review` | `/agtoosa-review` | All automated tasks complete |
| `ship` | `/agtoosa-ship` | Review passed / In Review status |

Print dispatch banner before executing:

```text
AgToosa Next → /agtoosa-<command> (<story-id>) — <one-line rationale>
SYNC: <paste pulse line>
```

Then read and execute the matching `docs/AgToosa_<Phase>.md` workflow in full.

### Step 3 — Idle cycle (no active work)

When Active Cycle is empty or all rows are Shipped/Done/Backlog-only:

1. **Backlog scan** — Read `## Backlog` for the highest-priority row (`P0` first) that is:
   - Not `🏁 Shipped` or `✅ Done`
   - Status contains `Draft`, `Spec ready`, `needs-interview`, or `Backlog`
2. **If a backlog candidate exists:**
   - `needs-interview` → `/agtoosa-spec` for that story (Plan-Mode Spec Interview)
   - `Spec ready` → `/agtoosa-spec` (approval gate slice if spec file exists; else complete spec)
   - `Draft` / `Backlog` → `/agtoosa-spec` for that story ID
3. **If no backlog candidate** — **cold start:**
   - Tell the user there is no enrolled spec yet.
   - Ask: *"Do you have something in mind to work on together?"*
   - If yes → `/agtoosa-spec` with their idea.
   - If no → present **up to 3** recommendations from Backlog (priority order, skip shipped/done, note blockers). Use **Question Format** from `docs/AgToosa_Agent.md` → Smart Interview Protocol. User picks one → `/agtoosa-spec` for that story.

`/agtoosa-next pick` always uses step 3 cold-start presentation even when a default backlog row exists — user must confirm the pick.

### Step 4 — Blocked or unclear

When multiple blockers, conflicting status, or `anchor` is `none` with ambiguous Master-Plan:

1. Run `/agtoosa-status` (read-only).
2. Print top finding and the recommended fix command.
3. **Stop** — do not guess a mutating dispatch.

## Execution Contract

After dispatch banner:

1. Read the target workflow doc (`docs/AgToosa_Spec.md`, `Build.md`, `Review.md`, or `Ship.md`).
2. Execute that workflow's full flow (respecting sub-command defaults).
3. Honor **Phase Stop** inside the dispatched workflow.
4. On successful completion, print the **dual-line phase close** from the dispatched workflow (`Next:` + `SYNC:` per `docs/AgToosa_Agent.md` → Lifecycle Next-Step Contract).
5. Remind the user: *"Say `/agtoosa-next` again when ready to advance."*

## Relationship to Lifecycle Compass

- Freeform asks without `/agtoosa-*` still use **AgToosa Lifecycle Compass** (Project Intake).
- Explicit `/agtoosa-next` bypasses Compass ceremony and runs this dispatch protocol.
- Compass `ANCHOR` values (`spec` · `build` · `review` · `ship`) align with `anchor` from `--route-hint`.

## Output (dry / preview)

For `/agtoosa-next dry`:

```text
AgToosa Next (dry) → /agtoosa-<command> (<story-id|none>) — <rationale>
SYNC: ...
Note: No workflow executed. Run `/agtoosa-next` to dispatch.
```

## Threat Model (STRIDE summary)

| Threat | Mitigation |
|--------|------------|
| Spoofing — wrong phase dispatched | Deterministic pulse from Master-Plan; approval override before build |
| Tampering — agent skips approval | Build guard checks `## ✅ Spec Approved` in spec file |
| Repudiation — unclear what ran | Dispatch banner + SYNC line before every execution |
| Information disclosure | No secrets in routing; same reads as status-line |
| Denial of service | Single-phase dispatch; fail-closed on ambiguous state |
| Elevation — auto-chaining phases | Phase Stop: one command per `/agtoosa-next` invocation |
