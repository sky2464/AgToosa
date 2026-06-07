# DEV-035 Launch P0 Publication And Quickstart Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first launch-readiness slice from `docs/AgToosa_Launch_Readiness_Spec_Bundle.md`: public/private launch gates, truthful quickstart publication status, support surface readiness, and regression coverage.

**Architecture:** Add a small release-readiness shell checker that defaults to private-staging mode and only performs public URL assertions when explicitly run in public mode. Update README/support docs so private staging is honest now and public launch has a clear gate. Add focused Bats coverage for the docs and checker behavior before changing production/docs content.

**Tech Stack:** Bash, Bats, Markdown, GitHub issue templates, existing AgToosa maintainer docs.

---

## Scope

### Specs Covered

- `LRS-001 - Public Distribution Publication Gate`
- `LRS-002 - Public Quickstart Install`
- `LRS-012 - Public Support And Community Surface` public-link subset
- `LRS-013 - Launch Readiness Regression Gate` public/private URL mode subset

### Files

- Create: `scripts/check-launch-readiness.sh`
- Create: `docs/archived/spec-DEV-035.md`
- Create: `docs/AgToosa_TestPlan-DEV-035.md`
- Modify: `README.md`
- Modify: `.github/SUPPORT.md`
- Modify: `.github/DISCUSSIONS.md`
- Modify: `.github/ISSUE_TEMPLATE/bug.yml`
- Modify: `.github/ISSUE_TEMPLATE/feature.yml`
- Modify: `tests/agtoosa.bats`
- Modify: `docs/Master-Plan.md`

### Out Of Scope

- Making GitHub repositories public.
- Creating release assets.
- Publishing the Homebrew tap.
- Fixing PowerShell `-Update` parity.
- Fixing registry publish/install archive shape.
- Rewriting the full competitor table.

## Task 1: DEV-035 Spec And Test Plan

**Files:**
- Create: `docs/archived/spec-DEV-035.md`
- Create: `docs/AgToosa_TestPlan-DEV-035.md`
- Modify: `docs/Master-Plan.md`

- [ ] **Step 1: Create the DEV-035 spec**

Create `docs/archived/spec-DEV-035.md` with:

