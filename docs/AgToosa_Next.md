# AgToosa /agtoosa-next Workflow

## Objective

**Primary sequential command for ~90% of users.** After `/agtoosa-init`, repeat `/agtoosa-next` to spec, build, test, review, fix, decide, update docs, and ship — one phase per invocation. SYNC drives routing; users do not need to memorize the lifecycle diagram.

> **Maintainer Dogfood Mode:** This repository uses `docs/` paths. Generated projects use `Docs/`. See `docs/agtoosa-maintainer.md`.

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-next` | **Full dispatch:** state pulse → route → execute exactly one workflow |
| `/agtoosa-next dry` | **Preview only:** same routing as help-next; do **not** execute |
| `/agtoosa-next pick` | **Idle cold-start:** present backlog recommendations; user picks → `/agtoosa-spec` |
| `/agtoosa-next fix` | Tributary: small bug/chore → serving build or `/agtoosa-spec quick` |
| `/agtoosa-next test` | Tributary: QA → `/agtoosa-qa` or `/agtoosa-build test` |
| `/agtoosa-next docs` | Tributary: changelog/archive only → `/agtoosa-ship docs` |

## Help previews, Next executes (A+B)

| Surface | Mutates? | Executes? |
|---------|----------|-----------|
| `/agtoosa-help next` | No | No — same routing as `dry`; ends with "To execute: `/agtoosa-next`" |
| `/agtoosa-next` | Yes (via dispatched workflow) | Yes — one phase |
| `/agtoosa-next dry` | No | No |

## Phase Stop Contract

- One lifecycle command per `/agtoosa-next` invocation.
- **Never** auto-chain Spec → Build → Review → Ship in a single run.
- Inner workflows honor their own phase stops — except approval gates when **served by Next** (see Sequential Approval Contract).
- Closure line: `Next: /agtoosa-next — <rationale>` plus SYNC pulse (underlying phase optional in rationale).

## Sequential Approval Contract

When `/agtoosa-next` **dispatches** a lifecycle workflow, the user's `/agtoosa-next` invocation counts as **explicit approval** at phase gates — complete the phase through approval, then stop. Direct phase slashes (`/agtoosa-spec`, `/agtoosa-review`, `/agtoosa-ship`) keep the standard separate approval turns.

| Gate | Next-served behavior |
|------|---------------------|
| **Spec** | After Parts 1–4 and Spec Quality Analyzer pass, append `## ✅ Spec Approved`, update Master-Plan, close — do **not** wait for a second approval turn |
| **Review** | When verdict is PASS (no unresolved 🔴 Critical), record Review ✅ Approved and close — do **not** wait for a second approval turn |
| **Ship deploy** | After Part 0 passes, run Part 1 deploy/archive in the same invocation — do **not** wait for a separate deploy approval turn |

**Still blocked (no implicit override):**

- Spec Quality Analyzer failures or unresolved Must-AC gaps
- 🔴 Critical review findings (verdict BLOCKED)
- Part 0 ship readiness failures (🔴 Critical)
- Cross-model reviewer model tier above parent session (still needs explicit consent in the same turn)

**Repeat `/agtoosa-next`** after each phase closes to advance: spec approved → build; build complete → review; review approved → ship; ship complete → next backlog spec (or cold-start).

## Routing Algorithm

### Step 0 — State pulse (mandatory)

```bash
bash agtoosa.sh --status-line [path] --route-hint --format json
```

On Windows: `agtoosa.ps1 -StatusLine -RouteHint` with JSON when available.

Parse: `anchor`, `story_id`, `tasks_done`, `tasks_total`, `next`, `sync`, `spec_approved`.

When `spec_approved` is `false`, SYNC `next` is already `/agtoosa-spec` (generator-enforced). Still verify active spec file before build dispatch.

### Step 1 — Tributary intents (optional argument)

When user passes `fix`, `test`, `docs`, or Compass routes a tributary:

