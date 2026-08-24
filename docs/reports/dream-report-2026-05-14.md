# AgToosa Dream Report — 2026-05-14

**Scope:** Last 7 days (2026-05-07 → 2026-05-14)
**Commits reviewed:** 13 (3bbbb37 → 84b5969)
**Versions shipped:** 4.0.0 → 4.1.0 → 4.2.0 (plus unreleased 4.1.1 patch)

---

## What Improved

### v4.0.0 — Kiro-style spec format
SPEC-FORMAT.md landed as the canonical single-file spec reference, with EARS acceptance criteria, a hierarchical checkbox task tree, Wave Plan subsection, and progress bar tracking in Master-Plan.md. The `AgToosa_Spec.md` and `AgToosa_Build.md` docs were updated consistently. `lib/config.sh` correctly registers the new file in `DOCS_FILES`. Bats coverage (commit 9522e59) added version-pin updates and Master-Plan template assertions.

### v4.1.0 — Status guidance loop
The deterministic "Recommended Next Actions" algorithm (Part 5.5), aging escalation prefix, sub-command typo helper, and universal closure line (`✅ Done. Run /agtoosa-status to verify findings cleared.`) were added across all relevant platform variants. The per-platform asymmetry for `init`/`help` (3 variants, not 5) is correctly encoded in both the maintainer guide and new bats parity tests (D1, D2, D3). This is the most complete and well-tested release in the recent batch.

### v4.2.0 — Manual task support
Tasks tagged `[manual]` now have a proper lifecycle: `[manual]` → `[manual-deferred: YYYY-MM-DD]` → `[manual-done]`. The build cycle prompts the user (mark done / defer / show-then-defer) without blocking. The `🔧 Awaiting Manual` story state is correctly treated as non-blocking by `/agtoosa-status` — excluded from health score deductions and staleness thresholds. All four file types in the CHANGELOG "Files updated" list were verified to contain the new behavior.

### Overall process hygiene
- `[Unreleased]` section is clean (no floating changes).
- Platform file wiring for the new `/agtoosa-status` command was landed across all 5 variants and registered in `lib/config.sh` in a single commit (78d5001).
- Security: symlink path-traversal fix for `validate_pack_files` (v3.4.1) is covered by a bats test at line 1122.

---

## What Needs Attention

### 1. Version parity broken — `agtoosa.ps1` stuck at `4.1.0`

`agtoosa.sh` is at **4.2.0**. `agtoosa.ps1` is still at **4.1.0**. The release checklist requires identical values in both files, and the bats version-parity test will fail:

```
@test "version parity: agtoosa.sh and agtoosa.ps1 report same version" {
  # agtoosa.sh → 4.2.0   agtoosa.ps1 → 4.1.0   → FAIL
```

The gap spans **two** releases: `agtoosa.ps1` was not bumped at 4.1.1 either (commit 041fcc0 bumped `agtoosa.sh` to 4.1.1 but not `agtoosa.ps1`). Since 4.1.1 has no CHANGELOG entry and appears to have been folded into 4.2.0, a single bump of `agtoosa.ps1` to `4.2.0` is the correct fix.

### 2. Bats version pins not updated for 4.2.0

Three exact-version pin assertions in `tests/agtoosa.bats` still reference `4.1.0`:

| Line | Test | Expected | Actual |
|------|------|----------|--------|
| 23 | `--version prints version string` | `AgToosa v4.1.0` | `AgToosa v4.2.0` |
| 1161 | `fresh install writes Docs/.agtoosa-version` | `4.1.0` | `4.2.0` |
| 1172 | `--update after fresh install shows real version` | `*"4.1.0"*` | `*"4.2.0"*` |

These three tests will fail on every CI run until updated. The comment on line 20 (`# Update this expected string on each release`) confirms this is a known manual step that was skipped.

### 3. No bats coverage for v4.2.0 manual task behavior

The 4.2.0 release introduced substantial new template behavior (manual task detection gate, `🔧 Awaiting Manual` transition, Manual/Deferred table in status dashboard) with **zero new bats tests**. Comparable template behavior in 4.1.0 received 10 targeted parity tests (D1–D3). The maintainer guide's operating rule applies: *"If you change generator behavior, update or add targeted bats coverage."*

Missing test assertions include:
- `SPEC-FORMAT.md` contains `[manual]` annotation rules and `🔧 Awaiting Manual` status key.
- `AgToosa_Build.md` contains the Manual Task Detection gate string.
- `AgToosa_Status.md` contains manual exemption language and the Manual/Deferred dashboard section.
- `Master-Plan.md` template contains the Manual/Deferred Tasks section.

### 4. Missing `## [4.1.1]` block in CHANGELOG.md

Commit 041fcc0 bumped `agtoosa.sh` to `4.1.1` with message "chore: update version to 4.1.1 and refine Master-Plan documentation", but:
- No `## [4.1.1]` entry exists in `CHANGELOG.md`.
- `agtoosa.ps1` was not bumped at that commit.
- The version was then superseded by 4.2.0.

The current CHANGELOG jumps `4.1.0 → 4.2.0`, obscuring the intermediate patch. Either backfill a minimal `[4.1.1]` entry (if the Master-Plan refinement was a meaningful fix) or document in 4.2.0's notes that 4.1.1 was an unreleased intermediate. Either way, the gap makes `git log` and CHANGELOG diverge for anyone tracing the history.

---

## 3 Prioritized Action Items

### Priority 1 — Fix version parity and stale bats pins (CI is currently broken)

Bump `agtoosa.ps1` from `4.1.0` → `4.2.0` and update the three bats version pins. The version-parity bats test and `--version` test are failing on every CI run right now. This is a one-liner fix in two files.

Files: `agtoosa.ps1` line 65, `tests/agtoosa.bats` lines 23, 1161, 1172.

```bash
# Verification
bash agtoosa.sh --version     # must print: AgToosa v4.2.0
bats tests/agtoosa.bats -f "version"
```

### Priority 2 — Add bats parity tests for v4.2.0 manual task behavior

Add a `# ── 4.2.0 manual task support (M1 / M2 / M3 / M4) ──` block to `tests/agtoosa.bats` covering the key strings introduced by 4.2.0:

- **M1:** `SPEC-FORMAT.md` contains `[manual]` annotation rules (`\[manual\]`, `\[manual-deferred`, `Awaiting Manual`).
- **M2:** `AgToosa_Build.md` contains the Manual Task Detection gate (`Manual Task Detection`, `mark done, defer`).
- **M3:** `AgToosa_Status.md` contains manual exemption (`manual-deferred.*excluded`, `Awaiting Manual.*non-blocking` or equivalent strings).
- **M4:** `Master-Plan.md` template contains the `Manual / Deferred` section heading.

This mirrors the D1–D3 pattern established in 4.1.0 and closes the coverage gap before the next release.

### Priority 3 — Resolve the 4.1.1 CHANGELOG ghost and document the version history clearly

Decide and act: either add a minimal `## [4.1.1] — 2026-05-12` block to `CHANGELOG.md` describing the Master-Plan documentation refinement, or add a note to the `## [4.2.0]` block that it subsumes the unreleased 4.1.1 patch. Update the `[4.1.0]` "Coming next" section (which still lists the 4.2.0 AgToosa Status Guide sub-agent and `/agtoosa-help next` as planned — those were not shipped in 4.2.0 either, so update the forward-looking note or move those items to `## [Unreleased]`).

---

*Generated by AgToosa maintainer review · 2026-05-14*
