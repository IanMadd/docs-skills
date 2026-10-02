---
name: edit-code-file-comments
description: 'Review and edit comments in code examples embedded in Markdown docs and in standalone downloadable code/config files (YAML, TOML, JSON-with-comments, shell, PowerShell, templates, Ruby, Python, Go, JavaScript, and similar). Applies the comment style rules in code-comments.instructions.md: moves documentation-only narration out of Markdown-embedded examples into surrounding prose, keeps customization/warning/intent comments in downloadable files, removes redundant comments, fixes placeholder formatting, and standardizes labels and formatting. In standalone mode, can cross-check a file'"'"'s comments against a Markdown page that documents it. Triggers on: review comments, edit comments, fix comments, comment style, review code comments, clean up comments, comment review, downloadable file comments, YAML comments, TOML comments, code example comments.'
argument-hint: "Path to a Markdown file or a standalone code/config file to review, optionally
  followed by the Markdown page that documents it --- for example: examples/agent-config.yaml
  docs/how-to/configure-agent.md"
---

# Edit comments in code examples and configuration files

Reviews and edits comments in two kinds of targets, applying the comment style rules in
[code-comments.instructions.md](../../instructions/code-comments.instructions.md):

- **Markdown-embedded examples** --- fenced code blocks inside a `.md` file
- **Standalone downloadable files** --- a whole YAML, TOML, shell, PowerShell, or source code
  file referenced or linked for download

This skill doesn't duplicate the style rules here --- read that section before starting, and
apply it directly, including its placeholder-formatting and line-length rules.

In standalone mode, if a Markdown page is given alongside the target file, or the target file's
directory contains an obvious doc page that links to it, use that page as a source for Step 3's
cross-check --- don't just edit the file's comments in isolation.

---

## Step 1: Determine mode

| Condition | Mode |
|-----------|------|
| Target is a `.md` file | Markdown mode --- scan every fenced code block in the file |
| Target is any other file (`.yaml`, `.yml`, `.toml`, `.json`, `.sh`, `.ps1`, `.rb`, `.py`, `.go`, `.js`, and similar) | Standalone mode --- the whole file is the artifact |

Report which mode you'll run before continuing.

In standalone mode, also check for a documenting Markdown page: use a second path argument if
one was given; otherwise search nearby `.md` files for a link to the target file's path. If you
find one, read it and carry it into Step 3. If you find none, continue without it --- this
cross-check is additive, not required.

---

## Step 2: Markdown mode --- review each fenced code block

For each fenced code block in the file, review every comment line and classify it:

- **Doc-specific** --- meaningful only because the example appears in documentation: it
  references a UI location, a documentation page, the surrounding tutorial workflow, or
  explains an unfamiliar construct for teaching purposes. Remove the comment from the code
  block and write an equivalent sentence in the surrounding Markdown prose instead --- directly
  before the code block for setup context, or directly after it for output explanation. Do this
  even for single-line comments.
- **Universally useful** --- explains why, intent, a risk, a customization point, an
  assumption, or an operational requirement. Keep it inline and reformat it per Step 4.
- **Redundant** --- restates the next line or an obvious name/value. Remove it. If the value is
  a short, cryptic token (an enum, flag, or code), check whether the comment actually decodes
  what the value means or does --- if so, it's universally useful, not redundant, even though
  it sits next to a setting name that already appears in the code.

After moving a comment to prose, confirm the resulting code block still makes sense on its own
--- if removing the comment leaves an unexplained placeholder value with no surrounding prose
sentence covering it, add one.

Flag, but don't silently invent, any code block that's missing a customization or warning
comment for a placeholder value or a risky setting (for example, disabling TLS verification) ---
add one per the approved comment types.

Enforce the length limits from code-comments.instructions.md: if a section comment would run past
about 5 lines, move the excess into Markdown prose above the block and shorten the in-code
comment to the essential 2 to 4 lines. Don't shorten a block that's already within the 2-to-4
line range just because one line is long. Never paraphrase or drop an exact remediation command
(a shell invocation, flag, or payload the reader would copy and run) to make a comment
shorter---keep it verbatim, even past the usual length guidance; shorten surrounding wording
first.

Check every placeholder value against the Markdown-embedded format: angle brackets, uppercase
text, underscores, no determiner (`my`, `your`, `our`) inside the token --- for example
`<TENANT_ID>`, not `your-tenant-id`.

Also check realistic, non-bracketed example values shown in comments (hostnames, domains,
paths) for an embedded determiner, and reword them to a neutral form, for example
`tenant-name.example.com` instead of `mytenant.example.com`.

---

## Step 3: Standalone mode --- review the whole file

Read the entire file as a single artifact that a reader will download, copy, and modify.

For every comment:

- If it references a documentation page, a UI screen, or tutorial-only narration, rewrite it as
  a self-contained statement that doesn't depend on the docs site --- keep the underlying
  customization point or requirement, just strip the doc-specific framing. Don't delete the
  comment outright if it points at a real customization point; rewrite it instead.
