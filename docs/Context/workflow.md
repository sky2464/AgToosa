# Workflow Configuration


## TDD

tdd: true

## Coverage

coverage_threshold: 100

## Branch Naming

branch_naming: "main"

## Commit Strategy

commit_strategy: "conventional"

## Linting

linter: "shellcheck"

## lint_config: ""

## Cross-model review

cross_model: recommended
<!-- off | on-demand | recommended | required — controls independent reviewer subagents during /agtoosa-review (see docs/AgToosa_CrossModelReview.md) -->

reviewer_model: parent
<!-- parent | ask — parent = same model tier as this chat unless user approves premium; ask = always confirm model before delegating -->

## Notes
<!-- Add team workflow rules, code review requirements, or release policies here. -->

## Standing Corrections

Dated, deduped always/never lessons from **AgToosa Project Intake**. Agents must read this section before classifying freeform asks (see `docs/AgToosa_Agent.md` → Project Intake Protocol).

| Date | Correction | Origin |
|------|------------|--------|
| _(none yet)_ | — | — |

Dedupe: if an equivalent correction already exists, refresh the date instead of adding a duplicate row. Do not store secrets — record intent only.
