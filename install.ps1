# install.ps1 — Install or update the DevOps Docs AI Skills toolkit
#
# Installs prompts and instructions to the VS Code user profile so they are
# available as slash commands in every workspace on this machine.
#
# Usage:
#   .\install.ps1                        Install to VS Code user profile only
#   .\install.ps1 -TargetRepo <path>     Also copy workspace files to a docs repo
#
# Safe to re-run. Running again after `git pull` updates all installed files.
#
# If you see an execution policy error, run once as Administrator:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TargetRepo = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot

# ── Locate the VS Code user prompts directory ─────────────────────────────────
$VSCodeUser = Join-Path $env:APPDATA "Code\User"

# Uncomment to target VS Code Insiders instead:
# $VSCodeUser = Join-Path $env:APPDATA "Code - Insiders\User"

$VSCodePrompts = Join-Path $VSCodeUser "prompts"

if (-not (Test-Path $VSCodePrompts)) {
    New-Item -ItemType Directory -Path $VSCodePrompts -Force | Out-Null
}

# ── Install prompts to user profile ──────────────────────────────────────────
# Prompts installed here appear as slash commands in every workspace.
Write-Host "Installing prompts to: $VSCodePrompts"
$PromptFiles = Get-ChildItem -Path (Join-Path $ScriptDir ".github\prompts\*.prompt.md")
foreach ($file in $PromptFiles) {
    Copy-Item -Path $file.FullName -Destination $VSCodePrompts -Force
}
Write-Host "  Installed $($PromptFiles.Count) prompt files"

# ── Install instructions to user profile ─────────────────────────────────────
# devops-docs-style: applyTo "**/*.md" — auto-applies to every Markdown file
# doc-types: on-demand — loaded when asking about document structure
Write-Host "Installing instructions to: $VSCodePrompts"
Copy-Item -Path (Join-Path $ScriptDir ".github\instructions\devops-docs-style.instructions.md") `
    -Destination $VSCodePrompts -Force
Copy-Item -Path (Join-Path $ScriptDir ".github\instructions\doc-types.instructions.md") `
    -Destination $VSCodePrompts -Force
Write-Host "  Installed 2 instruction files"

# ── Optionally install workspace files to a target docs repo ─────────────────
# copilot-instructions.md: workspace-level context (project name, product, audience)
# This file is intentionally kept per-repo so it can be customized for each project.
if ($TargetRepo -ne "") {
    $TargetRepo = Resolve-Path $TargetRepo

    if (-not (Test-Path (Join-Path $TargetRepo ".git"))) {
        Write-Error "'$TargetRepo' is not the root of a Git repository."
        exit 1
    }

    $TargetGithub = Join-Path $TargetRepo ".github"
    $TargetInstructions = Join-Path $TargetGithub "instructions"

    New-Item -ItemType Directory -Path $TargetInstructions -Force | Out-Null

    Copy-Item -Path (Join-Path $ScriptDir ".github\copilot-instructions.md") `
        -Destination $TargetGithub -Force
    Copy-Item -Path (Join-Path $ScriptDir ".github\instructions\doc-types.instructions.md") `
        -Destination $TargetInstructions -Force

    Write-Host ""
    Write-Host "Installed workspace files to: $TargetGithub"
    Write-Host ""
    Write-Host "  Next step: customize $TargetGithub\copilot-instructions.md"
    Write-Host "  Replace the placeholder audience and style content with details specific to this repo,"
    Write-Host "  then commit the file:"
    Write-Host ""
    Write-Host "    cd $TargetRepo"
    Write-Host "    git add .github/"
    Write-Host "    git commit -m 'Add DevOps docs AI skills workspace config'"
}

Write-Host ""
Write-Host "Done."
Write-Host "Reload VS Code to pick up new or updated prompts:"
Write-Host "  Ctrl+Shift+P -> Developer: Reload Window"
