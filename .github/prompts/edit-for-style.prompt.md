---
description: "Edit a doc to comply with the team style guide. Fixes voice, tense, person, headings, code blocks, UI element formatting, link text, and DevOps terminology. Use when reviewing or polishing any documentation draft."
name: "Edit for style"
argument-hint: "Paste or attach the document to edit"
agent: "agent"
---

Edit the following documentation to comply with the team style guide defined in [docs-style.instructions.md](../instructions/docs-style.instructions.md).

**Document to edit**:

$input

Apply all of the following corrections:

1. **Voice**: Change passive voice to active voice where the subject of the action is known
2. **Person**: Change "users," "one," or "the user" to "you"
3. **Tense**: Change future tense ("will return") to present tense ("returns") when describing product behavior
4. **Language**:
   - "utilize" → "use"
   - "navigate to" → "go to"
   - "via" → "through," "with," or "using"
   - "e.g." → "for example"
   - "i.e." → "that is"
   - "please" → remove
   - "alongside" (meaning "together with") → "together with"
   - "click" / "click on" → "select"
5. **Contractions**: Add contractions where natural ("do not" → "don't", "cannot" → "can't")
6. **Headings**: Convert to sentence case; change -ing first words to bare infinitives for task-based headings
7. **Code blocks**: Add language identifiers to any fenced blocks that are missing them; wrap inline commands in backticks if they aren't
8. **UI elements**: Bold UI element names with `**name**`
9. **Links**: Replace non-descriptive link text ("click here", "here", "this page") with descriptive text
10. **DevOps terms**: Apply correct capitalization and spelling (Kubernetes not k8s, GitOps, IaC on second reference)

Return the fully edited document.
After the document, add a `## Changes made` section listing which categories of corrections were applied.
