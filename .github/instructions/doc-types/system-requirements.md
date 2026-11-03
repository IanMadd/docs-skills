---
description: "Structural template and guidelines for system requirements sections, standalone pages, and multi-page requirements sets, including links to preparation and verification guides."
---

# System requirements

**Purpose**: A specialized reference type that helps readers determine whether their environment meets the conditions for installation or deployment.
Use this guidance for a short requirements list, a standalone requirements page, or a multi-page requirements set.
Unlike a command reference, system requirements don't need syntax, option defaults, or a minimum number of examples.

## Requirements, preparation, and verification

Distinguish these three reader needs:

| Content      | Reader's question        | Format                                |
| ------------ | ------------------------ | ------------------------------------- |
| Requirements | What must be true?       | Bullets, tables, or description lists |
| Preparation  | How do I make it true?   | A how-to procedure                    |
| Verification | How do I know it's true? | Checks with expected results          |

State the required condition in the requirements reference.
For example, a requirement might state that each host needs a unique machine ID.
A preparation procedure explains how to assign unique IDs, and verification explains how to check that the IDs differ.

Use the [how-to guide template](how-to-guide.md) for substantial preparation and verification procedures.
Don't apply a requirements-only structure to a configuration guide merely because it lives in a requirements directory.

## Choose the structure

Use the smallest structure that gives readers the information they need.
The following patterns are alternatives, not mandatory sections for every page.

### Requirements section

Use a section within an installation or configuration guide for a short, uncomplicated set of requirements.
Introduce its scope, then use an unordered list.
Don't add category headings when one list is easier to scan.

```markdown
## System requirements

These requirements apply to the deployment model described in this guide.

- State a hardware requirement and whether it applies per host or per deployment.
- State a software requirement and its applicable version or platform.
- State a conditional requirement, starting with the condition.
```

### Standalone requirements page

Use a standalone page when several categories need explanation or readers need a reusable reference.
Name the product, component, or deployment model in the title, such as "Embedded cluster requirements" or "Linux host requirements".

```markdown
# System requirements for the deployment

State which product version, deployment model, topology, or node roles this page covers.
Link to requirements for other deployment models when readers need to choose between them.

## Hardware

List resource requirements, distinguishing minimum and recommended sizing where documented.
State whether each value applies per host, per node role, or across the deployment.

## Software and supported platforms

List supported operating systems, architectures, versions, and dependencies as documented.

## Network and storage

State the required connectivity and storage conditions.
Link each substantial preparation task directly from the relevant requirement.

## Verification

Include documented checks and expected results, or link to a readiness-check guide.
Omit this section if verification is already provided with each requirement.

## Next steps

Link to the installation or deployment guide to follow when the applicable requirements are met.
```

Hardware, software, supported platforms, storage, networking, DNS, security, permissions, and licensing are possible categories, not required headings.
Include only categories relevant to the documented environment.
Put shared requirements before deployment-specific additions, and state whether those additions supplement or replace shared requirements.

### Multi-page requirements set

Use an overview page with linked references when requirements are extensive or vary substantially by deployment model, topology, platform, or node role.
Don't split every category into a separate page automatically or use page length as the only reason to split.

The overview is the readiness entry point, not just a directory of links.
It should establish applicability, present shared requirements or link to their owning references, and identify conditional requirements.
A compact table can help readers find requirements, preparation procedures, and verification for each area.
Don't add empty columns when those resources don't exist.

Give readers an explicit path through the set:

1. Identify the applicable deployment model, topology, and connectivity model.
1. Review shared requirements and applicable detailed references.
1. Follow preparation links for conditions the environment doesn't meet.
1. Run documented readiness checks and compare the results with the expected results.
1. Continue to installation or deployment.

Link detailed references back to the overview.
Link preparation guides to the requirement they satisfy, include verification at the end, and provide an explicit route back to the overview.
Identify any required order between preparation tasks; don't make readers infer it from navigation order.
Breadcrumbs alone don't explain what readers should do next.

## Decide when to separate procedures

- Keep a short preparation action or read-only verification check with its requirement when this makes the requirement easier to use.
- Separate substantial preparation into a how-to guide, especially when it involves elevated permissions, restarts, meaningful risks, or platform-specific branches.
- State the required condition even when its configuration procedure is on another page.
- Create a separate readiness-check guide only when enough substantive checks justify it.
- Explain when automated preflight checks run and what they cover, using documented behavior only.
  Don't imply that all checks can run before installation or that a successful check proves readiness beyond its documented scope.

## Write clear requirements

- State applicability near the beginning, not in a late "Check whether this applies" section.
- Use noun phrases for reference titles and category headings; use action-based titles for preparation guides.
- Distinguish required, recommended, optional, and conditional items when the source establishes that distinction.
- State conditions before the requirements they qualify.
- Distinguish minimum resource requirements, recommended sizing, and supported configurations without treating them as interchangeable.
- Identify the subject of each requirement, including host, node role, cluster, or deployment scope where applicable.
- Use consistent units, terminology, product names, and version formatting.
- Use bullets for simple requirements, tables for genuine comparisons or port matrices, and description lists for named settings or terms.
- Give each requirement one authoritative source location.
  Link to it or use the repository's transclusion mechanism instead of maintaining duplicate copies.
- Keep technical background brief and link to conceptual documentation for deeper explanations.
- Make readiness checklists optional and use them to track completion, not to duplicate the full reference or substitute for verification.
- Omit unrelated marketing sections, redundant prerequisite sections, and repeated installation links.

## Preserve technical meaning

During editorial work, don't infer or invent resource values, versions, ports, endpoints, permissions, compatibility, support claims, or verification commands.
Preserve documented distinctions and technical values, and flag missing or ambiguous information for the content owner.
Only add technical facts and checks when supported by an established source and within the approved task scope.
For every verification check, explain where to run it and what result indicates success.
Distinguish checks that inspect the environment from actions that change it.
