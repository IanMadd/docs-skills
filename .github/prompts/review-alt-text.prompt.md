---
description: "Audit a Markdown document for missing, empty, and weak image alt text. Produces a report of every image reference with its current alt text, a quality verdict, and a suggested fix. Use when you want to check accessibility compliance without editing the file. Triggers on: review alt text, audit alt text, check alt text, alt text report, image accessibility audit, missing alt text, weak alt text."
name: "Review alt text"
argument-hint: "Paste or attach the Markdown document to audit, then optionally enter a file path to save the report (for example: alt-text-report.md)"
agent: "agent"
---

Audit the following Markdown document for image alt text quality.

**Document to audit**:

$input

---

## What to look for

Find every image reference in the document. These include:

- Markdown syntax: `![alt text](path)` — including `![]()` where alt text is empty
- HTML syntax: `<img src="..." alt="...">` — including tags where the `alt` attribute is
  missing or empty

For each image found, record:

- The line number
- The image path or URL
- The current alt text (or note that it is absent)
- A quality verdict from the categories below

---

## Quality categories

**Missing** — no alt text at all. In Markdown, the brackets are empty: `![]()`. In HTML,
the `alt` attribute is absent entirely.

**Decorative — unverified** — the alt attribute is an empty string (`alt=""` or `![]()`)
but the surrounding context suggests the image may be informative. Flag these for human
review.

**Decorative — confirmed** — the alt attribute is an empty string and the surrounding
context confirms the image is purely decorative. No fix needed.

**Weak** — alt text is present but low quality. Common signs:
- Text is the file name or path (for example, `diagram.png`, `./images/screenshot`)
- Text is a generic label with no context (`image`, `screenshot`, `diagram`, `figure`, `photo`)
- Text describes only appearance, not purpose or meaning
- Text starts with "Image of" or similar redundant phrasing
- Text repeats the surrounding paragraph verbatim

**Acceptable** — alt text meets quality standards. No fix needed.

---

## Alt text standards

When suggesting fixes, apply these rules:

- Communicate the image's **purpose and meaning**, not what it looks like.
- Begin with a capital letter. End with a period, even for fragments.
- Start by identifying the image type: "Screenshot of...", "Diagram showing...",
  "Bar chart of...". Don't start with the word "Image".
- Keep suggestions under 150 characters. For complex images, suggest a short summary
  and note that a longer description should be added to the surrounding text.
- Don't use the file name or path as alt text.
- Don't repeat text already present in a surrounding caption or paragraph.
- For screenshots in procedures: describe what the screenshot illustrates in the
  procedure context, not every visible UI element.
- For diagrams and flow charts: name the diagram type, then describe the key components
  and relationships.
- For charts and graphs: state the chart type and the key trend or finding.
- For logos: describe any significant symbol and include any text verbatim.
- For badge images (CI status, version, license): include the label and current value.
- For button or link images: describe what the button or link does, not what it looks like.

Note: this prompt audits alt text values already present in the source. It cannot view
image files. Mark any suggestion that depends on seeing the image as
`[requires image review]` so a human or the `/alt-text-edit` skill can verify it.

---

## Report format

Return a report with one entry per image, using this format:

> **Line \<n\>** — `<image path>`
> **Current alt text**: `<value>` *(or "absent")*
> **Verdict**: \<Missing | Decorative — unverified | Decorative — confirmed | Weak | Acceptable\>
> **Suggested alt text**: `<suggestion>` *(omit this line if verdict is Acceptable or Decorative — confirmed)*
> **Notes**: \<optional — explain the verdict or flag anything that requires human review\>

After all image entries, add a summary:

- Total images found
- Count by verdict category
- Overall accessibility assessment:
  - **Pass** — all images are acceptable or confirmed decorative
  - **Needs attention** — one or more images are weak or decorative but unverified
  - **Fail** — one or more images are missing alt text

---

If the user provided a file path as a second argument after the document, write the full
report to that file. Otherwise return the report in chat.
