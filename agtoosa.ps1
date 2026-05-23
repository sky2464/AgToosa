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
    Registry sub-command: list, search, info, or install.

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
$AGTOOSA_VERSION = "4.2.0"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$TEMPLATE_DIR = Join-Path $SCRIPT_DIR "template"
$SHIP_DIR = Join-Path $SCRIPT_DIR "ship"

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


function Stage-Files([string[]]$platforms) {
    $docsFiles = @(
        "Docs\AgToosa_Agent.md", "Docs\AgToosa_Init.md", "Docs\AgToosa_Spec.md",
        "Docs\AgToosa_Build.md", "Docs\AgToosa_Review.md", "Docs\AgToosa_Ship.md",
        "Docs\AgToosa_QA.md", "Docs\AgToosa_Revert.md", "Docs\AgToosa_Task.md",
        "Docs\AgToosa_Goal.md", "Docs\AgToosa_Update.md", "Docs\AgToosa_Registry.md", "Docs\AgToosa_Skills.md",
        "Docs\CONTEXT-FORMAT.md", "Docs\ADR-FORMAT.md", "Docs\DEEPENING.md",
        "Docs\LANGUAGE.md", "Docs\Master-Plan.md", "Docs\AgToosa_Changelog.md"
    )

    foreach ($f in $docsFiles) {
        $src = Join-Path $TEMPLATE_DIR $f
        $dst = Join-Path $SHIP_DIR $f
        if (Test-Path $src) {
            $dir = Split-Path -Parent $dst
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            Copy-Item $src $dst
            Write-Color "  ${GREEN}✅${NC} $f"
        }
    }

    foreach ($p in $platforms) {
        switch ($p) {
            "cursor" {
                $src = Join-Path $TEMPLATE_DIR ".cursorrules"
                $dst = Join-Path $SHIP_DIR ".cursorrules"
                Copy-Item $src $dst
                Write-Color "  ${GREEN}✅${NC} .cursorrules ${CYAN}(Cursor)${NC}"
            }
            "windsurf" {
                $src = Join-Path $TEMPLATE_DIR ".windsurfrules"
                $dst = Join-Path $SHIP_DIR ".windsurfrules"
                Copy-Item $src $dst
                Write-Color "  ${GREEN}✅${NC} .windsurfrules ${CYAN}(Windsurf)${NC}"
            }
            "claude" {
                $src = Join-Path $TEMPLATE_DIR "CLAUDE.md"
                $dst = Join-Path $SHIP_DIR "CLAUDE.md"
                Copy-Item $src $dst
                $srcExtra = Join-Path $TEMPLATE_DIR "Docs\AgToosa_Claude.md"
                $dstExtra = Join-Path $SHIP_DIR "Docs\AgToosa_Claude.md"
                if (Test-Path $srcExtra) { Copy-Item $srcExtra $dstExtra }
                Write-Color "  ${GREEN}✅${NC} CLAUDE.md + Docs\AgToosa_Claude.md ${CYAN}(Claude Code)${NC}"
            }
            "gemini" {
                $src = Join-Path $TEMPLATE_DIR "AGENTS.md"
                $dst = Join-Path $SHIP_DIR "AGENTS.md"
                Copy-Item $src $dst
                $srcExtra = Join-Path $TEMPLATE_DIR "Docs\AgToosa_Gemini.md"
                $dstExtra = Join-Path $SHIP_DIR "Docs\AgToosa_Gemini.md"
                if (Test-Path $srcExtra) { Copy-Item $srcExtra $dstExtra }
                Write-Color "  ${GREEN}✅${NC} AGENTS.md + Docs\AgToosa_Gemini.md ${CYAN}(Gemini CLI / Jules)${NC}"
            }
            "copilot" {
                $ghDir = Join-Path $SHIP_DIR ".github\instructions"
                New-Item -ItemType Directory -Path $ghDir -Force | Out-Null
                $src = Join-Path $TEMPLATE_DIR ".github\copilot-instructions.md"
                $dst = Join-Path $SHIP_DIR ".github\copilot-instructions.md"
                Copy-Item $src $dst
                Write-Color "  ${GREEN}✅${NC} .github\copilot-instructions.md ${CYAN}(GitHub Copilot)${NC}"
            }
            "opencode" {
                $src = Join-Path $TEMPLATE_DIR "OPENCODE.md"
                $dst = Join-Path $SHIP_DIR "OPENCODE.md"
                if (Test-Path $src) {
                    Copy-Item $src $dst
                    Write-Color "  ${GREEN}✅${NC} OPENCODE.md ${CYAN}(OpenCode)${NC}"
                }
            }
        }
    }
}

