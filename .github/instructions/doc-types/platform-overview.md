---
description: "Structural template for Chef platform overviews: multiple products, their roles and relationships, adoption considerations, and next steps for decision-makers and engineers."
---

# Platform overview

**Purpose**: Explain what the Chef portfolio provides, which products address a reader's needs, how the products relate, and where to start.
Serve business decision-makers, engineers, and people new to Chef.
Don't assume familiarity with Chef terminology, even when readers know the technical domain.

## Boundaries

- A platform overview explains multiple products and their relationships.
- A [product overview](product-overview.md) explains one product's value and capabilities.
- A [workflow guide](workflow-guide.md) connects procedures into a cross-product outcome.
- A [conceptual doc](conceptual.md) explains a technical topic in greater depth.

Define what "platform" means for the page.
Don't equate the entire Chef portfolio with Chef 360 Platform or imply that all products belong to one installation, subscription, or control plane.
The initial scope includes Chef 360 Platform, Chef Automate, Chef Infra Client, Chef Workstation, Chef Habitat, and Chef InSpec.
Confirm additions or exclusions before drafting.

## Core structure

Use the following sections as an editorial template, not as instructions to reproduce empty headings.
Adapt headings to the reader's questions and include only supported content.
In Hugo, use TOML front matter and existing menu and search conventions from the destination repository.
Don't add a Markdown H1 when the layout already renders the page title.

### Introduction

Use one or two paragraphs to identify the problem, explain what Chef provides, and define the portfolio's scope.
Connect business value to concrete capabilities instead of unsupported promises about efficiency, security, or cost.
Define unfamiliar terms or link to a short explanation.

### What you can do with Chef

Describe a small set of concrete scenarios.
For each scenario, identify the reader's problem, the relevant products and their roles, and the supported outcome.
Link to existing product overviews or workflow guides for detail.
Don't turn scenarios into installation instructions or imply that every scenario requires every product.

### How the products fit together

Explain verified relationships in prose and, when evidence supports it, a high-level system landscape diagram.
Distinguish portfolio membership, technical integration, optional combinations, required dependencies, and alternatives.
Only describe standalone use when sources confirm it; missing integration evidence doesn't prove independence.
State material edition or version conditions and link to their authoritative documentation.

Give the diagram a single takeaway, label meaningful connections, and explain it in the surrounding text.
Include alt text, a caption, and a text equivalent for important relationships.
Don't invent arrows or make a product name imply a particular architectural boundary.
When evidence or an approved asset is missing, leave a diagram brief in the draft's review notes instead of a broken image link.

### Products and their roles

Provide a concise, consistent summary for each in-scope product:

- What the product does and who uses it.
- When to choose it and which supported outcome it enables.
- How it relates to other products, including optional or required dependencies.
- Where to find its authoritative overview and getting started documentation.

Use an H3 for each product in Markdown mode.
Group by reader need or capability when helpful, but keep canonical product names visible.
Don't reproduce detailed feature lists, API references, or existing product overviews.

### Adoption considerations

Explain material deployment choices, dependencies, limitations, and licensing or edition conditions only when supported by current, applicable sources.
Link to detailed requirements, installation instructions, and pricing rather than maintaining copies.
Describe the skills and work involved without calling adoption easy or inventing implementation timelines.
Don't imply that using a product guarantees compliance with a security standard.

### Where to start

Offer clearly labeled paths for evaluating the portfolio and beginning hands-on work.
Connect each path to a reader goal and a verified destination.
Don't prescribe a mandatory installation sequence for the entire portfolio.
Add support resources or a short glossary only when they help readers make the next decision.

## Single-page and multipage output

Keep one page when concise scenarios, product roles, relationships, and next steps remain readable together.
Recommend companion pages only when a distinct reader question needs substantial explanation, such as product selection or a relationship model.
Don't create one page per product automatically; link to existing product overviews.

Before writing, propose the page paths, titles, purpose, source coverage, and links between pages.
Get approval for the scope, especially new companion pages or changes to existing published paths.
Keep the main overview useful without requiring readers to open every companion page.

## Sources and review

