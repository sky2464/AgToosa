# AgToosa Dream Report — 2026-05-20

**Scope:** Last 7 days (2026-05-13 → 2026-05-20)
**Commits reviewed:** 6 (c5c6e1a → d3b74d8 — all dream reports; zero code commits)
**Versions shipped this window:** none (latest release: 4.2.0 on 2026-05-13)
**New since 05-19 report:** 1 commit (d3b74d8 — dream report only; no code changes)

---

## What Improved

### Dream report cadence is consistent — six consecutive days
Reports have run 05-14, 05-16, 05-17, 05-18, 05-19, and today (05-20). The diagnostic signal has been reliable and precise throughout the window. No new defects were introduced in this period.

### v4.2.0 template content remains internally consistent
All four template files carrying the v4.2.0 manual-task semantics (`SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, `Master-Plan.md`) remain mutually consistent and accurately described in CHANGELOG. No documentation drift has been introduced since the release commit.

### Platform variant architecture held under v4.2.0 change
The build and status platform variants correctly delegate to canonical `Docs/AgToosa_Build.md` and `Docs/AgToosa_Status.md` by reference. Manual-task behavior propagates through those docs without per-variant edits.

---

## What Needs Attention

> **Escalation note — DAY 6.** All five issues below were first identified in the 05-14 dream report. Zero code fixes have landed across six consecutive days. CI has been failing on every run since 4.2.0 shipped on 05-13. Items 1 and 2 are the sole CI blockers. Total remediation time is ~20 minutes across all five items.

### 1. (DAY 6 — CI FAILING) `agtoosa.ps1` version stuck at `4.1.0`

`agtoosa.sh` line 13: `AGTOOSA_VERSION="4.2.0"` ✓
`agtoosa.ps1` line 65: `$AGTOOSA_VERSION = "4.1.0"` ← stale by two releases (missed 4.1.1 and 4.2.0)

The bats version-parity test at `tests/agtoosa.bats:979` does an exact string comparison between the two files. It fails on every CI run.

**One-line fix:**
```powershell
# agtoosa.ps1 line 65
$AGTOOSA_VERSION = "4.2.0"
```

### 2. (DAY 6 — CI FAILING) Three bats version pins stale at `4.1.0`

| File | Line | Stale assertion | Correct value |
|------|------|-----------------|---------------|
| `tests/agtoosa.bats` | 23 | `"AgToosa v4.1.0"` | `"AgToosa v4.2.0"` |
| `tests/agtoosa.bats` | 1161 | `"4.1.0"` | `"4.2.0"` |
| `tests/agtoosa.bats` | 1172 | `*"4.1.0"*` | `*"4.2.0"*` |

Line 20 carries the comment `# Update this expected string on each release` — skipped for both 4.1.1 and 4.2.0.

### 3. (DAY 6) No bats coverage for v4.2.0 manual task behavior

4.2.0 shipped four template changes and zero new tests. The only manual-related bats test is "declining copy shows manual copy instructions" at line 696, which tests a different behavior entirely. The D1–D3 precedent (added in 4.1.0) shows exactly how to cover a template doc feature. The complete M1–M4 block is ready to append after line 1269:

```bash
# ── 4.2.0 manual task support (M1 / M2 / M3 / M4) ────────────────────────────

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

Validation: `bats tests/agtoosa.bats -f "M[1-4]"` — all four pass immediately (the template content exists; only the tests are missing).

### 4. (DAY 6) Undelivered "Coming next (4.2.0)" features remain in a released CHANGELOG entry

`CHANGELOG.md` lines 54–57, inside `## [4.1.0]`, promise two features that did not ship in 4.2.0:

- AgToosa Status Guide sub-agent (read-only Auditor + Coach persona)
- `/agtoosa-help next` (context-aware next-move help)

`## [Unreleased]` is empty. A released entry with forward promises misrepresents project state and will mislead anyone reading the changelog to understand what is in scope.

**Fix:** Move both bullet points from `## [4.1.0] → ### Coming next (4.2.0)` into `## [Unreleased]`; delete the now-empty `### Coming next` subsection.

### 5. (DAY 6) README version badge and install snippet stale at `4.1.0`

| File | Line | Current | Correct |
|------|------|---------|---------|
| `README.md` | 8 | `version-4.1.0-green.svg` | `version-4.2.0-green.svg` |
| `README.md` | 52 | `--ref v4.1.0` | `--ref v4.2.0` |

`docs/agtoosa-maintainer.md` Release Checklist explicitly requires updating both on every release. Both were missed for 4.1.1 and again for 4.2.0.

---

## 3 Prioritized Action Items

### Priority 1 — Fix CI (version parity + stale pins) — ~5 min, unblocks everything

Four exact-string substitutions across two files. CI has been red for 7 days.

**`agtoosa.ps1` line 65** — change `"4.1.0"` to `"4.2.0"`:
```powershell
$AGTOOSA_VERSION = "4.2.0"
```

**`tests/agtoosa.bats` line 23** — change `v4.1.0` to `v4.2.0`:
```bash
[[ "$output" == "AgToosa v4.2.0" ]]
```

**`tests/agtoosa.bats` line 1161** — change `"4.1.0"` to `"4.2.0"`:
```bash
[ "$ver" = "4.2.0" ]
```

**`tests/agtoosa.bats` line 1172** — change `4.1.0` to `4.2.0`:
```bash
[[ "$output" == *"4.2.0"* ]]
```

Validation: `bats tests/agtoosa.bats -f "version"` — all three version tests pass green.

### Priority 2 — Add M1–M4 bats tests for v4.2.0 manual task behavior — ~10 min

Append the four-test block from Item 3 above after line 1269 of `tests/agtoosa.bats`. Closes the only coverage gap for v4.2.0 and follows D1–D3 precedent exactly. All four tests will pass immediately since the template content is already present.

Validation: `bats tests/agtoosa.bats -f "M[1-4]"` — all four pass.

### Priority 3 — README + CHANGELOG housekeeping — ~5 min

1. `README.md` lines 8 and 52: `4.1.0` → `4.2.0`.
2. `CHANGELOG.md`: move the two undelivered "Coming next (4.2.0)" items from `## [4.1.0]` into `## [Unreleased]`; delete the vacated `### Coming next (4.2.0)` subsection.

Together, Priorities 1–3 take roughly 20 minutes and retire all five open findings.

---

*Generated by AgToosa maintainer review · 2026-05-20*
