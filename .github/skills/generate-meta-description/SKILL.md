---
name: generate-meta-description
description: 'Read a Markdown file or all Markdown files in a directory, analyze each page''s content, and generate or update the description field in TOML or YAML frontmatter. Handles prose pages, CLI reference pages built from a Hugo shortcode and a data_path pointing at vendored YAML, and API reference pages built from an OpenAPI or Swagger spec referenced through an api_file_path. Produces a Google-compliant meta description of 150–160 characters. Triggers on: meta description, description frontmatter, SEO description, generate description, page description, frontmatter description, add description, update description, write description, write meta description, CLI reference description, API reference description, OpenAPI description, Swagger description, data-generated page description, shortcode page description.'
argument-hint: "Path to a single Markdown file or a directory, optionally followed by --force---for example: docs/reference/kitchen-yml.md or docs/reference/cli/ --force"
---

# Generate meta descriptions

Runs a four-stage workflow to generate or update the `description` field in the TOML or
YAML frontmatter of one or more Markdown files.
The skill reads each page's content, generates a Google-compliant meta description, and
writes it to the frontmatter---overwriting the existing value only if it's missing or
doesn't meet the quality checklist, unless the `--force` option is set, in which case
every file gets a freshly generated description regardless of the existing value.

Some pages have no real prose body. CLI reference pages pull their body from vendored
YAML data files through a Hugo shortcode and a `data_path` field. API reference pages
pull their content from an OpenAPI or Swagger spec file referenced through an
`api_file_path` field and rendered through a ReDoc viewer instead of Markdown. The skill
detects both kinds of data-generated pages, resolves the underlying source through the
repo's Hugo module mounts, and drafts the description from that source instead of the
(empty) body.

0. **Identify files**---determines whether the input is a single file or a directory; if a
   directory, collects all `.md` files recursively
1. **Read and analyze**---reads each file's frontmatter; detects the frontmatter format
   (TOML or YAML); determines whether the page is a normal prose page or a data-generated
   page and, for data-generated pages, resolves and reads the underlying data source
2. **Generate description**---produces a 150–160 character description following Google's
   meta description guidelines
3. **Write to frontmatter**---inserts or replaces the `description` field using the syntax
   for the detected frontmatter type

---

## What to ask before starting

Before starting, confirm these inputs if not already provided:

1. **File or directory path**---the path to a single `.md` file or a directory to process
   recursively, for example: `docs/reference/kitchen-yml.md` or `docs/reference/`
2. **Force update**---whether to regenerate every description regardless of whether the
   existing one already passes the quality checklist. Default: no. Ask this only if the
   user hasn't already indicated it (for example, by passing `--force` or saying
   something like "regenerate all" or "even the ones that already pass")

---

## Meta description rules

