BeforeAll {
    $script:RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
    $script:AgtoosaPs1 = Join-Path $script:RepoRoot 'agtoosa.ps1'
    $script:GeneratorVersion = (
        Select-String -Path $script:AgtoosaPs1 -Pattern '\$AGTOOSA_VERSION = "([^"]+)"' |
            Select-Object -First 1
    ).Matches.Groups[1].Value

    function script:Invoke-AgToosaInstall {
        param([string[]]$Arguments)
        $argList = @('-NoProfile', '-File', $script:AgtoosaPs1) + $Arguments
        $proc = Start-Process -FilePath 'pwsh' -ArgumentList $argList -Wait -PassThru -NoNewWindow
        return $proc.ExitCode
    }
}

Describe 'DEV-074 PS1 non-interactive install' {
    It 'NI-001: installs claude platform without stdin' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-ni-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        try {
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'claude', '-Yes')
            $exit | Should -Be 0
            Test-Path (Join-Path $project 'Docs\AgToosa_Agent.md') | Should -BeTrue
            Test-Path (Join-Path $project 'CLAUDE.md') | Should -BeTrue
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'NI-002: rejects unknown platform names' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-ni-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        try {
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'not-a-tool', '-Yes')
            $exit | Should -Not -Be 0
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'NI-003: -Yes without -Path exits non-zero' {
        $exit = Invoke-AgToosaInstall @('-Yes')
        $exit | Should -Not -Be 0
    }

    It 'NI-004: writes Docs\.agtoosa-version matching generator' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-ni-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        try {
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'claude', '-Yes')
            $exit | Should -Be 0
            $verFile = Join-Path $project 'Docs\.agtoosa-version'
            Test-Path $verFile | Should -BeTrue
            (Get-Content -Raw $verFile).Trim() | Should -Be $script:GeneratorVersion
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'NI-005: -DryRun does not copy files to target' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-ni-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        try {
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'claude', '-Yes', '-DryRun')
            $exit | Should -Be 0
            Test-Path (Join-Path $project 'Docs\AgToosa_Agent.md') | Should -BeFalse
            Test-Path (Join-Path $project 'CLAUDE.md') | Should -BeFalse
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }
}

Describe 'DEV-128 PS1 upgrade guards' {
    It 'UPG-001: -Platforms cursor on upgrade applies without union-add' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-upg-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        try {
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'cursor,claude', '-Yes')
            $exit | Should -Be 0
            Test-Path (Join-Path $project '.cursorrules') | Should -BeTrue
            Test-Path (Join-Path $project 'CLAUDE.md') | Should -BeTrue
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'cursor', '-Yes')
            $exit | Should -Be 0
            Test-Path (Join-Path $project '.cursorrules') | Should -BeTrue
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'UPG-002: downgrade blocked when installed version is newer than generator' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-upg-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        try {
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Platforms', 'claude', '-Yes')
            $exit | Should -Be 0
            Set-Content -Path (Join-Path $project 'Docs\.agtoosa-version') -Value '9.9.9' -NoNewline
            $exit = Invoke-AgToosaInstall @('-Path', $project, '-Yes')
            $exit | Should -Not -Be 0
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'UPG-008: platform narrowing confirmation copy exists in agtoosa.ps1' {
        $root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $ps1 = Join-Path $root 'agtoosa.ps1'
        Get-Content $ps1 -Raw | Should -Match 'Confirm-PlatformNarrowingIfNeeded'
        Get-Content $ps1 -Raw | Should -Match 'Enter = keep all checked above'
    }

    It 'UPG-009: compact cleanup verbose flag forwards to bash' {
        $root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $ps1 = Join-Path $root 'agtoosa.ps1'
        Get-Content $ps1 -Raw | Should -Match 'CleanupVerbose'
        Get-Content $ps1 -Raw | Should -Match "--verbose"
    }

    It 'UPG-010: Get-InstalledPlatforms detects copilot scoped instructions' {
        $root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $ps1 = Join-Path $root 'agtoosa.ps1'
        Get-Content $ps1 -Raw | Should -Match 'agtoosa-\*'
        Get-Content $ps1 -Raw | Should -Match '\.github\\instructions'
    }

    It 'UPG-011: smart upgrade banner copy in agtoosa.ps1' {
        $root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        $ps1 = Join-Path $root 'agtoosa.ps1'
        Get-Content $ps1 -Raw | Should -Match 'Only changed files will be written'
        Get-Content $ps1 -Raw | Should -Match 'Staged files for upgrade'
    }
}
