---
description: "Draft a how-to guide for a specific DevOps task. Produces a task-based doc with prerequisites, numbered steps, and expected result. Use when the reader knows the context and needs the steps."
name: "Draft how-to guide"
argument-hint: "Describe the task — for example: set up a Kubernetes namespace with RBAC"
agent: "agent"
---

Draft a how-to guide for a DevOps audience.
Use the structure in [doc-types.instructions.md](../instructions/doc-types.instructions.md) and the style rules in [devops-docs-style.instructions.md](../instructions/devops-docs-style.instructions.md).

**Task**: $input

Produce a focused, task-based guide with:

- A title that starts with a bare infinitive verb: "Configure...", "Deploy...", "Set up..."
- One or two sentences contextualizing when and why a reader would perform this task
- A "Before you begin" section only if there are non-obvious prerequisites
- Numbered steps, one action per step, each starting with an imperative verb
- At least one code block showing an actual command or config, with the correct language identifier
- The expected output or result after steps where it helps verify success
- No conceptual explanations — if background is needed, add a `<!-- TODO: link to conceptual doc -->` comment

Keep the guide under ten steps.
If the task requires more, add a `<!-- TODO: consider splitting into multiple guides -->` comment at the point where it should be divided.
