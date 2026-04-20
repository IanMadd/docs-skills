---
name: markdownlint-edit
description: 'Lint a Markdown file with markdownlint-cli2, auto-fix all correctable issues, then manually fix anything that remains. Use when you want a focused Markdown formatting fix without running the full docs-style-edit workflow. Triggers on: markdownlint, markdown lint, lint markdown, fix markdown, markdown formatting, markdown errors, markdownlint errors, fix formatting.'
argument-hint: "Path to the Markdown file to lint and fix — for example: docs/how-to-deploy.md"
---

# Markdown lint and fix

Runs a two-stage workflow on a documentation file:

1. **Auto-fix** — runs `markdownlint-cli2 --fix` to correct all auto-fixable formatting issues in place
2. **Manual fix** — reports any remaining issues and edits the file to resolve them

---

## Before running this skill

Confirm markdownlint-cli2 is installed:

```shell
markdownlint-cli2 --version
```

See [markdownlint-setup.md](../docs-style-edit/references/markdownlint-setup.md) for
installation instructions.

Check the repo root for a markdownlint config file. Common file names are
`.markdownlint.yaml`, `.markdownlint.yml`, and `.markdownlint.json`. If one exists,
markdownlint-cli2 picks it up automatically — no extra flags are needed.

---

## Stage 1: Auto-fix with markdownlint-cli2

Run markdownlint-cli2 with the `--fix` flag:

```shell
markdownlint-cli2 --fix <file>
```

This corrects the majority of formatting issues in place, including:

- Trailing spaces
- Hard tabs
- Multiple consecutive blank lines
- Missing blank lines around headings, fenced code blocks, and lists
- Inconsistent emphasis style (`*` vs `_`)
- Missing language identifiers on fenced code blocks

After auto-fix, run markdownlint-cli2 again without `--fix` to see what remains:

```shell
markdownlint-cli2 <file>
```

markdownlint-cli2 reports remaining issues in this format:

```
<file>:<line>:<col>  <rule-id>/<alias>  <message>
```

If no issues remain, the workflow is complete — report that and stop.

---

## Stage 2: Fix remaining issues manually

For each remaining issue:

1. Go to the reported line number.
2. Read the rule ID and message to understand what needs to change. Use the table below for
   common rules.
3. Edit the file to resolve the issue.
4. Don't change surrounding text unless it is necessary to fix that specific issue.

### Common rules that require manual fixes

The following rules are enabled in [.markdownlint.yaml](./assets/.markdownlint.yaml)
and cannot always be auto-corrected.

`MD014` / `commands-show-output`
: A command is prefixed with `$` but no output is shown. Either remove the `$` prefix, or add
  a `console` block below the command showing the expected output.

`MD024` / `no-duplicate-heading`
: Two headings at the same nesting level have identical text (`siblings_only: true` is set, so
  only sibling headings are checked). Reword one of the headings to make it distinct.

`MD033` / `no-inline-html`
: Inline HTML is present that is not in the allowed elements list. The allowed elements are:
  `<code>`, `<table>`, `<tbody>`, `<thead>`, `<td>`, `<th>`, `<tr>`, `<colgroup>`, `<col>`,
  `<span>`. Replace any other HTML with equivalent Markdown where possible. If there is no
  Markdown equivalent (for example, a `<details>` block), suppress the rule locally:

  ```markdown
  <!-- markdownlint-disable MD033 -->
  <details>
  <summary>Expand for details</summary>
  Content here
  </details>
  <!-- markdownlint-enable MD033 -->
  ```

`MD040` / `fenced-code-language`
: A fenced code block is missing a language identifier. Add the appropriate identifier after
  the opening fence: `shell`, `yaml`, `json`, `hcl`, `dockerfile`, or `console`.

`MD044` / `proper-names`
: A proper name is not capitalized correctly. The list of enforced names is defined in
  `.markdownlint.yaml` under `MD044.names`. If the flagged term is correct, add it to the
  `names` list in the config instead of changing the text.

After editing, run markdownlint-cli2 one more time to confirm no issues remain:

```shell
markdownlint-cli2 <file>
```

If new issues appear, address those too before finishing.

---

## Final output

Return the fully edited file content.

After the file content, add an `## Edit summary` section with:

- Number of issues auto-fixed by `markdownlint-cli2 --fix`
- Number of issues fixed manually, listed by rule ID
- Any suppression comments added (`<!-- markdownlint-disable -->`) and why
