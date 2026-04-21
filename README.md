# DevOps Docs AI Skills

A reusable toolkit of GitHub Copilot prompts and instructions for documentation teams
writing technical content for DevOps engineers.

## What's in this toolkit

### Instructions

| File | What it does |
|------|-------------|
| `.github/copilot-instructions.md` | Always-on context: audience, tone, and style baseline for the whole workspace |
| `.github/instructions/devops-docs-style.instructions.md` | Style rules auto-applied to every Markdown file |
| `.github/instructions/doc-types.instructions.md` | On-demand structural templates for each of the six doc types |

### Prompts

Prompts are single-task slash commands. Use them for drafting or editing one document at a time.

| File | What it does |
|------|-------------|
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
| `.github/prompts/review-alt-text.prompt.md` | `/review-alt-text` — audit a doc for missing, weak, and unverified alt text; produces a per-image report with suggested fixes |

### Skills

Skills are multi-stage workflows. Use them when a task requires sequential steps with intermediate results — for example, running a linter and then applying fixes based on its output.

| Directory | What it does |
|-----------|-------------|
| `.github/skills/docs-style-edit/` | `/docs-style-edit` — lint with markdownlint-cli2 and vale, fix all flagged issues, then apply the style guide |
| `.github/skills/alt-text-edit/` | `/alt-text-edit` — scan a file for images, audit every alt text value, view each image, draft accurate descriptions, and edit the file in place |
| `.github/skills/fix-broken-links/` | `/fix-broken-links` — run linkchecker against a site or build output, map broken links to Markdown source files, suggest replacements, and apply confirmed fixes |

### Install scripts

| File | What it does |
|------|-------------|
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

   To install specific prompts, instructions, or skills instead of everything, use the
   `--prompts`, `--instructions`, and `--skills` flags with `all` or a comma-separated list
   of names. Run `./install.sh --help` to see available names and more examples.

   ```shell
   # Install a specific skill to an existing docs repo
   ./install.sh --target ../path/to/your-docs-repo --skills fix-broken-links

   # Install specific prompts only
   ./install.sh --prompts review-alt-text,review-completeness
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

   To install specific prompts, instructions, or skills instead of everything, use the
   `-Prompts`, `-Instructions`, and `-Skills` flags with `all` or a comma-separated list
   of names. Run `.\install.ps1 -Help` to see available names and more examples.

   ```shell
   # Install a specific skill to an existing docs repo
   .\install.ps1 -TargetRepo .\path\to\your-docs-repo -Skills fix-broken-links

   # Install specific prompts only
   .\install.ps1 -Prompts review-alt-text,review-completeness
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

## How to use the docs-style-edit skill

The `/docs-style-edit` skill runs a four-stage editing workflow for an existing document:

1. **Stage 1 — Markdown lint**: Runs `markdownlint-cli2 --fix` to auto-correct formatting issues, then reports anything that couldn't be auto-fixed.
2. **Stage 2 — Lint**: Uses the Vale MCP server (or CLI fallback) to capture all prose errors, warnings, and suggestions.
3. **Stage 3 — Fix vale issues**: Applies fixes for every flagged item, working from errors down to suggestions.
4. **Stage 4 — Apply style guide**: Edits the fixed document against the full DevOps docs style rules.

**Prerequisites**: markdownlint-cli2 must be installed, and either the Vale MCP server must be
configured in VS Code or vale must be installed with `vale sync` run in the repo. The skill
uses the Vale MCP server when available and falls back to the CLI. See
`.github/skills/docs-style-edit/references/markdownlint-setup.md` and
`.github/skills/docs-style-edit/references/vale-setup.md` for setup instructions.

**Usage**:

1. Open Copilot Chat in VS Code and switch to **Agent** mode using the mode dropdown.
2. Type `/docs-style-edit`.
3. Enter the path to the file you want to edit, for example: `docs/how-to-deploy.md`
4. Copilot runs all four stages and returns the edited file plus a summary of changes.

