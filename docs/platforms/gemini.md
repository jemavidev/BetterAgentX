# BetterAgents on Gemini

This document provides platform-specific guidance for using the BetterAgents system within a Gemini environment.

## Overview

This is an adaptation of the AgentX (Claude Code) system for Gemini. The core system lives in `.claude/` and this file provides Gemini-specific guidance.

## File Structure

- **`.gemini/`**: Contains Gemini-specific configurations.
  - **`agents/`**: Specialized agents for the Gemini platform.
  - **`skills/`**: Skills available for Gemini agents.
  - **`steering/`**: Steering files for context, synchronized from `.claude/memory/`.
- **`.betteragents/sync/`**: Contains scripts for synchronizing memory between Claude and Gemini environments.

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

Project memory is maintained in `.claude/memory/` and synchronized to `.gemini/steering/`. The synchronization is handled by scripts in `.betteragents/sync/`.

- **`project-context.md`** - Current project state
- **`architecture-decisions.md`** - Recent decisions
- **`reusable-patterns.md`** - Identified patterns

## Usage in Gemini

When working in Gemini, the system will:
1. Load steering files automatically from `.gemini/steering/`.
2. Provide access to specialized agents from `.gemini/agents/`.
3. Inject relevant skills from `.gemini/skills/` based on context.
4. Maintain memory across sessions through the synchronization mechanism.

## Synchronization

Changes made in Gemini are synchronized back to `.claude/memory/` through the `.betteragents/sync/` system. This ensures that the core memory remains consistent across platforms.
