---
name: review-system-requirements
description: 'Review and edit customer-facing system requirements in installation and configuration documentation for clarity, structure, scannability, and consistency. Use the repository instructions and Good Docs Project installation-guide guidance. Do not verify technical claims or change requirement values. Triggers on: review system requirements, edit system requirements, clarify requirements, improve requirements, installation requirements, configuration requirements, prerequisites review.'
argument-hint: "Path to a Markdown file, file#heading, directory, or space-separated file list."
---

# Review system requirements

Review and edit customer-facing installation and configuration requirements for clarity,
structure, scannability, and consistency.
Use the repository's documentation instructions and the
[Good Docs Project installation guide](https://www.thegooddocsproject.dev/template/installation-guide)
as editorial guidance.

This skill doesn't verify whether requirements are technically correct, current, supported,
secure, or sufficient.
It doesn't research Kubernetes, cloud platforms, operating systems, runtimes, or product
compatibility.
It doesn't change versions, resource values, ports, endpoints, permissions, or other
technical requirement claims.

Use the `docs-style-edit` skill separately for a full markdownlint, Vale, cspell, and style
guide pass.

Don't modify target documentation until the user approves the proposed edits.

---

## Stage 0: Determine inputs and review scope

Accept one of the following targets:

- A Markdown file
- A section written as `<file>#<heading>`
- A space-separated list of Markdown files
- A directory containing Markdown files

If the target is missing or ambiguous, ask for it.

For a directory target, recursively collect Markdown files, but include only files that
contain requirement-like headings or are reached through the bounded expansion in Stage 1.
Requirement-like headings include:

- System requirements
- Requirements
- Prerequisites
- Before you begin
- Supported platforms
- Supported versions
- Hardware requirements
- Software requirements
- Network requirements

For a section target, review the named section through the next heading of the same or higher
level.
Still expand transclusions and directly related requirement links found in that section.

Before continuing, report:

- The primary target and selected section, if any
- Files initially in scope
- Whether related local content will be expanded
- That the review is editorial-only and doesn't verify technical claims

## Stage 1: Expand related local content

Build a review set that preserves the source location and ownership of every requirement.

### Resolve transclusions

Inspect the target content for local includes and transclusions, including repository-specific
shortcodes.
Common examples include Hugo `readfile` and `include` shortcodes and Jekyll or Liquid
`include` tags.

For each transclusion:

1. Resolve the path using the repository's content-root and shortcode conventions.
2. Read the included file.
3. Add its requirement content to the review set.
4. Record the included file as the owning source for findings and later edits.

Don't report an issue against the including page when the relevant text is owned by an
included file.

### Follow directly related local links

Follow a local Markdown link only when its link text, target path, or surrounding sentence
identifies it as requirement, prerequisite, supported-platform, install-option, or
configuration-dependency content.
Follow an anchor only within the linked section.
Don't crawl general navigation, conceptual background, or unrelated procedure links.

### Prevent cycles and uncontrolled expansion

- Normalize paths and track every visited file and section.
- Process each normalized target once.
- Stop a branch when it reaches content already visited.
- Limit expansion to three link or transclusion hops from the primary target.
- Report cycles, missing targets, unsupported shortcode syntax, and depth-limit truncation.
- Deduplicate repeated content while preserving every source location where wording differs.

Report the final review set before editing.

## Stage 2: Review requirements structure and wording

Read frontmatter as metadata, not requirement prose.
Review requirements found in headings, paragraphs, lists, tables, description lists, callouts,
and included files.

Use [requirements-checklist.md](./references/requirements-checklist.md).
Focus on whether a customer can quickly understand what the section covers, what they need to
prepare, and how the information is organized.

Review each requirement for:

- Clear subject and action
- Explicit required, recommended, conditional, or optional status when applicable
- Clear scope, such as deployment model, environment, topology, or node role
- Consistent terminology and capitalization
- Consistent units and formatting
- Unambiguous references to related sections or procedures
- Scannable presentation in a paragraph, list, table, or description list appropriate to the
  content
- A verification step when the source already provides one or the wording can be clarified
  without inventing a command

Flag unclear, repetitive, inconsistent, overly broad, or difficult-to-scan wording.
Don't decide whether a stated value or technical claim is correct.
Don't add missing technical facts from general knowledge.

## Stage 3: Draft editorial corrections

Propose the smallest changes that improve the supplied text.

Allowed corrections include:

- Reordering content for a clearer progression
- Splitting dense paragraphs into scannable lists
- Clarifying headings and introductory sentences
- Making required and optional conditions explicit when the existing text establishes them
- Defining an acronym at first use
- Standardizing terminology, capitalization, units, and formatting
- Removing repetition and resolving pronoun or referent ambiguity
- Improving link text and cross-reference wording
- Clarifying whether a documented value applies to a node, pool, topology, or deployment only
  when the existing text already provides that distinction
- Correcting grammar, voice, tense, and sentence structure according to the repository
  instructions

Do not:

- Verify or invalidate a requirement
- Replace a version, quantity, port, endpoint, platform, product, or permission
- Infer a supported platform, architecture, topology, security policy, or sizing value
- Add external citations as proof of technical accuracy
- Rewrite a technical statement merely because it seems unusual
- Run a separate technical research workflow

## Stage 4: Report proposed edits

Return a report in this order.

### Review scope

List the primary target, expanded files and sections, owning source files, cycles, unresolved
local targets, and the editorial-only limitation.

### Findings

Lead with the highest-impact editorial issues.
For each finding, include:

- Location in the owning source
- Existing wording or structural issue
- Editorial category, such as clarity, organization, consistency, scannability, terminology,
  or accessibility
- Why the issue may confuse or slow a customer
- Suggested wording or structural change

Don't label a technical claim as correct, incorrect, supported, current, stale, secure, or
complete.

### Summary

Provide compact counts by editorial category and severity.
Mention technical questions only as out of scope, without investigating or judging them.

### Edit decision

After presenting the report, ask whether the user wants to apply:

- All proposed editorial corrections
- Selected corrections
- No edits

Stop before editing until the user answers.

## Stage 5: Apply approved editorial corrections

Run this stage only after explicit user approval.

Edit only the owning source files and only the approved editorial changes.
Preserve frontmatter, shortcodes, anchors, links, technical values, and product terminology.
Don't modify unrelated prose.

After editing:

1. Re-read the changed requirements and their related pages.
2. Confirm that technical claims and values are unchanged unless the user explicitly approved a
   wording-only correction that preserves their meaning.
3. Repeat the focused structural and editorial checks from Stage 2.
4. Report corrections applied and any editorial issues that remain.
5. Recommend the `docs-style-edit` skill when the changed files need a complete lint and prose
   pass.
