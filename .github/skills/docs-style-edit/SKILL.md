---
name: docs-style-edit
description: 'Apply the team style guide to a documentation file, then run markdownlint-cli2, Vale (MCP server or CLI fallback), and cspell and fix flagged issues. Use when you want to fully review and edit a doc for prose quality and style compliance. Triggers on: run vale, lint documentation, check style, fix prose, style edit, review doc, vale errors, documentation linting, markdownlint, markdown formatting, cspell, spell check.'
argument-hint: "Path to the Markdown file to lint and edit — for example: docs/how-to-deploy.md"
---

# Markdown lint and style edit

Runs a two-stage editing workflow on a documentation file:

1. **Style guide edit** — applies team style rules from [docs-style.instructions.md](../../instructions/docs-style.instructions.md)
2. **Lint and fixes** — runs markdownlint-cli2, Vale, and cspell on the style-edited document and resolves any remaining issues

Do not run any of the three linter checks before completing the style-guide edit.
If resolving lint findings changes the document or its word list, rerun all three
linters so their results reflect the final content.

---

## Before running this skill

Confirm that the linter tools are available and configured. These are version and
setup checks, not lint runs against the target document.

**markdownlint-cli2**: See [markdownlint-setup.md](./references/markdownlint-setup.md)
for installation and configuration instructions.

```shell
markdownlint-cli2 --version
```

**Vale MCP server or CLI**: This skill uses the Vale MCP server when available. Check
whether it is configured by typing `/` in Copilot Chat and looking for a tool with
`vale` in its name. If the MCP server is unavailable, use the Vale CLI.

```shell
vale --version
vale sync
```

See [vale-setup.md](./references/vale-setup.md) for MCP server configuration and CLI
setup instructions.

**cspell**:

```shell
cspell --version
```

---

## Stage 1: Apply the team style guide

Apply the team style rules from [docs-style.instructions.md](../../instructions/docs-style.instructions.md)
to the target document. Finish all style-guide edits before proceeding to Stage 2.

Use these checks to guide the edit:

### Voice and person

- Change passive voice to active voice where the subject is known.
- Address the reader as "you" instead of "users," "one," or "the user."

### Tense

- Use present tense for current product behavior, such as "returns" or "creates."
- Keep future tense for genuinely asynchronous or future events.

### Word substitutions

- Replace `utilize` with `use`.
- Replace `navigate to` with `go to`.
- Replace `via` with `through`, `with`, or `using`.
- Replace `e.g.` with `for example` and `i.e.` with `that is`.
- Remove `please`.
- Replace `alongside` (meaning "together with") with `together with`.
- Replace `click` or `click on` with `select`.
- Replace `do not`, `cannot`, and `are not` with `don't`, `can't`, and `aren't`.

### Headings

- Use sentence case.
- Start task-based headings with a bare infinitive: "Configure the cluster," not
  "Configuring the cluster."

### Code blocks

- Add language identifiers to fenced code blocks that are missing one, such as
  `shell`, `yaml`, `json`, `hcl`, `dockerfile`, or `console`.
- Use angle brackets for placeholder values, such as `<CLUSTER_NAME>` and
  `<NAMESPACE>`.

### UI elements and links

- Bold UI element names, such as **Save** and **Settings**.
- Replace non-descriptive link text such as "click here," "here," and "this page"
  with descriptive text.

### Tables

Convert a simple two-column table that defines individual settings, properties,
parameters, options, flags, endpoints, or similar terms to a Markdown description
list when the rows do not need comparison or alignment.

```markdown
`term`
: Description text.

`term`
: Description text.
```

Use code formatting for literal terms such as flags, option names, property keys,
and endpoint paths. Use plain text for natural-language labels. Keep tables that
compare multiple attributes, present numeric data, or serve another purpose.

### DevOps terminology

- Write `Kubernetes`, not `k8s`, in body text.
- Write `GitOps` in camel case.
- Spell out "infrastructure as code" before using `IaC`.
- Spell out "continuous integration and continuous delivery" before using `CI/CD`.
- Use `container` instead of `Docker container` unless the context is Docker-specific.

---

## Stage 2: Run all linters on the style-edited document

Run each linter below against the target file only after completing Stage 1.

### Markdownlint

Check the repository root for a Markdownlint config file. Common names include
`.markdownlint.yaml`, `.markdownlint.yml`, and `.markdownlint.json`. If one exists,
markdownlint-cli2 picks it up automatically.

Run markdownlint-cli2 with `--fix`, then run it again without `--fix` to identify
remaining issues:

```shell
markdownlint-cli2 --fix <file>
markdownlint-cli2 <file>
```

Resolve any remaining issues manually. See [markdownlint-setup.md](./references/markdownlint-setup.md)
for guidance on common rules.

### Vale

Use the Vale MCP tool to lint the target file and collect its issues. Look for a tool
with `vale` in its name, typically `vale_lint`. Record each issue's severity, rule,
and message. If the MCP server is unavailable, use the CLI:

```shell
vale --minAlertLevel=error <file>
```

Resolve Vale errors only; record warnings and suggestions in the final summary. Use
the rule name and message to guide targeted edits. See [vale-fix-guide.md](./references/vale-fix-guide.md)
for help with common rules.

### Cspell

Run cspell against the target file:

```shell
cspell lint <file>
```

Correct genuine misspellings. For valid technical or project-specific terms, add the
word to the repository word list instead of changing the text. Look for `cspell.json`,
`.cspell.json`, `cspell.yaml`, `.cspell.yaml`, `cspell.yml`, or a `words` array in
`package.json` at the repository root. If no word list exists, create `cspell.json`:

```json
{
  "version": "0.2",
  "words": ["<word>"]
}
```

### Verify the final document

After fixing any markdownlint, Vale, or cspell findings, rerun all three linters if
the document or its word list changed. Finish only after markdownlint-cli2 and cspell
report no issues and Vale reports no errors.

---

## Final output

Return the fully edited file content.

After the file content, add an `## Edit summary` section with:

- Number of markdownlint issues auto-fixed and issues resolved manually.
- Final markdownlint, Vale, and cspell status.
- Number of Vale errors fixed and the Vale rules that fired.
- Number of spelling errors fixed and words added to the word list.
- Style-guide corrections applied, grouped by category.
- Any `<!-- TODO: verify -->` comments added for items that need human review.
