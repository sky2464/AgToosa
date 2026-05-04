# AgToosa v3.1.0 — Production Readiness Audit

**Date:** 2025-07  
**Scope:** Full repo audit for public release  
**Auditor:** GitHub Copilot  
**Verdict:** ❌ NOT RELEASE-READY — 4 critical bugs and 3 high-severity security issues must be resolved first.

---

## Summary

| Category | Count | Blocking? |
|---|---|---|
| Critical bugs | 4 | YES |
| Missing features | 5 | PS1-only gap (decide policy) |
| Test gaps | 7 | Recommended before release |
| Platform parity | 8 | PS1 significantly behind |
| UX/message issues | 6 | Yes (2 are wrong/misleading) |
| Security issues | 5 | YES (3 must fix) |
| Documentation gaps | 6 | Yes (2 must fix) |
| CI issues | 4 | No (1 deprecated but functional) |

---

## 1. Critical Bugs

### CB-1 — Registry install stages files that the EXIT trap immediately deletes

**File:** `lib/registry.sh` (function `registry_install`) + `agtoosa.sh` (trap `_cleanup EXIT`)

**Problem:**  
`registry_install` stages the downloaded pack tarball to `${SHIP_DIR}/packs/${pack_name}/`. Then the script executes `exit $?`. The `trap _cleanup EXIT` fires, and `_cleanup` runs `rm -rf "$SHIP_DIR"` because `KEEP_SHIP` is never set to `true` in the `--registry install` code path. Every staged pack file is deleted before the user can do anything with them.

The success message printed immediately before the files are deleted says:
```
✅ Pack staged at: /path/to/agtoosa/ship/packs/ml-pipeline
Run 'bash agtoosa.sh' in your project to merge the pack files.
```
This instruction is factually wrong: the directory referenced no longer exists.

**Fix:**
```bash
registry_install() {
  ...
  # At the END of staging, before printing the success message:
  KEEP_SHIP=true   # ← add this
  echo -e "  ${GREEN}✅${NC} Pack staged at: ${pack_dir}"
  echo ""
  echo -e "${YELLOW}➡️  To merge this pack into your project, run:${NC}"
  echo -e "   ${BOLD}bash agtoosa.sh /path/to/your/project${NC}"
  echo -e "   (The pack in ${BOLD}ship/packs/${pack_name}/${NC} will be merged automatically)"
}
```
Also update `manual_copy_instructions` to mention the `ship/packs/` directory so declining the copy prompt still gives correct instructions.

---

### CB-2 — PowerShell registry parses `.packs` field on a flat JSON array

**File:** `agtoosa.ps1` (all `Invoke-Registry*` and `Show-Registry*` functions)

**Problem:**  
All PS1 registry functions do:
```powershell
$registryData = ($json | ConvertFrom-Json)
$packs = $registryData.packs   # returns $null — registry.json IS the array
```
The actual `registry.json` (and `tests/fixtures/registry.json`) is a flat JSON array `[...]`. There is no `.packs` wrapper. `ConvertFrom-Json` on a JSON array returns a `PSCustomObject[]`, not an object with a `.packs` field. All PS1 registry commands (`list`, `search`, `info`, `install`) silently return nothing.

**Fix — Option A (recommended):** Fix PS1 to treat the JSON as an array:
```powershell
$packs = @($json | ConvertFrom-Json)   # @ forces array even for single item
```

**Fix — Option B:** Wrap `registry.json` in `{"packs": [...]}` and update bash to use `.packs[]` instead of `.[]`. Requires updating `tests/fixtures/registry.json` too.

Pick one option and enforce it in CI (the existing `tests/fixtures/registry.json` is the ground truth).

---

### CB-3 — jq injection via unsanitized user input in registry functions

**File:** `lib/registry.sh` (functions `registry_search`, `registry_info`, `registry_install`)

**Problem:**  
User-supplied strings are shell-interpolated directly into jq filter expressions:

