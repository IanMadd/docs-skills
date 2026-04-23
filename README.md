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
| `.github/skills/generate-examples-from-repo/` | `/generate-examples-from-repo` — fetch source code from a public GitHub repository, extract usage patterns for one command or all commands, and generate formatted, annotated examples ready for documentation |

### Install scripts

| File | What it does |
|------|-------------|
| `install.sh` | Install or update the toolkit on macOS and Linux |
| `install.ps1` | Install or update the toolkit on Windows |

## Install skills, prompts, and instructions

### Requirements

- [VS Code](https://code.visualstudio.com/) 1.99 or later
- [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) with an active Copilot subscription

### Before you install

Clone this repository if you haven't already:

```shell
git clone <repo-url>
cd docs-skills
```

Run `./install.sh --help` (macOS and Linux) or `.\install.ps1 -Help` (Windows) to list
available names for all component types and see additional usage examples.

### Install prompts

Prompts are installed to the VS Code user profile and appear as slash commands in every
workspace on the machine. No target repo is needed.

To install all prompts:

**macOS and Linux**:

```shell
./install.sh --prompts all
```

**Windows**:

```shell
.\install.ps1 -Prompts all
```

To install specific prompts, provide a comma-separated list of prompt names:

**macOS and Linux**:

```shell
./install.sh --prompts draft-tutorial,review-alt-text
```

**Windows**:

```shell
.\install.ps1 -Prompts draft-tutorial,review-alt-text
```

After installing, reload VS Code (`Cmd+Shift+P` / `Ctrl+Shift+P` → **Developer: Reload Window**)
and open Copilot Chat. Type `/` to see the installed prompts.

### Install instructions

Instruction files are installed to the VS Code user profile. The `devops-docs-style`
instruction file uses `applyTo: "**/*.md"` and loads automatically whenever you work with
a Markdown file. The `doc-types` file is loaded on demand when you ask about document
structure or templates.

To install all instruction files:

**macOS and Linux**:

```shell
./install.sh --instructions all
```

**Windows**:

```shell
.\install.ps1 -Instructions all
```

To install a specific instruction file, provide its name without the `.instructions.md` extension:

**macOS and Linux**:

```shell
./install.sh --instructions devops-docs-style
```

**Windows**:

```shell
.\install.ps1 -Instructions devops-docs-style
```

After installing, reload VS Code (`Cmd+Shift+P` / `Ctrl+Shift+P` → **Developer: Reload Window**)
to pick up the updated instruction files.

### Install skills

Skills are workspace-scoped and must be installed into each docs repo where you want to use
them. They appear as slash commands only in VS Code Copilot Agent mode when the
`.github/skills/` directory is present in the open repo.

Installing skills also copies `copilot-instructions.md` and the `doc-types` instruction
file into the target repo's `.github/` directory, and installs `.vale.ini` if it isn't
already present.

To install all skills into a docs repo:

**macOS and Linux**:

```shell
./install.sh --target ../path/to/your-docs-repo --skills all
```

**Windows**:

```shell
.\install.ps1 -TargetRepo ..\path\to\your-docs-repo -Skills all
```

To install a specific skill, provide its directory name:

**macOS and Linux**:

```shell
./install.sh --target ../path/to/your-docs-repo --skills fix-broken-links
```

**Windows**:

```shell
.\install.ps1 -TargetRepo ..\path\to\your-docs-repo -Skills fix-broken-links
```

After installing, reload VS Code (`Cmd+Shift+P` / `Ctrl+Shift+P` → **Developer: Reload Window**)
and switch to Agent mode in Copilot Chat. Type `/` to see the installed skills.

If you installed the `docs-style-edit` skill, run `vale sync` in the target repo to
download the required style packages:

```shell
cd path/to/your-docs-repo
vale sync
```

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

## How to use the generate-examples-from-repo skill

The `/generate-examples-from-repo` skill reads source code from a public GitHub repository and
generates documentation-ready code examples with realistic argument values and expected output.
Examples come from spec and test files, so they reflect how the tool is actually used.

1. **Stage 1 — Discover**: Fetches the repo's directory listing and locates command definitions
   by language and framework (Ruby, Go, Python, Node.js). Builds a full command inventory.
2. **Stage 2 — Fetch**: Retrieves spec and test files for each command in scope using raw
   GitHub URLs. Falls back to implementation files when spec coverage is missing.
3. **Stage 3 — Extract**: Reads invocation patterns, flag combinations, output assertions, and
   error-path tests from the fetched files. Builds a per-command usage inventory.
4. **Stage 4 — Generate**: Produces a canonical usage line, two to four concrete invocations,
   expected output (only when asserted in specs), a key-flags description list, and an
   explanatory paragraph per command.

**Usage**:

1. Open Copilot Chat in VS Code and switch to **Agent** mode using the mode dropdown.
2. Type `/generate-examples-from-repo`.
3. Enter a GitHub repository URL when prompted — for example:
   `https://github.com/chef/chef-cli`
4. Optionally add a command name to scope the output to a single command — for example:
   `https://github.com/chef/chef-cli generate cookbook`
5. Copilot runs all four stages and returns formatted Markdown examples with a source summary.

> **Tip**: If you want examples for all commands, let the skill enumerate them first. When a
> repo has more than 15 commands, it asks you to confirm scope or select a subset before
> fetching anything.

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

> **Note:** The install scripts update your VS Code user profile only when run without
> `--target` / `-TargetRepo`. If your docs repos have a committed `.github/copilot-instructions.md`,
> that file is project-specific and won't be overwritten by the script. Skills are
> workspace-scoped — use `--target` / `-TargetRepo` to install or update them in each docs repo.

## Sync skills automatically with a GitHub Action

You can keep skills and instruction files current across target repos using either of the
following approaches:

- **Push from docs-skills**: a workflow in this repository triggers on a push to `main` and
  pushes changes into each target repo directly. Requires a PAT with write access to every
  target repo.
- **Pull from target repos (cron)**: a workflow in each target repo runs on a daily schedule,
  checks whether this repository has changed, and pulls the updates. Requires no PAT and no
  workflow in this repository.

### Push from docs-skills

This approach runs a workflow in this repository whenever you push to `main`. The workflow
checks out each target docs repo, runs the install script against it, and opens a pull request
with the updated files.

#### Requirements

- A GitHub personal access token (PAT) or a GitHub App token with `contents: write` and
  `pull-requests: write` permissions on each target docs repo, stored as a secret named
  `SYNC_TOKEN` in this repository.
- The [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)
  action, which handles committing changes and opening the PR.

#### Set up the push workflow

To configure push-based syncing, follow these steps:

1. Add your token as a repository secret named `SYNC_TOKEN` (**Settings** > **Secrets and
   variables** > **Actions** > **New repository secret**).

1. Create the workflow file at `.github/workflows/sync-skills.yml` in this repository:

   ```yaml
   name: Sync skills to docs repos

   on:
     push:
       branches:
         - main
       paths:
         - .github/instructions/**
         - .github/skills/**

   jobs:
     sync:
       runs-on: ubuntu-latest
       strategy:
         matrix:
           repo:
             - <org>/<docs-repo-1>
             - <org>/<docs-repo-2>
       steps:
         - name: Check out docs-skills
           uses: actions/checkout@v4
           with:
             path: docs-skills

         - name: Check out target repo
           uses: actions/checkout@v4
           with:
             repository: ${{ matrix.repo }}
             token: ${{ secrets.SYNC_TOKEN }}
             path: target-repo

         - name: Run install script
           run: |
             cd docs-skills
             ./install.sh --target ../target-repo --skills all

         - name: Open pull request
           uses: peter-evans/create-pull-request@v6
           with:
             token: ${{ secrets.SYNC_TOKEN }}
             path: target-repo
             commit-message: "chore: sync docs-skills toolkit"
             title: "chore: sync docs-skills toolkit"
             body: |
               Automated sync from the [docs-skills](https://github.com/IanMadd/docs-skills) repository.
               Review the changes and merge when ready.
             branch: sync/docs-skills
             delete-branch: true
   ```

1. In the `matrix.repo` list, replace `<org>/<docs-repo-1>` and `<org>/<docs-repo-2>` with
   the names of your target documentation repositories, for example `myorg/platform-docs`.
   Add one entry per repo.

1. Commit and push the workflow file to `main`.

After setup, every push that changes `.github/instructions/` or `.github/skills/` in this
repository triggers the workflow and opens a pull request in each target repo.

### Pull from target repos (cron)

This approach adds a workflow to each target docs repo. The workflow runs on a daily schedule,
fetches the latest commit SHA from this repository, and runs the install script only when the
SHA has changed since the last sync. No workflow is needed in this repository, and no PAT is
required---the workflow uses the target repo's own `GITHUB_TOKEN`.

#### Requirements

- The [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)
  action in each target repo.
- Read access from each target repo to this repository (no token needed if this repo is public).

#### Set up the pull workflow

Add the following workflow file at `.github/workflows/sync-docs-skills.yml` in each target
docs repo:

```yaml
name: Sync docs-skills toolkit

on:
  schedule:
    - cron: '0 6 * * *'   # Runs daily at 06:00 UTC
  workflow_dispatch:        # Allow manual runs

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Get latest docs-skills commit SHA
        id: remote-sha
        run: |
          SHA=$(git ls-remote https://github.com/IanMadd/docs-skills.git HEAD | cut -f1)
          echo "sha=$SHA" >> "$GITHUB_OUTPUT"

      - name: Get last synced SHA
        id: cached-sha
        run: |
          if [ -f .docs-skills-sha ]; then
            echo "sha=$(cat .docs-skills-sha)" >> "$GITHUB_OUTPUT"
          else
            echo "sha=" >> "$GITHUB_OUTPUT"
          fi

      - name: Skip if already up to date
        if: steps.remote-sha.outputs.sha == steps.cached-sha.outputs.sha
        run: |
          echo "docs-skills is already up to date. Skipping."
          exit 0

      - name: Check out docs-skills
        if: steps.remote-sha.outputs.sha != steps.cached-sha.outputs.sha
        uses: actions/checkout@v4
        with:
          repository: IanMadd/docs-skills
          path: docs-skills
          fetch-depth: 0

      - name: Check for relevant changes
        id: relevant-changes
        if: steps.remote-sha.outputs.sha != steps.cached-sha.outputs.sha
        run: |
          OLD_SHA="${{ steps.cached-sha.outputs.sha }}"
          NEW_SHA="${{ steps.remote-sha.outputs.sha }}"
          if [ -z "$OLD_SHA" ]; then
            echo "First run — treating all files as changed."
            echo "changed=true" >> "$GITHUB_OUTPUT"
          else
            CHANGED=$(git -C docs-skills log --oneline "$OLD_SHA..$NEW_SHA" \
              -- .github/skills .github/instructions)
            if [ -n "$CHANGED" ]; then
              echo "Relevant changes found."
              echo "changed=true" >> "$GITHUB_OUTPUT"
            else
              echo "No changes to .github/skills or .github/instructions. Skipping."
              echo "changed=false" >> "$GITHUB_OUTPUT"
            fi
          fi

      - name: Check out this repo
        if: steps.relevant-changes.outputs.changed == 'true'
        uses: actions/checkout@v4
        with:
          path: target-repo

      - name: Run install script
        if: steps.relevant-changes.outputs.changed == 'true'
        run: |
          cd docs-skills
          ./install.sh --target ../target-repo --skills all

      - name: Record new SHA
        if: steps.relevant-changes.outputs.changed == 'true'
        run: echo "${{ steps.remote-sha.outputs.sha }}" > target-repo/.docs-skills-sha

      - name: Open pull request
        if: steps.relevant-changes.outputs.changed == 'true'
        uses: peter-evans/create-pull-request@v6
        with:
          path: target-repo
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: "chore: sync docs-skills toolkit"
          title: "chore: sync docs-skills toolkit"
          body: |
            Automated sync from the [docs-skills](https://github.com/IanMadd/docs-skills) repository.

            Updated to commit `${{ steps.remote-sha.outputs.sha }}`.
            Review the changes and merge when ready.
          branch: sync/docs-skills
          delete-branch: true
```

To sync only specific components, replace `--skills all` with the flags you need---for
example, `--skills fix-broken-links,docs-style-edit` or `--instructions all`.

The workflow runs at 06:00 UTC every day.
It fetches the current `HEAD` SHA from this repository using `git ls-remote` and compares it
to the SHA stored in `.docs-skills-sha` at the root of the target repo.
If the SHAs match, the workflow exits early.
If they differ, it checks out docs-skills with full history and uses `git log` to check
whether any commits between the old and new SHA touched `.github/skills` or
`.github/instructions`.
If none did, the workflow skips the install and PR---no changes to those directories means
nothing to sync.
If relevant changes are found, it checks out the target repo, runs the install script,
records the new SHA, and opens a pull request.

The first time the workflow runs, `.docs-skills-sha` won't exist, so the install always runs
and creates the file.
You can also trigger the workflow manually from **Actions** > **Sync docs-skills toolkit** >
**Run workflow** in the target repo.

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
