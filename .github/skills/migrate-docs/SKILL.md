---
name: migrate-docs
description: 'Migrate Chef documentation from a source repo to a product subdirectory in the chef/chef-web-docs main branch, reorganize content within a single repository, or unversion content from a release branch. Supports versioned repos (branch-based, with a product/version directory structure), unversioned repos (default branch, flat product directory), in-repo versioned migrations (release branch to product/version subdirectory in the same repo), and in-repo reorganization (content root to product/version subdirectory on the same branch). Imports one version, an explicit version list, or all discovered release versions in one batch for branch-based migrations, with shared configuration updates and final validation after all imports. Copies or moves content and static files, updates frontmatter menu references, transforms menu.toml, rewrites internal links, and strips the docs.chef.io domain from cross-product links (skipped for in-repo reorganization). Triggers on: migrate docs, versioned docs migration, unversioned docs migration, branch to subdirectory, docs migration, move versioned content, migrate unversioned content, reorganize docs, migrate versioned documentation, in-repo versioned migration, unversion content, same-repository migration, in-repo content migration, in-repo reorganization, reorganize content, move to versioned subdirectory, in-repo content reorganization, batch import docs, migrate all versions, import multiple versions.'
argument-hint: "Migration type (versioned, unversioned, in-repo, or reorganize), product short name, version or comma-separated versions or all (branch-based migrations), source or repo path, and target repo path. Examples: 'versioned inspec all /path/to/chef-inspec-docs /path/to/chef-web-docs', 'versioned inspec 7.3,7.2,6.8 /path/to/chef-inspec-docs /path/to/chef-web-docs', 'unversioned inspec /path/to/source-repo /path/to/chef-web-docs', 'in-repo 360 all /path/to/repo', or 'reorganize 360 1.6 /path/to/repo'"
---

# Migrate docs to a product subdirectory

Runs a workflow to migrate documentation from a source repo to the
unified `chef/chef-web-docs` main branch, or to reorganize content within a single
repository. Supports four migration types:

- **Versioned** — source content lives on a `release-<version>` branch; target uses a
  `content/<product>/<version>/` directory structure in `chef/chef-web-docs`
- **Unversioned** — source content lives on the default branch; target uses a
  `content/<product>/` directory structure with no version component in `chef/chef-web-docs`
- **In-repo versioned** — source content lives on a `release-<version>` branch in the
  same repo as the target; target uses a `content/<product>/<version>/` directory structure
  in the `main` branch of the same repo
- **In-repo reorganization** — content is reorganized within the same repo on the same
  branch; content moves from `content/` to `content/<product>/<version>/` and static files
  move from `static/images/` to `static/<product>/<version>/images/`; the
  `docs.chef.io` domain-stripping stage is skipped for this type

Versioned and in-repo versioned migrations accept one version, a comma-separated version
list, or `all` to import every discovered release version in one invocation.
Unversioned migrations and in-repo reorganization remain single-import workflows.

Stages:

1. **Gather inputs and validate** — collects required inputs and confirms the repo or repos exist
2. **Copy or move files** — sets up the working tree and copies or moves content and static files to the target directory
3. **Update frontmatter** — rewrites `[menu.X]` references and `identifier`/`parent` values in every migrated file
4. **Update menu.toml** — merges source menu sections into a single menu in the target; adds the version to the version switcher (versioned, in-repo versioned, and in-repo reorganization only)
5. **Rewrite links** — updates internal content links, image paths, and shortcode file paths
6. **Strip docs.chef.io domain** — removes the `docs.chef.io` domain from cross-product links (versioned, unversioned, and in-repo versioned only; skip for in-repo reorganization)

