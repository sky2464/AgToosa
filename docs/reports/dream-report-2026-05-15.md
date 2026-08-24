# AgToosa Dream Report — 2026-05-15

**Scope:** Last 7 days (2026-05-08 → 2026-05-15)
**Commits reviewed:** 14 (f5166cc → c5c6e1a)
**Versions shipped:** 4.0.0 → 4.1.0 → 4.2.0
**Continuity:** Builds on 2026-05-14 report; all three priority items from that report remain unresolved.

---

## What Improved

### Manual task lifecycle — thorough cross-file consistency

The 4.2.0 manual task feature (commit 056d7c8) is well-specified and internally consistent across all four affected template files. `SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, and `Master-Plan.md` all agree on:
- The annotation lifecycle: `[manual]` → `[manual-deferred: YYYY-MM-DD]` → `[manual-done]`
- The `🔧 Awaiting Manual` status key and its non-blocking semantics
- Health score exemption: manual/deferred tasks are excluded from task-counter mismatch and staleness deductions
- The relaxed staleness thresholds (7 d → 30 d warning, 30 d → 90 d error) when all active stories are awaiting manual steps

No contradictions found between the four files. The CHANGELOG `## [4.2.0]` "Files updated" list accurately matches what was changed.

### /agtoosa-status launch — platform parity and test coverage (4.1.0)

The 78d5001 commit remains the strongest addition this week: 55 files changed, all 5 platform variants wired, the 3-vs-5 init/help asymmetry encoded in both maintainer docs and bats tests (D1, D2, D3), and the status command registered in `lib/config.sh`. No regressions found in platform file inventory.

### Dream report baseline established

Yesterday's report (2026-05-14) produced a full gap inventory with exact file names and line numbers. That document now serves as a concrete backlog — no new discoveries were buried in the same week's churn.

---

## What Needs Attention

### 1. Version parity still broken — `agtoosa.ps1` stuck at 4.1.0 (second day)

`agtoosa.sh` is at **4.2.0** (`lib/version.sh` AGTOOSA_VERSION=4.2.0); `agtoosa.ps1` is at **4.1.0** (line 65). The bats version-parity test compares both and will fail on every CI run. This has been unfixed for two days.

### 2. Bats version pins still at 4.1.0 (second day)

Three assertions in `tests/agtoosa.bats` reference the old version string:

| Line | Test | Stale assertion |
|------|------|-----------------|
| 23 | `--version prints version string` | `"AgToosa v4.1.0"` |
| 1161 | `fresh install writes Docs/.agtoosa-version` | `"4.1.0"` |
| 1172 | `--update after fresh install shows real version` | `*"4.1.0"*` |

The comment on line 20 (`# Update this expected string on each release`) confirms these are manual release-step artifacts, not intentional pin values.

### 3. README version badge and pinned install snippet not bumped to 4.2.0

The release checklist in `docs/agtoosa-maintainer.md` requires: *"Update README.md version badge AND any pinned --ref vX.Y.Z install snippets."* Both are still at 4.1.0:

- Line 8: `[![Version](https://img.shields.io/badge/version-4.1.0-green.svg)...]`
- Line 52: `bash <(curl -fsSL .../bootstrap.sh) --ref v4.1.0`

