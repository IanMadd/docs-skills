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
   docs from [doc-types/conceptual.md](../../instructions/doc-types/conceptual.md)
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
[doc-types/conceptual.md](../../instructions/doc-types/conceptual.md):

- `# <Title: noun phrase>` — name the doc after the concept itself where possible
  ("Deployment strategies in Kubernetes"); avoid bare titles like "Overview" or
  "Introduction" with no accompanying noun
- (Optional) An introductory paragraph framing the concept's relevance, using the
  inverted pyramid: high-level idea first, details later
- `## What is <concept>` — a clear, scoped definition; state what's in scope and, if
  useful, what's out of scope; explain how it fits into the broader system; favor
  direct definition patterns ("<Concept> is...", "<Concept> solves the challenge
  of...", "By using <concept>, you can...")
- (Optional) A diagram or visual, placed near the top if it clarifies architecture or
  data flow, and kept next to the text that explains it
- (Optional) `## Background` — historical or design context, only if it meaningfully
  aids understanding
- `## Use cases` — framed around the reader's problems: what challenges does this
  concept solve
- (Optional) `## Comparison` — a table of options/versions/alternatives and when to
  use each, if the concept has more than one variant
- `## Related resources` — subcategorized links: **How-to guides** (implements this
  concept), **Related concepts** (a related conceptual doc), **Reference** (config
  or options for this concept)

Guidelines to enforce:

- One conceptual doc covers exactly one concept — if a second concept needs
  explaining, link to a separate doc instead of expanding scope
- Don't include step-by-step procedures — replace them with
  `<!-- TODO: link to how-to guide for [task] -->`
- Use the inverted pyramid: high-level overview first, details later
- Explain trade-offs and limitations honestly — don't gloss over them
- Match the diagram type to what it needs to show: context diagram (how the concept
  fits a broader system), flowchart (a sequential process or how the concept
  evolved), decision tree (choices and consequences), or infographic (a high-level,
  visual overview)
- If the doc must serve both non-technical and technical readers, layer the content
  (simple explanation first, then progressive technical depth) rather than mixing
  depths inconsistently; split into separate docs if the audiences' needs diverge
  too far to layer well

---

## Stage 2: Map or draft content

### Restructure mode

1. Confirm the file covers exactly one concept. If it explains more than one unrelated
   concept, flag the extra content:
   `<!-- TODO: split into a separate conceptual doc for [concept] -->` rather than
   deleting it.
2. Rewrite the title as a noun phrase naming the concept itself ("Payments", not
   "Overview"); use a generic label like "Understanding <concept>" only if the
   concept name alone reads awkwardly as a title.
3. Extract or write a scoped definition for `What is <concept>`, stating what's in
   and out of scope, using direct definition patterns ("<Concept> is...", "<Concept>
   addresses the common pain points of...") rather than vague framing.
4. If the file references a diagram or describes an architecture/data flow visually,
   note its placement near the top, next to the text it explains; if no diagram
   exists but one would clarify the content, add
   `<!-- TODO: add a diagram showing [architecture/data flow] -->` and suggest the
   diagram type (context diagram, flowchart, decision tree, or infographic).
5. Move any historical or design-rationale content into `## Background`; drop this
   section if there's nothing that meaningfully aids understanding.
6. Reframe any existing use case content around reader problems in `## Use cases`.
7. If the concept has multiple types or alternatives, build a `## Comparison` table
   from existing content.
8. Replace any embedded step-by-step instructions with
   `<!-- TODO: link to how-to guide for [task] -->` — don't leave procedures inline.
9. Build `## Related resources` from any links already present in the file, grouped
   under **How-to guides**, **Related concepts**, and **Reference** subheadings.
10. If the file mixes a simple explanation with deep technical detail in no clear
    order, reorder it to layer the content — high-level first, technical depth
    after — instead of leaving the two interleaved.

### Create mode

1. Draft the title as a noun phrase naming the concept itself, applying the naming
   conventions above.
2. Draft an introductory paragraph from the source material, applying the inverted
   pyramid, if useful.
3. Draft `What is <concept>` as a scoped definition using the sources, favoring
   direct definition patterns; note in-scope/out-of-scope boundaries if the sources
   make them clear.
4. Add `<!-- TODO: add a diagram showing [architecture/data flow] -->` if the concept
   would benefit from one, and suggest which diagram type fits (context diagram,
   flowchart, decision tree, or infographic).
5. Draft `Background` only if the sources include historical or design context worth
   keeping.
6. Draft `Use cases` from problems the sources describe the concept as solving.
7. Draft `Comparison` only if the sources describe multiple variants or
   alternatives.
8. Build `Related resources` under **How-to guides**, **Related concepts**, and
   **Reference** subheadings; leave `<!-- TODO: link to related content -->` for any
   links not confirmed by the sources.
9. If the sources suggest both non-technical and technical readers, layer the draft
   (simple explanation first, technical depth after) rather than mixing depths.

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
- **Comments in examples**: apply [code-comments.instructions.md](../../instructions/code-comments.instructions.md)'s comment rules---move
  documentation-only narration to surrounding prose, keep customization/warning/intent comments
  inline, remove redundant comments

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
