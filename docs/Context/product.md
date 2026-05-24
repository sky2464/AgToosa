# Product Context

<!-- Fill in during /agtoosa-init. Used by /agtoosa-spec for requirements research. -->

## App Type
app_type: "CLI Tool & AI Framework Generator (Bash + PowerShell)"
# e.g., Web SaaS, Mobile App, CLI Tool, API Service, Browser Extension

## Target Users
target_users: "Software developers and agentic AI coding assistants (e.g. Claude Code, Gemini CLI, Cursor, Windsurf, Copilot)"
# Describe the primary user persona (e.g., "B2B: engineering teams at mid-size startups")

## Core Problem
core_problem: "Orchestrating clear, spec-driven, test-driven developer/agent workflows (Spec -> Build -> Review -> Ship) with multi-platform parity, preventing context drift and silent scope creep."
# The single most important problem this product solves

## Core Features
core_features:
  - "Multi-platform AI native workflow triggers (.claude, .cursorrules, .windsurfrules, .github/prompts, .gemini)"
  - "Smart generator framework with deep backup, merge, and update support"
  - "Deterministic status monitoring and project health scoring"
  - "Community registry for package manager expansions"

## Non-Goals
non_goals:
  - "Replacing human developer reviews entirely"
  - "A general-purpose application build tool (relies on target platforms for build steps)"

## Current Milestone
current_milestone: "v5.3.0"
# e.g., MVP, v1.0, v2.0 public launch

## Success Metrics
success_metrics:
  - "100% pass rate on full BATS integration tests across platform scenarios"
  - "Perfect parity of workflows and exit behaviors across all supported AI tools"

## Notes
<!-- Add business context, competitive landscape, regulatory constraints, or stakeholder notes here. -->
