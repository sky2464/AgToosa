BeforeAll {
    $script:RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
    $script:AgtoosaPs1 = Join-Path $script:RepoRoot 'agtoosa.ps1'
    $script:GeneratorVersion = (
        Select-String -Path $script:AgtoosaPs1 -Pattern '\$AGTOOSA_VERSION = "([^"]+)"' |
            Select-Object -First 1
    ).Matches.Groups[1].Value

    function script:Invoke-AgToosaPs1 {
        param(
            [string[]]$Arguments,
            [string]$Stdin = ''
        )
        $argList = @('-NoProfile', '-File', $script:AgtoosaPs1) + $Arguments
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = 'pwsh'
        $psi.Arguments = ($argList | ForEach-Object {
            if ($_ -match '\s') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
        }) -join ' '
        $psi.UseShellExecute = $false
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        if ($Stdin) { $proc.StandardInput.Write($Stdin) }
        $proc.StandardInput.Close()
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()
        return [pscustomobject]@{
            ExitCode = $proc.ExitCode
            Output   = ($stdout + $stderr)
        }
    }

    function script:New-InstalledProject {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-maintain-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $project -Force | Out-Null
        $exit = (Invoke-AgToosaPs1 @('-Path', $project, '-Platforms', 'claude', '-Yes')).ExitCode
        if ($exit -ne 0) {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
            throw "Failed to install fixture project (exit $exit)"
        }
        return $project
    }
}

Describe 'DEV-105 PS1 maintain parity' {
    It '@smoke PSP-001: -Verify dispatches repo verifier and preserves exit code' {
        $project = New-InstalledProject
        try {
            $result = Invoke-AgToosaPs1 @('-Verify', '-UpdatePath', $project)
            $result.ExitCode | Should -BeIn @(0, 1, 2)
            if ($result.Output) {
                $result.Output | Should -Match 'PASS|FAIL|verify|Verifier'
            }
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'PSP-001 negative: verify without installed verifier reports actionable error' {
        $project = Join-Path ([System.IO.Path]::GetTempPath()) ("agtoosa-maintain-" + [guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path (Join-Path $project 'Docs') -Force | Out-Null
        try {
            $result = Invoke-AgToosaPs1 @('-Verify', '-UpdatePath', $project)
            $result.ExitCode | Should -Not -Be 0
            $result.Output | Should -Match 'verify|Master-Plan|Error|not found'
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'PSP-002: -Doctor matches bash doctor signals' {
        $project = New-InstalledProject
        try {
            $result = Invoke-AgToosaPs1 @('-Doctor', '-UpdatePath', $project)
            $result.ExitCode | Should -BeIn @(0, 1)
            $result.Output | Should -Match 'Doctor|version|Docs|matches generator'
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'PSP-003: -Uninstall preserves Master-Plan and Context' {
        $project = New-InstalledProject
        try {
            $mp = Join-Path $project 'Docs\Master-Plan.md'
            Add-Content -Path $mp -Value 'user content'
            $result = Invoke-AgToosaPs1 @('-Uninstall', '-UpdatePath', $project) -Stdin "Y`n"
            $result.ExitCode | Should -Be 0
            Test-Path (Join-Path $project 'Docs\AgToosa_Agent.md') | Should -BeFalse
            Test-Path (Join-Path $project 'Docs\.agtoosa-version') | Should -BeFalse
            Test-Path $mp | Should -BeTrue
            (Get-Content -Raw $mp) | Should -Match 'user content'
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It '@smoke PSP-004: -Update delegates to bash run_update' {
        $project = New-InstalledProject
        try {
            Set-Content -Path (Join-Path $project 'Docs\.agtoosa-version') -Value '5.0.0' -Encoding UTF8
            $result = Invoke-AgToosaPs1 @('-Update', '-UpdatePath', $project)
            $result.ExitCode | Should -Be 0
            (Get-Content -Raw (Join-Path $project 'Docs\.agtoosa-version')).Trim() | Should -Be $script:GeneratorVersion
        } finally {
            Remove-Item -Recurse -Force $project -ErrorAction SilentlyContinue
        }
    }

    It 'PSP-005: maintain switches fail fast without -UpdatePath' {
        foreach ($switchName in @('Verify', 'Doctor', 'Uninstall', 'Update')) {
            $result = Invoke-AgToosaPs1 @("-$switchName")
            $result.ExitCode | Should -Not -Be 0 -Because "-$switchName should require -UpdatePath"
            $result.Output | Should -Match 'UpdatePath'
        }
    }
}
