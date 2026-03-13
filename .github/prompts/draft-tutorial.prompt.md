---
description: "Draft a new tutorial for DevOps audiences. Produces a complete tutorial scaffold with introduction, prerequisites, numbered steps, verification, and cleanup sections. Use when creating a new learning-oriented walkthrough."
name: "Draft tutorial"
argument-hint: "Describe what the tutorial will teach or have the reader build"
agent: "agent"
---

Draft a complete tutorial for a DevOps audience.
Use the structure in [doc-types.instructions.md](../instructions/doc-types.instructions.md) and the style rules in [devops-docs-style.instructions.md](../instructions/devops-docs-style.instructions.md).

**Topic**: $input

Produce a full draft with:

- A title that names what the reader will build or achieve
- An introductory paragraph explaining what the reader will build and why it matters to a DevOps engineer
- A "Before you begin" section listing realistic prerequisites (tools installed, permissions needed, prior knowledge)
- At least three numbered steps, each in its own `## Step N: <Action>` section with an imperative heading
- At least one shell, YAML, or config code block with the correct language identifier and angle-bracket placeholders for values the reader must supply: `<cluster-name>`, `<namespace>`
- A "Verify the setup" section with steps to confirm everything is working
- A "Clean up" section with steps to remove resources (if the tutorial creates any)
- A "Next steps" section with two or three relevant follow-on topics

Label any section you're unsure about with `<!-- TODO: verify -->` so the writer knows where to review.
