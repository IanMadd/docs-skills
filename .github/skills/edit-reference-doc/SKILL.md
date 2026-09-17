---
name: edit-reference-doc
description: 'Restructure an existing Markdown page, or draft a new one, to match the reference doc type template, then apply the team style guide and lint it with markdownlint, Vale, and cspell. Works on a single target file; supports optional source links when drafting new content. Triggers on: edit as reference doc, convert to reference doc, make this a reference page, format as reference, restructure reference doc, reference doc type, write reference docs from.'
argument-hint: "Path to the file to edit — for example: docs/reference/kubectl-rollout.md — optionally add source links when the file is new or empty: docs/reference/kubectl-rollout.md https://example.com/source-doc"
---

# Edit a page into a reference doc

Runs a five-stage workflow to restructure or draft a page so it matches the
reference doc type template and the team style guide.

0. **Determine mode** — reads the target file and classifies it as restructure mode
   (real content exists) or create mode (file is missing, empty, or placeholder-only)
1. **Apply the reference doc template** — pulls the structural rules for reference
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
| File has real syntax, options, or examples | Restructure mode |

Report which mode you'll run before continuing.

If you're in create mode and the user supplied source links or a source of truth for
flags/options (for example, a CLI's `--help` output, an OpenAPI spec, or a config
schema), fetch or read each one now (`fetch_webpage` for URLs, `read_file` for local
paths). Accurate option data is the core value of a reference doc — don't draft the
Options table from guesswork.

---

## Stage 1: Apply the reference doc template

Reference docs provide accurate, complete technical information designed to be
scanned, not read top to bottom. They mirror the structure of the system they
document and avoid high-level instructions or usage guidance — that belongs in a
how-to guide.

The required structure, from
[doc-types.instructions.md](../../instructions/doc-types.instructions.md):

- `# <Title: noun phrase>` — for example, "kubectl rollout options"
- One sentence describing what this reference covers
- `## Syntax` — the command or configuration syntax
- `## Description` — concise explanation of what it does
- `## Options` — a table with columns: Flag / Option, Type, Default, Description
- `## Examples` — at least two, each showing a different configuration, each in a
  fenced code block with a comment describing what it does
- `## Related` — links to a related reference page and a related how-to guide

Guidelines to enforce:

- Every flag, option, and parameter must be documented, with type and default
- Use `required` in the Default column when there's no default value
- Include at least two examples showing different configurations
- Use active voice in descriptions: "Returns a JSON object," not "A JSON object is
  returned"
- Use tables and bulleted lists to maximize scannability
- Don't include step-by-step procedures — link to a how-to guide instead

---

## Stage 2: Map or draft content

### Restructure mode

1. Rewrite the title as a noun phrase naming the command, option set, or
   configuration.
2. Extract the syntax line into `## Syntax`.
3. Condense any lengthy explanation into a concise `## Description`.
4. Convert prose descriptions of flags/options into the `## Options` table. Preserve
   every flag mentioned in the existing content. If a flag's type or default isn't
   stated anywhere in the file, mark it:
   `<!-- TODO: confirm type/default for --flag-name -->` rather than guessing.
5. Move any embedded step-by-step instructions out of the reference doc:
   `<!-- TODO: move this procedure to a how-to guide -->`, and keep only the
   reference-relevant facts (syntax, defaults, behavior).
6. Convert existing usage snippets into `## Examples`, each with a code comment. If
   fewer than two distinct examples exist, add
   `<!-- TODO: add a second example showing a different configuration -->`.
7. Build `## Related` from any links already present in the file.

### Create mode

1. Draft the title, one-sentence description, `Syntax`, and `Description` from the
   source material.
2. Build the `Options` table only from flags/options confirmed in the source
   material. For any flag mentioned without a documented type or default, write
   `<!-- TODO: confirm type/default -->` in that cell instead of guessing.
3. Draft at least two examples from real usage shown in the sources. If the sources
   only show one example, add a second with
   `<!-- TODO: add a second example showing a different configuration -->`.
4. Leave `Related` as `<!-- TODO: link to related reference/how-to guide -->` if no
   related content is known.

---

## Stage 3: Apply the team style guide

Apply [docs-style.instructions.md](../../instructions/docs-style.instructions.md).
Focus on these checks, since reference docs are scanned, not read linearly:

- **Voice**: active voice throughout descriptions ("Returns," "Accepts," not "is
  returned," "is accepted")
- **Headings**: sentence case, noun phrases (not verb-first)
- **Formatting**: consistent table structure and terminology across all reference
  pages in the repo; code font for flags, commands, and file paths
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
- Every `<!-- TODO: -->` left in the file and why (call out unresolved flag
  types/defaults explicitly, since these block publication)
- Confirmation that markdownlint, Vale, and cspell all pass with zero errors
