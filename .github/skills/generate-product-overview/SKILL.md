# generate-product-overview Skill

**WORKFLOW SKILL** — Automate drafting product overview pages by extracting key product information from marketing materials and reference documentation, then generating a structured overview page based on the product overview doc type template. Use when you need to quickly create a product overview draft from existing source materials.

## Purpose

Generate a first-draft product overview page (`_index.md`) by analyzing provided marketing materials and reference documents. The skill extracts key product information (market problem, capabilities, use cases, components, requirements) and structures it according to the enhanced product overview doc type—focusing on core sections (introduction, diagram, use cases, components, install, next steps) without optional sections.

## When to use this skill

- **Create a product overview from scratch** when you have marketing materials, product documentation, or reference pages to work from
- **Draft quickly from multiple sources** — provide URLs to marketing pages, GitHub READMEs, API docs, sales materials, or local documentation files
- **Generate a foundation for editing** — the skill produces a structured draft with TODO markers so you can refine, expand, and personalize the content
- **Standardize product overviews** — ensures all product overviews follow the product overview doc type guidelines and best practices
- **Avoid starting from blank pages** — let the skill extract and organize key information so you focus on refinement

**Triggers**: "generate product overview", "draft product overview", "create product overview", "product overview from sources", "generate product page", "draft _index.md", "create overview from marketing"

## How to use this skill

### Step 1: Gather source materials

Collect links to source materials that describe the product:
- Marketing pages (product homepage, features page)
- GitHub README files
- API documentation pages
- Product documentation or user guides
- Sales collateral or product briefs
- Installation or getting started guides
- Any other public material describing the product

**Note**: Local files must be accessible in your workspace. Use full file paths (e.g., `/path/to/workspace/product/README.md`).

### Step 2: Provide links to the skill

