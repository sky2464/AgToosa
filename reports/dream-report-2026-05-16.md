# AgToosa Dream Report — 2026-05-16

**Scope:** Last 7 days (2026-05-09 → 2026-05-16)
**Commits reviewed:** 15 (f5166cc → c5c6e1a)
**Versions shipped:** 4.0.0 → 4.1.0 → 4.1.1 (patch, unreleased) → 4.2.0

---

## What Improved

### v4.2.0 — Manual task support (landed 2026-05-13)
Tasks tagged `[manual]` now have a first-class lifecycle in the build cycle: `[manual]` → `[manual-deferred: YYYY-MM-DD]` → `[manual-done]`. The `/agtoosa-build` manual detection gate presents a three-way prompt without blocking the build cycle. `AgToosa_Status.md`, `Master-Plan.md`, and `SPEC-FORMAT.md` all contain the new behavior consistently. The `🔧 Awaiting Manual` state is correctly classified as non-blocking (ℹ️ Info, not Warning) and manual-deferred tasks are excluded from health score penalties and staleness thresholds. The CHANGELOG entry is detailed and accurate, with a proper "Files updated" list.

### v4.1.0 — Status guidance loop (landed 2026-05-11)
The deterministic Part 5.5 Next Actions algorithm, aging escalation prefix, sub-command typo helper, and universal closure line are fully wired across all platform variants. The `init`/`help` three-variant asymmetry is correctly encoded in the maintainer guide and enforced by the D2 bats test. The D1–D3 parity test suite is a strong precedent for the coverage pattern that v4.2.0 should follow.

### Process hygiene
- `[Unreleased]` section is clean: no floating changes.
- `lib/config.sh` registration for `/agtoosa-status` across all platform variants landed in a single atomic commit (78d5001).
- Security: `validate_pack_files` symlink path-traversal rejection is bats-covered and intact.

---

## What Needs Attention

> **Note:** All four issues below were identified in the 2026-05-14 dream report. None have been resolved in the two days since. Priority 1 is actively breaking CI.

### 1. Version parity broken — `agtoosa.ps1` stuck at `4.1.0` (CI FAILING)

`agtoosa.sh` is at **4.2.0**. `agtoosa.ps1` is still at **4.1.0**. The bats version-parity test reads both files and compares:

```
@test "version parity: agtoosa.sh and agtoosa.ps1 report same version" {
  BASH_VER=$(grep -m1 'AGTOOSA_VERSION=' agtoosa.sh | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  PS_VER=$(grep -m1 'AGTOOSA_VERSION' agtoosa.ps1  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  [ "$BASH_VER" = "$PS_VER" ]   # 4.2.0 ≠ 4.1.0 → FAIL
}
```

The gap spans two releases: `agtoosa.ps1` was not bumped at 4.1.1 (commit 041fcc0) and was not bumped again at 4.2.0 (commit 84b5969). Fix: `agtoosa.ps1` line 65, `"4.1.0"` → `"4.2.0"`.

### 2. Bats version pins not updated for 4.2.0 (CI FAILING)

Three exact-pin assertions in `tests/agtoosa.bats` still reference `4.1.0`:

| Line | Test name | Stale assertion |
|------|-----------|-----------------|
| 23 | `--version prints version string` | `"AgToosa v4.1.0"` |
| 1161 | `fresh install writes Docs/.agtoosa-version` | `"4.1.0"` |
| 1172 | `--update after fresh install shows real version` | `*"4.1.0"*` |

Line 20 has a comment: `# Update this expected string on each release`. This step was skipped for both 4.1.1 and 4.2.0.

### 3. No bats coverage for v4.2.0 manual task behavior

4.2.0 introduced four template changes with no corresponding bats tests. The 4.1.0 precedent (D1–D3, 10 tests) set a clear bar.

Missing assertions (proposed `M1`–`M4` block):

| ID | File | Key string to grep |
|----|------|--------------------|
| M1 | `template/Docs/SPEC-FORMAT.md` | `\[manual\]`, `\[manual-deferred`, `Awaiting Manual` |
| M2 | `template/Docs/AgToosa_Build.md` | `Manual Task Detection`, `mark done, defer` |
| M3 | `template/Docs/AgToosa_Status.md` | `manual-deferred`, `Awaiting Manual.*non-blocking` or equivalent |
| M4 | `template/Docs/Master-Plan.md` | `Manual / Deferred` section heading |

### 4. "Coming next (4.2.0)" promises in CHANGELOG not delivered

The `## [4.1.0]` block contains a `### Coming next (4.2.0)` subsection that listed two planned features. Neither shipped in 4.2.0:

- **AgToosa Status Guide sub-agent** — read-only Auditor + Coach persona
- **`/agtoosa-help next`** — context-aware next-move help

The `## [Unreleased]` block is currently empty. These items should be moved there to signal they are still planned, or the "Coming next" section should be removed to avoid reader confusion.

### 5. README version badge and install snippet stale at `4.1.0`

`README.md` line 8 badge: `version-4.1.0-green.svg`
`README.md` line 52 install snippet: `--ref v4.1.0`

These should read `4.2.0`. The release checklist requires updating both on every release.

---

## 3 Prioritized Action Items

### Priority 1 — Fix version parity and stale bats pins (unblocks CI)

**Files:** `agtoosa.ps1` line 65, `tests/agtoosa.bats` lines 23, 1161, 1172, `README.md` lines 8 and 52.

```bash
# agtoosa.ps1 line 65
$AGTOOSA_VERSION = "4.2.0"

# agtoosa.bats line 23
[[ "$output" == "AgToosa v4.2.0" ]]

# agtoosa.bats line 1161
[ "$ver" = "4.2.0" ]

# agtoosa.bats line 1172
[[ "$output" == *"4.2.0"* ]]

# README.md line 8
[![Version](https://img.shields.io/badge/version-4.2.0-green.svg)]...

# README.md line 52
bash <(curl -fsSL .../bootstrap.sh) --ref v4.2.0
```

Verification: `bats tests/agtoosa.bats -f "version"` — all three version tests must pass green.

### Priority 2 — Add bats M1–M4 parity tests for v4.2.0 manual task behavior

Append after the `D3` block in `tests/agtoosa.bats`:

```bash
# ── 4.2.0 manual task support (M1 / M2 / M3 / M4) ──────────────────────────

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

### Priority 3 — Clean up CHANGELOG forward-looking notes and 4.1.1 history gap

Two housekeeping items that compound over time:

1. Move the two unshipped "Coming next (4.2.0)" features (Status Guide sub-agent, `/agtoosa-help next`) from `## [4.1.0]` into `## [Unreleased]` so the backlog is visible and the released entry is accurate.

2. The `agtoosa.sh` 4.1.1 bump (commit 041fcc0) has no CHANGELOG entry and `agtoosa.ps1` was never updated for it. Since 4.1.1 is superseded by 4.2.0, add a one-line `## [4.1.1] — 2026-05-11` tombstone noting it was an unreleased intermediate patch (Master-Plan doc refinement), then never shipped — this closes the `git log` / CHANGELOG divergence for future readers.

---

*Generated by AgToosa maintainer review · 2026-05-16*
