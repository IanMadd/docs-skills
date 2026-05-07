---
name: generate-examples-from-repo
description: 'Fetch source code from a public GitHub repository, extract real usage patterns for one command or all commands, and generate formatted, annotated code examples ready for DevOps documentation. Triggers on: generate examples from repo, code examples from source, examples from GitHub, generate examples from code, spec examples, lib examples, command examples, generate documentation examples.'
argument-hint: "GitHub repo URL — for example: https://github.com/chef/chef-cli. Optionally add a command name to scope the output: https://github.com/chef/chef-cli generate cookbook"
---

# Generate code examples from a GitHub repository

Runs a four-stage workflow to produce documentation-ready code examples from the source
code of a public GitHub repository:

1. **Discover** — identifies the repo structure and locates the source files most useful
   for documentation examples
2. **Fetch** — retrieves the relevant source files using raw GitHub URLs
3. **Extract** — reads the fetched code and builds a usage inventory per command
4. **Generate** — produces formatted, annotated examples following the team style guide

---

## What to ask the user

Before starting, confirm the following inputs if not already provided:

1. **Repository URL** — the GitHub URL of the repo, for example:
   `https://github.com/chef/chef-cli`

2. **Command or scope** — one of:
   - A specific command name, for example: `chef generate cookbook`
   - `all` — generate examples for every command the repo exposes

3. **Source preference** (optional) — which part of the repo to read from:
   - `spec` — test and spec files (default; prefer these — they show real invocations,
     arguments, and expected output)
   - `lib` — implementation files (use when spec files are absent or sparse)
   - `both` — read spec files first, fall back to lib for any commands not covered

4. **Output format** (optional) — what kind of examples to produce:
   - `usage` (default) — command-line invocations with flags and arguments
   - `config` — configuration file snippets (YAML, JSON, HCL, Dockerfile)
   - `both`

---

## Stage 1: Discover the repository structure

### Step 1a: Fetch the top-level directory listing

Fetch the GitHub HTML page for the repo to read the directory listing:

```
https://github.com/<owner>/<repo>/tree/main
```

If the page returns a 404, try `master` instead of `main`.

From the listing, identify:
- Whether a `spec/` or `test/` directory exists
- Whether a `lib/` directory exists
- Whether a CLI entry point exists (common locations: `bin/`, `exe/`,
  `lib/<name>/cli.rb`, `lib/<name>/command/`, `cmd/`, `src/cmd/`)

### Step 1b: Locate command definitions

The strategy depends on the language and framework. Use the following lookup order:

#### Ruby (Thor, GLI, OptionParser)

1. `lib/<name>/command/` or `lib/<name>/commands/` — one file per command is common
2. `lib/<name>/cli.rb` — commands may all be defined inline
3. `bin/<name>` — the entry point often lists or dispatches commands

Fetch the `lib/` directory listing to enumerate files:

```
https://github.com/<owner>/<repo>/tree/main/lib
```

#### Go (cobra, cli)

1. `cmd/` — standard cobra layout, one file per command
2. `internal/cmd/` or `pkg/cmd/`

#### Python (click, argparse, typer)

1. `src/<name>/commands/` or `<name>/commands/`
2. `cli.py` or `<name>/cli.py`

#### Node.js (commander, yargs)

1. `src/commands/` or `lib/commands/`
2. `bin/<name>.js`

#### Unknown language

If the language isn't recognized, fetch `README.md` from the repo root and look for a
usage or commands section. Use that as the command inventory.

### Step 1c: Build a command inventory

List every command found. If the user requested a specific command, confirm it appears in
the inventory. If it doesn't, report which commands are available and ask the user to
choose one.

For `all`, report the total command count and list them. If there are more than 15
commands, ask the user whether to proceed with all of them or select a subset before
continuing.

---

## Stage 2: Fetch source files

For each command in scope, fetch the relevant source files using raw GitHub URLs.

### Construct raw URLs

Replace `github.com` with `raw.githubusercontent.com` and remove `/blob/` from the path:

```
# GitHub URL (for viewing):
https://github.com/<owner>/<repo>/blob/main/<path>

# Raw URL (for fetching file content):
https://raw.githubusercontent.com/<owner>/<repo>/main/<path>
```

Keep the `github.com/…/tree/…` form when fetching directory listings — raw URLs don't
serve directory indexes.

### Fetch spec files first

For each command, search the spec or test directory for files that match the command name.
Common filename patterns:

- `spec/unit/command/<command-name>_spec.rb`
- `spec/unit/<command-name>_spec.rb`
- `test/<command-name>_test.go`
- `tests/test_<command-name>.py`
- `spec/<command-name>.spec.js`

If a directory listing is needed to find the right file, fetch:

```
https://github.com/<owner>/<repo>/tree/main/spec
```

Parse the HTML listing to find matching filenames, then fetch each matched file's raw content.

### Fall back to lib files

