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

    # ── Install skills ────────────────────────────────────────────────────────────
    # Skills are workspace-scoped and must be present in the target repo to appear
    # as slash commands in VS Code Copilot Agent mode.
    # All skill directories under .github\skills\ are installed automatically.
    $TargetSkills = Join-Path $TargetGithub "skills"
    New-Item -ItemType Directory -Path $TargetSkills -Force | Out-Null
    $SkillDirs = Get-ChildItem -Path (Join-Path $ScriptDir ".github\skills") -Directory
    foreach ($skillDir in $SkillDirs) {
        Copy-Item -Path $skillDir.FullName -Destination $TargetSkills -Recurse -Force
        Write-Host "  Installed $($skillDir.Name) skill to: $TargetSkills"
    }
    Write-Host "  Installed $($SkillDirs.Count) skill(s) total"

    # ── Install vale config ───────────────────────────────────────────────────
    # .vale.ini points vale at the Google and Microsoft style packages.
    # vale sync downloads the package files to .vale\styles\ — those should not be committed.
    $ValeIni = Join-Path $ScriptDir ".github\skills\docs-style-edit\assets\.vale.ini"
    $TargetValeIni = Join-Path $TargetRepo ".vale.ini"
    if (Test-Path $TargetValeIni) {
        Write-Host "  Skipping .vale.ini — file already exists in $TargetRepo"
    } else {
        Copy-Item -Path $ValeIni -Destination $TargetRepo -Force
        Write-Host "  Installed .vale.ini to: $TargetRepo"
    }

    $Gitignore = Join-Path $TargetRepo ".gitignore"
    $ValeEntry = ".vale/styles/"
    if (-not (Test-Path $Gitignore) -or -not (Select-String -Path $Gitignore -SimpleMatch $ValeEntry -Quiet)) {
        Add-Content -Path $Gitignore -Value "`n# Vale downloaded style packages`n.vale/styles/"
        Write-Host "  Added .vale/styles/ to .gitignore"
    }

    Write-Host ""
    Write-Host "Installed workspace files to: $TargetGithub"
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "    1. Run 'vale sync' in $TargetRepo to download the Google and Microsoft style packages."
    Write-Host "    2. Customize $TargetGithub\copilot-instructions.md for this repo."
    Write-Host "    3. Commit the new files:"
    Write-Host ""
    Write-Host "       cd $TargetRepo"
    Write-Host "       git add .github/ .vale.ini .gitignore"
    Write-Host "       git commit -m 'Add DevOps docs AI skills workspace config'"
}

Write-Host ""
Write-Host "Done."
Write-Host "Reload VS Code to pick up new or updated prompts:"
Write-Host "  Ctrl+Shift+P -> Developer: Reload Window"
