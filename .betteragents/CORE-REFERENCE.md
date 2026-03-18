# BetterAgents Core System Reference

**Version:** 4.0.0
**Platform:** Claude Code + Kiro (Multi-Platform)
**Last Updated:** 2026-03-18

---

## Overview

This document serves as the authoritative reference for the BetterAgents core system located in `.claude/`. This is the **source of truth** for all platform adaptations. Any changes to the system architecture, agents, skills, or memory structure must be reflected here first.

## Core Principle

> `.claude/` is 100% functional and must NEVER be modified by platform adapters. All other platforms (Kiro, Windsurf, etc.) read from `.claude/` and generate their own platform-specific files.

---

## System Architecture

### 1. Orchestrator (AgentX)

**File:** `CLAUDE.md` (450+ lines)  
**Role:** Central dispatcher and router  
**Methodology:** 4-D (Deconstruct → Diagnose → Develop → Dispatch)

**Key Responsibilities:**
- Intent analysis and query routing
- Memory context injection (~150 tokens max)
- Skill injection (max 3 per dispatch)
- Critic Gate enforcement
- Anti-loop detection
- Memory write enforcement

**Dispatch Modes:**
- Mode A: Direct response (trivial queries)
- Mode B: Single agent dispatch
- Mode C: Multi-agent workflow

**Protocols:**
- Protocol 0: Session start (read MEMORY.md + session-last.md)
- Protocol 0.5: Triviality Gate (0-5 scoring)
- Protocol 0.6: Plan Mode (complexity threshold)
- Protocol 1: Memory context injection
- Protocol 2: Skill injection
- Protocol 3: Critic Gate
- Protocol 4: Feedback loop + anti-loop
- Protocol 4.7: Post-change verification
- Protocol 5: Memory writes (mandatory triggers)
- Protocol 5b: Memory self-assessment gate

---

### 2. Agent Ecosystem

**Location:** `.claude/agents/*.md`  
**Count:** 12 specialized agents  
**Format:** Markdown with YAML frontmatter

#### Agent Structure

```yaml
---
name: agent-name
description: When to use this agent and what it specializes in
---

# 🎯 Agent: Display Name

## Role
[Agent's primary responsibility]

## Expertise
[Bullet list of specializations]

## Core Principles
[Key principles this agent follows]

## Guidelines
[When and how to use this agent]

## Output Format
[Expected output structure]

## Associated Skills
[Skills that can be injected for this agent]

## Memory Contributions
[What memory files this agent updates]
```

#### Complete Agent List

| Agent | File | subagent_type | Domain |
|-------|------|---------------|--------|
| Architect | architect.md | `architect` | System design, API, scalability, DDD |
| Coder | coder.md | `coder` | Implementation, debugging, refactoring |
| Critic | critic.md | `critic` | Risk assessment, Tenth Man Rule |
| Security | security.md | `security` | OWASP, auth, cryptography |
| Tester | tester.md | `tester` | TDD, unit/integration/E2E |
| UX Designer | ux-designer.md | `ux-designer` | UI/UX, accessibility |
| Writer | writer.md | `writer` | Docs, README, API docs |
| Teacher | teacher.md | `teacher` | Concepts, learning paths |
| Product Manager | product-manager.md | `product-manager` | Strategy, user stories, roadmaps |
| DevOps | devops.md | `devops` | CI/CD, Docker, Kubernetes, IaC |
| Data Scientist | data-scientist.md | `data-scientist` | ML, statistics, data analysis |
| Researcher | researcher.md | `researcher` | Tech research, comparisons |

---

### 3. Skills System

**Location:** `.claude/commands/*.md`  
**Count:** 79 skills  
**Format:** Markdown with YAML frontmatter

#### Skill Structure

```yaml
---
description: Brief description of when to use this skill
---

# Skill Name

[Detailed skill content with patterns, examples, and best practices]

## When to Use This Skill
[Specific scenarios]

## Core Concepts
[Key concepts and principles]

## Patterns
[Code patterns and examples]

## Best Practices
[Guidelines and recommendations]

## Resources
[Related files and references]
```

#### Skill Categories

- **Architecture:** architecture-patterns, api-design-principles, microservices-patterns, ddd-patterns
- **Implementation:** error-handling-patterns, async-python-patterns, modern-javascript-patterns
- **Testing:** test-driven-development, e2e-testing-patterns
- **DevOps:** docker-expert, github-actions-templates, deployment-pipeline-design
- **Security:** auth-implementation-patterns, security-audit-checklist
- **Documentation:** doc-coauthoring, changelog-automation

---

### 4. Memory System

**Location:** `.claude/memory/*.json` + `.md`  
**Purpose:** Persistent cross-session memory

#### Memory Files

| File | Type | Purpose | Auto-loaded |
|------|------|---------|-------------|
| `MEMORY.md` | Markdown | Summary index (<120 lines) | ✅ Always |
| `session-last.md` | Markdown | Last session summary | ✅ Session start |
| `workflow-prefs.md` | Markdown | User preferences | ✅ Always |
| `active-context.json` | JSON | Current project state | On-demand |
| `decision-log.json` | JSON | Architecture decisions (ADR) | On-demand |
| `progress.json` | JSON | Task tracking | On-demand |
| `patterns.json` | JSON | Reusable patterns | On-demand |
| `llm-usage.json` | JSON | Session activity log | On-demand |
| `token-accounting.json` | JSON | Token usage breakdown | On-demand |
| `metrics-analytics.json` | JSON | System metrics | On-demand |
| `alerts-registry.json` | JSON | Live alerts + rules | On-demand |
| `memory-stats.json` | JSON | File size breakdown | On-demand |
| `project-metrics.json` | JSON | Project size/complexity | On-demand |
| `dashboard.html` | HTML | Interactive visualization | Web UI |

