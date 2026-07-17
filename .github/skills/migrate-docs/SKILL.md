---
name: migrate-docs
description: 'Migrate Chef documentation from a source repo to a product subdirectory in the chef/chef-web-docs main branch, or unversion content from a release branch into the main branch of the same repository. Supports versioned repos (branch-based, with a product/version directory structure), unversioned repos (default branch, flat product directory), and in-repo versioned migrations (release branch to product/version subdirectory in the same repo). Copies content and static files, updates frontmatter menu references, transforms menu.toml, rewrites internal links, and strips the docs.chef.io domain from cross-product links. Triggers on: migrate docs, versioned docs migration, unversioned docs migration, branch to subdirectory, docs migration, move versioned content, migrate unversioned content, reorganize docs, migrate versioned documentation, in-repo versioned migration, unversion content, same-repository migration, in-repo content migration.'
argument-hint: "Migration type (versioned, unversioned, or in-repo), product short name, version (versioned and in-repo only), source repo path, and target repo path — e.g. 'versioned 360 1.6 /path/to/source-repo /path/to/chef/chef-web-docs', 'unversioned inspec /path/to/source-repo /path/to/chef/chef-web-docs', or 'in-repo 360 1.6 /path/to/repo'"
---

# Migrate docs to a product subdirectory

Runs a workflow to migrate documentation from a source repo to the
unified `chef/chef-web-docs` main branch, or to unversion content from a release branch
into the `main` branch of the same repository. Supports three migration types:

- **Versioned** — source content lives on a `release-<version>` branch; target uses a
  `content/<product>/<version>/` directory structure in `chef/chef-web-docs`
- **Unversioned** — source content lives on the default branch; target uses a
  `content/<product>/` directory structure with no version component in `chef/chef-web-docs`
- **In-repo versioned** — source content lives on a `release-<version>` branch in the
  same repo as the target; target uses a `content/<product>/<version>/` directory structure
  in the `main` branch of the same repo

Stages:

1. **Gather inputs and validate** — collects required inputs and confirms the repo or repos exist
2. **Copy files** — sets up the working tree and copies content and static files to the target directory
3. **Update frontmatter** — rewrites `[menu.X]` references and `identifier`/`parent` values in every migrated file
4. **Update menu.toml** — merges source menu sections into a single menu in the target; adds the version to the version switcher (versioned and in-repo versioned only)
5. **Rewrite links** — updates internal content links, image paths, shortcode file paths, and strips the `docs.chef.io` domain from cross-product links

---

## Stage 0: Gather inputs and validate

Ask the user for the following if not already provided:

1. **Migration type** — versioned, unversioned, or in-repo versioned:
   - **Versioned**: source content is on a `release-<version>` branch in a separate source
     repo; target uses `content/<product>/<version>/` in `chef/chef-web-docs`
   - **Unversioned**: source content is on the default branch of a separate source repo;
     target uses `content/<product>/` with no version component in `chef/chef-web-docs`
   - **In-repo versioned**: source content is on a `release-<version>` branch in the same
     repo as the target; target uses `content/<product>/<version>/` in the `main` branch
     of the same repo

2. **Product short name** — the short identifier used in the URL and directory path, for
   example `360` for Chef 360 Platform or `inspec` for Chef InSpec.

3. **Version** *(versioned migrations only)* — the version number to migrate, for example
   `1.6`.

4. **Source repo path** — the absolute path to the local clone of the source documentation
   repository, for example `/Users/me/code/progress-platform-services/chef-web-docs` or
   `/Users/me/code/inspec/chef-inspec-resource-docs`.

5. **Source content subdirectory** *(unversioned migrations only)* — the subdirectory
   within the source repo where content lives. Common values:
   - `content/` — used by repos where docs are the entire repository
   - `docs-chef-io/content/` — used by repos where docs live alongside product code

   If the user is unsure, check the source repo structure:

   ```shell
   ls <source-repo>/content 2>/dev/null || ls <source-repo>/docs-chef-io/content
   ```

