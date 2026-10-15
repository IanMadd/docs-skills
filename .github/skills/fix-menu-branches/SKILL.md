---
name: fix-menu-branches
description: 'Find Hugo pages whose front matter menu identifier is used as the parent of other menu entries but is not defined in menu.toml, move that branch entry and every branch ancestor into config/_default/menu.toml as indented [[menu]] tables, and turn each branch page into a navigable leaf under its own branch. Use when pages that act as menu sections can''t be selected in the left nav. Triggers on: fix menu branches, menu.toml, menu identifier, menu parent, reorganize menu, page not clickable in menu, menu frontmatter, left nav structure, branch pages, menu leaf.'
argument-hint: "Absolute path to the Hugo site root (for example /path/to/chef-web-docs). Optionally, one or more menu identifiers to limit the fix to, such as use/administrators/notifications."
---

# Fix menu branches

In this docs set, `config/_default/menu.toml` defines the frame of the left navigation
menu---every branch---and each page's front matter menu table attaches the page as a leaf
at the end of a branch. When a page's menu `identifier` is used as another entry's
`parent`, the page becomes a branch instead. Hugo renders that branch as an expandable
section header, so readers can't navigate to the page itself.

This skill finds every such branch page and fixes it:

1. Copies the page's menu table into `menu.toml` as a `[[<menu>]]` table, placed under its
   parent and indented two spaces per nesting level.
2. Repeats this for every ancestor of the branch that's also defined in page front matter,
   up to and including the menu's root entry.
3. Turns the page into a leaf: its `parent` becomes its old `identifier`, and its
   `identifier` becomes `<old identifier>/<slug of the page title>`.

The workflow is driven by the bundled
[fix_menu_branches.py](./scripts/fix_menu_branches.py) script so the analysis and edits are
deterministic. The script runs as a dry run unless you pass `--apply`.

## Worked example

Before, `content/use/administrators/notifications/_index.md` is a branch page because
other pages, such as `administrator_guide.md`, use its identifier as their `parent`:

```toml
+++
title = "Notification management"
LinkTitle = "Notifications"

[menu.use]
title = "Notifications"
identifier = "use/administrators/notifications"
parent = "use/administrators"
weight = 60
+++
```

After, `menu.toml` contains an identical table, with `[menu.use]` changed to `[[use]]`.
It's indented four spaces because it has two ancestors, `use/administrators` and `use`:

```toml
    [[use]]
    title = "Notifications"
    identifier = "use/administrators/notifications"
    parent = "use/administrators"
    weight = 60
```

The page becomes a leaf under that branch. Only `identifier` and `parent` change:

```toml
[menu.use]
title = "Notifications"
identifier = "use/administrators/notifications/notification-management"
parent = "use/administrators/notifications"
weight = 60
```

`use/administrators` and `use` are branch pages too, so the skill moves them into
`menu.toml` the same way, at two spaces and zero spaces of indentation.

## Rules

Detection:

- **Branch page**: a page menu table whose `identifier` appears as the `parent` of any
  page menu table or any `menu.toml` entry, and whose `identifier` isn't defined in
  `menu.toml`. Because each ancestor of a branch is itself a parent, the whole ancestor
  chain is detected automatically, including root entries that have no `parent`.
- **Duplicate identifier**: a page menu table whose `identifier` is already defined in
  `menu.toml`. Two menu entries with one identifier conflict, so the page becomes a leaf
  under the existing `menu.toml` entry and nothing is added to `menu.toml`.
- **Dangling parent**: a `parent` value that matches no identifier anywhere. The script
  reports these but doesn't fix them; resolve them manually.

The `menu.toml` table:

- Copy the page's menu table key-for-key and value-for-value, in the same order. Only the
  table header changes, from `[menu.<menu>]` to `[[<menu>]]`. Don't add a `url`.
- Indent the header and every key by two spaces for each ancestor in the menu tree. A root
  entry such as `use` gets zero spaces, `use/administrators` gets two, and
  `use/administrators/notifications` gets four.
- Place the table after its parent table and after any of the parent's descendant tables
  that directly follow it, separated by a blank line. Place a root entry before the first
  existing table for that menu. If the menu has no tables yet, append a new section banner
  at the end of the file.
- Don't reindent or reorder existing `menu.toml` entries.

The page front matter:

- Set `parent` to the page's old `identifier`. Add a `parent` line after `identifier` if
  the page had none, as with root entries.
