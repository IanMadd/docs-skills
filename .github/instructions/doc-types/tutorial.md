---
description: "Structural template and guidelines for tutorial doc type pages."
---

# Tutorial

**Purpose**: Learning-oriented. The reader follows a guided path and ends with a working result and new skills. Assumes no prior practical knowledge of the tool. Tutorials eliminate unexpected scenarios---engineer the reader toward a successful finish.

Tutorials differ from how-to guides: tutorials teach; how-to guides guide experienced users through a task.

```markdown
# <Title: what the reader will build or achieve>

One paragraph explaining what the reader will build and why it matters to a DevOps engineer.

## Overview

### Learning objectives

By the end of this tutorial, you'll be able to:

- <Skill or action the reader can perform>
- <Skill or action the reader can perform>

### Intended audience

Who this tutorial is for and what prior knowledge is assumed.

## Background (optional)

Any context the reader needs before starting---feature explanation, project structure, key concepts.
Keep this brief; link to conceptual docs for deeper explanations.

## Before you begin

- Prerequisite 1 (link to setup steps where applicable)
- Prerequisite 2

## Step 1: <Bare infinitive action---"Configure the namespace">

Introductory sentence explaining what this step accomplishes and why.

1. Step action. Start with an imperative verb.
1. Step action.

   ```shell
   # Comment explaining what this command does
   command --flag <VALUE>
   ```

   Expected result: describe what the reader should see.

## Step 2: <Action>

...

## Summary

Recap the specific skills and knowledge the reader gained. Don't repeat the learning objectives
word-for-word---describe what they actually built or configured.

## Clean up (include if tutorial creates persistent or billable resources)

Steps to remove resources created during the tutorial.

## Next steps

- Link to a related how-to guide
- Link to a related conceptual doc or advanced tutorial
```

**Guidelines**:
- Tutorials should take 15–60 minutes to complete
- Keep steps to a maximum of 7 primary steps; maximum 4 substeps per step
- Each step builds on the previous one---don't jump ahead
- Show expected output after commands so the reader can verify success
- Use real, working examples---not placeholder logic
- Add comments to code samples following the comment style rules in
  [code-comments.instructions.md](../code-comments.instructions.md)---explain
  why and customization points, and move documentation-only narration into the surrounding prose
- Include a "Clean up" section whenever the tutorial creates persistent or billable resources
