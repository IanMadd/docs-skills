# Editorial review policy

Use this policy to keep the review focused on wording, structure, and usability.
This skill does not determine whether a requirement is technically correct or supported.

## Scope of the review

Review the supplied text and related local content for:

- Clear audience and deployment scope
- Logical order and useful section hierarchy
- Scannable presentation of requirements
- Consistent terminology, capitalization, units, and formatting
- Explicit required, recommended, conditional, and optional language when the source provides
  enough context
- Clear references between shared, standard, and air-gapped requirements
- Readable descriptions of customer and product responsibilities
- Defined acronyms and understandable specialized terms
- Grammar, active voice, present tense, and sentence structure according to repository
  instructions
- Descriptive links and accessible headings

Use the repository's instruction files as the primary style authority.
Use the Good Docs Project installation-guide page as additional guidance for organizing and
presenting installation requirements.

## Do not verify technical claims

Do not research or assess:

- Whether a platform or version is supported
- Whether a version is current, deprecated, or end of life
- Whether a CPU, memory, disk, node, or storage value is sufficient
- Whether a port, endpoint, registry, API, or runtime is required
- Whether a permission, security control, topology, or architecture is valid
- Whether a Kubernetes, cloud-provider, operating-system, or vendor behavior is accurate

Preserve those claims exactly unless an approved editorial change improves their wording
without changing their meaning.

If a requirement appears unusual, report it only as an editorial concern when its wording is
ambiguous or difficult to understand.
Don't call it wrong, stale, unsupported, insecure, or incomplete on technical grounds.

## Permitted editorial changes

You may:

- Rewrite a sentence for clarity while preserving its technical meaning
- Split dense prose into lists or shorter paragraphs
- Reorder existing material for a clearer customer workflow
- Clarify a heading or introductory sentence
- Define an acronym at first use
- Standardize existing terminology and capitalization
- Make an existing required or optional condition easier to find
- Improve cross-reference wording and link labels
- Remove repetition and resolve pronoun ambiguity
- Correct grammar, voice, tense, and punctuation

You may not:

- Add a technical value from general knowledge
- Replace or remove a version, quantity, port, endpoint, platform, product, or permission
- Add a compatibility statement or external citation as proof
- Convert a recommendation into a requirement or a requirement into an option
- Change a table value or alter a command's behavior

## Report findings

Each finding should include:

- Owning file and location
- Existing wording or structural issue
- Editorial category
- Why the issue may confuse or slow a customer
- Suggested wording or organization change

Use editorial categories such as `clarity`, `organization`, `scannability`, `consistency`,
`terminology`, `cross-reference`, `accessibility`, and `grammar`.

Use severity based only on reader impact:

- `High`: The wording or organization can cause customers to miss or misinterpret an existing
  requirement.
- `Medium`: The issue can cause avoidable confusion or re-reading.
- `Low`: The issue is a minor style or polish improvement.

Don't assign technical confidence or technical correctness statuses.
Mention technical questions as out of scope when necessary.

## Edit threshold

After the user approves edits:

- Apply only the approved editorial changes.
- Preserve technical values, claims, commands, links, frontmatter, shortcodes, and anchors.
- Edit the owning source file when content is transcluded.
- Leave technical questions unchanged.
- Report any remaining editorial concerns.
