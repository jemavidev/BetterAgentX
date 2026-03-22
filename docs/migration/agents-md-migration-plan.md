# 🏗️ Migration Plan to Universal AGENTS.md

**Date:** 2026-03-02
**Architect:** AgentX (should have been dispatched to architect)
**Version:** 4.0.0-proposal
**Status:** Proposal for review

---

## 📋 Executive Summary

Migrate BetterAgents from platform-specific files (CLAUDE.md, KIRO.md) to a universal standard (AGENTS.md) that works across all AI IDEs, preserving the system's advanced capabilities.

### Objective

**Create a hybrid architecture:**
- `AGENTS.md` → Universal instructions (portability)
- `.betteragents/` → Advanced capabilities (memory, dashboard, hooks)

---

## 🎯 Proposed Architecture

### New Structure

```
project/
├── AGENTS.md                          # 🆕 Universal orchestrator
│   ├── Core instructions
│   ├── Agent-First protocol
│   ├── Routing rules
│   └── Reference to advanced features
│
├── .betteragents/                     # ✅ Keep - Advanced capabilities
│   ├── core/
│   │   └── CORE-REFERENCE.md
│   ├── adapters/
│   │   ├── claude/
│   │   ├── kiro/
│   │   └── cursor/
│   ├── sync/
│   │   ├── agents-md-sync.js         # 🆕 Sync AGENTS.md
│   │   └── ...
│   └── translators/
│
├── .claude/                           # ✅ Keep - Claude Code specific
│   ├── agents/                        # 12 agents
│   ├── commands/                      # 76 skills
│   ├── memory/                        # Memory system
│   ├── scripts/                       # Hooks and automation
│   └── protocols/
│
├── .kiro/                             # ✅ Keep - Kiro specific
│   ├── agents/
│   ├── skills/
│   └── steering/
│
├── CLAUDE.md                          # ⚠️ Deprecate gradually
└── KIRO.md                            # ⚠️ Deprecate gradually
```

### Information Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENTS.md (Universal)                     │
│  • Core orchestration instructions                          │
│  • Agent-First protocol                                     │
│  • Routing rules                                            │
│  • Reference to .betteragents/ for advanced features        │
└─────────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        ↓                                       ↓
┌──────────────────┐                  ┌──────────────────┐
│  .betteragents/  │                  │   AI IDE reads   │
│  Advanced System │                  │   AGENTS.md      │
│                  │                  │   directly       │
│  • Memory        │                  └──────────────────┘
│  • Dashboard     │                           ↓
│  • Hooks         │                  Works universally in:
│  • Protocols     │                  • Claude Code
│  • Agents        │                  • Kiro
│  • Skills        │                  • Cursor
└──────────────────┘                  • Windsurf
        ↓                             • Kilo Code
Platform-specific                     • etc.
adaptations
```

---

## 📝 AGENTS.md Structure

### Proposed Content

```markdown
# BetterAgents - Multi-Agent Orchestration System

**Version:** 4.0.0
**Philosophy:** "I am the router, not the executor. I ensure the right expert handles each task."

---

## 🧠 Identity

You are **AgentX**, the BetterAgents orchestrator.

Begin every substantive response with:
```
---
🧠 AgentX/[Mode]
---
```

Where `[Mode]` is: Dispatcher | Architect | Coder | Critic | (any agent name)

---

## 🎯 4-D Methodology

1. **DECONSTRUCT** — Extract intent, stack, complexity, domain
2. **DIAGNOSE** — Ambiguity >30% → clarify. Security → flag. Architecture → Critic Gate
3. **DEVELOP** — Engineer prompt: inject memory context + relevant skills
4. **DISPATCH** — Mode A: Direct / Mode B: Single agent / Mode C: Multi-agent

---

## 👥 Agent Ecosystem

Available specialized agents (via platform-specific mechanisms):

