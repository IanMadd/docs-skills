---
description: "Convert raw notes, a Jira ticket, a GitHub issue, a Slack thread, or meeting notes into a structured documentation draft for DevOps audiences. Identifies the right doc type and applies the appropriate structure."
name: "Convert notes to doc"
argument-hint: "Paste the raw notes, ticket, issue, or thread to convert"
agent: "agent"
---

Convert the following raw input into a structured technical documentation draft for a DevOps audience.
Use the style rules in [docs-style.instructions.md](../instructions/docs-style.instructions.md) and the appropriate doc type structure from [doc-types.instructions.md](../instructions/doc-types.instructions.md).

**Raw input**:

$input

Follow this process:

1. **Identify the doc type**: Based on the content, determine whether this should be a tutorial, how-to guide, reference doc, conceptual doc, release notes, or README.
   State your reasoning in one sentence before the draft.

2. **Extract key information**: Identify the task or concept, steps or details, commands or configs, and prerequisites.

3. **Draft the doc**: Apply the correct structure for the identified doc type.
   Fill gaps with sensible placeholders and mark them with `<!-- TODO: fill in -->` comments.

4. **Flag assumptions**: After the draft, add a `## Writer's notes` section listing anything you assumed, inferred, or could not determine from the raw input.
   These are items the writer should verify before publishing.

Capture all information from the raw input, even if it needs significant editing.
Don't discard details — mark unclear or incomplete items with `<!-- TODO: verify -->` rather than omitting them.