Use the [platform research profile](../../skills/generate-research-doc/references/platform-overview.md) to record detailed evidence before drafting.
Use marketing for positioning, technical documentation for applicable behavior, and dated blog posts for examples and historical context.
Investigate conflicting claims rather than silently selecting a source by type.
Don't present roadmap items, historical integrations, or unsupported benefit claims as current behavior.

Keep claim-level citations and unresolved questions in the research report.
Use natural, descriptive documentation links in the customer-facing page.
Never expose private source URLs or unapproved internal information in published content.
Keep unresolved noncritical gaps in draft review notes; block claims that depend on unresolved critical conflicts.

Request product or engineering review of relationships, terminology review with product marketing, and a comprehension review by a newcomer or business reader.
Record the research date and remaining review needs outside the published prose.
Recheck the page when product positioning, availability, or integrations change materially.

## Output modes

Use `markdown` by default, `cards` on request, or `compare` to prototype alternatives before choosing a presentation.
These modes don't change the source requirements or single-page and multipage scope rules.

- `markdown`: Use product headings, descriptions, and related links without card shortcodes.
- `cards`: Use prose with approved card-based sections for products, components, features, benefits, or starting points.
- `compare`: Use a separate unpublished prototype containing paired Markdown and card alternatives for selected sections.

### Comparison prototypes

Keep the same wording, order, and link destinations in each alternative so reviewers compare presentation rather than different drafts.
Show each section's Markdown alternative followed by its card alternative, without duplicating the entire overview.
Use distinct H2 headings such as "Products: Markdown" and "Products: Cards" and unique explicit anchors.
Keep shared relationship explanations and adoption considerations outside the paired alternatives.

Approve the prototype path and selected sections before writing.
Don't replace the main overview, register the prototype in navigation, or copy both alternatives into the final page.
For a Hugo prototype, use `draft = true` and exclude it from publication, including builds that publish drafts.
If preview tooling is unavailable but shortcode definitions are available, save a source-only comparison outside the Hugo content tree and report the rendering limitation.
If shortcode support is unknown, request the definitions or approval for Markdown-only output rather than inventing syntax.

After review, select an alternative for each section; the final page can mix Markdown and card-based sections.
Update the final page and retain or remove the prototype only with authorization.
VS Code's standard Markdown preview doesn't render Hugo shortcodes; use the Chef Hugo theme for a visual comparison.
Code fences alone don't prevent Hugo shortcode processing.

### Chef card rules

Use `cards`, `card`, and `card_links` in `cards` or `compare` mode only when supported by the destination theme.
Inspect the shortcode implementations and a nearby example before generating syntax.

- Use `cards` as the grid wrapper with a supported column count; the current Chef theme supports 2, 3, or 4.
- Use `card` for one linked product, component, feature, or benefit with a concise description.
- Use `card_links` for a linked heading and an inner Markdown list of related destinations.
- Supply a meaningful title and a verified link for every card; don't emit placeholder destinations.
- Put grids below an H2 because the current theme renders card titles as H3 headings.
- Keep relationship explanations outside cards and preserve the same meaning in Markdown mode.
- Don't nest cards or put links inside a single-link card description.
- Use only supported parameters, valid Hugo string quoting, and verified icons when needed.
- Use destination paths in shortcode link parameters, not nested reference shortcodes.

Cards help readers scan and choose a destination; they don't replace the explanatory narrative.
If the theme doesn't support them, explain the limitation and use headings, prose, and links.

## Source guidance

This template synthesizes editorial guidance rather than adopting a universal platform-overview standard:

- [API product overviews](https://idratherbewriting.com/learnapidoc/docapis_doc_overview.html): mixed audiences, concrete scenarios, realistic adoption considerations, and marketing overlap.
- [AWS overview](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/introduction.html): platform context followed by linked capability categories.
- [Diataxis explanation](https://diataxis.fr/explanation/): context and connections, separate from procedures.
- [C4 system landscape diagrams](https://c4model.com/diagrams/system-landscape): relationships across multiple software systems for technical and nontechnical audiences.
- [Google illustration guidance](https://developers.google.com/tech-writing/two/illustrations): focused, readable diagrams with clear takeaways.
- [Progressive disclosure](https://www.nngroup.com/articles/progressive-disclosure/): concise entry points with clearly labeled paths to detail.
