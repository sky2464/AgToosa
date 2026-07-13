# Project Domain Language

**Status Guide**: The read-only Coach sub-agent that runs `/agtoosa-status` and walks the user through Part 5.5 Recommended Next Actions. Context: `Docs/AgToosa_StatusGuide.md`, `.github/agents/agtoosa-status-guide.agent.md`. Not: "status agent", "health bot".

**Coach loop**: The post-dashboard sequence that presents up to three Part 5.5 actions with rationale and waits for user authorization before each fix command. Context: `AgToosa_StatusGuide.md`. Not: "auto-fix", "autopilot".

**Authorization gate**: Explicit yes/no user consent required before invoking `/agtoosa-init`, `/agtoosa-spec`, `/agtoosa-build`, `/agtoosa-task`, or `/agtoosa-ship` from the Status Guide. Context: AC-004 in spec DEV-006. Not: "confirm", "approve PR".

**Recommended Next Actions**: Deterministic ranked list from `AgToosa_Status.md` Part 5.5; grouped by fix-command with capped verb-phrases. Context: status dashboard output. Not: "suggestions", "todo list".

**Auditor**: The read-only persona that compiles the status dashboard without mutations. Context: `AgToosa_Skills.md` `/agtoosa-status` personas. Not: "reviewer", "linter".

**Help helper**: The on-demand `/agtoosa-help` assistance surface. It is not a main workflow phase and must load only when the user asks for help. Context: `agtoosa-help` platform variants. Not: "phase", "dispatcher".

**Help-next**: The `/agtoosa-help next` sub-command that reads current project state read-only and recommends exactly one next AgToosa command. Context: spec DEV-007. Not: "auto-run", "Status Guide replacement".

**Project Intake**: Dual-mode freeform PM classifier that runs when the user omits `/agtoosa-*`: soft-expedite small asks; hard-gate Claim-Boundary-sized work with benefit-framed confirmation; persist Standing Corrections in `Docs/Context/workflow.md`. Context: DEV-110, ADR-013. Not: "new slash command", "runtime orchestrator", "Discovery Triage" (mid-build only), "help-next".

**Standing Corrections**: Dated, deduped always/never lessons in `Docs/Context/workflow.md` written by Project Intake so agents re-read them before repeating mistakes (e.g. inventing dependency versions from memory). Context: DEV-110. Not: "retro proposals only", "Update Log spam".

**Lifecycle Compass**: Semantic freeform router extending Project Intake — infers intent, reads `--status-line` SYNC state, anchors to Spec → Build → Review → Ship via **ANCHOR**; tributaries (explore/fix/track) serve a phase and return. Context: DEV-116, ADR-014. Not: "phrase table", "/agtoosa-compass command", "runtime orchestrator".

**ANCHOR**: Lifecycle phase label (`spec` · `build` · `review` · `ship` · `none`) printed on every Compass resolution. Context: DEV-116. Not: "git branch", "file path".

**Tributary**: Side work (explore, fix, track) allowed under Compass when it serves an anchored lifecycle phase and ends with a return cue. Context: DEV-116. Not: "permanent off-ramp", "skip spec forever".

**Phase pulse / SYNC line**: One executive line after lifecycle phases and from `agtoosa.sh --status-line` / `agtoosa.ps1 -StatusLine`. Context: ADR-012, DEV-109. Not: full `/agtoosa-status` dashboard.

**Lifecycle next-step**: Primary post-phase recommendation following Spec → Build → Review → Ship. Context: ADR-012. Not: universal “run `/agtoosa-status`” as headline.

**Clarity tags**: Combinable markers on Master-Plan / spec header: `ready` (`Ready`), `sa-ready` (`SA-R`), `needs-interview` (`N-CI`). Context: DEV-109 multi-spec intake. Not: story Status pills.

**Multi-spec intake**: Map confirmed objectives into child stories; interview per child (`sa-ready` parallel when allowed) or defer with `needs-interview`. Context: `AgToosa_Spec.md`. Not: `/agtoosa-spec to-issues` alone.

**Assistance-only command**: A command that explains or recommends workflow actions without mutating files, git state, or Master-Plan state. Context: `/agtoosa-help`, `/agtoosa-help next`. Not: "build step", "ship gate".

**Workflow skill**: An AgToosa-managed skill file, currently under `.codex/skills/agtoosa-*/SKILL.md`, that activates a canonical AgToosa workflow and preserves that workflow's gates. Context: DEV-008. Not: "thin dispatcher", "standalone replacement for Docs/AgToosa_*.md".

**Project Skill Discovery**: The `/agtoosa-init` step that identifies reusable, high-value project-specific skills from product, tech-stack, workflow, and domain context before asking whether to generate them. Context: DEV-008. Not: "install random marketplace skills".

**Story Skill Opportunity Synthesis**: The `/agtoosa-spec` step that derives story-specific skill candidates from the Goal Contract, acceptance criteria, architecture, and test plan. Context: DEV-008. Not: "create a skill for every task".

**Generated project skill**: A user-approved `.codex/skills/<skill-name>/SKILL.md` artifact created for a recurring project or story workflow, with optional `references/`, `scripts/`, or `assets/` only when needed. Context: DEV-008. Not: "chat-only preference", "secret store".

**Generated Project Mode**: The operating context where AgToosa workflow files are installed into another application's repository; docs refer to "the project" or "the product," not AgToosa as the app being built. Context: DEV-011, ADR-008. Not: "maintainer mode", "dogfood".

**Maintainer Dogfood Mode**: The operating context where the AgToosa repository uses AgToosa workflows to improve the generator; scope is `agtoosa.sh`, `lib/`, `template/`, and bats. Context: DEV-011, `docs/agtoosa-maintainer.md`. Not: "generated install", "downstream project".

**Master Architecture**: The durable project architecture map at `Docs/Master-Architecture.md`, created during setup and treated as high-priority context before architectural decisions. It captures goals, constraints, C4-style diagrams, system boundaries, data flow, deployment, security, observability, and decision links. Not: "Master-Plan", "Context files", "one-off diagram".

**Signed Registry Provenance**: Optional cryptographic signatures (minisign primary; cosign future alternate) on registry packs and release assets, verified with soft-warn when a signature artifact is present. Does not replace SHA-256 integrity or the registry `verified` flag. Not: "mandatory signed install", "SBOM", "fail-closed require-signatures" (those remain roadmap). Context: DEV-054, ADR-011.
