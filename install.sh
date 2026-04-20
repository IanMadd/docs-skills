#!/usr/bin/env bash
# install.sh — Install or update the DevOps Docs AI Skills toolkit
#
# Installs prompts and instructions to the VS Code user profile so they are
# available as slash commands in every workspace on this machine.
#
# Usage:
#   ./install.sh                      Install to VS Code user profile only
#   ./install.sh <path-to-docs-repo>  Also copy workspace files to a docs repo
#
# Safe to re-run. Running again after `git pull` updates all installed files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Locate the VS Code user prompts directory ─────────────────────────────────
case "$(uname -s)" in
  Darwin)
    VSCODE_USER="$HOME/Library/Application Support/Code/User"
    ;;
  Linux)
    VSCODE_USER="$HOME/.config/Code/User"
    ;;
  *)
    echo "Unsupported OS. Use install.ps1 on Windows." >&2
    exit 1
    ;;
esac

# Uncomment to target VS Code Insiders instead:
# VSCODE_USER="${VSCODE_USER/Code/Code - Insiders}"

VSCODE_PROMPTS="$VSCODE_USER/prompts"
mkdir -p "$VSCODE_PROMPTS"

# ── Install prompts to user profile ──────────────────────────────────────────
# Prompts installed here appear as slash commands in every workspace.
echo "Installing prompts to: $VSCODE_PROMPTS"
cp "$SCRIPT_DIR"/.github/prompts/*.prompt.md "$VSCODE_PROMPTS/"
echo "  Installed $(ls "$SCRIPT_DIR"/.github/prompts/*.prompt.md | wc -l | tr -d ' ') prompt files"

# ── Install instructions to user profile ─────────────────────────────────────
# devops-docs-style: applyTo "**/*.md" — auto-applies to every Markdown file
# doc-types: on-demand — loaded when asking about document structure
echo "Installing instructions to: $VSCODE_PROMPTS"
cp "$SCRIPT_DIR"/.github/instructions/devops-docs-style.instructions.md "$VSCODE_PROMPTS/"
cp "$SCRIPT_DIR"/.github/instructions/doc-types.instructions.md "$VSCODE_PROMPTS/"
echo "  Installed 2 instruction files"

# ── Optionally install workspace files to a target docs repo ─────────────────
# copilot-instructions.md: workspace-level context (project name, product, audience)
# This file is intentionally kept per-repo so it can be customized for each project.
if [[ -n "${1:-}" ]]; then
  TARGET="$(cd "$1" && pwd)"

  if [[ ! -d "$TARGET/.git" ]]; then
    echo "Error: '$TARGET' is not the root of a Git repository." >&2
    exit 1
  fi

  TARGET_GITHUB="$TARGET/.github"
  TARGET_INSTRUCTIONS="$TARGET_GITHUB/instructions"
  mkdir -p "$TARGET_INSTRUCTIONS"

  cp "$SCRIPT_DIR"/.github/copilot-instructions.md "$TARGET_GITHUB/"
  cp "$SCRIPT_DIR"/.github/instructions/doc-types.instructions.md "$TARGET_INSTRUCTIONS/"

  # ── Install skills ────────────────────────────────────────────────────────────
  # Skills are workspace-scoped and must be present in the target repo to appear
  # as slash commands in VS Code Copilot Agent mode.
  # All skill directories under .github/skills/ are installed automatically.
  TARGET_SKILLS="$TARGET_GITHUB/skills"
  mkdir -p "$TARGET_SKILLS"
  skill_count=0
  for skill_dir in "$SCRIPT_DIR"/.github/skills/*/; do
    skill_name="$(basename "$skill_dir")"
    cp -r "${skill_dir%/}" "$TARGET_SKILLS/"
    echo "  Installed $skill_name skill to: $TARGET_SKILLS"
    (( skill_count++ )) || true
  done
  echo "  Installed $skill_count skill(s) total"

  # ── Install vale config ─────────────────────────────────────────────────────
  # .vale.ini points vale at the Google and Microsoft style packages.
  # vale sync downloads the package files to .vale/styles/ — those should not be committed.
  if [[ -f "$TARGET/.vale.ini" ]]; then
    echo "  Skipping .vale.ini — file already exists in $TARGET"
  else
    cp "$SCRIPT_DIR"/.github/skills/docs-style-edit/assets/.vale.ini "$TARGET/"
    echo "  Installed .vale.ini to: $TARGET"
  fi

  GITIGNORE="$TARGET/.gitignore"
  if ! grep -qF '.vale/styles/' "$GITIGNORE" 2>/dev/null; then
    printf '\n# Vale downloaded style packages\n.vale/styles/\n' >> "$GITIGNORE"
    echo "  Added .vale/styles/ to $GITIGNORE"
  fi

  echo ""
  echo "Installed workspace files to: $TARGET_GITHUB"
  echo ""
  echo "  Next steps:"
  echo "    1. Run 'vale sync' in $TARGET to download the Google and Microsoft style packages."
  echo "    2. Customize $TARGET_GITHUB/copilot-instructions.md for this repo."
  echo "    3. Commit the new files:"
  echo ""
  echo "       cd $TARGET"
  echo "       git add .github/ .vale.ini .gitignore"
  echo "       git commit -m \"Add DevOps docs AI skills workspace config\""
fi

echo ""
echo "Done."
echo "Reload VS Code to pick up new or updated prompts:"
echo "  macOS/Linux: Cmd/Ctrl+Shift+P → Developer: Reload Window"
