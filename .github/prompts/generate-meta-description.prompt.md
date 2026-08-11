---
description: "Generate or update the description field in a single Markdown file's TOML or YAML frontmatter. Produces a Google-compliant meta description of 150–160 characters. For batch processing a directory, use the generate-meta-description skill instead."
name: "Generate meta description"
argument-hint: "Path to the Markdown file---for example: docs/reference/kitchen-yml.md"
agent: "agent"
---

Read the file at `$input` and generate or update the `description` field in its
frontmatter.

## Steps

1. Read the full file content.

2. Detect the frontmatter format by checking the first line:
   - `+++`---TOML frontmatter; fields use `key = "value"` syntax
   - `---`---YAML frontmatter; fields use `key: value` syntax
   - Anything else---stop and report that no frontmatter was detected

3. Extract the `title` field and read the body content to identify:
   - The page's primary topic
   - Its doc type (how-to, reference, conceptual, tutorial, or release notes)
   - The key terms a reader would search for
   - What the reader will find, learn, or be able to do

4. Generate a meta description that:
   - Is 150–160 characters long (count carefully)
   - Contains no double quotation marks---they truncate the snippet in search results
   - Names the primary topic and one or two key terms naturally
   - States the reader's outcome in present tense, active voice
   - Doesn't begin with "This page", "Learn", "Overview", or the title verbatim
   - Is specific to this page and wouldn't apply equally to another page

5. Insert or replace the `description` field immediately after the `title` line using the
   syntax for the detected format:
   - TOML: `description = "<description>"`
   - YAML: `description: "<description>"`

6. Report the generated description and its exact character count.
