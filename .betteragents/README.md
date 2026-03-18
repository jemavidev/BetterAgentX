# BetterAgents Multi-Platform System

**Version:** 4.0.0
**Status:** Production Ready
**Platforms:** Claude Code + Kiro (multi-platform modular installer)

---

## Overview

This directory contains the multi-platform adaptation system for BetterAgents. It allows the core system in `.claude/` to work natively across different AI IDEs without modification.

## Architecture Principle

> `.claude/` is the **source of truth**. All other platforms read from it and generate their own files.

```
.claude/              ← Source of truth (100% functional, never modified)
    ↓
.betteragents/        ← Adapter system (translators, sync, bridge)
    ↓
.kiro/                ← Kiro-specific files (generated)
.windsurf/            ← Windsurf-specific files (future)
.cursor/              ← Cursor-specific files (future)
```

---

## Directory Structure

```
.betteragents/
├── README.md                    # This file
├── CORE-REFERENCE.md            # Complete system documentation
├── sync/                        # Synchronization tools
│   ├── detect-platform.sh       # Platform detection
│   ├── memory-bridge.js         # Memory access layer
│   └── auto-sync.sh             # Auto-sync script
├── translators/                 # Platform translators
│   ├── claude-to-kiro.js        # Claude → Kiro
│   └── kiro-to-claude.js        # Kiro → Claude (future)
└── docs/                        # Additional documentation
```

---

## Quick Start

### 1. Detect Current Platform

```bash
bash .betteragents/sync/detect-platform.sh
# Output: claude-code | kiro | windsurf | cursor | unknown
```

### 2. Sync to Current Platform

```bash
bash .betteragents/sync/auto-sync.sh
```

### 3. Watch for Changes (Auto-sync)

```bash
bash .betteragents/sync/auto-sync.sh --watch
```

---

## Platform Support

### ✅ Claude Code (Source)
- **Status:** Fully functional (v3.7.0)
- **Location:** `.claude/`
- **Orchestrator:** `CLAUDE.md`
- **Agents:** 12 in `.claude/agents/`
- **Skills:** 79 in `.claude/commands/`
- **Memory:** `.claude/memory/*.json`

### ✅ Kiro (Adapter)
- **Status:** Phase 1 complete
- **Location:** `.kiro/`
- **Orchestrator:** `KIRO.md`
- **Agents:** 12 in `.kiro/agents/`
- **Skills:** 79 in `.kiro/skills/`
- **Memory:** Steering files in `.kiro/steering/`

### 🚧 Windsurf (Planned)
- **Status:** Not implemented
- **Location:** `.windsurf/` (future)

### 🚧 Cursor (Planned)
- **Status:** Not implemented
- **Location:** `.cursor/` (future)

---

## Translation System

### Claude → Kiro

```bash
# Translate everything
node .betteragents/translators/claude-to-kiro.js all

# Translate specific components
node .betteragents/translators/claude-to-kiro.js agents
node .betteragents/translators/claude-to-kiro.js skills
node .betteragents/translators/claude-to-kiro.js memory
node .betteragents/translators/claude-to-kiro.js orchestrator
```

### Translation Mapping

| Claude | Kiro | Notes |
|--------|------|-------|
| `.claude/agents/*.md` | `.kiro/agents/*.md` | Custom agent format |
| `.claude/commands/*.md` | `.kiro/skills/*.md` | Skill format |
| `.claude/memory/*.json` | `.kiro/steering/*.md` | Steering files |
| `CLAUDE.md` | `KIRO.md` | Simplified orchestrator |

---

## Memory Bridge

Access memory from any platform:

```bash
# Get summary
node .betteragents/sync/memory-bridge.js summary

# Get recent decisions
node .betteragents/sync/memory-bridge.js decisions 5

# Get tasks by status
node .betteragents/sync/memory-bridge.js tasks completed

# Get patterns by category
node .betteragents/sync/memory-bridge.js patterns architectural

# Read specific file
node .betteragents/sync/memory-bridge.js read active-context.json
```

---

## How It Works

### 1. Platform Detection

The system detects which IDE is running:
- Checks environment variables
- Looks for platform-specific directories
- Reads configuration files

### 2. Translation

When syncing:
1. Reads source files from `.claude/`
2. Parses frontmatter and content
3. Transforms to target platform format
4. Writes to platform-specific directory

### 3. Memory Synchronization

Memory flows in both directions:
- **Read:** All platforms read from `.claude/memory/`
- **Write:** Changes sync back through memory bridge

---

## Development

### Adding a New Platform

1. Create translator: `.betteragents/translators/claude-to-<platform>.js`
2. Update `detect-platform.sh` with detection logic
3. Update `auto-sync.sh` with sync case
4. Test translation with sample files
5. Document in this README

### Testing Translations

```bash
# Test platform detection
bash .betteragents/sync/detect-platform.sh

# Test memory bridge
node .betteragents/sync/memory-bridge.js summary

# Test translation
node .betteragents/translators/claude-to-kiro.js agents
```

---

## Troubleshooting

### Platform Not Detected

```bash
# Check detection logic
bash .betteragents/sync/detect-platform.sh

# Manually set platform
export KIRO_SESSION_ID="manual"
bash .betteragents/sync/auto-sync.sh
```

### Translation Errors

```bash
# Check source files exist
ls -la .claude/agents/
ls -la .claude/commands/

# Check Node.js version
node --version  # Should be v14+

# Run with verbose output
node .betteragents/translators/claude-to-kiro.js all
```

### Memory Bridge Issues

```bash
# Check memory files exist
ls -la .claude/memory/

# Test individual commands
node .betteragents/sync/memory-bridge.js read MEMORY.md
```

---

## Implementation Status

### ✅ Phase 1: Fundamentals (Complete)
- [x] Core reference documentation
- [x] Platform detection script
- [x] Memory bridge
- [x] Directory structure

### ✅ Phase 2: Claude → Kiro Translator (Complete)
- [x] Agent translation (12 agents)
- [x] Skill translation (79 skills)
- [x] Memory to steering translation
- [x] Orchestrator adaptation

### 🚧 Phase 3: Synchronization (In Progress)
- [ ] Bi-directional sync
- [ ] Change detection
- [ ] Conflict resolution
- [ ] Auto-sync on file changes

### 🚧 Phase 4: Kiro → Claude (Planned)
- [ ] Reverse translator
- [ ] Memory write-back
- [ ] Decision sync
- [ ] Pattern sync

### 🚧 Phase 5: Extensibility (Planned)
- [ ] Plugin system
- [ ] Custom translators
- [ ] Platform registry
- [ ] CLI tool

---

## References

- **Core System:** `.betteragents/CORE-REFERENCE.md`
- **Blueprint:** [docs/architecture/multi-platform-blueprint.md](../docs/architecture/multi-platform-blueprint.md)
- **Status:** [docs/project/status-multi-platform.md](../docs/project/status-multi-platform.md)
- **Tasks:** [docs/project/tasks-implementation.md](../docs/project/tasks-implementation.md)
- **Main README:** `README.md`
- **Platform Guides:**
  - [Claude Code](../docs/platforms/claude.md)
  - [Kiro](../docs/platforms/kiro.md)

---

**Last Updated:** 2026-03-02  
**Maintainer:** BetterAgents Team
