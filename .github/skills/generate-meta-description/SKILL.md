---
name: generate-meta-description
description: 'Read a Markdown file or all Markdown files in a directory, analyze each page''s content, and generate or update the description field in TOML or YAML frontmatter. Produces a Google-compliant meta description of 150–160 characters. Triggers on: meta description, description frontmatter, SEO description, generate description, page description, frontmatter description, add description, update description, write description, write meta description.'
argument-hint: "Path to a single Markdown file or a directory---for example: docs/reference/kitchen-yml.md or docs/reference/"
---

# Generate meta descriptions

Runs a four-stage workflow to generate or update the `description` field in the TOML or
YAML frontmatter of one or more Markdown files.
The skill reads each page's content, generates a Google-compliant meta description, and
writes it to the frontmatter---always overwriting any existing value.

0. **Identify files**---determines whether the input is a single file or a directory; if a
   directory, collects all `.md` files recursively
1. **Read and analyze**---reads each file's frontmatter and body content; detects the
   frontmatter format (TOML or YAML) and identifies the page's key topics and doc type
2. **Generate description**---produces a 150–160 character description following Google's
   meta description guidelines
3. **Write to frontmatter**---inserts or replaces the `description` field using the syntax
   for the detected frontmatter type

---

## What to ask before starting

Before starting, confirm these inputs if not already provided:

1. **File or directory path**---the path to a single `.md` file or a directory to process
   recursively, for example: `docs/reference/kitchen-yml.md` or `docs/reference/`

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
- `description`---the current value, if present (it will be overwritten)

### Read the body content

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

After processing all files, display a summary table:

| File | Format | Characters | Status |
|------|--------|-----------|--------|
| `docs/reference/kitchen-yml.md` | TOML | 158 | Written |
| `docs/reference/node.md` | YAML | 155 | Written |
| `docs/reference/broken.md` | None | — | Skipped---no frontmatter detected |
