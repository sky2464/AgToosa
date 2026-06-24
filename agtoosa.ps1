<#
.SYNOPSIS
    AgToosa — Spec-Driven Agentic AI Framework Generator (Windows PowerShell port)

.DESCRIPTION
    Interactive generator that copies AgToosa workflow files into your project.
    Equivalent to the bash agtoosa.sh on macOS / Linux.

.PARAMETER Force
    Overwrite existing files in the target project.

.PARAMETER DryRun
    Preview what would be copied without making any changes.

.PARAMETER Version
    Print the AgToosa version and exit.

.PARAMETER Help
    Show this help message and exit.

.PARAMETER Update
    Update an existing AgToosa install in the specified project path.

.PARAMETER UpdatePath
    Path to the project to update (used with -Update).

.PARAMETER Registry
    Access the AgToosa Community Template Registry.

.PARAMETER RegistryCommand
    Registry sub-command: list, search, info, or install. Native PowerShell publish prints a Bash/WSL/Git Bash redirect.

.PARAMETER RegistryArg
    Argument for the registry sub-command (keyword for search, pack name for info/install).

.EXAMPLE
    .\agtoosa.ps1
    .\agtoosa.ps1 -Force
    .\agtoosa.ps1 -DryRun
    .\agtoosa.ps1 -Update -UpdatePath C:\Projects\MyApp
    .\agtoosa.ps1 -Version
    .\agtoosa.ps1 -Registry -RegistryCommand list
    .\agtoosa.ps1 -Registry -RegistryCommand search -RegistryArg react
    .\agtoosa.ps1 -Registry -RegistryCommand info -RegistryArg my-pack
    .\agtoosa.ps1 -Registry -RegistryCommand install -RegistryArg my-pack
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$DryRun,
    [switch]$Version,
    [switch]$Help,
    [switch]$Update,
    [string]$UpdatePath = "",
    [switch]$Registry,
    [string]$RegistryCommand = "",
    [string]$RegistryArg = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Version ───────────────────────────────────────────────────
$AGTOOSA_VERSION = "5.3.0"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$TEMPLATE_DIR = Join-Path $SCRIPT_DIR "template"
$SHIP_DIR = Join-Path $SCRIPT_DIR "ship"
if ($env:AGTOOSA_PACK_QUEUE_DIR) {
    $PACK_QUEUE_DIR = $env:AGTOOSA_PACK_QUEUE_DIR
} else {
    $PACK_QUEUE_DIR = Join-Path $SCRIPT_DIR ".agtoosa\pack-queue"
}

# ── Colors (ANSI — requires Windows 10 v1511+ or Windows Terminal) ──
$ESC = [char]27
$RED    = "${ESC}[31m"
$GREEN  = "${ESC}[32m"
$YELLOW = "${ESC}[33m"
$CYAN   = "${ESC}[36m"
$PURPLE = "${ESC}[35m"
$BOLD   = "${ESC}[1m"
$NC     = "${ESC}[0m"

# ── Helpers ───────────────────────────────────────────────────
function Write-Color([string]$msg) { Write-Host $msg }

function Write-SelfTargetGuidance {
    Write-Color "${YELLOW}   --update is for downstream installed projects only.${NC}"
    Write-Color "${YELLOW}   In the AgToosa generator repo, follow docs/agtoosa-maintainer.md.${NC}"
    Write-Color "${YELLOW}   Do not create Docs/ or Docs/.agtoosa-version here.${NC}"
}

function Show-Usage {
    Write-Color @"
${BOLD}Usage:${NC}
  .\agtoosa.ps1 [options]

${BOLD}Options:${NC}
  -Force                Overwrite existing files
  -DryRun               Preview changes without applying them
  -Version              Print version and exit
  -Help                 Show this help
  -Update               Update an existing AgToosa install
  -UpdatePath <path>    Project path to update (used with -Update)

${BOLD}Registry:${NC}
  -Registry -RegistryCommand list               List available packs
  -Registry -RegistryCommand search -RegistryArg <kw>  Search packs
  -Registry -RegistryCommand info -RegistryArg <name>  Show pack details
  -Registry -RegistryCommand install -RegistryArg <name>  Install a pack
  -Registry -RegistryCommand publish            Print Bash/WSL/Git Bash publish guidance

${BOLD}Examples:${NC}
  .\agtoosa.ps1
  .\agtoosa.ps1 -Force
  .\agtoosa.ps1 -Update -UpdatePath C:\Projects\MyApp
  .\agtoosa.ps1 -DryRun
  .\agtoosa.ps1 -Registry -RegistryCommand list
  .\agtoosa.ps1 -Registry -RegistryCommand search -RegistryArg react
  .\agtoosa.ps1 -Registry -RegistryCommand install -RegistryArg my-pack
"@
}

function Test-Prerequisites {
    if (-not (Test-Path $TEMPLATE_DIR)) {
        Write-Color "${RED}❌ Error: template/ directory not found next to agtoosa.ps1.${NC}"
        Write-Color "${YELLOW}Run agtoosa.ps1 from the AgToosa repo directory.${NC}"
        exit 1
    }
}

function Get-InstalledVersion([string]$projectPath) {
    $agentFile = Join-Path $projectPath "Docs\AgToosa_Agent.md"
    if (-not (Test-Path $agentFile)) { return "unknown" }
    $line = Select-String -Path $agentFile -Pattern "AgToosa v\d+\.\d+\.\d+" | Select-Object -First 1
    if ($line) {
        if ($line.Line -match "AgToosa v(\d+\.\d+\.\d+)") { return $matches[1] }
    }
    return "unknown"
}

function Copy-FileWithGuard([string]$src, [string]$dst, [string]$label) {
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    if (-not (Test-Path $dst)) {
        Copy-Item $src $dst
        Write-Color "  ${GREEN}✅${NC} $label"
        return
    }

    if (-not $Force) {
        Write-Color "  ${YELLOW}⏭${NC}  Skipping $label (exists, use -Force to overwrite)"
        return
    }

    $ts = Get-Date -Format "yyyyMMdd-HHmm"
    $bak = "${dst}.bak.${ts}"
    Copy-Item $dst $bak
    Copy-Item $src $dst
    Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(backup: $(Split-Path -Leaf $bak))${NC}"
}

function Join-TemplatePath([string]$base, [string]$relativePath) {
    $normalized = $relativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar
    return Join-Path $base $normalized
}

