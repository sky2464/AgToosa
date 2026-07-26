# AgToosa Architecture Overview

> Deep dive for the 4-phase lifecycle. For a 30-second overview, see the [README lifecycle diagram](../README.md#lifecycle-at-a-glance).

AgToosa organizes development into **4 core phases**, executed via slash commands. Every feature follows the same lifecycle — from research to deployment — with mandatory review gates and a continuous loop back to the next story.

```mermaid
flowchart TD
    classDef setup   fill:#6366f1,stroke:#4338ca,color:#fff,font-weight:bold
    classDef spec    fill:#0284c7,stroke:#0369a1,color:#fff,font-weight:bold
    classDef build   fill:#059669,stroke:#047857,color:#fff,font-weight:bold
    classDef review  fill:#d97706,stroke:#b45309,color:#fff,font-weight:bold
    classDef gate    fill:#7c3aed,stroke:#6d28d9,color:#fff,font-weight:bold
    classDef ship    fill:#dc2626,stroke:#b91c1c,color:#fff,font-weight:bold

    INIT(["🚀  /agtoosa-init
    ─────────────────────
    Scan · Validate · Configure
    ‹ run once per project ›"])

    subgraph SPEC ["📋  PHASE 1 — SPEC & PLANNING"]
        direction TB
        S1["🔍 Context Research
        Codebase scan · Web analysis
        Clarifying Q&A"]
        S2["📝 Executable Specification
        Architecture blueprint
        Acceptance criteria"]
        S3["⚠️ STRIDE Threat Model
        DFD generation
        Security requirements"]
        S1 --> S2 --> S3
    end

    subgraph BUILD ["🏗️  PHASE 2 — BUILD & TEST"]
        direction TB
        B1["📌 Scope Declaration
        Task breakdown
        Out-of-scope boundary"]
        B2["🔴  RED
        Write failing test first"]
        B3["🟢  GREEN
        Minimal implementation"]
        B4["🔵  REFACTOR
        Clean · lint · &lt;500 LOC"]
        B5["🔬 Test Army
        Unit · Integration · SAST · DAST"]
        B1 --> B2 --> B3 --> B4 --> B5
    end

    subgraph REVIEW ["🔍  PHASE 3 — MULTI-PERSONA REVIEW"]
        direction LR
        R1["🛡️ Security Officer
        OWASP Top 10
        STRIDE audit"]
        R2["📊 Eng Manager
        Architecture · Coverage
        500-line gate"]
        R3["💼 CEO
        Product alignment
        Scope check"]
        R4["🧪 QA Lead
        Test quality
        Edge cases"]
    end

    GATE{{"All Reviews
    Passed?"}}

    subgraph SHIP ["🚢  PHASE 4 — SHIP & ARCHIVE"]
        direction TB
        SH1["✅ Readiness Gate
        All checks pass
        No open blockers"]
        SH2["📦 Deploy
        Approval-gated deployment · Changelog
        GitHub Release"]
        SH3["🗄️ Archive
        Specs → Docs/archived/
        Master-Plan updated"]
        SH4["💡 Next Story
        Retro · Suggest
        next feature"]
        SH1 --> SH2 --> SH3 --> SH4
    end

    INIT        --> SPEC
    SPEC        --> BUILD
    BUILD       --> REVIEW
    R1 & R2 & R3 & R4 --> GATE
    GATE        -- "✅  Approved"  --> SHIP
    GATE        -- "🔴  Changes needed" --> BUILD
    SH4         -- "🔄  Next story" --> SPEC

    class INIT setup
    class S1,S2,S3 spec
    class B1,B2,B3,B4,B5 build
    class R1,R2,R3,R4 review
    class GATE gate
    class SH1,SH2,SH3,SH4 ship
```

| Phase | Command | What It Does |
|-------|---------|-------------|
| **0. Setup** | `/agtoosa-init` | **One-time:** Scan codebase, validate AI configs, establish context |
| **1. Spec & Planning** | `/agtoosa-spec` | Research, specify, architect, STRIDE threat model, and atomic task planning. Generated spec files follow `Docs/SPEC-FORMAT.md` (EARS acceptance criteria, hierarchical task tree, Wave Plan). |
| **2. Build & Test** | `/agtoosa-build` | TDD Red-Green-Refactor against the planned task list → full test army |
| **3. Multi-Persona Review** | `/agtoosa-review` | Security · Architecture · Product · QA review gate |
| **4. Ship & Cleanup** | `/agtoosa-ship` | Deploy, archive, changelog, suggest next story |

## Related docs

- [README](../README.md) — short onboarding
- [README reference](readme-reference.md) — install matrix, commands, security tables
- [Enforcement comparison](../enforcement-comparison.md) — guided vs evidenced vs enforced
- [Phase lifecycle (wiki)](https://github.com/sky2464/AgToosa/wiki/Phase-Lifecycle)
