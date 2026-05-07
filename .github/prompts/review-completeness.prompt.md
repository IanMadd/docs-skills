---
description: "Review a doc for completeness, accuracy gaps, missing steps, undefined terms, and broken structure. Produces a section-by-section report with issue type and suggested fix, plus an overall readiness assessment."
name: "Review for completeness"
argument-hint: "Paste or attach the document to review"
agent: "agent"
---

Review the following documentation for completeness, accuracy, and structural integrity.
Assume the audience is DevOps engineers.
Use the standards in [docs-style.instructions.md](../instructions/docs-style.instructions.md) and the doc type structures in [doc-types.instructions.md](../instructions/doc-types.instructions.md).

**Document to review**:

$input

Evaluate the document against each checklist below and report your findings.

### Structure checklist

- Does the doc have a clear, descriptive title?
- Does it have an introductory sentence or paragraph?
- Are sections organized logically for the doc type?
- Is anything missing that the doc type template requires?

### Completeness checklist

- Are all steps present? Are any implied or skipped?
- Are prerequisites clearly stated?
- Are all commands and code examples present?
- Are placeholder values clearly marked with angle brackets?
- Is expected output shown where it would help verify success?
- Are there links to related docs where a reader would need them?

### Clarity checklist

- Are there undefined acronyms or jargon terms?
- Are there ambiguous instructions that could be interpreted multiple ways?
- Are there any steps where a reader might get stuck or confused?

### Code checklist

- Do all fenced code blocks have a language identifier?
- Are placeholder values clearly marked?
- Are commands runnable as written, with no obvious errors?

---

Return a report organized by section of the document.
Use this format for each issue:

> **[Section name]** — *[Issue type: Missing / Ambiguous / Incorrect / Incomplete]*
> Description of the issue and a suggested fix.

At the end, give an overall assessment on one of these three levels:
- **Ready to publish** — minor or no issues found
- **Needs minor edits** — issues found but none block publication
- **Needs major revision** — significant gaps, missing sections, or accuracy concerns
