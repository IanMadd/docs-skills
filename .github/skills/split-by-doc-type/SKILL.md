---
name: split-by-doc-type
description: 'Read a Markdown page that mixes conceptual, reference, and how-to content, and split it into separate pages that each match their doc type template, then apply the team style guide and lint each page with markdownlint, Vale, and cspell. Works on a single source file and writes one new file per detected doc type; the source file is left unchanged. Triggers on: split by doc type, split into doc types, separate concept reference how-to, break up mixed doc, split mixed content, extract how-to from concept, split this page by content type.'
argument-hint: "Path to the source file, optionally followed by output paths in how-to, reference, concept order — for example: docs/mixed-page.md docs/deploy-a-container.md docs/deployment-options-reference.md docs/deployment-strategies.md — omit the output paths to use default same-directory, type-suffixed filenames"
---

# Split a page by doc type

Runs a six-stage workflow to analyze a mixed-content page, split it into one page per
detected doc type (conceptual, reference, how-to), restructure each to match its doc
type template, apply the team style guide, and lint every generated file.

0. **Analyze the source** — reads the target file and classifies its sections against
   conceptual, reference, and how-to signatures, building a content map before writing
   anything
1. **Resolve output targets** — matches user-supplied output paths to detected types,
   or derives default filenames next to the source file
2. **Draft each output page** — pulls the matching template from
   [doc-types.instructions.md](../../instructions/doc-types.instructions.md) and
   populates it with the mapped content, flagging gaps and mixed content with
   `<!-- TODO: -->` comments
3. **Apply the team style guide** — applies rules from
   [docs-style.instructions.md](../../instructions/docs-style.instructions.md) to
   every generated page
4. **Lint with markdownlint, Vale, and cspell** — runs the same linters as the
   `docs-style-edit` skill on each generated file and fixes every issue
5. **Cross-link the generated pages** — adds "Related resources" or "See also" links
   between the new pages so readers can navigate between the split content

The source file is never modified or deleted — this skill only creates new files.

---

## Stage 0: Analyze the source

Read the target file in full.

Split the file into sections (by heading, then by paragraph within a section where
needed) and classify each one against these signatures:

| Doc type | Signature |
|----------|-----------|
| Conceptual | Definitions, "what is X" explanations, architecture or mental-model descriptions, trade-offs, no numbered steps |
| Reference | Syntax blocks, flags/options/parameters, tables or description lists of technical facts, designed to be scanned rather than read in order |
| How-to | Numbered or imperative steps, a specific task or problem being solved, "to do X, follow these steps" framing |

Build an internal content map of `section → assigned type` before writing any output
file. If a section or paragraph contains more than one type of content, assign it to
its dominant type and note the secondary content — don't split it at the
paragraph or sentence level.

Report the content map (which sections go to which output) before continuing to
Stage 1.

If the source covers only one or two of the three types, only generate pages for the
types actually present — don't create empty pages.

---

## Stage 1: Resolve output targets

If the user supplied output paths as arguments, map them to detected types in
**how-to, reference, concept** order — this is the fixed positional convention for
this skill. Restate the mapping explicitly (which path goes with which detected
type) before writing, since supplying fewer paths than detected types is ambiguous.
If the mapping is unclear — for example, the user gave two paths but three types were
detected — ask which type each path is for before proceeding.

If the user didn't supply output paths, derive default filenames in the same
directory as the source file, using its base name as a prefix:

- `<name>-howto.md`
- `<name>-reference.md`
- `<name>-concept.md`

Skip generating a file for any type with no content assigned in Stage 0.

---

## Stage 2: Draft each output page

For each detected type with content, apply its template from
[doc-types.instructions.md](../../instructions/doc-types.instructions.md):

### How-to guide

- `# <Title: bare infinitive>`
- One or two sentences describing the task and when a reader would perform it
- `## Before you begin` — only for non-obvious prerequisites
- `## <Task name: bare infinitive>` — introductory sentence, then numbered
  imperative steps
- `## Next steps` — only if part of a larger workflow
- `## See also` — populated in Stage 5

### Reference doc

- `# <Title: noun phrase>`
- `## Syntax`
- `## Description`
- `## Options` — as a description list with `Type:` and `Default:` for each flag
- `## Examples` — at least two, using real examples from the source; don't invent
  examples that aren't in the source
- `## Related` — populated in Stage 5

### Conceptual doc

- `# <Title: noun phrase>`
- Optional introductory paragraph
- `## What is <concept>`
- `## Use cases`
- `## (Optional) Comparison`
- `## Related resources` — populated in Stage 5

For every page:

- Preserve all working commands, real examples, code samples, and links exactly as
  they appear in the source — don't invent new ones.
- Carry over front matter fields relevant to the new page (title, weight, or
  equivalent); update the title to match the new page's content.
- Add `<!-- TODO: -->` markers for template sections the source doesn't cover.
- Add `<!-- TODO: consider splitting - contains [other type] content -->` on any
  section that Stage 0 flagged as mixed and left in place.

---

## Stage 3: Apply the team style guide

Apply [docs-style.instructions.md](../../instructions/docs-style.instructions.md) to
each generated page. Focus on these checks:

- **Voice and tense**: active voice, "you" instead of "the user," present tense
- **Headings**: sentence case, bare infinitive for how-to titles, noun phrase for
  reference and conceptual titles
- **Procedures**: imperative verbs to start every step (how-to pages only)
- **UI elements**: bold UI element names, correct terminology (select/enter/choose)
- **Language**: serial comma, contractions, no Latin abbreviations

---

## Stage 4: Lint with markdownlint, Vale, and cspell

Confirm every generated file passes all three linters the `docs-style-edit` skill
uses before finishing:

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

Re-run all three linters on each file after making fixes to confirm every file
reports zero errors.

---

## Stage 5: Cross-link the generated pages

Add links between the pages you generated so readers can navigate between the split
content:

- On the how-to guide, add links to the reference and conceptual pages it depends on
  in `## See also`.
- On the reference doc, add a link to the conceptual page and the how-to guide in
  `## Related`.
- On the conceptual doc, add links to the reference and how-to pages in
  `## Related resources`.

Only link to pages you actually generated in this run — don't invent links to pages
that don't exist.

---

## Report

Summarize:

- The content map from Stage 0 (section → assigned type)
- Which output files were created and at which paths
- Every `<!-- TODO: -->` left in each file and why, including mixed-content flags
- Confirmation that markdownlint, Vale, and cspell all pass with zero errors for
  every generated file
- Confirmation that the source file wasn't modified
