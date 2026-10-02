---
name: generate-research-doc
description: 'Gather information from any combination of optional sources — web pages, a GitHub repo (local or remote), a GitHub pull request, Confluence pages, and Jira stories or epics — and compile it into a lengthy, detailed, free-form Markdown research report on a given topic, with every claim inline-cited back to its source. The report is an input for other skills in this repo (edit-how-to-guide, edit-conceptual-doc, edit-workflow-guide, and so on), not a publishable doc itself. Uses read-only GitHub, Confluence, and Jira operations. Never create, update, or delete anything in GitHub, Confluence, or Jira. Triggers on: research this topic, compile research, gather research, generate research doc, research report, research from sources, build a research doc, investigate and summarize, research brief.'
argument-hint: "Research topic (free text), followed by one or more source lines, each prefixed by type — web: https://example.com/post — repo: /local/path/to/repo or repo: owner/repo — pr: owner/repo#123 or a PR URL — confluence: https://example.atlassian.net/wiki/spaces/KEY/pages/123 — jira: PROJ-123 or a Jira issue/epic/version URL"
---

# Generate a research document from multiple sources

Runs a four-stage workflow to compile a lengthy, detailed Markdown research report on a
topic from any combination of optional sources: web pages, a GitHub repo (local or
remote), a GitHub pull request, Confluence pages, and Jira stories or epics.

The report is a research artifact, not a publishable doc. It's meant to be handed to
other skills in this repo (`edit-how-to-guide`, `edit-conceptual-doc`,
`edit-reference-doc`, `edit-tutorial`, `edit-workflow-guide`) as source material when
drafting a specific doc type. It doesn't follow a `doc-types.instructions.md` template
and isn't linted with Vale or cspell.

It's especially useful for [edit-workflow-guide](../edit-workflow-guide/SKILL.md):
researching every product involved in a cross-product workflow first, in one pass,
produces the multi-source, pre-cited material a workflow guide needs to link each step
back to the right product's documentation.

Read-only policy:

- Use GitHub, Confluence, and Jira only to read and retrieve data needed for research.
- Never create, update, edit, transition, comment on, assign, delete, or otherwise
  modify anything in GitHub, Confluence, or Jira.
- Apply writes only to the new research report file.

0. **Determine inputs** — parses the research topic and every source line, groups
   sources by type, and confirms at least one source is present
1. **Gather** — fetches each source using the read-only tool appropriate to its type,
   recording failures without stopping
2. **Synthesize** — groups findings into themes relevant to the topic, resolves or
   flags conflicts between sources, and attaches an inline citation to every claim
3. **Draft and save** — assembles the free-form Markdown report and writes it to
   `research/<topic-slug>.md`

---

## What to ask the user

Before starting, confirm these inputs if not already provided:

1. **Research topic** (required) — a free-text description of what to research, for
   example: `How does our knife-ec-backup migration path compare to the new
   chef-import-cli flow?`

2. **Sources** (required, at least one) — one or more lines, each prefixed by type:

   | Prefix        | Example                                                                  | Notes                                                  |
   |---------------|--------------------------------------------------------------------------|--------------------------------------------------------|
   | `web:`        | `web: https://example.com/blog/post`                                     | Any public web page                                    |
   | `repo:`       | `repo: /Users/you/code/my-repo` or `repo: chef/chef-cli`                 | Local absolute path, or `owner/repo` for a remote repo |
   | `pr:`         | `pr: chef/chef-cli#456` or a full PR URL                                 | Files changed plus the PR description                  |
   | `confluence:` | `confluence: https://example.atlassian.net/wiki/spaces/CHEF/pages/12345` | A page URL or page ID                                  |
   | `jira:`       | `jira: CHEF-456` or a release/version URL                                | An issue key, epic key, or release URL                 |

   A request can mix any number of sources of any type, including more than one of the
   same type (for example, two `web:` links and one `jira:` key).

3. **Output path** (optional) — defaults to `research/<topic-slug>.md` at the
   workspace root. If the user gives a path, use it instead.

---

## Stage 0: Determine inputs

Parse the request into a topic and a list of source lines.

1. Extract the research topic. If none is given, ask for one before continuing.
2. Parse each source line by its prefix (`web:`, `repo:`, `pr:`, `confluence:`,
   `jira:`). Group sources into a task list by type.
3. For `repo:` sources, decide **local** or **remote**: if the value is an absolute
   path that exists in the workspace or on disk, treat it as local; otherwise treat it
   as `owner/repo` on GitHub.
4. If no source lines are found, stop and ask the user to supply at least one source.
   Don't proceed to Stage 1 with zero sources.
5. Determine the output path: the user-supplied path, or `research/<topic-slug>.md`
   (see Stage 3 for the slug rule).

Report before continuing:

- The research topic
- Each source, grouped by type, with local vs. remote noted for repos
- The output path that will be used

---

## Stage 1: Gather from each source

Fetch every source in parallel where the tools allow it. Read-only for all of the
following — never write, comment, or modify anything at the source.

### Web pages (`web:`)

Fetch the page content (for example with `fetch_webpage`, or `open_browser_page` plus
`read_page`). Capture:

- Page title
- URL
- The excerpts relevant to the research topic

If a page is inaccessible (404, paywall, login required), record the failure and move
on.

### GitHub repo — local (`repo:` with a local path)

Use `file_search`, `grep_search`, `read_file`, and `semantic_search` against the given
path. Absolute paths work even when the repo is outside the current workspace folder.

