#Requires -Version 5.1
<#
.SYNOPSIS
    One-command bootstrap: install pwsh, install scoop, restore the dev environment.
.DESCRIPTION
    Runs from Windows PowerShell 5.1 on a fresh machine. Each step is idempotent.
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
#>

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

& (Join-Path $root 'scripts\install-pwsh.ps1')
& (Join-Path $root 'scripts\install-scoop.ps1')
& (Join-Path $root 'scripts\restore-dev-env.ps1')
