---
name: review-page-titles
description: "Review a Markdown page's documentation type, update its page and menu titles to match the doc-type title guidance, and rename the Markdown file to match the page title when necessary. Triggers on: review page titles, fix page title, menu title, navigation title, title by doc type, rename Markdown file, filename consistency."
argument-hint: "Path to one Markdown file"
---

# Review page titles

Review one Markdown page, infer its documentation type from its content, and update its page title,
menu labels, and filename only where necessary.
Keep compliant titles and filenames unchanged.
Don't restructure the page or rewrite its body as part of this skill.

## Inputs and scope

- Use the supplied file path, or the active Markdown file if the request clearly refers to it.
  Ask for a path if neither identifies one file.
- Read the target repository's instructions and naming conventions before editing.
  Preserve unrelated edits already present in the working tree.
- Limit changes to the target page and references or navigation entries directly affected by its title
  or filename change. Don't commit, push, or publish changes.

## Identify the documentation type

Read the entire page, including its frontmatter and headings.
Classify it by its primary purpose, not by its existing title or filename:

- **How-to guide**: Complete one specific task; assumes practical knowledge.
- **Workflow guide**: Complete a cross-product outcome through connected procedures.
- **Tutorial**: Learn through a guided walkthrough with a working result.
- **Conceptual doc**: Understand concepts, architecture, or a mental model.
- **Reference doc**: Look up commands, syntax, settings, parameters, or compatibility information.
- **Product overview**: Evaluate a product's value and capabilities.
- **Release notes**: Review changes by version.
- **README**: Understand a project or repository and get started.

If the body comes from a shortcode, include, or generated data, read the referenced source needed to
understand the page's subject and scope.
Don't edit generated outputs; identify the editable source or report the limitation instead.
If the page mixes types, choose its dominant purpose and explain the choice.
If no dominant purpose is clear, ask the user to choose a type before editing.
Don't silently convert the page into a different type.

Load the matching template through [doc type structures](../../instructions/doc-types.instructions.md).
For installed copies, resolve this entrypoint from the target repository or the installed user
instructions, then load the matching file in its `doc-types/` directory.
If the guidance is unavailable, ask for its location rather than inventing title rules.
Treat the loaded template as the source of truth; the classification table isn't a title template.

## Review the page title

Identify the title actually used by the site's renderer: usually frontmatter `title`, a body H1,
or both. Inspect the nearest template or neighboring page when precedence is unclear.

- Apply the selected doc type's title rules to the page's actual subject and scope.
  For example, a how-to title starts with a bare infinitive, and a conceptual title uses a noun phrase.
- For reference pages, use the reference template's rules for descriptive titles, command indexes,
  and exact CLI or command names. Don't force every reference title to end with "reference".
- Use sentence case while preserving official names, acronyms, and exact command spelling.
  Don't add unsupported claims, subjects, or scope to make a title sound more complete.
- Update frontmatter `title` and an existing H1 that serves as the same page title consistently.
  Don't change unrelated H1s, headings in code examples, or version headings in release notes.
- If only an H1 supplies the title, update that H1 without adding frontmatter just for this skill.
  Don't add a duplicate H1 when the site renders a frontmatter title automatically.

## Review the menu title

Find the target page's existing navigation labels using the repository's actual schema.
Common locations include `linkTitle`, `sidebar_label`, `nav_title`, YAML `menu` entries,
TOML `[menu.<NAME>]` or `[[menu.<NAME>]]` entries, and a separate navigation configuration.
Don't assume every `name` field is a page label.
Use stable identifiers, page references, or paths to identify external navigation entries, not a
title-text match alone.

- Use a shorter version of the page title when it remains clear within its menu context.
  Remove redundant context before removing words that identify the task or subject.
- Keep the type-appropriate phrasing: retain the action in a how-to label and the subject in a
  conceptual or reference label. Preserve command names exactly.
- Keep the full title when shortening it creates ambiguity or duplicates a sibling label.
  Don't impose an arbitrary character limit.
- Update existing labels that name this page, including multiple menu entries when applicable.
  Preserve menu identifiers, parents, ordering weights, and unrelated navigation labels.
- If navigation falls back to the page title, add a shorter label only when the repository supports
  an established label field and the shorter label is useful. Otherwise, leave the fallback intact.
  Don't create a menu entry for a page that isn't in navigation.

## Align the filename and references

Derive the filename from the final page title using the repository's naming conventions.
If no convention exists, use a lowercase, hyphen-separated slug and preserve the Markdown extension.
Remove punctuation that isn't valid in the repository's slugs, collapse repeated separators, and
retain meaningful words, command names, version numbers, and required locale suffixes.

- Leave a filename unchanged if it already matches the title under those conventions.
- Preserve convention-required names such as `index.md`, `_index.md`, and `README.md`.
  Report these as exceptions rather than breaking site routing or repository discovery.
- Check for destination collisions, including case-insensitive collisions on macOS and Windows.
  Never overwrite another file. Ask for a distinguishing title or filename if there is a collision.
- Before renaming, inspect explicit `slug`, `url`, `aliases`, and permalink rules, plus any matching
  navigation entries, relative links, Hugo references, includes, or scripts in the target repository.
  Determine whether the filename change also changes the published URL.
- Preserve explicit URLs and stable menu identifiers by default. If a published URL changes, use the
  repository's established alias or redirect mechanism to preserve the old URL.
  If no supported mechanism is available, ask for approval of the URL change before renaming.
  Don't add speculative redirects or change public URLs just to match a title.
- Rename within the same directory. Don't move assets or reorganize directories.
  Update directly affected local links, page references, and navigation paths in the same change.
  Preserve link fragments; if an H1-derived fragment changes, update affected local fragment links too.
- Search for both the old source path and any old route or basename used by the site's reference
  syntax. Inspect each match in context; don't replace unrelated pages with the same basename,
  historical text, or external links blindly.
  Report external backlinks that can't be verified or updated locally.

## Apply and verify

Explain the inferred type and proposed title, menu label, and filename changes before editing.
Apply the local changes unless a specific ambiguity, collision, or URL risk requires confirmation.
Preserve YAML or TOML syntax, quoting, comments, and unrelated metadata.
Use a structured parser to validate frontmatter when one is available; don't reserialize the entire
document if that changes unrelated formatting.

After editing, complete these checks:

- Confirm that the rendered page title and each menu label still identify the same subject and
  conform to the selected doc type's guidance.
- Confirm that the renamed file exists, the old source path is absent, and affected local references
  resolve. For unchanged files or naming exceptions, confirm why no rename was needed.
- Check that no stale actionable references remain to the old path or changed heading fragment.
  Confirm that menu identifiers and hierarchy are unchanged.
- Run the repository's available Markdown, frontmatter, link, and build checks scoped to the changed
  files where supported. Inspect the diff for unrelated edits and whitespace churn.
- Review a second time: applying the skill again should propose no further changes.

## Report

Report the inferred doc type with a brief reason, followed by the old and new page title, menu
label or labels, and filename. Mark values that were already compliant as unchanged.
List affected references, preserved URLs or added redirects, naming exceptions, validation results,
and any checks that weren't available. Don't claim a rendered-page or link check passed unless run.
