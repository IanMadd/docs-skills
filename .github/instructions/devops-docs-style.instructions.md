---
description: "Style and formatting rules for DevOps technical documentation. Use when writing or editing any Markdown file, documentation page, guide, or reference content for DevOps audiences."
applyTo: "**/*.md"
---

# DevOps Docs Style Rules

Follow the Google Developer Documentation Style Guide primarily, then the Microsoft Writing Style Guide.
The rules below supplement those guides for this team's specific needs.

## Voice and person

- Write in second person: address the reader as "you"
- Use active voice for all instructions
- Use "you can" rather than "users can" or "one can"
- Passive voice is acceptable when the subject performing the action doesn't matter

## Tense

- Use present tense for facts and product behavior: "The command returns a JSON object"
- Use future tense only when describing something that occurs asynchronously or in the future
- Never use "will" to describe current product behavior or the effect of a step

## Language

- Plain US English; assume a global, non-native English audience
- Use contractions: "don't", "can't", "it's"
- Serial comma in all lists
- No Latin abbreviations: write "for example" not "e.g.", "that is" not "i.e."
- No "please"
- Use "select" not "click" or "click on"
- Use "enter" for text input; "run" or "execute" for commands
- Use "go to" not "navigate to"
- Use "use" not "utilize"
- Use "through," "with," or "using" instead of "via"
- Don't use "alongside" as a synonym for "together with"

## Headings

- Sentence case only: "Configure the deployment pipeline" not "Configure the Deployment Pipeline"
- Task-based headings use a bare infinitive: "Create a namespace" not "Creating a namespace"
- Conceptual headings use a noun phrase: "Cluster architecture" not "Understanding cluster architecture"
- No punctuation in headings except question marks where appropriate
- Don't skip heading levels (h1 → h2 → h3, never h1 → h3)

## Procedures

- Numbered lists for sequential steps; one action per step
- Bulleted list (single item) for single-step procedures — not a numbered list
- Start each step with an imperative verb
- State the location before the action: "In the **Settings** panel, select **Save**"
- State the goal before the action: "To apply the configuration, run:"
- Keep the result of a step in the same paragraph as the action
- Introduce optional steps with "Optional:"

## Code blocks

- Always use fenced code blocks with a language identifier
- `shell` — generic shell commands
- `bash` — only when the script explicitly targets bash
- `yaml` — YAML files and configuration
- `json` — JSON
- `hcl` — Terraform and other HCL
- `dockerfile` — Dockerfiles
- `console` — terminal output (read-only; not commands the reader runs)
- Use angle brackets for all placeholder values: `kubectl get pods -n <namespace>`
- Show expected output in a `console` block when it helps verify success
- Add a comment above commands that need context: `# Run from the repo root`

## DevOps terminology

- "container" not "Docker container" unless Docker-specific
- "image" not "Docker image" unless Docker-specific
- "cluster" for a Kubernetes cluster; "node" for a cluster node
- "Pod" (capital P) when referring to the Kubernetes object; "pod" in general use
- "pipeline" not "CI/CD pipeline" unless distinguishing from another type of pipeline
- "environment variable" in body text; "env var" is acceptable in code comments
- Spell out "Continuous Integration" and "Continuous Delivery/Deployment" on first use; "CI/CD" thereafter
- "GitOps" (camelCase)
- "infrastructure as code" (lowercase); abbreviate as "IaC" after first use
- "service mesh" (lowercase)
- Use official product names in body text: "Kubernetes" not "k8s", "GitHub Actions" not "GHA"

## UI elements

- Bold UI element names with `**name**`
- "Select **OK**" — don't say "click the OK button"
- "In the **Name** field" — use "field" not "box"
- "The **Create deployment** dialog" — use "dialog" not "pop-up"

## Links

- Use descriptive link text that explains the destination
- Never use "click here," "here," or "this page" as link text
- Use inline Markdown links: `[Kubernetes documentation](https://kubernetes.io/docs)`

## Notes and warnings

Use these admonition formats consistently:

```markdown
> **Note:** Information that helps but isn't critical.

> **Important:** Information the reader must not miss.

> **Warning:** Potential data loss or irreversible consequences.

> **Tip:** A shortcut, best practice, or efficiency improvement.
```
