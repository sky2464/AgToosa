# AgToosa Dream Report — 2026-05-18

**Scope:** Last 7 days (2026-05-11 → 2026-05-18)
**Commits reviewed:** 17 (9522e59 → 6cf9e72)
**Versions shipped:** 4.0.0 → 4.1.0 → 4.1.1 → 4.2.0
**New since 05-17 report:** 1 commit (6cf9e72 — dream report only; no code changes)

---

## What Improved

### Reporting cadence is fully established
Dream reports have now run four consecutive days (05-14, 05-16, 05-17, 05-18). The 05-17 report was the most precise yet — exact line numbers, copy-ready bats snippets, and a tight five-fix sequence. The diagnostic mechanism is healthy; the execution gap is the only remaining friction.

### v4.2.0 template content is internally consistent
All four template files carrying the v4.2.0 manual-task semantics (`SPEC-FORMAT.md`, `AgToosa_Build.md`, `AgToosa_Status.md`, `Master-Plan.md`) remain mutually consistent. No documentation drift has been introduced. The CHANGELOG entry for 4.2.0 is comprehensive and accurate.

### Test infrastructure is solid at 155 tests
`tests/agtoosa.bats` grew from ~130 tests at 4.0.0 to 155 today, covering D1–D3 parity loops, version-parity check, platform-variant matrix assertions, and the typo-helper guard. The foundation is strong; what's missing is additive, not structural.

---

## What Needs Attention

> **Escalation note — day 4.** All five issues below were first identified in the 05-14 dream report and have been re-confirmed every day since. No code fixes have landed. CI has been failing for four consecutive days. Items 1 and 2 are blocking every CI run. The window for a "quick five-minute fix" is narrowing — the longer these stay open, the more likely an interleaving commit will conflict.

### 1. (DAY 4 — CI FAILING) Version parity broken — `agtoosa.ps1` stuck at `4.1.0`

`agtoosa.sh` line 13: `AGTOOSA_VERSION="4.2.0"`
`agtoosa.ps1` line 65: `$AGTOOSA_VERSION = "4.1.0"` ← stale by two releases (4.1.1, 4.2.0)

The bats version-parity test (`tests/agtoosa.bats:979`) does an exact string comparison. It fails every run.

**One-line fix:**
```
agtoosa.ps1 line 65:  "4.1.0"  →  "4.2.0"
```

### 2. (DAY 4 — CI FAILING) Three bats version pins stale at `4.1.0`

| Line | Test description | Stale assertion |
|------|-----------------|-----------------|
| 23 | `--version prints version string` | `"AgToosa v4.1.0"` |
| 1161 | `fresh install writes Docs/.agtoosa-version` | `"4.1.0"` |
| 1172 | `--update after fresh install shows real version` | `*"4.1.0"*` |

Line 20 carries the inline comment `# Update this expected string on each release` — this instruction was skipped for both 4.1.1 and 4.2.0.

**Three-line fix:** replace all three `4.1.0` strings in `tests/agtoosa.bats` with `4.2.0`.

### 3. (DAY 4) No bats coverage for v4.2.0 manual task behavior

4.2.0 shipped four template changes and zero tests. The D1–D3 block established the pattern for spec-driven test coverage. The `M1`–`M4` block below is complete and ready to paste:

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

Append after the final `@test` block (currently line 1269). Verification: `bats tests/agtoosa.bats -f "M[1-4]"`.

### 4. (DAY 4) "Coming next (4.2.0)" promises in `## [4.1.0]` CHANGELOG entry undelivered

The `## [4.1.0]` block's `### Coming next (4.2.0)` subsection lists two features that did not ship:

- **AgToosa Status Guide sub-agent** (read-only Auditor + Coach persona)
- **`/agtoosa-help next`** (context-aware next-move help)

The `## [Unreleased]` section at the top of CHANGELOG.md is empty. These items should migrate there — leaving forward promises in a released changelog entry creates a false impression that 4.2.0 is incomplete.

### 5. (DAY 4) README version badge and install snippet stale at `4.1.0`

`README.md` line 8: `version-4.1.0-green.svg`
`README.md` line 52: `--ref v4.1.0`

The release checklist in `docs/agtoosa-maintainer.md` explicitly requires updating both on every release. Both were missed for 4.1.1 and 4.2.0.

---

## 3 Prioritized Action Items

### Priority 1 — Fix CI (version parity + stale pins) — ~5 min, unblocks everything

Five exact-string changes across three files. Do these first; nothing else matters while CI is red.

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

Validation: `bats tests/agtoosa.bats -f "version"` — all three version tests green.

### Priority 2 — Add M1–M4 bats tests for v4.2.0 manual task behavior — ~10 min

Append the four-test block above after line 1269 of `tests/agtoosa.bats`. This closes the only coverage gap in v4.2.0 and follows the D1–D3 precedent from v4.1.0.

Validation: `bats tests/agtoosa.bats -f "M[1-4]"` — all four pass.

### Priority 3 — README + CHANGELOG housekeeping — ~5 min

1. `README.md` lines 8 and 52: `4.1.0` → `4.2.0`.
2. `CHANGELOG.md`: move the two undelivered "Coming next (4.2.0)" items from `## [4.1.0]` into `## [Unreleased]`.

Together, Priorities 1–3 take roughly 20 minutes and retire all five open findings.

---

*Generated by AgToosa maintainer review · 2026-05-18*
