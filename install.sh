#!/usr/bin/env bash
# install.sh — Install or update the DevOps Docs AI Skills toolkit
#
# Installs prompts and instructions to the VS Code user profile so they are
# available as slash commands in every workspace on this machine.
#
# Run ./install.sh --help for full usage information.
#
# Safe to re-run. Running again after `git pull` updates all installed files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Argument state ────────────────────────────────────────────────────────────
TARGET=""
PROMPTS_SEL=""       # "all", comma-separated names, or "" (skip)
INSTRUCTIONS_SEL=""
SKILLS_SEL=""
EXPLICIT=false       # true when any component flag is given

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
  echo "Usage: ./install.sh [OPTIONS] [TARGET_REPO]"
  echo ""
  echo "Install or update the DevOps Docs AI Skills toolkit."
  echo ""
  echo "OPTIONS"
  echo "  --target PATH          Path to a docs repo to install workspace files into."
  echo "  --prompts NAMES        Prompts to install to the VS Code user profile."
  echo "                         Use 'all' or a comma-separated list of prompt names."
  echo "  --instructions NAMES   Instruction files to install to the VS Code user profile."
  echo "                         Use 'all' or a comma-separated list of instruction names."
  echo "  --skills NAMES         Skills to install to the target repo."
  echo "                         Use 'all' or a comma-separated list of skill names."
  echo "                         Requires --target."
  echo "  -h, --help             Show this message and exit."
  echo ""
  echo "When no component flags are given, all prompts and instructions are installed to"
  echo "the VS Code user profile. If a target repo is also provided, all workspace config"
  echo "files and skills are installed there too."
  echo ""
  echo "When component flags are given, only the specified components are installed."
  echo "Providing --target always installs workspace config files to the target repo."
  echo ""
  echo "AVAILABLE PROMPTS"
  for f in "$SCRIPT_DIR"/.github/prompts/*.prompt.md; do
    [[ -e "$f" ]] && echo "  $(basename "$f" .prompt.md)"
  done
  echo ""
  echo "AVAILABLE INSTRUCTIONS"
  for f in "$SCRIPT_DIR"/.github/instructions/*.instructions.md; do
    [[ -e "$f" ]] && echo "  $(basename "$f" .instructions.md)"
  done
  echo ""
  echo "AVAILABLE SKILLS"
  for d in "$SCRIPT_DIR"/.github/skills/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d")"
  done
  echo ""
  echo "EXAMPLES"
  echo "  # Install everything to the VS Code user profile"
  echo "  ./install.sh"
  echo ""
  echo "  # Install everything, including workspace files for a docs repo"
  echo "  ./install.sh --target ../my-docs-repo"
  echo ""
  echo "  # Install specific prompts only"
  echo "  ./install.sh --prompts draft-tutorial,review-alt-text"
  echo ""
  echo "  # Install a specific skill to a docs repo"
  echo "  ./install.sh --target ../my-docs-repo --skills fix-broken-links"
  echo ""
  echo "  # Install specific prompts and a skill to a docs repo"
  echo "  ./install.sh --target ../my-docs-repo --prompts review-alt-text --skills alt-text-edit"
}

# ── Parse arguments ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"; shift 2 ;;
    --prompts)
      PROMPTS_SEL="$2"; EXPLICIT=true; shift 2 ;;
    --instructions)
      INSTRUCTIONS_SEL="$2"; EXPLICIT=true; shift 2 ;;
    --skills)
      SKILLS_SEL="$2"; EXPLICIT=true; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2
      echo "Run ./install.sh --help for usage." >&2
      exit 1 ;;
    *)
      TARGET="$1"; shift ;;  # backward-compat positional argument
  esac
done

# Resolve TARGET to an absolute path
[[ -n "$TARGET" ]] && TARGET="$(cd "$TARGET" && pwd)"

# Apply defaults when no component flags were given
if [[ "$EXPLICIT" == "false" ]]; then
  PROMPTS_SEL="all"
  INSTRUCTIONS_SEL="all"
  [[ -n "$TARGET" ]] && SKILLS_SEL="all"
fi

# Skills require a target repo
if [[ -n "$SKILLS_SEL" && -z "$TARGET" ]]; then
  echo "Error: --skills requires --target <path-to-docs-repo>." >&2
  exit 1
fi

# ── Locate the VS Code user prompts directory ─────────────────────────────────
case "$(uname -s)" in
  Darwin) VSCODE_USER="$HOME/Library/Application Support/Code/User" ;;
  Linux)  VSCODE_USER="$HOME/.config/Code/User" ;;
  *)      echo "Unsupported OS. Use install.ps1 on Windows." >&2; exit 1 ;;
esac

# Uncomment to target VS Code Insiders instead:
# VSCODE_USER="${VSCODE_USER/Code/Code - Insiders}"

VSCODE_PROMPTS="$VSCODE_USER/prompts"
mkdir -p "$VSCODE_PROMPTS"

# ── Helper functions ──────────────────────────────────────────────────────────

# install_prompts DEST SELECTION
# Installs prompt files to DEST. SELECTION is "all" or comma-separated names.
install_prompts() {
  local dest="$1" sel="$2"
  echo "Installing prompts to: $dest"
  if [[ "$sel" == "all" ]]; then
    cp "$SCRIPT_DIR"/.github/prompts/*.prompt.md "$dest/"
    echo "  Installed $(ls "$SCRIPT_DIR"/.github/prompts/*.prompt.md | wc -l | tr -d ' ') prompt file(s)"
  else
    local count=0
    IFS=',' read -ra names <<< "$sel"
    for name in "${names[@]}"; do
      name="${name// /}"
      local file="$SCRIPT_DIR/.github/prompts/${name}.prompt.md"
      if [[ -f "$file" ]]; then
        cp "$file" "$dest/"
        echo "  Installed: ${name}.prompt.md"
        (( count++ )) || true
      else
        echo "  Warning: prompt not found: ${name}" >&2
      fi
    done
    echo "  Installed $count prompt file(s)"
  fi
}

# install_instructions DEST SELECTION
# Installs instruction files to DEST. SELECTION is "all" or comma-separated names.
install_instructions() {
  local dest="$1" sel="$2"
  echo "Installing instructions to: $dest"
  if [[ "$sel" == "all" ]]; then
    cp "$SCRIPT_DIR"/.github/instructions/*.instructions.md "$dest/"
    echo "  Installed $(ls "$SCRIPT_DIR"/.github/instructions/*.instructions.md | wc -l | tr -d ' ') instruction file(s)"
  else
    local count=0
    IFS=',' read -ra names <<< "$sel"
    for name in "${names[@]}"; do
      name="${name// /}"
      local file="$SCRIPT_DIR/.github/instructions/${name}.instructions.md"
      if [[ -f "$file" ]]; then
        cp "$file" "$dest/"
        echo "  Installed: ${name}.instructions.md"
        (( count++ )) || true
      else
        echo "  Warning: instruction file not found: ${name}" >&2
      fi
    done
    echo "  Installed $count instruction file(s)"
  fi
}

# install_skills DEST SELECTION
# Installs skill directories to DEST. SELECTION is "all" or comma-separated names.
install_skills() {
  local dest="$1" sel="$2"
  mkdir -p "$dest"
  if [[ "$sel" == "all" ]]; then
    local count=0
    for skill_dir in "$SCRIPT_DIR"/.github/skills/*/; do
      local skill_name
      skill_name="$(basename "$skill_dir")"
      cp -r "${skill_dir%/}" "$dest/"
      echo "  Installed skill: $skill_name"
      (( count++ )) || true
    done
    echo "  Installed $count skill(s) total"
  else
    local count=0
    IFS=',' read -ra names <<< "$sel"
    for name in "${names[@]}"; do
      name="${name// /}"
      local dir="$SCRIPT_DIR/.github/skills/${name}"
      if [[ -d "$dir" ]]; then
        cp -r "$dir" "$dest/"
        echo "  Installed skill: $name"
        (( count++ )) || true
      else
        echo "  Warning: skill not found: ${name}" >&2
      fi
    done
    echo "  Installed $count skill(s)"
  fi
}

