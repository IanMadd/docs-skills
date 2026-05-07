---
name: docs-style-edit
description: 'Lint a documentation file with markdownlint-cli2, the Vale MCP server (or CLI as fallback), and cspell, fix all flagged issues, then apply the team style guide. Use when you want to fully review and edit a doc for prose quality and style compliance. Triggers on: run vale, lint documentation, check style, fix prose, style edit, review doc, vale errors, documentation linting, markdownlint, markdown formatting, cspell, spell check.'
argument-hint: "Path to the Markdown file to lint and edit — for example: docs/how-to-deploy.md"
---

# Markdown lint and style edit

Runs a five-stage editing workflow on a documentation file:

1. **Markdown lint** — runs `markdownlint-cli2 --fix` to auto-correct formatting issues, then reports anything that couldn't be auto-fixed
2. **Vale lint** — lints prose with the Vale MCP server (or CLI fallback) and captures all errors, warnings, and suggestions
3. **Vale fixes** — edits the file to resolve vale errors only
4. **Spell check** — runs `cspell lint` to find spelling errors, fixes genuine misspellings, and adds valid technical terms to the project word list
5. **Style guide edit** — applies team style rules from [docs-style.instructions.md](../../instructions/docs-style.instructions.md)

Each stage runs in sequence. Fixing Markdown structure in Stage 1 first ensures vale lints clean, well-formed content. Stages 3 and 4 use separate context to prevent their rule sets from interfering with each other.

---

## Before running this skill

Confirm both linters are installed and configured before running this skill.

**markdownlint-cli2**: See [markdownlint-setup.md](./references/markdownlint-setup.md) for
installation and config instructions.

```shell
markdownlint-cli2 --version
```

**Vale MCP server or CLI**: This skill uses the Vale MCP server when available. Check whether
it is configured by typing `/` in Copilot Chat and looking for a tool with `vale` in its name
(typically `vale_lint` or similar). If the MCP server is not available, the skill falls back
to the vale CLI:

```shell
vale --version
vale sync
```

See [vale-setup.md](./references/vale-setup.md) for MCP server configuration and CLI setup
instructions.

---

## Stage 1: Fix Markdown formatting with markdownlint-cli2

Before running markdownlint-cli2, check the repo root for a markdownlint config file. Common
file names are `.markdownlint.yaml`, `.markdownlint.yml`, and `.markdownlint.json`. If one
exists, markdownlint-cli2 picks it up automatically — no extra flags are needed.

Run markdownlint-cli2 with the `--fix` flag. This auto-corrects the majority of Markdown
formatting issues in place — things like inconsistent heading levels, missing blank lines
around fenced code blocks, trailing spaces, and list indentation.

```shell
markdownlint-cli2 --fix <file>
```

After auto-fix, run markdownlint-cli2 again without `--fix` to see what remains:

```shell
markdownlint-cli2 <file>
```

markdownlint-cli2 reports remaining issues in this format:

```
<file>:<line>:<col>  <rule-name>/<alias>  <message>
```

For any issues that could not be auto-fixed, edit the file manually to resolve them.
See [markdownlint-setup.md](./references/markdownlint-setup.md) for guidance on common rules.

If no issues remain after auto-fix, proceed to Stage 2.

---

## Stage 2: Lint with the Vale MCP server

Use the Vale MCP tool to lint the target file and receive issues as structured data.

To find the tool name, type `/` in Copilot Chat and look for a tool with `vale` in the name —
it is typically called `vale_lint`. Call it with the target file path as the argument.

The MCP tool returns a structured list of issues. Each issue contains:

- `file` — path to the file
- `line` and `col` — location of the issue
- `severity` — `error`, `warning`, or `suggestion`
- `message` — description of the problem
- `rule` — the rule that fired (for example, `Google.Passive`, `Microsoft.Contractions`)

Severity levels, in order of priority:

- `error` — must fix; blocks publication
- `warning` — should fix; common style violations
- `suggestion` — consider fixing; minor improvements

Collect every issue and group by severity. Proceed to Stage 3.

If the tool returns no issues, skip Stage 3 and go directly to Stage 4.

> **CLI fallback**: If the Vale MCP server is not available, run the following command in a
> terminal and parse the plain-text output instead:
>
> ```shell
> vale --minAlertLevel=error <file>
> ```
>
> Vale reports issues in the format: `<file>:<line>:<col>  <severity>  <message>  <rule-name>`

---