function Copy-TemplateFile([string]$relativePath) {
    $src = Join-TemplatePath $TEMPLATE_DIR $relativePath
    $dst = Join-TemplatePath $SHIP_DIR $relativePath
    if (-not (Test-Path $src)) { return $false }
    $dir = Split-Path -Parent $dst
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Copy-Item $src $dst
    return $true
}

function Copy-TemplateDirectory([string]$relativePath) {
    $srcDir = Join-TemplatePath $TEMPLATE_DIR $relativePath
    if (-not (Test-Path $srcDir)) { return 0 }

    $count = 0
    foreach ($item in Get-ChildItem -Path $srcDir -Recurse -File) {
        $rel = $item.FullName.Substring($srcDir.Length).TrimStart('\', '/')
        $dst = Join-Path (Join-TemplatePath $SHIP_DIR $relativePath) $rel
        $dir = Split-Path -Parent $dst
        if ($dir -and -not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Copy-Item $item.FullName $dst
        $count++
    }
    return $count
}

function Copy-StagedDirectory([string]$relativePath, [string]$projectPath, [string]$label) {
    $srcDir = Join-TemplatePath $SHIP_DIR $relativePath
    if (-not (Test-Path $srcDir)) { return 0 }

    $count = 0
    Get-ChildItem -Path $srcDir -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($srcDir.Length).TrimStart('\', '/')
        $dst = Join-Path (Join-TemplatePath $projectPath $relativePath) $rel
        $dir = Split-Path -Parent $dst
        if ($dir -and -not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Copy-Item -Path $_.FullName -Destination $dst -Force
        $count++
    }
    if ($count -gt 0) {
        Write-Color "  ${GREEN}✅${NC} $label ($count files)"
    }
    return $count
}

# Extract AgToosa version from a file's START marker (shell or markdown comment).
function Get-AgToosaFileVersion([string]$path) {
    $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
    if ($content -match 'AgToosa v(\d+\.\d+\.\d+) START') { return $matches[1] }
    if ($content -match 'AgToosa v(\d+\.\d+\.\d+)') { return $matches[1] }
    return $null
}

# Returns $true if $a is less than $b (semantic version compare).
function Compare-AgToosaVersionLt([string]$a, [string]$b) {
    $pa = [version]::Parse($a); $pb = [version]::Parse($b)
    return $pa -lt $pb
}

# Merge-PlatformFile: 4-case merge for AgToosa-owned platform entry-point files.
# Case A: destination doesn't exist  → copy verbatim.
# Case B: destination has START/END block → replace block in-place (backup if older).
# Case C: destination has old AgToosa version marker, no block → replace file (backup).
# Case D: destination is user-owned (no AgToosa marker) → backup + append.
# -Force: backup + full replace, except same-or-newer version is preserved.
function Merge-PlatformFile([string]$src, [string]$dst, [string]$label) {
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    # Case A — new file
    if (-not (Test-Path $dst)) {
        Copy-Item $src $dst
        Write-Color "  ${GREEN}✅${NC} $label"
        return
    }

    $oldVer = Get-AgToosaFileVersion $dst
    $ts = Get-Date -Format "yyyyMMdd-HHmm"

    # --force path: backup + full replace (but preserve same-or-newer)
    if ($Force) {
        if ($oldVer -and -not (Compare-AgToosaVersionLt $oldVer $AGTOOSA_VERSION)) {
            Write-Color "  ${YELLOW}⏭${NC}  $label ${CYAN}(v${AGTOOSA_VERSION} — keeping your customizations)${NC}"
            return
        }
        $bak = "${dst}.bak.${ts}"
        Copy-Item $dst $bak
        Copy-Item $src $dst
        Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(v${oldVer} → v${AGTOOSA_VERSION}, backup: $(Split-Path -Leaf $bak))${NC}"
        return
    }

    $content = Get-Content $dst -Raw -ErrorAction SilentlyContinue

    # Case B — file has an AgToosa START/END delimited block
    if ($content -match 'AgToosa v\d+\.\d+\.\d+ START') {
        if ($oldVer -and -not (Compare-AgToosaVersionLt $oldVer $AGTOOSA_VERSION)) {
            Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(v${AGTOOSA_VERSION}, up to date)${NC}"
            return
        }
        $bak = "${dst}.bak.${ts}"
        Copy-Item $dst $bak
        # Strip existing block; use regex to remove everything from START line to END line (inclusive).
        $stripped = $content -replace '(?ms)(^|\r?\n)[^\r\n]*AgToosa v\d+\.\d+\.\d+ START.*?AgToosa END[^\r\n]*(\r?\n|$)', "`n"
        $stripped = $stripped.TrimEnd()
        $block = Get-Content $src -Raw
        "$stripped`n`n$block" | Set-Content $dst -NoNewline -Encoding UTF8
        Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(merged: v${oldVer} → v${AGTOOSA_VERSION}, backup: $(Split-Path -Leaf $bak))${NC}"
        return
    }

    # Case C — old-format AgToosa file (has version marker, no START/END)
    if ($oldVer) {
        if (-not (Compare-AgToosaVersionLt $oldVer $AGTOOSA_VERSION)) {
            Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(v${AGTOOSA_VERSION}, up to date)${NC}"
            return
        }
        $bak = "${dst}.bak.${ts}"
        Copy-Item $dst $bak
        Copy-Item $src $dst
        Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(v${oldVer} → v${AGTOOSA_VERSION}, backup: $(Split-Path -Leaf $bak))${NC}"
        return
    }

    # Case D — user-owned file: backup + append AgToosa block
    $bak = "${dst}.bak.${ts}"
    Copy-Item $dst $bak
    $block = Get-Content $src -Raw
    "$content`n`n$block" | Set-Content $dst -NoNewline -Encoding UTF8
    Write-Color "  ${GREEN}✅${NC} $label ${CYAN}(appended to existing file, backup: $(Split-Path -Leaf $bak))${NC}"
}


function Copy-StageFiles([string[]]$platforms) {
    $docsCount = Copy-TemplateDirectory "Docs"
    if ($docsCount -gt 0) {
        Write-Color "  ${GREEN}✅${NC} Docs\ ${CYAN}($docsCount workflow and context files)${NC}"
    }

    foreach ($p in $platforms) {
        switch ($p) {
            "cursor" {
                Copy-TemplateFile ".cursorrules" | Out-Null
                $ruleCount = Copy-TemplateDirectory ".cursor/rules"
                $commandCount = Copy-TemplateDirectory ".cursor/commands"
                Write-Color "  ${GREEN}✅${NC} .cursorrules ${CYAN}(Cursor)${NC}"
                if ($ruleCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .cursor/rules/ ${CYAN}($ruleCount rules)${NC}" }
                if ($commandCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .cursor/commands/ ${CYAN}($commandCount commands)${NC}" }
            }
            "windsurf" {
                Copy-TemplateFile ".windsurfrules" | Out-Null
                $ruleCount = Copy-TemplateDirectory ".windsurf/rules"
                $workflowCount = Copy-TemplateDirectory ".windsurf/workflows"
                Write-Color "  ${GREEN}✅${NC} .windsurfrules ${CYAN}(Windsurf)${NC}"
                if ($ruleCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .windsurf/rules/ ${CYAN}($ruleCount rules)${NC}" }
                if ($workflowCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .windsurf/workflows/ ${CYAN}($workflowCount workflows)${NC}" }
            }
            "claude" {
                Copy-TemplateFile "CLAUDE.md" | Out-Null
                $commandCount = Copy-TemplateDirectory ".claude/commands"
                $skillCount = Copy-TemplateDirectory ".claude/skills"
                $hookCount = Copy-TemplateDirectory ".claude/hooks"
                Copy-TemplateFile ".claude/settings.json" | Out-Null
                Write-Color "  ${GREEN}✅${NC} CLAUDE.md + Docs\AgToosa_Claude.md ${CYAN}(Claude Code)${NC}"
                if ($commandCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .claude/commands/ ${CYAN}($commandCount commands)${NC}" }
                if ($skillCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .claude/skills/ ${CYAN}($skillCount skills)${NC}" }
                if ($hookCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .claude/hooks/ ${CYAN}($hookCount hooks)${NC}" }
            }
            "gemini" {
                Copy-TemplateFile "AGENTS.md" | Out-Null
                $commandCount = Copy-TemplateDirectory ".gemini/commands"
                Write-Color "  ${GREEN}✅${NC} AGENTS.md + Docs\AgToosa_Gemini.md ${CYAN}(Gemini CLI / Jules)${NC}"
                if ($commandCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .gemini/commands/ ${CYAN}($commandCount commands)${NC}" }
            }
            "copilot" {
                Copy-TemplateFile ".github/copilot-instructions.md" | Out-Null
                $instructionCount = Copy-TemplateDirectory ".github/instructions"
                $promptCount = Copy-TemplateDirectory ".github/prompts"
                $agentCount = Copy-TemplateDirectory ".github/agents"
                Write-Color "  ${GREEN}✅${NC} .github\copilot-instructions.md ${CYAN}(GitHub Copilot)${NC}"
                if ($instructionCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .github/instructions/ ${CYAN}($instructionCount instructions)${NC}" }
                if ($promptCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .github/prompts/ ${CYAN}($promptCount prompts)${NC}" }
                if ($agentCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .github/agents/ ${CYAN}($agentCount agents)${NC}" }
            }
            "opencode" {
                if (Copy-TemplateFile "OPENCODE.md") {
                    $skillCount = Copy-TemplateDirectory ".codex/skills"
                    $promptCount = Copy-TemplateDirectory ".codex/prompts"
                    Write-Color "  ${GREEN}✅${NC} OPENCODE.md ${CYAN}(OpenCode)${NC}"
                    if ($skillCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .codex/skills/ ${CYAN}($skillCount skills)${NC}" }
                    if ($promptCount -gt 0) { Write-Color "  ${GREEN}✅${NC} .codex/prompts/ ${CYAN}($promptCount prompts)${NC}" }
                }
            }
        }
    }
}

function Get-InstalledPlatforms([string]$projectPath) {
    $platforms = [System.Collections.Generic.List[string]]::new()
    if (Test-Path (Join-Path $projectPath ".cursorrules")) { $platforms.Add("cursor") }
    if ((Test-Path (Join-Path $projectPath ".cursor\rules")) -or (Test-Path (Join-Path $projectPath ".cursor\commands"))) { if (-not $platforms.Contains("cursor")) { $platforms.Add("cursor") } }
    if (Test-Path (Join-Path $projectPath ".windsurfrules")) { $platforms.Add("windsurf") }
    if ((Test-Path (Join-Path $projectPath ".windsurf\rules")) -or (Test-Path (Join-Path $projectPath ".windsurf\workflows"))) { if (-not $platforms.Contains("windsurf")) { $platforms.Add("windsurf") } }
    if ((Test-Path (Join-Path $projectPath "CLAUDE.md")) -or (Test-Path (Join-Path $projectPath ".claude"))) { $platforms.Add("claude") }
    if ((Test-Path (Join-Path $projectPath "AGENTS.md")) -or (Test-Path (Join-Path $projectPath ".gemini"))) { $platforms.Add("gemini") }
    if ((Test-Path (Join-Path $projectPath ".github\copilot-instructions.md")) -or (Test-Path (Join-Path $projectPath ".github\prompts")) -or (Test-Path (Join-Path $projectPath ".github\agents"))) { $platforms.Add("copilot") }
    if ((Test-Path (Join-Path $projectPath "OPENCODE.md")) -or (Test-Path (Join-Path $projectPath ".codex"))) { $platforms.Add("opencode") }
    return $platforms.ToArray()
}

function Initialize-PackQueueDir {
    if (-not (Test-Path $PACK_QUEUE_DIR)) {
        New-Item -ItemType Directory -Path $PACK_QUEUE_DIR -Force | Out-Null
    }
}

function New-PackQueueDirectory([string]$packName) {
    Initialize-PackQueueDir
    $packDir = Join-Path $PACK_QUEUE_DIR $packName
    if (Test-Path $packDir) { Remove-Item -Recurse -Force $packDir }
    New-Item -ItemType Directory -Path $packDir -Force | Out-Null
    return $packDir
}

function ConvertTo-PackDirectoryLayout([string]$packDir, [string]$packName) {
    $nested = Join-Path $packDir $packName
    if (-not (Test-Path $nested -PathType Container)) { return }

    $topLevelItems = @(Get-ChildItem -Path $packDir -Force | Where-Object { $_.Name -ne $packName -and $_.Name -ne ".pack-meta.json" })
    if ($topLevelItems.Count -gt 0) { return }

    foreach ($item in Get-ChildItem -Path $nested -Force) {
        Move-Item -Path $item.FullName -Destination (Join-Path $packDir $item.Name) -Force
    }
    Remove-Item -Path $nested -Recurse -Force
}

# Return $true when $childPath is strictly under $parentPath (not a prefix collision).
function Test-PathUnderDirectory([string]$childPath, [string]$parentPath) {
    $child = [System.IO.Path]::GetFullPath($childPath).TrimEnd('\', '/')
    $parent = [System.IO.Path]::GetFullPath($parentPath).TrimEnd('\', '/')
    $sep = [System.IO.Path]::DirectorySeparatorChar
    return ($child.StartsWith($parent + $sep) -or $child.StartsWith($parent + '/'))
}

# Reject pack archives whose staging area contains sibling top-level roots.
function Assert-PackStageLayout([string]$stage, [string]$packName) {
    $topDirs = @()
    $topFiles = @()
    foreach ($item in Get-ChildItem -Path $stage -Force -ErrorAction SilentlyContinue) {
        if ($item.Name -eq '.pack-meta.json') { continue }
        if ($item.PSIsContainer) { $topDirs += $item } else { $topFiles += $item }
    }
    if ($topDirs.Count -gt 1) {
        Write-Color "${RED}❌ Pack archive contains multiple top-level directories (expected a single pack root).${NC}"
        return $false
    }
    if ($topDirs.Count -eq 1 -and $topFiles.Count -gt 0) {
        Write-Color "${RED}❌ Pack archive mixes top-level files with a directory layout.${NC}"
        return $false
    }
    if ($topDirs.Count -eq 1) {
        if ($topDirs[0].Name -ne $packName) {
            Write-Color "${RED}❌ Pack archive top-level directory '$($topDirs[0].Name)' does not match pack name '$packName'.${NC}"
            return $false
        }
        Write-Color "${RED}❌ Pack archive must use a flat layout or a single nested '$packName/' directory.${NC}"
        return $false
    }
    return $true
}

function Move-ShipPacksToQueue {
    $legacy = Join-Path $SHIP_DIR "packs"
    if (-not (Test-Path $legacy)) { return }
    Initialize-PackQueueDir
    foreach ($packDir in Get-ChildItem -Path $legacy -Directory) {
        $dest = Join-Path $PACK_QUEUE_DIR $packDir.Name
        if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
        Move-Item -Path $packDir.FullName -Destination $dest
    }
    if ((Get-ChildItem -Path $legacy -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
        Remove-Item -Path $legacy -Force -ErrorAction SilentlyContinue
    }
}

# Destinations a pack must never write to: executable-hook and CI surfaces.
$PACK_DENYLIST_PREFIXES = @('.claude/hooks/', '.github/workflows/')
$PACK_DENYLIST_FILES    = @('.claude/settings.json')

function Test-PackPathDenied([string]$relPath) {
    $norm = $relPath.Replace('\', '/').TrimStart('/')
    foreach ($f in $PACK_DENYLIST_FILES) {
        if ($norm -eq $f) { return $true }
    }
    foreach ($p in $PACK_DENYLIST_PREFIXES) {
        if ($norm.StartsWith($p)) { return $true }
    }
    return $false
}

# Reject tarballs with absolute-path or '..' members BEFORE extraction.
function Test-SafeTarArchive([string]$archivePath) {
    $members = tar -tzf $archivePath 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Color "${RED}❌ Unable to read archive member list (corrupt archive?).${NC}"
        return $false
    }
    foreach ($member in $members) {
        if ([string]::IsNullOrWhiteSpace($member)) { continue }
        if ($member.StartsWith('/') -or $member.StartsWith('\') -or $member -match '^[A-Za-z]:') {
            Write-Color "${RED}❌ Archive contains absolute path member: $member${NC}"
            return $false
        }
        if (('/' + $member.Replace('\', '/') + '/') -match '/\.\./') {
            Write-Color "${RED}❌ Archive contains path traversal member: $member${NC}"
            return $false
        }
    }
    return $true
}

# Port of bash validate_pack_files: extension allowlist + canonical-path
# containment so symlinks or crafted names cannot escape the pack directory.
function Test-PackFiles([string]$dir) {
    $allowed = @('md', 'json', 'toml', 'mdc')
    $canonicalDir = [System.IO.Path]::GetFullPath($dir).TrimEnd('\', '/')
    foreach ($file in Get-ChildItem -Path $dir -Recurse -File -Force) {
        $canonicalFile = [System.IO.Path]::GetFullPath($file.FullName)
        if (-not (Test-PathUnderDirectory $canonicalFile $canonicalDir)) {
            Write-Color "${RED}❌ Pack contains path traversal: $($file.FullName)${NC}"
            return $false
        }
        if ($file.LinkType) {
            $target = $file.ResolveLinkTarget($true)
            if ($target -and -not (Test-PathUnderDirectory ([System.IO.Path]::GetFullPath($target.FullName)) $canonicalDir)) {
                Write-Color "${RED}❌ Pack contains escaping link: $($file.FullName)${NC}"
                return $false
            }
        }
        if ($file.Name -eq '.pack-meta.json') { continue }
        $ext = $file.Extension.TrimStart('.')
        if ([string]::IsNullOrEmpty($ext) -or ($allowed -notcontains $ext)) {
            Write-Color "${RED}❌ Pack contains disallowed file type: $($file.FullName) (allowed: .md .json .toml .mdc)${NC}"
            return $false
        }
    }
    return $true
}

function Merge-PackFromDirectory([string]$packDir, [string]$packName, [string]$projectPath) {
    $allowed = @('md', 'json', 'toml', 'mdc')
    $count = 0
    $canonicalDir = [System.IO.Path]::GetFullPath($packDir).TrimEnd('\', '/')
    Get-ChildItem -Path $packDir -Recurse -File | ForEach-Object {
        if ($_.Name -eq '.pack-meta.json') { return }
        # Merge-time containment check (queue may have been modified).
        $canonicalFile = [System.IO.Path]::GetFullPath($_.FullName)
        if (-not (Test-PathUnderDirectory $canonicalFile $canonicalDir)) {
            Write-Color "  ${YELLOW}⏭${NC}  Skipping path-escaping file: $($_.FullName)"
            return
        }
        $ext = $_.Extension.TrimStart('.')
        if ($allowed -notcontains $ext) { return }
        $rel = $_.FullName.Substring($packDir.Length).TrimStart('\', '/')
        if (Test-PackPathDenied $rel) {
            Write-Color "  ${YELLOW}⛔${NC} Skipping sensitive destination: $rel (packs may not write hook or CI surfaces)"
            return
        }
        $dst = Join-Path $projectPath $rel
        $dstParent = Split-Path $dst -Parent
        if ($dstParent -and -not (Test-Path $dstParent)) {
            New-Item -ItemType Directory -Path $dstParent -Force | Out-Null
        }
        Copy-Item -Path $_.FullName -Destination $dst -Force
        $count++
    }
    Write-Color "  ${GREEN}✅${NC} Pack '${packName}': ${count} files merged"
    return $count
}

function Merge-PacksUnderRoot([string]$packsRoot, [string]$projectPath, [bool]$clearAfter) {
    $packCount = 0
    $metaFiles = [System.Collections.Generic.List[string]]::new()
    if (-not (Test-Path $packsRoot)) {
        return @{ Count = 0; MetaFiles = @() }
    }
    foreach ($packDir in Get-ChildItem -Path $packsRoot -Directory) {
        $null = Merge-PackFromDirectory $packDir.FullName $packDir.Name $projectPath
        $packCount++
        $meta = Join-Path $packDir.FullName ".pack-meta.json"
        if (Test-Path $meta) { $metaFiles.Add($meta) }
        if ($clearAfter) {
            Remove-Item -Path $packDir.FullName -Recurse -Force
        }
    }
    return @{ Count = $packCount; MetaFiles = $metaFiles.ToArray() }
}

function Update-LockFileFromPackMeta([string]$projectPath, [string[]]$metaFiles) {
    if ($metaFiles.Count -eq 0) { return }
    $lockFile = Join-Path $projectPath "Docs\agtoosa-lock.json"
    $timestamp = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $existingPacks = @()
    if (Test-Path $lockFile) {
        try {
            $existing = Get-Content $lockFile -Raw | ConvertFrom-Json
            if ($existing.packs) { $existingPacks = @($existing.packs) }
        } catch { $existingPacks = @() }
    }
    $newNames = @()
    $newEntries = @()
    foreach ($metaPath in $metaFiles) {
        $entry = Get-Content $metaPath -Raw | ConvertFrom-Json
        $newNames += $entry.name
        $newEntries += $entry
    }
    $kept = @($existingPacks | Where-Object { $newNames -notcontains $_.name })
    $allPacks = @($kept) + @($newEntries)
    $lock = [ordered]@{
        agtoosa_version = $AGTOOSA_VERSION
        generated_at    = $timestamp
        packs           = $allPacks
    }
    $lock | ConvertTo-Json -Depth 5 | Out-File -FilePath $lockFile -Encoding UTF8
    Write-Color "  ${GREEN}✅${NC} Docs/agtoosa-lock.json updated"
}

function Install-Files([string]$projectPath, [string[]]$platforms) {
    $shipDocs = Join-Path $SHIP_DIR "Docs"
    if (Test-Path $shipDocs) {
        $dstDocs = Join-Path $projectPath "Docs"
        New-Item -ItemType Directory -Path $dstDocs -Force | Out-Null
        Get-ChildItem -Path $shipDocs -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($shipDocs.Length).TrimStart('\', '/')
            Copy-FileWithGuard $_.FullName (Join-Path $dstDocs $rel) "Docs\$rel"
        }
    }

    foreach ($p in $platforms) {
        switch ($p) {
            "cursor" {
                $src = Join-Path $SHIP_DIR ".cursorrules"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath ".cursorrules") ".cursorrules" }
                Copy-StagedDirectory ".cursor/rules" $projectPath ".cursor/rules/" | Out-Null
                Copy-StagedDirectory ".cursor/commands" $projectPath ".cursor/commands/" | Out-Null
            }
            "windsurf" {
                $src = Join-Path $SHIP_DIR ".windsurfrules"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath ".windsurfrules") ".windsurfrules" }
                Copy-StagedDirectory ".windsurf/rules" $projectPath ".windsurf/rules/" | Out-Null
                Copy-StagedDirectory ".windsurf/workflows" $projectPath ".windsurf/workflows/" | Out-Null
            }
            "claude" {
                $src = Join-Path $SHIP_DIR "CLAUDE.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath "CLAUDE.md") "CLAUDE.md" }
                Copy-StagedDirectory ".claude/commands" $projectPath ".claude/commands/" | Out-Null
                Copy-StagedDirectory ".claude/skills" $projectPath ".claude/skills/" | Out-Null
                Copy-StagedDirectory ".claude/hooks" $projectPath ".claude/hooks/" | Out-Null
                $settingsSrc = Join-Path $SHIP_DIR ".claude/settings.json"
                if (Test-Path $settingsSrc) {
                    Copy-FileWithGuard $settingsSrc (Join-Path $projectPath ".claude/settings.json") ".claude/settings.json"
                }
            }
            "gemini" {
                $src = Join-Path $SHIP_DIR "AGENTS.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath "AGENTS.md") "AGENTS.md" }
                Copy-StagedDirectory ".gemini/commands" $projectPath ".gemini/commands/" | Out-Null
            }
            "copilot" {
                $ghDir = Join-Path $projectPath ".github"
                New-Item -ItemType Directory -Path $ghDir -Force | Out-Null
                $src = Join-Path $SHIP_DIR ".github\copilot-instructions.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $ghDir "copilot-instructions.md") ".github\copilot-instructions.md" }
                Copy-StagedDirectory ".github/prompts" $projectPath ".github/prompts/" | Out-Null
                Copy-StagedDirectory ".github/agents" $projectPath ".github/agents/" | Out-Null
                Copy-StagedDirectory ".github/instructions" $projectPath ".github/instructions/" | Out-Null
            }
            "opencode" {
                $src = Join-Path $SHIP_DIR "OPENCODE.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath "OPENCODE.md") "OPENCODE.md" }
                Copy-StagedDirectory ".codex/skills" $projectPath ".codex/skills/" | Out-Null
                Copy-StagedDirectory ".codex/prompts" $projectPath ".codex/prompts/" | Out-Null
            }
        }
    }

    # Create empty Context/ and archived/ stubs if not present
    $ctxDir = Join-Path $projectPath "Docs\Context"
    if (-not (Test-Path $ctxDir)) { New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null }
    $archDir = Join-Path $projectPath "Docs\archived"
    if (-not (Test-Path $archDir)) { New-Item -ItemType Directory -Path $archDir -Force | Out-Null }

    # Merge durable pack queue, then any same-session ship\packs staging.
    $queueResult = Merge-PacksUnderRoot $PACK_QUEUE_DIR $projectPath $true
    $shipResult  = Merge-PacksUnderRoot (Join-Path $SHIP_DIR "packs") $projectPath $false
    $totalPacks  = [int]$queueResult["Count"] + [int]$shipResult["Count"]
    if ($totalPacks -gt 0) {
        Write-Color "  ${GREEN}✅${NC} Packs merged: $totalPacks"
    }
    $allMeta = @($queueResult.MetaFiles) + @($shipResult.MetaFiles)
    if ($allMeta.Count -gt 0) {
        Update-LockFileFromPackMeta $projectPath $allMeta
    }
}

# ── Registry ──────────────────────────────────────────────────
if ($env:AGTOOSA_REGISTRY_URL) {
    $REGISTRY_URL = $env:AGTOOSA_REGISTRY_URL
} else {
    $REGISTRY_URL = "https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json"
}

function Invoke-RegistryFetch {
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { [System.IO.Path]::GetTempPath() }
    $cacheDir  = Join-Path $homeDir ".cache\agtoosa"
    $cacheFile = "$cacheDir\registry.json"
    $cacheTTL  = 3600

    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }

    if (Test-Path $cacheFile) {
        $ageSeconds = ([DateTimeOffset]::UtcNow - (Get-Item $cacheFile).LastWriteTime).TotalSeconds
        if ($ageSeconds -lt $cacheTTL) {
            return (Get-Content $cacheFile -Raw)
        }
    }

    try {
        if ($REGISTRY_URL -like "file://*") {
            $localPath = $REGISTRY_URL.Substring(7)
            Copy-Item -Path $localPath -Destination $cacheFile -Force
        } else {
            Invoke-WebRequest -Uri $REGISTRY_URL -OutFile $cacheFile -UseBasicParsing | Out-Null
        }
        return (Get-Content $cacheFile -Raw)
    } catch {
        if (Test-Path $cacheFile) {
            Write-Color "${YELLOW}⚠️  Registry fetch failed; using cached copy.${NC}"
            return (Get-Content $cacheFile -Raw)
        }
        Write-Color "${RED}❌ Failed to fetch registry and no cache available: $_${NC}"
        exit 1
    }
}

function Show-RegistryList {
    $json  = Invoke-RegistryFetch
    $packs = @($json | ConvertFrom-Json)
    foreach ($pack in $packs) {
        Write-Color "$($pack.name) v$($pack.version) — $($pack.description) (by $($pack.author))"
    }
}

function Show-RegistrySearch([string]$query) {
    $json  = Invoke-RegistryFetch
    $packs = @($json | ConvertFrom-Json)
    foreach ($pack in $packs) {
        if ($pack.name -like "*$query*" -or $pack.description -like "*$query*") {
            Write-Color "$($pack.name) v$($pack.version) — $($pack.description) (by $($pack.author))"
        }
    }
}

function Show-RegistryInfo([string]$packName) {
    $json  = Invoke-RegistryFetch
    $packs = @($json | ConvertFrom-Json)
    $pack  = $packs | Where-Object { $_.name -eq $packName } | Select-Object -First 1
    if (-not $pack) {
        Write-Color "${RED}❌ Pack '$packName' not found in registry.${NC}"
        exit 1
    }
    Write-Color "${BOLD}Name:${NC}        $($pack.name)"
    Write-Color "${BOLD}Description:${NC} $($pack.description)"
    Write-Color "${BOLD}Author:${NC}      $($pack.author)"
    Write-Color "${BOLD}Version:${NC}     $($pack.version)"
    Write-Color "${BOLD}URL:${NC}         $($pack.url)"
    Write-Color "${BOLD}Verified:${NC}    $($pack.verified)"
}

function Invoke-RegistryInstall([string]$packSpec) {
    # Parse optional name@version syntax
    $packName    = $packSpec
    $packVersion = ""
    if ($packSpec -match "^(.+)@(.+)$") {
        $packName    = $matches[1]
        $packVersion = $matches[2]
    }

    $json  = Invoke-RegistryFetch
    $packs = @($json | ConvertFrom-Json)
    if ($packVersion -ne "") {
        $pack = $packs | Where-Object { $_.name -eq $packName -and $_.version -eq $packVersion } | Select-Object -First 1
        if (-not $pack) {
            $available = ($packs | Where-Object { $_.name -eq $packName } | ForEach-Object { $_.version }) -join ', '
            if ([string]::IsNullOrEmpty($available)) {
                Write-Color "${RED}❌ Pack '$packName' not found in registry.${NC}"
            } else {
                Write-Color "${RED}❌ Pack '$packName' version '$packVersion' not found in registry (available: $available).${NC}"
            }
            exit 1
        }
    } else {
        $pack = $packs | Where-Object { $_.name -eq $packName } | Select-Object -First 1
        if (-not $pack) {
            Write-Color "${RED}❌ Pack '$packName' not found in registry.${NC}"
            exit 1
        }
    }

    # Enforce the registry verified flag. Unverified packs require explicit opt-in.
    $packVerified = $false
    if ($pack.PSObject.Properties['verified'] -and $pack.verified -eq $true) { $packVerified = $true }
    if (-not $packVerified -and $env:AGTOOSA_ALLOW_UNVERIFIED -ne '1') {
        Write-Color "${RED}❌ Pack '$packName' is not verified in the registry.${NC}"
        Write-Color "Unverified packs have not passed maintainer review."
        Write-Color "To install anyway, set AGTOOSA_ALLOW_UNVERIFIED=1 and retry."
        exit 1
    }

    $confirm = Read-Host "Installing: $packName v$($pack.version) — Continue? (Y/n)"
    if ([string]::IsNullOrEmpty($confirm)) { $confirm = "Y" }
    if ($confirm -notmatch "^[Yy]$") {
        Write-Color "${YELLOW}Aborted.${NC}"
        exit 0
    }

    $url     = $pack.url
    $tmpFile = [System.IO.Path]::GetTempFileName() + ".tar.gz"

    try {
        Write-Color "${CYAN}Downloading $packName...${NC}"
        if ($url -like "file://*") {
            $localPath = $url.Substring(7)
            Copy-Item -Path $localPath -Destination $tmpFile -Force
        } else {
            Invoke-WebRequest -Uri $url -OutFile $tmpFile -UseBasicParsing | Out-Null
        }
    } catch {
        Write-Color "${RED}❌ Failed to download pack: $_${NC}"
        exit 1
    }

    # Verify SHA-256
    $actualHash   = (Get-FileHash $tmpFile -Algorithm SHA256).Hash.ToLower()
    $expectedHash = $pack.sha256.ToLower()
    if ($actualHash -ne $expectedHash) {
        Write-Color "${RED}❌ SHA-256 mismatch! Expected: $expectedHash  Got: $actualHash${NC}"
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    $tarAvailable = $null -ne (Get-Command tar -ErrorAction SilentlyContinue)
    if (-not $tarAvailable) {
        Write-Color "${RED}❌ tar is not available on this system. Cannot extract the pack tarball.${NC}"
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    # Reject hostile member paths BEFORE any extraction happens.
    if (-not (Test-SafeTarArchive $tmpFile)) {
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    # Extract to durable pack queue (survives ship\ rebuild on next agtoosa.ps1 run).
    $packDir = New-PackQueueDirectory $packName

    $proc = Start-Process -NoNewWindow -Wait -PassThru -FilePath tar -ArgumentList @('-xzf', $tmpFile, '-C', $packDir)
    if ($proc.ExitCode -ne 0) {
        Write-Color "${RED}❌ Extraction failed (tar exit code $($proc.ExitCode)).${NC}"
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    ConvertTo-PackDirectoryLayout $packDir $packName

    if (-not (Assert-PackStageLayout $packDir $packName)) {
        Remove-Item -Recurse -Force $packDir -ErrorAction SilentlyContinue
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    # Validate extracted content (extension allowlist + containment) — parity
    # with the bash validate_pack_files gate.
    if (-not (Test-PackFiles $packDir)) {
        Remove-Item -Recurse -Force $packDir -ErrorAction SilentlyContinue
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    Remove-Item $tmpFile -ErrorAction SilentlyContinue

    # Write pack metadata
    $metaFile = Join-Path $packDir ".pack-meta.json"
    $meta = [ordered]@{
        name         = $packName
        version      = $pack.version
        sha256       = $actualHash
        installed_at = [DateTimeOffset]::UtcNow.ToString("o")
        source       = "registry"
    }
    $meta | ConvertTo-Json | Out-File -FilePath $metaFile -Encoding UTF8

    Write-Color "${GREEN}✅ Pack '$packName' v$($pack.version) queued at '$packDir'.${NC}"
    Write-Color "Run '.\agtoosa.ps1' in your project to merge queued packs."
    $script:keepShip = $true
}

# ── Cleanup on exit ───────────────────────────────────────────
$keepShip = $false
function Remove-ShipDir {
    if (-not $keepShip -and (Test-Path $SHIP_DIR)) {
        Remove-Item -Recurse -Force $SHIP_DIR -ErrorAction SilentlyContinue
    }
}

# ── Preflight ─────────────────────────────────────────────────
Test-Prerequisites

# ── OS note ───────────────────────────────────────────────────
if ($IsLinux -or $IsMacOS) {
    Write-Color "${YELLOW}⚠️  You are running the PowerShell port on a Unix system.${NC}"
    Write-Color "${YELLOW}   Consider using the bash version: bash agtoosa.sh${NC}"
    Write-Color ""
}

# ── --version ─────────────────────────────────────────────────
if ($Version) {
    Write-Host "AgToosa v${AGTOOSA_VERSION}"
    exit 0
}

# ── --help ────────────────────────────────────────────────────
if ($Help) {
    Show-Usage
    exit 0
}

# ── --registry ────────────────────────────────────────────────
if ($Registry) {
    switch ($RegistryCommand) {
        "list"    { Show-RegistryList; exit 0 }
        "search"  { Show-RegistrySearch $RegistryArg; exit 0 }
        "info"    { Show-RegistryInfo $RegistryArg; exit 0 }
        "install" { Invoke-RegistryInstall $RegistryArg; exit 0 }
        "publish" {
            Write-Color "${YELLOW}ℹ️  Registry publish is not available in the PowerShell port.${NC}"
            Write-Color "Use the Bash implementation (canonical for v1):"
            Write-Color "  bash agtoosa.sh --registry publish [path-to-pack]"
            exit 0
        }
        default   {
            Write-Color "${RED}❌ Unknown registry command '$RegistryCommand'. Use list, search, info, install.${NC}"
            exit 1
        }
    }
}

# ── --update ──────────────────────────────────────────────────
if ($Update) {
    if ([string]::IsNullOrEmpty($UpdatePath)) {
        $UpdatePath = Read-Host "Project path to update"
    }
    $UpdatePath = $UpdatePath.TrimEnd('\', '/')

    if (-not (Test-Path $UpdatePath -PathType Container)) {
        Write-Color "${RED}❌ Error: Directory '$UpdatePath' does not exist.${NC}"
        exit 1
    }

    $resolvedProject = Resolve-Path $UpdatePath
    $resolvedScript  = Resolve-Path $SCRIPT_DIR
    if ($resolvedProject.Path -eq $resolvedScript.Path) {
        Write-Color "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}"
        Write-SelfTargetGuidance
        exit 1
    }

    if (-not (Test-Path (Join-Path $UpdatePath "Docs"))) {
        Write-Color "${RED}❌ Error: No Docs\ directory found in '$UpdatePath'.${NC}"
        Write-Color "${YELLOW}Run the full install first: .\agtoosa.ps1${NC}"
        exit 1
    }

    $oldVersion = Get-InstalledVersion $UpdatePath
    Write-Color ""
    Write-Color "${PURPLE}${BOLD}Updating AgToosa v${oldVersion} → v${AGTOOSA_VERSION}${NC}"
    Write-Color "${PURPLE}${BOLD}Project: ${UpdatePath}${NC}"
    Write-Color ""

    try {
        Move-ShipPacksToQueue
        if (Test-Path $SHIP_DIR) { Remove-Item -Recurse -Force $SHIP_DIR }
        New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\archived") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\Context") -Force | Out-Null
        $platforms = Get-InstalledPlatforms $UpdatePath
        Copy-StageFiles $platforms
        Install-Files $UpdatePath $platforms
        $verFile = Join-Path $UpdatePath "Docs\.agtoosa-version"
        Set-Content -Path $verFile -Value $AGTOOSA_VERSION -Encoding UTF8
        Write-Color ""
        Write-Color "${GREEN}${BOLD}✅ AgToosa updated to v${AGTOOSA_VERSION} in '${UpdatePath}'${NC}"
    } finally {
        Remove-ShipDir
    }
    exit 0
}

# ── Interactive mode ──────────────────────────────────────────
Clear-Host
Write-Color ""
Write-Color "${PURPLE}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
Write-Color "${PURPLE}${BOLD}║          🤖 AgToosa v${AGTOOSA_VERSION} — Local Generator         ║${NC}"
Write-Color "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
Write-Color ""
Write-Color "${CYAN}AgToosa is a spec-driven agentic AI framework that${NC}"
Write-Color "${CYAN}understands your codebase and helps you develop with${NC}"
Write-Color "${CYAN}a clean folder structure and structured workflow.${NC}"
Write-Color ""
Write-Color "${YELLOW}How it works:${NC}"
Write-Color "  1. We detect which AI assistant(s) you use"
Write-Color "  2. We generate ONLY the necessary config files"
Write-Color "  3. We copy them directly to your project"
Write-Color "  4. Run /agtoosa-init in your AI assistant (one-time)"
Write-Color "  5. Then use: /agtoosa-spec → /agtoosa-build → /agtoosa-review → /agtoosa-ship"
Write-Color ""
Write-Color "${YELLOW}────────────────────────────────────────────────────${NC}"
Write-Color ""

# ── Project path ──────────────────────────────────────────────
$projectPath = Read-Host "Project path"
$projectPath = $projectPath.TrimEnd('\', '/')

if (-not (Test-Path $projectPath -PathType Container)) {
    Write-Color "${RED}❌ Error: Directory '$projectPath' does not exist.${NC}"
    exit 1
}

$resolvedProject = Resolve-Path $projectPath
$resolvedScript  = Resolve-Path $SCRIPT_DIR
if ($resolvedProject.Path -eq $resolvedScript.Path) {
    Write-Color "${RED}❌ Error: Target path cannot be the AgToosa source directory itself.${NC}"
    Write-SelfTargetGuidance
    exit 1
}

Write-Color ""
Write-Color "${GREEN}✅ Project found: $projectPath${NC}"
Write-Color ""

# ── Platform selection ────────────────────────────────────────
Write-Color "${YELLOW}Select AI platform(s) — enter numbers separated by spaces (e.g. 1 3):${NC}"
Write-Color "  1) Cursor"
Write-Color "  2) Windsurf"
Write-Color "  3) Claude Code"
Write-Color "  4) Gemini CLI / Jules"
Write-Color "  5) GitHub Copilot"
Write-Color "  6) VS Code (Copilot + prompts)"
Write-Color "  7) OpenCode"
Write-Color "  8) All of the above"
Write-Color ""
$selectionRaw = Read-Host "Selection"
$selection = $selectionRaw.Trim()

$platforms = [System.Collections.Generic.List[string]]::new()
if ($selection -eq "8") {
    $platforms.AddRange([string[]]@("cursor","windsurf","claude","gemini","copilot","opencode"))
} else {
    if ($selection -match "1") { $platforms.Add("cursor") }
    if ($selection -match "2") { $platforms.Add("windsurf") }
    if ($selection -match "3") { $platforms.Add("claude") }
    if ($selection -match "4") { $platforms.Add("gemini") }
    if ($selection -match "5") { $platforms.Add("copilot") }
    if ($selection -match "6") { $platforms.Add("copilot") }
    if ($selection -match "7") { $platforms.Add("opencode") }
}

if ($platforms.Count -eq 0) {
    Write-Color ""
    Write-Color "${YELLOW}⚠️  No AI platform selected. Only Docs\ workflow files will be copied.${NC}"
    $noPlatformConfirm = Read-Host "Continue anyway? (y/N)"
    if ($noPlatformConfirm -notmatch "^[Yy]$") {
        Write-Color "${YELLOW}Re-run agtoosa.ps1 and select at least one platform.${NC}"
        exit 0
    }
}

# ── Stage files into ship\ ────────────────────────────────────
try {
    Move-ShipPacksToQueue
    if (Test-Path $SHIP_DIR) { Remove-Item -Recurse -Force $SHIP_DIR }
    New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\archived") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\Context") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR ".github\instructions") -Force | Out-Null

    Write-Color ""
    Copy-StageFiles $platforms.ToArray()

    Write-Color ""
    Write-Color "${GREEN}${BOLD}Generated files staged.${NC}"
    Write-Color "${YELLOW}────────────────────────────────────────────────────${NC}"
    Write-Color ""
    Write-Color "${BOLD}Ready to copy AgToosa files to:${NC}"
    Write-Color "  ${CYAN}$projectPath${NC}"
    Write-Color ""

    if ($DryRun) {
        Write-Color "${YELLOW}[DRY RUN] Would copy staged files to '$projectPath'.${NC}"
        Write-Color "${YELLOW}[DRY RUN] No changes made. Remove -DryRun to apply.${NC}"
        $keepShip = $false
        exit 0
    }

    $confirm = Read-Host "Copy files now? (Y/n)"
    if ([string]::IsNullOrEmpty($confirm)) { $confirm = "Y" }

    if ($confirm -match "^[Yy]$") {
        Install-Files $projectPath $platforms.ToArray()
        Write-Color ""
        Write-Color "${GREEN}${BOLD}✅ AgToosa v${AGTOOSA_VERSION} installed in '$projectPath'!${NC}"
        # Write version marker
        $verFile = Join-Path $projectPath "Docs\.agtoosa-version"
        $AGTOOSA_VERSION | Out-File -FilePath $verFile -Encoding UTF8 -NoNewline
        Write-Color ""
        Write-Color "${YELLOW}Next steps:${NC}"
        Write-Color "  1. Open your AI assistant in your project"
        Write-Color "  2. Run /agtoosa-init (one-time setup)"
        Write-Color "  3. Run /agtoosa-spec to start your first feature"
    } else {
        Write-Color ""
        Write-Color "${YELLOW}Files are staged in: $SHIP_DIR${NC}"
        Write-Color "${YELLOW}Copy them manually to: $projectPath${NC}"
        $keepShip = $true
    }
} finally {
    Remove-ShipDir
}
