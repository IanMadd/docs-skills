---
description: "Generate shell commands, YAML configs, CLI examples, Dockerfile snippets, Terraform HCL, JSON, or other code examples for DevOps documentation. Produces correctly formatted, annotated, copy-paste-ready examples."
name: "Generate code examples"
argument-hint: "Describe what the code example should do and which tool or language to use"
agent: "agent"
---

Generate code examples suitable for DevOps technical documentation.
Follow the code formatting standards in [devops-docs-style.instructions.md](../instructions/devops-docs-style.instructions.md).

**Request**: $input

For each example:

- Use the correct fenced code block language identifier:
  - `shell` — generic shell commands
  - `bash` — bash-specific scripts
  - `yaml` — YAML configuration
  - `json` — JSON
  - `hcl` — Terraform and HCL
  - `dockerfile` — Dockerfiles
  - `console` — expected terminal output (read-only)
- Use angle brackets for all values the reader must replace: `<cluster-name>`, `<namespace>`, `<image-tag>`
- Add a comment above the code block explaining what the example does (use the language's comment syntax)
- Show expected output in a separate `console` block when the output helps verify success
- Keep examples minimal: show only what is needed to illustrate the point
- If meaningful variations exist (for example, with and without a flag), show each as a separate example with a brief label

After the examples, add a short explanatory paragraph covering:
- What the code does
- Any important flags or options used
- Any prerequisites (tools installed, permissions required)
- Common errors and how to avoid them
