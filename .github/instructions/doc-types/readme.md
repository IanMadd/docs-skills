---
description: "Structural template and guidelines for README doc type pages."
---

# README

**Purpose**: The first document a reader finds in a repository.
Answers: what is this, who is it for, why should I care, and how do I start?
Focus on why a reader would engage with the project, not just what it does.

```markdown
# <Project name>

One sentence describing what the project does and who it's for.

<!-- Optional: status badges for build, coverage, version, and license -->

## Project description

Expand on what the project does and why a reader should use it.
Use these patterns:

- "With <project>, you can <verb> <noun>..."
- "<Project> helps you <verb> <noun>..."
- "Unlike <alternative>, <project> <verb> <noun>..."

Include a screenshot or short video clip if it helps readers evaluate the project quickly.
If similar alternatives exist, list what makes this project different.

## Who is this for

Who can use this project, what problems it helps them solve, and what tasks it helps them accomplish.

## Prerequisites

List what the reader needs before they can use the project, and why each is needed.
Link to installation instructions for each.

- <Tool or library> <minimum version>: <Why it's needed>---[Install](<link>)

## Quick start

The minimum steps to get something working. Keep to five steps or fewer.

1. Step one.
1. Step two.

## Installation

```shell
# Install command
<command>
```

If there are platform-specific steps or multiple installation methods, use a subheading for each.

## Configuration

| Variable / Option | Default | Description |
|-------------------|---------|-------------|
| `VAR_NAME` | `""` | What it controls |

## Usage

```shell
# Description of what this does
command --flag <VALUE>
```

Show expected output when it helps readers verify success.
Link to more complete examples if they're too long to include here.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| <Error or symptom> | <How to fix it> |

## Contributing

Brief inline guide or link to `CONTRIBUTING.md`.
State whether you're open to contributions and what you require.
Include any commands needed to run tests or lint the code.

## How to get help

Where to ask questions, report bugs, or get support.
For example: link to issues, a Slack channel, a mailing list, or Stack Overflow.

## Roadmap (optional)

Planned improvements or future release ideas.
Use a bulleted list or link to a project board.

## Authors and acknowledgment (optional)

Recognize contributors and any third-party libraries or resources used in the project.

## Additional documentation (optional)

- [<Doc title>](<link>)---brief description

For large or complex projects, keep the README short and link to separate files.
Common breakouts: `CONTRIBUTING.md`, `INSTALL.md`, `CHANGELOG.md`, `SECURITY.md`, `docs/configuration.md`.

## License

License name and a link or brief statement.

## Project status (include if development has slowed or stopped)

Note if the project is no longer actively maintained, so others can decide whether to fork it or step in as maintainer.
```

**Guidelines**:
- Choose a self-explaining name for the project
- Lead with why, not just what---explain why a reader should care before describing technical details
- Include status badges near the top to signal project health at a glance; use [Shields.io](https://shields.io/) or your CI provider
- Include a screenshot or short video in the project description when it helps readers evaluate the project quickly
- List differentiating factors if similar alternatives exist
- Keep the README scannable: short paragraphs, code blocks for all commands, clear headings
- Put the quick start before the full installation steps so readers can evaluate the project before committing
- Show expected output after commands so readers can verify their results
- For contributing, document any commands needed to run tests or lint the code; make environment setup steps explicit for both external contributors and your future self
- Include a troubleshooting section for the most common errors new users encounter
- Don't duplicate information that lives in linked docs---link instead
- Split large READMEs into supplementary files and keep the main README as a short entry point with clear links
- Add a table of contents for READMEs with many sections so readers can scan and navigate quickly
- Revisit the README regularly as the project evolves
- If the project is no longer actively maintained, say so prominently at the top of the README