#### Memory Write Scripts

**Location:** `.claude/scripts/`

- `add-task.sh` - Append task to progress.json
- `add-decision.sh` - Append decision to decision-log.json
- `add-pattern.sh` - Append pattern to patterns.json
- `update-context.sh` - Update active-context.json

**Mandatory Triggers (AgentX only):**

1. **Task completion** → `add-task.sh`
2. **Architecture decision** → `add-decision.sh`
3. **Pattern identified (2+ uses)** → `add-pattern.sh`
4. **Phase/focus change** → `update-context.sh`

---

### 5. Configuration

**Location:** `config/betteragents.json`

```json
{
  "name": "BetterAgentX",
  "version": "3.7.0",
  "platform": "claude-code",
  "agents": {
    "agentx": { "file": "CLAUDE.md", "type": "orchestrator" },
    "architect": { "file": ".claude/agents/architect.md", "type": "core" }
    // ... 11 more agents
  },
  "features": {
    "agentx": { "enabled": true },
    "memory": { "enabled": true, "autoLoad": ".claude/memory/MEMORY.md" },
    "commands": { "enabled": true, "directory": ".claude/commands" },
    "hooks": { "enabled": true, "configFile": ".claude/settings.local.json" }
  },
  "directories": {
    "orchestrator": "CLAUDE.md",
    "agents": ".claude/agents",
    "commands": ".claude/commands",
    "memory": ".claude/memory",
    "scripts": ".claude/scripts"
  }
}
```

---

## Data Formats

### Decision Log Entry

```json
{
  "id": "DEC-NN",
  "title": "Short decision title",
  "date": "2026-03-02T08:00:00-05:00",
  "timestamp": "2026-03-02T08:00:00-05:00",
  "agent": "architect",
  "status": "implemented",
  "tags": ["tag1", "tag2"],
  "context": "Why this decision was needed",
  "decision": "What was decided",
  "rationale": "Why this approach",
  "consequences": {
    "positive": ["Benefit 1"],
    "negative": ["Limitation 1"],
    "risks": ["Risk 1"]
  }
}
```

### Task Entry

```json
{
  "id": "TASK-NN",
  "title": "Short task title",
  "status": "completed",
  "agent": "coder",
  "priority": "high",
  "date": "2026-03-02T08:00:00-05:00",
  "createdAt": "2026-03-02T08:00:00-05:00",
  "updatedAt": "2026-03-02T08:00:00-05:00",
  "duration": 45,
  "tags": ["tag1", "tag2"],
  "triviality": { "score": 2, "automated": false },
  "description": "What needs to be done",
  "outcome": "What was actually done"
}
```

### Pattern Entry

```json
{
  "id": "PAT-NN",
  "name": "kebab-case-name",
  "title": "Pattern Display Title",
  "category": "architectural",
  "date": "2026-03-02T08:00:00-05:00",
  "createdAt": "2026-03-02T08:00:00-05:00",
  "agent": "agentx",
  "applications": 1,
  "usageCount": 1,
  "tags": ["tag1", "tag2"],
  "description": "What problem this solves",
  "context": "When to use this pattern",
  "solution": "How to implement it"
}
```

---

## Routing Logic

### Task() Function

```python
Task(subagent_type="agent-name", prompt="[CONTEXT]\n...\n[SKILLS]\n...\n[TASK]\n...")
```

### Routing Table

| Query Type | Agent | Trigger Keywords |
|------------|-------|------------------|
| System design, API, architecture | `architect` | design, architecture, API, scalability |
| Implementation, debug, refactor | `coder` | implement, fix, debug, refactor |
| Tests, TDD, coverage | `tester` | test, TDD, coverage, QA |
| Docs, README, changelogs | `writer` | document, README, changelog |
| CI/CD, Docker, infra | `devops` | deploy, Docker, CI/CD, Kubernetes |
| Critical analysis, risks | `critic` | risk, critique, challenge |
| Research, comparisons | `researcher` | research, compare, evaluate |
| Auth, security, OWASP | `security` | security, auth, vulnerability |
| UI/UX, accessibility | `ux-designer` | UI, UX, design, accessibility |

---

## Hooks System

**Location:** `.claude/settings.local.json`

### Hook Types

- `UserPromptSubmit` - Before each user message
- `Stop` - Session end
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution

### Active Hooks

1. **Memory debt reminder** (UserPromptSubmit)
2. **Session summary** (Stop)
3. **Syntax verification** (PostToolUse - Write/Edit)
4. **Dashboard rebuild** (PostToolUse - Bash on memory files)

---

## Platform Adaptation Guidelines

### For Kiro

1. **Agents** → `.kiro/agents/*.md` (custom agent format)
2. **Skills** → `.kiro/skills/*.md` (skill format)
3. **Memory** → `.kiro/steering/*.md` (steering files)
4. **Orchestrator** → `KIRO.md` (adapted from CLAUDE.md)

### For Other Platforms

Follow the same pattern:
- Read from `.claude/` (source of truth)
- Generate platform-specific files
- Never modify `.claude/` directly
- Sync changes back through `.betteragents/sync/`

---

## Version History

- **3.7.0** (2026-03-02): Multi-platform architecture, Protocol 5b
- **3.6.0** (2026-02-28): Dashboard SAFETY tab, per-file heat-map
- **3.5.0** (2026-02-27): 3-layer memory enforcement
- **3.3.0** (2026-02-20): 6-pillar safety framework

---

## References

- Main README: `README.md`
- Configuration: `config/betteragents.json`
- Orchestrator: `CLAUDE.md`
- Memory docs: `docs/memory/README.md`
- Blueprint: `BLUEPRINT-MULTI-PLATFORM.md`