| Intent | Serving phase | Dispatches |
|--------|---------------|------------|
| `fix` — small bug/chore | active `build` | `/agtoosa-build` expedite or `/agtoosa-spec quick` |
| `test` — QA / test run | `build` or pre-review | `/agtoosa-qa` or `/agtoosa-build test` |
| PM / decision / unclear goal | `spec` | `/agtoosa-goal story` or `/agtoosa-spec` |
| Backlog capture | `spec` | `/agtoosa-task` |
| `docs` — changelog/archive only | `ship` | `/agtoosa-ship docs` |
| Parallel / handoff / cross-model | — | **Advanced mode** — do not route via Next |

### Step 2 — Lifecycle anchor (sequential default)

| SYNC `anchor` / `next` | Dispatches |
|------------------------|------------|
| `spec` | `/agtoosa-spec` |
| `build` | `/agtoosa-build` (only when `spec_approved` is true) |
| `review` | `/agtoosa-review` |
| `ship` | `/agtoosa-ship` |
| idle / none | Backlog scan → spec, or cold-start |

Print dispatch banner before executing:

```text
AgToosa Next → /agtoosa-<command> (<story-id>) — <one-line rationale>
SYNC: <paste pulse line>
```

### Step 3 — Idle cycle (post-ship or empty Active Cycle)

1. **Backlog scan** — highest-priority (`P0` first) non-shipped row with Draft, Spec ready, needs-interview, or Backlog.
2. **Candidate exists** → dispatch `/agtoosa-spec` for that story (interview + draft + **Sequential Approval** when quality checks pass).
3. **No candidate** — cold start:

```text
No spec is planned in Master-Plan.
Recommendations:
  1. [story-id] — [title] ([priority])
  2. ...
  3. ...
Or describe what the next spec should be, or run /agtoosa-next pick.
```

`/agtoosa-next pick` always uses cold-start presentation (user must confirm before spec dispatch).

### Step 4 — Blocked or unclear

Run `/agtoosa-status` (read-only), print top finding, **stop** — do not guess.

## Advanced mode

Honor explicit phase slashes when the user names them (`/agtoosa-review security`, `/agtoosa-handoff`, cross-model review, parallel orchestration). **Do not** invoke `/agtoosa-next` for those — run the named advanced command directly.

## Execution Contract

1. Read target workflow doc and execute full flow **as served by `/agtoosa-next`** (Sequential Approval Contract applies).
2. Honor Phase Stop: one phase per invocation — never chain into the next lifecycle phase in the same run.
3. Print dual-line close with `Next: /agtoosa-next` when sequential mode applies.
4. Remind: *"Say `/agtoosa-next` again to advance to the next phase (or next backlog spec after ship)."*

## Relationship to Lifecycle Compass

- Freeform **sequential** intent ("next", "what's next", "continue the cycle") → route to **`/agtoosa-next`**, not a raw phase slash.
- Compass tributaries (explore, fix, track) may map through Next tributary intents when appropriate.
- Explicit `/agtoosa-next` bypasses Compass ceremony.

## Help handoff (`/agtoosa-help next`)

1. Run Step 0 routing (same as `dry`).
2. Output preview + rationale.
3. End with:

```text
To execute: /agtoosa-next
(This preview did not modify anything.)
```

## Output (dry / preview)

```text
AgToosa Next (dry) → /agtoosa-<command> (<story-id|none>) — <rationale>
SYNC: ...
Note: No workflow executed. Run `/agtoosa-next` to dispatch.
```

## Threat Model (STRIDE summary)

| Threat | Mitigation |
|--------|------------|
| Wrong phase dispatched | SYNC + `spec_approved` in route-hint JSON |
| Build before approval | Generator sets `next` to spec when not approved |
| Unclear what ran | Dispatch banner + SYNC before execution |
| Auto-chaining phases | Phase Stop: one command per invocation |