For a batch, follow [Batch execution](#batch-execution) instead of completing the entire
workflow, including verification, separately for each version.

---

## Stage 0: Gather inputs and validate

Ask the user for the following if not already provided:

1. **Migration type** — versioned, unversioned, in-repo versioned, or in-repo reorganization:
   - **Versioned**: source content is on a `release-<version>` branch in a separate source
     repo; target uses `content/<product>/<version>/` in `chef/chef-web-docs`
   - **Unversioned**: source content is on the default branch of a separate source repo;
     target uses `content/<product>/` with no version component in `chef/chef-web-docs`
   - **In-repo versioned**: source content is on a `release-<version>` branch in the same
     repo as the target; target uses `content/<product>/<version>/` in the `main` branch
     of the same repo
   - **In-repo reorganization**: content in `content/` moves to
     `content/<product>/<version>/` on the same branch; there is no separate source or
     target repo — one repo path serves as both

2. **Product short name** — the short identifier used in the URL and directory path, for
   example `360` for Chef 360 Platform or `inspec` for Chef InSpec.

   **In-repo reorganization** — after the user provides the product short name, confirm
   it's correct by checking whether it already appears in the repo's config files:

   ```shell
   grep -r '<product>' <repo>/config/_default/params.toml
   grep -r '<product>' <repo>/config/_default/menu.toml
   ```

   If the product name doesn't appear, that's expected for the first version being added.
   Confirm the intended directory path with the user: `content/<product>/<version>/`.

3. **Version selection** _(versioned and in-repo versioned migrations)_---one version
   (for example `1.6`), a comma-separated list (for example `7.3,7.2,6.8`), or `all`.
   Discover and confirm the exact versions before importing when the user requests all
   versions or provides a list.
   **In-repo reorganization** accepts exactly one version; don't repeat a root-content
   move for multiple versions.

4. **Source repo path** *(versioned, unversioned, and in-repo versioned migrations only)* —
   the absolute path to the local clone of the source documentation repository, for example
   `/Users/me/code/progress-platform-services/chef-web-docs` or
   `/Users/me/code/inspec/chef-inspec-resource-docs`.

   **In-repo reorganization** — skip this item. Provide a **repo path** instead (see item 7).

5. **Source content subdirectory** *(unversioned migrations only)* — the subdirectory
   within the source repo where content lives. Common values:
   - `content/` — used by repos where docs are the entire repository
   - `docs-chef-io/content/` — used by repos where docs live alongside product code

   If the user is unsure, check the source repo structure:

   ```shell
   ls <source-repo>/content 2>/dev/null || ls <source-repo>/docs-chef-io/content
   ```

6. **Target repo path** *(versioned and unversioned migrations only)* — the absolute path
   to the local clone of `chef/chef-web-docs`, for example
   `/Users/me/code/chef/chef-web-docs`.

7. **Repo path** *(in-repo reorganization only)* — the absolute path to the local clone of
   the repository being reorganized, for example
   `/Users/me/code/progress-platform-services/chef-web-docs`. This path serves as both
   source and target.

### Resolve the version selection

For version lists and `all` in versioned and in-repo versioned migrations, list local
and remote-tracking release branches once:

```shell
git -C <SOURCE_REPO> for-each-ref --format='%(refname)' 'refs/heads/release-*' 'refs/remotes/*/release-*'
```

Replace `<SOURCE_REPO>` with the source repository path, or the shared repository path
for an in-repo versioned migration.
This discovers refs already available locally; it doesn't fetch or create local branches.
If the expected refs aren't available, report that and ask whether to fetch before
continuing.

- Extract the version suffix from each `release-<version>` branch.
  For `all`, select numeric versions such as `5.23` and `7.3`; flag other suffixes for
  clarification rather than silently treating maintenance branches as versions.
- Deduplicate local and remote-tracking copies of the same version.
  Prefer the local branch only when its commit matches the remote-tracking copies.
  If refs for the same version point to different commits, record the conflict and ask
  which ref to use before importing that version.
  Resolve destination collisions first so an already migrated version can be excluded
  without choosing a source commit unnecessarily.
- For an explicit list, trim whitespace, deduplicate versions, and resolve only those
  requested.
  If any version remaining in the approved import queue is missing or ambiguous, stop
  before importing anything.
- Sort the selected versions newest first using numeric version components, not
  alphabetical or decimal-number ordering; for example, `7.10` precedes `7.3`.
- Record each selected version's full ref and resolved commit ID.
  Use the recorded commit throughout the import so a moving ref can't change the source
  halfway through the batch.

For example, a checkout with `release-5.23`, `release-5.24`, `release-6.8`,
`release-7.0`, `release-7.1`, `release-7.2`, and `release-7.3` produces seven imports,
ordered `7.3,7.2,7.1,7.0,6.8,5.24,5.23`.
Don't hard-code this example list or count.

### Derive migration identifiers

From the inputs, derive the following values and confirm them with the user before
continuing:

For a batch, derive a separate set of identifiers for each selected version.
Confirm the complete version-to-ref, commit, menu, content, and static path mapping in
one plan rather than asking for each version separately.

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

**In-repo reorganization:**

- **Branch name**: current branch (no checkout needed; confirm it is not `main`)
- **Menu name**: `<product>_<version>` with all dots replaced by underscores — for
  example `360_1_6` for product `360` and version `1.6`
- **Repo path**: `<repo>` — the single path provided in item 7 above
- **Source content path**: `<repo>/content/`
- **Content target path**: `<repo>/content/<product>/<version>/`
- **Static source path**: `<repo>/static/images/`
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

**In-repo reorganization** — confirm the repo exists and is a valid git repository:

```shell
ls <repo>/.git
```

If the check fails, stop and ask the user to correct the path.

**In-repo reorganization only**---confirm the current branch is not `main`:

```shell
git -C <repo> branch --show-current
```

If the current branch is `main`, warn the user that in-repo reorganization should be done
on a dedicated reorganization branch, not directly on `main`. Ask for confirmation before
continuing.

Check whether the target content directory already exists (indicating a partial move is
already in progress):

```shell
ls <repo>/content/<product> 2>/dev/null
```

If the directory exists, warn the user and ask for confirmation before continuing.

### Detect destination collisions

For both single-version and batch branch-based migrations, inspect every proposed
destination before creating directories, worktrees, or copied files.
Check the content target `content/<product>/<version>/` and the static version root
`static/<product>/<version>/` in the target repository, including untracked and hidden
entries.
Don't infer that a version is unmigrated just because its configuration is missing.

If a destination exists and is a directory, check for any entry, not just Markdown files:

```shell
find <DESTINATION_PATH> -mindepth 1 -maxdepth 1 -print -quit
```

Replace `<DESTINATION_PATH>` with each resolved content or static destination path.
Any output means the directory is nonempty and the version has a collision.
An absent or empty directory alone isn't a content collision.
Treat a file or symlink at a destination, or an inspection error such as a permissions
failure, as blocking rather than treating it as an empty directory.
Check existing menu and version-switcher entries separately for configuration conflicts.

Report all collisions together, with the version and occupied paths.
Ask the user to exclude those versions from this invocation, stop, or explicitly approve
a scoped replacement or resumption plan.
Recommend excluding versions already migrated; never silently overwrite, merge, delete,
or rerun transformations on their content.
An instruction to import `all` isn't permission to replace existing content.

After the user approves exclusions, remove those versions from the import queue and
leave their content, static files, menus, and version entries unchanged.
For example, if `7.3` already has content, report it as a collision and, with approval,
import only `7.2,7.1,7.0,6.8,5.24,5.23`.
Record excluded versions separately from successful imports and don't count them in
batch totals.
If no versions remain, report that there's nothing to import and stop without editing
files or running final validation.

Recheck destinations immediately before each version's Stage 1 directory creation and
copy.
If a previously empty destination now contains entries, stop for a new decision rather
than letting `rsync` merge or overwrite files.

### Validate source snapshots

For batches, validate every selected commit before creating any target files.
Validate only versions remaining in the approved import queue after collision handling.
Complete these checks before importing:

- Confirm its `content/`, `config/_default/menu.toml`, and
  `config/_default/params.toml` exist using `git ls-tree` and `git show`.
  Check whether `static/images/` exists; if it doesn't, confirm that no images need to
  be copied rather than letting an unexpected copy error pass.
  Skip that version's static copy only when the absence is confirmed and recorded.
- Read menu names, identifier conventions, and search product/version keys from that
  commit, not from the source checkout or another release.
  Don't assume these values stay the same between versions.
- Inspect the target working tree and resolve any remaining configuration conflicts
  for every selected version before writing.
- Confirm distinct versions produce distinct target paths and menu names.
  Stop on collisions or missing required inputs.

The branch and source-file checks below apply to single imports.
For batches, the commit-based checks above replace them, including the final
source-checkout `menu.toml` check.

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

## Batch execution

Use this execution order for version lists and `all` in versioned or in-repo versioned
migrations.
Keep the batch workflow even if discovery or approved exclusions leave only one version.
A request for one explicit version uses the existing single-import workflow.

1. Complete Stage 0 once for the entire selection.
   Record the approved plan, existing target changes, and per-version progress in session
   state outside the target content tree.
   Collect confirmations for source menu names and identifier conventions together.
1. Process each selected version sequentially through Stages 1–5, with the shared writes
   below deferred.
   Scope every copy, transformation, and local check to that version's destination.
   Complete its content transformations before starting the next version; don't run
   replacements across the entire product directory.
1. Apply the accumulated shared configuration changes once, after every selected
   version completes its content stages.
1. Run [Verification](#verification) once for the completed batch, using one site build
   and preview server, with coverage for every selected version.
1. Return one combined migration summary with per-version results and batch totals.

Sequential per-version transformations keep source-specific rules isolated and bound
temporary disk use.
Batch repository discovery, confirmations, shared configuration writes, and site
validation instead of parallelizing writes to shared target files.
Don't claim a speed improvement without measuring it.

### Keep source snapshots isolated

For both branch-based migration types, create a temporary detached worktree for the
current version's recorded commit instead of checking out branches in the source
working tree:

```shell
git -C <SOURCE_REPO> worktree add --detach <WORKTREE_PATH> <SOURCE_COMMIT>
```

Replace the following:

- `<SOURCE_REPO>`: the source repository path, or the shared repository path for in-repo migrations
- `<WORKTREE_PATH>`: a unique, unused temporary path outside the source and target repositories
- `<SOURCE_COMMIT>`: the commit ID recorded for this version in Stage 0

For batch imports, this overrides Stage 1's checkout and worktree setup instructions.
Use this worktree for every source read in Stages 1–5, including content, images, menus,
and search/version parameters.
Keep it until all source reads and local transformations for that version finish;
don't remove it immediately after copying static files.
Then remove only this skill-created worktree with `git worktree remove` before
processing the next version.
Don't use force removal or change the source checkout.
If cleanup fails, report the error and preserve the worktree for inspection.

### Defer shared configuration writes

During each version's content stages:

- Run Stage 2g using that version's source search keys and write its cascade only to its
  own destination `_index.md`.
- Prepare the Stage 2h `params.toml` version entry without writing it.
- Read and transform that version's source menu in Stages 3a and 3b, but defer the
  Stage 3c confirmation and write and the Stage 3d version-switcher write.
- Keep Stage 1's copy checks and Stages 2–5's scoped transformation checks.
  These catch import errors early; they're not the final build, browser, or link check.

After all versions finish, combine the prepared changes with the target's existing
`menu.toml` and `params.toml`.
Preserve unrelated configuration and any pre-existing target edits.
Show the complete combined configuration diff and request one confirmation before
writing either file.
If the user declines, leave configuration unapplied and report the batch as incomplete.

Apply approved additions in one editing pass per shared file.
Add each version's menu and switcher entries exactly once; reuse an existing entry only
if it matches the intended configuration.
Ask before replacing a conflicting entry.
Order version entries newest first by numeric components, and assign menu switcher
weights consistently with that order, including existing versions.
If that requires editing an excluded version's entry, show the conflict and request
approval rather than changing the excluded entry.
Don't change which version is the default unless the user approves that change.

### Handle failures and interrupted batches

If preflight or a per-version step fails, stop and report the version, stage, error, and
paths already changed.
Don't silently skip a version, apply incomplete shared configuration, or start final
validation while selected imports remain unfinished.
Preserve completed imports and unrelated working-tree changes; don't roll back or delete
them automatically.
Clean up only skill-created worktrees when safe.

Record which versions completed content stages, whether shared configuration was applied,
and whether final validation passed.
On resumption, compare that state with the actual files and ask about discrepancies.
Don't rerun non-idempotent prefix or link substitutions on already transformed content.
Resume at the first unfinished operation; if a partial version needs a clean reimport,
get approval for the exact destination files to replace first.
Don't report success until every selected version and the final batch validation pass.

---

## Stage 1: Copy or move files

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

**In-repo reorganization** — confirm the current branch and that the working tree is
clean:

```shell
git -C <repo> branch --show-current
git -C <repo> status --short
```

If there are uncommitted changes, warn the user and ask for confirmation before
proceeding. Do not discard changes without explicit permission.

### Create target directories

For branch-based migrations, complete the destination collision check immediately before
this step, even for a single-version import.

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

**In-repo reorganization:**

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

**In-repo reorganization** — move all content from the `content/` root to the target
directory. The `content/<product>/` directory was just created, so exclude it from the
move to avoid trying to move a directory into itself:

```shell
find <repo>/content -maxdepth 1 -mindepth 1 -not -name '<product>' \
  -exec mv {} <repo>/content/<product>/<version>/ \;
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

**In-repo versioned** — copy from the worktree:

```shell
rsync -av \
  <worktree-path>/static/images/ \
  <repo>/static/<product>/<version>/images/
```

Keep the worktree until all source reads finish, including the search parameter lookup
in Stage 2g and the source menu read in Stage 3a.
For batches, follow the worktree lifetime in [Batch execution](#batch-execution).
After the final source read, remove the worktree:

```shell
git -C <repo> worktree remove <worktree-path>
```

**In-repo reorganization** — move all images from `static/images/` to the target
directory:

```shell
find <repo>/static/images -maxdepth 1 -mindepth 1 \
  -exec mv {} <repo>/static/<product>/<version>/images/ \;
```

### Stage the moves (in-repo reorganization only)

After moving files, stage all changes so Git can detect the renames. Git identifies
moved files as renames automatically when file-content similarity is 50% or higher.

```shell
git -C <repo> add -A
```

Confirm that Git recognized the moves as renames rather than deletions:

```shell
git -C <repo> status --short | head -20
```

Expect to see lines beginning with `R` (renamed). If you see only `D` (deleted) and `A`
(added) lines, Git didn't find matches above the similarity threshold. This is unusual
but can happen if files were heavily modified before the move. No action is required —
the files are still staged correctly; Git just won't record them as renames.

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

**In-repo reorganization:**

```shell
ls <repo>/content/<product>/<version>/ | head -20
ls <repo>/static/<product>/<version>/images/ | head -10
```

Count the moved Markdown files and report the count to the user before continuing:

```shell
find <repo>/content/<product>/<version> -name "*.md" | wc -l
```

Also confirm the `content/` root is now empty (or contains only the new `<product>/`
subdirectory):

```shell
ls <repo>/content/
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

For batches, read the current source worktree's `config/_default/menu.toml` instead of
using the source checkout or an unpinned release branch in the commands below.

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
grep -r '^identifier = ' <target-repo>/content/<product>/<version>/ | head -5
```

Note whether identifiers use fully qualified paths (for example
`inspec/resources/aws/aws_s3_bucket resource`) or short local names (for example
`get_started/enroll_nodes`). Steps 2d and 2e are only needed if the source uses short
local names and you want to add a qualifying prefix for clarity. If identifiers are
already fully qualified, skip steps 2d and 2e and go directly to step 2f.

**Note**: For unversioned migrations, the content target path is
`<target-repo>/content/<product>/`. Replace `<target-repo>/content/<product>/<version>/`
with `<target-repo>/content/<product>/` in all commands in this stage.
For in-repo versioned migrations and in-repo reorganization, replace `<target-repo>`
with `<repo>` in all commands in this stage.

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
**In-repo versioned**: `<repo>/content/<product>/<version>/_index.md`
**In-repo reorganization**: `<repo>/content/<product>/<version>/_index.md`

Check whether this file exists at the target path:

```shell
ls <target-repo>/content/<product>/<version>/_index.md   # versioned
ls <target-repo>/content/<product>/_index.md              # unversioned
ls <repo>/content/<product>/<version>/_index.md           # in-repo versioned and in-repo reorganization
```

If the file is missing, create it with at least a `title` in the frontmatter before
adding the cascade section.

**In-repo reorganization note**: The `_index.md` at the content root (`content/_index.md`)
was moved to `content/<product>/<version>/_index.md` in Stage 1 and should already exist
at the new path. If it didn't exist in the source, create it now.

#### Look up the swiftype_search_products value

Find the search product key for the migrated product in the repo's
`config/_default/params.toml`:

**Versioned and unversioned migrations:**

```shell
grep -A5 '\[search\.products\.' <source-repo>/config/_default/params.toml \
  | grep -A4 '<product>'
```

**In-repo versioned** (read from the source worktree, not the target's current branch):

```shell
grep -A5 '\[search\.products\.' <WORKTREE_PATH>/config/_default/params.toml
```

For a single in-repo import, `<WORKTREE_PATH>` is the temporary release worktree.
For batches, use the current version's source worktree for both branch-based migration
types, including in the versioned source-path command above.
Read the matching product and version entry, not another release's search key.

**In-repo reorganization:**

```shell
grep -A5 '\[search\.products\.' <repo>/config/_default/params.toml \
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
- `version_selector` — set to `true` for versioned, in-repo versioned, and in-repo
  reorganization migrations; set to `false` or omit for unversioned products that don't
  have a version switcher
- `this_version_text` — the full product display name and version as it should appear in
  the UI (for example `"Chef Infra Client 19"`)
- `section_root` — the URL path to the root of this content section (for example
  `"/client/19"` for versioned or in-repo reorganization, `"/inspec"` for unversioned)
- `menu_id` — the `<menu-name>` value used in `menu.toml` and the frontmatter `[menu.X]`
  sections (for example `client_19` or `aws`)
- `breadcrumbs` — set to `true`
- `st_robots` — set to an empty string (`''`)

After editing, confirm the section is syntactically correct by checking that the
frontmatter opens and closes with `+++` and that the TOML is properly indented.

### Step 2h: Add version entry to params.toml (versioned, in-repo versioned, and in-repo reorganization only)

For **unversioned migrations**, skip this step.
For batches, prepare this entry per version, but defer the write to the shared
configuration pass in [Batch execution](#batch-execution).

The repo's `config/_default/params.toml` contains a `[[versions.<product>]]`
array that drives the version switcher UI. Each entry maps a display label to a URL.
Add an entry for the new version.

Read the existing version entries for the product:

**Versioned migrations:**

```shell
grep -A3 '^\[\[versions\.<product>\]\]' <target-repo>/config/_default/params.toml
```

**In-repo versioned and in-repo reorganization:**

```shell
grep -A3 '^\[\[versions\.<product>\]\]' <repo>/config/_default/params.toml
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

**Versioned migrations:**

```shell
grep -A3 '^\[\[versions\.<product>\]\]' <target-repo>/config/_default/params.toml
```

**In-repo versioned and in-repo reorganization:**

```shell
grep -A3 '^\[\[versions\.<product>\]\]' <repo>/config/_default/params.toml
```

---

## Stage 3: Update menu.toml in target

### Step 3a: Read the source menu

Read the source `config/_default/menu.toml` in full.
For batches, read from the current source worktree, not from the source checkout or an
unpinned release branch in the commands below.

**Versioned and unversioned migrations:**

```shell
cat <source-repo>/config/_default/menu.toml
```

**In-repo versioned migrations** — read from the release branch using `git show`:

```shell
git -C <repo> show release-<version>:config/_default/menu.toml
```

**In-repo reorganization** — read from the current repo's `menu.toml`:

```shell
cat <repo>/config/_default/menu.toml
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

For batches, defer this step and Step 3d until all versions complete their content
stages, then confirm and apply the combined configuration diff once.

Show the user the complete new section before making any changes. Ask for confirmation
before writing to the file.

After confirmation, append the new section to the target `menu.toml`:

- **Versioned and unversioned migrations**: `<target-repo>/config/_default/menu.toml`
- **In-repo versioned migrations**: `<repo>/config/_default/menu.toml`
- **In-repo reorganization**: `<repo>/config/_default/menu.toml`

Add it after the last existing `[[<product>_*]]` version menu block (versioned, in-repo
versioned, and in-repo reorganization), or after the `[[<product>]]` version switcher
block (unversioned), or at the end of the file if neither exists yet.

### Step 3d: Update the version switcher (versioned, in-repo versioned, and in-repo reorganization only)

For **unversioned migrations**, skip this step.

Read the `[[<product>]]` version switcher block in the target `menu.toml`
(`<target-repo>/config/_default/menu.toml` for versioned migrations,
`<repo>/config/_default/menu.toml` for in-repo versioned migrations and in-repo
reorganization).
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
- **In-repo reorganization**: `<repo>/content/<product>/<version>/`

Use the appropriate path in all commands in this stage.

### Step 4a: Rewrite absolute internal content links

In the source repo, internal links used absolute paths relative to the site root, for
example `[Install](/install/)`. After migration, these links must include the product
prefix — and version prefix for versioned migrations:

- **Versioned**: `[Install](/<product>/<version>/install/)`
- **Unversioned**: `[Install](/<product>/install/)`
- **In-repo reorganization**: `[Install](/<product>/<version>/install/)`

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

**In-repo versioned and in-repo reorganization:**

```shell
grep -rn '](/' <repo>/content/<product>/<version>/ \
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

**In-repo versioned and in-repo reorganization:**

```shell
find <repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' 's|](\(/[^)]*\))|](/<product>/<version>\1)|g' {} +
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

