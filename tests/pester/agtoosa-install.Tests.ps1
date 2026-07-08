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
