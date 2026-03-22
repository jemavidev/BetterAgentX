# 🧠 BetterAgents for Gemini

**Adapted from:** AgentX (Claude Code)
**Version:** 3.7.0
**Platform:** Gemini

---

## Overview

This is an adaptation of the BetterAgents system for Gemini. The core system lives in `.claude/` and this file provides Gemini-specific guidance.

## Available Agents

The following specialized agents are available in `.gemini/agents/`:

- **architect** - System design and architecture
- **coder** - Implementation and debugging
- **critic** - Critical analysis and risk assessment
- **security** - Security auditing
- **tester** - Testing and QA
- **ux-designer** - UI/UX design
- **writer** - Documentation
- **teacher** - Concept explanation
- **product-manager** - Product strategy
- **devops** - Infrastructure and deployment
- **data-scientist** - Data analysis and ML
- **researcher** - Technology research

## Available Skills

76+ skills are available in `.gemini/skills/` covering:
- Architecture patterns
- API design
- Testing strategies
- DevOps practices
- Security best practices
- And more...

## Memory System

Project memory is maintained in `.claude/memory/` and synchronized to `.gemini/steering/`:

- **project-context.md** - Current project state
- **architecture-decisions.md** - Recent decisions
- **reusable-patterns.md** - Identified patterns

## Usage in Gemini

When working in Gemini, the system will:
1. Load steering files automatically
2. Provide access to specialized agents
3. Inject relevant skills based on context
4. Maintain memory across sessions

## Synchronization

Changes made in Gemini are synchronized back to `.claude/memory/` through the `.betteragents/sync/` system.

---

**Original System:** CLAUDE.md (AgentX)
**Generated:** 2026-03-22T02:32:35.753Z
**Platform:** Gemini
