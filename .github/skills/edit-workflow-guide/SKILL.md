---
name: edit-workflow-guide
description: 'Restructure an existing Markdown page, or draft a new one, to match the workflow guide doc type template, then apply the team style guide and lint it with markdownlint, Vale, and cspell. A workflow guide is a how-to guide subtype that connects two or more products into one cross-product outcome instead of documenting a single product task. Works on a single target file; supports optional source links, or a research doc produced by generate-research-doc, when drafting new content. Triggers on: edit as workflow guide, convert to workflow guide, make this a workflow guide, format as workflow guide, cross-product guide, connect product docs, narrative workflow, orchestration guide, solution guide, workflow doc type, workflow guide from research doc.'
argument-hint: "Path to the file to edit — for example: docs/workflows/audit-and-remediate-compliance.md — optionally add a research doc and/or source links: docs/workflows/audit-and-remediate-compliance.md research/compliance-remediation.md https://example.com/product-a-docs"
---

# Edit a page into a workflow guide

Runs a five-stage workflow to restructure or draft a page so it matches the workflow
guide doc type template and the team style guide.

0. **Determine mode** — reads the target file and classifies it as restructure mode
   (real content exists) or create mode (file is missing, empty, or placeholder-only)
1. **Apply the workflow guide template** — pulls the structural rules for workflow
   guides from [doc-types/workflow-guide.md](../../instructions/doc-types/workflow-guide.md)
2. **Map or draft content** — in restructure mode, moves and rewrites existing content
   into the template sections, replacing embedded product implementation detail with
   links; in create mode, drafts new content, optionally using source links, and
   flags gaps with `<!-- TODO: -->` comments
3. **Apply the team style guide** — applies rules from
   [docs-style.instructions.md](../../instructions/docs-style.instructions.md)
4. **Lint with markdownlint, Vale, and cspell** — runs the same linters as the
   `docs-style-edit` skill and fixes every issue so the file passes all three
   before finishing

---

## Recommended input: pair with generate-research-doc

A workflow guide's whole value is the cross-product narrative, so it benefits from
broader source material than a single product page. When the user hasn't already
supplied sources, suggest running
[generate-research-doc](../generate-research-doc/SKILL.md) first: gather existing
documentation, blog posts, Confluence pages, Jira epics, or repos for every product
involved in the workflow, and compile them into a research report at
`research/<topic-slug>.md`. Then pass that report's path as a source argument to this
skill.

A research doc is a stronger source than a plain link list because it's already
synthesized across products and every claim carries an inline citation back to its
original source — use those citations as the per-step product links in Stage 2 instead
of inventing new ones.

---

## Stage 0: Determine mode

Read the target file if it exists.

| Condition | Mode |
|-----------|------|
| File doesn't exist | Create mode |
| File exists but is empty or contains only a heading/placeholder text | Create mode |
| File has real prose, steps, or commands | Restructure mode |

Report which mode you'll run before continuing.

If you're in create mode, read every source argument now:

- **Research doc** — a local Markdown file (typically under `research/`, produced by
  `generate-research-doc`): read it with `read_file`. Treat its themes as the
  candidate product sections for the `Workflow` list and its inline citations as the
  per-step links back to each product's own documentation
- **Other local paths** — read with `read_file`
- **URLs** — fetch with `fetch_webpage`

If no sources were supplied, ask whether the user wants to run
[generate-research-doc](../generate-research-doc/SKILL.md) first, or confirm they want
a skeleton with `<!-- TODO: -->` markers for content you can't infer.

---

## Stage 1: Apply the workflow guide template

A workflow guide is a how-to guide subtype: an outcome that spans two or more
independently versioned products or documentation sets. It doesn't replace product
documentation---it connects existing tutorials, how-to guides, reference docs, and
conceptual docs into one coherent end-to-end process.

The required structure, from
[doc-types/workflow-guide.md](../../instructions/doc-types/workflow-guide.md):

- `# <Title: outcome-oriented bare infinitive>` — for example, "Audit and remediate
  infrastructure compliance"
- Opening paragraph: "This guide explains how to <outcome>," naming every product
  involved, followed by one or two sentences on the overall goal
- `## Before you begin` — links to setup or prerequisite docs for each product, plus
  any version/edition requirements
- `## Workflow` — introductory paragraph on the artifact flow between products, then
  a numbered list of steps; each step that belongs to a specific product links to
  that product's own documentation instead of documenting the step
