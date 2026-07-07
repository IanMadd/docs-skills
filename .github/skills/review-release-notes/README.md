# Review release notes skill

Reviews and edits a release notes file using Jira release data and GitHub pull requests as optional sources.

## Description

With this skill, you can review and improve a draft release notes file, add new entries from source data, or edit an existing file for style and structure only.
The skill uses Jira and GitHub as co-equal, optional sources.
It applies the team style guide and release notes doc type structure to all edits.

All Jira and GitHub operations are read-only.
The skill never creates, updates, or deletes anything in Jira or GitHub---it applies edits only to the local release notes file in your workspace.

## Who is this for

Documentation writers, technical writers, and engineers who maintain release notes and want to:

- Review and improve existing release note entries using Jira issues or merged pull requests as source data
- Add new release note sections from Jira or GitHub data when no entries exist yet
- Edit a release notes file for style, structure, and consistency without source data

## Inputs

Provide the path to the release notes file.
Jira and GitHub sources are optional---if neither is provided, the skill edits the file for style and structure only.

| Input | Required | Description | Example |
|-------|----------|-------------|---------|
| Release notes file path | Yes | Path to the Markdown file to review | `docs/release-notes/v2.4.md` |
| Jira release URL or epic key | No | A Jira release/version URL or an epic key | `https://example.atlassian.net/projects/CHEF/versions/43153/tab/release-report-all-issues` or `PLATFORM-456` |
| GitHub repository | No | The `owner/repo` the PRs belong to | `chef/chef-infra-client` |

You can provide one or both optional sources.
If you include full GitHub PR URLs in your release notes file, the skill parses the owner and repo from those URLs automatically.

## Workflow stages

The skill runs a five-stage workflow.
The stages that run depend on which inputs you provide.

### Stage 0: Determine available inputs

Identifies which data sources are available (Jira, GitHub, or none) and maps which stages to run.
Reports whether Stage 4 will run in edit mode, add mode, or style-only mode.

### Stage 1: Parse the release notes file

Reads the release notes file and extracts every pull request reference.
Supports short references (`#123`), full GitHub URLs, and Markdown links.
Determines whether release note entries are already drafted (edit mode) or not yet written (add mode).

### Stage 2: Fetch Jira release issues

Runs if you provide a Jira release URL or epic key.
Retrieves all issues in the Jira release or epic and collects each issue's key, summary, type, status, and description.
Cross-references Jira issues against PR bodies to build a mapping for Stage 4.

### Stage 3: Fetch pull request details from GitHub

Runs if you provide a GitHub repository or if the release notes file contains PR references.
Retrieves the title, body, labels, linked issues, and merge status for each referenced PR.
Reports any PRs that couldn't be fetched or that weren't merged.

### Stage 4: Edit the release notes

Edits the file in one of three modes:

- **Edit mode**: Entries for this release are already drafted.
  The skill reviews each entry against Jira and PR data, corrects inaccurate or vague notes, and applies the team style guide.
- **Add mode**: No entries exist yet for this release.
  The skill adds new sections populated from Jira issues and/or PR data.
- **Style-only mode**: No Jira or GitHub sources are available.
  The skill edits the file for style, grammar, and section structure only---it doesn't infer or expand content.

In all modes, the skill checks section structure against the release notes template, removes empty sections, and flags notes that need human review.

## After the skill runs

The skill reports:

- Which mode Stage 4 ran in
- How many Jira issues and PRs were used as source data
- How many entries were updated, added, or left unchanged
- Any sections removed because they were empty or contained only placeholder text
- Any notes flagged for human review, with the reason

## Related

- [SKILL.md](SKILL.md)---full workflow instructions for this skill
- [docs-style.instructions.md](../../instructions/docs-style.instructions.md)---team prose style guide
- [doc-types.instructions.md](../../instructions/doc-types.instructions.md)---release notes doc type structure
