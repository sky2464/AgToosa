# Spec: DEV-059 — Governance Policy-as-Code

> **Story ID:** DEV-059
> **Epic:** DEV-004
> **Status:** 🟨 In Progress — build GREEN
> **Estimate:** M
> **Spec created:** 2026-06-08
> **Spec deepened:** 2026-07-11
> **Competitive execution wave:** DEV-042 through DEV-060

## Context

AgToosa currently expresses path, tool, secret, approval, and risky-action boundaries across workflow prose, handoff packs, generator deny-lists, and optional CI checks. Those controls do not share one machine-checkable contract, and most agent behavior remains agent-instructed. Teams therefore cannot tell from one repo-local artifact which constraints apply, what happens on violation, or which layer actually enforces a rule.

DEV-059 defines a versioned, optional, repo-local policy schema and deterministic checker. It centralizes declarations without turning AgToosa into a hosted control plane or claiming that documentation can sandbox an agent. The mode-appropriate `docs/Master-Plan.md` or `Docs/Master-Plan.md` remains authoritative for lifecycle state. This story remains backlog until Master-Plan enrollment and explicit spec approval.

Recommended sequencing is DEV-055, then DEV-045, then DEV-059; that recommendation is not enrollment authority. Re-check `docs/Master-Plan.md` before build.

## 1. Requirements

### 1.1 Goal Contract

| Field | Value |
|-------|-------|
| Goal | Define allowed paths, tools, network access, secret handling, approval levels, and risky actions in a versioned repo-local policy whose rules carry honest enforcement and violation labels. |
| User outcome | Teams can declare agent boundaries before work begins, and every AgToosa workflow can refer to the same policy instead of inferring constraints from scattered prose. |
| Success condition | A documented YAML subset, safe example, deterministic local checker, resolution order, and workflow violation contract are installed; future GP-001–GP-008 checks cover the contract. |
| Proof / evidence | Future RED/GREEN records in `docs/AgToosa_TestPlan-DEV-059.md`, GP-focused bats output, checker fixtures, review findings, and ship evidence ledger pointers. No proof exists while this story is Backlog. |
| Non-goals | Runtime interception of agent tool calls; hosted policy service; SSO/RBAC; mandatory CI; silent hook installation; enterprise compliance certification. |
| Assumptions | Policy is optional; AgToosa remains local-first and markdown-first; Bash is already required for the installed verifier path; the mode-appropriate Master-Plan remains the repo-local source of truth. |
| Risks | Users mistake advisory rules for a sandbox; policy contains secret values; workflow copies drift; a malformed optional policy accidentally makes an install unusable. |
| Unresolved questions | None for v1: `.agtoosa/policy.yaml` is the project override, the mode-appropriate `Docs/Context/agtoosa-policy.yaml` or `docs/Context/agtoosa-policy.yaml` is the project-context fallback, and the shipped `.example.yaml` is never active automatically. |

### 1.2 User Stories

**As a** security-conscious team lead, **I want** path, tool, network, secret, approval, and risky-action boundaries in one repo-local policy **so that** agents receive explicit constraints before work begins.

**As an** orchestrator preparing a handoff, **I want** applicable policy rules included in the handoff pack **so that** an external agent sees the same boundaries as the primary agent.

**As a** maintainer, **I want** a dependency-light checker and contract tests **so that** invalid examples, dishonest enforcement labels, and workflow drift are caught before release.

### 1.3 Acceptance Criteria (EARS)

