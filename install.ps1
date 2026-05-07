# install.ps1 — Install or update the DevOps Docs AI Skills toolkit
#
# Installs prompts and instructions to the VS Code user profile so they are
# available as slash commands in every workspace on this machine.
#
# Run .\install.ps1 -Help for full usage information.
#
# Safe to re-run. Running again after `git pull` updates all installed files.
#
# If you see an execution policy error, run once as Administrator:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$TargetRepo = "",

    # "all" or comma-separated prompt names. Default: all (when no component flags given).
    [Parameter(Mandatory = $false)]
    [string]$Prompts = "",

    # "all" or comma-separated instruction file names. Default: all (when no component flags given).
    [Parameter(Mandatory = $false)]
    [string]$Instructions = "",

    # "all" or comma-separated skill names. Requires -TargetRepo.
    [Parameter(Mandatory = $false)]
    [string]$Skills = "",

    [Parameter(Mandatory = $false)]
    [switch]$Help
)

$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot

# ── Usage ─────────────────────────────────────────────────────────────────────
function Show-Usage {
    $PromptNames  = Get-ChildItem -Path (Join-Path $ScriptDir ".github\prompts\*.prompt.md") -ErrorAction SilentlyContinue |
                    ForEach-Object { "  " + ($_.BaseName -replace '\.prompt$', '') }
    $InstrNames   = Get-ChildItem -Path (Join-Path $ScriptDir ".github\instructions\*.instructions.md") -ErrorAction SilentlyContinue |
                    ForEach-Object { "  " + ($_.BaseName -replace '\.instructions$', '') }
    $SkillNames   = Get-ChildItem -Path (Join-Path $ScriptDir ".github\skills") -Directory -ErrorAction SilentlyContinue |
                    ForEach-Object { "  $($_.Name)" }

    Write-Host @"
Usage: .\install.ps1 [OPTIONS]

Install or update the DevOps Docs AI Skills toolkit.

OPTIONS
  -TargetRepo PATH       Path to a docs repo to install workspace files into.
  -Prompts NAMES         Prompts to install to the VS Code user profile.
                         Use 'all' or a comma-separated list of prompt names.
  -Instructions NAMES    Instruction files to install to the VS Code user profile.
                         Use 'all' or a comma-separated list of instruction names.
  -Skills NAMES          Skills to install to the target repo.
                         Use 'all' or a comma-separated list of skill names.
                         Requires -TargetRepo.
  -Help                  Show this message and exit.

When no component flags are given, all prompts and instructions are installed to
the VS Code user profile. If a target repo is also provided, all workspace config
files and skills are installed there too.

When component flags are given, only the specified components are installed.
Providing -TargetRepo always installs workspace config files to the target repo.

AVAILABLE PROMPTS
$($PromptNames -join "`n")

AVAILABLE INSTRUCTIONS
$($InstrNames -join "`n")

AVAILABLE SKILLS
$($SkillNames -join "`n")

EXAMPLES
  # Install everything to the VS Code user profile
  .\install.ps1

  # Install everything, including workspace files for a docs repo
  .\install.ps1 -TargetRepo ..\my-docs-repo

  # Install specific prompts only
  .\install.ps1 -Prompts draft-tutorial,review-alt-text

  # Install a specific skill to a docs repo
  .\install.ps1 -TargetRepo ..\my-docs-repo -Skills fix-broken-links

  # Install specific prompts and a skill to a docs repo
  .\install.ps1 -TargetRepo ..\my-docs-repo -Prompts review-alt-text -Skills alt-text-edit
"@
}

if ($Help) { Show-Usage; exit 0 }

# ── Determine whether explicit component flags were given ─────────────────────
$Explicit = ($Prompts -ne "" -or $Instructions -ne "" -or $Skills -ne "")

# Resolve TargetRepo to an absolute path
if ($TargetRepo -ne "") {
    $TargetRepo = (Resolve-Path $TargetRepo).Path
}

# Apply defaults when no component flags were given
if (-not $Explicit) {
    $Prompts      = "all"
    $Instructions = "all"
    if ($TargetRepo -ne "") { $Skills = "all" }
}

# Skills require a target repo
if ($Skills -ne "" -and $TargetRepo -eq "") {
    Write-Error "-Skills requires -TargetRepo <path-to-docs-repo>."
    exit 1
}

# ── Locate the VS Code user prompts directory ─────────────────────────────────
$VSCodeUser = Join-Path $env:APPDATA "Code\User"

# Uncomment to target VS Code Insiders instead:
# $VSCodeUser = Join-Path $env:APPDATA "Code - Insiders\User"

$VSCodePrompts = Join-Path $VSCodeUser "prompts"
if (-not (Test-Path $VSCodePrompts)) {
    New-Item -ItemType Directory -Path $VSCodePrompts -Force | Out-Null
}

# ── Helper functions ──────────────────────────────────────────────────────────

# Install-Prompts: copies prompt files to the VS Code user profile.
function Install-Prompts([string]$Dest, [string]$Selection) {
    Write-Host "Installing prompts to: $Dest"
    if ($Selection -eq "all") {
        $files = Get-ChildItem -Path (Join-Path $ScriptDir ".github\prompts\*.prompt.md")
        foreach ($f in $files) { Copy-Item $f.FullName -Destination $Dest -Force }
        Write-Host "  Installed $($files.Count) prompt file(s)"
    } else {
        $count = 0
        foreach ($name in ($Selection -split ',')) {
            $name = $name.Trim()
            $file = Join-Path $ScriptDir ".github\prompts\${name}.prompt.md"
            if (Test-Path $file) {
                Copy-Item $file -Destination $Dest -Force
                Write-Host "  Installed: ${name}.prompt.md"
                $count++
            } else {
                Write-Warning "Prompt not found: ${name}"
            }
        }
        Write-Host "  Installed $count prompt file(s)"
    }
}

