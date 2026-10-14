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

- **<Package or component name>**: Updated to <version> to address <CVE-id>, which fixes <describe the vulnerability in plain language>. <Severity, if disclosed>.
- **<Package or component name>**: Updated to <version> to address the following CVEs:
  - <CVE-id>
  - <CVE-id>
- (For an application-level fix, not a dependency update) The <application or feature> now correctly <does XYZ>. Previously, it was vulnerable to <describe the vulnerability in plain language>.
- (If no CVE is assigned) Updated <package or component> to resolve a security issue that <describe the vulnerability in plain language>. <Severity, if disclosed>.

### New features

- **<Feature name>**: What the feature does and how it benefits the reader.
  See [<feature docs>](<link>) for more information.

### New features requiring configuration updates

- **<Feature name>**: What the feature does. To use this feature, you must <describe the required config>.
  See [<feature docs>](<link>) for configuration steps.

### Improvements

- **<Feature or component name>**: What was added, updated, or removed and the benefit to the reader.

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

### Packages (include if package availability, installer type, or format changed this release)

- <Description of what changed and the benefit to the reader, for example a new platform, architecture, installer type, or package format>. ([#<PR-number>](<link>))

### Dependency updates (include if present)

- **<Dependency name>**: Upgraded to <version> to address <CVE or behavior change>. / Now requires <minimum version> or later. / Updated from <old version> to <new version>.

### Bundled components (include if your product bundles components the reader writes or runs content against)

This release includes:

- **<Component name>**: <Version>

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
- For CVE fixes, use this pattern: "Updated <package> to <version> to address <CVE-id>, which fixes <describe the vulnerability in plain language>." Don't lead with "Fixed <CVE-id>..."
- If a single package update addresses multiple CVEs, use one bullet naming the package and version, followed by an indented sub-list of the bare CVE IDs---don't repeat the package name and description for each CVE: "Updated <package> to <version> to address the following CVEs:" followed by one indented `- <CVE-id>` bullet per CVE
- If one patch addresses CVEs in multiple distinct underlying libraries (for example, a vendor patch that updates both a web framework and an unrelated logging library), use a separate parent bullet per library, each with its own nested CVE list
- For a security fix to application code rather than a dependency update, use the bug-fix two-part pattern instead: "The <application or feature> now correctly <does XYZ>. Previously, it was vulnerable to <describe the vulnerability in plain language>."
- For security fixes with no assigned CVE, use this pattern: "Updated <package> to resolve a security issue that <describe the vulnerability in plain language>." Don't lead with "Fixed..." or "Resolved a vulnerability..."
- Never use "Bumped" for a package, dependency, or bundled component version change (for example, don't write "Bumped the PostgreSQL 13 tuxcare patch to 1.0.1"); use "Updated" instead
- List the most important items in each section first
- Use the bold run-in heading (`**<Change name>**`) only for the specific feature, change, or issue name---not as a generic category label like "Authentication" or "Reporting". See [Description lists and run-in headings](../docs-style.instructions.md#description-lists-and-run-in-headings) for the full rule
- Give breaking changes, deprecations, and security fixes their own section heading---don't rely on a bold run-in label alone to flag these categories
- Include issue or PR numbers and link them where your organization permits
- Omit any section that has no entries
- Use semantic versioning for release numbers (for example, `1.3.2`); include the date in `YYYY-MM-DD` format
- In Packages, list only what changed this release---a new platform or architecture, a new installer type (native or Habitat), a package format change, a Docker image update, or a package no longer provided. Don't restate a full matrix of every currently supported platform and package in each release; that list goes stale and adds maintenance burden without helping readers find what's new. Maintain a definitive, always-current platform/package matrix on a separate reference page if your project needs one
- In Packages, call out the installer type (native or Habitat) when it's part of what changed, since installation and management differs between the two
- In Upgrade notes, cover only what the reader must verify or do before upgrading---don't repeat Breaking changes content
- In Platform support, list only the platforms that changed in this release (added or removed); apply the same changes-only principle as Packages---don't restate the full current matrix
- In Dependency updates, note a reader-facing reason when one exists---a CVE fix, a new minimum version requirement, or a behavior change. If there's no specific reason, list the version change as "Updated from <old version> to <new version>" so readers can confirm the exact versions shipped. Use "Updated," never "Bumped," regardless of the reason
- In Bundled components, list a component when the reader writes or runs their own content against it (for example, Ruby in Chef Infra Client, or Chef InSpec bundled in Chef Automate)---even if the version didn't change this release. Don't list internal implementation libraries the reader never invokes directly; those belong in Dependency updates instead
- Only include a "Supported <extension type> versions" section for products with a separately installed, independently versioned extension mechanism (such as Chef 360 Platform skills); most products won't need this section
- Unlike Bundled components, an extension such as a skill or plugin is installed separately from the application and typically has no release notes of its own---this table is the only place its version changes are documented. List the current supported version for every extension, even if it didn't change, and use Change summary to describe what changed in that version since it was last listed
- Don't add a "Supported external products" or similar cross-product compatibility section unless your team has a verified process for testing and maintaining that compatibility claim
