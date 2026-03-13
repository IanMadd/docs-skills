# DevOps Docs AI Skills

A reusable toolkit of GitHub Copilot prompts and instructions for documentation teams
writing technical content for DevOps engineers.

## What's in this toolkit

| File | What it does |
|------|-------------|
| `.github/copilot-instructions.md` | Always-on context: audience, tone, and style baseline for the whole workspace |
| `.github/instructions/devops-docs-style.instructions.md` | Style rules auto-applied to every Markdown file |
| `.github/instructions/doc-types.instructions.md` | On-demand structural templates for each of the six doc types |
| `.github/prompts/draft-tutorial.prompt.md` | `/draft-tutorial` — scaffold a new tutorial |
| `.github/prompts/draft-how-to.prompt.md` | `/draft-how-to` — scaffold a how-to guide |
| `.github/prompts/draft-reference-doc.prompt.md` | `/draft-reference-doc` — scaffold a reference page |
| `.github/prompts/draft-conceptual.prompt.md` | `/draft-conceptual` — scaffold a conceptual or overview doc |
| `.github/prompts/draft-release-notes.prompt.md` | `/draft-release-notes` — convert a changelog or PR list to structured release notes |
| `.github/prompts/draft-readme.prompt.md` | `/draft-readme` — generate a README for a tool or repo |
| `.github/prompts/edit-for-style.prompt.md` | `/edit-for-style` — rewrite a doc to comply with the style guide |
| `.github/prompts/review-completeness.prompt.md` | `/review-completeness` — audit a doc for gaps, missing steps, and accuracy |
| `.github/prompts/generate-code-examples.prompt.md` | `/generate-code-examples` — generate shell, YAML, CLI, HCL, or config examples |
| `.github/prompts/notes-to-doc.prompt.md` | `/notes-to-doc` — convert raw notes or tickets into a structured draft |
| `install.sh` | Install or update the toolkit on macOS and Linux |
| `install.ps1` | Install or update the toolkit on Windows |

## Requirements

- [VS Code](https://code.visualstudio.com/) 1.99 or later
- [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) with an active Copilot subscription

## Quick start

### macOS and Linux

1. Clone this repository.

   ```shell
   git clone <repo-url>
   cd docs-skills
   ```

2. Run the install script.

   ```shell
   ./install.sh
   ```

   To also install workspace files into an existing docs repo, pass the repo path as an argument:

   ```shell
   ./install.sh ../path/to/your-docs-repo
   ```

3. Open VS Code and reload the window (`Cmd+Shift+P` → **Developer: Reload Window**).

4. Open Copilot Chat (`Cmd+Option+I`) and type `/` to see the available prompts.

### Windows

1. Clone this repository.

   ```shell
   git clone <repo-url>
   cd docs-skills
   ```

2. Run the install script in PowerShell.

   ```shell
   .\install.ps1
   ```

   If you see an execution policy error, run this first:

   ```shell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

   To also install workspace files into an existing docs repo, pass the repo path:

   ```shell
   .\install.ps1 -TargetRepo .\path\to\your-docs-repo
   ```

3. Open VS Code and reload the window (`Ctrl+Shift+P` → **Developer: Reload Window**).

4. Open Copilot Chat (`Ctrl+Alt+I`) and type `/` to see the available prompts.

## How to use the prompts

All prompts appear as slash commands in Copilot Chat.

1. Open Copilot Chat in VS Code.
2. Type `/` to see all available prompts.
3. Select a prompt, then enter the requested input when prompted.

**Example — draft a how-to guide**:

1. Type `/draft-how-to` in Copilot Chat.
2. Enter: `Configure a Kubernetes NetworkPolicy to restrict pod-to-pod traffic`
3. Copilot returns a structured draft. Copy it to a new `.md` file and edit as needed.

**Example — edit an existing draft for style**:

1. Open the draft in VS Code.
2. Type `/edit-for-style` in Copilot Chat.
3. Attach the file using `#` or paste the content directly.
4. Copilot returns the corrected version with a summary of changes made.

## How the style instructions work

The file `.github/instructions/devops-docs-style.instructions.md` uses `applyTo: "**/*.md"` in
its frontmatter. Copilot automatically loads it whenever you open or edit any Markdown file —
no action needed. Style rules apply in the background on every interaction involving a `.md` file.

## Keeping the toolkit up to date

Pull the latest changes and re-run the install script. The scripts overwrite existing files,
so this is the complete update process:

**macOS and Linux**:

```shell
cd path/to/docs-skills
git pull
./install.sh
```

**Windows**:

```shell
cd path\to\docs-skills
git pull
.\install.ps1
```

After running, reload VS Code (`Cmd/Ctrl+Shift+P` → **Developer: Reload Window**) to pick up the changes.

> **Note:** The `install.sh` and `install.ps1` scripts update your VS Code user profile only.
> If your docs repos have a committed `.github/copilot-instructions.md`, that file is
> project-specific and won't be overwritten by the script.

## Customizing the toolkit

### Add product-specific terminology

Edit `.github/instructions/devops-docs-style.instructions.md` and add terms to the
"DevOps terminology" section.

### Adjust the style guide reference

The instructions reference both the Google Developer Documentation Style Guide and the
Microsoft Writing Style Guide. To pin to one guide or add team-specific overrides, edit the
opening section of `.github/instructions/devops-docs-style.instructions.md`.

### Add a new prompt

1. Create a file in `.github/prompts/` named `<task>.prompt.md`.
2. Add YAML frontmatter with at least a `description` (keyword-rich) and `agent: "agent"`.
3. Reference the instruction files for style and structure context.

```markdown
---
description: "What this prompt does and when to use it — include trigger keywords."
name: "Prompt display name"
argument-hint: "What to enter when the prompt asks for input"
agent: "agent"
---

Prompt body. Reference shared instructions like this:
[devops-docs-style.instructions.md](../instructions/devops-docs-style.instructions.md)
```

## Contributing

Open a pull request with your proposed changes. For changes to style rules, include a
before-and-after example showing the effect on a sample document.
