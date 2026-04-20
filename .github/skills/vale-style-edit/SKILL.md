---
name: vale-style-edit
description: 'Lint a documentation file with the Vale MCP server (or CLI as fallback) at error severity, then fix every error. Use when you want a focused prose error check without running the full docs-style-edit workflow. Triggers on: run vale, vale errors, vale lint, fix vale errors, prose errors, fix errors.'
argument-hint: "Path to the Markdown file to lint and fix — for example: docs/how-to-deploy.md"
---

# Vale lint and fix

Runs a two-stage workflow on a documentation file:

1. **Vale lint** — lints prose with the Vale MCP server (or CLI fallback) at `error` severity only
2. **Vale fixes** — edits the file to resolve every reported error

---

## Before running this skill

Confirm vale is installed and configured before running this skill.

**Vale MCP server or CLI**: This skill uses the Vale MCP server when available. Check whether
it is configured by typing `/` in Copilot Chat and looking for a tool with `vale` in its name
(typically `vale_lint` or similar). If the MCP server is not available, the skill falls back
to the vale CLI:

```shell
vale --version
vale sync
```

See [vale-setup.md](../docs-style-edit/references/vale-setup.md) for MCP server configuration
and CLI setup instructions.

---

## Stage 1: Lint with the Vale MCP server

Use the Vale MCP tool to lint the target file at error severity. Call the tool with the target
file path as the argument and, where the tool supports it, pass `minAlertLevel: error` (or the
equivalent option name the tool exposes) so only errors are returned.

To find the tool name, type `/` in Copilot Chat and look for a tool with `vale` in the name —
it is typically called `vale_lint`.

The MCP tool returns a structured list of issues. Each issue contains:

- `file` — path to the file
- `line` and `col` — location of the issue
- `severity` — only `error` results are collected in this stage
- `message` — description of the problem
- `rule` — the rule that fired (for example, `Google.Latin`, `Microsoft.Avoid`)

Collect every error. If the tool returns no errors, the workflow is complete — report that
no errors were found and stop.

> **CLI fallback**: If the Vale MCP server is not available, run the following command in a
> terminal instead:
>
> ```shell
> vale --minAlertLevel=error <file>
> ```
>
> Vale reports issues in the format: `<file>:<line>:<col>  <severity>  <message>  <rule-name>`
>
> Collect every line with severity `error` and proceed to Stage 2.

---

## Stage 2: Fix every error

Edit the file to resolve each error reported in Stage 1.

For each error:

1. Go to the reported line number.
2. Read the rule name and message — see [vale-fix-guide.md](../docs-style-edit/references/vale-fix-guide.md) for how to interpret common rules.
3. Edit the text to resolve the error.
4. Don't change surrounding text unless it is necessary to fix that specific issue.

After addressing all errors, run vale again to confirm the error count is zero:

```shell
vale --minAlertLevel=error <file>
```

If new errors appear, address those too before finishing.

---

## Final output

Return the fully edited file content.

After the file content, add an `## Edit summary` section with:

- Total number of vale errors fixed
- List of vale rules that fired, with a count for each
- Any `<!-- vale off -->` suppression comments added, and why
- Any `<!-- TODO: verify -->` comments added for items that need human review