```markdown
# Spec: DEV-035 - Launch P0 publication and quickstart gate

> **Story ID:** DEV-035
> **Epic:** DEV-004 - Testing & QA Harness
> **Status:** In Progress
> **Estimate:** M
> **Spec created:** 2026-06-07
> **Launch specs:** LRS-001, LRS-002, LRS-012 public-link subset, LRS-013 public/private gate subset

## Context

The strategic launch review found that public GitHub, raw bootstrap, registry, Homebrew, and support URLs returned 404 from this environment. The owner clarified this is expected because the repository is intentionally private during staging. That private state is acceptable before launch, but the README currently reads as if anonymous public install and support links are ready.

DEV-035 makes the repo launch-aware. It adds a private-staging/public-launch readiness command, updates quickstart and support docs to avoid accidental public claims, and adds regression coverage so private-staging 404s are not confused with public-launch readiness.

## Goal Contract

| Field | Value |
|-------|-------|
| Goal | Make publication status, quickstart install claims, and support links explicitly gated for private staging versus public launch. |
| User outcome | Maintainers can run a local readiness gate before public launch and know exactly which public surfaces still require manual publication. |
| Success condition | README/support docs are truthful in private staging, a launch checker exists, Bats covers private/public mode behavior, and Master-Plan records DEV-035 as the active launch-readiness story. |
| Proof / evidence | `bats tests/agtoosa.bats -f "DEV-035"`, `bash scripts/check-launch-readiness.sh --mode private`, and `git diff --check` pass. |
| Non-goals | Publishing external repos, fixing PowerShell update parity, fixing registry archive shape, Homebrew release hardening, or rewriting competitive positioning. |
| Assumptions | Public launch means anonymous developer access. Private staging remains allowed until launch mode is explicitly enabled. |
| Risks | Docs can drift into looking public-ready before publication. Mitigate with explicit private-staging wording and public-mode URL checks. |

## Requirements

| ID | Requirement |
|----|-------------|
| AC-001 | WHEN the repo is private THE SYSTEM SHALL state that public install/support URLs are private-staging gates rather than public-ready commands. |
| AC-002 | WHEN a maintainer runs the readiness checker in private mode THE SYSTEM SHALL validate local launch docs and skip anonymous public URL checks. |
| AC-003 | WHEN a maintainer runs the readiness checker in public mode THE SYSTEM SHALL check repo, release, raw bootstrap, registry, support, issues, discussions, and Homebrew URLs if advertised. |
| AC-004 | WHEN README quickstart is read THE SYSTEM SHALL place pinned release guidance before `main` guidance and label `main` as development-only. |
| AC-005 | WHEN support and issue templates are read THE SYSTEM SHALL ask for OS, shell, install command, AgToosa version, target project context, and affected surface. |
| AC-006 | WHEN focused DEV-035 tests run THE SYSTEM SHALL prevent regression to unqualified public-ready wording while the project is private. |

## Design

Add `scripts/check-launch-readiness.sh` with `--mode private` and `--mode public`. Private mode checks local files and docs language only. Public mode performs the same checks plus anonymous URL checks with `curl`.

Update README to say the project is in private staging until publication. Keep the public commands, but label them as launch-target commands that require the repo/release URLs to be public. Keep clone/manual install for private collaborators.

Update GitHub support docs and issue templates so they collect actionable launch-support data.

## Build Scope

Ready to proceed. Files in scope: `scripts/check-launch-readiness.sh`, `README.md`, `.github/SUPPORT.md`, `.github/DISCUSSIONS.md`, `.github/ISSUE_TEMPLATE/bug.yml`, `.github/ISSUE_TEMPLATE/feature.yml`, `tests/agtoosa.bats`, `docs/Master-Plan.md`, `docs/AgToosa_TestPlan-DEV-035.md`, `docs/archived/spec-DEV-035.md`.

## Tasks

- [ ] **1.** Add failing DEV-035 Bats checks.
- [ ] **2.** Implement launch-readiness checker.
- [ ] **3.** Update README quickstart publication wording.
- [ ] **4.** Update support/community docs and issue templates.
- [ ] **5.** Enroll DEV-035 in Master-Plan.
- [ ] **6.** Run focused and broader validation.
```

- [ ] **Step 2: Create the DEV-035 test plan**

Create `docs/AgToosa_TestPlan-DEV-035.md` with:

````markdown
# Test Plan: DEV-035 - Launch P0 publication and quickstart gate

> **Spec:** `docs/archived/spec-DEV-035.md`
> **Coverage target:** private/public launch mode, quickstart truthfulness, support intake readiness
> **Smoke filter:** `bats tests/agtoosa.bats -f "DEV-035"`

## AC Coverage

| AC | Test ID | Category | Description | @smoke |
|----|---------|----------|-------------|--------|
| AC-001, AC-004 | LG-001 | Docs | README states private staging, labels public commands as launch-target, and places pinned release before `main` | yes |
| AC-002, AC-003 | LG-002 | Integration | Launch checker supports private and public modes and defaults to private mode | yes |
| AC-002 | LG-003 | Integration | Private mode validates local docs without requiring public URLs to return 2xx | yes |
| AC-003 | LG-004 | Static | Public mode URL list includes repo, releases, raw bootstrap, registry, issues, discussions, support, and Homebrew-if-advertised surfaces | no |
| AC-005 | LG-005 | Docs | Support templates request OS, shell, install command, AgToosa version, target project context, and affected surface | no |
| AC-006 | LG-006 | Integration | Focused DEV-035 Bats filter covers launch-gate regression checks | no |

## Commands

```bash
bats tests/agtoosa.bats -f "DEV-035"
bash scripts/check-launch-readiness.sh --mode private
git diff --check
```

Public launch verification after repo publication:

```bash
AGTOOSA_LAUNCH_MODE=public bash scripts/check-launch-readiness.sh
```

## Validation Evidence

Record command output here during build.
````

- [ ] **Step 3: Enroll DEV-035 in Master-Plan**

Edit `docs/Master-Plan.md`:

1. Change Project Charter milestone to `v5.2.6` unchanged.
2. Change Active cycle from empty to:

```markdown
| DEV-035 | Launch P0 publication and quickstart gate | Chore | M | In Progress | 0/6 |
```

3. Add Active Tasks:

```markdown
**DEV-035 - Launch P0 publication and quickstart gate** (spec: `docs/archived/spec-DEV-035.md`)

- [ ] **1.** Add failing DEV-035 Bats checks - _AC-001-AC-006_
- [ ] **2.** Implement launch-readiness checker - _AC-002, AC-003, AC-006_
- [ ] **3.** Update README quickstart publication wording - _AC-001, AC-004_
- [ ] **4.** Update support/community docs and issue templates - _AC-005_
- [ ] **5.** Enroll DEV-035 bookkeeping and test plan evidence - _AC-006_
- [ ] **6.** Run focused and broader validation - _AC-002, AC-006_
```

4. Add Backlog row above shipped rows:

```markdown
| DEV-035 | Chore: Launch P0 publication and quickstart gate | Chore | M | DEV-004 | High | In Progress |
```

- [ ] **Step 4: Verify spec files are present**

Run:

```bash
test -f docs/archived/spec-DEV-035.md
test -f docs/AgToosa_TestPlan-DEV-035.md
rg -n "DEV-035|LRS-001|LRS-002|LG-001|LG-006" docs/archived/spec-DEV-035.md docs/AgToosa_TestPlan-DEV-035.md docs/Master-Plan.md
```

Expected: all commands exit `0`.

## Task 2: Failing DEV-035 Regression Tests

**Files:**
- Modify: `tests/agtoosa.bats`

- [ ] **Step 1: Add DEV-035 tests near the end of `tests/agtoosa.bats`**

Append this section after the DEV-034 tests:

```bash
# -- DEV-035 Launch P0 publication and quickstart gate (LG-001-LG-006) --------

@test "DEV-035 LG-001: README labels private staging and public launch commands truthfully" {
  local readme="$BATS_TEST_DIRNAME/../README.md"

  grep -q "Private staging status" "$readme"
  grep -q "Public launch target" "$readme"
  grep -q "development-only main branch" "$readme"

  local pinned_line main_line
  pinned_line="$(grep -n "Public launch target: pinned release" "$readme" | head -n1 | cut -d: -f1)"
  main_line="$(grep -n "development-only main branch" "$readme" | head -n1 | cut -d: -f1)"
  [[ -n "$pinned_line" ]]
  [[ -n "$main_line" ]]
  [[ "$pinned_line" -lt "$main_line" ]]
}

@test "DEV-035 LG-002: launch readiness checker exposes private and public modes" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"

  [[ -x "$checker" ]]
  grep -q -- "--mode private" "$checker"
  grep -q -- "--mode public" "$checker"
  grep -q "AGTOOSA_LAUNCH_MODE" "$checker"
}

@test "DEV-035 LG-003: private launch readiness mode passes without public URL access" {
  run bash "$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh" --mode private
  [ "$status" -eq 0 ]
  [[ "$output" == *"mode: private"* ]]
  [[ "$output" == *"Skipping anonymous public URL checks"* ]]
}

@test "DEV-035 LG-004: public launch mode checks all advertised public surfaces" {
  local checker="$BATS_TEST_DIRNAME/../scripts/check-launch-readiness.sh"

  grep -q "https://github.com/sky2464/AgToosa" "$checker"
  grep -q "https://github.com/sky2464/AgToosa/releases" "$checker"
  grep -q "https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh" "$checker"
  grep -q "https://raw.githubusercontent.com/sky2464/AgToosa/v5.2.5/bootstrap.sh" "$checker"
  grep -q "https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json" "$checker"
  grep -q "https://github.com/sky2464/AgToosa/issues" "$checker"
  grep -q "https://github.com/sky2464/AgToosa/discussions" "$checker"
  grep -q "https://github.com/sky2464/homebrew-agtoosa" "$checker"
}

@test "DEV-035 LG-005: support templates collect actionable launch support details" {
  local bug="$BATS_TEST_DIRNAME/../.github/ISSUE_TEMPLATE/bug.yml"
  local feature="$BATS_TEST_DIRNAME/../.github/ISSUE_TEMPLATE/feature.yml"
  local support="$BATS_TEST_DIRNAME/../.github/SUPPORT.md"

  grep -q "Operating system" "$bug"
  grep -q "Shell" "$bug"
  grep -q "Install command" "$bug"
  grep -q "Target project context" "$bug"
  grep -q "Affected surface" "$feature"
  grep -q "private staging" "$support"
}

@test "DEV-035 LG-006: test plan maps all launch gate checks" {
  local tp="$BATS_TEST_DIRNAME/../docs/AgToosa_TestPlan-DEV-035.md"

  grep -q "LG-001" "$tp"
  grep -q "LG-002" "$tp"
  grep -q "LG-003" "$tp"
  grep -q "LG-004" "$tp"
  grep -q "LG-005" "$tp"
  grep -q "LG-006" "$tp"
}
```