**In-repo versioned and in-repo reorganization:**

```shell
grep -rn '](/images/' <repo>/content/<product>/<version>/
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

Because the reusable files were copied or moved into the migrated directory in Stage 1,
every path must be updated to include the product prefix — and version prefix for
versioned migrations:

- **Versioned**: `file="content/reusable_text/..."` → `file="content/<product>/<version>/reusable_text/..."`
- **Unversioned**: `file="content/reusable_text/..."` → `file="content/<product>/reusable_text/..."`
- **In-repo reorganization**: `file="content/reusable_text/..."` → `file="content/<product>/<version>/reusable_text/..."`

Find all readfile shortcodes in the migrated files:

**Versioned:**

```shell
grep -rn 'readfile file=' <target-repo>/content/<product>/<version>/
```

**Unversioned:**

```shell
grep -rn 'readfile file=' <target-repo>/content/<product>/
```

**In-repo versioned and in-repo reorganization:**

```shell
grep -rn 'readfile file=' <repo>/content/<product>/<version>/
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

**In-repo versioned and in-repo reorganization:**

```shell
find <repo>/content/<product>/<version> -name "*.md" -exec \
  sed -i '' \
    's|readfile file="content/|readfile file="content/<product>/<version>/|g' \
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

**In-repo versioned and in-repo reorganization:**

```shell
grep -rn 'readfile file="content/' <repo>/content/<product>/<version>/ \
  | grep -v 'readfile file="content/<product>/<version>/'
