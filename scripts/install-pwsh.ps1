#Requires -Version 5.1
<#
.SYNOPSIS
    Install PowerShell 7 (pwsh) via winget, with a direct MSI fallback.
.DESCRIPTION
    Designed to run from Windows PowerShell 5.1 on a fresh machine.
    Idempotent: skips when pwsh is already on PATH (unless -Force).
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-pwsh.ps1
#>
[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

if ((Get-Command pwsh -ErrorAction SilentlyContinue) -and -not $Force) {
    Write-Host "[pwsh] already installed at $((Get-Command pwsh).Source)" -ForegroundColor Green
    return
}

$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    Write-Host "[pwsh] installing via winget (accept any UAC prompt)..." -ForegroundColor Cyan
    & winget install --id Microsoft.PowerShell --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget install failed (exit $LASTEXITCODE)."
    }
}
else {
    Write-Host "[pwsh] winget not found; downloading the latest MSI..." -ForegroundColor Yellow
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
    $asset = $release.assets |
        Where-Object { $_.name -match 'win-x64\.msi$' } |
        Select-Object -First 1
    if (-not $asset) {
        throw "Could not locate a win-x64 MSI in the latest PowerShell release."
    }

    $msiPath = Join-Path $env:TEMP $asset.name
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $msiPath

    Write-Host "[pwsh] running the MSI installer (accept any UAC prompt)..." -ForegroundColor Cyan
    $proc = Start-Process msiexec.exe -ArgumentList @('/i', $msiPath, '/qn', '/norestart') -Wait -PassThru -Verb RunAs
    if ($proc.ExitCode -ne 0) {
        throw "MSI install failed (exit $($proc.ExitCode))."
    }
}

Write-Host "[pwsh] install finished. Start a new terminal and run 'pwsh'." -ForegroundColor Green