# ── Install to VS Code user profile ──────────────────────────────────────────
[[ -n "$PROMPTS_SEL" ]]      && install_prompts      "$VSCODE_PROMPTS" "$PROMPTS_SEL"
[[ -n "$INSTRUCTIONS_SEL" ]] && install_instructions "$VSCODE_PROMPTS" "$INSTRUCTIONS_SEL"

# ── Install workspace files to target repo ────────────────────────────────────
if [[ -n "$TARGET" ]]; then
  if [[ ! -d "$TARGET/.git" ]]; then
    echo "Error: '$TARGET' is not the root of a Git repository." >&2
    exit 1
  fi

  TARGET_GITHUB="$TARGET/.github"
  TARGET_INSTRUCTIONS="$TARGET_GITHUB/instructions"
  TARGET_SKILLS="$TARGET_GITHUB/skills"
  mkdir -p "$TARGET_INSTRUCTIONS"

  # Workspace config files are always installed when --target is given.
  # copilot-instructions.md is kept per-repo so it can be customized for each project.
  cp "$SCRIPT_DIR"/.github/copilot-instructions.md "$TARGET_GITHUB/"
  cp "$SCRIPT_DIR"/.github/instructions/doc-types.instructions.md "$TARGET_INSTRUCTIONS/"
  echo "Installed workspace config to: $TARGET_GITHUB"

  # Install skills
  [[ -n "$SKILLS_SEL" ]] && install_skills "$TARGET_SKILLS" "$SKILLS_SEL"

  # Vale config — install in default mode or when skills are being installed.
  # .vale.ini points vale at the Google and Microsoft style packages.
  # vale sync downloads the package files to .vale/styles/ — those should not be committed.
  if [[ "$EXPLICIT" == "false" || -n "$SKILLS_SEL" ]]; then
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
  fi

  if [[ "$EXPLICIT" == "false" ]]; then
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
fi

echo ""
echo "Done."
echo "Reload VS Code to pick up new or updated prompts:"
echo "  Cmd/Ctrl+Shift+P → Developer: Reload Window"
