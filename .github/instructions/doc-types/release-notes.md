---
description: "Structural template and guidelines for release notes doc type pages."
---

# Release notes

**Purpose**: Communicate new features, improvements, bug fixes, and known issues to stakeholders. Release notes are customer-facing---use plain language, not developer-facing changelog language. Written for both technical and non-technical readers.

```markdown
## <PRODUCT> <VERSION>

Release date: <MONTH> <DAY>, <YEAR>

(Optional) One to two sentences highlighting the most important items in this release.

### Breaking changes (include if present---always lead with this section)

{{< warning >}}

The following changes require action before upgrading.

{{< /warning >}}

- **<Change name>**: What changed, what the reader must do, and a link to the migration guide.

### Upgrade notes (include if present)

- **<Requirement name>**: What the reader must verify or do before upgrading to this version, such as a minimum current version or an upgrade-order requirement.

(Optional) If the upgrade requires specific commands, show them in a fenced code block after the list.

### Security (include if present---lead with this section after breaking changes)

- **[<CVE or issue-id>](<link>) <Short description>**: Resolved a vulnerability that <describe impact>. <Severity, if disclosed>.

### New features

- **<Feature name>**: What the feature does and how it benefits the reader.
  See [<feature docs>](<link>) for more information.

### New features requiring configuration updates

- **<Feature name>**: What the feature does. To use this feature, you must <describe the required config>.
  See [<feature docs>](<link>) for configuration steps.

### Improvements

- **<Area or feature>**: What was added, updated, or removed and the benefit to the reader.

### Licensing (optional)

- **<Change name>**: What changed about license tiers, enforcement, or usage reporting, and what the reader must do, if anything.

### Bug fixes

- **[<issue-id>](<link>) <Short description>**: The <application or feature> now correctly <does XYZ>. Previously, it <did ABC>.
  See [<docs link>](<link>) for more information.

### Known issues

- **[<issue-id>](<link>) <Short description>**: <What happens and in what scenario>.
  Workaround: <Steps to work around the issue, if available>.

### Deprecated features (optional)

- **<Feature name>**: <Feature> will be removed in <version or date>.
  <Replacement feature> replaces it. The system will <describe data migration if applicable>.
  See [<deprecated feature docs>](<link>).

### Platform support (include if present)

- **<Platform name>**: Added support for <platform or architecture>. / Removed support for <platform or architecture>; see <migration link> if applicable.

### Packages

Packages are available for the following platforms and architectures:

| Platform | Architecture | Package format |
|----------|--------------|----------------|
| <Platform name> | <Architecture, such as x86-64 or ARM64> | <Package format, such as `.msi`, `.pkg`, `.rpm`, `.deb`, or `.hart`> |

### Dependency updates (include if present)

- **<Dependency name>**: Upgraded to <version> to address <CVE or behavior change>. / Now requires <minimum version> or later.

### Bundled components (include if your product bundles components the reader writes or runs content against)

This release includes:

| Component | Version |
|-----------|---------|
| <Component name> | <Version> |

### Supported <extension type> versions (optional---name this section using your product's term for its extension mechanism, such as "Supported skill versions" or "Supported plugin versions")

This release supports the following <extension type> versions.

| <Extension type> | Package | Version | Change summary |
|-------------------|---------|---------|-----------------|
| <Extension name> | <Package identifier> | <Version> | <What changed in this version, if anything> |
```

**Guidelines**:
- Write in a positive, friendly tone; use plain language
- Use second person: "You can now...", "Use the new... to..."
- Use present tense for new features and improvements: "Adds support for...", "Lets you..."
- For bug fixes, use this two-part pattern: "The <application or feature> now correctly <does XYZ>. Previously, it <did ABC>."
- Don't start bug fix entries with "Fixed..." or "Resolved..."
- List the most important items in each section first
- Use the bold run-in heading (`**<Change name>**`) only for the specific feature, change, or issue name---not as a generic category label like "Authentication" or "Reporting". See [Description lists and run-in headings](../docs-style.instructions.md#description-lists-and-run-in-headings) for the full rule
- Give breaking changes, deprecations, and security fixes their own section heading---don't rely on a bold run-in label alone to flag these categories
- Include issue or PR numbers and link them where your organization permits
- Omit any section that has no entries
- Use semantic versioning for release numbers (for example, `1.3.2`); include the date in `YYYY-MM-DD` format
- In the Packages section, list only the platforms and architectures available for the specific release; omit rows that don't apply
- In Upgrade notes, cover only what the reader must verify or do before upgrading---don't repeat Breaking changes content
- In Platform support, list only the platforms that changed in this release (added or removed); the full current matrix belongs in Packages
- In Dependency updates, list a bundled dependency bump only when it has a reader-facing reason---a CVE fix, a new minimum version requirement, or a behavior change. Omit routine patch bumps with no practical impact
- In Bundled components, list a component when the reader writes or runs their own content against it (for example, Ruby in Chef Infra Client, or Chef InSpec bundled in Chef Automate)---even if the version didn't change this release. Don't list internal implementation libraries the reader never invokes directly; those belong in Dependency updates instead
- Only include a "Supported <extension type> versions" section for products with a separately installed, independently versioned extension mechanism (such as Chef 360 Platform skills); most products won't need this section
- Unlike Bundled components, an extension such as a skill or plugin is installed separately from the application and typically has no release notes of its own---this table is the only place its version changes are documented. List the current supported version for every extension, even if it didn't change, and use Change summary to describe what changed in that version since it was last listed
- Don't add a "Supported external products" or similar cross-product compatibility section unless your team has a verified process for testing and maintaining that compatibility claim