- [ ] **Step 2: Run the tests to verify they fail before implementation**

Run:

```bash
bats tests/agtoosa.bats -f "DEV-035"
```

Expected: FAIL because the checker and wording do not exist yet.

## Task 3: Launch Readiness Checker

**Files:**
- Create: `scripts/check-launch-readiness.sh`

- [ ] **Step 1: Create the checker**

Create `scripts/check-launch-readiness.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${AGTOOSA_LAUNCH_MODE:-private}"

usage() {
  cat <<'EOF'
Usage:
  scripts/check-launch-readiness.sh [--mode private|public]

Modes:
  private  Validate local launch docs and skip anonymous public URL checks.
  public   Validate local launch docs and require advertised public URLs to respond.

Environment:
  AGTOOSA_LAUNCH_MODE=private|public
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      [[ $# -lt 2 ]] && { echo "Error: --mode requires private or public" >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$MODE" in
  private|public) ;;
  *)
    echo "Error: unsupported mode '$MODE' (expected private or public)" >&2
    exit 2
    ;;
esac

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$ROOT_DIR/$path" ]] || fail "missing required file: $path"
  pass "found $path"
}

require_text() {
  local path="$1"
  local pattern="$2"
  local label="$3"
  grep -qE "$pattern" "$ROOT_DIR/$path" || fail "$label"
  pass "$label"
}

check_url() {
  local url="$1"
  local label="$2"
  local code
  code="$(curl -L -sS -o /dev/null -w '%{http_code}' --max-time 20 "$url" || true)"
  case "$code" in
    200|204|301|302|307|308)
      pass "$label ($code)"
      ;;
    *)
      fail "$label returned HTTP $code: $url"
      ;;
  esac
}

printf 'AgToosa launch readiness mode: %s\n' "$MODE"

require_file "README.md"
require_file ".github/SUPPORT.md"
require_file ".github/DISCUSSIONS.md"
require_file ".github/ISSUE_TEMPLATE/bug.yml"
require_file ".github/ISSUE_TEMPLATE/feature.yml"
require_file "bootstrap.sh"
require_file "bootstrap.ps1"

require_text "README.md" "Private staging status" "README states private staging status"
require_text "README.md" "Public launch target: pinned release" "README labels pinned release public launch target"
require_text "README.md" "development-only main branch" "README labels main branch command as development-only"
require_text ".github/SUPPORT.md" "private staging" "support doc explains private staging"
require_text ".github/ISSUE_TEMPLATE/bug.yml" "Install command" "bug template asks for install command"
require_text ".github/ISSUE_TEMPLATE/bug.yml" "Target project context" "bug template asks for target project context"
require_text ".github/ISSUE_TEMPLATE/feature.yml" "Affected surface" "feature template asks for affected surface"

if [[ "$MODE" == "private" ]]; then
  echo "Skipping anonymous public URL checks in private mode."
  exit 0
fi

check_url "https://github.com/sky2464/AgToosa" "GitHub repository"
check_url "https://github.com/sky2464/AgToosa/releases" "GitHub releases"
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh" "raw bootstrap.sh on main"
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/v5.2.5/bootstrap.sh" "raw bootstrap.sh on pinned release"
check_url "https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1" "raw bootstrap.ps1 on main"
check_url "https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json" "registry index"
check_url "https://github.com/sky2464/AgToosa/issues" "GitHub issues"
check_url "https://github.com/sky2464/AgToosa/discussions" "GitHub discussions"
check_url "https://github.com/sky2464/homebrew-agtoosa" "Homebrew tap"
```

