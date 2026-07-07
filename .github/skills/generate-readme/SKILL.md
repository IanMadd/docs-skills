---
name: generate-readme
description: 'Read through a repository and generate or update a README.md file at the repository root. Creates a comprehensive, well-structured README from scratch if one doesn''t exist, or updates an existing one. Triggers on: generate readme, create readme, update readme, write readme, README.md, repository documentation, repo documentation, readme from scratch, document repository, write documentation.'
argument-hint: "Path to the repository root — for example: . for the current workspace, or /path/to/repo"
---

# Generate or update a README

Runs a four-stage workflow to create or update a `README.md` file at the root of a
repository.
The skill reads the repository's source files, manifests, CI/CD configs, and existing
documentation to produce a README that's accurate, informative, and complete.

0. **Check for an existing README** — determines whether to create, regenerate, or update
   in place, based on what's already there and what you choose
1. **Discover** — lists the repository structure and identifies the files most useful for
   writing a README
2. **Read** — reads manifests, documentation files, CI/CD configs, and source files to
   extract the information needed for each section
3. **Draft and write** — drafts each section from the collected information and writes the
   `README.md` file

---

## What to ask before starting

Before starting, confirm these inputs if not already provided:

1. **Repository root path** — the path to the root of the repository to document, for
   example: `.` for the current workspace, or `/path/to/repo`

If a `README.md` already exists at the repository root, ask the user:

> A `README.md` already exists.
> Do you want to:
>
> - **Regenerate** — discard the existing file completely and write a new README from
>   scratch using only what I find in the repository. I won't carry over any text from
>   the existing file.
> - **Update** — rewrite each recognized section individually while preserving any custom
>   sections you've added?

Wait for an answer before continuing.

---

## Stage 0: Check for an existing README

Use `list_dir` on the repository root to check whether a `README.md` file already exists.

Determine the run mode:

| Condition | Mode |
|-----------|------|
| No `README.md` found | **Create** — write the file from scratch |
| `README.md` found, user chose regenerate | **Regenerate** — delete all existing content and write a new README from scratch; don't read or reuse any text from the existing file |
| `README.md` found, user chose update | **Update** — rewrite recognized sections, preserve custom ones |

Report the mode before continuing to Stage 1.

---

## Stage 1: Discover the repository structure

List the root directory and record every top-level file and subdirectory.

### Identify manifest files

Read any of the following that exist.
Each one gives you the project name, version, description, dependencies, and available
commands or scripts:

| File | Project type |
|------|-------------|
| `package.json` | Node.js |
| `go.mod` | Go |
| `pyproject.toml` | Python |
| `setup.py` | Python |
| `requirements.txt` | Python |
| `Gemfile` | Ruby |
| `*.gemspec` | Ruby |
| `Cargo.toml` | Rust |
| `pom.xml` | Java (Maven) |
| `build.gradle` | Java (Gradle) |
| `Makefile` | C/C++, generic |
| `CMakeLists.txt` | C/C++ |
| `composer.json` | PHP |

### Identify documentation files

Note which of the following exist — you'll read them in Stage 2:

- `CONTRIBUTING.md`
- `CHANGELOG.md` or `HISTORY.md`
- `LICENSE`, `LICENSE.md`, or `LICENSE.txt`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`
- `.env.example`, `config.example.yaml`, `config.example.toml`, or any file that names
  environment variables or configuration options

### Identify CI/CD files

Note which of the following exist — you'll read them in Stage 2:

- `.github/workflows/` — list the workflow files
- `.gitlab-ci.yml`
- `Jenkinsfile`
- `.circleci/config.yml`
- `Taskfile.yml` or `Taskfile.yaml`

### Identify source directories

Note which of the following exist:

- `src/`, `lib/`, `cmd/`, `pkg/`, `app/`, `internal/`

---

## Stage 2: Read key files

Read the files identified in Stage 1 in the order below.
Extract only what's needed for the README sections defined in Stage 3.

### Step 2a: Manifest files

From each manifest file, extract:

- Project name
- Version
- Description (if present)
- License identifier
- Scripts, commands, or targets that a user would run (for example, `scripts` in
  `package.json`, `Makefile` targets, `go run` entry points)
- Key runtime dependencies

### Step 2b: Documentation files

From each documentation file, extract:

- `CONTRIBUTING.md` — contributing process, required tools, test commands, support
  channels
- `CHANGELOG.md` or `HISTORY.md` — project history, useful context for the description
- `LICENSE` — license name, for the **License** section
- `.env.example` and config example files — environment variable names, defaults, and
  descriptions, for the **Configuration** section
- `CONTRIBUTORS`, `AUTHORS`, or `ACKNOWLEDGMENTS` — contributors and credits
- `ROADMAP.md` or `ROADMAP` — planned improvements or future release ideas
- `SECURITY.md` — security reporting process, for the **How to get help** section

### Step 2c: CI/CD workflow files

Read up to three CI/CD files.
From each file, extract:

- Build commands
- Test commands
- Install steps
- Deployment targets or environments

### Step 2d: Source files

Read source files only if no manifest file provides a clear description of what the
project does.

1. Look for the main entry point: `main.go`, `cmd/root.go`, `index.js`, `app.py`,
   `lib/<name>.rb`, `src/main.rs`, `src/index.ts`, or similar.
2. Read the main entry point first.
3. Read up to four additional representative files from the source directory.
4. Stop at 10 source files total.

Also check the following to populate optional sections:

- Is there a `ROADMAP.md`, project board link, or roadmap section in any existing doc?
- Is there a `CONTRIBUTORS` or `AUTHORS` file?
- Are there signs the project is no longer actively maintained (repository archived status,
  a deprecation note in an existing README, or a long period without commits)?

After Stage 2, you should be able to answer:

- What does this project do?
- How do you install it?
- How do you run or invoke it?
- What configuration does it require?
- What is the license?

If any answer is unclear after reading the available files, add a
`<!-- TODO: verify — [item] -->` comment in the relevant section of the draft.

---

## Stage 3: Draft and write the README

### Formatting rules

Apply these rules to every section of the README:

- Use GitHub Flavored Markdown.
- Don't use emojis.
- Use sentence case for all headings.
- Wrap all commands in fenced code blocks with a language identifier.
  Use `shell` for terminal commands unless the script targets a specific shell.
- Show expected output in a `console` block when it helps verify a step.
- Mark placeholder values with angle brackets: `<your-api-key>`, `<repo-url>`.
- Use `<!-- TODO: verify — [reason] -->` for anything you can't confirm from the
  source files.

### README structure

Follow the README doc type structure defined in
[doc-types.instructions.md](../../instructions/doc-types.instructions.md).

Use the following table to determine which source data from Stage 2 populates each
section.
Include a section only when you have relevant source data for it.
Mark any section where data is incomplete with `<!-- TODO: verify — [reason] -->`.

| README section | When to include | Source data |
|---------------|-----------------|-------------|
| Project name | Always | Manifest name field, or repository directory name |
| One-sentence description | Always | Manifest `description` field, or source file header comments |
| Project description | Always | Manifest `description`; `CHANGELOG.md` or `HISTORY.md` for history and context |
| Who is this for | Always | Manifest `description`, CI target environments, source files |
| Prerequisites | Always | Manifest dependencies and minimum versions, CI/CD runtime requirements |
| Quick start | Always | Manifest `scripts`, CI install and run steps, source file entry points |
| Installation | Always | Manifest install commands, CI/CD install steps |
| Configuration | When config files or environment variables are present | `.env.example`, config example files, CI environment variable definitions |
| Usage | Always | Manifest `scripts`, source file entry points, CI workflow steps |
| Troubleshooting | When common errors can be inferred or are documented | Existing README or linked docs |
| Contributing | Always | `CONTRIBUTING.md` content, or a brief inline guide based on what you found |
| How to get help | Always | `CONTRIBUTING.md`, manifest `bugs` or `homepage` field, `SECURITY.md` |
| Roadmap | When explicitly documented | `ROADMAP.md`, project board links, or roadmap sections in existing docs |
| Authors and acknowledgment | When contributors are documented | `CONTRIBUTORS`, `AUTHORS`, manifest `contributors` field |
| Additional documentation | When supplementary docs exist in the repository | Linked docs found during discovery |
| License | When a license file or identifier is present | `LICENSE` file, manifest `license` field |
| Project status | When signs of inactivity are found | Archived repository status, deprecation notes, or existing README notice |

### Write the file

**Create mode** or **Regenerate mode**:
Write the entire drafted content to `README.md` at the repository root.
Delete all existing content before writing.
Don't read or carry over any text from the existing file — the new README is written
entirely from what the skill discovered in Stages 1 and 2.

**Update mode**:

1. For each section in the draft, find the matching heading in the existing `README.md`
   (exact or case-insensitive match).
2. If a match is found, replace that section's content with the new draft content.
3. If no match is found for a section in the draft, append it to the end of the file.
4. Preserve any sections in the existing `README.md` that have no counterpart in the
   draft — these are custom sections the user added.
   Note each preserved section in the write summary.

---

## Final output

Produce the written `README.md` and a `## Write summary` section reporting:

- **Mode**: created, regenerated, or updated
- **Sections written**: list each section heading written or updated
- **Custom sections preserved** (update mode only): list any headings kept unchanged
- **Files read**: list every file read during Stages 1 and 2
- **TODO comments added**: list each `<!-- TODO: verify -->` comment and its reason
- **Unreadable files**: any files that existed but couldn't be read, with the reason
