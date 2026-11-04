# Chef platform overview research profile

Use this optional profile with [generate-research-doc](../SKILL.md) when researching the Chef portfolio for a platform overview.
It adds evidence requirements, not a separate collection workflow.
Keep the parent skill's source prefixes, failure handling, read-only policy, citations, and output-path rules.
Don't apply this structure to unrelated research requests.

## Determine scope

Confirm the research topic, relevant date or release context, product list, sources, and output path.
The initial product list is Chef 360 Platform, Chef Automate, Chef Infra Client, Chef Workstation, Chef Habitat, and Chef InSpec.
Ask before adding products to the main scope; record necessary external dependencies as context.
Use the existing `web:`, `repo:`, `pr:`, `confluence:`, and `jira:` input prefixes.
Sources can include documentation, marketing pages, blogs, and local repositories.
If no sources are supplied, follow the parent skill's request for sources rather than filling gaps from memory.

## Gather evidence

Record the following for each source:

- Title, original URL or file locator, and source type.
- Products and claims it covers.
- Publication or update date when available, retrieval date, and applicable version or edition.
- Whether it's public, internal, or of unknown publication status.
- Access failures or missing date and version information.

Use current, applicable technical documentation to check behavior, requirements, and integrations.
Use marketing pages for positioning and intended outcomes, and dated blog posts for examples and historical context.
Don't assume the newest source is applicable to every edition or deployment.
When sources disagree, compare their scope and dates, cite both, and preserve unresolved disagreements.
Never convert announced or planned functionality into a released capability.

## Build the product inventory

For every in-scope product, record its canonical name, purpose, audience, capabilities, concrete use cases, and supported benefits.
Include deployment choices, material limitations, requirements, licensing or edition conditions, and authoritative overview and adoption links when sources provide them.
Cite every factual statement to its original source, not merely another summary.
Make missing evidence visible for each product rather than omitting that product silently.
Don't invent adoption effort, pricing, lifecycle status, implementation timelines, or compliance guarantees.

## Build the relationship evidence record

Record each candidate relationship separately, using a table or repeated entries with these fields:

- Source product and destination product, or the portfolio grouping when there is no technical connection.
- Relationship type: portfolio association, integration, dependency, optional combination, or alternative.
- Direction, artifact or data exchanged, and each product's role when applicable.
- Whether the relationship is required, optional, or unknown.
- Applicable versions, editions, deployment models, and current or historical context.
- Original evidence locator and a concise explanation of what it establishes.
- Verification state: supported, conflicting, or unverified.

Shared branding isn't evidence of integration.
Missing integration evidence doesn't prove that a product operates independently.
Describe standalone use only when evidence confirms it.
Don't assume a shared control plane, installer, license, or dependency across the portfolio.
Don't turn an optional combination into a mandatory sequence.

## Synthesize scenarios and diagram inputs

Describe concrete reader problems and the products that address them, with evidence for each role and outcome.
Separate verified scenarios from hypothetical or incomplete ones.
Identify useful capability groupings without hiding product names or implying unsupported dependencies.

Prepare diagram inputs from supported relationships only.
Include actors, products, meaningful boundaries, connection labels, and conditions.
Explain the intended takeaway in a short diagram brief.
Don't produce an architectural arrow from portfolio membership or an unresolved relationship.

## Assemble the report

Retain the parent skill's sources reviewed, gaps and open questions, and deduplicated sources sections.
Include the product inventory, relationship evidence record, concrete scenarios, diagram inputs, and adoption considerations as research themes.
Add a dated summary of source coverage for every in-scope product.

For each conflict or gap, identify the affected claim, sources, applicable conditions, and the question that needs resolution.
Flag critical issues that prevent explaining a product's purpose or a claimed integration accurately.
Distinguish unknown, unsupported, historical, and confirmed information; unknown doesn't mean false.
Keep the report detailed enough to support drafting without making the customer-facing overview equally long.

## Hand off to drafting

Pass the report path and review summary to [generate-platform-overview](../../generate-platform-overview/SKILL.md).
Preserve original public link targets for useful links in the draft.
Keep claim-level provenance and private source locators in the research report, outside publishable content.
Internal sources can inform authorized research, but publishing their facts requires explicit approval or public corroboration.
Never expose private links or confidential details in the customer-facing page.

If research remains incomplete, report what succeeded, which sources failed, and what needs review.
Allow a research-only checkpoint before recommending page scope or drafting.
