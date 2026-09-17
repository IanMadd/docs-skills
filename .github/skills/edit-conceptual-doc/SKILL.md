---
name: edit-conceptual-doc
description: 'Restructure an existing Markdown page, or draft a new one, to match the conceptual doc type template, then apply the team style guide and lint it with markdownlint, Vale, and cspell. Works on a single target file; supports optional source links when drafting new content. Triggers on: edit as conceptual doc, convert to conceptual doc, make this a conceptual doc, format as conceptual, restructure conceptual doc, concept doc type, write a conceptual doc from.'
argument-hint: "Path to the file to edit — for example: docs/concepts/deployment-strategies.md — optionally add source links when the file is new or empty: docs/concepts/deployment-strategies.md https://example.com/source-doc"
---

# Edit a page into a conceptual doc

Runs a five-stage workflow to restructure or draft a page so it matches the
conceptual doc type template and the team style guide.

0. **Determine mode** — reads the target file and classifies it as restructure mode
   (real content exists) or create mode (file is missing, empty, or placeholder-only)
1. **Apply the conceptual doc template** — pulls the structural rules for conceptual
   docs from [doc-types.instructions.md](../../instructions/doc-types.instructions.md)
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
| File has real explanatory prose | Restructure mode |

Report which mode you'll run before continuing.

If you're in create mode and the user supplied source links, fetch or read each one
now (`fetch_webpage` for URLs, `read_file` for local paths) to use as source material
in Stage 2. If no sources were supplied, draft a skeleton with `<!-- TODO: -->`
markers for content you can't infer.

---

## Stage 1: Apply the conceptual doc template

Conceptual docs help readers understand a concept, architecture, or system. They
build a mental model rather than teaching by doing (that's a tutorial) or walking
through a task (that's a how-to guide).

The required structure, from
[doc-types.instructions.md](../../instructions/doc-types.instructions.md):

- `# <Title: noun phrase>` — for example, "Deployment strategies in Kubernetes"
- (Optional) An introductory paragraph framing the concept's relevance, using the
  inverted pyramid: high-level idea first, details later
- `## What is <concept>` — a clear, scoped definition; state what's in scope and, if
  useful, what's out of scope; explain how it fits into the broader system
- (Optional) A diagram or visual, placed near the top if it clarifies architecture or
  data flow
- (Optional) `## Background` — historical or design context, only if it meaningfully
  aids understanding
- `## Use cases` — framed around the reader's problems: what challenges does this
  concept solve
- (Optional) `## Comparison` — a table of options/versions/alternatives and when to
  use each, if the concept has more than one variant
- `## Related resources` — links to a related conceptual doc, a how-to guide that
  implements this concept, and a reference doc for its configuration options

Guidelines to enforce:

- One conceptual doc covers exactly one concept — if a second concept needs
  explaining, link to a separate doc instead of expanding scope
- Don't include step-by-step procedures — replace them with
  `<!-- TODO: link to how-to guide for [task] -->`
- Use the inverted pyramid: high-level overview first, details later
- Include a diagram whenever it clarifies structure, data flow, or relationships
- Explain trade-offs and limitations honestly — don't gloss over them

---

## Stage 2: Map or draft content

### Restructure mode

1. Confirm the file covers exactly one concept. If it explains more than one unrelated
   concept, flag the extra content:
   `<!-- TODO: split into a separate conceptual doc for [concept] -->` rather than
   deleting it.
2. Rewrite the title as a noun phrase naming the concept.
3. Extract or write a scoped definition for `What is <concept>`, stating what's in
   and out of scope.
4. If the file references a diagram or describes an architecture/data flow visually,
   note its placement near the top; if no diagram exists but one would clarify the
   content, add `<!-- TODO: add a diagram showing [architecture/data flow] -->`.
5. Move any historical or design-rationale content into `## Background`; drop this
   section if there's nothing that meaningfully aids understanding.
6. Reframe any existing use case content around reader problems in `## Use cases`.
7. If the concept has multiple types or alternatives, build a `## Comparison` table
   from existing content.
8. Replace any embedded step-by-step instructions with
   `<!-- TODO: link to how-to guide for [task] -->` — don't leave procedures inline.
9. Build `## Related resources` from any links already present in the file.

### Create mode

1. Draft the title and, if useful, an introductory paragraph from the source
   material, applying the inverted pyramid.
2. Draft `What is <concept>` as a scoped definition using the sources; note
   in-scope/out-of-scope boundaries if the sources make them clear.
3. Add `<!-- TODO: add a diagram showing [architecture/data flow] -->` if the concept
   would benefit from one.
4. Draft `Background` only if the sources include historical or design context worth
   keeping.
5. Draft `Use cases` from problems the sources describe the concept as solving.
6. Draft `Comparison` only if the sources describe multiple variants or
   alternatives.
7. Leave `Related resources` as `<!-- TODO: link to related content -->` for any
   links not confirmed by the sources.

---

## Stage 3: Apply the team style guide

Apply [docs-style.instructions.md](../../instructions/docs-style.instructions.md).
Focus on these checks:

- **Voice and tense**: active voice, present tense for general behavior
- **Headings**: sentence case, noun phrases (not -ing verb forms) for the title and
  major headings
- **Language**: serial comma, contractions, no Latin abbreviations, plain language
  for global readability
- **Accessibility**: clear headings describing the content that follows, alt text
  for any images/diagrams

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
