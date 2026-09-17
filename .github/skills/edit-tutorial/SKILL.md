---
name: edit-tutorial
description: 'Restructure an existing Markdown page, or draft a new one, to match the tutorial doc type template, then apply the team style guide and lint it with markdownlint, Vale, and cspell. Works on a single target file; supports optional source links when drafting new content. Triggers on: edit as tutorial, convert to tutorial, make this a tutorial, format as tutorial, restructure tutorial, tutorial doc type, write a tutorial from.'
argument-hint: "Path to the file to edit — for example: docs/tutorials/deploy-first-app.md — optionally add source links when the file is new or empty: docs/tutorials/deploy-first-app.md https://example.com/source-doc"
---

# Edit a page into a tutorial

Runs a five-stage workflow to restructure or draft a page so it matches the tutorial
doc type template and the team style guide.

0. **Determine mode** — reads the target file and classifies it as restructure mode
   (real content exists) or create mode (file is missing, empty, or placeholder-only)
1. **Apply the tutorial template** — pulls the structural rules for tutorials from
   [doc-types.instructions.md](../../instructions/doc-types.instructions.md)
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

If you're in create mode and the user supplied source links (URLs or workspace file
paths), fetch or read each one now (`fetch_webpage` for URLs, `read_file` for local
paths) to use as source material in Stage 2. If no sources were supplied, tell the user
you'll draft a skeleton with `<!-- TODO: -->` markers for content you can't infer from
the file name or any context already in the conversation.

---

## Stage 1: Apply the tutorial template

Tutorials are learning-oriented: the reader follows a guided path and ends with a
working result and new skills. Tutorials eliminate unexpected scenarios rather than
alerting the reader to them — that's the job of a how-to guide.

The required structure, from
[doc-types.instructions.md](../../instructions/doc-types.instructions.md):

- `# <Title>` — what the reader will build or achieve, followed by one paragraph on
  what they'll build and why it matters
- `## Overview` with `### Learning objectives` (bulleted, "By the end of this
  tutorial, you'll be able to: ...") and `### Intended audience`
- `## Background` (optional) — brief context only; link to conceptual docs for
  depth
- `## Before you begin` — prerequisites as a bulleted list
- `## Step 1: <Bare infinitive action>` through `## Step N: <Action>` — each step
  starts with an introductory sentence, then a numbered list of substeps, each
  starting with an imperative verb; code blocks include comments; each step states
  the expected result
- `## Summary` — recap what the reader actually built or configured, not a repeat of
  the learning objectives
- `## Clean up` — include only if the tutorial creates persistent or billable
  resources
- `## Next steps` — links to a related how-to guide and a related conceptual doc or
  advanced tutorial

Guidelines to enforce:

- Target 15–60 minutes to complete
- Maximum 7 primary steps; maximum 4 substeps per step — if the existing content has
  more, consolidate or flag with `<!-- TODO: split into a second tutorial; exceeds 7 steps -->`
- Each step must build on the previous one; reorder steps if they jump ahead
- Show expected output after commands
- Use real, working examples, not placeholder logic
- Add a comment to every code sample explaining what it does

---

## Stage 2: Map or draft content

### Restructure mode

Work through the existing file section by section:

1. Identify the reader's end goal from the existing content and rewrite the title as
   a statement of what they'll build or achieve.
2. Extract or infer learning objectives and intended audience; if absent, draft them
   from the existing steps and flag with `<!-- TODO: confirm learning objectives -->`.
3. Convert any prerequisite mentions into the `Before you begin` list.
4. Reorganize the existing steps into `Step N: <Bare infinitive>` sections. Preserve
   all working commands and real examples as-is — don't invent new commands. Split
   steps that combine unrelated actions; merge steps that are too granular.
5. If a step exceeds 4 substeps, split it into two steps.
6. If the tutorial creates persistent or billable resources (cloud instances,
   databases, DNS records, and so on) and no `Clean up` section exists, add one and
   flag it: `<!-- TODO: add clean-up steps for resources created in Step N -->`.
7. Write or rewrite `Summary` and `Next steps` based on what the steps actually do.
8. Flag any content that doesn't fit the tutorial structure (conceptual asides,
   reference tables) with `<!-- TODO: consider moving to a conceptual doc or reference doc -->`
   rather than deleting it.

### Create mode

1. Draft the title, introductory paragraph, learning objectives, and intended
   audience using the fetched source material.
2. Draft `Before you begin` from any prerequisites mentioned in the sources.
3. Draft steps from the source material's procedures. If sources don't cover a full
   working procedure, draft as many steps as the sources support and mark the rest:
   `<!-- TODO: no source material found for this step; add real, tested commands -->`.
4. Don't invent commands or flags that don't appear in the source material — leave a
   TODO instead of guessing.
5. Draft `Summary` and `Next steps`; leave `Next steps` links as
   `<!-- TODO: link to related how-to guide/conceptual doc -->` if no related docs are
   known.

---

## Stage 3: Apply the team style guide

Apply [docs-style.instructions.md](../../instructions/docs-style.instructions.md).
Focus on these checks, since tutorials are heavy on procedures:

- **Procedures**: introductory sentence for each step section, imperative verbs to
  start every step, parallel structure across substeps
- **Voice and tense**: active voice, "you" instead of "the user," present tense for
  general behavior
- **Headings**: sentence case, bare infinitive for the title and step headings
- **UI elements**: bold UI element names, correct terminology (select/enter/choose,
  not click/utilize)
- **Language**: serial comma, contractions, no Latin abbreviations, "select" instead
  of "click"

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
