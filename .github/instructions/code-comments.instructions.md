---
description: "Comment style rules for code examples embedded in Markdown docs and for standalone downloadable code/config files. Use when writing, reviewing, or editing comments in fenced code blocks or in YAML, TOML, shell, PowerShell, or other downloadable source files."
---

# Comments in code and configuration examples

Apply these rules to every comment inside a fenced code block, and to comments in standalone
downloadable files---YAML, TOML, JSON-with-comments variants, shell scripts, PowerShell scripts,
configuration templates, Ruby, Python, Go, JavaScript, and other supported languages.

## Core principle

A comment should explain why, intent, an assumption, a risk, a customization point, or an
operational consideration. Never use a comment to restate obvious syntax or a self-explanatory
name or value.

Preferred:

```yaml
# Use a dedicated service account so requests can be audited.
service_account: chef-automate
```

Avoid:

```yaml
# Set the service account.
service_account: chef-automate
```

This applies even when the value is a short, cryptic token---don't just restate the setting
name, decode what the chosen value actually means or does. Naming the setting a second time
adds nothing the reader can't already see; explaining the value does.

Preferred---explains what the value means:

```yaml
# Single-node deployment with no high availability.
topology: hyperconverged-nonha
```

Avoid---restates the setting name without adding information:

```yaml
# Cluster deployment topology.
topology: hyperconverged-nonha
```

## Markdown-embedded examples vs. downloadable files

This is the most important distinction in this section.

- **Markdown-embedded examples** (fenced code blocks inside a doc page) exist to teach. If a
  comment is only meaningful because the example appears in documentation---it references a UI
  location, a documentation page, the surrounding tutorial workflow, or explains an unfamiliar
  construct for teaching purposes---move that information into the surrounding Markdown prose
  instead of leaving it as a comment inside the code block. This applies even to single-line
  comments.

  Preferred---add a prose sentence before the code block, then keep the code minimal:

  Replace `<TENANT_ID>` with the tenant ID shown on the **Tenant Details** page.

  ```yaml
  tenant_id: <TENANT_ID>
  ```

  Avoid---leaving the same information trapped inside a code comment:

  ```yaml
  # Find this value on the Tenant Details page.
  tenant_id: <TENANT_ID>
  ```

- **Downloadable files** (standalone YAML, TOML, shell, PowerShell, or code files a reader
  downloads and modifies) are operational artifacts. Comments stay in the file, but they must
  remain useful after the reader leaves the docs site---never reference a UI screen, a
  documentation page, or tutorial narration. Keep comments that explain customization,
  requirements, risks, or intent.

  Preferred:

  ```yaml
  # Replace with your organization's tenant ID.
  tenant_id: <TENANT_ID>
  ```

  Avoid:

  ```yaml
  # Find this value in the Tenant Details page.
  tenant_id: <TENANT_ID>
  ```

## Placeholder values

Placeholder format depends on where the example lives, and in a file it must stay valid syntax
for that file's type.

