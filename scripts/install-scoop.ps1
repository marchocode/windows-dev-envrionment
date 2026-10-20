#Requires -Version 5.1
<#
.SYNOPSIS
    Install Scoop, plus git (required by Scoop for buckets) if missing.
.DESCRIPTION
    Idempotent: skips when scoop is already on PATH (unless -Force).
    Runs from either Windows PowerShell 5.1 or PowerShell 7.
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-scoop.ps1
#>
[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# --- scoop already installed? ---
if ((Get-Command scoop -ErrorAction SilentlyContinue) -and -not $Force) {
    Write-Host "[scoop] already installed at $((Get-Command scoop).Source)" -ForegroundColor Green
    return
}

# --- git (Scoop needs it to add/update buckets) ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw "git is required by Scoop. Install git first, or use a system that has winget."
    }
    Write-Host "[scoop] installing git via winget..." -ForegroundColor Cyan
    & winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget failed to install git (exit $LASTEXITCODE)."
    }

    # Refresh PATH so the freshly installed git is visible in this session.
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git installed but not found on PATH. Reopen your terminal and re-run this script."
    }
}

# --- install scoop (official installer) ---
Write-Host "[scoop] installing scoop..." -ForegroundColor Cyan
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    throw "scoop install completed but 'scoop' is not on PATH. Reopen your terminal."
}
Write-Host "[scoop] installed." -ForegroundColor Green