- `## Expected outcome` — what the reader should observe when the workflow succeeds
  end-to-end
- `## Next steps` — link to a related workflow guide or the conceptual doc explaining
  how the involved products fit together
- `## See also` — links to each product's reference documentation used in the workflow

Guidelines to enforce:

- The guide must span two or more products; if it stays inside one product, flag it
  with `<!-- TODO: this is a single-product task; consider a standard how-to guide instead -->`
- Name every involved product in the title or opening paragraph
- Replace embedded implementation detail with a link to the owning product's
  authoritative doc; where no source link exists, add
  `<!-- TODO: link to [product] documentation for [step] -->`
- Don't reproduce API, CLI, or resource reference content---link to it instead
- Don't embed complete code examples, cookbook recipes, or InSpec profiles; reduce
  any inline example to a short, generic, version-neutral illustration, or remove it
  and link out
- Minimize version-specific detail; link to the product's own docs for version-specific syntax
- Use conditional imperatives for decision points, matching how-to guide step structure
- End with an expected-outcome statement confirming the whole cross-product flow succeeded

---

## Stage 2: Map or draft content

### Restructure mode

1. Confirm the guide spans two or more products. If it doesn't, flag it:
   `<!-- TODO: this is a single-product task; consider a standard how-to guide instead -->`
2. Rewrite the title as an outcome-oriented bare infinitive.
3. Rewrite the opening paragraph as "This guide explains how to <outcome>," naming
   every product involved, followed by one or two sentences on the overall goal.
4. Extract setup or prerequisite links for each product into `Before you begin`.
5. For each step in the existing content, identify which product owns it:
   - If the step documents that product's implementation (commands, API calls,
     configuration, resource syntax), replace the implementation detail with a link
     to that product's own doc and a one-sentence description of the step's purpose.
     Where no source link was given, add
     `<!-- TODO: link to [product] documentation for [step] -->` instead of deleting
     the step.
   - If the step is a decision point, rewrite it as a conditional imperative
     ("If `<condition>`, do `<alternative step>`; otherwise, continue.").
6. Strip embedded code blocks, cookbook recipes, or InSpec profiles down to a short,
   generic, version-neutral illustration, or remove them and add a link to the
   owning product's documentation instead.
7. Add the artifact-flow narrative paragraph before the numbered steps if the
   content doesn't already explain what moves between products and in what order.
8. Add or rewrite `Expected outcome` so it describes the end-to-end result, not just
   one product's output.
9. Add `Next steps` only if the content implies a related workflow; otherwise omit
   it. Add `See also` with any product reference links already present in the content.

### Create mode

1. Draft the title as an outcome-oriented bare infinitive and an opening paragraph
   in the form "This guide explains how to <outcome>," naming every product
   involved, drawn from the source material.
2. Draft `Before you begin` only if the sources mention setup or version
   requirements for the involved products.
3. Draft the `Workflow` narrative paragraph and numbered steps from the source
   material, linking each product-specific step to its source link instead of
   documenting the implementation.
   - When the source is a research doc, use its per-topic sections to identify each
     product involved and reuse its inline citation targets as the step links,
     instead of re-deriving links from scratch.
4. Don't invent commands, flags, or outcomes not present in the source material —
   leave `<!-- TODO: no source material found for this step -->` instead.
5. Draft `Expected outcome` only from what the sources confirm; otherwise leave
   `<!-- TODO: confirm expected outcome -->`.
6. Add `See also` links only for sources you were actually given; otherwise leave
   `<!-- TODO: link to related product reference docs -->`.

---

## Stage 3: Apply the team style guide

Apply [docs-style.instructions.md](../../instructions/docs-style.instructions.md).
Focus on these checks:

- **Procedures**: imperative verbs to start every step, conditional-imperative
  phrasing for decision points, results kept in the same paragraph as the action
- **Voice and tense**: active voice, "you" instead of "the user," present tense
- **Headings**: sentence case, outcome-oriented bare infinitive for the title
- **Language**: serial comma, contractions, no Latin abbreviations
- **Links**: every cross-product link is descriptive and names the product it
  points to, so the reader knows they're leaving this guide for another doc set

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
- Section-by-section changes made, including which embedded implementation detail
  was replaced with links to which products
- Every `<!-- TODO: -->` left in the file and why, especially missing product-doc links
- Confirmation that markdownlint, Vale, and cspell all pass with zero errors