6. **Target repo path** — the absolute path to the local clone of `chef/chef-web-docs`,
   for example `/Users/me/code/chef/chef-web-docs`.

### Derive migration identifiers

From the inputs, derive the following values and confirm them with the user before
continuing:

**Versioned migration:**

- **Branch name**: `release-<version>` — for example `release-1.6`
- **Menu name**: `<product>_<version>` with all dots replaced by underscores — for example
  `360_1_6` for product `360` and version `1.6`
- **Source content path**: `<source-repo>/content/`
- **Content target path**: `<target-repo>/content/<product>/<version>/`
- **Static target path**: `<target-repo>/static/<product>/<version>/images/`

**Unversioned migration:**

- **Branch name**: default branch (no checkout needed)
- **Menu name**: user-specified — often the same as the product short name or a resource
  pack identifier. Check the source `menu.toml` to confirm the menu array names in use;
  the target menu name is typically the same as the primary source menu array name (for
  example `aws` or `about`)
- **Source content path**: `<source-repo>/<content-subdir>/` — for example
  `<source-repo>/content/` or `<source-repo>/docs-chef-io/content/`
- **Content target path**: `<target-repo>/content/<product>/`
- **Static target path**: `<target-repo>/static/<product>/images/`

**In-repo versioned migration:**

- **Branch name**: `release-<version>` — for example `release-1.6`
- **Menu name**: `<product>_<version>` with all dots replaced by underscores — for
  example `360_1_6` for product `360` and version `1.6`
- **Worktree path**: a temporary directory outside the repo, for example
  `/tmp/<product>-<version>-worktree`
- **Content target path**: `<repo>/content/<product>/<version>/`
- **Static target path**: `<repo>/static/<product>/<version>/images/`

### Validate repos

**Versioned and unversioned migrations** — confirm both repos exist and are valid git
repositories:

```shell
ls <source-repo>/.git && ls <target-repo>/.git
```

If either check fails, stop and ask the user to correct the path.

**In-repo versioned migrations** — confirm the repo exists and is a valid git repository:

```shell
ls <repo>/.git
```

If the check fails, stop and ask the user to correct the path.

**Versioned migrations only** — confirm the source branch exists:

```shell
git -C <source-repo> branch --list release-<version>
```

If the branch is not listed, show the user the available `release-*` branches and stop:

```shell
git -C <source-repo> branch --list 'release-*'
```

**In-repo versioned migrations only** — confirm the release branch exists:

```shell
git -C <repo> branch --list release-<version>
```

If the branch is not listed, show the user the available `release-*` branches and stop:

```shell
git -C <repo> branch --list 'release-*'
```

**Unversioned migrations only** — confirm the source content subdirectory exists:

```shell
ls <source-repo>/<content-subdir>
```

If it is missing, report the error and ask the user to correct the subdirectory path.

Confirm the source `menu.toml` exists:

```shell
ls <source-repo>/config/_default/menu.toml
```

If it is missing, report the error and stop.

---

## Stage 1: Copy files

### Set up the working tree

**Versioned migrations** — check for uncommitted changes that would be lost before
checking out:

```shell
git -C <source-repo> status --short
```

If there are uncommitted changes, warn the user and ask for confirmation before
proceeding. Do not discard changes without explicit permission.

Check out the release branch:

```shell
git -C <source-repo> checkout release-<version>
```

If the checkout fails, show the error and stop.

**Unversioned migrations** — confirm the working tree is clean before copying:

```shell
git -C <source-repo> status --short
```

If there are uncommitted changes, warn the user and ask for confirmation before proceeding.

**In-repo versioned migrations** — confirm `main` is checked out and the working tree is
clean:

```shell
git -C <repo> branch --show-current
git -C <repo> status --short
```