function Install-Files([string]$projectPath, [string[]]$platforms) {
    $shipDocs = Join-Path $SHIP_DIR "Docs"
    if (Test-Path $shipDocs) {
        $dstDocs = Join-Path $projectPath "Docs"
        New-Item -ItemType Directory -Path $dstDocs -Force | Out-Null
        Get-ChildItem -Path $shipDocs -File | ForEach-Object {
            Copy-FileWithGuard $_.FullName (Join-Path $dstDocs $_.Name) "Docs\$($_.Name)"
        }
    }

    foreach ($p in $platforms) {
        switch ($p) {
            "cursor" {
                $src = Join-Path $SHIP_DIR ".cursorrules"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath ".cursorrules") ".cursorrules" }
                # Native .cursor/rules/ MDX files
                $cursorRulesDir = Join-Path $projectPath ".cursor\rules"
                $shipCursorRulesDir = Join-Path $SHIP_DIR ".cursor\rules"
                if (Test-Path $shipCursorRulesDir) {
                    New-Item -ItemType Directory -Path $cursorRulesDir -Force | Out-Null
                    Get-ChildItem -Path $shipCursorRulesDir -File | ForEach-Object {
                        $dst = Join-Path $cursorRulesDir $_.Name
                        Copy-Item -Path $_.FullName -Destination $dst -Force
                    }
                    Write-Color "  ${GREEN}✅${NC} .cursor/rules/ (MDX rules)"
                }
            }
            "windsurf" {
                $src = Join-Path $SHIP_DIR ".windsurfrules"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath ".windsurfrules") ".windsurfrules" }
                # Native .windsurf/rules/ files
                $wsRulesDir = Join-Path $projectPath ".windsurf\rules"
                $shipWsRulesDir = Join-Path $SHIP_DIR ".windsurf\rules"
                if (Test-Path $shipWsRulesDir) {
                    New-Item -ItemType Directory -Path $wsRulesDir -Force | Out-Null
                    Get-ChildItem -Path $shipWsRulesDir -File | ForEach-Object {
                        $dst = Join-Path $wsRulesDir $_.Name
                        Copy-Item -Path $_.FullName -Destination $dst -Force
                    }
                    Write-Color "  ${GREEN}✅${NC} .windsurf/rules/ (rules)"
                }
            }
            "claude" {
                $src = Join-Path $SHIP_DIR "CLAUDE.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath "CLAUDE.md") "CLAUDE.md" }
                # Native .claude/commands/ and .claude/skills/ files
                foreach ($subdir in @("commands", "skills")) {
                    $shipClaudeDir = Join-Path $SHIP_DIR ".claude\$subdir"
                    if (Test-Path $shipClaudeDir) {
                        $dstClaudeDir = Join-Path $projectPath ".claude\$subdir"
                        New-Item -ItemType Directory -Path $dstClaudeDir -Force | Out-Null
                        Get-ChildItem -Path $shipClaudeDir -File | ForEach-Object {
                            $dst = Join-Path $dstClaudeDir $_.Name
                            Copy-Item -Path $_.FullName -Destination $dst -Force
                        }
                        Write-Color "  ${GREEN}✅${NC} .claude/$subdir/"
                    }
                }
            }
            "gemini" {
                $src = Join-Path $SHIP_DIR "AGENTS.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath "AGENTS.md") "AGENTS.md" }
                # Native .gemini/commands/ TOML files
                $geminiCmdDir = Join-Path $projectPath ".gemini\commands"
                $shipGeminiCmdDir = Join-Path $SHIP_DIR ".gemini\commands"
                if (Test-Path $shipGeminiCmdDir) {
                    New-Item -ItemType Directory -Path $geminiCmdDir -Force | Out-Null
                    Get-ChildItem -Path $shipGeminiCmdDir -File | ForEach-Object {
                        $dst = Join-Path $geminiCmdDir $_.Name
                        Copy-Item -Path $_.FullName -Destination $dst -Force
                    }
                    Write-Color "  ${GREEN}✅${NC} .gemini/commands/ (TOML commands)"
                }
            }
            "copilot" {
                $ghDir = Join-Path $projectPath ".github"
                New-Item -ItemType Directory -Path $ghDir -Force | Out-Null
                $src = Join-Path $SHIP_DIR ".github\copilot-instructions.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $ghDir "copilot-instructions.md") ".github\copilot-instructions.md" }
                # Native .github/prompts/, .github/agents/, .github/instructions/ files
                foreach ($subdir in @("prompts", "agents", "instructions")) {
                    $shipGhDir = Join-Path $SHIP_DIR ".github\$subdir"
                    if (Test-Path $shipGhDir) {
                        $dstGhDir = Join-Path $ghDir $subdir
                        New-Item -ItemType Directory -Path $dstGhDir -Force | Out-Null
                        Get-ChildItem -Path $shipGhDir -File | ForEach-Object {
                            $dst = Join-Path $dstGhDir $_.Name
                            Copy-Item -Path $_.FullName -Destination $dst -Force
                        }
                        Write-Color "  ${GREEN}✅${NC} .github/$subdir/"
                    }
                }
            }
            "opencode" {
                $src = Join-Path $SHIP_DIR "OPENCODE.md"
                if (Test-Path $src) { Merge-PlatformFile $src (Join-Path $projectPath "OPENCODE.md") "OPENCODE.md" }
            }
        }
    }

    # Create empty Context/ and archived/ stubs if not present
    $ctxDir = Join-Path $projectPath "Docs\Context"
    if (-not (Test-Path $ctxDir)) { New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null }
    $archDir = Join-Path $projectPath "Docs\archived"
    if (-not (Test-Path $archDir)) { New-Item -ItemType Directory -Path $archDir -Force | Out-Null }

    # Write Docs/agtoosa-lock.json (create or update agtoosa_version + generated_at; preserve existing packs).
    $lockFile = Join-Path $projectPath "Docs\agtoosa-lock.json"
    $timestamp = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $packsArray = @()
    if (Test-Path $lockFile) {
        try {
            $existing = Get-Content $lockFile -Raw | ConvertFrom-Json
            if ($existing.packs) { $packsArray = @($existing.packs) }
        } catch { $packsArray = @() }
    }
    $lock = [ordered]@{
        agtoosa_version = $AGTOOSA_VERSION
        generated_at    = $timestamp
        packs           = $packsArray
    }
    $lock | ConvertTo-Json -Depth 5 | Out-File -FilePath $lockFile -Encoding UTF8
    Write-Color "  ${GREEN}✅${NC} Docs/agtoosa-lock.json updated"
}