- [ ] **Step 2: Make the checker executable**

Run:

```bash
chmod +x scripts/check-launch-readiness.sh
```

- [ ] **Step 3: Run private mode before docs updates**

Run:

```bash
bash scripts/check-launch-readiness.sh --mode private
```

Expected: FAIL until README and support docs are updated.

## Task 4: README Quickstart Truth

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace the top one-time usage block**

Replace the current top "One-time usage (pinned release)" block with:

````markdown
**Private staging status:** AgToosa is still staged in a private repository. Public launch commands below are the launch target and require the repo, release tag, raw bootstrap files, registry, and support links to be public before announcement.

**Public launch target: pinned release**

```bash
# Replace v5.2.5 with the latest public release tag after publication
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.2.5
```

**Private collaborator path: clone and run**

```bash
git clone https://github.com/sky2464/AgToosa.git && cd AgToosa && bash agtoosa.sh
````
```

- [ ] **Step 2: Rewrite the Installation Quick Start macOS/Linux block**

Replace the macOS/Linux quickstart block with:

````markdown
**macOS & Linux:**

```bash
# Public launch target: pinned release. Requires the repo and tag to be public.
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh) --ref v5.2.5

# Private staging or manual verification path for collaborators with repo access:
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
bash agtoosa.sh --version

# development-only main branch command; may include unreleased changes
bash <(curl -fsSL https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.sh)
```
````

- [ ] **Step 3: Rewrite the Windows quickstart block**

Replace the Windows native block with:

````markdown
**Windows (native):**

```powershell
# Public launch target: pinned release after publication
$Ref = "v5.2.5"
iwr -UseBasicParsing https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1 | iex
.\agtoosa.ps1 -Version

# Private staging path for collaborators with repo access
git clone https://github.com/sky2464/AgToosa.git
cd AgToosa
.\agtoosa.ps1 -Version
```
````

- [ ] **Step 4: Update the lower one-time usage section**

Ensure the lower "Option 2: One-time Usage" section contains the exact phrase `Public launch target: pinned release` before the `main` branch command, and the exact phrase `development-only main branch` before the `main` command.

- [ ] **Step 5: Run README-focused checks**

Run:

```bash
rg -n "Private staging status|Public launch target: pinned release|development-only main branch|v5.2.5" README.md
```

Expected: all terms appear, and pinned release wording appears before main branch wording.

## Task 5: Support And Issue Template Readiness

**Files:**
- Modify: `.github/SUPPORT.md`
- Modify: `.github/DISCUSSIONS.md`
- Modify: `.github/ISSUE_TEMPLATE/bug.yml`
- Modify: `.github/ISSUE_TEMPLATE/feature.yml`

- [ ] **Step 1: Add private staging note to support docs**

Add this paragraph after the first heading in `.github/SUPPORT.md`:

```markdown
> **Private staging:** Until the repository is public, GitHub Discussions, Issues, release links, and raw bootstrap URLs are launch gates rather than public support channels. Public launch requires these links to resolve anonymously.
```

Add this paragraph after the first heading in `.github/DISCUSSIONS.md`:

```markdown
> **Private staging:** Discussions are the intended public community surface after launch. While the repository is private, use maintainer access or direct owner communication for support.
```

- [ ] **Step 2: Expand bug report template**

In `.github/ISSUE_TEMPLATE/bug.yml`, add these fields after `version`:

```yaml
  - type: input
    id: operating_system
    attributes:
      label: Operating system
      description: "macOS, Linux distribution, Windows version, WSL2, or Git Bash"
      placeholder: "macOS 15.5, Ubuntu 24.04, Windows 11 PowerShell"
    validations:
      required: true

  - type: input
    id: shell
    attributes:
      label: Shell
      description: "Shell used to run AgToosa"
      placeholder: "bash 5.2, zsh launching bash, PowerShell 7.5"
    validations:
      required: true

  - type: textarea
    id: install_command
    attributes:
      label: Install command
      description: "Exact command used to install or run AgToosa"
      render: bash
    validations:
      required: true

  - type: textarea
    id: target_project_context
    attributes:
      label: Target project context
      description: "New repo or existing repo, selected platforms, and whether this was install, update, registry, or bootstrap"
      placeholder: "Existing repo; selected Docs + Claude + Codex; ran --update"
    validations:
      required: true
```

