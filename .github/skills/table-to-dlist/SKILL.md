---
name: table-to-dlist
description: 'Identify Markdown tables that define properties, parameters, options, flags, settings, endpoints, or other technical terms, then convert each qualifying table to a Markdown description list. Handles two-column and multi-column definition tables. Triggers on: convert tables, table to list, description list, definition list, dlist, convert table, table to description list, properties table, parameters table.'
argument-hint: "Path to the Markdown file to convert — for example: docs/reference/config-options.md"
---

# Convert definition tables to description lists

Scans a Markdown file for tables that define technical terms and converts each qualifying
table to a Markdown description list.

---

## Step 1: Identify qualifying tables

Read the file and find all Markdown tables. For each table, decide whether it qualifies for
conversion based on the criteria below.

### Tables to convert

A table qualifies if it:

- Defines or describes individual items — properties, parameters, options, flags, settings,
  endpoints, roles, permissions, environment variables, CLI arguments, or similar technical terms
- Has a first column that contains term names (the items being defined)
- Has a second column that contains a description, definition, or explanation of each term
- Additional columns contain supplementary attributes of each term (type, default, required, actions, and so on)

### Tables to leave unchanged

Do not convert a table if it:

- Compares multiple items across shared attributes where no single column is clearly "the term"
- Contains numeric or statistical data (benchmarks, counts, sizes)
- Is a lookup or mapping table without a primary term column
- Has merged cells or complex structure that would not survive a flat list format

If you are unsure, leave the table unchanged and add a `<!-- TODO: verify table conversion -->` comment above it.

---

## Step 2: Convert each qualifying table

Apply the appropriate conversion pattern based on the number of columns.

---

### Two-column tables

Use this pattern when the table has exactly two columns: a term column and a description column.

**Source:**

```markdown
| Option | Description |
|--------|-------------|
| `--verbose` | Enable verbose output. |
| `--dry-run` | Preview changes without applying them. |
```

**Output:**

```markdown
`--verbose`
: Enable verbose output.

`--dry-run`
: Preview changes without applying them.
```

**Rules:**

- The term goes on its own line with no leading punctuation.
- The description starts on the next line, prefixed with `: ` (colon space).
- Use a blank line between entries.
- Apply inline code formatting (backticks) to the term when it is a literal value: a flag,
  option name, property key, parameter name, environment variable, endpoint path, or command.
  Use plain text when the term is a natural-language label or role name.
- End each description with a period if it does not already end with one.
- Preserve any inline formatting (backticks, bold, links) that appears inside the original cells.

---

### Multi-column tables

Use this pattern when the table has three or more columns. The first column is always the term.
Remaining column values become labeled lines inside the description body, using the column
header as the label.

**Source:**

```markdown
| Name | ID | Actions |
|------|----|---------|
| Owner | owner | * |
| Project Owner | project-owner | iam:users:get, iam:users:list, applications:* |
```

**Output:**

```markdown
Owner
: ID: owner

  Actions: *

Project Owner
: ID: project-owner

  Actions: iam:users:get, iam:users:list, applications:*
```

**Rules:**

- The first column value is the term. Format it with backticks if it is a literal identifier;
  use plain text for natural-language labels.
- The second column value becomes the first description line, prefixed with
  `: <ColumnHeader>: <value>`.
- Each additional column value becomes a continuation line indented with two spaces, in the
  form `  <ColumnHeader>: <value>`.
- Separate each continuation line from the next with a blank line.
- Separate each complete description-list entry from the next with a blank line.
- If a cell is empty or contains only a dash (`-`), omit that line from the description body
  entirely.
- Preserve any inline formatting (backticks, bold, links) inside cell values.

---

## Step 3: Replace the table in the file

For each converted table:

1. Remove the entire original Markdown table (header row, separator row, and all data rows).
2. Insert the description list in its place.
3. Preserve any text, headings, or other content that appeared immediately before or after
   the table — do not shift or reflow surrounding content.
4. Ensure there is a blank line between the preceding paragraph (or heading) and the first
   description list entry, and a blank line between the last entry and the following content.

---

## Final output

Return the fully edited file content.

After the file content, add an `## Edit summary` section with:

- Number of tables converted
- For each converted table: its heading context (the nearest heading above the table) and
  whether it was two-column or multi-column
- Number of tables skipped and why (if any)
- Any `<!-- TODO: verify table conversion -->` comments added