```bash
# registry_search — $query is user input
echo "$registry" | jq -r ".[] | select(.name | test(\"$query\"; \"i\") or .description | test(\"$query\"; \"i\")) | ..."

# registry_info — $pack_name is user input (from CLI arg)
echo "$registry" | jq -r ".[] | select(.name == \"$pack_name\") | ..."

# registry_install — $pack_name is user input
pack_entry=$(echo "$registry" | jq -r ".[] | select(.name == \"$pack_name\")")
```

A crafted input like `x") | halt_error(` can manipulate jq execution. More critically, jq's `@sh` and `@base64d` builtins could be leveraged for information exfiltration in complex scenarios. At minimum, an attacker can crash the registry lookup with arbitrary jq errors.

**Fix:** Use `--arg` to pass all user strings as safe jq variables:
```bash
# registry_search
echo "$registry" | jq --arg q "$query" \
  -r '.[] | select((.name | test($q; "i")) or (.description | test($q; "i"))) | ...'

# registry_info and registry_install
echo "$registry" | jq --arg name "$pack_name" \
  -r '.[] | select(.name == $name) | ...'
```

---

### CB-4 — `merge_platform_file` Case B re-merges without version markers

**File:** `lib/copy.sh` (function `merge_platform_file`, Case B branch)

**Problem:**  
When an existing platform file has an older `<!-- AgToosa v1.0.0 START -->` block, the function strips the old block via awk and appends the new template content:
```bash
awk '/<!-- AgToosa .* START -->/{...strip block...}' "$target" > "$tmp"
cat "$src" >> "$tmp"   # ← raw template, no version markers
```
The appended content has no `<!-- AgToosa vX.Y.Z START -->` / `<!-- AgToosa END -->` delimiters. On the next run, `extract_version` finds no markers in this section, classifies the file as Case D (user-owned), and appends a second copy. Re-running the installer on a project where Case B was triggered accumulates duplicate content.

**Fix:**
```bash
local tmp_versioned
tmp_versioned=$(mktemp)
inject_version "$src" "$tmp_versioned"
cat "$tmp_versioned" >> "$tmp"
rm -f "$tmp_versioned"
```

---

## 2. Missing Features

### MF-1 — PowerShell: native platform directories not installed

**File:** `agtoosa.ps1` (function `Install-Files`)

**Problem:**  
The bash `install_files` copies the full native platform directory trees:
- `.claude/commands/` (6+ slash command files)
- `.claude/skills/`
- `.claude/settings.json` (hook configuration)
- `.cursor/rules/` (MDX rule files)
- `.gemini/commands/` (TOML command files)
- `.github/prompts/`, `.github/agents/`, `.github/instructions/`
- `.windsurf/rules/`

The PS1 `Install-Files` only copies the top-level entry-point file for each platform (e.g., `CLAUDE.md`, `.cursorrules`). Users on Windows get the workflow documentation but none of the IDE integration — effectively ~20% of the functionality.

**Fix:** Mirror the bash `install_files` structure in PS1. For each platform, iterate the corresponding file arrays defined at the top of the script and copy them from ship/ to project/.

---

### MF-2 — PowerShell: `Install-Files` is non-recursive; Context/ stubs never copied

**File:** `agtoosa.ps1` (function `Install-Files`)

**Problem:**
```powershell
Get-ChildItem -Path $shipDocs -File | ForEach-Object {
    Copy-FileWithGuard $_.FullName (Join-Path $dstDocs $_.Name) ...
}
```
`-File` without `-Recurse` only lists files in the root of `ship/Docs/`. Files in `ship/Docs/Context/` (workflow.md, tech-stack.md, product.md, product-guidelines.md) are silently skipped. New installs via PS1 never get these stub files.

**Fix:** Add a separate loop for `Docs/Context/`:
```powershell
$contextSrc = Join-Path $shipDocs "Context"
if (Test-Path $contextSrc) {
    $contextDst = Join-Path $dstDocs "Context"
    New-Item -ItemType Directory -Path $contextDst -Force | Out-Null
    Get-ChildItem -Path $contextSrc -File | ForEach-Object {
        Copy-FileWithGuard $_.FullName (Join-Path $contextDst $_.Name) "Docs\Context\$($_.Name)"
    }
}
```

---

### MF-3 — PowerShell: no `inject_version` equivalent