| ID | EARS | Priority |
|----|------|----------|
| AC-001 | WHEN `AgToosa_GovernancePolicy.md` is installed THE SYSTEM SHALL define a constrained YAML policy schema with `paths`, `tools`, `network`, `secrets`, `approvals`, and `risky_actions` categories and SHALL require every rule to declare `id`, `description`, `enforcement_class`, and `on_violation` | Must |
| AC-002 | WHEN `.agtoosa/policy.yaml` and a Context policy under the selected `Docs/` or `docs/` root are both present THE SYSTEM SHALL resolve `.agtoosa/policy.yaml`; WHEN neither active policy path is present THE SYSTEM SHALL report `no extra policy configured` and continue without making the project unhealthy | Must |
| AC-003 | WHEN `/agtoosa-handoff` assembles a handoff pack THE SYSTEM SHALL add an `Applicable Policy` section containing the resolved policy path and applicable rules, or the explicit no-policy result, without mutating policy or lifecycle state | Must |
| AC-004 | WHEN `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-review`, or `/agtoosa-import` encounters a declared policy violation THE SYSTEM SHALL follow the rule's documented `on_violation` behavior, identify its enforcement class, and preserve the mode-appropriate Master-Plan as lifecycle authority | Must |
| AC-005 | WHEN the local policy checker receives a policy file THE SYSTEM SHALL deterministically validate required keys, category names, enforcement-class values, violation-action values, unique rule IDs, and a bounded file size without network access | Must |
| AC-006 | WHEN a rule uses `block_generator` THE SYSTEM SHALL limit that label to a wired generator-owned operation and SHALL describe agent terminal, network, and host sandbox controls as agent-instructed, manual, CI-enforced, or roadmap unless implementation proves stronger enforcement | Must |
| AC-007 | IF verifier integration is implemented THEN WHEN `docs/agtoosa-verify.sh` encounters an invalid optional policy THE SYSTEM SHALL emit a policy WARN by default and SHALL NOT treat a missing policy as a finding | Should |
| AC-008 | WHEN the checker finds a forbidden secret-value field or likely credential literal THE SYSTEM SHALL fail validation, identify only the rule and field, and SHALL NOT echo the suspected secret value | Must |

Allowed `enforcement_class` values are exactly: `generator-enforced`, `CI-enforced`, `agent-instructed`, `manual`, and `roadmap`. Allowed v1 `on_violation` values are exactly: `warn`, `instruct_stop`, and `block_generator`.

### 1.4 Failure Modes

| ID | Maps to | Failure mode | Required response |
|----|---------|--------------|-------------------|
| FM-001 | AC-001 | A rule omits `enforcement_class`, causing an implicit enforcement claim. | Checker rejects the policy and names the rule ID. |
| FM-002 | AC-002 | Missing optional policy aborts install, update, or verification. | Resolve to `no extra policy configured`; do not fail or create a file. |
| FM-003 | AC-003 | A handoff omits configured policy, so an external lane receives weaker boundaries. | Handoff stops before export and reports how to regenerate the pack. |
| FM-004 | AC-004, AC-006 | Workflow prose claims that an instruction blocks host tools or network access. | Contract checks fail; wording must be downgraded to the proven class. |
| FM-005 | AC-005 | A malformed or oversized policy reaches a workflow. | Checker exits nonzero with a bounded, non-secret diagnostic. |
| FM-006 | AC-008 | Diagnostic output prints a token or password literal. | Redact the value and fail the security-focused GP check. |
| FM-007 | AC-004 | Policy handling writes story status or tasks directly in either Master-Plan path. | Abort that mutation and route lifecycle changes through the normal AgToosa command. |

### 1.5 Out of Scope

- Runtime interception or sandboxing of agent tool calls
- Network firewalling, process isolation, or operating-system access control
- Automatic installation of hooks; that remains DEV-052
- Hosted policy distribution, organization federation, SSO, SAML, or RBAC
- Fail-closed behavior merely because no policy file exists
- Storing secret values, tokens, passwords, or private keys in policy
- Automatically editing the mode-appropriate Master-Plan, approved specs, or policy from external-agent output
- Release publication and version bump work before normal ship enrollment

### 1.6 Claim Boundary

| Control | Classification | Honest boundary |
|---------|----------------|-----------------|
| Governance policy doc, checker, and example installed by AgToosa | generator-enforced | Generator can install known files; installation does not enforce user-authored rules. |
| Example and fixtures checked in repository tests | CI-enforced | Enforced only when project/release CI runs the GP tests. |
| Policy checker invoked locally | manual | Deterministic after invocation; AgToosa does not claim it always runs. |
| Optional policy checker wired into user CI | CI-enforced | Opt-in and limited to the declared schema. |
| Workflow consultation and `instruct_stop` | agent-instructed | A host agent can ignore prose unless its own sandbox provides stronger controls. |
| Existing generator-owned deny-list action labeled `block_generator` | generator-enforced | Applies only to the specifically wired generator operation. |
| Policy authoring and approval | manual | A human owns rule intent and accepts material policy changes. |
| Universal tool, network, or secret sandbox | roadmap | Not provided by this story. |

