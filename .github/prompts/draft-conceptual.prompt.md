---
description: "Draft a conceptual or overview doc explaining an architecture, system, or DevOps concept. Produces an explanation-focused page with mental models, trade-offs, and links to how-to guides. Use when the goal is understanding, not doing."
name: "Draft conceptual doc"
argument-hint: "Name the concept, system, or architecture to explain"
agent: "agent"
---

Draft a conceptual doc for a DevOps audience.
Use the structure in [doc-types.instructions.md](../instructions/doc-types.instructions.md) and the style rules in [devops-docs-style.instructions.md](../instructions/devops-docs-style.instructions.md).

**Concept**: $input

Produce a conceptual page with:

- A title that is a noun phrase: "Deployment strategies in Kubernetes", not "Understanding deployment strategies"
- An introduction that explains what the page covers and why it matters to a DevOps engineer
- A "What is [concept]" section with a clear, concise definition
- A "How [concept] works" section explaining the mechanics, components, and data flow in plain language
- A "When to use [concept]" section with use cases, trade-offs, and any relevant limitations
- Optional sub-sections for named components or variations, if the concept has distinct parts
- A "Related concepts" section with links to related conceptual docs
- A "Next steps" section pointing to relevant how-to guides

Don't include step-by-step procedures in this doc.
If procedural steps would be helpful, add `<!-- TODO: link to how-to guide for [task] -->` where the link should go.