If the working tree has uncommitted changes, warn the user and ask for confirmation before
proceeding. Do not discard changes without explicit permission.

Add the release branch as a git worktree at the temporary path so you can access its
files without switching branches:

```shell
git -C <repo> worktree add <worktree-path> release-<version>
```

If the worktree add fails, show the error and stop.

### Create target directories

**Versioned:**

```shell
mkdir -p <target-repo>/content/<product>/<version>
mkdir -p <target-repo>/static/<product>/<version>/images
```

**Unversioned:**

```shell
mkdir -p <target-repo>/content/<product>
mkdir -p <target-repo>/static/<product>/images
```

**In-repo versioned:**

```shell
mkdir -p <repo>/content/<product>/<version>
mkdir -p <repo>/static/<product>/<version>/images
```

### Copy content files

Copy everything under the source content subdirectory to the content target directory,
including `reusable_text/` and similar directories that contain Hugo partial content
referenced by `readfile` shortcodes. These files must be present at their new paths so
the shortcode references updated in Stage 4c resolve correctly.

**Versioned:**

```shell
rsync -av \
  <source-repo>/content/ \
  <target-repo>/content/<product>/<version>/
```

**Unversioned:**

```shell
rsync -av \
  <source-repo>/<content-subdir>/ \
  <target-repo>/content/<product>/
```

**In-repo versioned** — copy from the worktree checked out in the previous step:

```shell
rsync -av \
  <worktree-path>/content/ \
  <repo>/content/<product>/<version>/
```

### Copy static files

**Versioned:**

```shell
rsync -av \
  <source-repo>/static/images/ \
  <target-repo>/static/<product>/<version>/images/
```

**Unversioned** — adjust the source path to match the source repo's static directory
location (commonly `static/images/` or `docs-chef-io/static/images/`):

```shell
rsync -av \
  <source-repo>/<static-subdir>/images/ \
  <target-repo>/static/<product>/images/
```

**In-repo versioned** — copy from the worktree, then remove the worktree:

```shell
rsync -av \
  <worktree-path>/static/images/ \
  <repo>/static/<product>/<version>/images/
```

After the rsync completes, remove the worktree:

```shell
git -C <repo> worktree remove <worktree-path>
```

### Verify the copy

**Versioned:**

```shell
ls <target-repo>/content/<product>/<version>/ | head -20
ls <target-repo>/static/<product>/<version>/images/ | head -10
```

Count the migrated Markdown files and report the count to the user before continuing:

```shell
find <target-repo>/content/<product>/<version> -name "*.md" | wc -l
```

**Unversioned:**

```shell
ls <target-repo>/content/<product>/ | head -20
ls <target-repo>/static/<product>/images/ | head -10
```

```shell
find <target-repo>/content/<product> -name "*.md" | wc -l
```

**In-repo versioned:**

```shell
ls <repo>/content/<product>/<version>/ | head -20
ls <repo>/static/<product>/<version>/images/ | head -10
```

```shell
find <repo>/content/<product>/<version> -name "*.md" | wc -l
```

---

## Stage 2: Update frontmatter in migrated files

Every Markdown file in the source repo uses TOML frontmatter delimited by `+++`. Files
that appear in the left-nav have a `[menu.X]` section binding them to a named menu. After
migration, all of these bindings must point to the single `[menu.<menu-name>]` menu.
Collisions with other products are avoided by using separate named menu tables, not by
prefixing identifiers. Some repos use fully qualified identifier paths as a convention
(for example `inspec/resources/aws/aws_s3_bucket`); others use short local names (for
example `get_started/enroll_nodes`). Preserve whichever convention the source repo uses.

### Step 2a: Discover source menu names

Before running any replacements, read the source `menu.toml` to identify all menu array
names used in that repo. Don't assume them — they vary by product.

**Versioned and unversioned migrations:**

```shell
grep '^\[\[' <source-repo>/config/_default/menu.toml | sort -u
```

