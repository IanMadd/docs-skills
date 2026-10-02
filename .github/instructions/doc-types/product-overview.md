---
description: "Structural template and guidelines for product overview doc type pages."
---

# Product overview

**Purpose**: Provides a high-level description of a product's value, capabilities, and use cases. This is often the entry point for developers, managers, and executives evaluating a product. Helps readers understand what the product does, why they might use it, and where to find additional resources.

Product overview pages combine information that overlaps with marketing and READMEs, but focus on linking readers to relevant documentation resources within your product ecosystem.

# PRODUCT NAME Overview

Introductory paragraph(s) explaining what the product is, what it does, what problems it solves, and the benefits to the user.
This content will overlap with marketing for this product.
For example, see the [AWS Lambda marketing page](https://aws.amazon.com/lambda/features/) and the [AWS Lambda documentation page](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html).

## Product diagram

Include a basic diagram showing how the product works and how components connect at a high level.
Reference the [Google guide to documentation illustrations](https://developers.google.com/tech-writing/two/illustrations) for design guidance.
See [Azure Analysis Services](https://learn.microsoft.com/en-gb/azure/analysis-services/analysis-services-overview) and [Azure Cognitive Search](https://learn.microsoft.com/en-gb/azure/search/search-what-is-azure-search) for diagram examples.

## When to use PRODUCT NAME

Describe the use cases for this product, with one use case per major benefit.
Reference [Jira's list of use cases](https://www.atlassian.com/software/jira/guides/use-cases/what-is-jira-used-for) as an example.
See [Azure Cognitive Search use cases](https://learn.microsoft.com/en-gb/azure/search/search-what-is-azure-search#why-use-cognitive-search) for additional guidance.

### (Optional) Intended audience and prerequisites

Identify who this product is for, what technical level is assumed, and any prerequisites or background knowledge readers need.
Include links to preparatory documentation if readers need to learn concepts before using this product.

### (Optional) Key differentiators

Highlight the unique capabilities or features that distinguish this product in the market and address specific user pain points.
Focus on what makes this product a good fit for its intended audience.

### (Optional) Technical requirements and limitations

List system requirements (OS, memory, storage), geo-availability, licensing constraints, and knowledge prerequisites.
Document what this product does NOT do or scenarios it doesn't support to prevent users from discovering limitations after committing to the product.

### (Optional) Development effort and scope

Provide realistic guidance on implementation complexity and time investment required.
Avoid using words like "easy" or "simple."
Instead, qualify effort by audience type and experience level.
For example: "For seasoned engineers familiar with X, implementation typically requires one week.
For new users unfamiliar with X, allow several months for learning and integration."

## PRODUCT NAME components

### Component name

Include an H3 heading for each main component or feature.
Provide one or more paragraphs summarizing what the component is, what it does, and how it relates to the overall product.
Include links in the text to documentation for each component.

### Another component

Repeat the pattern above for each component.

## Install PRODUCT NAME

Add a link to installation documentation and any relevant system requirements.

## Next steps

Provide a brief paragraph or a few sentences guiding readers to the next steps for using this product.
Include links to getting started tutorials and documentation for downloading, installing, and configuring the product.

## Additional resources

### Downloads

- Chef Downloads page for the product

### Learning

- Chef webinars for the product
- Learn Chef tutorials for the product

### Support

- Chef Help Center for the product

### Community

- Section on Chef Discourse for the product
- Section in the Chef Blog for the product

### GitHub repositories

Include links to repositories that advanced users might want to explore.
This could include the main product repository, resource repositories, or on-premises repositories.
```

**Guidelines**:
- The product overview page is often the only documentation page that executives will see---prioritize clarity for all audience levels
- Lead with the market problem or pain point the product solves before describing features or benefits
- Include a product diagram whenever possible to show how components connect
- Make use cases concrete and specific; avoid abstract descriptions like "improves collaboration" or "increases efficiency"
  - Good example: "X product allows writers to simultaneously edit the same document in a browser without installing software"
  - Weak example: "X product helps teams work together more effectively"
- Each use case should map to a distinct product benefit; avoid overly long use case lists
- Link component sections directly to their detailed documentation pages
- Keep introductory paragraphs to one or two paragraphs; avoid dense walls of text
- Follow the file path convention: use `_index.md` in the product subdirectory (for example, `content/habitat/_index.md`)
- Use TOML front matter format and include the `swiftype_search_products` cascade to enable search
- Don't duplicate information that lives in linked documentation---link instead
- Keep the page scannable with clear headings and bulleted lists for resources
- Include only public repositories; exclude private repositories from the GitHub repositories section
- Omit the GitHub repositories section if no public repositories are accessible
- Avoid marketing language like "easy," "simple," or "just"; instead qualify implementation effort by audience type and experience level
- Be honest about implementation complexity; what is straightforward for one audience may be challenging for another
- If marketing content already exists for this product, link to it rather than duplicating; alternatively, create a more technical version focused on implementation
- Optional sections (Intended audience, Key differentiators, Technical requirements, Development effort, Most popular topics) can be excluded if not relevant to your product
- Don't include step-by-step procedures in the overview---link to getting started tutorials or how-to guides instead