```

Any remaining matches reference content at a path that wasn't covered by the substitution.
Review each one — the path may use a different prefix or point to shared content outside
the migrated directory. Fix the path manually or flag it with a TODO comment:

```markdown
<!-- TODO: verify readfile path — may need updating after migration -->
```

---

## Stage 5: Strip docs.chef.io domain from cross-product links

> **Skip this stage for in-repo reorganization.** The content stays within the same
> repository and site, so cross-product links that include `https://docs.chef.io` are
> still valid and should remain unchanged.

In the source repo, links to other Chef products included the full domain name because
the source repo was served as a standalone site. In `chef/chef-web-docs`, all Chef
products are served from the same domain, so the domain prefix can be removed.

This stage applies to versioned, unversioned, and in-repo versioned migration types only.
Use the content target path for your migration type in all commands.

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

For a single import, verify after all stages complete and before committing.
For a batch, don't run these final checks inside the per-version loop.
Start only after every selected version completes Stages 1–5 and the combined shared
configuration is applied.
Run one target-site build and reuse one preview server for the entire batch.
If a check fails, fix the affected files and rerun the necessary checks; don't repeat
successful imports.

1. **Build locally**: Run the Hugo dev server in the target repo and confirm pages load:

   **Versioned and unversioned migrations:**

   ```shell
   cd <target-repo> && hugo server
   ```

   **In-repo versioned migrations and in-repo reorganization:**

   ```shell
   cd <repo> && hugo server
   ```

   Open the migrated section in a browser and confirm:

   - **Versioned**: `http://localhost:1313/<product>/<version>/`
   - **Unversioned**: `http://localhost:1313/<product>/`
   - **In-repo versioned**: `http://localhost:1313/<product>/<version>/`
   - **In-repo reorganization**: `http://localhost:1313/<product>/<version>/`

   Confirm:
   - The section loads without errors
   - The left-nav menu appears and is structured correctly
   - Images render correctly on content pages

   For batches, open every selected `/<product>/<version>/` section using the same server.