**In-repo versioned migrations** — read from the release branch using `git show`:

```shell
git -C <repo> show release-<version>:config/_default/menu.toml | grep '^\[\[' | sort -u
```

This returns lines like `[[overview]]`, `[[get_started]]`, `[[aws]]`, `[[about]]`.
Exclude `[[main]]` from your replacement list — it's the site-wide navigation and should
not be renamed.

Confirm the source menu names with the user before continuing.

### Step 2b: Identify the source identifier convention

Check the identifier format used in a few source files to understand the convention
before running any replacements:

```shell
grep '^identifier = ' <target-repo>/content/<product>/*/about.md 2>/dev/null \
  || grep -r '^identifier = ' <target-repo>/content/<product>/ | head -5
```

Note whether identifiers use fully qualified paths (for example
`inspec/resources/aws/aws_s3_bucket resource`) or short local names (for example
`get_started/enroll_nodes`). Steps 2d and 2e are only needed if the source uses short
local names and you want to add a qualifying prefix for clarity. If identifiers are
already fully qualified, skip steps 2d and 2e and go directly to step 2f.

**Note**: For unversioned migrations, the content target path is
`<target-repo>/content/<product>/`. Replace `<target-repo>/content/<product>/<version>/`
with `<target-repo>/content/<product>/` in all commands in this stage.
For in-repo versioned migrations, replace `<target-repo>` with `<repo>` in all commands
in this stage.

Work on all `.md` files under the content target path.

### Step 2c: Rename menu section headers

Replace every `[menu.X]` line where `X` is any of the source menu names (from Step 2a)
with `[menu.<menu-name>]`. Build the alternation pattern from the source menu names you
identified. For example, for Chef 360 Platform:

```shell
find <target-repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' \
    's/^\[menu\.\(overview\|get_started\|install\|console\|chef_360_ui\|user_guide\|reference\)\]$/[menu.<menu-name>]/g' \
  {} +
```

On Linux, omit the `''` after `-i`.

Verify the replacement by checking for any remaining old menu names:

```shell
grep -r '^\[menu\.' <target-repo>/content/<product>/<version> | grep -v '<menu-name>'
```

If any lines are returned, those files still reference an old menu name. Fix them
manually before continuing.

### Step 2d: Prefix identifier values (optional)

If the source uses short local identifier names and you want to qualify them with the
menu name, prefix every `identifier = "X"` with `<menu-name>/`:

```shell
find <target-repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' 's/^identifier = "\([^"]*\)"/identifier = "<menu-name>\/\1"/g' {} +
```

### Step 2e: Prefix parent values (optional)

If you ran step 2d, also update every `parent = "X"` to match the prefixed identifiers:

```shell
find <target-repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' 's/^parent = "\([^"]*\)"/parent = "<menu-name>\/\1"/g' {} +
```

### Step 2f: Verify frontmatter updates

Spot-check three files — one top-level section index, one nested page, and one leaf
page — and confirm the frontmatter is correct. A correctly migrated frontmatter block
for a versioned migration looks like this:

```toml
+++
title = "Enroll nodes"

[menu.360_1_6]
title = "Enroll nodes"
identifier = "360_1_6/get_started/enroll_nodes"
parent = "360_1_6/get_started"
weight = 60
+++
```

For an unversioned migration, the same block would look like:

```toml
+++
title = "aws_s3_bucket resource"

[menu.aws]
title = "aws_s3_bucket"
identifier = "inspec/resources/aws/aws_s3_bucket"
parent = "inspec/resources/aws"
+++
```

### Step 2g: Update cascade params in _index.md

The `_index.md` file at the root of the migrated content directory requires a
`[cascade.params]` section that configures search, navigation, and version-selector
behavior for the entire section.

**Versioned**: `<target-repo>/content/<product>/<version>/_index.md`
**Unversioned**: `<target-repo>/content/<product>/_index.md`