# ── Registry ──────────────────────────────────────────────────
$REGISTRY_URL = "https://raw.githubusercontent.com/sky2464/agtoosa-registry/main/registry.json"

function Invoke-RegistryFetch {
    $cacheDir  = "$env:USERPROFILE\.cache\agtoosa"
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
        Invoke-WebRequest -Uri $REGISTRY_URL -OutFile $cacheFile -UseBasicParsing | Out-Null
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
    $packs = $json | ConvertFrom-Json
    foreach ($pack in $packs) {
        Write-Color "$($pack.name) v$($pack.version) — $($pack.description) (by $($pack.author))"
    }
}

function Show-RegistrySearch([string]$query) {
    $json  = Invoke-RegistryFetch
    $packs = $json | ConvertFrom-Json
    foreach ($pack in $packs) {
        if ($pack.name -like "*$query*" -or $pack.description -like "*$query*") {
            Write-Color "$($pack.name) v$($pack.version) — $($pack.description) (by $($pack.author))"
        }
    }
}

function Show-RegistryInfo([string]$packName) {
    $json  = Invoke-RegistryFetch
    $packs = $json | ConvertFrom-Json
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
    $packs = $json | ConvertFrom-Json
    $pack  = $packs | Where-Object { $_.name -eq $packName } | Select-Object -First 1
    if (-not $pack) {
        Write-Color "${RED}❌ Pack '$packName' not found in registry.${NC}"
        exit 1
    }

    if ($packVersion -ne "" -and $pack.version -ne $packVersion) {
        Write-Color "${YELLOW}⚠️  Requested version $packVersion but registry has $($pack.version). Proceeding with registry version.${NC}"
    }

    $confirm = Read-Host "Installing: $packName — Continue? (Y/n)"
    if ([string]::IsNullOrEmpty($confirm)) { $confirm = "Y" }
    if ($confirm -notmatch "^[Yy]$") {
        Write-Color "${YELLOW}Aborted.${NC}"
        exit 0
    }

    $url     = $pack.url
    $tmpFile = [System.IO.Path]::GetTempFileName() + ".tar.gz"

    try {
        Write-Color "${CYAN}Downloading $packName...${NC}"
        Invoke-WebRequest -Uri $url -OutFile $tmpFile -UseBasicParsing | Out-Null
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

    # Extract
    $packDir = Join-Path $SHIP_DIR "packs\$packName"
    New-Item -ItemType Directory -Path $packDir -Force | Out-Null

    $tarAvailable = $null -ne (Get-Command tar -ErrorAction SilentlyContinue)
    if (-not $tarAvailable) {
        Write-Color "${RED}❌ tar is not available on this system. Cannot extract the pack tarball.${NC}"
        Remove-Item $tmpFile -ErrorAction SilentlyContinue
        exit 1
    }

    $proc = Start-Process -NoNewWindow -Wait -PassThru -FilePath tar -ArgumentList @('-xzf', $tmpFile, '-C', $packDir)
    if ($proc.ExitCode -ne 0) {
        Write-Color "${RED}❌ Extraction failed (tar exit code $($proc.ExitCode)).${NC}"
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

    Write-Color "${GREEN}✅ Pack '$packName' v$($pack.version) installed to '$packDir'.${NC}"
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
        if (Test-Path $SHIP_DIR) { Remove-Item -Recurse -Force $SHIP_DIR }
        New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\archived") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\Context") -Force | Out-Null
        Stage-Files @()
        Install-Files $UpdatePath @()
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
    if (Test-Path $SHIP_DIR) { Remove-Item -Recurse -Force $SHIP_DIR }
    New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\archived") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR "Docs\Context") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $SHIP_DIR ".github\instructions") -Force | Out-Null

    Write-Color ""
    Stage-Files $platforms.ToArray()

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