- Set `identifier` to `<old identifier>/<slug>`, where the slug is the page's front matter
  `title` lowercased with each run of non-alphanumeric characters replaced by a single
  hyphen. For example, `Notification management` becomes `notification-management`. If
  that identifier is already taken, the script appends `-2`, `-3`, and so on.
- Leave every other key, including the menu `title` and `weight`, unchanged.

## Stage 1: Confirm inputs

1. Confirm the site root path exists and contains `config/_default/menu.toml` and a
   `content/` directory. If either is somewhere else, pass `--menu-file` or
   `--content-dir` to the script in later stages.
1. Confirm Python 3.11 or later is available, since the script uses the standard library
   `tomllib` module:

   ```shell
   python3 --version
   ```

1. Check that the site repo has no uncommitted changes to `menu.toml` or `content/` so the
   changes can be reviewed and reverted with Git:

   ```shell
   git -C <SITE_ROOT> status --short -- config/_default/menu.toml content
   ```

   If there are uncommitted changes, ask the user whether to continue.

## Stage 2: Run a dry run

Run the script from this skill's directory without `--apply`:

```shell
python3 <SKILL_DIR>/scripts/fix_menu_branches.py --repo <SITE_ROOT>
```

Replace the following:

- `<SKILL_DIR>`: the path to this skill, usually `.github/skills/fix-menu-branches`
- `<SITE_ROOT>`: the absolute path to the Hugo site root

To limit the fix to one branch and its ancestors, add `--only <IDENTIFIER>`. The option is
repeatable. Add `--json` for machine-readable output.

The report lists:

- Each branch page, the indentation and parent of its new `menu.toml` table, its new leaf
  `identifier` and `parent`, and how many children it has
- Each page that duplicates a `menu.toml` identifier
- Each dangling parent
- Warnings for front matter the script can't safely edit, such as YAML front matter, menus
  defined as a string or list, or menu tables with nested tables

## Stage 3: Review the plan with the user

Summarize the dry-run report for the user in a table with these columns: branch
identifier, source file, `menu.toml` indentation, and new leaf identifier. Then point out
anything that needs a decision:

- **Dangling parents and warnings**: these need manual fixes. List them and ask whether to
  continue with the rest.
- **Awkward slugs**: a slug built from a long page title, such as
  `get_started/get-started-with-chef-360-platform`, is valid but verbose. Offer to keep it
  or to set a shorter identifier manually after Stage 4.
- **Leaf position**: the leaf keeps its original `weight`, so a section's landing page can
  sort after its sibling pages. Offer to adjust weights after Stage 4.
- **Duplicate menu labels**: the new branch and its leaf share the same menu `title`, for
  example a **Notifications** branch containing a **Notifications** leaf. Offer to change
  the leaf's menu `title` after Stage 4.

Don't apply changes until the user confirms the plan.

## Stage 4: Apply the changes

Run the same command with `--apply`, including any `--only` options the user chose:

```shell
python3 <SKILL_DIR>/scripts/fix_menu_branches.py --repo <SITE_ROOT> --apply
```

Then make any follow-up edits the user asked for in Stage 3, such as shorter identifiers,
weights, or menu titles. If you change a leaf identifier, confirm that no other entry uses
it as a `parent`.

## Stage 5: Verify

1. Run the dry run again. It must report zero branch pages and zero duplicates:

   ```shell
   python3 <SKILL_DIR>/scripts/fix_menu_branches.py --repo <SITE_ROOT>
   ```

1. Confirm `menu.toml` is still valid TOML:

   ```shell
   python3 -c "import tomllib; tomllib.load(open('<SITE_ROOT>/config/_default/menu.toml', 'rb'))"
   ```

1. Search layouts, data files, and other config for any old identifiers that are now leaf
   identifiers, since templates sometimes look up menu entries by identifier. Report any
   matches to the user instead of changing them.
1. Review the diff with `git -C <SITE_ROOT> diff --stat` and spot-check one nested branch
   in `menu.toml` and its leaf page.
1. If the site's local build tooling is set up, build or serve the site, for example with
   `make serve` or `hugo server`, and confirm that each former branch page is now a
   clickable item inside its own expandable section.

## Stage 6: Report

Tell the user:

- How many branch entries moved into `menu.toml`, grouped by menu
- How many pages became leaves, and any whose identifier or title you changed manually
- Any dangling parents, warnings, or template matches that still need manual work
- That the changes aren't committed, so they can review the diff first