## Stage 3: Apply vale fixes

Edit the file to address vale **errors** only. Ignore warnings and suggestions in this stage.

For each error:
1. Go to the reported line number
2. Read the rule name and message — see [vale-fix-guide.md](./references/vale-fix-guide.md) for how to interpret common rules
3. Edit the text to resolve the error
4. Don't change surrounding text unless it is necessary to fix that specific issue

After addressing all errors, run vale again to confirm the error count is zero:

```shell
vale --minAlertLevel=error <file>
```

If new errors appear, address those too before moving on.

Document which rules fired and how many errors were fixed. Include this in the final summary.

---

## Stage 4: Spell check with cspell

Run cspell to find spelling errors in the file:

```shell
cspell lint <file>
```

cspell reports issues in the format:

```
<file>:<line>:<col> - Unknown word (<word>)
```

For each flagged word, determine whether it is a genuine misspelling or a valid technical term:

- **Genuine misspelling**: Edit the file to correct the spelling.
- **Valid technical term or project-specific word** (falsely flagged): Add the word to the project word list instead of changing the text. Look for a `cspell.json`, `.cspell.json`, `cspell.yaml`, `.cspell.yaml`, `cspell.yml`, or a `words` array in `package.json` at the repo root. Add the word to the `words` array:

  ```json
  {
    "words": ["<word>"]
  }
  ```

  If no word list file exists, create `cspell.json` at the repo root with this structure:

  ```json
  {
    "version": "0.2",
    "words": ["<word>"]
  }
  ```

After making corrections and additions, run cspell again to confirm no errors remain:

```shell
cspell lint <file>
```

Document the number of misspellings fixed and the number of words added to the word list. Include this in the final summary.

---

## Stage 5: Apply the team style guide

With vale issues resolved, apply the team style rules from [docs-style.instructions.md](../../instructions/docs-style.instructions.md).

Work through these checks in order:

### Voice and person

- Change passive voice to active voice where the subject is known
- Change "users", "one", or "the user" to "you"

### Tense

- Change "will return" / "will create" (describing current product behavior) to "returns" / "creates"
- Keep future tense only for genuinely asynchronous or future events

### Word substitutions

| Replace | With |
|---------|------|
| `utilize` | `use` |
| `navigate to` | `go to` |
| `via` | `through`, `with`, or `using` |
| `e.g.` | `for example` |
| `i.e.` | `that is` |
| `please` | _(remove)_ |
| `alongside` (meaning "together with") | `together with` |
| `click` / `click on` | `select` |
| `do not` / `cannot` / `are not` | `don't` / `can't` / `aren't` |

### Headings

- Convert to sentence case
- Change -ing verbs at the start of task-based headings to bare infinitives: "Configuring the cluster" → "Configure the cluster"

### Code blocks

- Add language identifiers to any fenced blocks that are missing one (`shell`, `yaml`, `json`, `hcl`, `dockerfile`, `console`)
- Verify all placeholder values use angle brackets: `<cluster-name>`, `<namespace>`

### UI elements

- Bold UI element names: `**Save**`, `**Settings**`
- Replace non-descriptive link text ("click here", "here", "this page") with descriptive text

### Tables

Convert simple two-column tables that define a setting, property, parameter, option, flag,
endpoint, or similar item into a Markdown description list. A table qualifies if:

- It has exactly two columns (term and description)
- Each row defines or explains a single item
- The table has no meaningful need for alignment or comparison across rows

Replace the table with a description list in this format:

```markdown
`term`
: Description text.

`term`
: Description text.
```

Use inline code formatting for the term when it is a literal value (a flag, option name,
property key, or endpoint path). Use plain text when the term is a natural-language label.

Do not convert tables that compare multiple attributes across items, present numeric data,
or serve a purpose other than defining individual terms.

### DevOps terminology

- `k8s` → `Kubernetes` in body text
- `GitOps` (camelCase)
- `IaC` only after spelling out "infrastructure as code" on first use
- `CI/CD` only after spelling out on first use
- `container` not `Docker container` unless Docker-specific

---

## Final output

Return the fully edited file content.

After the file content, add an `## Edit summary` section with:
- Number of markdownlint issues auto-fixed and any that required manual edits
- Number of vale errors fixed
- List of vale rules that fired
- Number of spelling errors fixed and words added to the word list
- List of style guide corrections applied, by category
- Any `<!-- TODO: verify -->` comments added for items that need human review
