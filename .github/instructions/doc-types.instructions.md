---
description: "Use when asking about doc structure, how to organize a document, or what sections to include. Covers structural templates for tutorials, how-to guides, reference docs, conceptual docs, release notes, and READMEs."
---

<!-- vale Microsoft.Quotes = NO -->
<!-- vale Microsoft.Contractions = NO -->

# Doc type structures

Source guidance: [The Good Docs Project](https://www.thegooddocsproject.dev/template/)

Each doc type's full template and guidelines live in its own file under
[doc-types/](doc-types/) so you only need to load the one doc type that's
relevant to your current task:

| Doc type | Purpose |
|----------|---------|
| [Tutorial](doc-types/tutorial.md) | Learning-oriented guided walkthrough with a working end result |
| [How-to guide](doc-types/how-to-guide.md) | Task-based procedure with a clear, specific outcome |
| [Workflow guide](doc-types/workflow-guide.md) | Cross-product outcome that connects existing product documentation |
| [Reference doc](doc-types/reference.md) | CLI commands, config options, API parameters; designed to be scanned |
| [Conceptual doc](doc-types/conceptual.md) | Architecture overviews, explanations, mental models |
| [Release notes](doc-types/release-notes.md) | Changes per version, grouped by type |
| [Product overview](doc-types/product-overview.md) | High-level product value and capabilities |
| [README](doc-types/readme.md) | Project and repository overview |

---

## Admonitions

This docs set renders notes, warnings, and danger callouts with Hugo shortcodes---never with
blockquote text like `> **Note:**`. Use this syntax anywhere a doc type calls for an admonition:

```markdown
{{< note >}}

Note text

{{< /note >}}
```

```markdown
{{< warning >}}

Warning text

{{< /warning >}}
```

```markdown
{{< danger >}}

Danger text

{{< /danger >}}
```

Use `note` for supplementary information, `warning` for actions that could cause unexpected
behavior, and `danger` for actions that risk data loss or a breaking change.

Use admonitions only when necessary. Too many notices on a page lose their visual
distinctiveness---see if you can convey the information in the surrounding prose instead.
Avoid grouping two or more admonitions together, such as back-to-back warnings or a note
nested inside a caution; if a page needs that, reorganize the content instead.

