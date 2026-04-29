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

.EXAMPLE
    .\agtoosa.ps1
    .\agtoosa.ps1 -Force
    .\agtoosa.ps1 -DryRun
    .\agtoosa.ps1 -Update -UpdatePath C:\Projects\MyApp
    .\agtoosa.ps1 -Version
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$DryRun,
    [switch]$Version,
    [switch]$Help,
    [switch]$Update,
    [string]$UpdatePath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Version ───────────────────────────────────────────────────
$AGTOOSA_VERSION = "2.6.0"
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

${BOLD}Examples:${NC}
  .\agtoosa.ps1
  .\agtoosa.ps1 -Force
  .\agtoosa.ps1 -Update -UpdatePath C:\Projects\MyApp
  .\agtoosa.ps1 -DryRun
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

function Stage-Files([string[]]$platforms) {
    $docsFiles = @(
        "Docs\AgToosa_Agent.md", "Docs\AgToosa_Spec.md", "Docs\AgToosa_Build.md",
        "Docs\AgToosa_Review.md", "Docs\AgToosa_Ship.md", "Docs\AgToosa_Init.md",
        "Docs\AgToosa_Changelog.md"
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
                if (Test-Path $src) { Copy-FileWithGuard $src (Join-Path $projectPath ".cursorrules") ".cursorrules" }
            }
            "windsurf" {
                $src = Join-Path $SHIP_DIR ".windsurfrules"
                if (Test-Path $src) { Copy-FileWithGuard $src (Join-Path $projectPath ".windsurfrules") ".windsurfrules" }
            }
            "claude" {
                $src = Join-Path $SHIP_DIR "CLAUDE.md"
                if (Test-Path $src) { Copy-FileWithGuard $src (Join-Path $projectPath "CLAUDE.md") "CLAUDE.md" }
            }
            "gemini" {
                $src = Join-Path $SHIP_DIR "AGENTS.md"
                if (Test-Path $src) { Copy-FileWithGuard $src (Join-Path $projectPath "AGENTS.md") "AGENTS.md" }
            }
            "copilot" {
                $ghDir = Join-Path $projectPath ".github"
                New-Item -ItemType Directory -Path $ghDir -Force | Out-Null
                $src = Join-Path $SHIP_DIR ".github\copilot-instructions.md"
                if (Test-Path $src) { Copy-FileWithGuard $src (Join-Path $ghDir "copilot-instructions.md") ".github\copilot-instructions.md" }
            }
            "opencode" {
                $src = Join-Path $SHIP_DIR "OPENCODE.md"
                if (Test-Path $src) { Copy-FileWithGuard $src (Join-Path $projectPath "OPENCODE.md") "OPENCODE.md" }
            }
        }
    }

    # Create empty Context/ and archived/ stubs if not present
    $ctxDir = Join-Path $projectPath "Docs\Context"
    if (-not (Test-Path $ctxDir)) { New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null }
    $archDir = Join-Path $projectPath "Docs\archived"
    if (-not (Test-Path $archDir)) { New-Item -ItemType Directory -Path $archDir -Force | Out-Null }
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