2. **Check links**: Run the `fix-broken-links` skill against the locally served site,
   scoped to the product path, to catch any links that weren't updated.

   For batches, run this as one final link-checking phase after all versions are present
   so cross-version destinations exist.
   Ensure every selected version is crawled; don't assume one version's links reach all
   others.
   Use one product-scoped crawl if it reaches them all; otherwise check each selected
   version from its own start URL using the same server.
   Report unrelated existing product-path failures separately from migration failures.

3. **Spot-check pages**: Manually verify at least three pages — choose a section index, a
   deeply nested content page, and a page with images and cross-product links.

   For batches, select at least three pages per version, not three pages for the batch.

4. **Confirm menu** *(versioned, in-repo versioned, and in-repo reorganization only)*:
   Confirm the version appears in the version switcher on the product landing page.

   For batches, confirm every selected version appears once, in newest-first order,
   points to the correct section, and selects the correct menu when opened.
   Verify the existing default version hasn't changed without approval.

---

## Final output

After all stages complete, return a `## Migration summary` section with:

For batches, return one summary, not a separate final response per version.
Include the selected versions and pinned refs/commits, a per-version table of the counts
below, and batch totals.
List excluded versions and their collision paths separately; don't label them as newly
imported or validated.
List shared configuration changes once and report the exact validation commands,
results, and browser coverage by version.
If the batch stops early, distinguish completed content imports, partial or unstarted
versions, shared configuration status, and final validation that hasn't run or passed.

- Migration type: versioned, unversioned, in-repo versioned, or in-repo reorganization
- Source repo or repo path, branch (versioned and in-repo versioned) or current branch
  (in-repo reorganization) or default branch (unversioned), and content paths
- Target repo and content and static paths (not applicable for in-repo reorganization;
  list the single repo path instead)
- Number of Markdown content files migrated (or moved, for in-repo reorganization)
- Number of static files migrated (or moved, for in-repo reorganization)
- Frontmatter updates: count of files updated
- Menu entries added to `menu.toml`: count of `[[<menu-name>]]` entries added
- Link rewrites: count of internal content links updated
- Image path rewrites: count of image paths updated
- Shortcode path rewrites: count of `readfile` paths updated
- `docs.chef.io` links stripped: count (enter `N/A — skipped for in-repo reorganization`
  if the migration type is in-repo reorganization)
- Files that need manual review: list any files with unresolved `readfile` paths,
  skipped links, or items where automatic rewriting produced unexpected results