# Install-Instructions: copies instruction files to the VS Code user profile.
function Install-Instructions([string]$Dest, [string]$Selection) {
    Write-Host "Installing instructions to: $Dest"
    if ($Selection -eq "all") {
        $files = Get-ChildItem -Path (Join-Path $ScriptDir ".github\instructions\*.instructions.md")
        foreach ($f in $files) { Copy-Item $f.FullName -Destination $Dest -Force }
        Write-Host "  Installed $($files.Count) instruction file(s)"
    } else {
        $count = 0
        foreach ($name in ($Selection -split ',')) {
            $name = $name.Trim()
            $file = Join-Path $ScriptDir ".github\instructions\${name}.instructions.md"
            if (Test-Path $file) {
                Copy-Item $file -Destination $Dest -Force
                Write-Host "  Installed: ${name}.instructions.md"
                $count++
            } else {
                Write-Warning "Instruction file not found: ${name}"
            }
        }
        Write-Host "  Installed $count instruction file(s)"
    }
}

# Install-Skills: copies skill directories to the target repo.
function Install-Skills([string]$Dest, [string]$Selection) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    if ($Selection -eq "all") {
        $dirs = Get-ChildItem -Path (Join-Path $ScriptDir ".github\skills") -Directory
        foreach ($d in $dirs) {
            Copy-Item -Path $d.FullName -Destination $Dest -Recurse -Force
            Write-Host "  Installed skill: $($d.Name)"
        }
        Write-Host "  Installed $($dirs.Count) skill(s) total"
    } else {
        $count = 0
        foreach ($name in ($Selection -split ',')) {
            $name = $name.Trim()
            $dir = Join-Path $ScriptDir ".github\skills\$name"
            if (Test-Path $dir) {
                Copy-Item -Path $dir -Destination $Dest -Recurse -Force
                Write-Host "  Installed skill: $name"
                $count++
            } else {
                Write-Warning "Skill not found: $name"
            }
        }
        Write-Host "  Installed $count skill(s)"
    }
}

# ── Install to VS Code user profile ──────────────────────────────────────────
if ($Prompts      -ne "") { Install-Prompts      $VSCodePrompts $Prompts }
if ($Instructions -ne "") { Install-Instructions $VSCodePrompts $Instructions }

# ── Install workspace files to target repo ────────────────────────────────────
if ($TargetRepo -ne "") {
    if (-not (Test-Path (Join-Path $TargetRepo ".git"))) {
        Write-Error "'$TargetRepo' is not the root of a Git repository."
        exit 1
    }

    $TargetGithub      = Join-Path $TargetRepo ".github"
    $TargetInstructions = Join-Path $TargetGithub "instructions"
    $TargetSkillsDir   = Join-Path $TargetGithub "skills"
    New-Item -ItemType Directory -Path $TargetInstructions -Force | Out-Null

    # Workspace config files are always installed when -TargetRepo is given.
    # copilot-instructions.md is kept per-repo so it can be customized for each project.
    Copy-Item -Path (Join-Path $ScriptDir ".github\copilot-instructions.md") -Destination $TargetGithub -Force
    Copy-Item -Path (Join-Path $ScriptDir ".github\instructions\doc-types.instructions.md") -Destination $TargetInstructions -Force
    Copy-Item -Path (Join-Path $ScriptDir ".github\instructions\docs-style.instructions.md") -Destination $TargetInstructions -Force
    Write-Host "Installed workspace config to: $TargetGithub"

    # Install skills
    if ($Skills -ne "") { Install-Skills $TargetSkillsDir $Skills }

    # Vale config — install in default mode or when skills are being installed.
    # .vale.ini points vale at the Google and Microsoft style packages.
    # vale sync downloads the package files to .vale\styles\ — those should not be committed.
    if (-not $Explicit -or $Skills -ne "") {
        $ValeIni      = Join-Path $ScriptDir ".github\skills\docs-style-edit\assets\.vale.ini"
        $TargetValeIni = Join-Path $TargetRepo ".vale.ini"
        if (Test-Path $TargetValeIni) {
            Write-Host "  Skipping .vale.ini — file already exists in $TargetRepo"
        } else {
            Copy-Item -Path $ValeIni -Destination $TargetRepo -Force
            Write-Host "  Installed .vale.ini to: $TargetRepo"
        }

    }

    if (-not $Explicit) {
        Write-Host ""
        Write-Host "  Next steps:"
        Write-Host "    1. Run 'vale sync' in $TargetRepo to download the Google and Microsoft style packages."
        Write-Host "    2. Customize $TargetGithub\copilot-instructions.md for this repo."
        Write-Host "    3. Commit the new files:"
        Write-Host ""
        Write-Host "       cd $TargetRepo"
        Write-Host "       git add .github/ .vale.ini"
        Write-Host "       git commit -m 'Add DevOps docs AI skills workspace config'"
    }
}

Write-Host ""
Write-Host "Done."
Write-Host "Reload VS Code to pick up new or updated prompts:"
Write-Host "  Ctrl+Shift+P -> Developer: Reload Window"