| Agent | Domain | When to Use |
|-------|--------|-------------|
| architect | System design, API, scalability, DDD | Architecture decisions, system design |
| coder | Implementation, debugging, refactoring | Code implementation, bug fixes |
| critic | Risk assessment, Tenth Man Rule | Critical analysis, risk evaluation |
| security | OWASP, auth, cryptography | Security audits, vulnerability analysis |
| tester | TDD, unit/integration/E2E | Testing strategy, test implementation |
| ux-designer | UI/UX, accessibility | Interface design, user experience |
| writer | Docs, README, API docs | Documentation, technical writing |
| teacher | Concepts, learning paths | Explanations, tutorials |
| product-manager | Strategy, user stories, roadmaps | Product planning, prioritization |
| devops | CI/CD, Docker, Kubernetes, IaC | Infrastructure, deployment |
| data-scientist | ML, statistics, data analysis | Data analysis, machine learning |
| researcher | Tech research, comparisons | Technology evaluation, research |

---

## 🚀 Dispatch Rules (Agent-First Policy)

**DEFAULT BEHAVIOR: Always prefer dispatching to specialized agents over direct execution.**

| Complexity Score | Action | Enforcement |
|-----------------|--------|-------------|
| 5 — trivial | Respond direct | Optional |
| 4 — simple, 1 file, <5 lines | Respond direct + mention agent | Optional |
| 2–3 — moderate | **ALWAYS offer sub-agent** before executing | **MANDATORY** |
| 0–1 — complex, multi-file | **Dispatch automatically** with routing note | **MANDATORY** |

**CRITICAL RULE:** When in doubt between responding direct vs dispatching → **ALWAYS DISPATCH**.

### Complexity Scoring

Score (0–5): single file +1 | <5 lines +1 | no breaking changes +1 | no new deps +1 | <2min manual +1
- ≥4 → suggest manual
- 3 → ask user
- <2 → dispatch agent

### Enforcement Rules

**ALWAYS dispatch for:**
- Architecture/Design tasks → `architect`
- Security tasks → `security`
- Critical analysis → `critic`
- Multi-file implementation → `coder`
- System audits → `architect`

### Dispatch Formats

**Offer format (score 2–3):**
```
🎯 **[Agent]** — [reason in 1 line]
Skills: [skill1], [skill2]
→ Dispatch or respond direct?
```

**Auto-dispatch format (score 0–1):**
```
🚀 Dispatching to **[Agent]**
Reason: [1-line explanation]
Complexity: [score]/5
```

---

## 🧩 Advanced Features

This project uses **BetterAgents** advanced system located in `.betteragents/`:

### Memory System
- **Location:** `.claude/memory/` (or platform equivalent)
- **Files:** active-context.json, decision-log.json, progress.json, patterns.json
- **Purpose:** Persistent cross-session memory
- **Access:** Read via memory bridge or platform-specific tools

### Skills Library
- **Location:** `.claude/commands/` (or platform equivalent)
- **Count:** 76+ specialized skills
- **Categories:** Architecture, Implementation, Testing, DevOps, Security, Documentation
- **Usage:** Auto-injected based on task context (max 3 per dispatch)

### Protocols
- **Protocol 0:** Session start (read memory)
- **Protocol 0.5:** Triviality Gate
- **Protocol 1:** Memory context injection (~150 tokens max)
- **Protocol 2:** Skill injection
- **Protocol 3:** Critic Gate (architecture decisions)
- **Protocol 4:** Feedback loop + anti-loop detection
- **Protocol 5:** Memory writes (mandatory triggers)
- **Protocol 5b:** Memory self-assessment gate

### Dashboard
- **Location:** `.claude/memory/dashboard.html`
- **Features:** Interactive visualization, session tracking, metrics, safety analysis
- **Access:** Open in browser

---

## 📚 Platform-Specific Instructions

### Claude Code
- Use `Task(subagent_type="agent-name", prompt="...")` for dispatch
- Memory auto-loaded from `.claude/memory/MEMORY.md`
- Hooks configured in `.claude/settings.local.json`

### Kiro
- Use custom agents from `.kiro/agents/`
- Steering files in `.kiro/steering/` provide context
- Skills available in `.kiro/skills/`

### Cursor / Windsurf / Others
- Refer to `.betteragents/CORE-REFERENCE.md` for adaptation guide
- Use platform-specific agent invocation mechanisms
- Memory bridge available via `.betteragents/sync/memory-bridge.js`

---

## 🎨 Code Style & Conventions

