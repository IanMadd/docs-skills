---
description: "Structural template and guidelines for reference doc type pages."
---

# Reference doc

**Purpose**: Provides accurate, complete technical information designed to be scanned, not read top to bottom. Mirrors the structure of the application or system it documents. Avoid high-level instructions or usage guides---link to how-to guides instead.

````markdown
# <Title: subject and reference scope, or exact command name---"AWS CLI Command Reference" or "accessanalyzer">

One sentence describing what this reference covers.

## Syntax

`command [flags] <arguments>`

## Description

What the command, option set, or configuration does. Keep this concise.

## Options

`--flag`
: What it does.

  Type: string

  Default: `""`

`--required-flag`
: What it does.

  Type: int

  Default: required

## Examples

```shell
# Description of what this example does
command --flag <VALUE>
```

```shell
# Description of a second variation
command --flag <VALUE> --other-flag
```

## Related

- Link to related reference page
- Link to related how-to guide
````

**Guidelines**:

- Name the subject and, when useful, the reference scope or information type, such as a command
  reference, language reference, or support matrix. Use a noun phrase, not a task-based verb phrase.
- For a page that lists all commands, use the CLI name and a scope label such as "Command Reference".
  For a page about one CLI or command, the exact name alone can be the clearest title.
  Don't append "reference", "command", or "options" when it adds no useful distinction.
- Use sentence case for descriptive titles, but preserve official product names, established reference
  names, and exact command spelling and capitalization. These are examples of good reference titles:
  - "SQL++ for Query Reference" for a query language reference
  - "Office and Windows configuration support matrix" for a support matrix
  - "AWS CLI Command Reference" for the page that lists all AWS CLI commands
  - "accessanalyzer" for the accessanalyzer AWS CLI command
  - "gcloud" for the gcloud CLI
  - "az" for the az CLI
- Every flag, option, and parameter must be documented; include type and default
- Document each flag or option as a description list: the term is the flag in code font, and the
  definition starts with a one-line description followed by indented `Type:` and `Default:` lines
- Use `required` for the `Default:` value when there is no default value
- Examples must be present---at least two, showing different configurations
- Use active voice in descriptions: "Returns a JSON object" not "A JSON object is returned"
- Use description lists and bulleted lists to maximize scannability
- Maintain consistent structure, terminology, and tone across all reference pages
- Don't include step-by-step procedures---link out to how-to guides