- If a comment's only content is a bare link to a vendor reference page (for example, "See
  `https://docs.aws.amazon.com/...` for valid values"), add the actionable fact --- the value,
  format, or behavior the reader needs --- ahead of the link rather than leaving the link as the
  sole source of it. Keep the link as a supplement if it points to a stable, canonical,
  vendor-maintained page; replace it with a self-contained statement if it points to this
  project's own tutorial or how-to page. See
  [Linking to external documentation](../../instructions/code-comments.instructions.md#linking-to-external-documentation).
- If it's redundant (restates the next line or an obvious name), remove it. If the value is a
  short, cryptic token (an enum, flag, or code) and the comment decodes what it means or does,
  keep it --- that's explaining, not restating, even though the setting name already appears in
  the code.
- Keep and reformat comments that explain why, a customization point, a risk, a requirement, or
  an operational consideration.
- If a block has conditionally required fields left blank (for example, dependent fields under
  a disabled-by-default `enabled: false`) and its comment runs over the length limit because it
  includes an example value for each field, don't delete the examples to fit the limit---convert
  each one to a short trailing comment on its own field's line instead of a multi-line block
  comment. See
  [Optional settings with blank fields](../../instructions/code-comments.instructions.md#optional-settings-with-blank-fields).
- Never paraphrase or drop an exact remediation command (a shell invocation, flag, or payload
  the reader would copy and run) to shorten a comment block, and don't shorten a block that's
  already within the 2-to-4 line range just because one line is long---keep the command
  verbatim and shorten surrounding wording instead.
- Apply the language-specific notes from code-comments.instructions.md --- for example, Shell and
  PowerShell scripts can carry slightly more explanatory comments than YAML or TOML.

Check every placeholder value against the downloadable-file format: the same uppercase,
underscore, no-determiner token inside angle brackets, formatted so it stays valid syntax for
the file type --- quoted for YAML/JSON/TOML string values, matching the native string literal
syntax for shell, PowerShell, and general-purpose languages.

Also check realistic, non-bracketed example values shown in comments (hostnames, domains,
paths) for an embedded determiner --- `my`, `your`, `our` --- and reword them to a neutral
form, for example `tenant-name.example.com` instead of `mytenant.example.com`. See
[Placeholder values](../../instructions/code-comments.instructions.md#placeholder-values).

If a documenting Markdown page was found in Step 1, cross-check the file's comments against it:

- For every setting the page describes as required, optional, conditionally required, or
  defaulted, confirm the file's comment on that setting says the same thing. Reword the comment
  to match the documented behavior rather than guessing from the file alone.
- Flag, but don't silently resolve, any mismatch between the page and the file --- for example,
  the page says a setting defaults to a value but the file has no comment noting the default, or
  the page describes a constraint between settings that the file's comment doesn't mention.
- Don't copy doc-specific framing over (UI steps, page references, tutorial narration) --- pull
  only the underlying setting behavior, and write it as a self-contained comment per the rewrite
  rule above.
- If the page documents a setting that has no comment in the file at all, add one.

---

## Step 4: Apply formatting rules

Apply the formatting rules from code-comments.instructions.md to every comment that remains after
Steps 2 and 3:

- Sentence case
- Complete sentences, ending with a period
- Wrap comment lines at about 80 characters, continuing onto an additional comment-prefixed line
  instead of letting one line run long
- Consistent labels --- `NOTE:`, `REQUIRED:`, `RECOMMENDED:`, `IMPORTANT:`, `WARNING:`, `TODO:` ---
  applied where the comment fits one of the approved comment types (TODO only in source
  repositories, never in reader-facing downloadable files). Use `REQUIRED:` for a value the
  reader must set, not `IMPORTANT:`---reserve `IMPORTANT:` for a hard requirement that isn't
  about entering a value. Keep the label and its text on the same comment line
- No restating a setting name or value that's already visible in the code
- State a conditional requirement condition-first --- lead with the `if` clause, then the
  requirement it triggers. Reword "X is required only when Y" to "If Y, set X."
- In a standalone file with many settings, add a blank line before a comment that introduces a
  different setting or field group when the line above is also a commented setting, so each
  documented setting reads as its own unit. Don't insert a blank line between a comment and the
  field it documents, and don't force one between consecutive uncommented settings that need no
  explanation. See
  [Spacing between settings](../../instructions/code-comments.instructions.md#spacing-between-settings).

---

## Final output

Return the fully edited file content.

After the file content, add an `## Edit summary` section with:

- Mode used (Markdown or standalone)
- Comments removed as redundant, with their original text
- Comments moved to prose, showing the original comment and the new prose sentence plus its
  location (before or after the code block)
- Comments reworded for formatting or placeholder fixes, showing old --- new
- Comments added for missing customization or warning coverage, and why
- If a documenting Markdown page was used: the page's path, and every mismatch found between
  the page and the file's comments, with how each was resolved
- Any code block or section skipped or left ambiguous, and why
