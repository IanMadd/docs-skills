---
description: "Structural template and guidelines for workflow guide doc type pages."
---

# Workflow guide

**Purpose**: A specialized how-to guide for an outcome that spans two or more independently versioned products or documentation sets. A workflow guide doesn't replace product documentation---it connects existing tutorials, how-to guides, reference docs, and conceptual docs into one coherent end-to-end process. Based on [narrative workflow topics](https://idratherbewriting.com/2013/09/12/narrative-workflow-topics-helping-users-connect-the-dots-among-topics/).

A standard how-to guide solves one task inside one product. A workflow guide orchestrates multiple products toward one business or operational outcome, linking out to each product's own documentation instead of reproducing it.

```markdown
# <Title: outcome-oriented bare infinitive---"Audit and remediate infrastructure compliance">

This guide explains how to <outcome>, coordinating <Product A>, <Product B>, and <Product C>.
One or two sentences stating the overall goal and why a reader would follow this workflow.

## Before you begin

- Link to setup or prerequisite documentation for each product involved
- Note any product versions or editions required for the workflow to work end-to-end

## Workflow

A short paragraph describing the end-to-end flow before the numbered list---what moves between
products and in what order.

1. <Step---bare description of the action>. See [<Product> documentation](<link>) for how to
   <action>.
1. <Step>. See [<Product> documentation](<link>) for how to <action>.
1. <Step that happens automatically or as a result of a prior step, with no linked procedure>.
1. <Decision point>: if <condition>, do <alternative path>; otherwise, continue to the next step.

## Expected outcome

Describe what the reader should observe when the workflow completes successfully.

## Next steps

- Link to a related workflow guide
- Link to the conceptual doc explaining how the involved products fit together

## See also

- Link to each product's reference documentation used in this workflow
```

**Guidelines**:

- A workflow guide spans two or more products, services, or independently versioned
  documentation sets; if the task stays inside one product, write a standard how-to guide instead
- State the overall outcome in the title and opening paragraph, and name every product involved
- Explain why each step exists and how an artifact (a profile, a cookbook, a report, a policy)
  moves from one product to the next---this connective narrative is the guide's entire value
- Link to the authoritative tutorial, how-to guide, or reference page for each step instead of
  documenting the step's implementation; add
  `<!-- TODO: link to [product] documentation for [step] -->` where a target page doesn't exist yet
- Don't reproduce API reference, CLI reference, resource reference, or other product reference
  content---link to it
- Don't embed complete code examples, cookbook recipes, or InSpec profiles; keep any inline
  example short, generic, and version-neutral, illustrating the concept rather than a working
  implementation
- Minimize version-specific detail---describe behavior that holds across supported versions of
  each involved product; link to the product's own docs for version-specific syntax
- Call out decision points explicitly with conditional imperatives ("If `<condition>`, do
  `<alternative step>`"), matching how-to guide step structure
- Describe the expected outcome at the end so the reader can confirm the workflow succeeded
  end-to-end, not just that one product's step succeeded
- Workflow guides live in a separate "Solutions" or "Workflows" area of the docs set, not inside
  any single product's directory---don't file a workflow guide under a product-specific path
- Review and update a workflow guide whenever a linked product's documentation restructures or
  renames pages---broken links in a workflow guide break the entire cross-product journey
