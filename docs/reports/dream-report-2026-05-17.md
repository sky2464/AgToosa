# AgToosa Dream Report — 2026-05-17

**Scope:** Last 7 days (2026-05-10 → 2026-05-17)
**Commits reviewed:** 16 (f5166cc → 499aa69)
**Versions shipped:** 4.0.0 → 4.1.0 → 4.1.1 (intermediate patch) → 4.2.0
**New since 05-16 report:** 1 commit (499aa69 — dream report only; no code changes)

---

## What Improved

### Dream reporting process is active
Consistent daily reporting (05-14, 05-16) is producing detailed, precise diagnostics. The 05-16 report correctly identified every open gap with line numbers, proposed bats test IDs (M1–M4), and concrete one-line fixes. The pattern is working — the bottleneck is now execution, not diagnosis.

### v4.2.0 manual task scaffolding is internally consistent
All four template files touched by 4.2.0 (`SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, `Master-Plan.md`) contain the `[manual]` / `[manual-deferred]` / `🔧 Awaiting Manual` semantics and they are mutually consistent. The health-score exemption logic, staleness relaxation, and counter format extension are all present and cross-referenced correctly. No documentation drift found between the four files.

### `lib/config.sh` registration complete for `/agtoosa-status`
All five platform variants of `/agtoosa-status` (Claude, Cursor, Gemini, GitHub, Windsurf) are registered in `lib/config.sh` and the files exist on disk. The parity loop in the D3 bats test covers them.

---

## What Needs Attention

> **Escalation note:** All five issues below were first identified in the 05-14 dream report. The 05-16 report confirmed all five remained open. This is day 3 with CI failing and no fix landed. Items 1 and 2 are blocking every CI run.

### 1. (DAY 3) Version parity broken — `agtoosa.ps1` stuck at `4.1.0` — CI FAILING

`agtoosa.sh` is at **4.2.0**. `agtoosa.ps1` line 65 is still at **`4.1.0`**. The bats version-parity test compares both files and fails. The gap spans two releases: 4.1.1 (041fcc0) and 4.2.0 (84b5969) both bumped `agtoosa.sh` without touching `agtoosa.ps1`.

**Fix:** `agtoosa.ps1` line 65: `"4.1.0"` → `"4.2.0"`

### 2. (DAY 3) Bats version pins stale at `4.1.0` — CI FAILING

Three exact-pin assertions still reference `4.1.0`:

| Line | Test | Stale string |
|------|------|--------------|
| 23 | `--version prints version string` | `"AgToosa v4.1.0"` |
| 1161 | `fresh install writes Docs/.agtoosa-version` | `"4.1.0"` |
| 1172 | `--update after fresh install shows real version` | `*"4.1.0"*` |

Line 20 carries the comment `# Update this expected string on each release` — this step was skipped for both 4.1.1 and 4.2.0.

**Fix:** Replace all three `4.1.0` strings with `4.2.0`.

### 3. (DAY 3) No bats coverage for v4.2.0 manual task behavior

4.2.0 shipped four template changes with no corresponding bats tests. The 4.1.0 precedent (D1–D3 block, 10 tests) set a clear bar. Proposed `M1`–`M4` block:

| ID | File | Key strings to assert |
|----|------|-----------------------|
| M1 | `template/Docs/SPEC-FORMAT.md` | `[manual]`, `[manual-deferred`, `Awaiting Manual` |
| M2 | `template/Docs/AgToosa_Build.md` | `Manual Task Detection`, `mark done, defer` |
| M3 | `template/Docs/AgToosa_Status.md` | `manual-deferred`, `Awaiting Manual` |
| M4 | `template/Docs/Master-Plan.md` | `Manual / Deferred` |

```bash
# ── 4.2.0 manual task support (M1 / M2 / M3 / M4) ─────────────────────────

@test "M1: SPEC-FORMAT.md documents [manual] annotation lifecycle" {
  local f="$TEMPLATE_DIR/Docs/SPEC-FORMAT.md"
  grep -q '\[manual\]' "$f"
  grep -q '\[manual-deferred' "$f"
  grep -q 'Awaiting Manual' "$f"
}

@test "M2: AgToosa_Build.md contains Manual Task Detection gate" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Build.md"
  grep -q 'Manual Task Detection' "$f"
  grep -q 'mark done, defer' "$f"
}

@test "M3: AgToosa_Status.md exempts manual-deferred from health score" {
  local f="$TEMPLATE_DIR/Docs/AgToosa_Status.md"
  grep -q 'manual-deferred' "$f"
  grep -q 'Awaiting Manual' "$f"
}

@test "M4: Master-Plan.md template contains Manual / Deferred section" {
  grep -q 'Manual / Deferred' "$TEMPLATE_DIR/Docs/Master-Plan.md"
}
```

Verification: `bats tests/agtoosa.bats -f "M1\|M2\|M3\|M4"` — all four must pass.

### 4. (DAY 3) "Coming next (4.2.0)" promises in CHANGELOG undelivered

The `## [4.1.0]` block's `### Coming next (4.2.0)` subsection listed two features that did not ship in 4.2.0:

- **AgToosa Status Guide sub-agent** — read-only Auditor + Coach persona
- **`/agtoosa-help next`** — context-aware next-move help

The `## [Unreleased]` section remains empty. These items should be moved there so the backlog is visible and the released 4.1.0 entry no longer promises undelivered work.

### 5. (DAY 3) README version badge and install snippet stale at `4.1.0`

`README.md` line 8: `version-4.1.0-green.svg`
`README.md` line 52: `--ref v4.1.0`

Both should read `4.2.0`. The release checklist in `docs/agtoosa-maintainer.md` explicitly requires updating these on every release — this step was skipped.

---

## 3 Prioritized Action Items

### Priority 1 — Fix version parity and stale bats pins (unblocks CI, ~5 min)

Five exact-string changes across three files. CI is blocked until these land.

**`agtoosa.ps1` line 65:**
```
$AGTOOSA_VERSION = "4.2.0"
```

**`tests/agtoosa.bats` line 23:**
```
[[ "$output" == "AgToosa v4.2.0" ]]
```

**`tests/agtoosa.bats` line 1161:**
```
[ "$ver" = "4.2.0" ]
```

**`tests/agtoosa.bats` line 1172:**
```
[[ "$output" == *"4.2.0"* ]]
```

**`README.md` line 8:**
```
[![Version](https://img.shields.io/badge/version-4.2.0-green.svg)]...
```

**`README.md` line 52:**
```
bash <(curl -fsSL .../bootstrap.sh) --ref v4.2.0
```

Validation: `bats tests/agtoosa.bats -f "version"` — all three version tests green.

### Priority 2 — Add M1–M4 bats tests for v4.2.0 manual task behavior (~10 min)

Append the four-test `M1`–`M4` block (see Issue 3 above) after the `D3` section in `tests/agtoosa.bats` (after line 1269). Verify: `bats tests/agtoosa.bats -f "M1\|M2\|M3\|M4"`.

This closes the coverage gap left by 4.2.0 and follows the D1–D3 precedent established in 4.1.0.

### Priority 3 — Clean up CHANGELOG forward-looking section (~5 min)

1. Move the two undelivered "Coming next (4.2.0)" items from `## [4.1.0]` into `## [Unreleased]` so they appear as planned work rather than as broken promises in a released entry.
2. Add a minimal `## [4.1.1] — 2026-05-12` tombstone noting it was an unreleased intermediate patch (Master-Plan doc refinement only) that was superseded by 4.2.0 — this closes the `git log` / CHANGELOG divergence.

---

*Generated by AgToosa maintainer review · 2026-05-17*
