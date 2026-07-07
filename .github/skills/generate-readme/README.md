# Generate readme skill

Reads through a repository and generates or updates a `README.md` file at the
repository root.

## Description

With this skill, you can create a `README.md` from scratch or update an existing one.
The skill reads your repository's manifest files, source code, CI/CD configs, and
existing documentation to produce a README that accurately describes what the project
does and how to use it.

If a `README.md` already exists, the skill asks whether to regenerate the file entirely
or update it section by section.
In update mode, any custom sections you've added are preserved unchanged.

## Who is this for

Developers and documentation writers who want to:

- Create an initial README for a new or undocumented repository
- Bring an outdated README up to date based on the current state of the codebase
- Ensure a README covers all standard sections without writing it manually

## Inputs

| Input | Required | Description | Example |
|-------|----------|-------------|---------|
| Repository root path | Yes | Path to the root of the repository | `.` for the current workspace, or `/path/to/repo` |
| Mode (regenerate or update) | Only if README exists | Whether to replace the entire file or update sections in place | Prompted at runtime if a `README.md` is found |

## Workflow stages

The skill runs a four-stage workflow.

### Stage 0: Check for an existing README

Checks whether a `README.md` already exists at the repository root.

- If no `README.md` exists, the skill runs in **create mode** and proceeds directly to Stage 1.
- If a `README.md` exists, the skill asks whether to **regenerate** (replace the entire
  file) or **update** (rewrite each recognized section and preserve custom ones).

### Stage 1: Discover the repository structure

Lists the repository root and records every top-level file and subdirectory.
Identifies manifest files (`package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`,
and so on), documentation files (`CONTRIBUTING.md`, `LICENSE`, `.env.example`, and so
on), CI/CD configs (`.github/workflows/`, `.gitlab-ci.yml`, and so on), and source
directories (`src/`, `lib/`, `cmd/`, and so on).

### Stage 2: Read key files

Reads the files identified in Stage 1 in a defined order:

1. Manifest files --- extracts the project name, version, description, license, and
   available commands
2. Documentation files --- extracts the contributing process, license name, and
   configuration options
3. CI/CD workflow files --- extracts build, test, and install commands
4. Source files --- reads up to 10 source files when no manifest provides a clear
   description of what the project does

### Stage 3: Draft and write the README

Drafts each section from the collected information and writes the file.

The README always includes:

- Project name and one-sentence description
- Short description paragraph
- **Prerequisites**
- **Installation**
- **Usage**
- **Contributing**

The README includes the following sections when source material is available:

- **Configuration** --- when environment variables or config files are present
- **License** --- when a `LICENSE` file or license identifier is present

**Update mode**: sections matching an existing heading are replaced; unrecognized custom
sections are preserved and listed in the write summary.

## After the skill runs

The skill reports:

- Which mode ran (created, regenerated, or updated)
- Which sections were written or updated
- Which custom sections were preserved (update mode only)
- Every file read during Stages 1 and 2
- Any `<!-- TODO: verify -->` comments added, with the reason for each
- Any files that existed but couldn't be read

## Related

- [SKILL.md](SKILL.md) --- full workflow instructions for this skill
- [docs-style.instructions.md](../../instructions/docs-style.instructions.md) --- team
  prose style guide
- [doc-types.instructions.md](../../instructions/doc-types.instructions.md) --- README
  doc type structure