> **Tip**: If `/docs-style-edit` doesn't appear, check that you're in **Agent** mode (not Ask
> or Edit) and that `.github/skills/docs-style-edit/` exists in the repo you have open. Run
> `./install.sh <path-to-your-docs-repo>` to install it.

## How to use the alt-text-edit skill

The `/alt-text-edit` skill runs a four-stage workflow to audit and fix alt text in an
existing Markdown file:

1. **Stage 1 — Find images**: Scans the file for all image references in Markdown
   (`![]()`) and HTML (`<img>`) syntax.
2. **Stage 2 — Audit**: Categorizes each image as missing, weak, decorative, or acceptable
   based on accessibility and style standards.
3. **Stage 3 — View and draft**: Uses the `view_image` tool to inspect each local image and
   drafts accurate alt text based on what the image shows and its surrounding context.
4. **Stage 4 — Edit**: Writes the new alt text into the file for every image that needs it.

**Prerequisites**: No external tools required. The skill uses built-in agent capabilities to
view images. Images must be in the workspace for the agent to view them; external URLs are
flagged with a `<!-- TODO: verify -->` comment for human review.

**Usage**:

1. Open Copilot Chat in VS Code and switch to **Agent** mode using the mode dropdown.
2. Type `/alt-text-edit`.
3. Enter the path to the file you want to edit, for example: `docs/how-to-deploy.md`
4. Copilot audits every image, views local image files, drafts alt text, edits the file,
   and returns a summary of every change made.

> **Tip**: If `/alt-text-edit` doesn't appear, check that you're in **Agent** mode (not Ask
> or Edit) and that `.github/skills/alt-text-edit/` exists in the repo you have open. Run
> `./install.sh <path-to-your-docs-repo>` to install it.

## How to use the fix-broken-links skill

The `/fix-broken-links` skill checks a documentation site for dead links and fixes them in
the Markdown source. It supports three check targets and can scope the check to one section
of a multi-repo site.

1. **Stage 1 — Verify installation**: Confirms linkchecker is installed and the check target
   is ready (dev server running, or build output directory populated).
2. **Stage 2 — Configure check**: Builds the linkchecker command for the target type. Applies
   URL filters to restrict the crawl to the section this repository owns.
3. **Stage 3 — Run linkchecker**: Runs the check and writes errors to `linkchecker-errors.csv`.
4. **Stage 4 — Parse errors**: Reads the CSV and extracts every broken URL with its parent page.
5. **Stage 5 — Map to source**: Maps each broken link back to the Markdown file that generated
   the parent page, using generator-specific path patterns (Hugo, MkDocs, Jekyll).
6. **Stage 6 — Fix links**: Searches the repo for a likely replacement URL, presents it for
   confirmation, and applies the fix. Flags links with no replacement as TODO comments.

**Prerequisites**: linkchecker must be installed. See
`.github/skills/fix-broken-links/references/linkchecker-setup.md` for installation instructions.
The check target must be reachable when the skill runs — start your local dev server or run
your site generator's build command first.

**Usage**:

1. Open Copilot Chat in VS Code and switch to **Agent** mode using the mode dropdown.
2. Type `/fix-broken-links`.
3. Enter the check target when prompted — for example:
   - `http://localhost:1313/` for a Hugo dev server
   - `https://docs.example.com/platform/v2/` to check a deployed section
   - `/path/to/public/` for a local build output
4. Optionally provide a URL path prefix to scope the check to one section of the site.
5. Copilot runs all six stages and returns a fix summary with every change made.

> **Tip**: If `/fix-broken-links` doesn't appear, check that you're in **Agent** mode (not Ask
> or Edit) and that `.github/skills/fix-broken-links/` exists in the repo you have open. Run
> `./install.sh <path-to-your-docs-repo>` to install it.

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
> project-specific and won't be overwritten by the script. The `docs-style-edit` skill is
> workspace-scoped — run the install script with a target repo path to install it there.

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
