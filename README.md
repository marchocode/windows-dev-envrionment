# Windows Dev Environment Bootstrap

Scripts to take a fresh Windows machine to a working dev environment: install
PowerShell 7, install Scoop, then restore your toolchain from a manifest.

## Quick start

On a new machine, open **Windows PowerShell 5.1** (ships with Windows) and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

This runs, in order:

| Script | What it does |
| --- | --- |
| `scripts/install-pwsh.ps1` | Install PowerShell 7 via winget (MSI fallback if no winget). |
| `scripts/install-scoop.ps1` | Install git if missing, then Scoop via the official installer. |
| `scripts/restore-dev-env.ps1` | Add Scoop buckets and install apps from `config/dev-env.json`. |

Each script is **idempotent**: safe to re-run, skips anything already installed.

## Individual steps

Run any script on its own:

```powershell
# PowerShell 7 only
.\scripts\install-pwsh.ps1

# Scoop (needs git)
.\scripts\install-scoop.ps1

# Restore tools from manifest
.\scripts\restore-dev-env.ps1
```

## Customizing your environment

Edit `config/dev-env.json`:

- `buckets` — extra Scoop buckets to add (`main` is added automatically and
  should not be listed).
- `apps` — one Scoop package name per entry, installed in order.

Point the restore script at a different manifest if you maintain several:

```powershell
.\scripts\restore-dev-env.ps1 -Manifest .\config\dev-env-minimal.json
```

## Requirements

- Windows 10/11 with **winget** (included by default on recent builds). If
  winget is missing, `install-pwsh.ps1` falls back to downloading the MSI, and
  `install-scoop.ps1` will ask you to install git manually.
- Internet access. Package installs may trigger UAC prompts for machine-wide
  tools.
