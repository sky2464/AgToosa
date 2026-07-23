# ADR-016: Bounded Adapter Rendering and Semantic Conformance

**Status:** Accepted
**Date:** 2026-07-14
**Deciders:** User + AI agent (DEV-118 interview and approval)
**Related:** ADR-015 (Product Truth Contract) · DEV-094 (Assistant Compatibility Contract) · DEV-121 (Behavioral Conformance Lab)

## Context

AgToosa currently ships 19 native command files on each of six command surfaces. The existing WP2 test still expects 18, demonstrating that file-count parity can drift behind the product. File presence also cannot detect semantic contradictions such as the canonical two-question `/agtoosa-spec quick` limit appearing as three questions on Gemini and Copilot or two-to-three on Claude.

The six surfaces use different native formats and may expose additional artifact layers such as Codex skills. Full byte-for-byte generation would erase useful target-specific instructions, while validator-only maintenance would keep stable facts duplicated by hand.

## Decision

1. Model six stable command targets:
   - `cursor.project-commands`
   - `windsurf.workflows`
   - `anthropic.claude-code`
   - `google.gemini-cli`
   - `github.copilot-vscode`
   - `openai.codex-cli`
2. Inventory every current native command dynamically from the contract—19 at the DEV-118 baseline—rather than hard-coding a permanent count. Auxiliary artifacts such as Codex skills use explicit artifact kinds and reasoned exceptions.
3. Render only bounded, marked contract-owned fields: command identity, canonical workflow reference, modes/subcommands, question budget, mutation class, approval/phase-stop rule, and lifecycle close. Platform-specific prose remains hand-authored.
4. Provide separate operations:
   - `check`: read-only schema, inventory, extraction, path, claim, and semantic validation.
   - `render --check`: derive expected managed blocks and fail on drift without writing.
   - `render --apply`: explicit maintainer action that updates only existing managed blocks and refuses unmarked or out-of-scope files.
5. Enforce portable invariants for every command × target cell (114 at the baseline). Apply deeper semantic goldens to Init, Spec, Build, Review, and Ship first.
6. Target-specific extensions are namespaced and schema-checked. They may describe format needs but cannot redefine portable invariants.
7. CI runs check-only modes. Rendering never runs automatically during install, update, validation, or CI.
8. Static conformance proves declared routing and semantics only. Assistant recognition and behavior remain DEV-121 scope.

## Rationale

- Bounded rendering removes duplication for stable facts without flattening target-native UX.
- Dynamic inventory catches the current 18-versus-19 drift and future command additions.
- Universal invariants protect every surface; deeper goldens focus initial effort on the core lifecycle.
- Check-only CI and marked-block writes minimize accidental adapter damage.

## Consequences

### Positive

- New commands cannot silently miss a native surface.
- Stable command facts have one authoring location.
- Target-specific prose remains possible without semantic authority drift.
- Negative contradiction fixtures can prove the checker fails closed.

### Negative

- Existing adapters need managed-block migration.
- Extractors and renderers must support Markdown and TOML safely.
- Managed markers become a compatibility contract.
- Non-lifecycle utilities receive shallower semantic coverage until later goldens are added.

## Alternatives Considered

| Option | Rejected because |
| -------- | ------------------ |
| Validate hand-authored files only | Leaves stable facts duplicated and fails the selected authority model. |
| Generate entire adapters | Risks deleting target-specific guidance and creates a large migration blast radius. |
| Keep file-count parity only | Cannot detect contradictory modes, gates, paths, or phase semantics. |
| Deep-golden all commands immediately | Expands DEV-118 beyond a bounded L story before the model is proven. |
| Treat Codex, OpenCode, Jules, and Copilot Cloud as identical aliases | Vendor and surface behavior differs; inherited claims would be unsupported. |
