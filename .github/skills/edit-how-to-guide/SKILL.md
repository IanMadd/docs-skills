---
name: edit-how-to-guide
description: 'Restructure an existing Markdown page, or draft a new one, to match the how-to guide doc type template, then apply the team style guide and lint it with markdownlint, Vale, and cspell. Works on a single target file; supports optional source links when drafting new content. Triggers on: edit as how-to guide, convert to how-to guide, make this a how-to guide, format as how-to, restructure how-to guide, how-to doc type, write a how-to guide from.'
argument-hint: "Path to the file to edit — for example: docs/how-to/deploy-a-container.md — optionally add source links when the file is new or empty: docs/how-to/deploy-a-container.md https://example.com/source-doc"
---

# Edit a page into a how-to guide

Runs a five-stage workflow to restructure or draft a page so it matches the how-to
guide doc type template and the team style guide.

0. **Determine mode** — reads the target file and classifies it as restructure mode
   (real content exists) or create mode (file is missing, empty, or placeholder-only)
1. **Apply the how-to guide template** — pulls the structural rules for how-to guides
   from [doc-types.instructions.md](../../instructions/doc-types.instructions.md)
2. **Map or draft content** — in restructure mode, moves and rewrites existing content
   into the template sections; in create mode, drafts new content, optionally using
   source links, and flags gaps with `<!-- TODO: -->` comments
3. **Apply the team style guide** — applies rules from
   [docs-style.instructions.md](../../instructions/docs-style.instructions.md)
4. **Lint with markdownlint, Vale, and cspell** — runs the same linters as the
   `docs-style-edit` skill and fixes every issue so the file passes all three
   before finishing

---

## Stage 0: Determine mode

Read the target file if it exists.

| Condition | Mode |
|-----------|------|
| File doesn't exist | Create mode |
| File exists but is empty or contains only a heading/placeholder text | Create mode |
| File has real prose, steps, or commands | Restructure mode |

Report which mode you'll run before continuing.

If you're in create mode and the user supplied source links, fetch or read each one
now (`fetch_webpage` for URLs, `read_file` for local paths) to use as source material
in Stage 2. If no sources were supplied, draft a skeleton with `<!-- TODO: -->`
markers for content you can't infer.

---

## Stage 1: Apply the how-to guide template

How-to guides are task-oriented: they help an experienced reader complete one
specific task or solve one specific problem. Unlike tutorials, they alert the reader
to unexpected scenarios rather than eliminating them, and they assume practical
knowledge.

The required structure, from
[doc-types.instructions.md](../../instructions/doc-types.instructions.md):

- `# <Title: bare infinitive>` — for example, "Deploy a container to Kubernetes"
- One or two sentences describing the task and when a reader would perform it
- `## Before you begin` — include only for non-obvious prerequisites; omit if the
  task has none worth calling out
- `## <Task name: bare infinitive>` — introductory sentence, then a numbered list of
  steps, each starting with an imperative verb; conditional steps use "If
  `<condition>`, do `<alternative step>`."
- `## Next steps` — include only when this guide is part of a larger workflow and
  leads directly into other procedures; omit for standalone tasks
- `## See also` — links to a related how-to guide, conceptual doc, or reference page

Guidelines to enforce:

- One how-to guide covers exactly one task — if the file covers more than one, flag
  the extra task(s) with
  `<!-- TODO: split into a separate how-to guide; this file should cover one task -->`
- Maximum 8–10 steps; if the task genuinely needs more, recommend splitting into
  multiple guides rather than padding one file
- Use conditional imperatives for variations instead of branching into separate
  procedures
- Don't explain concepts inline — replace concept explanations with
  `<!-- TODO: link to conceptual doc explaining [concept] -->`
- Document only the most common or recommended method; note alternatives as links,
  not full alternate procedures
- Flag unexpected scenarios with `{{< note >}}` or `{{< warning >}}` shortcodes

---

## Stage 2: Map or draft content

### Restructure mode

1. Confirm the file covers exactly one task. If it covers more, split out the
   additional task(s) into `<!-- TODO: move to a separate how-to guide -->` blocks
   rather than deleting the content.
2. Rewrite the title as a bare infinitive naming the task.
3. Extract only non-obvious prerequisites into `Before you begin`; drop a generic
   "Before you begin" section if every prerequisite is already obvious from the
   title.
4. Reorganize existing steps into the numbered task list. Preserve all working
   commands and real examples — don't invent new ones.
5. Convert any embedded concept explanations into `{{< note >}}` shortcodes or a
   `<!-- TODO: link to conceptual doc -->` marker instead of leaving long explanatory
   asides inside the steps.
6. Convert any "if this doesn't work" or edge-case text into conditional imperative
   steps or `{{< warning >}}` shortcodes.
7. If more than 8–10 steps remain after consolidation, flag the file:
   `<!-- TODO: exceeds recommended step count; consider splitting into multiple guides -->`
8. Add `Next steps` only if the existing content implies a larger workflow; otherwise
   omit it. Add `See also` with any related links already present in the content.

### Create mode

1. Draft the title as a bare infinitive and the one- or two-sentence task
   description from the source material.
2. Draft `Before you begin` only if the sources mention non-obvious prerequisites.
3. Draft the numbered steps from the source material's procedure. Use conditional
   imperatives for variations described in the sources.
4. Don't invent commands, flags, or outcomes not present in the source material —
   leave `<!-- TODO: no source material found for this step -->` instead.
5. Add `See also` links only for sources you were actually given; otherwise leave
   `<!-- TODO: link to related content -->`.

---

## Stage 3: Apply the team style guide

Apply [docs-style.instructions.md](../../instructions/docs-style.instructions.md).
Focus on these checks:

- **Procedures**: imperative verbs to start every step, conditional-imperative
  phrasing for variations, results kept in the same paragraph as the action
- **Voice and tense**: active voice, "you" instead of "the user," present tense
- **Headings**: sentence case, bare infinitive for the title and task heading
- **UI elements**: bold UI element names, correct terminology (select/enter/choose)
- **Language**: serial comma, contractions, no Latin abbreviations

---

## Stage 4: Lint with markdownlint, Vale, and cspell

Confirm the file passes all three linters the `docs-style-edit` skill uses before
finishing:

1. **markdownlint-cli2**: Run `markdownlint-cli2 --fix <file>` to auto-correct
   formatting issues, then run `markdownlint-cli2 <file>` again to confirm none
   remain. Manually fix anything that can't be auto-fixed. See
   [markdownlint-setup.md](../docs-style-edit/references/markdownlint-setup.md) for
   installation and common rules.
2. **Vale**: Lint with the Vale MCP tool (or `vale --minAlertLevel=error <file>` as a
   CLI fallback) and fix every error. See
   [vale-fix-guide.md](../docs-style-edit/references/vale-fix-guide.md) for guidance
   on interpreting common rules and
   [vale-setup.md](../docs-style-edit/references/vale-setup.md) for MCP/CLI setup.
3. **cspell**: Run `cspell lint <file>`. Fix genuine misspellings; add valid
   technical terms to the project's word list (`cspell.json` or similar at the repo
   root) instead of changing them.

Re-run all three linters after making fixes to confirm each reports zero errors.

---

## Report

Summarize:

- Which mode ran (restructure or create)
- Section-by-section changes made
- Every `<!-- TODO: -->` left in the file and why
- Confirmation that markdownlint, Vale, and cspell all pass with zero errors