**File:** `agtoosa.ps1` (function `Stage-Files`)

**Problem:**  
All platform entry-point files are copied with a plain `Copy-Item $src $dst`. No version-delimiting markers (`<!-- AgToosa v3.1.0 START -->` / `<!-- AgToosa END -->`) are injected. On re-install from PS1:
- `Copy-FileWithGuard` cannot detect the AgToosa block (no markers) → applies wrong merge logic
- `--update` via PS1 cannot smartly merge platform entry-points — it falls back to simple overwrite (no backup, no Case B merge)

**Fix:** Implement `Invoke-InjectVersion`:
```powershell
function Invoke-InjectVersion([string]$srcPath, [string]$dstPath) {
    $content = Get-Content $srcPath -Raw
    if ($srcPath -match '\.md$') {
        $wrapped = "<!-- AgToosa v$AGTOOSA_VERSION START -->`n`n$content`n<!-- AgToosa END -->`n"
    } else {
        $wrapped = "# AgToosa v$AGTOOSA_VERSION START`n`n$content`n# AgToosa END`n"
    }
    Set-Content -Path $dstPath -Value $wrapped -Encoding UTF8 -NoNewline
}
```
Call it wherever `Stage-Files` currently does `Copy-Item $src $dst` for platform entry-points.

---

### MF-4 — PowerShell: `--registry publish` not implemented

**File:** `agtoosa.ps1` (registry dispatch switch)

**Problem:**  
The bash `--registry publish` runs an interactive contribution wizard. The PS1 registry switch only handles `list`, `search`, `info`, `install`. A PS1 user running `agtoosa.ps1 --registry publish` hits the default case and gets "Unknown registry command".

**Fix:** Add a `"publish"` case that either implements the wizard (matching bash) or prints "Use the bash version to publish packs: bash agtoosa.sh --registry publish".

---

### MF-5 — PowerShell: `.claude/settings.json` merge not implemented

**File:** `agtoosa.ps1` (function `Install-Files`)

**Problem:**  
The bash installer deep-merges `.claude/settings.json` (PreToolUse/PostToolUse/Stop hooks) via Python3, deduplicating existing hooks. The PS1 installer has no equivalent. Users on Windows who install Claude Code support via PS1 never get the git-safety hooks configured.

**Fix:** Implement a PS1 `Merge-ClaudeSettings` function using `ConvertFrom-Json`/`ConvertTo-Json` to perform the deep merge, or call Python3 if available:
```powershell
function Merge-ClaudeSettings([string]$srcFile, [string]$dstFile) {
    if (-not (Get-Command python3 -ErrorAction SilentlyContinue)) {
        Write-Color "${YELLOW}⚠️  python3 not found — skipping .claude/settings.json merge${NC}"
        return
    }
    # Call the same Python3 merge script used by bash
    python3 -c "..." $srcFile $dstFile
}
```

---

## 3. Test Gaps

### TG-1 — No bats tests for `--registry list`, `search`, `info`, or `install`

**File:** `tests/agtoosa.bats`

**Problem:**  
The only `--registry` tests are:
- `--registry bogus-cmd` exits non-zero (error path only)
- `validate_pack_files` unit tests (rejects .sh, accepts .md/.json)
- `lock file is written when packs are staged and merged` (uses ship/ fixture, skips in non-TTY)

Zero tests for the actual happy paths: `list`, `search <term>`, `info <pack>`, or `install ./local-path`. CB-1 (staged files deleted) and CB-2 (PS1 JSON schema mismatch) both would have been caught by a `--registry install ./fixtures/test-pack` integration test.

**Fix:** Add tests using the local install path (`--registry install ./tests/fixtures/test-pack`) with the existing fixture. Mock `fetch_registry` by setting `$REGISTRY_CACHE_FILE` to the fixture for `list`/`search`/`info` tests.

---

### TG-2 — CB-4 (`merge_platform_file` Case B) has no re-run regression test

**File:** `tests/agtoosa.bats`

**Problem:**  
The Case B test (`merge_platform_file Case B: older AgToosa block upgraded in-place with .bak`) only verifies the first merge. It does not run the installer a second time to verify the merged file is stable (no duplicate content). CB-4 would pass the existing test but fail on re-run.

**Fix:** Add a test that runs the installer twice on the same file and asserts exactly one `AgToosa.*START` block in the result:
```bash
@test "Case B: second install does not duplicate the block" {
  printf '<!-- AgToosa v1.0.0 START -->\nold\n<!-- AgToosa END -->\n' > "$TEST_PROJECT/CLAUDE.md"
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$(grep -c 'AgToosa.*START' "$TEST_PROJECT/CLAUDE.md")" -eq 1 ]
}
```

---

### TG-3 — No bats test for jq injection protection

**File:** `tests/agtoosa.bats`

**Problem:**  
CB-3 (jq injection) has no regression test. A test using a crafted search query that would exploit the injection would make the fix verifiable and guard against future regressions.

**Fix:**
```bash
@test "registry_search: crafted jq injection query does not crash" {
  export REGISTRY_CACHE_FILE="$BATS_TEST_DIRNAME/fixtures/registry.json"
  export REGISTRY_CACHE_TTL=999999
  source "$BATS_TEST_DIRNAME/../lib/registry.sh"
  run registry_search '") | halt_error(42'
  [ "$status" -eq 0 ]   # should find 0 results, not crash
}
```

---

### TG-4 — No bats test for `merge_settings_json` when python3 is unavailable

**File:** `tests/agtoosa.bats`

**Problem:**  
`merge_settings_json` silently skips the merge with a yellow warning when python3 is not available. This fallback is never tested. A user without python3 gets no Claude hooks but no error — this should be verified as the correct silent-skip behavior.

**Fix:** Shadow python3 in the test PATH and verify install succeeds without creating `.claude/settings.json`:
```bash
@test "merge_settings_json gracefully skips when python3 absent" {
  PATH="/dev/null:$PATH" run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  # settings.json may or may not exist — but the install should not fail
}
```

---

### TG-5 — Version test string hardcoded to `"AgToosa v3.1.0"`

**File:** `tests/agtoosa.bats` (line ~20)

**Problem:**
```bash
@test "--version outputs correct version string" {
  run bash "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == "AgToosa v3.1.0" ]]   # ← breaks on every version bump
}
```
This requires a manual bats edit on every release. It's listed as a known issue in TODOS.md but not yet fixed.

**Fix:** Extract the expected version dynamically:
```bash
EXPECTED_VER=$(grep -m1 '^AGTOOSA_VERSION=' "$SCRIPT" | cut -d'"' -f2)
[[ "$output" == "AgToosa v$EXPECTED_VER" ]]
```

---

### TG-6 — No bats test that `.agtoosa-version` is written on initial install

**File:** `tests/agtoosa.bats`

**Problem:**  
Tests verify `.agtoosa-version` is written by `--update` but not by the initial interactive install. The `install_files` bash function writes this file; the PS1 also writes it. Neither path is covered for fresh install.

**Fix:**
```bash
@test "initial install writes Docs/.agtoosa-version" {
  run bash -c "printf '$TEST_PROJECT\n3\nY\n' | bash '$SCRIPT'"
  [ "$status" -eq 0 ]
  [ -f "$TEST_PROJECT/Docs/.agtoosa-version" ]
  [[ "$(cat "$TEST_PROJECT/Docs/.agtoosa-version")" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}
```

---

### TG-7 — No bats test for registry_publish unsanitized JSON output

**File:** `tests/agtoosa.bats`

**Problem:**  
`registry_publish` uses `printf '{\n  "name": "%s",\n  ...' "$pub_name" "$pub_desc" "$pub_version"` with no escaping. A pack name containing `"` or `\n` produces malformed JSON. Not tested.

**Fix:** Add a unit test that runs `registry_publish` with a name containing `"` and validates the output with a JSON parser.

---

## 4. Platform Parity Issues (bash vs. PowerShell)

| Feature | bash (`agtoosa.sh`) | PowerShell (`agtoosa.ps1`) |
|---|---|---|
| Registry JSON schema | `.[]` (flat array) | `.packs` field (WRONG — see CB-2) |
| inject_version | ✅ START/END markers on platform files | ❌ Raw copy — no markers |
| merge_platform_file | ✅ 4 cases (new/older/old-format/user-owned) | ❌ Simple copy/skip/backup only |
| Native platform dirs | ✅ All 6 dir trees installed | ❌ None installed (entry-point files only) |
| Context/ stubs | ✅ 4 files copied | ❌ Not copied (non-recursive dir read) |
| .claude/settings.json merge | ✅ python3 deep-merge, deduplicated | ❌ Not implemented |
| --update platform detection | ✅ Detects installed platforms, merges each | ❌ Runs with empty platform list (Docs only) |
| registry publish | ✅ Interactive wizard | ❌ Not implemented |
| --list-template-files | ✅ Implemented | ❌ Not implemented |
| Exit cleanup | ✅ `trap _cleanup EXIT` | ⚠️ try/finally in install only; registry dispatch has no cleanup |
| Preflight checks | ✅ Checks template/ AND lib/ | ⚠️ Only checks template/ |
| VS Code (option 6) | ✅ Separate `USE_VSCODE` flag | ⚠️ Mapped to "copilot" (same files as option 5) |

**Priority for fixing:** Items 1–6 above (registry schema, inject_version, merge logic, native dirs, Context/ stubs, settings.json) make a PS1 install functionally incomplete for production use.

---

## 5. UX / Message Issues

### UX-1 — Registry install success message is factually wrong

**File:** `lib/registry.sh` (`registry_install`)

After staging files, the function prints:
```
Run 'bash agtoosa.sh' in your project to merge the pack files.
```
But ship/ is deleted milliseconds later by the EXIT trap (CB-1). The instruction is wrong. Fix alongside CB-1.

---

### UX-2 — Template entry-point files hardcode "Linear project `AgToosa`"

**Files:** `template/AGENTS.md`, `template/CLAUDE.md`, `template/OPENCODE.md`

All three files contain a reference to Linear project `AgToosa` which is the AgToosa maintainer's own Linear workspace. When copied into a user's project, this reference is misleading — their Linear project won't be named "AgToosa".

**Fix:** Replace with a placeholder:
```markdown
<!-- TODO: Update with your Linear project name -->
Linear project: `[YOUR-PROJECT-NAME]`
```
Or remove the reference entirely and let `/agtoosa-init` guide the user to set it up.

---

### UX-3 — `bootstrap.sh` references "macOS 26+"

**File:** `bootstrap.sh`

The script contains: `"macOS 26+ ships with bash 5.2+, git, curl, tar by default."` macOS 26 does not exist (current is macOS 15 Sequoia). This is either a future-dated speculation or a typo for macOS 12+.

**Fix:** Change to: `"macOS 12+ (Monterey and later) ships with git, curl, and tar. bash 5.x requires Homebrew: brew install bash"`

---

### UX-4 — `generate.sh` uses `\u2705` escape for OpenCode; all others use `✅` directly

**File:** `lib/generate.sh` (OpenCode block)

```bash
echo -e "  ${GREEN}\u2705${NC} OPENCODE.md ..."
```
All other platform blocks use the literal `✅` character. `\u2705` requires bash 4.4+ and certain locale settings to render correctly; the literal character works everywhere.

**Fix:** Replace `\u2705` with `✅` to match all other platform blocks.

---

### UX-5 — `registry_info` exits 0 when pack is not found

**File:** `lib/registry.sh` (`registry_info`)

When `jq` returns empty output for an unknown pack name, the function prints nothing and exits 0. A user running `--registry info nonexistent-pack` gets blank output with no error.

**Fix:**
```bash
if [[ -z "$pack_entry" ]]; then
    echo -e "${RED}❌ Pack '${pack_name}' not found in registry.${NC}" >&2
    return 1
fi
```
Apply the same pattern to `registry_search` (no results should print a "No packs found" message).

---

### UX-6 — `backup_file` has minute-level precision; two backups in the same minute overwrite each other

**File:** `lib/copy.sh` (`backup_file`)

```bash
bak="${f}.bak.$(date +%Y%m%d-%H%M)"
```
If `--force` is run twice within the same minute on the same file, the second backup overwrites the first. While rare, this silently destroys the first backup.

**Fix:** Change to seconds: `date +%Y%m%d-%H%M%S`  
Same fix needed in `agtoosa.ps1`: `Get-Date -Format "yyyyMMdd-HHmmss"`

---

## 6. Security Issues

### SI-1 — jq injection via user-controlled strings (HIGH)

**File:** `lib/registry.sh` (functions `registry_search`, `registry_info`, `registry_install`)

Documented in CB-3 above. Severity is HIGH for a public release: any user running `bash agtoosa.sh --registry search <crafted-input>` is affected.

**Fix:** Use `jq --arg` for all user-supplied strings (see CB-3 fix section).

---

### SI-2 — PowerShell `cmd /c tar` with unsanitized paths allows command injection (HIGH)

**File:** `agtoosa.ps1` (`Invoke-RegistryInstall`)

```powershell
cmd /c "tar -xzf `"$tmpFile`" -C `"$packDir`""
```
If `$tmpFile` or `$packDir` contain characters that are special to cmd.exe (`&`, `|`, `;`, etc.), they break out of the quoted context. On Windows, temp directories created by `[System.IO.Path]::GetTempPath()` can contain user-controlled path segments in enterprise environments.

**Fix:** Use PowerShell's own process invocation, which does not go through cmd.exe:
```powershell
$proc = Start-Process -FilePath "tar" `
    -ArgumentList @("-xzf", $tmpFile, "-C", $packDir) `
    -Wait -NoNewWindow -PassThru
if ($proc.ExitCode -ne 0) { throw "tar extraction failed" }
```

---

### SI-3 — `validate_pack_files` does not prevent path traversal (MEDIUM)

**File:** `lib/registry.sh` (`validate_pack_files`)

The function validates file extensions but not file paths. A tarball containing `../../.bashrc` would pass extension validation (`.bashrc` → ext=`bashrc` → rejected because not in allowed list). However, a file named `../../../../.ssh/authorized_keys.md` has extension `.md` which IS allowed, and could be extracted to an arbitrary location on the filesystem.

**Fix:** After extraction, validate that all file paths within the pack resolve to within the pack directory:
```bash
while IFS= read -r -d '' file; do
    real_file=$(realpath "$file" 2>/dev/null || echo "$file")
    real_dir=$(realpath "$dir")
    if [[ "$real_file" != "$real_dir"/* ]]; then
        echo "Error: Pack contains path traversal: $file" >&2
        return 1
    fi
    # existing extension check follows...
done < <(find "$dir" -type f -print0)
```

---

### SI-4 — `registry_publish` embeds unsanitized user input in raw JSON (MEDIUM)

**File:** `lib/registry.sh` (`registry_publish`)

```bash
printf '  "name": "%s",\n  "description": "%s",\n  "version": "%s",...' \
    "$pub_name" "$pub_desc" "$pub_version"
```
A pack name containing `"` or a newline produces malformed JSON. The generated PR JSON would fail registry validation, but the error message would be confusing.

**Fix:** Use `jq -n` to build the JSON safely:
```bash
jq -n \
  --arg name "$pub_name" \
  --arg desc "$pub_desc" \
  --arg version "$pub_version" \
  --arg author "$pub_author" \
  --arg url "$pub_url" \
  --arg sha "$pub_sha" \
  '{name: $name, description: $desc, version: $version, author: $author, url: $url, sha256: $sha}'
```

---

### SI-5 — Registry JSON itself is not integrity-verified (LOW)

**File:** `lib/registry.sh` (`fetch_registry`)

Pack tarballs are SHA-256 verified against values in `registry.json`. However, `registry.json` itself is downloaded over HTTPS without GPG or checksum verification. A MITM or compromised CDN could serve a modified registry.json pointing to malicious pack URLs with attacker-controlled SHA-256 values.

**Note:** HTTPS provides reasonable protection for most threat models. This is LOW severity for a community project. Document the trust model explicitly.

**Fix:** Add a `# SECURITY NOTE: registry.json is trusted via HTTPS only. Verify pack SHA-256 values independently for high-security environments.` comment in the fetch function, and consider publishing a GPG-signed registry manifest in a future release.

---

## 7. Documentation Gaps

### DG-1 — `CONTRIBUTING.md` has incorrect bats invocation and missing dev prereqs

**File:** `CONTRIBUTING.md`

```markdown
bash tests/agtoosa.bats    ← wrong; this will not work
```
Correct invocation requires `bats-core` installed and is:
```bash
bats tests/agtoosa.bats
```
The contributing guide also does not list `bats-core` as a development dependency. New contributors following the guide will not be able to run tests.

**Fix:**
1. Add to dev prerequisites: `brew install bats-core` (macOS) / `apt install bats` (Linux)
2. Change the example to `bats tests/agtoosa.bats`

---

### DG-2 — README does not warn that `agtoosa.ps1` is feature-limited

**File:** `README.md`

The Windows install section presents `agtoosa.ps1` as the equivalent of `agtoosa.sh`. Users on Windows selecting Claude Code, Cursor, or Gemini CLI will install only the top-level entry-point file and none of the native platform integration (slash commands, rules, prompts, agents, hooks). There is no warning about this.

**Fix:** Add a note under the Windows install section:
```markdown
> **Note:** `agtoosa.ps1` currently installs entry-point platform files only.
> Native platform directories (`.claude/commands/`, `.cursor/rules/`, etc.)
> require the bash installer via Git Bash or WSL2: `bash agtoosa.sh`
```

---

### DG-3 — `AgToosa_Registry.md` Step 5 describes `ship/` as being in the user's project

**File:** `template/Docs/AgToosa_Registry.md`

Step 5 of the Installation Flow says:
> **Stage** the pack files into your project's `ship/` directory.

`ship/` is a temporary staging directory in the AgToosa *source clone*, not in the user's project. This is confusing for users who installed AgToosa via Homebrew (no source clone) or bootstrap (temporary extraction).

**Fix:** Revise Step 5:
> **Stage** — AgToosa downloads the pack and stages it internally. When you next run `bash agtoosa.sh /path/to/project`, the pack is merged automatically.

---

### DG-4 — `OPTIONAL_TEMPLATE_FILES` in `lib/config.sh` is defined but never used

**File:** `lib/config.sh`

The `OPTIONAL_TEMPLATE_FILES` array is defined and is included in `print_template_files` output (used by `--list-template-files` and the CI template-completeness check). However, it is never iterated or referenced in `generate.sh`, `install.sh`, or `update.sh`. Its purpose is undocumented.

This is confusing for contributors who may assume these files are somehow optionally staged but have no code to do so.

**Fix:** Either:
- Add a comment: `# Listed for --list-template-files completeness check only; copied as part of platform-specific blocks above`
- Or remove if truly unused

---

### DG-5 — `jq` not documented as recommended dependency

**File:** `README.md`, `bootstrap.sh`

The registry feature degrades significantly without `jq`:
- `registry_list` falls back to `grep` (loses formatting, author, URL fields)
- `registry_install` fails entirely (no `jq` = no SHA-256 extraction from registry entry)
- `_write_lock_file` fails to merge existing entries

`jq` is never mentioned in README or bootstrap dependency checks.

**Fix:**
1. Add `jq` to the "Optional but recommended" section in README
2. In `registry_install`, check for `jq` early and exit with a clear message if absent:
   ```bash
   if ! command -v jq &>/dev/null; then
       echo -e "${RED}❌ Error: jq is required for registry install.${NC}"
       echo -e "  macOS: brew install jq | Linux: apt install jq"
       exit 1
   fi
   ```

---

### DG-6 — README version badge is hardcoded

**File:** `README.md`

```markdown
[![Version](https://img.shields.io/badge/version-3.1.0-green.svg)](...)
```
This badge will show `3.1.0` indefinitely until manually updated after each release.

**Fix:** Use a dynamic badge from the GitHub tags API:
```markdown
[![Version](https://img.shields.io/github/v/tag/sky2464/AgToosa?label=version&color=green)](...)
```

---

## 8. CI Issues

### CI-1 — `release.yml` uses deprecated `actions/create-release@v1`

**File:** `.github/workflows/release.yml`

`actions/create-release` was archived in 2021. It still functions but receives no security updates and its underlying API calls may deprecate.

**Fix:** Replace with `softprops/action-gh-release`:
```yaml
- name: Create GitHub Release
  uses: softprops/action-gh-release@v2
  with:
    tag_name: ${{ steps.tag.outputs.tag }}
    name: AgToosa ${{ steps.tag.outputs.tag }}
    body: ${{ steps.changelog.outputs.content }}
    draft: false
    prerelease: false
```

---

### CI-2 — `release.yml` uses deprecated multiline output encoding

**File:** `.github/workflows/release.yml`

The changelog extraction step uses the old `%0A`-escaping approach for multiline values in `$GITHUB_OUTPUT`. GitHub deprecated this encoding in favor of heredoc delimiters.

**Fix:**
```yaml
- name: Extract changelog
  id: changelog
  run: |
    {
      echo "content<<EOF"
      # ... extraction logic ...
      echo "EOF"
    } >> "$GITHUB_OUTPUT"
```

---

### CI-3 — BATS installed by tag, not commit SHA

**File:** `.github/workflows/ci.yml`, `.github/workflows/pre-release-checklist.yml`

```yaml
curl -sSL "https://github.com/bats-core/bats-core/archive/refs/tags/${BATS_VERSION}.tar.gz" -o bats.tar.gz
```
The BATS download is not pinned to a commit SHA. A tag can theoretically be moved. All other action pins in CI use commit SHAs — BATS should too.

**Fix:** Pin to the tarball SHA-256 or use `bats-core/bats-core` as a checked-out action with a commit SHA pin.

---

### CI-4 — TruffleHog pinned to "main" commit SHA

**File:** `.github/workflows/security-scan.yml`

```yaml
uses: trufflesecurity/trufflehog@abc1234...  # comment: "latest commit SHA of main"
```
This is a commit SHA of the main branch, not a release tag. The SHA can become stale (main advances) and there's no signal when to update it.

**Fix:** Pin to a release tag + SHA: `trufflesecurity/trufflehog@v3.x.y` with the corresponding commit SHA as a comment.

---

## Prioritized Fix Order for Public Release

### Must fix before release

| ID | Issue | Effort |
|---|---|---|
| CB-1 | Registry install destroys staged files | Small |
| CB-2 | PS1 registry JSON schema mismatch | Small |
| CB-3 | jq injection in registry_search/info/install | Small |
| CB-4 | merge_platform_file Case B loses version markers | Small |
| SI-1 | jq injection (same as CB-3, consolidated fix) | — |
| SI-2 | PS1 `cmd /c tar` command injection | Small |
| SI-3 | validate_pack_files path traversal | Small |
| UX-1 | Registry success message is factually wrong | Trivial |
| UX-2 | Template files hardcode "Linear project AgToosa" | Trivial |
| DG-1 | CONTRIBUTING.md incorrect bats invocation | Trivial |
| DG-2 | README missing PS1 feature gap warning | Trivial |

### Fix before or immediately after release

| ID | Issue | Effort |
|---|---|---|
| MF-1 | PS1: native dirs not installed | Large |
| MF-2 | PS1: Context/ stubs not copied | Small |
| MF-3 | PS1: no inject_version | Medium |
| TG-1 | No registry happy-path tests | Medium |
| TG-2 | CB-4 re-run regression test | Small |
| TG-3 | jq injection regression test | Small |
| CI-1 | Deprecated create-release action | Small |
| CI-2 | Deprecated multiline output encoding | Small |

### Nice to have

| ID | Issue | Effort |
|---|---|---|
| MF-4 | PS1: registry publish | Medium |
| MF-5 | PS1: settings.json merge | Medium |
| TG-4–7 | Remaining test gaps | Small each |
| UX-3–6 | Minor message/UX issues | Trivial each |
| SI-4–5 | registry_publish JSON safety, registry trust model | Small |
| DG-3–6 | Docs cleanup | Trivial each |
| CI-3–4 | BATS pin, TruffleHog pin | Trivial |
