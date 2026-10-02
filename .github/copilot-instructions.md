# Editorial style guide rules

This repository contains documentation written for DevOps engineers: professionals
who design, build, operate, and maintain CI/CD pipelines, infrastructure, containers,
configuration management systems, monitoring stacks, and cloud environments.

When contributing to Markdown documentation, follow these style guidelines in order of precedence:

1. **Chef-specific style** ([docs-style.instructions.md](instructions/docs-style.instructions.md))
2. **Google Developer Documentation Style Guide** principles
3. **Third-party references** (Merriam-Webster, Chicago Manual of Style, Microsoft Writing Style Guide)

## Audience

- **Primary**: DevOps engineers, platform engineers, SREs
- **Assumes**: Familiarity with Linux, shell scripting, Git, containers, and cloud platforms
- **Does not assume**: Knowledge of a specific vendor's tooling; explain tool-specific concepts when they appear

## Style guide

Detailed voice, language, procedure, heading, and UI-element rules live in
[instructions/docs-style.instructions.md](instructions/docs-style.instructions.md) and apply
automatically to every Markdown file. Don't duplicate those rules here---update that file
instead so there's a single source of truth.

## Doc types in this repo

- **Tutorials** — learning-oriented, guided walkthroughs with a working end result
- **How-to guides** — task-based procedures with a clear, specific outcome
- **Workflow guides** — cross-product outcomes that connect existing product documentation instead of duplicating it
- **Reference docs** — CLI commands, config options, API parameters; designed to be scanned
- **Conceptual docs** — architecture overviews, explanations, mental models
- **Product overview** — high-level product value and capabilities; often an entry point for evaluators
- **Release notes** — changes per version, grouped by type
- **READMEs** — project and repository overviews

See [instructions/doc-types.instructions.md](instructions/doc-types.instructions.md) for the
full structural template for each doc type.
