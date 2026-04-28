# DEV-82 Research: awesome-copilot patterns for AgToosa

Workspace mirror of the Linear research document for DEV-82.

## Goal

Evaluate awesome-copilot patterns that make AgToosa lighter and simpler for end users.

## What to borrow

- Clear resource layers: always-on instructions, topic-specific instructions, reusable skills, and specialist agents.
- Validation and contribution conventions that keep custom files maintainable.
- A machine-readable index or inventory style for discoverability.
- A conservative default surface where the user sees one workflow while background agents handle structure.

## What not to borrow

- Excessively large catalogs that make the primary workflow noisy.
- Overlapping instruction layers that create contradictory guidance.
- Any pattern that requires the user to manage too many files manually.

## Recommended AgToosa integration

1. Keep the core agent baseline as the default project entry point.
2. Add narrow, high-value instruction files only when a rule is repeated often.
3. Convert repeatable workflows into skills.
4. Introduce specialist agents only for research, review, or security jobs that need a different toolset.
5. Mirror each rollout in Linear first, then reflect the result here.

## Business case

- Faster onboarding.
- More consistent outputs.
- Lower support burden.
- Better reuse across projects.

## Status

- DEV-82 is done in Linear.
- The research document is linked in the issue resources and mirrored here.
