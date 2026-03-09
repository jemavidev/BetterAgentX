---
inclusion: manual
---

# Memory System Usage Guide for Kiro

## Overview

Since Kiro doesn't have automatic hooks like Claude Code, AgentX must manually update memory after significant work using the wrapper script.

## When to Update Memory (Protocol 5b)

| Score | Criteria | Action |
|-------|----------|--------|
| 0 | Conversational only | Nothing |
| 1 | Any file edited/created | Update context |
| 2-3 | 2+ files OR structural choice | Log task |
| 4 | 3+ files OR architectural decision | Log task + decision + context |

## Commands

### Add Task
```bash
bash .kiro/scripts/update-memory.sh task \
  TASK-ID "Task title" status agent \
  "Outcome description" priority "tags,csv" duration_min
```

**Example:**
```bash
bash .kiro/scripts/update-memory.sh task \
  TASK-01 "Implement auth flow" completed coder \
  "JWT auth with refresh tokens, 3 files changed" \
  high "auth,security" 120
```

### Add Decision
```bash
bash .kiro/scripts/update-memory.sh decision \
  DEC-ID "Decision title" status agent \
  "Context (why needed)" "Decision made" "Alternatives" "Consequences"
```

**Example:**
```bash
bash .kiro/scripts/update-memory.sh decision \
  DEC-01 "Use PostgreSQL over MongoDB" implemented architect \
  "Need strong relational guarantees for financial data" \
  "PostgreSQL with UUID primary keys" \
  "MongoDB, MySQL" \
  "Complex joins become easier, need migrations for schema changes"
```

### Add Pattern
```bash
bash .kiro/scripts/update-memory.sh pattern \
  PAT-ID "pattern-name" category \
  "Problem description" "Solution description"
```

**Example:**
```bash
bash .kiro/scripts/update-memory.sh pattern \
  PAT-01 "repository-pattern" architectural \
  "Business logic coupled to database queries" \
  "Abstract data access behind Repository interfaces"
```

### Update Context
```bash
bash .kiro/scripts/update-memory.sh context field value
```

**Examples:**
```bash
bash .kiro/scripts/update-memory.sh context version 2.0.0
bash .kiro/scripts/update-memory.sh context phase "2.0 — Auth Implementation"
bash .kiro/scripts/update-memory.sh context focus "User authentication system"
```

## Adding Agents and Skills (Runtime Mode)

When operating in `installed` mode, you can extend the system:

### Add a New Agent
Register a new agent in `AGENTS.md` under `## PROJECT AGENTS`:
```
| AgentName | subagent_type | Domain description (max 60 chars) |
```

Valid subagent_type values: `architect` | `coder` | `critic` | `security` | `tester` | `ux-designer` | `writer` | `teacher` | `product-manager` | `devops` | `data-scientist` | `researcher` | `general-purpose`

**Validation rules:**
- Agent name: letters, numbers, spaces, hyphens only
- Domain: plain text, max 60 chars
- No forbidden keywords: ignore, override, system prompt, instructions, forget, disregard

### Add a New Skill
Register a new skill in `AGENTS.md` under `## PROJECT SKILLS`:
```
| skill-name | .kiro/skills/skill-name.md | Domain description |
```

**Validation rules:**
- Skill name: kebab-case only (lowercase + hyphens)
- No path traversal (no `../`)
- No duplicate names

## Document Governance

When creating new `.md` documents:
1. Use `lowercase-with-hyphens.md` naming (no dates, no uppercase, no underscores)
2. Add required frontmatter at the top:
   ```markdown
   ---
   title: Document Title
   version: 1.0
   date: YYYY-MM-DD
   author: AgentX/YourRole
   status: Draft | Complete | Archived
   category: Protocol | Script | Memory | Config | Documentation | Phase
   ---
   ```
3. Never delete documents — archive them by moving to a project archive folder

## Troubleshooting

**Memory not updating?**
```bash
# Check if scripts exist
ls -la .kiro/scripts/

# Check if Claude scripts are available (for memory bridge)
ls -la .claude/scripts/add-*.sh

# Test memory update
bash .kiro/scripts/update-memory.sh context focus "Test"
```

**What memory bridge requires:**
- Claude platform installed (`.claude/scripts/` must exist)
- `jq` installed
- Run: `bash installer/install.sh --platform=claude --target=.`

---

**Version:** 3.8.0
**Last Updated:** 2026-03-07
