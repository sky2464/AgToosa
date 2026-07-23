# AgToosa Windows Bootstrap Installer (PowerShell)
# Usage: $Ref='v5.3.28'; download bootstrap.ps1 from that ref, then invoke it with -Ref $Ref.

param(
    [string]$Ref = "main",
    [string]$Archive = "",
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

# ──────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────

$REPO_OWNER = "sky2464"
$REPO_NAME = "AgToosa"
$WORKDIR = Join-Path $env:TEMP "agtoosa-bootstrap-$(Get-Random)"
$ARCHIVE_PATH = Join-Path $WORKDIR "agtoosa.tar.gz"

# ──────────────────────────────────────────────────────────────
# Colors for output
# ──────────────────────────────────────────────────────────────

$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"

# ──────────────────────────────────────────────────────────────
# Helper Functions
# ──────────────────────────────────────────────────────────────

function Print-Help {
    Write-Host "AgToosa Windows Bootstrap Installer"
    Write-Host ""
    Write-Host "Usage: powershell -Command `"iex (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sky2464/AgToosa/main/bootstrap.ps1')`""
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Ref <git-ref>    Git ref to download (default: main, recommended: vX.Y.Z tag)"
    Write-Host "  -Archive <path>   Use a local .tar.gz archive instead of downloading"
    Write-Host "  -Help             Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  # Pin a specific release:"
    Write-Host "  `$ref='v5.3.28'; `$body=Invoke-RestMethod -Uri \"https://raw.githubusercontent.com/sky2464/AgToosa/`$ref/bootstrap.ps1\"; & ([scriptblock]::Create(`$body)) -Ref `$ref"
}

function Test-Command {
    param([string]$Command)
    try {
        & $Command --version > $null 2>&1
        return $true
    } catch {
        return $false
    }
}

function Get-ExecutablePath {
    param([string]$Command)
    try {
        (Get-Command $Command -ErrorAction Stop).Path
    } catch {
        return $null
    }
}

function Print-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $ErrorColor
}

function Print-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $SuccessColor
}

function Print-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $InfoColor
}

function Test-ReleaseRef {
    param([string]$Candidate)
    if ($Candidate -eq "main" -or $Candidate -eq "master") { return $true }
    return $Candidate -match '\Av[0-9]+\.[0-9]+\.[0-9]+\z'
}

# ──────────────────────────────────────────────────────────────
# Dependency Checking
# ──────────────────────────────────────────────────────────────

function Check-Dependencies {
    Write-Host "Checking system dependencies..."
    Write-Host ""

    $missing = @()

    # Check Git
    if (-not (Test-Command "git")) {
        $missing += "git"
    }

    # Check Bash (usually via Git for Windows or WSL)
    if (-not (Test-Command "bash")) {
        $missing += "bash"
    }

    # Check Curl
    if (-not (Test-Command "curl")) {
        $missing += "curl"
    }

    # Check Tar
    if (-not (Test-Command "tar")) {
        $missing += "tar"
    }

    if ($missing.Count -gt 0) {
        Write-Host "Missing required tools:" -ForegroundColor $ErrorColor
        Write-Host ""

        foreach ($tool in $missing) {
            switch ($tool) {
                "git" {
                    Write-Host "  $tool — Git for Windows"
                    Write-Host "    Download: https://git-scm.com/download/win"
                    Write-Host "    Or: scoop install git  (if using Scoop)"
                    Write-Host "    Or: choco install git  (if using Chocolatey)"
                }
                "bash" {
                    Write-Host "  $tool — Git for Windows includes bash (git bash)"
                    Write-Host "    Download: https://git-scm.com/download/win"
                }
                "curl" {
                    Write-Host "  $tool"
                    Write-Host "    Or: scoop install curl"
                    Write-Host "    Or: choco install curl"
                    Write-Host "    Or: winget install curl"
                }
                "tar" {
                    Write-Host "  $tool — Usually available on Windows 10/11 (built-in)"
                    Write-Host "    If missing: scoop install tar"
                }
            }
            Write-Host ""
        }

        return $false
    }

    Print-Success "✓ All dependencies found"
    return $true
}

# ──────────────────────────────────────────────────────────────
# Download and Extract
# ──────────────────────────────────────────────────────────────

