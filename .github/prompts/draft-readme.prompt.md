---
description: "Draft a README for a DevOps tool, service, or repository. Produces a structured README with an overview, requirements, installation, quick start, configuration table, usage examples, and contributing section."
name: "Draft README"
argument-hint: "Describe the tool, service, or repo — include its purpose and tech stack"
agent: "agent"
---

Draft a README for a DevOps tool or repository.
Use the structure in [doc-types.instructions.md](../instructions/doc-types.instructions.md) and the style rules in [docs-style.instructions.md](../instructions/docs-style.instructions.md).

**Tool / repo description**: $input

Produce a complete README with:

- A project name heading and one sentence describing what it does and who it's for
- A `## Requirements` section listing runtime versions, tool dependencies, and system prerequisites
- An `## Installation` section with a working install command in a `shell` code block
- A `## Quick start` section: the minimum steps to get something working — five steps or fewer
- A `## Configuration` section with a table documenting key environment variables or config file options (columns: Variable/Option | Default | Description)
- A `## Usage` section with at least two practical command examples in fenced code blocks, each with a comment explaining what it does
- A `## Contributing` section — a brief inline guide or a link to `CONTRIBUTING.md`
- A `## License` section with the license name

Keep the README scannable: short paragraphs, code blocks for all commands, and clear headings.
Mark any assumptions with `<!-- TODO: verify -->`.
