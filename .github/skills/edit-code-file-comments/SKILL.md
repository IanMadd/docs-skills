---
name: edit-code-file-comments
description: 'Review and edit comments in code examples embedded in Markdown docs and in standalone downloadable code/config files (YAML, TOML, JSON-with-comments, shell, PowerShell, templates, Ruby, Python, Go, JavaScript, and similar). Applies the comment style rules in docs-style.instructions.md: moves documentation-only narration out of Markdown-embedded examples into surrounding prose, keeps customization/warning/intent comments in downloadable files, removes redundant comments, fixes placeholder formatting, and standardizes labels and formatting. Triggers on: review comments, edit comments, fix comments, comment style, review code comments, clean up comments, comment review, downloadable file comments, YAML comments, TOML comments, code example comments.'
argument-hint: "Path to a Markdown file or a standalone code/config file to review --- for example: docs/how-to/configure-agent.md or examples/agent-config.yaml"
---

# Edit comments in code examples and configuration files

Reviews and edits comments in two kinds of targets, applying the comment style rules in
[docs-style.instructions.md](../../instructions/docs-style.instructions.md#comments-in-code-and-configuration-examples):

- **Markdown-embedded examples** --- fenced code blocks inside a `.md` file
- **Standalone downloadable files** --- a whole YAML, TOML, shell, PowerShell, or source code
  file referenced or linked for download

This skill doesn't duplicate the style rules here --- read that section before starting, and
apply it directly, including its placeholder-formatting and line-length rules.

---

## Step 1: Determine mode

| Condition | Mode |
|-----------|------|
| Target is a `.md` file | Markdown mode --- scan every fenced code block in the file |
| Target is any other file (`.yaml`, `.yml`, `.toml`, `.json`, `.sh`, `.ps1`, `.rb`, `.py`, `.go`, `.js`, and similar) | Standalone mode --- the whole file is the artifact |

Report which mode you'll run before continuing.

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
- **Redundant** --- restates the next line or an obvious name/value. Remove it.

After moving a comment to prose, confirm the resulting code block still makes sense on its own
--- if removing the comment leaves an unexplained placeholder value with no surrounding prose
sentence covering it, add one.

Flag, but don't silently invent, any code block that's missing a customization or warning
comment for a placeholder value or a risky setting (for example, disabling TLS verification) ---
add one per the approved comment types.

Enforce the length limits from docs-style.instructions.md: if a section comment would run past
about 5 lines, move the excess into Markdown prose above the block and shorten the in-code
comment to the essential 2 to 4 lines.

Check every placeholder value against the Markdown-embedded format: angle brackets, uppercase
text, underscores, no determiner (`my`, `your`, `our`) inside the token --- for example
`<TENANT_ID>`, not `your-tenant-id`.

---

## Step 3: Standalone mode --- review the whole file

Read the entire file as a single artifact that a reader will download, copy, and modify.

For every comment:

- If it references a documentation page, a UI screen, or tutorial-only narration, rewrite it as
  a self-contained statement that doesn't depend on the docs site --- keep the underlying
  customization point or requirement, just strip the doc-specific framing. Don't delete the
  comment outright if it points at a real customization point; rewrite it instead.
- If it's redundant (restates the next line or an obvious name), remove it.
- Keep and reformat comments that explain why, a customization point, a risk, a requirement, or
  an operational consideration.
- Apply the language-specific notes from docs-style.instructions.md --- for example, Shell and
  PowerShell scripts can carry slightly more explanatory comments than YAML or TOML.

Check every placeholder value against the downloadable-file format: the same uppercase,
underscore, no-determiner token inside angle brackets, formatted so it stays valid syntax for
the file type --- quoted for YAML/JSON/TOML string values, matching the native string literal
syntax for shell, PowerShell, and general-purpose languages.

---

## Step 4: Apply formatting rules

Apply the formatting rules from docs-style.instructions.md to every comment that remains after
Steps 2 and 3:

- Sentence case
- Complete sentences, ending with a period
- Wrap comment lines at about 80 characters, continuing onto an additional comment-prefixed line
  instead of letting one line run long
- Consistent labels --- `NOTE:`, `IMPORTANT:`, `WARNING:`, `TODO:` --- applied where the comment
  fits one of the approved comment types (TODO only in source repositories, never in
  reader-facing downloadable files)
- No restating a setting name or value that's already visible in the code

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
- Any code block or section skipped or left ambiguous, and why