Check whether this file exists after the rsync copy:

```shell
ls <target-repo>/content/<product>/<version>/_index.md   # versioned
ls <target-repo>/content/<product>/_index.md              # unversioned
```

If the file is missing, create it with at least a `title` in the frontmatter before
adding the cascade section.

#### Look up the swiftype_search_products value

Find the search product key for the migrated product in the source repo's
`config/_default/params.toml`:

```shell
grep -A5 '\[search\.products\.' <source-repo>/config/_default/params.toml \
  | grep -A4 '<product>'
```

For versioned products, the value is the `product_version_key` for the migrated version
(for example `"client-19"`). For unversioned products without version entries, use the
`product_key` (for example `"inspec"`).

#### Add or update the [cascade.params] section

Add the following block inside the `+++` frontmatter of `_index.md`, replacing the
placeholder values with the actual values for this migration:

```toml
[cascade]
  [cascade.params]
    swiftype_search_products = ["<swiftype-key>"]
    version_selector_product = "<product>"
    version_selector = true
    this_version_text = "<Full Product Name> <version>"
    section_root = "/<product>/<version>"
    menu_id = "<menu-name>"
    breadcrumbs = true
    st_robots = ''
```

Field reference:

- `swiftype_search_products` — the `product_version_key` value from `params.toml` for
  this version (for example `["client-19"]`); for unversioned products, use the
  `product_key` (for example `["inspec"]`)
- `version_selector_product` — the product short name without a version (for example
  `client`); same as the `product_key` in `params.toml`
- `version_selector` — set to `true` for versioned migrations; set to `false` or omit
  for unversioned products that don't have a version switcher
- `this_version_text` — the full product display name and version as it should appear in
  the UI (for example `"Chef Infra Client 19"`)
- `section_root` — the URL path to the root of this content section (for example
  `"/client/19"` for versioned, `"/inspec"` for unversioned)
- `menu_id` — the `<menu-name>` value used in `menu.toml` and the frontmatter `[menu.X]`
  sections (for example `client_19` or `aws`)
- `breadcrumbs` — set to `true`
- `st_robots` — set to an empty string (`''`)

After editing, confirm the section is syntactically correct by checking that the
frontmatter opens and closes with `+++` and that the TOML is properly indented.

### Step 2h: Add version entry to params.toml (versioned and in-repo versioned migrations only)

For **unversioned migrations**, skip this step.

The target repo's `config/_default/params.toml` contains a `[[versions.<product>]]`
array that drives the version switcher UI. Each entry maps a display label to a URL.
You must add an entry for the new version.

Read the existing version entries for the product:

```shell
grep -A3 '^\[\[versions\.<product>\]\]' <target-repo>/config/_default/params.toml
```

If no entries exist for `<product>` yet, add a new block at the end of the versioned
products section. If entries exist, add the new version in the correct position — newer
versions should appear before older versions.

The new entry follows this pattern:

```toml
[[versions.<product>]]
link_text = "<Full Product Name> <version>"
base_url = "/<product>/<version>/"
```

For example, for Chef Infra Client 19:

```toml
[[versions.client]]
link_text = "Chef Infra Client 19"
base_url = "/client/19/"
```

After adding the entry, verify the block looks correct:

```shell
grep -A3 '^\[\[versions\.<product>\]\]' <target-repo>/config/_default/params.toml
```

---

## Stage 3: Update menu.toml in target

### Step 3a: Read the source menu

Read the source `config/_default/menu.toml` in full.

**Versioned and unversioned migrations:**

```shell
cat <source-repo>/config/_default/menu.toml
```

**In-repo versioned migrations** — read from the release branch using `git show`:

```shell
git -C <repo> show release-<version>:config/_default/menu.toml
```

Identify all menu arrays that are **not** `[[main]]`. These are the arrays you'll
transform. The names vary by product — use the output of Step 2a to confirm them.

