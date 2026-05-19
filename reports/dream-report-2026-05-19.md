# AgToosa Dream Report — 2026-05-19

**Scope:** Last 7 days (2026-05-12 → 2026-05-19)
**Commits reviewed:** 6 (056d7c8 → 762f5d7)
**Versions shipped this window:** 4.2.0 (2026-05-13); no new releases since
**New since 05-18 report:** 1 commit (762f5d7 — dream report only; no code changes)

---

## What Improved

### Dream report cadence is consistent — five consecutive days
Reports have run 05-14, 05-16, 05-17, 05-18, and today (05-19). The diagnostic signal is reliable and precise; the execution gap is the only remaining friction.

### v4.2.0 template content remains internally consistent
All four template files carrying the v4.2.0 manual-task semantics (`SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, `Master-Plan.md`) are mutually consistent and accurately described in CHANGELOG. No documentation drift has been introduced since the release commit.

### Platform variant architecture is sound
The build and status platform variants (Claude, Cursor, Gemini, GitHub Copilot, Windsurf) correctly delegate to the canonical `Docs/AgToosa_Build.md` and `Docs/AgToosa_Status.md` by reference. The manual-task behavior propagates through those docs without requiring per-variant edits — the architecture held up under the v4.2.0 change.

---

## What Needs Attention

> **Escalation note — day 5.** All five issues below were first identified in the 05-14 dream report. No code fixes have landed across five consecutive days. CI has been failing every run since 4.2.0 shipped on 05-13. Items 1 and 2 are the sole blockers; Items 3–5 are additive. The total remediation time is ~20 minutes.

### 1. (DAY 5 — CI FAILING) `agtoosa.ps1` version stuck at `4.1.0`

`agtoosa.sh` line 13: `AGTOOSA_VERSION="4.2.0"` ✓  
`agtoosa.ps1` line 65: `$AGTOOSA_VERSION = "4.1.0"` ← stale by two releases

The bats version-parity test at `tests/agtoosa.bats:979` does an exact string comparison between the two files. It fails every run.

**Fix:**
```powershell
# agtoosa.ps1 line 65
$AGTOOSA_VERSION = "4.2.0"
```

### 2. (DAY 5 — CI FAILING) Three bats version pins stale at `4.1.0`

| File | Line | Stale assertion | Correct value |
|------|------|-----------------|---------------|
| `tests/agtoosa.bats` | 23 | `"AgToosa v4.1.0"` | `"AgToosa v4.2.0"` |
| `tests/agtoosa.bats` | 1161 | `"4.1.0"` | `"4.2.0"` |
| `tests/agtoosa.bats` | 1172 | `*"4.1.0"*` | `*"4.2.0"*` |

Line 20 carries the inline comment `# Update this expected string on each release` — skipped for 4.1.1 and again for 4.2.0.

### 3. (DAY 5) No bats coverage for v4.2.0 manual task behavior

4.2.0 shipped four template changes and zero tests. The D1–D3 block established the precedent. The complete `M1`–`M4` block is copy-paste ready:

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

Append after line 1269 of `tests/agtoosa.bats`. Validation: `bats tests/agtoosa.bats -f "M[1-4]"`.

### 4. (DAY 5) "Coming next (4.2.0)" section in `## [4.1.0]` CHANGELOG entry lists undelivered features

`CHANGELOG.md` lines 54–57 promise two features that did not ship in 4.2.0:

- AgToosa Status Guide sub-agent (read-only Auditor + Coach persona)
- `/agtoosa-help next` (context-aware next-move help)

`## [Unreleased]` is empty. These items belong there — a released entry with undelivered forward promises misrepresents project state.

**Fix:** Move both bullet points from `## [4.1.0] → ### Coming next (4.2.0)` into `## [Unreleased]`; remove the now-empty `### Coming next` subsection.

### 5. (DAY 5) README version badge and install snippet stale at `4.1.0`

| File | Line | Current | Correct |
|------|------|---------|---------|
| `README.md` | 8 | `version-4.1.0-green.svg` | `version-4.2.0-green.svg` |
| `README.md` | 52 | `--ref v4.1.0` | `--ref v4.2.0` |

The release checklist in `docs/agtoosa-maintainer.md` explicitly requires updating both on every release. Both were missed for 4.1.1 and again for 4.2.0.

---

## 3 Prioritized Action Items

### Priority 1 — Fix CI (version parity + stale pins) — ~5 min, unblocks everything

Five exact-string substitutions across three files. CI has been red for 6 days; nothing else matters while it is blocked.

**`agtoosa.ps1` line 65:**
```powershell
$AGTOOSA_VERSION = "4.2.0"
```

**`tests/agtoosa.bats` line 23:**
```bash
[[ "$output" == "AgToosa v4.2.0" ]]
```

**`tests/agtoosa.bats` line 1161:**
```bash
[ "$ver" = "4.2.0" ]
```

**`tests/agtoosa.bats` line 1172:**
```bash
[[ "$output" == *"4.2.0"* ]]
```

Validation: `bats tests/agtoosa.bats -f "version"` — all three version tests pass.

### Priority 2 — Add M1–M4 bats tests for v4.2.0 manual task behavior — ~10 min

Append the four-test block from Item 3 above after line 1269 of `tests/agtoosa.bats`. Closes the only coverage gap in v4.2.0 and follows D1–D3 precedent.

Validation: `bats tests/agtoosa.bats -f "M[1-4]"` — all four pass.

### Priority 3 — README + CHANGELOG housekeeping — ~5 min

1. `README.md` lines 8 and 52: `4.1.0` → `4.2.0`.
2. `CHANGELOG.md`: move the two undelivered "Coming next (4.2.0)" items from `## [4.1.0]` into `## [Unreleased]`; delete the vacated subsection.

Together, Priorities 1–3 take roughly 20 minutes and retire all five open findings.

---

*Generated by AgToosa maintainer review · 2026-05-19*
