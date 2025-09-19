# BetterAgents — Modular Installer v3.8.0

Multi-platform installer for the BetterAgents multi-agent system.
Supports: **Claude Code** | **Kiro IDE** | (extensible to Cursor, Windsurf, etc.)

## Quick Start

```bash
# Claude Code (default)
bash instalador/install.sh --platform=claude --target=/path/to/project

# Kiro IDE
bash instalador/install.sh --platform=kiro --target=/path/to/project

# Both platforms
bash instalador/install.sh --platform=both --target=/path/to/project

# Interactive platform selection
bash instalador/install.sh --interactive
```

## Architecture

```
instalador/
├── install.sh              ← Multi-platform dispatcher
├── lib/                    ← Shared libraries (core, registry, config, ui)
├── config/
│   ├── platforms.json      ← Platform registry
│   └── betteragents.json   ← Version config
├── scripts/
│   └── detect-platform.sh  ← Auto-detect installed platforms
└── platforms/
    ├── claude/             ← Claude Code module
    ├── kiro/               ← Kiro IDE module
    └── _template/          ← Template for new platforms
```

## What Gets Installed

### Claude Code Platform (`--platform=claude`)

| Component | Location | Description |
|-----------|----------|-------------|
| AgentX orchestrator | `CLAUDE.md` | Main AI routing instructions |
| Safety config | `.claudecode.json` | Efficiency & safety rules |
| Agent definitions | `.claude/agents/` | 12 specialist agents |
| Slash commands | `.claude/commands/` | 78 skill commands |
| Protocols | `.claude/protocols/` | 7 safety gates |
| Hook scripts | `.claude/scripts/` | Automation & verification |
| Memory system | `.claude/memory/` | JSON data + dashboard |
| Runtime mode | `.claude/.betteragents-mode` | `installed` (locks system files) |

### Kiro IDE Platform (`--platform=kiro`)

| Component | Location | Description |
|-----------|----------|-------------|
| AgentX orchestrator | `AGENTS.md` | Universal orchestrator |
| Steering files | `.kiro/steering/` | 5 context files for Kiro |
| Memory bridge | `.kiro/scripts/update-memory.sh` | Bridges Kiro to memory system |
| Runtime mode | `.betteragents-mode` | `installed` (in project root) |

## Dashboard (Claude Platform)

```bash
# Start dashboard (Node.js)
bash .claude/scripts/start-dashboard.sh
# → http://localhost:3000

# Or with Docker
docker --context default compose -f ~/.betteragents/docker-compose.yml up -d
```

## Maintenance

```bash
# Reset session data (keep decisions/tasks/patterns)
bash reset-memory.sh

# Full reset (clear everything)
bash reset-memory.sh --full

# Update existing installation (skips existing memory)
bash instalador/install.sh --platform=claude --target=/path/to/project

# Unregister from central dashboard
bash instalador/install.sh --unregister --target=/path/to/project

# Validate Kiro installation
bash instalador/platforms/kiro/validate.sh /path/to/project

# Uninstall Kiro
bash instalador/platforms/kiro/uninstall.sh /path/to/project
```

## Adding a New Platform

1. Copy `platforms/_template/` → `platforms/<name>/`
2. Edit `platforms/<name>/manifest.json`
3. Implement `platforms/<name>/install.sh`
4. Register in `config/platforms.json`

## Requirements

| Tool | Required | Purpose |
|------|----------|---------|
| jq | Yes | Memory scripts, platform registry |
| Claude Code | Claude only | AI agent runtime |
| Kiro IDE | Kiro only | AI agent runtime |
| Node.js | Optional | Local dashboard server |
| Docker | Optional | Containerized dashboard |
| git | Optional | Version tracking |