When running the skill, you'll be prompted for a **bulk list of links**. Provide:
- One link per line
- URLs (https://...) or workspace file paths (/workspace/path/file.md)
- Mix of URLs and local files is fine

**Example input**:
```
https://example.com/product-marketing-page
https://example.com/features
https://docs.example.com/getting-started
/Users/you/workspace/product/README.md
https://github.com/your-org/product/wiki/Architecture
```

### Step 3: Skill validates and extracts

The skill will:
1. **Validate each link** — test URL accessibility, confirm local files exist
2. **Extract content** — fetch URLs using `fetch_webpage`, read local files using `read_file`
3. **Analyze for key information**:
   - Market problem or pain point the product solves
   - Product value propositions and benefits
   - Use cases and target scenarios
   - Key components or features
   - Target audience
   - Technical requirements or system requirements
   - Installation/setup information

### Step 4: Draft generation

The skill generates a product overview page with:

**Structure**:
- TOML front matter (with placeholders for `title`, `swiftype_search_products`, etc.)
- Introduction — market problem + product description
- Product diagram — placeholder with reference guidance
- When to use — extracted use cases (concrete, not abstract)
- Components — main product features/components
- Install — link to installation documentation
- Next steps — call to action to getting started
- Additional resources — placeholder structure for extensions

**Content**:
- Sections populated with extracted information from your sources
- Clear TODO markers (`<!-- TODO: ... -->`) for sections you need to complete or refine
- Concrete use cases instead of marketing language ("allows X to do Y" not "improves collaboration")
- No marketing buzzwords ("easy", "simple", "just")

### Step 5: Review and refine

The skill outputs:
- **Generated draft file** — saved to workspace as `_index.md` (or your specified filename)
- **Improvement suggestions** — based on product overview doc type guidelines
- **Next steps** — options to regenerate sections, edit specific areas, or finalize

After generation, you'll:
- Review the extracted content for accuracy
- Complete TODO sections with missing information
- Refine use cases to ensure they're concrete and specific
- Add real product names (replace "PRODUCT NAME")
- Customize front matter values for your documentation system
- Add the actual diagram (the draft provides a placeholder)

## What the skill outputs

### Generated file structure

```markdown
+++
title = "PRODUCT NAME Overview"
weight = 10
draft = false

[cascade]
  swiftype_search_products = ["PRODUCT"]

[menu]
  [menu.product]
  title = "PRODUCT NAME Overview"
  parent = "product"
  identifier = "product/PRODUCT NAME Overview"
  weight = 10
+++

# PRODUCT NAME Overview

[Introduction paragraph extracted from sources]

## Product diagram

<!-- TODO: Add diagram showing product architecture/components -->
Reference: https://developers.google.com/tech-writing/two/illustrations

## When to use PRODUCT NAME

[Use cases extracted from sources - concrete examples only]

## PRODUCT NAME components

### [Component 1]
[Description extracted from sources]

<!-- TODO: Link to component documentation -->

### [Component 2]
[Description extracted from sources]

<!-- TODO: Link to component documentation -->

## Install PRODUCT NAME

<!-- TODO: Link to installation documentation -->

## Next steps

<!-- TODO: Add call-to-action linking to getting started tutorial -->

## Additional resources

### Downloads
- <!-- TODO: Link to downloads page -->

### Learning
- <!-- TODO: Link to tutorials -->

### Support
- <!-- TODO: Link to support channel -->

### Community
- <!-- TODO: Link to community forum or discussion board -->
```

## Guidelines applied from product overview doc type

The generated draft follows these best practices:

✓ **Lead with the market problem** — introduction focuses on what problem the product solves
✓ **Concrete use cases** — use cases are specific scenarios, not abstract marketing language
✓ **Avoid marketing language** — no "easy", "simple", or "just"
✓ **Honest about complexity** — implementation effort is qualified by audience type
✓ **Scannable structure** — clear headings and bulleted lists
✓ **Proper TOML front matter** — includes `swiftype_search_products` cascade
✓ **Links not duplication** — references to full documentation rather than replicating content
✓ **TODO markers for clarity** — user knows exactly what still needs work

## What you need to do after generation

The generated draft is a **first pass**. You'll need to:

- [ ] Replace "PRODUCT NAME" with actual product name
- [ ] Update TOML front matter (`title`, `weight`, `swiftype_search_products`, menu structure)
- [ ] Review use cases — ensure they're concrete and accurate
- [ ] Flesh out component descriptions with links to their documentation
- [ ] Add an actual product diagram (or create a placeholder image)
- [ ] Fill in all TODO sections (install link, resources, etc.)
- [ ] Remove or collapse empty sections
- [ ] Verify content accuracy and tone against your product
- [ ] Add your product's GitHub repositories if public and relevant
- [ ] Customize the "Additional resources" section to match your docs structure

## Example workflow

**Scenario**: You're creating a product overview for an API called "DataFetch".

1. Gather sources:
   - Marketing page: https://example.com/datafetch
   - API docs: https://docs.example.com/datafetch/intro
   - GitHub README: https://github.com/your-org/datafetch#readme

2. Run the skill and provide those links

3. Skill extracts:
   - "DataFetch lets developers retrieve data from multiple sources without writing custom adapters"
   - Use cases: "Sync data from Salesforce to your data warehouse", "Pull metrics from monitoring tools"
   - Key components: HTTP API, CLI tool, SDKs for Python/Node/Go
   - Requirements: API key, Node 14+, Docker (for CLI)

4. Skill generates draft with:
   - Introduction mentioning the data sync problem
   - Use cases as concrete scenarios
   - Component sections for API, CLI, SDKs
   - TODOs for: diagram, full install link, getting started link, community resources

5. You review and:
   - Verify the extracted content is accurate
   - Add the architecture diagram
   - Link to real documentation pages
   - Refine use cases if needed
   - Remove or consolidate empty sections

## Tips for best results

- **Provide diverse sources** — marketing page + technical docs + README gives the skill more context
- **Include reference pages** — linking to feature lists, use cases, or architecture docs helps extraction
- **Use public URLs** — the skill works best with publicly accessible materials
- **Prepare local files** — if using workspace files, ensure paths are correct and files are readable
- **Review output for accuracy** — extracted content is a starting point; verify it matches your product
- **Concrete examples matter** — if sources have vague marketing language ("improves efficiency"), refine those during review

## Common pitfalls to avoid

- ❌ Providing only marketing pages (lacks technical depth) — include docs and README too
- ❌ Marketing language in sources ("easy to implement") — the skill will extract it; edit during review
- ❌ Abstract use cases in sources — refine these during review to be concrete scenarios
- ❌ Incomplete sources that lack component information — gather docs that describe product architecture
- ❌ Private GitHub repos or paywalled content — the skill can't access these sources

## Next steps after using this skill

1. **Edit the generated draft** using your editor or the Docs editing agent
2. **Run the docs-style-edit skill** to lint and style-check the final markdown
3. **Commit and deploy** the `_index.md` to your documentation site
4. **Link from parent pages** — update navigation or parent overview pages to reference your new product overview

## Related resources

- [Product overview doc type](https://link-to-doc-types-reference) — full template, guidelines, and best practices
- [Tom Johnson's product overview guide](https://idratherbewriting.com/learnapidoc/docapis_doc_overview.html) — comprehensive reference on writing effective product overviews
- [Good Docs Project: API Overview template](https://github.com/thegooddocsproject/templates/tree/master/api-overview) — community best practices
