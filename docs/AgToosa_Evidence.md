# AgToosa /agtoosa-evidence Workflow

## Sub-Commands

| Sub-command | Runs |
|-------------|------|
| `/agtoosa-evidence` | Create or update the per-story evidence ledger from current test-plan / review / ship artifacts |
| `/agtoosa-evidence review` | Review-phase update only (called from `/agtoosa-review`) |
| `/agtoosa-evidence ship` | Ship-phase finalize only (called from `/agtoosa-ship`) |

## Objective

Maintain a **per-story evidence ledger** — a concise, auditable proof index for files, tests, logs, PRs, screenshots, and review notes — so every shipped story has a durable trail without a hosted audit service.

> **Prerequisites:** Active story with approved spec. Prefer existing RED/GREEN/IMPORT evidence in the story test plan and the review report path.
>
> **Claim Boundary:** This workflow is **agent-instructed** (not generator-enforced). Verifier WARN/FAIL for missing ledgers is **roadmap**. The optional JSONL mirror is **non-authoritative**.
>
> **Source of truth:** `docs/Master-Plan.md` remains the repo-local source of truth. The markdown ledger is the canonical index; `docs/agtoosa-evidence.jsonl` is an optional tooling mirror.

## When to update

| Gate | Action |
|------|--------|
| `/agtoosa-review` | Create or update `docs/archived/evidence-[story-id].md` with `phase=review` rows |
| `/agtoosa-ship` | Finalize the same file with `phase=ship` rows before marking Shipped |
| `/agtoosa-build` / `/agtoosa-import` | Do **not** write the ledger live — keep writing test-plan / IMPORT evidence; consolidate at review/ship |

## Markdown schema (canonical)

Write to `docs/archived/evidence-[story-id].md` (sanitize story-id to `[A-Za-z0-9._-]+`):

```markdown
# Evidence Ledger — [Story ID]

> **Story:** [ID] — [title]
> **Claim Boundary:** agent-instructed index; Master-Plan remains SoT
> **Updated:** [YYYY-MM-DD HH:MM] ([review|ship])

| Phase | AC | Artifact | Pointer | Verification | Exit | Reviewer | ts |
|-------|----|----------|---------|--------------|------|----------|-----|
| review | AC-001 | test-log | docs/AgToosa_TestPlan-….md#GREEN | bats … -f "…" | 0 | AgToosa | ISO-8601 |
```

**Required columns:** Phase (`review` \| `ship`), AC, Artifact, Pointer, Verification, Exit, Reviewer, ts.

**Artifact types:** `test-log` · `review` · `pr` · `branch` · `screenshot` · `spec` · `verifier` · `other`

## Optional JSONL mirror (non-authoritative)

When useful, append one JSON object per new ledger row to `docs/agtoosa-evidence.jsonl`:

```json
{"ts":"ISO-8601","story":"DEV-049","phase":"review","ac":["AC-001"],"artifact":"test-log","pointer":"…","verification":"…","exit":0,"reviewer":"AgToosa"}
```

Never treat JSONL as overriding the markdown file.

## Workflow

1. **Resolve story** — Active Cycle ID; if multiple, ask which.
2. **Collect pointers** — From story test plan (RED/GREEN/IMPORT), review report path, verifier/smoke commands.
3. **Write/update markdown** — Merge rows; do not delete prior review rows when shipping.
4. **Optional JSONL** — Append new rows only.
5. **Secret safety** — Cite paths and command names only; **redact** tokens, API keys, passwords, private URLs.
6. **Phase event** — Append to `docs/agtoosa-events.jsonl`:
   `{"ts":"[ISO-8601 UTC]","phase":"evidence","event":"update","story":"[Story ID]","by":"AgToosa"}`

## Output

* Print the evidence file path and row count.
* Print verbatim: `✅ Done. Run /agtoosa-status to verify findings cleared.`

## Rules

1. **Markdown is canonical.** JSONL is optional and non-authoritative.
2. **Honest claims.** Never describe the ledger as generator-enforced or CI-enforced in v1.
3. **No hosted audit log.** Repo-local files only.
4. **Consolidate at review/ship** — not during build/import.
5. **Secret safety** — paths/process only; sanitize story-id in filenames.