- [ ] **Step 3: Expand feature template**

In `.github/ISSUE_TEMPLATE/feature.yml`, add this dropdown after the opening markdown block:

```yaml
  - type: dropdown
    id: affected_surface
    attributes:
      label: Affected surface
      description: Which AgToosa area should this change?
      options:
        - "Generator: agtoosa.sh / lib"
        - "PowerShell: agtoosa.ps1"
        - "Bootstrap / distribution"
        - "Workflow templates"
        - "Platform adapter"
        - "Registry"
        - "Documentation"
        - "Release / CI"
    validations:
      required: true
```

- [ ] **Step 4: Run support-template checks**

Run:

```bash
rg -n "private staging|Operating system|Shell|Install command|Target project context|Affected surface" .github/SUPPORT.md .github/DISCUSSIONS.md .github/ISSUE_TEMPLATE/bug.yml .github/ISSUE_TEMPLATE/feature.yml
```

Expected: all terms appear.

## Task 6: Validate And Record Evidence

**Files:**
- Modify: `docs/AgToosa_TestPlan-DEV-035.md`
- Modify: `docs/Master-Plan.md`

- [ ] **Step 1: Run focused DEV-035 tests**

Run:

```bash
bats tests/agtoosa.bats -f "DEV-035"
```

Expected: `6/6` passing.

- [ ] **Step 2: Run private launch checker**

Run:

```bash
bash scripts/check-launch-readiness.sh --mode private
```

Expected: exit `0`, with output containing:

```text
AgToosa launch readiness mode: private
Skipping anonymous public URL checks in private mode.
```

- [ ] **Step 3: Run adjacent doc/version checks**

Run:

```bash
bats tests/agtoosa.bats -f "^version parity:|R1:|R2:|R7:|DEV-034"
```

Expected: all selected tests pass.

- [ ] **Step 4: Run full Bats suite if focused checks pass**

Run:

```bash
bats tests/agtoosa.bats
```

Expected: full suite passes.

- [ ] **Step 5: Run shell quality checks**

Run:

```bash
shellcheck -x -S warning --exclude=SC2002,SC2046,SC2086,SC1091,SC2034 agtoosa.sh bootstrap.sh lib/*.sh scripts/check-launch-readiness.sh
```

Expected: exit `0`.

- [ ] **Step 6: Update test plan evidence**

Replace the `Validation Evidence` section in `docs/AgToosa_TestPlan-DEV-035.md` with the actual command results:

````markdown
## Validation Evidence

```text
bats tests/agtoosa.bats -f "DEV-035"
=> 6/6 passing

bash scripts/check-launch-readiness.sh --mode private
=> exit 0; local docs checked; public URL checks skipped

bats tests/agtoosa.bats -f "^version parity:|R1:|R2:|R7:|DEV-034"
=> passing

bats tests/agtoosa.bats
=> full suite passing

shellcheck -x -S warning --exclude=SC2002,SC2046,SC2086,SC1091,SC2034 agtoosa.sh bootstrap.sh lib/*.sh scripts/check-launch-readiness.sh
=> exit 0
```
````

- [ ] **Step 7: Update Master-Plan task checkboxes**

In `docs/Master-Plan.md`, mark DEV-035 tasks complete only for validations that actually passed. Leave the story In Progress until review/ship artifacts exist.

- [ ] **Step 8: Final diff hygiene**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; changed files match DEV-035 scope plus existing untracked report/spec artifacts.

## Self-Review

- Spec coverage: LRS-001, LRS-002, LRS-012 public-link subset, and LRS-013 public/private gate subset are mapped to tasks.
- External blockers: repository publication, release publication, registry publication, and Homebrew tap publication remain manual launch gates by design.
- Placeholder scan: no unfinished placeholder markers are intentionally left.
- Scope check: this plan is one implementation story; PowerShell update parity, registry archive contract, Homebrew hardening, and competitor positioning remain separate stories.
