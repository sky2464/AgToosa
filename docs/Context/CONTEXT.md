# Project Domain Language

**Status Guide**: The read-only Coach sub-agent that runs `/agtoosa-status` and walks the user through Part 5.5 Recommended Next Actions. Context: `Docs/AgToosa_StatusGuide.md`, `.github/agents/agtoosa-status-guide.agent.md`. Not: "status agent", "health bot".

**Coach loop**: The post-dashboard sequence that presents up to three Part 5.5 actions with rationale and waits for user authorization before each fix command. Context: `AgToosa_StatusGuide.md`. Not: "auto-fix", "autopilot".

**Authorization gate**: Explicit yes/no user consent required before invoking `/agtoosa-init`, `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-task`, or `/agtoosa-ship` from the Status Guide. Context: AC-004 in spec DEV-006. Not: "confirm", "approve PR".

**Recommended Next Actions**: Deterministic ranked list from `AgToosa_Status.md` Part 5.5; grouped by fix-command with capped verb-phrases. Context: status dashboard output. Not: "suggestions", "todo list".

**Auditor**: The read-only persona that compiles the status dashboard without mutations. Context: `AgToosa_Skills.md` `/agtoosa-status` personas. Not: "reviewer", "linter".

**Help helper**: The on-demand `/agtoosa-help` assistance surface. It is not a main workflow phase and must load only when the user asks for help. Context: `agtoosa-help` platform variants. Not: "phase", "dispatcher".

**Help-next**: The `/agtoosa-help next` sub-command that reads current project state read-only and recommends exactly one next AgToosa command. Context: spec DEV-007. Not: "auto-run", "Status Guide replacement".

**Assistance-only command**: A command that explains or recommends workflow actions without mutating files, git state, or Master-Plan state. Context: `/agtoosa-help`, `/agtoosa-help next`. Not: "build step", "ship gate".

**Workflow skill**: An AgToosa-managed skill file, currently under `.codex/skills/agtoosa-*/SKILL.md`, that activates a canonical AgToosa workflow and preserves that workflow's gates. Context: DEV-008. Not: "thin dispatcher", "standalone replacement for Docs/AgToosa_*.md".

**Project Skill Discovery**: The `/agtoosa-init` step that identifies reusable, high-value project-specific skills from product, tech-stack, workflow, and domain context before asking whether to generate them. Context: DEV-008. Not: "install random marketplace skills".

**Story Skill Opportunity Synthesis**: The `/agtoosa-spec` step that derives story-specific skill candidates from the Goal Contract, acceptance criteria, architecture, and test plan. Context: DEV-008. Not: "create a skill for every task".

**Generated project skill**: A user-approved `.codex/skills/<skill-name>/SKILL.md` artifact created for a recurring project or story workflow, with optional `references/`, `scripts/`, or `assets/` only when needed. Context: DEV-008. Not: "chat-only preference", "secret store".
