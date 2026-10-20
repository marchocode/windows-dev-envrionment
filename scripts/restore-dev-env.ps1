#Requires -Version 5.1
<#
.SYNOPSIS
    Restore the dev environment: add Scoop buckets and install apps from a manifest.
.DESCRIPTION
    Reads config\dev-env.json (buckets + apps). Idempotent: skips anything
    already present, detected via the scoop directory layout.
.EXAMPLE
    pwsh -NoProfile -File .\scripts\restore-dev-env.ps1
.PARAMETER Manifest
    Path to the JSON manifest. Defaults to config\dev-env.json.
#>
[CmdletBinding()]
param(
    [string]$Manifest = (Join-Path $PSScriptRoot '..\config\dev-env.json')
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    throw "scoop not found on PATH. Run scripts\install-scoop.ps1 first."
}

# Scoop install root (respect a custom SCOOP env var, default to ~\scoop).
$scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE 'scoop' }

function Add-Bucket {
    param([string]$Name)
    if (Test-Path (Join-Path $scoopRoot "buckets\$Name")) {
        Write-Host "  [skip] bucket '$Name' already added" -ForegroundColor DarkGray
        return
    }
    Write-Host "  [bucket] adding '$Name'..." -ForegroundColor Cyan
    & scoop bucket add $Name
    if ($LASTEXITCODE -ne 0) { throw "Failed to add bucket '$Name'." }
}

function Install-App {
    param([string]$App)
    if (Test-Path (Join-Path $scoopRoot "apps\$App")) {
        Write-Host "  [skip] app '$App' already installed" -ForegroundColor DarkGray
        return
    }
    Write-Host "  [app] installing '$App'..." -ForegroundColor Cyan
    & scoop install $App
    if ($LASTEXITCODE -ne 0) { throw "Failed to install '$App'." }
}

$config = Get-Content $Manifest -Raw | ConvertFrom-Json

Write-Host "Adding buckets..." -ForegroundColor Green
foreach ($b in $config.buckets) { Add-Bucket $b }

Write-Host "Installing apps..." -ForegroundColor Green
foreach ($a in $config.apps) { Install-App $a }

Write-Host "`nDev environment restored." -ForegroundColor Green
