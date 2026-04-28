# AgToosa /agtoosa-task Workflow

> **Lightweight issue capture. Use for bugs, chores, spikes, and fixes that do not require a full spec.**

## Objective

Create a well-formed Linear issue in under 5 steps. No spec file is generated. Use this for:
- Bugs found during `/agtoosa-build` via the Discovery Triage Protocol
- Small chores or dependency updates
- Spike investigations (time-boxed research)
- Targeted fixes (< 1 day) that don't need architecture decisions

Do **not** use `/agtoosa-task` for features or stories that require architecture decisions — use `/agtoosa-spec` instead.

## Workflow

### Step 1 — Classify

Ask the user: "What type of issue is this?"

| Type | When to use |
|------|-------------|
| **Bug** | Something broken that was previously working |
| **Chore** | Maintenance, dependency update, config change, refactor |
| **Spike** | Time-boxed research or investigation |
| **Fix** | Targeted correction for a known issue |

### Step 2 — Title & Priority

Ask: "Describe the issue in one sentence."

Prefix the answer with the type: `Bug: [sentence]`, `Chore: [sentence]`, `Spike: [sentence]`, `Fix: [sentence]`

Ask: "Priority — **High** (blocking someone now) / **Medium** (should be done soon) / **Low** (whenever)"

### Step 3 — Context & Acceptance Criteria

Ask type-specific questions:

- **Bug:** "What is the current behavior?" and "What is the expected behavior?"
- **Chore:** "What needs to change and why?"
- **Spike:** "What question needs to be answered?" and "What is the time-box (hours/days)?"
- **Fix:** "What is the root cause?" and "What is the fix boundary?"

Generate the Description automatically using the Linear Issue Standard (see `AgToosa_Agent.md` `## Linear Issue Standard`), including a type-appropriate **Definition of Done**:

**Bug DoD:**
- [ ] Regression test written and named `regression_[bug-id]_[desc]`
- [ ] Root cause documented in the issue
- [ ] Fix reviewed (no 🔴 Critical in `/agtoosa-review`)

**Chore DoD:**
- [ ] CI passes after the change
- [ ] No regressions in dependent modules

**Spike DoD:**
- [ ] Research summary written to `Docs/Context/`
- [ ] Time-box respected
- [ ] Decision or recommendation documented

**Fix DoD:**
- [ ] Fix is targeted to the declared scope
- [ ] Existing tests pass
- [ ] Regression test added if applicable

### Step 4 — Parent Linking

Ask: "Does this belong under an existing Epic or Story? (Paste the issue ID, or 'None')"

If an ID is given, set it as the parent issue.

### Step 5 — Create Issue

Create the Linear issue with:
- **Title** from Step 2
- **Label** matching the type (Bug / Chore / Fix / Feature)
- **Priority** from Step 2
- **Status:** `Backlog`
- **Description** from Step 3 (following the Linear Issue Standard)
- **Parent** from Step 4 (if provided)

Record the new issue ID and title in `Docs/Master-Plan.md` under `## Backlog`.

If the issue was created during Discovery Triage, append to the description:
> *Discovered during `/agtoosa-build` on [parent Story ID] on [YYYY-MM-DD].*

## Output

- Confirm the Linear issue was created; display the issue ID and URL.
- Ask: "Want to continue what you were doing, or tackle this now?"
