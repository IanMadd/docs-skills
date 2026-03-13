# DevOps Docs Team — Workspace Context

This repository contains documentation written for DevOps engineers: professionals
who design, build, operate, and maintain CI/CD pipelines, infrastructure, containers,
configuration management systems, monitoring stacks, and cloud environments.

## Audience

- **Primary**: DevOps engineers, platform engineers, SREs
- **Assumes**: Familiarity with Linux, shell scripting, Git, containers, and cloud platforms
- **Does not assume**: Knowledge of a specific vendor's tooling; explain tool-specific concepts when they appear

## Style

Follow the **Google Developer Documentation Style Guide** as the primary reference,
with the **Microsoft Writing Style Guide** as secondary. When the two conflict, prefer
Google's guidance.

Key defaults:

- Active voice, present tense, second person ("you")
- Sentence case for headings
- Serial comma
- "Select" not "click"; "enter" not "type"
- Contractions are acceptable ("don't", "can't", "it's")
- No Latin abbreviations — use "for example" not "e.g.", "that is" not "i.e."
- No "please"

## Doc Types in This Repo

- **Tutorials** — learning-oriented, guided walkthroughs with a working end result
- **How-to guides** — task-based procedures with a clear, specific outcome
- **Reference docs** — CLI commands, config options, API parameters; designed to be scanned
- **Conceptual docs** — architecture overviews, explanations, mental models
- **Release notes** — changes per version, grouped by type
- **READMEs** — project and repository overviews

## Code and Commands

- Wrap all commands in fenced code blocks with a language identifier
- Use `shell` (not `bash`) unless the script targets bash specifically
- Use `yaml`, `json`, `hcl`, `dockerfile`, or `console` where appropriate
- Mark placeholder values with angle brackets: `<cluster-name>`, `<namespace>`
- Show expected output in a `console` block when it helps verify success
- Add a comment above commands that need context: `# Run from the repo root`