- **Markdown-embedded examples**: use angle brackets with uppercase text and underscores, as
  described in [Code and commands](docs-style.instructions.md#code-and-commands)---for example
  `<CLUSTER_NAME>`, `<TENANT_ID>`.
- **Downloadable files**: keep the same uppercase-with-underscores token inside angle brackets,
  but format it so the surrounding syntax stays valid for the file type:
  - YAML, JSON, and TOML string values: quote the placeholder if the file's linter or schema
    expects a quoted string, for example `"tenant_id": "<TENANT_ID>"`
  - Shell and PowerShell: an unquoted placeholder is valid in most positions, for example
    `--tenant-id <TENANT_ID>`; quote it where the surrounding syntax requires a string, for
    example `$tenantId = "<TENANT_ID>"`
  - General-purpose languages (Ruby, Python, Go, JavaScript, and similar): use the language's
    string literal syntax, for example `tenant_id = "<TENANT_ID>"`
- Don't use a determiner (`my`, `your`, `our`) inside a placeholder value---use `<TENANT_ID>` or
  `<API_TOKEN>`, not `your-tenant-id` or `my-api-token`. Determiners are fine in the surrounding
  comment or prose that explains the placeholder, since that text addresses the reader directly,
  for example "Replace `<TENANT_ID>` with your organization's tenant ID."
- The no-determiner rule also applies to realistic, non-bracketed example values that
  illustrate a field's format (see
  [Optional settings with blank fields](#optional-settings-with-blank-fields))---use
  `tenant-name.example.com`, not `mytenant.example.com`. A `my`-prefixed example still reads as
  a stand-in for the reader's own value instead of a neutral format illustration.

## Linking to external documentation

Inline the specific fact the reader needs to act on right now; don't make a URL the only source
of it. A reader with just the downloadable file may have no network access, and documentation
pages reorganize more often than most engineers expect---a stale link leaves the reader with
nothing, while inline text keeps working.

- State the actionable fact first---the value, format, or behavior the reader needs---then add a
  link only as a supplement, for background or for a canonical reference that changes over time
  (for example, a provider's current list of supported regions).
- Only link to a stable, canonical, vendor-maintained reference page---never to this project's
  own tutorial or how-to page. That restriction already applies to downloadable files; see
  [Markdown-embedded examples vs. downloadable files](#markdown-embedded-examples-vs-downloadable-files).
- Use a bare URL, not Markdown link syntax---most downloadable file types aren't Markdown and
  can't render a link.
- A trailing link still counts toward the comment's line length; shorten the inline fact rather
  than dropping the link's protocol or domain.

Preferred---the comment still works if the link goes stale or the reader is offline:

```yaml
# Must be a valid AWS region code, for example us-east-1.
# See https://docs.aws.amazon.com/general/latest/gr/rande.html for the full list.
region: <AWS_REGION>
```

Avoid---the reader has nothing if the link breaks or they're offline:

```yaml
# See https://docs.aws.amazon.com/general/latest/gr/rande.html for valid values.
region: <AWS_REGION>
```

## Approved comment types

- **Explanatory**: explains purpose or intent, for example `# Increase the timeout for high-latency networks.`
- **Customization**: flags a value the reader should change, for example `# Replace with your tenant ID.`
- **Required**: flags a customization point the example won't work without, for example
  `# REQUIRED: Set this value before deployment.`
- **Recommended**: flags a suggested value for typical or production use that the reader can
  keep or override, for example `# RECOMMENDED: Use this value for production deployments.`
- **Warning**: highlights a risk or side effect, for example `# WARNING: Disabling TLS verification reduces security.`
- **Important**: highlights a hard requirement or invariant that isn't about entering a value---for
  example a constraint between two settings---for example `# IMPORTANT: This value must match the server configuration.`
- **TODO**: used sparingly, only in source repositories, never in reader-facing downloadable files, for example `# TODO: Remove after migration to v3.`
- **Section**: describes a group of related settings, in 2 to 4 lines

Use the labels `NOTE:`, `REQUIRED:`, `RECOMMENDED:`, `IMPORTANT:`, `WARNING:`, and `TODO:` as
plain-text prefixes inside a comment. Choose the label that matches what the reader needs to do,
not just the tone of the comment:

- `REQUIRED:` --- the reader must supply or change this value for the example to work
- `RECOMMENDED:` --- a suggested value for common or production use; the reader can keep the
  default or override it
- `IMPORTANT:` --- a hard requirement or invariant that isn't tied to entering a value, for
  example a constraint between two settings
- `WARNING:` --- a risk or side effect of a choice the reader is about to make
- `NOTE:` --- supplementary information that doesn't fit the other labels

Don't use `IMPORTANT:` for a value the reader must fill in---use `REQUIRED:` instead, so the
label tells the reader what to do, not just that the setting matters.

Keep the label and its comment text on the same line, for example
`# REQUIRED: Set this value before deployment.`; only wrap onto an additional comment-prefixed
line if the text exceeds about 80 characters.

These labels are a different mechanism from the `{{< note >}}` and `{{< warning >}}`
Hugo shortcodes used for prose-level admonitions---see
[Admonitions](doc-types.instructions.md#admonitions). Don't use a shortcode inside a code
comment, and don't use a comment label where a shortcode belongs in the surrounding prose.

## Formatting

- Use sentence case
- Write complete sentences and end each one with a period
- Don't restate the setting name or a value already visible in the code
- State a conditional requirement condition-first: lead with the `if` clause, then the
  requirement it triggers. Write "If enabled is true, set hostname, username, and password."
  not "hostname, username, and password are required only when enabled is true."
- Wrap comment lines at about 80 characters; continue onto an additional comment-prefixed line
  instead of letting one line run long. This matters most in downloadable files, which readers
  often open in a terminal or a plain editor without line wrapping.
- Don't wrap or paraphrase an exact command the reader needs to copy and run---a shell
  invocation, flag, or payload. Keep it verbatim on one line even past 80 characters; splitting
  it across lines forces the reader to manually rejoin it before running it.

## Spacing between settings

In a downloadable file with many settings, a blank line marks where one documented setting (or
tightly related group of settings) ends and the next begins. Without it, stacked comments on
consecutive settings read as one run-on block, and the reader can't tell at a glance which
comment belongs to which field.

- Add a blank line before a comment that introduces a different setting or field group, when
  the line above is also a commented setting---don't let two unrelated comments sit flush
  against each other.
- Don't add a blank line between a comment and the field it documents---keep a setting's
  comment immediately above its own value.
- Keep closely related fields that share one comment together with no blank line between
  them, for example `tenant_admin_first_name` and `tenant_admin_last_name` under one comment
  that explains both.
- Don't force a blank line between consecutive uncommented settings---dense, uncommented
  defaults are fine as long as nothing is left unexplained that needs a comment.

Preferred---a blank line separates each documented setting from the next:

```yaml
# REQUIRED: Public tenant hostname used for access, for example
# tenant-name.example.com or tenant-name.example.com:31000.
fqdn: ""

# REQUIRED: Short tenant identifier used in URLs and config names, for
# example chef360 or platform-prod.
slug: ""
```

Avoid---stacked comments with no separation read as one run-on block:

```yaml
# REQUIRED: Public tenant hostname used for access, for example
# tenant-name.example.com or tenant-name.example.com:31000.
fqdn: ""
# REQUIRED: Short tenant identifier used in URLs and config names, for
# example chef360 or platform-prod.
slug: ""
```

## Length limits

- Inline comments: 1 line
- Section comments: 2 to 4 lines, maximum about 5 lines before moving the explanation into
  surrounding Markdown prose instead
- In a downloadable file there's no surrounding prose to move an over-length explanation
  into---shorten the wording instead of deleting the information it conveys. See
  [Optional settings with blank fields](#optional-settings-with-blank-fields) for the common case
  of a conditionally required block that needs more than a one-line summary.
- Never shorten a block by paraphrasing an exact remediation command into prose, or dropping it
  to save lines---keep the runnable command verbatim, even if the block then runs past the usual
  line count. Shorten surrounding prose first instead.

Preferred---keeps the exact command the reader needs to run:

```yaml
# Set this to the StorageClass used by your cluster.
# Check available classes: kubectl get storageclass
# Ensure one StorageClass is marked default; if needed:
# kubectl patch storageclass <STORAGE_CLASS_NAME> -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
storageClass: ""
```

Avoid---paraphrasing the command into prose removes the exact flags and payload the reader
would otherwise have to look up themselves:

```yaml
# RECOMMENDED: Set to your cluster's StorageClass name; leave blank to use
# the cluster's default. Run `kubectl get storageclass` to list available
# classes and confirm one is marked default.
storageClass: ""
```

## Optional settings with blank fields

A block disabled by default (for example `enabled: false`) often leaves its dependent fields
blank. A one-line summary naming those fields isn't enough on its own---a blank field carries no
placeholder token, so the reader has no cue for the expected format, and dropping the example to
fit the length limit removes real information instead of just tightening the wording.

- State the conditional requirement in one line above the block, condition-first (see
  Formatting). Use `IMPORTANT:` when it's a constraint between settings (the fields are only
  required when another setting changes); use `REQUIRED:` only when every field is
  unconditionally required.
- Show the expected format for each blank field as a short trailing comment on that field's own
  line, instead of a separate multi-line "Example:" block above the whole group. Each trailing
  comment is its own inline comment, so it still fits the 1-line inline limit even though the
  group as a whole documents four fields.
- Use a realistic example value for structural fields (hostnames, regions, paths), but keep it
  determiner-free (see [Placeholder values](#placeholder-values))---`tenant-name.example.com`,
  not `mytenant.example.com`. Use an uppercase placeholder token for secrets (API keys,
  passwords, access tokens) instead of a realistic-looking fake credential, so the reader can't
  mistake it for a working value.

Preferred:

```yaml
external:
  s3_config:
    # IMPORTANT: If enabled is true, set endpoint, access_key, secret_key, and region.
    enabled: false
    endpoint:     # for example, s3.us-east-1.amazonaws.com
    access_key:   # <AWS_ACCESS_KEY_ID>
    secret_key:   # <AWS_SECRET_ACCESS_KEY>
    region:       # for example, us-east-1
```

Avoid---stating the requirement before its condition:

```yaml
external:
  s3_config:
    # IMPORTANT: Required only when enabled is true.
    enabled: false
    endpoint:     # for example, s3.us-east-1.amazonaws.com
    access_key:   # <AWS_ACCESS_KEY_ID>
    secret_key:   # <AWS_SECRET_ACCESS_KEY>
    region:       # for example, us-east-1
```

Avoid---a separate "Example:" block that repeats every field name a second time:

```yaml
external:
  s3_config:
    # If enabled is true, fill all of: endpoint, access_key, secret_key, region.
    # Example:
    # endpoint: s3.us-east-1.amazonaws.com
    # access_key: <AWS_ACCESS_KEY_ID>
    # secret_key: <AWS_SECRET_ACCESS_KEY>
    # region: us-east-1
    enabled: false
    endpoint:
    access_key:
    secret_key:
    region:
```

Avoid---trimming to fit the length limit by deleting the example entirely: a bare field-name
list doesn't tell the reader what a valid value looks like.

```yaml
external:
  s3_config:
    # If enabled is true, set endpoint, access_key, secret_key, and region.
    enabled: false
    endpoint:
    access_key:
    secret_key:
    region:
```

## Language-specific notes

- **YAML and TOML**: use comments for customization, warnings, and section descriptions; avoid
  excessive inline comments
- **Shell and PowerShell**: slightly more explanatory comments are acceptable, since procedural
  scripts are often read sequentially
- **General-purpose languages** (Ruby, Python, Go, JavaScript, and similar): apply the same
  why-not-what principle as YAML and TOML