- Read the README and any top-level docs first for orientation.
- Search for keywords drawn from the research topic across the repo.
- Capture file paths and line ranges for anything quoted or paraphrased, so the
  citation can point to `path/to/file.ext#L10-L20`.

### GitHub repo — remote (`repo:` with `owner/repo`)

Use the `github_repo` (semantic) and `github_text_search` (keyword) tools first. Fall
back to the GitHub MCP tools (`search_code`, `get_file_contents`, `list_commits`,
`get_latest_release`) or raw `raw.githubusercontent.com` URLs (see
[generate-examples-from-repo](../generate-examples-from-repo/SKILL.md) for the
raw-URL construction pattern) if those aren't sufficient.

- Start with the README, then search for topic keywords.
- Capture the file path and, where possible, a permalink or `owner/repo` + path +
  line range for citation.

### GitHub pull request (`pr:`)

Use the GitHub MCP pull request read tool to retrieve the PR title, description, and
changed files/diff. Never comment on, review, or merge the PR.

- Capture the PR number, title, description, and a summary of what changed in the
  diff relevant to the topic.
- If the PR description references a Jira issue key (for example, `CHEF-456`), add
  that key to the Jira task list from Stage 0 so Stage 2 can cross-reference it, even
  if the user didn't supply it directly.

### Confluence pages (`confluence:`)

Use the Atlassian MCP server's read operations (`search`, `getConfluencePage`,
`getConfluencePageDescendants`). Never create or edit pages or comments.

- Capture the page title, URL or page ID, and the content relevant to the topic.
- If the page has child pages that look relevant to the topic, fetch a reasonable
  number of them too (use judgment; don't recurse through an entire space).

### Jira issues, epics, and releases (`jira:`)

Use the Atlassian MCP server's read operations (`getJiraIssue`,
`searchJiraIssuesUsingJql`). Never create, edit, transition, or comment on issues.

- **Single issue key** — fetch the issue directly: summary, description, status,
  issue type.
- **Epic key** — fetch the epic (summary, description, status), then fetch its child
  issues the same way [review-release-notes](../review-release-notes/SKILL.md) Stage 2
  does for epics.
- **Release/version URL** — parse the project key and version ID from the URL, then
  fetch all issues in that version.
- Include any Jira keys added by the PR cross-reference step above.

### Handling failures

If a source can't be reached or returns nothing useful, record it as a failed source
with a one-line reason (404, access denied, empty result, and so on). Continue
gathering the remaining sources — one failure never stops the stage.

Report before continuing:

- How many sources were gathered successfully, grouped by type
- Which sources failed and why

---

## Stage 2: Synthesize findings

Organize everything gathered in Stage 1 around the research topic, not around source
type. Group related findings into themes as they naturally emerge from the material —
don't force a fixed set of section names.

1. **Group by theme.** Read across all gathered sources together and cluster findings
   by subject matter (for example, "authentication flow," "data migration steps,"
   "known limitations") rather than listing everything source-by-source.
2. **Resolve or flag conflicts.** If two sources disagree, don't silently pick one —
   state the disagreement explicitly and cite both sources, letting the reader (or a
   downstream skill) decide.
3. **Cite every claim inline.** Attach a citation to each factual statement, using a
   format that identifies the source unambiguously:
   - `(Source: web — <https://example.com/post>)`
   - `(Source: repo — owner/repo, path/to/file.rb#L42)` or `(Source: repo —
     /local/path/file.rb#L42)`
   - `(Source: PR #456)`
   - `(Source: Confluence — "Page title")`
   - `(Source: JIRA-456)`
4. **Note gaps.** Track any part of the topic the gathered sources didn't cover, and
   any question that came up during synthesis but wasn't answered by any source.

---

## Stage 3: Draft and save the report

Assemble the report as a single Markdown file. The structure is free-form — let the
themes from Stage 2 drive the section headings — but always include:

```markdown
# <Research topic>

One paragraph stating what was researched, why, and which source types were consulted.

## Sources reviewed

- List each source consulted, grouped by type, with a one-line note on what it
  contributed. Include failed sources with their failure reason.

## <Theme 1>

Findings for this theme, each claim inline-cited.

## <Theme 2>

...

## Gaps and open questions

- What the gathered sources didn't answer
- Any conflicting information found in Stage 2, restated here if not already
  resolved inline

## Sources

- A deduplicated flat list of every source consulted, with its full locator
  (URL, file path, PR number, Confluence page, or Jira key) so a downstream skill can
  go back to the original material.
```

### Save the file

1. Build the topic slug: lowercase the topic, replace non-alphanumeric runs with a
   single hyphen, trim leading/trailing hyphens, and cap the result at roughly 60
   characters.
2. Use the output path determined in Stage 0 — `research/<topic-slug>.md` by default.
   Create the `research/` directory at the workspace root if it doesn't exist.
3. Write the file. If a file already exists at that path, ask the user whether to
   overwrite it or choose a different name before writing.
4. Optional: run `markdownlint-cli2 --fix` on the new file for basic Markdown hygiene
   (heading spacing, list formatting). This report doesn't need to pass Vale or
   cspell — it isn't a `doc-types.instructions.md` doc type and isn't customer-facing.

---

## Report

Summarize:

- The research topic and the output file path
- Every source consulted, grouped by type, and which ones failed (with reasons)
- The themes the report ended up organized around
- The contents of the "Gaps and open questions" section
- A reminder that this file is a research input for other skills, not a doc ready to
  publish
