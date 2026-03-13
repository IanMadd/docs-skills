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

  echo ""
  echo "Installed workspace files to: $TARGET_GITHUB"
  echo ""
  echo "  Next step: customize $TARGET_GITHUB/copilot-instructions.md"
  echo "  Replace the placeholder audience and style content with details specific to this repo,"
  echo "  then commit the file:"
  echo ""
  echo "    cd $TARGET"
  echo "    git add .github/"
  echo "    git commit -m \"Add DevOps docs AI skills workspace config\""
fi

echo ""
echo "Done."
echo "Reload VS Code to pick up new or updated prompts:"
echo "  macOS/Linux: Cmd/Ctrl+Shift+P → Developer: Reload Window"
