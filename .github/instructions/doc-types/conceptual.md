---
description: "Structural template and guidelines for conceptual doc type pages."
---

# Conceptual doc

**Purpose**: Helps readers understand a concept, architecture, or system. Provides foundational knowledge so readers can understand how-to guides and reference docs in context. Builds mental models; does not teach by doing.

Conceptual docs appear early in documentation journeys, or as mid-level layers when a reader encounters an unfamiliar concept in a how-to guide.

Before drafting, define the concept's scope and boundaries so you know what belongs in the doc and what
doesn't. Then gather the questions readers actually ask about it---from support tickets, community
forums, or internal chat threads---such as "What is it?", "Why do I need it?", "Why not use <Y>
instead?", or "When shouldn't I use it?" Use these questions to shape what the doc covers, and to check
afterward that you answered them.

Name the document after the concept itself wherever possible---for example, "Payments" or "Deployment
strategies in Kubernetes"---rather than a generic label. If a generic label fits your doc set better,
use "Overview of <concept>," "Introduction to <concept>," "About <concept>," "Understanding <concept>,"
or "Background." Avoid bare titles like "Overview" or "Introduction" with no accompanying noun: they're
hard to discover in search and don't tell the reader what the page covers.

```markdown
# <Title: noun phrase---"Deployment strategies in Kubernetes">

(Optional) An introductory paragraph framing the concept's relevance and what the page covers.
Apply the inverted pyramid: start with the high-level idea, then go deeper.

## What is <concept>

A clear definition scoped to what this document covers. State what is in scope and, where useful,
what is out of scope. Explain how the concept fits into the broader system or workflow.
Use analogies where they help---prefer universally understood comparisons.

Typical definition patterns:
- "<Concept> is..." or "<Concept> represents..."
- "<Concept> addresses the common pain points of..." or "solves the challenge of..."
- "By using <concept>, you can..." or "To use <concept>, you create <thing>"

## (Optional) <Diagram or visual>

If a diagram clarifies the architecture or data flow, describe or embed it here, near the top.
Place the diagram next to the text that explains it---don't separate a visual from its explanation
with unrelated content in between.

## (Optional) Background

Historical context, design decisions, or industry context that affects how the concept works.
Include only if it meaningfully aids understanding.

Typical wordings to use:
- "The reason <concept> is designed that way is because historically..."
- "The idea of <concept> originated from the growing demand for..."
- "With the rise of <X>, the need for <concept> became paramount."

## Use cases

When and why a DevOps engineer would use or encounter this concept.
Frame use cases around the reader's problems: what challenges does this concept solve?

## (Optional) Comparison

If the concept has multiple types, versions, or similar alternatives, include a comparison table.

| | When to use |
|---|-------------|
| <Option 1> | <Reason> |
| <Option 2> | <Reason> |

## Related resources

How-to guides
- Link to a how-to guide that implements this concept

Related concepts
- Link to a related conceptual doc

Reference
- Link to a reference doc for this concept's options or configuration
```

**Guidelines**:
- One conceptual doc covers exactly one concept; if explaining a second concept becomes necessary, link to a separate doc
- Don't include step-by-step procedures---add a `<!-- TODO: link to how-to guide for [task] -->` comment where a procedure link should go
- Use the inverted pyramid: high-level overview first, details later
- Explain trade-offs and limitations honestly
- Identify your audience's familiarity with the concept before writing. If a doc must serve both
  non-technical and technical readers, layer the content: open with a simple, high-level explanation,
  then progressively add technical depth. If the two audiences' needs diverge too far to layer well,
  split into separate documents instead of forcing one doc to serve both
- Include a diagram whenever it clarifies structure, data flow, or relationships, and pick the type that
  matches what you're explaining:

  | Diagram type | Best for |
  |---|---|
  | Context diagram | Showing how the concept fits into a broader system or ecosystem |
  | Flowchart | Explaining a sequential process, or how the concept evolved over time |
  | Decision tree | Presenting choices and their consequences |
  | Infographic | A high-level, visually driven overview, especially one built around numbers |

- Keep visual aids close to the text that explains them, and use them sparingly---a document with too
  many competing visuals is as hard to parse as one with none
- Prefer diagrams-as-code (a text-based diagram notation rendered by tooling) over static images so
  diagrams stay easy to update as the concept changes
- Review conceptual docs on a regular schedule, and whenever the underlying concept, a linked concept,
  or a dependency changes; a stale definition or analogy actively misleads readers
- When validating updates, test comprehension rather than just proofreading: ask a reader to explain
  the concept back in their own words, or walk through a real-world scenario, to confirm the definition
  and analogies still land
