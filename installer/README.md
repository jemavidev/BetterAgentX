# BetterAgents — Installer

Self-contained installer for the BetterAgents multi-agent system.

## Quick Start

```bash
# 1. Copy this folder to your project
cp -r installer/ /path/to/your-project/

# 2. Run the installer from the project root
cd /path/to/your-project
bash installer/install.sh

# 3. Open Claude Code
claude .
```

## What Gets Installed

| Component | Location | Description |
|-----------|----------|-------------|
| AgentX orchestrator | `CLAUDE.md` | Main AI routing instructions |
| Safety config | `.claudecode.json` | Efficiency & safety rules |
| Agent definitions | `.claude/agents/` | 12 specialist agents |
| Slash commands | `.claude/commands/` | 76 skill commands |
| Protocols | `.claude/protocols/` | 7 safety gates |
| Hook scripts | `.claude/scripts/` | Automation & tracking |
| Memory system | `.claude/memory/` | JSON data + dashboard |
| Templates | `templates/memory/` | Required for Docker |
| Dashboard | `.claude/memory/dashboard.html` | Web UI |
| Docker files | `Dockerfile`, `docker-compose.yml` | Optional container |
| Environment | `.env` | Project name + port config |

## Dashboard

### Option A — Node.js (no Docker required)
```bash
bash .claude/scripts/start-dashboard.sh
# Opens at http://localhost:3000 (or next free port)
```

### Option B — Docker
```bash
docker compose up -d
# Opens at http://localhost:PORT  (see .env for port)
```

The container is named `betteragents-<project-name>` automatically.
Each project uses its own container and port (auto-assigned, no conflicts).

## Maintenance

### Reset session data (keep decisions/tasks/patterns)
```bash
bash reset-memory.sh
```

### Full reset (clear everything)
```bash
bash reset-memory.sh --full
```

### Re-run installer (update scripts, skip existing memory)
```bash
bash installer/install.sh
```

### Unregister from central dashboard
```bash
bash installer/install.sh --unregister
# or directly:
bash installer/.claude/scripts/generate-central-compose.sh "<project-name>" "" --unregister
docker compose -f ~/.betteragents/docker-compose.yml down && \
docker compose -f ~/.betteragents/docker-compose.yml up -d
```

## Multi-project Setup

Each project gets its own `.env` file:
```bash
BETTERAGENTS_PROJECT=my-project-name
BETTERAGENTS_PORT=3000   # change this if running multiple projects simultaneously
```

## Requirements

| Tool | Required | Purpose |
|------|----------|---------|
| Claude Code | Yes | AI agent runtime |
| jq | Recommended | Memory scripts (installer warns if missing) |
| Node.js | Optional | Local dashboard server |
| Docker | Optional | Containerized dashboard |
| git | Optional | Version tracking |