## 2. Design

### 2.1 Architecture Blueprint

Files to create:

- `template/Docs/AgToosa_GovernancePolicy.md` — canonical schema, resolution order, violation behavior, and enforcement glossary
- `docs/AgToosa_GovernancePolicy.md` — maintainer-dogfood mirror with lowercase `docs/` paths
- `template/Docs/Context/agtoosa-policy.example.yaml` — inert, secret-free generated-project example
- `docs/Context/agtoosa-policy.example.yaml` — maintainer example
- `template/Docs/agtoosa-policy-check.sh` — standalone local resolver and constrained-schema checker
- `docs/agtoosa-policy-check.sh` — maintainer mirror
- `tests/fixtures/policy/valid.yaml` — complete valid policy fixture
- `tests/fixtures/policy/invalid-missing-class.yaml` — missing-class negative fixture
- `tests/fixtures/policy/invalid-secret-value.yaml` — redaction negative fixture

Files to change:

- `template/Docs/AgToosa_{Spec,Build,Review,Handoff,Import,Governance}.md` and matching `docs/` mirrors — canonical policy references and violation behavior
- `template/Docs/agtoosa-verify.sh` and `docs/agtoosa-verify.sh` — optional WARN integration only if AC-007 is selected during enrollment
- `lib/config.sh` — install the policy doc, example, and checker
- `tests/agtoosa.bats` — GP-001–GP-008 contract and behavior checks
- `docs/AgToosa_TestPlan-DEV-059.md` — future TDD and validation evidence

Key interfaces:

- `bash Docs/agtoosa-policy-check.sh [--root PATH] [--policy PATH]`
- Resolution result: `policy_path=<repo-relative path>` or `policy_path=none`
- Exit `0`: valid policy or no optional policy; exit `1`: policy invalid; exit `2`: bad arguments or unreadable root
- Diagnostics contain rule IDs and field names only; suspected secret values are redacted

The checker supports the documented constrained YAML shape; it is not advertised as a general YAML parser.

### 2.2 Data Flow

1. A user optionally copies the inert example to `.agtoosa/policy.yaml` or the Context policy under the selected `docs/` or `Docs/` root and reviews it.
2. The checker resolves an explicit `--policy` first, then `.agtoosa/policy.yaml`, then the mode-appropriate Context policy; the `.example.yaml` file is never active.
3. The checker reads the selected local file, bounds its size, validates schema and values, and emits a redacted result without network access.
4. Spec, Build, Review, Handoff, and Import read the resolved policy before actions that fall under a declared rule.
5. Handoff copies rule metadata, not secrets, into `Applicable Policy` and records the repo-relative policy source.
6. On violation, a workflow follows `warn`, `instruct_stop`, or a specifically wired `block_generator` path; it does not invent stronger enforcement.
7. Lifecycle changes continue through the mode-appropriate Master-Plan and the existing AgToosa phase commands.
8. Repository CI may run GP tests and users may wire the checker into their CI, but neither is represented as mandatory.

### 2.3 Threat Model (STRIDE)

| Threat | Category | Mitigation |
|--------|----------|------------|
| A remote or generated file impersonates project policy | Spoofing | Fixed repo-local resolution order; no URL or remote includes; report selected relative path. |
| An unreviewed policy weakens path or tool restrictions | Tampering | Git-visible policy, deterministic schema check, manual approval, and no silent defaults. |
| An agent denies seeing applicable rules | Repudiation | Handoff records policy path and rule IDs; workflows report the violated rule ID. |
| Policy or diagnostics expose credentials | Information Disclosure | Secret names and handling only; reject value fields; redact suspected values. |
| A huge or adversarial policy stalls shell parsing | Denial of Service | Enforce a documented size limit and bounded diagnostics before parsing. |
| `block_generator` is used to imply host-level sandboxing | Elevation of Privilege | Permit the label only for explicitly wired generator-owned operations; contract checks enforce wording. |

### 2.4 Build Scope

