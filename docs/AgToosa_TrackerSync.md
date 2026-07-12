# AgToosa Tracker Sync — Export and Proposal Bridge

Mirror AgToosa story state into external trackers **without** surrendering `docs/Master-Plan.md` authority. v1 is **one-way export** plus **proposal-only import** — not live API synchronization.

> **Authority:** `docs/Master-Plan.md` wins every conflict. External trackers are optional mirrors created only when the user explicitly asks. AgToosa does not call provider APIs in v1.

---

## Quick Start

**Export current story state (neutral JSON envelope):**
```bash
bash agtoosa.sh --tracker export --path /path/to/project --output /tmp/tracker-export.json
```

**Turn a returned tracker envelope into a reviewable proposal (no repo mutation):**
```bash
bash agtoosa.sh --tracker propose --path /path/to/project \
  --input /path/to/tracker-return.json \
  --output /tmp/tracker-proposal.md
```

PowerShell (delegates to Bash — Git Bash or WSL required):
```powershell
.\agtoosa.ps1 -Tracker -TrackerCommand export -Path C:\Projects\MyApp -TrackerOutput $env:TEMP\export.json
```

Run `/agtoosa-tracker export` or `/agtoosa-tracker propose` in your AI assistant for the full workflow. Substantive rules live in this document; platform adapters delegate here.

---

## Workflow: `/agtoosa-tracker export`

1. Confirm the user wants a tracker mirror (not a replacement for Master-Plan).
2. Resolve the project path (explicit `--path` or current repo root).
3. Run the local export command — **no network calls**.
4. The bridge reads `docs/Master-Plan.md` and only spec files referenced by exported stories.
5. Stories are normalized and sorted by stable story ID; volatile fields (e.g. `generated_at`) are excluded from the export ID digest.
6. Write the `agtoosa.tracker-bridge/v1` JSON envelope to the explicit `--output` path.
7. Tell the user how to transport the envelope (manual upload, provider adapter, or MCP tool **outside** AgToosa).

**Export envelope fields (summary):** `schema_version`, `export_id`, `generated_at`, `repository`, `source` (commit + `master_plan_sha256`), `stories[]` with `story_id`, `title`, `epic`, `status`, `estimate`, `spec_path`, `acceptance_criteria`.

Full schema: `docs/agtoosa-tracker-sync.schema.json`.

---

## Workflow: `/agtoosa-tracker propose`

1. Require a return envelope that references a prior export (`base_export_id`).
2. Validate schema, story IDs, allowed fields, secret safety, and current `Master-Plan.md` digest.
3. For each change, compare **repo value** (authoritative) vs **proposed value** (external).
4. Write a Markdown proposal artifact to `--output` with disposition per item: `proposed`, `unchanged`, `stale`, `unsupported`, or `rejected`.
5. **Never** modify `docs/Master-Plan.md`, specs, or task checkboxes during propose.
6. Route accepted changes through existing AgToosa workflows (see **Proposal acceptance** below).

---

## Proposal acceptance

Accepted proposals **do not** auto-apply. Use one of:

| Change type | Route |
|-------------|-------|
| Status, estimate, backlog row, task checkbox | `/agtoosa-task` or explicit human edit to `docs/Master-Plan.md` |
| Spec content, ACs, design | `/agtoosa-spec amend` |
| New story | `/agtoosa-spec` (new story) |

After applying accepted changes, run a **fresh export** before the next tracker snapshot. External state never overwrites the repo implicitly.

---

## Provider field mappings (v1)

AgToosa defines **translation guidance only**. Transport and provider-side create/update/delete are **manual or provider-enforced** — not performed by the core bridge.

### GitHub Issues (first validated adapter)

| AgToosa field | GitHub Issues | Unsupported behavior |
|---------------|---------------|----------------------|
| `story_id` | Issue title prefix or label `agtoosa:DEV-XXX` | Store in `external_ref`; warn if label missing |
| `title` | Issue title (after ID prefix) | — |
| `status` | Open / closed + optional `status:` labels | Map 🟦 Todo→open, 🟨 In Progress→open+label, ✅ Done→closed; unmapped → `unsupported` |
| `estimate` | Issue body field or `estimate:` label | S/M/L/XL only; provider-only sizes → `unmapped` |
| `epic` | Milestone or `epic:` label | — |
| `spec_path` | Issue body link | — |
| `acceptance_criteria` | Issue body checklist (read-only mirror) | No AC round-trip in v1 |

### Linear

| AgToosa field | Linear | Unsupported behavior |
|---------------|--------|----------------------|
| `story_id` | Issue identifier suffix or custom label | — |
| `title` | Issue title | — |
| `status` | Workflow state (Backlog, In Progress, Done, …) | Unmapped states → `unsupported` |
| `estimate` | Estimate points or t-shirt label | Non-numeric estimates → `unmapped` |
| `epic` | Project or cycle | — |
| `spec_path` | Description link | — |
| `acceptance_criteria` | Description section | No comment round-trip in v1 |

### Jira

| AgToosa field | Jira | Unsupported behavior |
|---------------|------|----------------------|
| `story_id` | Issue key suffix or label | — |
| `title` | Summary | — |
| `status` | Status (To Do, In Progress, Done, …) | Custom workflows → map or `unsupported` |
| `estimate` | Story points or original estimate | — |
| `epic` | Epic link | — |
| `spec_path` | Description link | — |
| `acceptance_criteria` | Description or custom field | Custom fields not auto-synced |

### TaskMaster

| AgToosa field | TaskMaster | Unsupported behavior |
|---------------|------------|----------------------|
| `story_id` | Task `id` | — |
| `title` | Task `title` | — |
| `status` | `pending` / `in-progress` / `done` | Other statuses → `unsupported` |
| `estimate` | `metadata.estimate` or priority | — |
| `epic` | `metadata.epic` or parent task | — |
| `spec_path` | `metadata.spec_path` | — |
| `acceptance_criteria` | `details` checklist | No dependency round-trip in v1 |

When a provider field has no AgToosa equivalent, preserve the original value in proposal diagnostics as `unmapped` and leave repo state unchanged.

---

## Claim Boundary (v1)

| Surface | Classification | Boundary |
|---------|----------------|----------|
| Schema validation, digest, mutation refusal | generator-enforced | Local files only |
| `/agtoosa-tracker export` and `propose` workflow | agent-instructed | This document is canonical |
| Provider field mapping tables | agent-instructed | Translation guidance, not API guarantee |
| Transporting envelopes to/from trackers | manual / provider-enforced | Human, provider tool, or authorized integration |
| Accepting a proposal | manual authorization | `/agtoosa-task`, `/agtoosa-spec amend`, or explicit edit |
| Live API sync, webhooks, polling | **not in v1** | Do not claim two-way sync |
| `docs/Master-Plan.md` | repo-local source of truth | Wins every tracker conflict |

**v1 does not:**

- Call GitHub, Linear, Jira, or TaskMaster APIs
- Store OAuth tokens or API credentials
- Auto-create, update, or delete external issues
- Apply returned status or title changes without human approval

---

## Security

- Treat every return envelope as **untrusted input**.
- Redact or reject credentials, token-bearing URLs, absolute local paths, and control characters.
- Bound file size and record count before parsing oversized returns.
- Proposal output must not alias `docs/Master-Plan.md` or other source files.

---

## Related

- **PM source of truth:** `docs/Master-Plan.md`
- **Fast backlog edits:** `docs/AgToosa_Task.md`
- **Spec amendments:** `docs/AgToosa_Spec.md` (`amend` sub-command)
- **Envelope schema:** `docs/agtoosa-tracker-sync.schema.json`