This was also missed at 4.1.0 (the 4.1.0 CHANGELOG notes the badge was bumped *from 3.1.0*, not from a prior release — meaning it wasn't bumped at 4.0.0 either). The pattern of missing README bumps is now two releases old.

### 4. No bats coverage for 4.2.0 manual task behavior (second day)

The manual task feature introduced substantial template behavior — Manual Task Detection gate in Build, Awaiting Manual story state, Manual/Deferred dashboard section, health score exemptions — with zero new bats tests. The D1–D3 precedent from 4.1.0 establishes the pattern. Missing targeted assertions:

- **M1:** `SPEC-FORMAT.md` contains `[manual]`, `[manual-deferred`, `Awaiting Manual`
- **M2:** `AgToosa_Build.md` contains `Manual Task Detection` gate string
- **M3:** `AgToosa_Status.md` contains manual exemption text and `Manual / Deferred` section heading
- **M4:** `Master-Plan.md` template contains `Manual / Deferred` section and `🔧 Awaiting Manual` in status key

### 5. "Coming next (4.2.0)" features were not shipped and are now untracked

The 4.1.0 CHANGELOG lists two planned features under `### Coming next (4.2.0)`:
- AgToosa Status Guide sub-agent (Auditor + Coach persona)
- `/agtoosa-help next` (context-aware next-move help)

Neither appeared in 4.2.0 and neither is in `## [Unreleased]`. They exist only in the 4.1.0 historical section. Without moving them to `## [Unreleased]` or `TODOS.md`, they will be silently forgotten when someone reads the CHANGELOG forward from 4.2.0.

### 6. CHANGELOG 4.1.1 gap (second day)

`agtoosa.sh` was bumped to 4.1.1 in commit 041fcc0 with no CHANGELOG entry and no `agtoosa.ps1` bump. The CHANGELOG jumps 4.1.0 → 4.2.0 with a gap. Either a minimal backfill entry or an explicit "subsumed by 4.2.0" note is needed.

---

## 3 Prioritized Action Items

### Priority 1 — Fix all release-checklist gaps for v4.2.0 (CI broken; user-facing drift)

Four items from the v4.2.0 release checklist were skipped. Fix them together in one commit:

1. **`agtoosa.ps1` line 65:** `$AGTOOSA_VERSION = "4.1.0"` → `"4.2.0"`
2. **`tests/agtoosa.bats` line 23:** `"AgToosa v4.1.0"` → `"AgToosa v4.2.0"`
3. **`tests/agtoosa.bats` lines 1161, 1172:** `"4.1.0"` / `"4.1.0"` → `"4.2.0"` each
4. **`README.md` line 8:** badge `version-4.1.0` → `version-4.2.0`
5. **`README.md` line 52:** `--ref v4.1.0` → `--ref v4.2.0`

Verification:
```bash
bash agtoosa.sh --version          # must print: AgToosa v4.2.0
bats tests/agtoosa.bats -f "version"
```

### Priority 2 — Add bats M1–M4 tests for 4.2.0 manual task behavior

Add a `# ── 4.2.0 manual task support (M1 / M2 / M3 / M4) ──` block immediately after the D3 block in `tests/agtoosa.bats`:

```bash
@test "M1: SPEC-FORMAT.md documents [manual] annotation lifecycle and Awaiting Manual status" {
  grep -q '\[manual\]' "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
  grep -q '\[manual-deferred' "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
  grep -q 'Awaiting Manual' "$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
}

@test "M2: AgToosa_Build.md contains Manual Task Detection gate" {
  grep -q 'Manual Task Detection' "$TEMPLATE_DIR/Docs/AgToosa_Build.md"
}

@test "M3: AgToosa_Status.md contains manual exemption and Manual / Deferred section" {
  grep -q 'manual-deferred' "$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q 'Manual / Deferred' "$TEMPLATE_DIR/Docs/AgToosa_Status.md"
}

@test "M4: Master-Plan.md template contains Manual / Deferred section and Awaiting Manual status key" {
  grep -q 'Manual / Deferred' "$TEMPLATE_DIR/Docs/Master-Plan.md"
  grep -q 'Awaiting Manual' "$TEMPLATE_DIR/Docs/Master-Plan.md"
}
```

Verification: `bats tests/agtoosa.bats -f "M1\|M2\|M3\|M4"`

### Priority 3 — Clean up CHANGELOG history and forward-looking commitments

Two targeted edits:

1. **Move unshipped planned features to `## [Unreleased]`.** The Status Guide sub-agent and `/agtoosa-help next` were promised in "Coming next (4.2.0)" but not delivered. Add them to `## [Unreleased]` so they appear in the forward view:
   ```markdown
   ## [Unreleased]

   ### Planned
   - AgToosa Status Guide sub-agent — Auditor + Coach persona …
   - `/agtoosa-help next` — context-aware help based on fresh status read.
   ```

2. **Resolve the 4.1.1 ghost.** Add a one-line note under `## [4.2.0]` or create a minimal `## [4.1.1] — 2026-05-12` entry noting the Master-Plan documentation refinement. Either is acceptable; pick the one that best reflects the intent of 041fcc0.

---

*Generated by AgToosa maintainer review · 2026-05-15*