function Download-Archive {
    param([string]$Ref)

    $archiveKind = if ($Ref -eq "main" -or $Ref -eq "master") { "heads" } else { "tags" }
    $url = "https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/$archiveKind/$Ref.tar.gz"

    Write-Host "Downloading AgToosa ($Ref)..."
    Write-Host "URL: $url"

    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($url, $ARCHIVE_PATH)
        return $true
    } catch {
        Print-Error "Failed to download from $url"
        Print-Error "Error: $_"
        return $false
    }
}

function Cleanup {
    if (Test-Path $WORKDIR) {
        Remove-Item -Recurse -Force $WORKDIR
    }
}

# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if ($Help) {
    Print-Help
    exit 0
}

if (-not $Archive -and -not (Test-ReleaseRef $Ref)) {
    Print-Error "Invalid -Ref '$Ref'. Use main, master, or an exact vX.Y.Z release tag."
    exit 1
}

# Ensure work directory exists
New-Item -ItemType Directory -Path $WORKDIR | Out-Null

# Register cleanup on exit
$exitCode = 0
try {
    # Check dependencies
    if (-not (Check-Dependencies)) {
        exit 1
    }

    Write-Host ""

    # Download or use local archive
    if ($Archive) {
        if (-not (Test-Path $Archive)) {
            Print-Error "Archive file not found: $Archive"
            exit 1
        }
        Write-Host "Using local archive: $Archive"
        Copy-Item $Archive $ARCHIVE_PATH
    } else {
        if (-not (Download-Archive $Ref)) {
            exit 1
        }
    }

    # Reject archives with absolute-path or '..' members BEFORE extraction
    # (post-extract checks cannot undo a tar slip).
    $memberList = tar -tzf $ARCHIVE_PATH 2>$null
    if ($LASTEXITCODE -ne 0) {
        Print-Error "Error: Unable to read archive member list (corrupt archive?)"
        exit 1
    }
    foreach ($member in $memberList) {
        if ([string]::IsNullOrWhiteSpace($member)) { continue }
        if ($member.StartsWith("/") -or $member.StartsWith("\")) {
            Print-Error "Error: Archive contains absolute path member: $member"
            exit 1
        }
        if (("/" + $member + "/") -match "/\.\./") {
            Print-Error "Error: Archive contains path traversal member: $member"
            exit 1
        }
    }

    # Extract archive
    Write-Host "Extracting..."
    tar -xzf $ARCHIVE_PATH -C $WORKDIR

    # Find extracted directory
    $srcDir = Get-ChildItem -Directory $WORKDIR | Select-Object -First 1 | Select-Object -ExpandProperty FullName

    if (-not $srcDir -or -not (Test-Path (Join-Path $srcDir "agtoosa.sh"))) {
        Print-Error "Error: Extracted archive does not contain agtoosa.sh"
        exit 1
    }

    if (-not (Test-Path (Join-Path $srcDir "template")) -or -not (Test-Path (Join-Path $srcDir "lib"))) {
        Print-Error "Error: Extracted archive is incomplete"
        exit 1
    }

    # Find Git Bash
    $gitBashPath = $null
    $possiblePaths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe",
        (Get-ExecutablePath "bash")
    )

    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path $path)) {
            $gitBashPath = $path
            break
        }
    }

    if (-not $gitBashPath) {
        Print-Error "Error: Git Bash not found. Please install Git for Windows"
        Print-Error "Download: https://git-scm.com/download/win"
        exit 1
    }

    # Durable queue: bootstrap deletes its temp extract on exit, so packs staged
    # via registry install must survive outside WORKDIR (parity with npm wrapper).
    $packQueueDir = Join-Path $env:USERPROFILE ".cache\agtoosa\pack-queue"
    New-Item -ItemType Directory -Path $packQueueDir -Force | Out-Null
    $env:AGTOOSA_PACK_QUEUE_DIR = $packQueueDir

    # Execute agtoosa.sh via Git Bash.
    # The source directory is passed via the environment, not string
    # interpolation, so quote characters in the path cannot inject shell code.
    Write-Host "Running AgToosa..."
    $env:AGTOOSA_BOOTSTRAP_SRC = $srcDir
    & $gitBashPath -lc 'cd "$AGTOOSA_BOOTSTRAP_SRC" && bash agtoosa.sh'
    $exitCode = $LASTEXITCODE
    Remove-Item Env:\AGTOOSA_BOOTSTRAP_SRC -ErrorAction SilentlyContinue

} finally {
    Cleanup
}

exit $exitCode