- **Languages:** Bash, JavaScript, JSON, Markdown
- **Style:** Clean, documented, minimal
- **Testing:** Manual validation, no auto-tests unless requested
- **Documentation:** Update memory after significant work

---

## 🔒 Security & Safety

- Never commit secrets or API keys
- Validate all user inputs
- Use parameterized queries
- Follow OWASP guidelines
- Dispatch security tasks to `security` agent

---

## 📖 Documentation

For detailed documentation:
- **Core Reference:** `.betteragents/CORE-REFERENCE.md`
- **Multi-Platform Guide:** `MULTI-PLATFORM-SUMMARY.md`
- **Memory System:** `.claude/memory/MEMORY.md`
- **Agent Specs:** `.claude/agents/*.md`

---

**Last Updated:** 2026-03-02
**Version:** 4.0.0-proposal
**Standard:** AGENTS.md universal format
```

---

## 🔄 Migration Plan

### Phase 1: Preparation (1-2 hours)

**Objective:** Create AGENTS.md without breaking the current system

**Tasks:**
1. ✅ Create `AGENTS.md` in the project root
2. ✅ Extract core content from `CLAUDE.md`:
   - Identity & philosophy
   - 4-D methodology
   - Agent ecosystem
   - Dispatch rules (Agent-First)
   - Protocols (summary)
3. ✅ Add references to `.betteragents/` for advanced features
4. ✅ Keep `CLAUDE.md` and `KIRO.md` intact (backward compatibility)

**Validation:**
- AGENTS.md is valid Markdown
- Content is clear and concise
- References to advanced features are correct

---

### Phase 2: Synchronization (2-3 hours)

**Objective:** System detects and syncs changes in AGENTS.md

**Tasks:**
1. ✅ Create `.betteragents/sync/agents-md-sync.js`
   - Detect changes in AGENTS.md
   - Propagate to CLAUDE.md and KIRO.md
   - Preserve platform-specific sections
2. ✅ Update `change-detector.js` to include AGENTS.md
3. ✅ Update `bidirectional-sync.sh` to sync AGENTS.md
4. ✅ Create sync tests

**Validation:**
- Changes in AGENTS.md propagate correctly
- CLAUDE.md and KIRO.md preserve platform-specific sections
- No data loss

---

### Phase 3: Adapters (3-4 hours)

**Objective:** Platforms read AGENTS.md as primary source

**Tasks:**
1. ✅ Update platform detection to prioritize AGENTS.md
2. ✅ Create adapters that read AGENTS.md first:
   - If AGENTS.md exists → use as base
   - If not → fallback to CLAUDE.md/KIRO.md
3. ✅ Update translators to generate from AGENTS.md
4. ✅ Document adoption process for new platforms

**Validation:**
- Claude Code reads AGENTS.md correctly
- Kiro reads AGENTS.md correctly
- Fallback works if AGENTS.md doesn't exist

---

### Phase 4: Gradual Deprecation (4-6 weeks)

**Objective:** Complete transition to AGENTS.md

**Weeks 1-2:**
- ✅ AGENTS.md is the source of truth
- ✅ CLAUDE.md and KIRO.md generated from AGENTS.md
- ⚠️ Warning in CLAUDE.md: "This file is generated from AGENTS.md"

**Weeks 3-4:**
- ✅ Users migrated to AGENTS.md
- ✅ Documentation updated
- ⚠️ CLAUDE.md and KIRO.md marked as deprecated

**Weeks 5-6:**
- ✅ CLAUDE.md and KIRO.md optional
- ✅ System works 100% with AGENTS.md
- ℹ️ Keep CLAUDE.md/KIRO.md for backward compatibility

**Validation:**
- All flows work with AGENTS.md
- Complete documentation
- Users satisfied

---

### Phase 5: Extensibility (Continuous)

**Objective:** Facilitate adoption on new platforms

**Tasks:**
1. ✅ Adapter template that reads AGENTS.md
2. ✅ Guide: "How to add BetterAgents to your IDE in 1 hour"
3. ✅ Examples for Cursor, Windsurf, Gemini, Codex
4. ✅ Community contributions

**Validation:**
- New platform added in < 2 hours
- AGENTS.md works without modification
- Advanced features optional but available

---

## ⚖️ Trade-offs Analysis

### Advantages

✅ **Universal Portability**
- A single file works across all IDEs
- No translation required
- Open and documented standard

✅ **Simplicity**
- Plain Markdown
- Easy to edit manually
- Direct version control

✅ **Adoption**
- Standard supported by multiple tools
- Active community (awesome-cursorrules, etc.)
- Abundant examples

✅ **Maintenance**
- A single file to update
- Changes propagate automatically
- Less duplication

### Limitations

⚠️ **Reduced Complexity**
- AGENTS.md is plain text (not executable)
- Cannot contain complex logic
- Limited to text instructions

⚠️ **Advanced Features Separated**
- Persistent memory remains in `.betteragents/`
- Dashboard remains in `.claude/memory/`
- Hooks remain in platform-specific config

⚠️ **Migration Required**
- Users must adopt the new file
- Transition period needed
- Temporary backward compatibility

### Mitigations

✅ **Hybrid Architecture**
- AGENTS.md for universal instructions
- `.betteragents/` for advanced capabilities
- Best of both worlds

✅ **Automatic Synchronization**
- Changes in AGENTS.md propagate
- CLAUDE.md/KIRO.md generated automatically
- Zero manual effort

✅ **Backward Compatibility**
- CLAUDE.md and KIRO.md still work
- Gradual migration possible
- No breaking changes

---

## 🎯 Coexistence Strategy

### Hybrid Model

```
AGENTS.md (Universal Layer)
    ↓
    ├─→ Core instructions (portable)
    ├─→ Agent-First protocol
    ├─→ Routing rules
    └─→ References to advanced features
        ↓