### Step 3b: Build the new menu section

Construct a new TOML section for `[[<menu-name>]]` by transforming every non-`[[main]]`
entry from the source:

1. Replace every array table header (for example `[[user_guide]]` or `[[aws]]`) with
   `[[<menu-name>]]`.
2. If the source uses short local identifier names and you applied prefixing in Step 2d,
   prefix every `identifier` value with `<menu-name>/`:
   `identifier = "guide/courier"` → `identifier = "<menu-name>/guide/courier"`
   Otherwise, preserve the identifiers as-is from the source.
3. If you applied prefixing in Step 2d, also prefix every `parent` value with
   `<menu-name>/`:
   `parent = "guide"` → `parent = "<menu-name>/guide"`
   Otherwise, preserve parent values as-is.
4. For any entry that doesn't have a `weight` field, add one. Assign weights
   incrementally by 10 within each parent group, starting from `weight = 10`.

**Versioned migration** — the resulting section follows this pattern:

```toml
####
# Chef 360 Platform <version> Menu
####

[[<menu-name>]]
title = "Overview"
identifier = "<menu-name>/overview"
weight = 10

  [[<menu-name>]]
  title = "Architecture"
  identifier = "<menu-name>/overview/architecture"
  parent = "<menu-name>/overview"
  weight = 10

[[<menu-name>]]
title = "Get started"
identifier = "<menu-name>/get_started"
weight = 20

...

####
# End Chef 360 Platform <version> Menu
####
```

**Unversioned migration** — the resulting section follows the same pattern but without
version components in identifiers:

```toml
####
# Chef InSpec AWS Resource Pack Menu
####

[[aws]]
title = "AWS"
identifier = "inspec/resources/aws"
weight = 10

  [[aws]]
  title = "About AWS resources"
  identifier = "inspec/resources/aws/About"
  parent = "inspec/resources/aws"
  weight = 10

  [[aws]]
  title = "aws_s3_bucket"
  identifier = "inspec/resources/aws/aws_s3_bucket resource"
  parent = "inspec/resources/aws"
  weight = 20

...

####
# End Chef InSpec AWS Resource Pack Menu
####
```

### Step 3c: Confirm and append

Show the user the complete new section before making any changes. Ask for confirmation
before writing to the file.

After confirmation, append the new section to the target `menu.toml`:

- **Versioned and unversioned migrations**: `<target-repo>/config/_default/menu.toml`
- **In-repo versioned migrations**: `<repo>/config/_default/menu.toml`

Add it after the last existing `[[<product>_*]]` version menu block (versioned and in-repo versioned), or after
the `[[<product>]]` version switcher block (unversioned), or at the end of the file if
neither exists yet.

### Step 3d: Update the version switcher (versioned and in-repo versioned migrations only)

For **unversioned migrations**, skip this step.

Read the `[[<product>]]` version switcher block in the target `menu.toml`
(`<target-repo>/config/_default/menu.toml` for versioned migrations,
`<repo>/config/_default/menu.toml` for in-repo versioned migrations).
Check whether an entry for the version being migrated already exists by looking for
`url = "/<product>/<version>/"` (for example `url = "/360/1.6/"`).

If the entry is missing, add it. Determine the correct `weight` by reviewing the existing
version entries — lower weight = higher position in the list = newer version. Insert the
new entry at the weight that reflects its position relative to other versions.

The new entry follows this format:

```toml
  [[<product>]]
  title = "version <version>"
  parent = "<product>"
  identifier = "<product>/<version>"
  url = "/<product>/<version>/"
  weight = <next-weight>
```

---

## Stage 4: Rewrite links in migrated files

All link rewrites apply to every `.md` file under the content target path:

- **Versioned**: `<target-repo>/content/<product>/<version>/`
- **Unversioned**: `<target-repo>/content/<product>/`
- **In-repo versioned**: `<repo>/content/<product>/<version>/`

