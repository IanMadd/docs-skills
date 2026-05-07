---
description: "Draft a reference doc for a CLI command, config file, API endpoint, or set of options. Produces a scannable page with syntax, a flags/parameters table with types and defaults, and runnable examples."
name: "Draft reference doc"
argument-hint: "Name the command, API, or config option set to document"
agent: "agent"
---

Draft a reference doc for a DevOps audience.
Use the structure in [doc-types.instructions.md](../instructions/doc-types.instructions.md) and the style rules in [docs-style.instructions.md](../instructions/docs-style.instructions.md).

**Subject**: $input

Produce a complete reference page with:

- A title that is a noun phrase naming the command, option set, or API: "kubectl rollout options", "deploy.yaml configuration reference"
- One sentence describing what this reference covers
- A `## Syntax` section showing the command or call signature
- A `## Description` section explaining what the subject does
- An `## Options` or `## Parameters` table with these columns: Flag/Parameter | Type | Default | Description
  - Every option must include a type and a default value
  - If a value is required with no default, write `required` in the Default column
- At least two `## Examples` entries, each with a fenced code block (correct language identifier) and a comment explaining what the example does
- A `## Related` section with links to relevant how-to guides or other reference pages

Mark any options with unknown defaults as `<!-- TODO: confirm default value -->`.