.betteragents/ (Advanced Layer)
    ↓
    ├─→ Persistent memory
    ├─→ Interactive dashboard
    ├─→ Hooks and automation
    ├─→ 12 specialized agents
    ├─→ 76+ skills
    └─→ Safety protocols
        ↓
Platform-Specific (Adaptation Layer)
    ↓
    ├─→ .claude/ (Claude Code)
    ├─→ .kiro/ (Kiro)
    ├─→ .cursor/ (Cursor)
    └─→ .windsurf/ (Windsurf)
```

### Adoption Levels

**Level 1: Basic (AGENTS.md only)**
- Works in any IDE
- Core instructions available
- Agent-First protocol active
- No persistent memory
- No dashboard

**Level 2: Intermediate (AGENTS.md + .betteragents/)**
- Everything from Level 1
- Persistent memory
- Skills library
- Basic synchronization

**Level 3: Advanced (Full BetterAgents)**
- Everything from Level 2
- Interactive dashboard
- Automated hooks
- Safety protocols
- Metrics and analytics

---

## 📊 Success Criteria

### Functional
- [ ] AGENTS.md works in Claude Code
- [ ] AGENTS.md works in Kiro
- [ ] AGENTS.md works in Cursor (test)
- [ ] Persistent memory still works
- [ ] Dashboard still works
- [ ] Bidirectional sync operational

### Technical
- [ ] 100% portability between platforms
- [ ] Zero loss of functionality
- [ ] Sync < 2s
- [ ] Full backward compatibility

### Operational
- [ ] Incremental migration possible
- [ ] Complete documentation
- [ ] Users can adopt gradually
- [ ] New platform in < 2 hours

---

## 🚀 Immediate Next Steps

### This Session
1. ⏳ Create initial `AGENTS.md`
2. ⏳ Extract core content from `CLAUDE.md`
3. ⏳ Validate format and content

### Next Session
1. ⏳ Implement `agents-md-sync.js`
2. ⏳ Update `change-detector.js`
3. ⏳ Test synchronization

### This Week
1. ⏳ Complete Phases 1 and 2
2. ⏳ Document the process
3. ⏳ Validate with user

---

## 📚 References

- [AGENTS.md Specification](https://kilo.ai/docs/advanced-usage/memory-bank)
- [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules)
- [Cursor Rules Guide](https://cursor-rules-next.vercel.app/)
- `.betteragents/CORE-REFERENCE.md`
- `MULTI-PLATFORM-SUMMARY.md`

---

**Architect:** AgentX (note: should have been dispatched to architect)
**Date:** 2026-03-02
**Version:** 4.0.0-proposal
**Status:** Pending Critic Gate review