If no spec file is found for a command, or if the user selected `lib` as the source
preference, fetch the implementation file for that command instead.

### File size

If a raw file is very long (over approximately 500 lines), read only the sections relevant
to the command — locate class, function, or method definitions that match the command name
rather than treating the entire file as input.

---

## Stage 3: Extract usage patterns

For each fetched file, extract patterns according to the source type. Build a per-command
inventory from what you find.

### From spec and test files

Spec files are the preferred source because they exercise real inputs and assert real
outputs, which translates directly into accurate documentation.

**Invocation patterns** — lines that call the command with arguments and flags:

```ruby
# Ruby RSpec
described_class.new(["cookbook", "my-cookbook"]).run
Chef::CLI::Command::Generate.new(["cookbook", "--copyright", "Chef Software"]).run
```

```go
// Go test
cmd.SetArgs([]string{"generate", "cookbook", "my-cookbook"})
cmd.Execute()
```

**Flag combinations** — tests that vary a flag show which options users care about:

```ruby
described_class.new(["cookbook", "--license", "apachev2"]).run
```

**Expected output** — `expect` blocks or assertions that show what the command prints:

```ruby
expect(stdout).to include("Your cookbook is ready")
```

**Error cases** — tests on bad input are useful for the "common errors" part of the
explanatory paragraph:

```ruby
expect { described_class.new([]).run }.to raise_error(...)
```

### From lib and implementation files

**Available flags and options** — option parser definitions list every supported flag:

```ruby
option :copyright, short: "-C", long: "--copyright", description: "..."
option :license, default: "all_rights"
```

**Subcommand registrations** — CLI framework calls that enumerate all subcommands:

```ruby
subcommand "generate", "Generate a new cookbook", Chef::CLI::Command::Generate
```

### Usage inventory per command

For each command, record:

- The canonical invocation form: `chef generate cookbook <NAME>`
- Available flags with types and defaults (from option parser definitions)
- Representative invocation examples with real argument values (from spec files)
- Expected output snippets (from spec assertions only — don't infer output)
- Error conditions (from spec error-path tests)

---

## Stage 4: Generate examples

Using the inventory from Stage 3, produce documentation-ready examples. Apply the
formatting rules from [docs-style.instructions.md](../../instructions/docs-style.instructions.md).

### Example structure per command

Produce the following sections in order for each command:

#### 1. Canonical usage line

Show the command signature with angle-bracket placeholders for required arguments:

````markdown
```shell
chef generate cookbook <COOKBOOK_NAME>
```
````

#### 2. Common invocations

Show two to four concrete examples drawn directly from spec file invocation patterns. Use
realistic values from the spec files, not placeholders:

````markdown
```shell
# Generate a cookbook in the current directory
chef generate cookbook my-app
```

```shell
# Generate a cookbook with a custom copyright holder
chef generate cookbook my-app --copyright "Example Corp"
```
````

#### 3. Expected output

If the spec files contain output assertions, show the output in a `console` block:

````markdown
```console
Generating cookbook my-app
- Ensuring correct cookbook content
Your cookbook is ready. Type `cd my-app` to enter it.
```
````

If no output assertions exist in the source, omit this block entirely. Don't fabricate
output.

#### 4. Key flags

List only the flags that spec tests actually exercise — not the full option list from the
implementation. Use a description list:

```markdown
`--copyright <NAME>`
: Sets the copyright holder in generated file headers. Defaults to the value in your
  knife configuration.

`--license <LICENSE>`
: Sets the license type. Common values: `apachev2`, `mit`, `gplv2`, `all_rights`.
```

#### 5. Explanatory paragraph

Write a short paragraph covering:
- What the command does and when to use it
- Any prerequisites (installed tools, required configuration)
- The most common error and how to avoid it, drawn from error-path spec tests

### Formatting rules

- Use `shell` for command-line invocations; `console` for terminal output
- Use angle brackets for values the reader must replace: `<COOKBOOK_NAME>`, `<NAMESPACE>`
- Use realistic argument values from spec files when showing concrete examples
- Keep each code block minimal — one concept per block
- Add a `#` comment above blocks whose purpose isn't obvious from the command itself
- Don't invent flags, arguments, or behavior not evidenced in the fetched source files

### Scope: one command vs. all commands

**One command**: produce the full five-section structure above.

**All commands**: produce one canonical usage line per command with a single sentence
description, then ask the user which commands to expand. Don't generate the full structure
for every command at once — it produces unmanageable output and is more useful done
iteratively.

---

## Final output

Return the generated examples as Markdown, ready to paste into a documentation file.

After the examples, add a `## Source summary` section with:

- Repository URL and branch used
- Source files fetched, listed as: `<path> (spec)` or `<path> (lib)`
- Commands covered
- Commands requested but not found in the source, with a reason
- Any examples marked `[inferred — no spec coverage]` where behavior was not directly
  evidenced in the fetched files
