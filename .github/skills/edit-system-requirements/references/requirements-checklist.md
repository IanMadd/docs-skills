# System requirements review checklist

Use this checklist to review customer-facing requirements for installing or configuring an
application.
Apply only the checks relevant to the product and deployment model.
Don't require empty sections for categories that don't apply.

The [Good Docs Project installation guide](https://www.thegooddocsproject.dev/template/installation-guide)
is a general structural and formatting reference.
The target repository's documentation instructions remain authoritative for local style.
This checklist doesn't verify technical claims or product support.

## Audience and scope

Confirm that the requirements identify:

- The application, edition, and release or version range they cover
- The supported deployment models, such as virtual machine, managed Kubernetes, or bring your
  own Kubernetes
- Differences between development, evaluation, and production environments
- Differences between standard, high-availability, and air-gapped installations
- Requirements that apply to all deployments and requirements that apply only under stated
  conditions
- Customer, product, cloud-provider, and third-party responsibilities

Flag requirements that combine scopes in a way that makes applicability unclear.

## Requirement quality

For each requirement, determine whether a customer can answer the following questions:

- What component, resource, capability, or permission do I need?
- Is it required, recommended, conditional, or optional?
- What minimum, maximum, supported range, or exact value applies?
- Which deployment model, environment, node role, or installation step does it affect?
- Is the value per node, per worker pool, per availability zone, or aggregate?
- Does the value refer to physical, provisioned, requested, available, or allocatable capacity?
- How can I verify the requirement before installation?
- Where can I find the related procedure or section in this documentation set?

Flag vague terms such as "recent," "modern," "sufficient," "standard," or "as needed" when
they prevent a customer from making a reliable decision.

Don't require every requirement to contain a rationale.
Require one when a surprising constraint, exception, or operational consequence would
otherwise be difficult to understand.

## Presentation and terminology

Confirm that the content:

- Groups related requirements under descriptive headings
- Uses paragraphs, lists, description lists, or tables according to the information being
  presented
- Uses comparison tables for values that readers need to evaluate across platforms,
  topologies, or roles
- Defines units and uses them consistently
- Distinguishes decimal and binary storage units when the distinction affects sizing
- Preserves version constraints exactly as supplied while presenting them consistently
- Uses product and technology names consistently
- Defines specialized abbreviations when the intended audience might not know them
- Links to detailed procedures instead of embedding unrelated installation steps

Don't convert a useful comparison or capacity table into a description list.

## Platform and software presentation

When these topics appear, check that the existing information is presented consistently:

- Supported operating systems, distributions, and versions
- Processor architectures
- Kubernetes distributions and versions
- Managed-service versions or release channels
- Container runtimes and versions
- Required command-line tools and versions
- Browsers, databases, runtimes, libraries, or package managers
- Required APIs, feature gates, custom resources, or operators
- Upgrade paths and version-skew limits

Don't determine whether any platform, version, runtime, or API is supported.
Report only unclear wording or inconsistent presentation.

## Compute and topology

Check for applicable requirements for:

- CPU or virtual CPU
- Memory
- Disk capacity and ephemeral storage
- Minimum node count
- Worker-pool composition
- Node roles, labels, taints, affinity, and anti-affinity
- Availability-zone or failure-domain distribution
- Capacity reserved for the operating system, Kubernetes, storage, ingress, monitoring, and
  other workloads
- Capacity needed during upgrades, node drains, or node failure
- Scaling limits or workload assumptions that affect sizing

For every numeric value, identify whether it is:

- A minimum, recommendation, tested value, or limit
- Per node, per role, per pool, or aggregate
- Provisioned, available, allocatable, requested, or consumed
- Inclusive of system and failure-recovery overhead

Flag totals only when the surrounding wording makes their scope unclear.
Don't recalculate or validate the values.

## Storage

Check for applicable requirements for:

- A default or named StorageClass
- Dynamic provisioning
- PersistentVolume access modes
- Volume expansion and reclaim behavior
- Capacity per service or aggregate capacity
- Performance, latency, throughput, or input/output operations per second
- Shared, block, object, or local storage
- Encryption requirements
- Snapshot, backup, restore, and disaster-recovery ownership
- Storage behavior during node or availability-zone failure

Don't determine whether the described storage meets the application's availability or
performance needs.

## Network, DNS, and certificates

Check that each network requirement identifies applicable details:

- Source and destination
- Inbound or outbound direction
- Protocol
- Port or port range
- Purpose
- Installation-time or runtime applicability
- Connected or air-gapped applicability
- Proxy behavior and exceptions
- Firewall, network-policy, ingress, load-balancer, or service requirements

Also check for:

- DNS names and resolution requirements
- Fully qualified domain name constraints
- Wildcard-domain requirements
- TLS certificate issuer, subject alternative names, format, and renewal ownership
- Network time synchronization
- Container registry and artifact download endpoints
- Private registry mirroring and artifact-transfer requirements for air-gapped environments

Flag wildcard domains without an explanation of why they are necessary.

## Identity, access, and security

Check for applicable requirements for:

- Installation identity and runtime identities
- Namespace-scoped and cluster-scoped permissions
- Custom Resource Definition installation
- Role-based access control resources
- Secret creation, storage, and rotation
- Pod Security Standards or equivalent controls
- Security contexts, privileged access, host access, and Linux capabilities
- Image pull credentials and registry trust
- Admission controllers, network policies, and policy-engine exceptions
- Encryption and key-management responsibilities

Clarify broad permission descriptions only when the existing text already states the intended
scope.
Don't infer or recommend a permission scope.

## Operational readiness

Check for applicable requirements for:

- Cluster and node health
- Required operators, controllers, and APIs
- Monitoring, logging, and alerting ownership
- Backup and restore readiness
- Recovery time and recovery point objectives
- Maintenance windows and upgrade capacity
- License, account, entitlement, and download access
- Installation workstation requirements
- Artifact integrity or signature verification

Prefer testable readiness conditions.
When appropriate, include a safe command or observable state that confirms the condition.
Don't add commands whose output or permissions haven't been verified.

## Cross-page checks

Compare the primary target, included files, and directly related requirement pages for:

- Different minimum versions for the same dependency
- Different CPU, memory, disk, or node totals
- Conflicting port, domain, or protocol requirements
- Different node labels or topology terminology
- Standard and air-gapped requirements that omit shared prerequisites
- Links whose labels promise requirements but lead to unrelated content
- Reusable text whose wording doesn't fit every page that includes it
- Requirements repeated in several files without a clear owning source

Report each contradiction at every affected source location.

## Completion criteria

A requirements review is complete when:

- Every material requirement is associated with a scope and owning source
- Editorial issues are reported with an owning source and suggested correction
- Cross-page wording differences and missing editorial context are reported
- Suggested edits preserve technical claims and values
- No source file has changed before the user approves edits