Apply these rules when generating every description.
They are drawn from the
[Google meta description guidelines](https://developers.google.com/search/docs/appearance/snippet#meta-descriptions).

- **Length**: 150–160 characters. Count characters including spaces. Descriptions under
  150 characters may be too thin; descriptions over 160 risk truncation in search results.
- **No double quotation marks**: Double quotes (`"`) truncate the snippet in search
  results. Use single quotes if quoting is necessary, or rephrase to avoid it.
- **Be specific and accurate**: Summarize what the reader will find, learn, or be able to
  do after reading the page. Don't use generic phrases like "This page covers...", "Learn
  about...", or "An overview of...".
- **Include keywords naturally**: Incorporate the page's key terms where they fit
  naturally. Don't stuff keywords---write for the reader first.
- **Present tense, active voice**: Write as though describing what the page does for the
  reader right now.
- **Unique per page**: Each description must be distinct. Don't reuse the title verbatim
  or produce boilerplate text that could apply to multiple pages.
- **Complete sentences**: Use at least one grammatically complete sentence. Fragments are
  acceptable only when they form a clear, readable summary alongside a sentence.

### Description quality checklist

Before accepting a generated description, verify all of the following:

- [ ] Character count is between 150 and 160 (inclusive)
- [ ] Contains no double quotation marks
- [ ] Doesn't begin with "This page", "Learn", "Overview", or the page title verbatim
- [ ] Contains at least one key term from the page
- [ ] Is written in present tense, active voice
- [ ] Would make sense as a standalone snippet in a search result

---

## Stage 0: Identify files

Determine whether the input is a single file or a directory path.

**Single file**: confirm the path exists and ends in `.md`.
If the file doesn't exist, stop and report the error.

**Directory**: run the following command to collect all Markdown files recursively:

```shell
find <path> -name "*.md" -type f | sort
```

Report the number of files found before continuing to Stage 1.
If no `.md` files are found, stop and report that the directory contains no Markdown
files.

---

## Stage 1: Read and analyze

For each file, complete the following steps.

### Detect the frontmatter format

Read the first non-empty line of the file:

| First line | Format | Field syntax |
|------------|--------|--------------|
| `+++` | TOML | `key = "value"` |
| `---` | YAML | `key: value` |
| Anything else | None | — |

If no frontmatter delimiter is detected, skip the file and record it in the batch report
with status **Skipped---no frontmatter detected**.

### Extract frontmatter fields

Read the content between the opening and closing delimiters and extract:

- `title`---the page title (used to avoid repeating it verbatim in the description)
- `description`---the current value, if present (checked against the quality checklist
  before deciding whether to overwrite it)
- `summary`---a short human-written summary, if present (some CLI and API reference
  pages already have one; see **Detect data-generated pages** below)
- `data_path`---if present, the page's own default data source for a CLI reference
  page (see below)
- `layout`---if present, indicates a non-default template; `data-api` marks an API
  reference page rendered from an OpenAPI or Swagger spec
- `api_file_path`---if present alongside `layout = "data-api"`, the path to the page's
  OpenAPI or Swagger spec file (see below)
- `headless` and `build.render` (including inside a `cascade` block)---used to detect
  sections that never render as standalone pages (see **Detect headless and
  non-rendered content** below)

### Check the existing description

If `--force` is set, skip this check entirely and proceed straight to Stage 1's
remaining steps---every file gets a freshly generated description regardless of
whether one already exists or already passes the checklist.

Otherwise, if the file already has a `description` field, run it through the
**Description quality checklist** in **Meta description rules** before generating a
replacement.

- If the existing description passes every checklist item, skip generation for this
  file. Record it in the batch report as **Skipped---existing description already
  compliant** and move to the next file.
- If it fails any checklist item, proceed to Stage 1's remaining steps and Stage 2 as
  normal---the generated description will overwrite it in Stage 3.
- If no `description` field exists, proceed as normal---there's nothing to check.

### Detect headless and non-rendered content

Some sections hold reusable Markdown or data fragments that get pulled into other
pages through shortcodes or partials---they're never rendered as standalone pages and
gain nothing from a meta description. Skip a file if any of the following is true:

- Its own frontmatter sets `headless = true` (TOML) or `headless: true` (YAML)---a
  Hugo headless bundle.
- Its own frontmatter sets `render = "never"` under `[build]`/`build:`, either directly
  or inside a `[[cascade]]`/`cascade:` block.
- Any ancestor directory's `_index.md` or `index.md`, between the file and the
  `content/` root, sets `headless = true` or a cascading `build.render = "never"`---the
  setting applies to every page in that section, including the section's own index file
  and any fragment file that happens to carry its own frontmatter. (Fragment files with
  no frontmatter at all are already caught by **Skipped---no frontmatter detected**.)

Record skipped files in the batch report as **Skipped---headless/non-rendered
content** and move to the next file.

### Detect data-generated pages

Two kinds of data-generated pages exist in this repo, each pulling content from a
different source at build time.

**CLI reference pages (shortcode-driven)**: the body is one or more Hugo shortcode
calls that pull content from vendored YAML data files. Scan the body for shortcode
calls (`{{< shortcode-name param="value" ... >}}`).

A page is a **CLI reference page** if any shortcode call either:

- Includes an explicit `data_path="..."` argument, or
- Has no arguments at all, and the page's own frontmatter contains a `data_path` field

Collect every distinct `data_path` value the page needs---a single page can reference
more than one (for example, a CLI commands data source and a separate error-codes data
source).

**API reference pages (OpenAPI/Swagger-driven)**: the page has no shortcode body at
all---instead, its frontmatter sets `layout` to `data-api` and includes an
`api_file_path` field. The `api_file_path` value is a path to an OpenAPI (v3) or
Swagger (v2) spec file in JSON or YAML format, rendered through a ReDoc viewer rather
than from Markdown prose.

A page is an **API reference page** if its frontmatter contains both a `layout` field
equal to `data-api` and an `api_file_path` field.

If the page matches neither pattern, treat it as a normal prose page and skip to
**Read the body content** below.

### Resolve the data source (data-generated pages only)

Both CLI reference pages and API reference pages point at a **virtual path**---a
site-relative path that doesn't exist on disk until it's resolved through the repo's
Hugo module mounts. Compute the virtual path first, then resolve it.

#### Compute the virtual path

- **CLI reference pages**: the virtual path is `data/<data_path>` for each `data_path`
  value collected above.
- **API reference pages**: the virtual path is `static/<resolved-site-path>`, where
  `<resolved-site-path>` depends on the form of `api_file_path`:
  - If `api_file_path` starts with `/`, strip the leading `/`---the rest is the
    resolved site path directly.
  - Otherwise, `api_file_path` is relative to the page's own rendered URL. Compute the
    page's URL directory by taking its path relative to `content/` and stripping the
    `.md` extension (and, for `_index.md` files, the `_index` segment itself), then
    apply the relative path as a browser would resolve a relative link from that
    directory---for example, `content/reference/supervisor_api.md` renders at
    `reference/supervisor_api/`, so `api_file_path = "../habitat-api-docs/sup-api.json"`
    resolves to `reference/habitat-api-docs/sup-api.json`.

#### Resolve the virtual path through Hugo module mounts

1. Find the repo's Hugo module mount config. Check, in this order:
   `config/_default/module.toml`, `config/_default/hugo.toml`, `hugo.toml`,
   `config.toml` at the repo root.
2. Read every mount definition in the config:
   - Local `[[mounts]]` blocks---`source` and `target` are relative to the repo root.
   - `[[imports]] path = "<module>"` blocks---their nested `[[imports.mounts]]`
     `source` and `target` are relative to `_vendor/<module>/`.
3. Compute each mount's real absolute source directory: local mount---
   `<repo-root>/<source>`; import mount---`<repo-root>/_vendor/<module path>/<source>`.
4. Match the virtual path against every mount's `target`, using the **longest
   matching prefix**. Strip the matched target prefix from the virtual path to get the
   leftover suffix, then append it to that mount's real source directory---this is the
   resolved location.
5. Confirm the resolved directory or file exists on disk.

If no mount matches, the resolved path doesn't exist, or more than one mount
ambiguously matches the same target, **stop processing this file**. Record it in the
batch report as **Skipped---data source unresolved** with a short reason, and move to
the next file. Don't guess a description from the title alone.

### Extract from the resolved data (CLI reference pages)

Once a `data_path` resolves to real files:

- **Command directory** (multiple `<cli>[_<subcommand>...].yaml` files): read the root
  command file---the one whose filename, minus `.yaml`, has no additional
  underscore-separated subcommand segments (for example, `chef-automate.yaml`, not
  `chef-automate_backup.yaml`). Extract `synopsis`, `description`, and the first 5--8
  entries of `see_also` (subcommand name plus its one-line description).
- **Flat data file** (a single file with a top-level list key, for example
  `errors.yaml` with an `errors:` list): read it directly and characterize it briefly
  (for example, "documents N numbered error codes and their meanings"). Treat this as
  supplementary context unless it's the page's only data source.
- **Combine with frontmatter**: if the page's frontmatter already has a `summary`
  field, treat it as the primary "what this page is about" statement, and use the
  extracted subcommand or error names only to add 2--3 concrete key terms. If no
  `summary` field exists, derive the primary statement from the root command file's
  `synopsis`/`description` instead.

Record the combined result---primary statement, key terms, and doc type (always
**Reference** for data-generated CLI pages)---for use in Stage 2.

### Extract from the resolved spec (API reference pages)

Once `api_file_path` resolves to a real file or directory:

- **Single spec file** (the common case): parse it as JSON or YAML based on its
  extension, then read `info.title` and `info.description` from the top-level `info`
  block---both OpenAPI 3.x and Swagger 2.0 documents use this structure. Treat
  `info.title` as the API or service name.
- **Condense `info.description`**: this field is often long Markdown written for the
  rendered API reference (headings, code blocks, authentication instructions), not a
  search snippet. Use only the plain-text lead-in before the first heading or code
  block, and strip Markdown link and code syntax before using it as context.
- **Resolved directory instead of a single file**: list the `.json`/`.yaml` filenames
  it contains---each typically represents one API resource or service---and
  characterize the group briefly (for example, "documents 5 service APIs including
  chef-courier-delivery, chef-license-management-service, and chef-node-enrollment").
- **Combine with frontmatter**: if the page's frontmatter already has a `summary`
  field, treat it as the primary "what this page is about" statement, and use
  `info.title` and the condensed `info.description` only to add 1--2 concrete key
  terms (the service name, a domain it covers). If no `summary` field exists, derive
  the primary statement directly from `info.title` and the condensed
  `info.description`.

Record the combined result---primary statement, key terms, and doc type (always
**Reference** for data-generated API pages)---for use in Stage 2.

### Read the body content (prose pages only)

Read everything after the closing frontmatter delimiter.
Identify:

- **Doc type**---how-to, reference, conceptual, tutorial, release notes, or README
- **Primary topic**---the subject or resource the page documents
- **Key terms**---the most important nouns and phrases a reader would search for
- **Reader outcome**---what the reader will be able to do, find, or understand

Record these for use in Stage 2.

---

## Stage 2: Generate the description

Using the information from Stage 1, draft a meta description for the file.

### Draft the description

Write a description that:

- Is 150–160 characters long
- Contains no double quotation marks
- Names the primary topic and one or two key terms
- States the reader's outcome (what they'll find, learn, or accomplish)
- Doesn't begin with "This page", "Learn", "Overview", or the page title verbatim
- Is written in present tense, active voice

### Doc type framing guidance

Use the page's doc type to frame the description:

| Doc type | Framing approach |
|----------|-----------------|
| How-to | State the task and what the reader can accomplish: "Configure X to do Y." |
| Reference | Name the resource and what it defines: "Reference for X options, including Y and Z." |
| CLI reference (data-generated) | Name the CLI and reference 2--3 representative commands or error categories: "Reference for the `<cli-name>` command line interface, covering `<cmd>`, `<cmd>`, and `<cmd>`." |
| API reference (data-generated) | Name the API and what it covers, referencing the service or a domain from its spec: "Reference for the `<API name>` API, covering `<domain>` and `<domain>` endpoints." |
| Conceptual | State the concept and what it enables: "Explains how X works and when to use Y." |
| Tutorial | Name the goal and what the reader builds: "Walk through building X with Y and Z." |
| Release notes | Name the product, version, and change type: "Release notes for X version Y, covering Z." |

### Verify before continuing

Check the description against the quality checklist in **Meta description rules** before
proceeding to Stage 3.
If any check fails, revise until all checks pass.

---

## Stage 3: Write to frontmatter

Write the generated description into the file using the syntax that matches the detected
frontmatter format.

### TOML frontmatter (`+++`)

**If `description = "..."` already exists in the `+++` block**, replace the entire line:

```toml
description = "<generated description>"
```

**If no `description` field exists**, insert it on the line immediately after the
`title = ...` line:

```toml
title = "..."
description = "<generated description>"
```

### YAML frontmatter (`---`)

**If `description: ...` already exists in the `---` block**, replace the entire line:

```yaml
description: "<generated description>"
```

**If no `description` field exists**, insert it on the line immediately after the
`title: ...` line:

```yaml
title: ...
description: "<generated description>"
```

### Batch report

After processing all files, display a summary table. The **Source** column shows
`Prose` for a normal body read, `CLI` for a CLI reference page resolved through a
shortcode `data_path`, `API` for an API reference page resolved through
`api_file_path`, or a skip reason:

| File | Format | Source | Characters | Status |
|------|--------|--------|-----------|--------|
| `docs/reference/kitchen-yml.md` | TOML | Prose | 158 | Written |
| `docs/reference/cli/chef_courier_cli.md` | TOML | CLI | 156 | Written |
| `docs/reference/api/supervisor_api.md` | TOML | API | 157 | Written |
| `docs/reference/node.md` | YAML | Prose | 155 | Written |
| `docs/reference/broken.md` | None | — | — | Skipped---no frontmatter detected |
| `docs/reference/cli/unknown-cli.md` | TOML | — | — | Skipped---data source unresolved |
| `content/reusable/index.md` | TOML | — | — | Skipped---headless/non-rendered content |
| `docs/reference/existing-good.md` | YAML | Prose | — | Skipped---existing description already compliant |
| `docs/reference/forced-update.md` | YAML | Prose | 156 | Written (forced) |

When `--force` is set, mark every regenerated file's status as **Written (forced)**
instead of **Written** so the report distinguishes forced rewrites from normal ones.
