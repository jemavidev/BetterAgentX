# Kiro IDE Platform Module

**Version:** 3.7.0  
**Platform:** Kiro IDE  
**Module Type:** BetterAgents Platform Integration

---

## Overview

This module provides Kiro IDE integration for the BetterAgents multi-agent orchestration system. It includes:

- **AgentX Orchestrator** - Universal AGENTS.md routing system
- **Steering Files** - Context and memory files (Kiro's memory system)
- **Skills Library** - Specialized skills for different tasks
- **Custom Agents** - Optional custom agent definitions
- **Memory Bridge** - Integration with Claude memory system
- **Scripts** - Utility scripts including memory bridge wrapper

---

## Installation

### Prerequisites

**Required:**
- `jq` - JSON processor for memory bridge
  - Linux: `sudo apt install jq`
  - macOS: `brew install jq`
  - Windows: Download from https://stedolan.github.io/jq/

**Optional:**
- `git` - Version control
- `node` - For development tools
- Kiro IDE - https://kiro.ai
- Claude platform - For memory bridge functionality

### Quick Install

From the installer root directory:

```bash
bash install.sh --platform=kiro --target=/path/to/project
```

### Interactive Install

```bash
bash install.sh --interactive
```

### Manual Install

```bash
cd installer
bash platforms/kiro/install.sh /path/to/project
```

### Multi-Platform Install

Install both Claude and Kiro for full functionality:

```bash
bash install.sh --platform=both --target=/path/to/project
```

---

## Directory Structure

After installation, your project will have:

```
project/
├── AGENTS.md                      # Universal AgentX orchestrator
├── .kiro/
│   ├── .version                   # Installation version
│   ├── steering/                  # Steering files (Kiro's memory)
│   │   ├── agentx-identity.md
│   │   ├── project-context.md
│   │   ├── architecture-decisions.md
│   │   ├── reusable-patterns.md
│   │   └── memory-usage-guide.md
│   ├── skills/                    # Skills library (optional)
│   ├── agents/                    # Custom agents (optional)
│   ├── scripts/                   # Utility scripts
│   │   └── update-memory.sh      # Memory bridge wrapper
│   └── settings/                  # Configuration (optional)
└── .claude/                       # If Claude platform installed
    └── memory/                    # Shared memory system
```

---

## Memory System

### Kiro's Approach: Steering Files

Unlike Claude's JSON-based memory system, Kiro uses **steering files** - markdown documents that provide context and guidance:

| File | Purpose | Auto-Generated |
|------|---------|----------------|
| `agentx-identity.md` | AgentX identity and protocols | ✗ |
| `project-context.md` | Current project state | ✓ |
| `architecture-decisions.md` | Architecture decisions | ✓ |
| `reusable-patterns.md` | Reusable patterns | ✓ |
| `memory-usage-guide.md` | Memory system guide | ✗ |

### Case A/B/C Logic

The installer uses intelligent initialization:

- **Case A: New Project**
  - No existing project indicators
  - Installs clean steering templates
  - Initializes empty steering files

- **Case B: Existing BetterAgents**
  - Has `.kiro/.version` file
  - **Preserves all existing steering files**
  - Only adds missing files

- **Case C: Existing Non-BetterAgents Project**
  - Has git/package.json/etc but no `.kiro/.version`
  - Installs clean steering templates
  - Does not overwrite existing files

---

## Memory Bridge

### What is it?

The memory bridge connects Kiro's steering files with Claude's JSON-based memory system. This allows Kiro to leverage Claude's memory infrastructure while maintaining its own steering file approach.

### Requirements

- Claude platform must be installed (`.claude/memory/` and `.claude/scripts/`)
- `jq` must be installed for JSON processing

### Usage

```bash
# Update Claude memory from Kiro
bash .kiro/scripts/update-memory.sh

# This wrapper calls Claude memory scripts:
# - .claude/scripts/add-decision.sh
# - .claude/scripts/add-task.sh
# - .claude/scripts/update-context.sh
```

### How it works

1. Kiro maintains steering files in `.kiro/steering/`
2. Memory bridge script reads steering files
3. Extracts structured data (decisions, tasks, context)
4. Calls Claude memory scripts to update JSON files
5. Claude dashboard displays combined data

### Without Claude Platform

If Claude platform is not installed:
- Steering files still work for Kiro context
- Memory bridge is unavailable
- No dashboard visualization
- Manual memory management only

---

## Usage

### Starting Kiro IDE

```bash
# Open project in Kiro IDE
kiro /path/to/project
```

### Steering Files

Steering files are automatically loaded by Kiro IDE and provide context to the AI:

```bash
# View steering files
ls -la .kiro/steering/

# Edit steering files
vim .kiro/steering/project-context.md
```

### Memory Bridge (with Claude)

```bash
# Update Claude memory from Kiro
bash .kiro/scripts/update-memory.sh

# View dashboard (requires Claude platform)
bash .claude/scripts/start-dashboard.sh
```

### Validation

```bash
# Validate installation
bash installer/platforms/kiro/validate.sh /path/to/project
```

---

## Skills

### Skills Library

Skills are specialized markdown files that provide domain-specific knowledge:

```
.kiro/skills/
├── architect.md
├── coder.md
├── researcher.md
├── triviality-detector.md
└── ...
```

### Using Skills

Skills are automatically available in Kiro IDE through the skills system. Reference them in your prompts or let the AI auto-select based on context.

---

## Custom Agents

### What are Custom Agents?

Custom agents are Kiro-specific agent definitions that extend the base agent ecosystem:

```
.kiro/agents/
├── custom-agent-1.md
├── custom-agent-2.md
└── ...
```

### Creating Custom Agents

1. Create a markdown file in `.kiro/agents/`
2. Define agent identity, domain, and capabilities
3. Kiro IDE will automatically load the agent

---

## AGENTS.md Orchestrator

### Universal Format

The `AGENTS.md` file is a universal orchestrator that works across multiple AI IDEs:

- **Claude Code:** Uses `Task(subagent_type="agent-name", ...)`
- **Kiro:** Uses custom agents from `.kiro/agents/`
- **Others:** Platform-specific mechanisms

### Platform Detection

AGENTS.md automatically detects the platform and adapts:

```markdown
### Kiro
- Use custom agents from `.kiro/agents/`
- Steering files in `.kiro/steering/` provide context
- Skills available in `.kiro/skills/`
```

---

## Coexistence with Claude

### Multi-Platform Setup

You can install both Claude and Kiro platforms in the same project:

```bash
# Install both platforms
bash install.sh --platform=both --target=.
```

This creates:
- `.claude/` - Claude platform files
- `.kiro/` - Kiro platform files
- `AGENTS.md` - Shared universal orchestrator
- Memory bridge connects both systems

### Benefits

- Use Claude's dashboard for visualization
- Use Kiro's steering files for context
- Shared memory system via bridge
- Switch between IDEs seamlessly

---

## Troubleshooting

### Installation Issues

**Problem:** `jq: command not found`
```bash
# Linux
sudo apt install jq

# macOS
brew install jq
```

**Problem:** Steering files not created
```bash
# Check Case detection
ls -la .kiro/.version

# Reinstall with clean templates
rm -rf .kiro
bash installer/platforms/kiro/install.sh .
```

### Memory Bridge Issues

**Problem:** Memory bridge not working
```bash
# Check Claude platform installed
ls -la .claude/memory/
ls -la .claude/scripts/

# Install Claude platform
bash installer/platforms/claude/install.sh .

# Check jq installation
jq --version
```

**Problem:** update-memory.sh not executable
```bash
# Make script executable
chmod +x .kiro/scripts/update-memory.sh
```

### Steering File Issues

**Problem:** Steering files not loading
```bash
# Check steering directory
ls -la .kiro/steering/

# Verify file format (must be .md)
file .kiro/steering/*.md

# Check file permissions
chmod 644 .kiro/steering/*.md
```

---

## Uninstallation

### Safe Uninstall

```bash
bash installer/platforms/kiro/uninstall.sh /path/to/project
```

This will:
1. Backup all steering files to `.kiro-backup/`
2. Move `.kiro/` to `.kiro-removed-{timestamp}`
3. Move `AGENTS.md` to `AGENTS.md.removed.{timestamp}` (if Claude not installed)
4. Clean `.gitignore` entries

### Manual Cleanup

```bash
# Remove all Kiro files
rm -rf .kiro

# Remove AGENTS.md (if not used by Claude)
rm AGENTS.md

# Clean .gitignore
# Remove lines containing .kiro/
```

---

## Upgrading

### From Previous Version

```bash
# Backup current installation
cp -r .kiro .kiro.backup

# Run installer (Case B will preserve steering files)
bash installer/platforms/kiro/install.sh .

# Validate upgrade
bash installer/platforms/kiro/validate.sh .
```

---

## Configuration

### Steering Files

Steering files are markdown documents that provide context:

**agentx-identity.md** - AgentX identity and protocols
**project-context.md** - Current project state
**architecture-decisions.md** - Architecture decisions
**reusable-patterns.md** - Reusable patterns

Edit these files to customize behavior and provide project-specific context.

---

## Comparison: Kiro vs Claude

| Feature | Kiro | Claude |
|---------|------|--------|
| **Memory Format** | Steering files (.md) | JSON files |
| **Dashboard** | Via Claude bridge | Native dashboard.html |
| **Agents** | Custom agents | 12 predefined agents |
| **Skills** | Skills library | Slash commands |
| **Hooks** | Manual | Automated via settings.local.json |
| **Memory Updates** | Manual or bridge | Automated via hooks |
| **Complexity** | Simpler, lightweight | Feature-rich, automated |

### When to Use Kiro

- Prefer markdown over JSON
- Want simpler, lightweight setup
- Need custom agent definitions
- Working in Kiro IDE

### When to Use Claude

- Want automated memory updates
- Need interactive dashboard
- Prefer structured JSON data
- Working in Claude Code IDE

### When to Use Both

- Want best of both worlds
- Need cross-IDE compatibility
- Want dashboard + steering files
- Working in multiple IDEs

---

## Support

### Documentation

- **Main Guide:** `AGENTS.md` in project root
- **Steering Files:** `.kiro/steering/*.md`
- **Skills:** `.kiro/skills/*.md`
- **Custom Agents:** `.kiro/agents/*.md`

### Issues

Report issues at: https://github.com/jemavidev/BetterAgentX/issues

---

## License

MIT License - See LICENSE file in repository root

---

**Last Updated:** 2026-03-02  
**Module Version:** 3.7.0  
**Installer Version:** 1.0.0