Use the appropriate path in all commands in this stage.

### Step 4a: Rewrite absolute internal content links

In the source repo, internal links used absolute paths relative to the site root, for
example `[Install](/install/)`. After migration, these links must include the product
prefix — and version prefix for versioned migrations:

- **Versioned**: `[Install](/<product>/<version>/install/)`
- **Unversioned**: `[Install](/<product>/install/)`

First, find all candidate absolute links — paths starting with `/` that don't already
include `/<product>/` and aren't external (`http://` or `https://`):

**Versioned:**

```shell
grep -rn '](/' <target-repo>/content/<product>/<version>/ \
  | grep -v '](/<product>/' \
  | grep -v '](https\?://'
```

**Unversioned:**

```shell
grep -rn '](/' <target-repo>/content/<product>/ \
  | grep -v '](/<product>/' \
  | grep -v '](https\?://'
```

Review the output and identify any false positives — for example, links that intentionally
point to other products and shouldn't be prefixed. If you find any, note the files so you
can skip them or handle them manually in the verification step.

Run the rewrite for all remaining absolute links:

**Versioned:**

```shell
find <target-repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' 's|](\(/[^)]*\))|](/<product>/<version>\1)|g' {} +
```

**Unversioned:**

```shell
find <target-repo>/content/<product> -name "*.md" -exec \
  sed -i '' 's|](\(/[^)]*\))|](/<product>\1)|g' {} +
```

On Linux, omit the `''` after `-i`.

Verify the rewrite by running the grep again. The output should be empty or contain
only intentional exceptions.

### Step 4b: Confirm image path rewrites

Image references follow the same pattern as content links and are covered by Step 4a.
Confirm by checking for any remaining unprefixed image references:

**Versioned:**

```shell
grep -rn '](/images/' <target-repo>/content/<product>/<version>/
```

**Unversioned:**

```shell
grep -rn '](/images/' <target-repo>/content/<product>/
```

Any remaining matches indicate image links that weren't caught by the substitution.
Fix them manually.

### Step 4c: Rewrite readfile shortcode paths

Files that use `{{< readfile >}}` or `{{% readfile %}}` shortcodes reference reusable
content by file path relative to the repo root. In the source repo, a call looks like
this:

```
{{< readfile file="content/reusable_text/example.md" >}}
```

Because the reusable files were copied into the migrated directory in Stage 1, every
path must be updated to include the product prefix — and version prefix for versioned
migrations:

- **Versioned**: `file="content/reusable_text/..."` → `file="content/<product>/<version>/reusable_text/..."`
- **Unversioned**: `file="content/reusable_text/..."` → `file="content/<product>/reusable_text/..."`

Find all readfile shortcodes in the migrated files:

**Versioned:**

```shell
grep -rn 'readfile file=' <target-repo>/content/<product>/<version>/
```

**Unversioned:**

```shell
grep -rn 'readfile file=' <target-repo>/content/<product>/
```

Rewrite all paths that start with `content/`:

**Versioned:**

```shell
find <target-repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' \
    's|readfile file="content/|readfile file="content/<product>/<version>/|g' \
  {} +
```

**Unversioned:**

```shell
find <target-repo>/content/<product> -name "*.md" -exec \
  sed -i '' \
    's|readfile file="content/|readfile file="content/<product>/|g' \
  {} +
```

On Linux, omit the `''` after `-i`.

Verify — the output should be empty:

**Versioned:**

```shell
grep -rn 'readfile file="content/' <target-repo>/content/<product>/<version>/ \
  | grep -v 'readfile file="content/<product>/<version>/'
```

**Unversioned:**

```shell
grep -rn 'readfile file="content/' <target-repo>/content/<product>/ \
  | grep -v 'readfile file="content/<product>/'
```

Any remaining matches reference content at a path that wasn't covered by the substitution.
Review each one — the path may use a different prefix or point to shared content outside
the migrated directory. Fix the path manually or flag it with a TODO comment:

```markdown
<!-- TODO: verify readfile path — may need updating after migration -->
```

---

## Stage 5: Strip docs.chef.io domain from cross-product links

In the source repo, links to other Chef products included the full domain name because
the source repo was served as a standalone site. In `chef/chef-web-docs`, all Chef
products are served from the same domain, so the domain prefix can be removed.

This stage applies to all three migration types. Use the content target path for your
migration type in all commands.

### Step 5a: Find all docs.chef.io links

**Versioned:**

```shell
grep -rn 'https://docs\.chef\.io' <target-repo>/content/<product>/<version>/
```

**Unversioned:**

```shell
grep -rn 'https://docs\.chef\.io' <target-repo>/content/<product>/
```

**In-repo versioned:**

```shell
grep -rn 'https://docs\.chef\.io' <repo>/content/<product>/<version>/
```

Review the output before running any replacements. Confirm that none of the matched links
point to anchored sections that may have moved or been renamed during migration.

### Step 5b: Strip the domain

**Versioned:**

```shell
find <target-repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' 's|https://docs\.chef\.io/|/|g' {} +
```

**Unversioned:**

```shell
find <target-repo>/content/<product> -name "*.md" -exec \
  sed -i '' 's|https://docs\.chef\.io/|/|g' {} +
```

**In-repo versioned:**

```shell
find <repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' 's|https://docs\.chef\.io/|/|g' {} +
```

Verify — the output should be empty:

**Versioned:**

```shell
grep -rn 'https://docs\.chef\.io' <target-repo>/content/<product>/<version>/
```

**Unversioned:**

```shell
grep -rn 'https://docs\.chef\.io' <target-repo>/content/<product>/
```

**In-repo versioned:**

```shell
grep -rn 'https://docs\.chef\.io' <repo>/content/<product>/<version>/
```

If any remain, they may be inside fenced code blocks or HTML comments. Review and fix
them manually.

---

## Verification

After all stages complete, verify the migration before committing:

1. **Build locally**: Run the Hugo dev server in the target repo and confirm pages load:

   **Versioned and unversioned migrations:**

   ```shell
   cd <target-repo> && hugo server
   ```

   **In-repo versioned migrations:**

   ```shell
   cd <repo> && hugo server
   ```

   Open the migrated section in a browser and confirm:

   - **Versioned**: `http://localhost:1313/<product>/<version>/`
   - **Unversioned**: `http://localhost:1313/<product>/`
   - **In-repo versioned**: `http://localhost:1313/<product>/<version>/`

   Confirm:
   - The section loads without errors
   - The left-nav menu appears and is structured correctly
   - Images render correctly on content pages

2. **Check links**: Run the `fix-broken-links` skill against the locally served site,
   scoped to the product path, to catch any links that weren't updated.

3. **Spot-check pages**: Manually verify at least three pages — choose a section index, a
   deeply nested content page, and a page with images and cross-product links.

4. **Confirm menu** *(versioned and in-repo versioned only)*: Confirm the version appears
   in the version switcher on the product landing page.

---

## Final output

After all stages complete, return a `## Migration summary` section with:

- Migration type: versioned, unversioned, or in-repo versioned
- Source repo (or repo, for in-repo versioned), branch (versioned and in-repo versioned)
  or default branch (unversioned), and content paths
- Target repo and content and static paths
- Number of Markdown content files migrated
- Number of static files migrated
- Frontmatter updates: count of files updated
- Menu entries added to `menu.toml`: count of `[[<menu-name>]]` entries added
- Link rewrites: count of internal content links updated
- Image path rewrites: count of image paths updated
- Shortcode path rewrites: count of `readfile` paths updated
- `docs.chef.io` links stripped: count
- Files that need manual review: list any files with unresolved `readfile` paths,
  skipped links, or items where automatic rewriting produced unexpected results
