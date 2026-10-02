---
description: "Structural template and guidelines for how-to guide doc type pages."
---

# How-to guide

**Purpose**: Task-oriented. Helps an experienced reader complete one specific task or solve one specific problem. Assumes the reader has practical knowledge and knows what they want to achieve. Alerts readers to unexpected scenarios; it doesn't eliminate them the way a tutorial does.

```markdown
# <Title: bare infinitive---"Deploy a container to Kubernetes">

This guide explains how to <bare description of the task, matching the title>.
<Optional: one sentence stating when and why a reader would perform this task---for example,
"Use a NetworkPolicy to restrict which pods can communicate with each other.">
Assume the reader already has basic knowledge of the application and knows what they want to achieve---
don't re-explain concepts the reader is assumed to know.
If the task is routine (for example, a recurring backup) or follows another event (for example, an
upgrade), state when to perform it.
If the task carries risk or requires a safety measure first---a backup, a maintenance window, elevated
permissions---state it before the steps.
If the task takes a long time or affects a critical system, tell the reader up front.

## Before you begin (include only for non-obvious prerequisites)

- Prerequisite: tool, permission, or environment needed
- Link to relevant setup docs
- If the reader will install third-party software, link to that software's system requirements

## <Task name: bare infinitive>

(Include an introductory sentence unless the heading alone gives the reader everything they need.)
Introductory sentence that adds context the heading doesn't already cover---don't just repeat the
heading. End the sentence with a colon if it immediately precedes the steps, or a period if other
material (for example, a note) comes between the sentence and the steps.
For example: "To customize the buttons, follow these steps:" or "Customize the buttons:"
Don't introduce the steps with a partial sentence that the numbered list completes, for example,
"To customize the buttons:" followed directly by the steps.

1. Step one. Start with an imperative verb. Write each step as one action or one decision the reader
   makes---write at the highest level the reader will understand rather than splitting one action into
   several small steps.
1. Step two: a short sentence stating only the action, with no bolding.

   Supplemental information goes in a paragraph after the action sentence---context, warnings, or
   an explanation of why the step matters. Don't bold the action sentence to make it look like a
   pseudo-heading.

   ```shell
   # Comment explaining the command
   command --flag <VALUE>
   ```

   Replace `<VALUE>` with <what it represents>. For two or more placeholders, use "Replace the
   following:" and a bulleted list instead (see
   [Code and commands](../docs-style.instructions.md#code-and-commands)).
   Expected output or result.
   Explain the significance of the output in a separate paragraph if it isn't obvious.

1. Optional: <step that isn't required>.
1. If <condition>, do <alternative step>.

## Next steps

- Link to another procedure the reader should complete after this one

## See also

- Link to a related how-to guide
- Link to a relevant conceptual doc or reference page
```

**Guidelines**:
- One how-to guide covers exactly one task
- Open with "This guide explains how to <task>," naming the same task as the title, so the reader
  immediately confirms they're in the right place
- State the problem or task the reader can solve or complete, and, when it's not obvious, when and why
  they'd want to perform it---for example, "This guide explains how to create an issue on GitHub. You
  can create issues to track ideas, feedback, tasks, or bugs for work on GitHub."
- Don't explain background concepts in the introduction---assume the reader has basic knowledge of the
  application and knows what they want to achieve; link to a conceptual doc instead
- Maximum 8–10 steps; if longer, split into multiple guides, or group related steps under subheadings so
  the reader stays oriented
- Introduce a set of steps with a sentence that adds context beyond the heading; skip the introductory
  sentence entirely if the heading already says everything the reader needs
- End an introductory sentence with a colon when the steps follow immediately, or a period when other
  material comes between the sentence and the steps
- Write the introductory sentence as a complete imperative statement, not a partial sentence the
  numbered steps complete---write "To customize the buttons, follow these steps:" or
  "Customize the buttons:", not "To customize the buttons:"
- Apply the same introductory-sentence rules to a step that has sub-steps: end that step with a colon
  or a period, as appropriate, before listing the sub-steps
- Write each step as a single action the reader takes or a single decision they make; if an action
  triggers a response from the application or system, describe that response in the same step, not as
  its own step
- Start the first sentence of every step with an imperative verb
- Write the action sentence in plain text---don't bold it as a pseudo-heading. If a step needs
  supplemental information (why it matters, what to watch for, background), state the action in one
  short sentence, then add the supplemental information as a separate paragraph below it, not merged
  into the action sentence
- Preface optional steps with "Optional:"
- State conditions at the start of a step, not the end, so the reader doesn't act before realizing the
  condition doesn't apply to them---for example, "If the test succeeds, reindex all organizations," not
  "Reindex all organizations if the test succeeds"
- Use a single unordered list item, not a numbered step, for single-step procedures
- Explain every placeholder immediately after the code example that introduces it, using the
  single- or multiple-placeholder pattern from
  [Code and commands](../docs-style.instructions.md#code-and-commands)---don't leave the reader to
  guess what a placeholder represents
- Don't explain concepts in the steps---link to conceptual docs instead
- Document only the most common or recommended method; omit or link to alternative methods
- Alert readers to possible unexpected scenarios with `{{< note >}}` or `{{< warning >}}` shortcodes (see [Admonitions](../doc-types.instructions.md#admonitions))
- Make the end point of the procedure clear---show expected output, a verification command, or a
  screenshot so the reader knows they reached the end point, whether it's the end of the guide or a
  waypoint in a longer set of procedures
- Test instructions end-to-end before publishing; re-test after every notable product release
- Include "Next steps" when the how-to guide is part of a larger workflow and leads directly into other procedures; omit it for standalone tasks