Proposed future scope; `/agtoosa-spec` must revalidate it against the enrolled cycle before implementation.

```text
✅ Ready to proceed — Scope Boundary
Files in scope      : template/Docs/AgToosa_GovernancePolicy.md, docs/AgToosa_GovernancePolicy.md, template/Docs/Context/agtoosa-policy.example.yaml, docs/Context/agtoosa-policy.example.yaml, template/Docs/agtoosa-policy-check.sh, docs/agtoosa-policy-check.sh, canonical and maintainer mirrors for Spec/Build/Review/Handoff/Import/Governance, optional verifier mirrors, lib/config.sh, policy fixtures, tests/agtoosa.bats, docs/AgToosa_TestPlan-DEV-059.md
Directories in scope: template/Docs/, docs/, lib/, tests/fixtures/policy/, tests/
Out of scope        : hook installation, hosted policy services, identity/RBAC, runtime agent sandboxing, automatic lifecycle mutation, release/version work before ship
```

## 3. Tasks

### 3.1 Task Tree

- [x] **1. Contract-first policy fixtures and tests:** establish falsifiable schema and safety behavior
  - [x] 1.1 Add valid, missing-class, and secret-value fixtures — _Requirements: AC-001, AC-005, AC-008_
  - [x] 1.2 Add failing GP-001, GP-002, GP-005, and GP-008 checks and record RED evidence — _Requirements: AC-001, AC-002, AC-005, AC-008_
- [x] **2. Canonical policy contract:** document one schema and honest enforcement model
  - [x] 2.1 Create GovernancePolicy canonical doc and maintainer mirror — _Requirements: AC-001, AC-002, AC-006_
  - [x] 2.2 Add inert example policy with all six categories — _Requirements: AC-001, AC-008_
- [x] **3. Deterministic local checker:** resolve and validate optional policy safely
  - [x] 3.1 Implement resolution, required-field, enum, uniqueness, and size checks — _Requirements: AC-002, AC-005_
  - [x] 3.2 Implement secret-field rejection and redacted diagnostics — _Requirements: AC-008_
  - [x] 3.3 Register the doc, example, and checker in `lib/config.sh` — _Requirements: AC-001, AC-005_
- [x] **4. Workflow policy consumption:** make violation handling consistent without duplicating schema
  - [x] 4.1 Add Handoff `Applicable Policy` behavior — _Requirements: AC-003_
  - [x] 4.2 Wire Spec, Build, Review, Import, and Governance references — _Requirements: AC-004, AC-006_
  - [x] 4.3 Add GP-003, GP-004, and GP-006 checks — _Requirements: AC-003, AC-004, AC-006_
- [x] **5. Optional verifier warning:** add only the soft integration permitted by the contract
  - [x] 5.1 Add invalid-present-policy WARN and absent-policy no-finding behavior — _Requirements: AC-007_
  - [x] 5.2 Add GP-007 coverage for default and strict verifier semantics — _Requirements: AC-007_
- [x] **6. Complete future verification:** close the TDD loop without broadening claims
  - [x] 6.1 Run GP-001–GP-008 and focused regression commands, then record GREEN evidence — _Requirements: AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, AC-008_
  - [x] 6.2 Review policy claims and secret-safe diagnostics before ship evidence is finalized — _Requirements: AC-006, AC-008_

### 3.2 Wave Plan

**Wave 1 (parallel):** 1.1, 2.1, 2.2
**Wave 2 (sequential after Wave 1):** 1.2, 3.1, 3.2
**Wave 3 (parallel after Wave 2):** 3.3, 4.1, 4.2
**Wave 4 (parallel after Wave 3):** 4.3, 5.1
**Wave 5 (sequential after Wave 4):** 5.2, 6.1, 6.2

### 3.3 Test Plan

Test plan: `docs/AgToosa_TestPlan-DEV-059.md`
AC coverage: 8 of 8 ACs mapped to GP-001–GP-008
Must coverage: 7 of 7 Must ACs mapped
Smoke set: 7 planned tests tagged `@smoke`
Execution state: not run; this story is Backlog

## ✅ Spec Approved

Approved: 2026-07-11 21:40
Enrollment: remaining-specs fan-out wave 2 (post v5.3.9)
