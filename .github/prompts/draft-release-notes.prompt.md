---
description: "Draft release notes from a PR list, commit log, Jira board, or change summary. Produces structured release notes with sections for breaking changes, new features, improvements, bug fixes, and upgrade notes."
name: "Draft release notes"
argument-hint: "Paste the PR list, commit log, or summary of changes for this release"
agent: "agent"
---

Draft release notes for a DevOps tool or platform.
Use the structure in [doc-types.instructions.md](../instructions/doc-types.instructions.md) and the style rules in [docs-style.instructions.md](../instructions/docs-style.instructions.md).

**Input — PR list, commit log, or change summary**:

$input

Produce structured release notes with:

- A title: `# Release notes — v<version> (<date>)` — use placeholders if version and date aren't provided
- An opening sentence summarizing the most significant change in this release
- Sections in this order: Breaking changes, What's new, Improvements, Bug fixes, Upgrade notes, Known issues
  - Omit any section that has no entries
  - Breaking changes must appear first if present, with a `> **Warning:**` admonition
- Each entry formatted as: `- **Short label**: One or two sentences describing the change and its impact`
- PR or issue numbers linked inline where provided: `([#123](link))`
- A `## Upgrade notes` section with numbered steps if any action is required to upgrade

Use past tense in entries: "Added support for...", "Fixed an issue where...", "Removed the deprecated..."
