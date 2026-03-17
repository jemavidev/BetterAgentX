# 🎯 BetterAgents

**Intelligent multi-agent orchestration system for Claude Code — 12 specialized agents + 1 orchestrator with automatic routing and persistent memory.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)](https://github.com/jemavidev/BetterAgentX/releases)
[![Platform](https://img.shields.io/badge/platform-Multi--Platform-orange.svg)](https://github.com/jemavidev/BetterAgentX)
[![Claude Code](https://img.shields.io/badge/Claude_Code-✓-green.svg)](https://claude.ai/claude-code)
[![Kiro](https://img.shields.io/badge/Kiro-✓-green.svg)](https://kiro.ai)

> Transform your development workflow with specialized agents that work together intelligently.

---

## What is BetterAgents?

BetterAgents installs **AgentX** — an intelligent orchestrator that sits on top of AI IDEs and automatically routes your requests to the right specialist:

- You ask a complex question
- **AgentX** analyzes it using the 4-D methodology (Deconstruct → Diagnose → Develop → Dispatch)
- AgentX routes it to the right specialist (or multiple agents for complex tasks)
- You get expert-level answers with full context

All of this happens automatically. No manual agent selection needed.

### 🌍 Multi-Platform Support

BetterAgents now works natively across multiple AI IDEs:

- ✅ **Claude Code** - Full support (source platform)
- ✅ **Kiro** - Full support with automatic sync
- 🚧 **Windsurf** - Coming soon
- 🚧 **Cursor** - Coming soon

The system automatically detects your IDE and adapts accordingly. See [Multi-Platform Guide](.betteragents/README.md) for details.

For platform-specific documentation:
- [Claude Code Guide](docs/platforms/claude.md)
- [Kiro Guide](docs/platforms/kiro.md)

---

## Agent Ecosystem (12 Specialists)

| Agent | Slash Command | Specialty |
|-------|--------------|-----------|
| 🏗️ Architect | `/architect` | System design, patterns, scalability |
| 💻 Coder | `/coder` | Clean code, debugging, refactoring |
| 🎭 Critic | `/critic` | Risk analysis, Tenth Man Rule |
| 🔒 Security | `/security` | OWASP, vulnerability assessment |
| 🧪 Tester | `/tester` | TDD, test strategy, QA |
| 🎨 UX Designer | `/ux-designer` | UI/UX, accessibility (WCAG) |
| ✍️ Writer | `/writer` | Docs, README, API docs |
| 👨‍🏫 Teacher | `/teacher` | Concept explanation, learning paths |
| 📋 Product Manager | `/product-manager` | Strategy, user stories, RICE |
| 🚀 DevOps | `/devops` | CI/CD, Docker, Kubernetes |
| 📊 Data Scientist | `/data-scientist` | ML, statistics, visualization |
| 🔍 Researcher | `/researcher` | Tech research, comparisons |

---

## Requirements

### For Claude Code
- **Claude Code** — [Install here](https://claude.ai/claude-code)
- **jq** — Required for memory scripts: `sudo apt install jq` (Linux) / `brew install jq` (macOS)
- **bash** — Required for hook scripts
- **git** — Recommended

### For Kiro
- **Kiro** — [Install here](https://kiro.ai)
- **Node.js** — v14+ for translation scripts
- **bash** — Required for sync scripts

---

## Installation

### Option A — Self-Contained Installer (Recommended)

No need to clone the repository first. Just copy the `installer/` folder into your project:

```bash
# 1. Copy the installer to your project
cp -r installer/ /path/to/your-project/

# 2. Run from your project root
cd /path/to/your-project
bash installer/install.sh

# 3. Open your project in Claude Code
claude .
```

### Option B — Repo-Based Installer

```bash
# 1. Clone BetterAgents
git clone https://github.com/jemavidev/BetterAgentX.git

# 2. Run from your project
cd /path/to/your-project
bash /path/to/BetterAgentX/scripts/init.sh

# 3. Open your project in Claude Code
claude .
```

That's it. AgentX is now active.

---

## Usage

### Automatic Routing (Recommended)
Just ask normally — AgentX decides which agent handles it:

```
"Design a REST API with authentication for 100k users"
→ AgentX routes to: Architect + Security agents

"Write tests for this authentication module"
→ AgentX routes to: Tester agent

"What could go wrong with this microservices design?"
→ AgentX routes to: Critic agent
```

### Slash Commands (Direct)
Invoke specific agents directly:

```
/architect   — System design challenge
/coder       — Implement or review code
/critic      — Challenge this proposal
/security    — Audit this for vulnerabilities
/tester      — Write tests for this
/ux-designer — Design accessible UI
/writer      — Write documentation
/teacher     — Explain this concept
/memory      — View project memory
/metrics     — View usage statistics
```

### Utility Commands
```
/memory    — View current project context, decisions, patterns
/metrics   — View token usage and project stats
```

---

## Memory System

BetterAgents maintains **persistent memory** across sessions in `.claude/memory/`:

| File | Contents |
|------|----------|
| `MEMORY.md` | Auto-loaded summary (always in context) |
| `session-last.md` | Last session summary — read on every session start |
| `workflow-prefs.md` | Stable user preferences — edit manually |
| `active-context.json` | Current project state |
| `decision-log.json` | Architecture decisions (ADR format) |
| `progress.json` | Task tracking |
| `patterns.json` | Reusable patterns learned |
| `llm-usage.json` | Session activity log — `activity.files` (array of `{path, added, removed}` objects), `activity.prompts` (array of user inputs), `activity.lastCommit` |
| `token-accounting.json` | Token usage breakdown |
| `metrics-analytics.json` | Efficiency & quality metrics |
| `alerts-registry.json` | Live alerts and rules |
| `memory-stats.json` | Memory file size breakdown |
| `project-metrics.json` | Project size and complexity |
| `historical-data.json` | Token usage trends over time |
| `dashboard.html` | Interactive visualization |

AgentX automatically updates memory when it detects:
- Technical decisions (via `add-decision.sh`)
- Completed tasks (via `add-task.sh`)
- Reusable patterns (via `add-pattern.sh`)
- Context changes

### Memory Dashboard

**Option A — Node.js (no Docker required):**
```bash
bash .claude/scripts/start-dashboard.sh
# Opens at http://localhost:3000
```

**Option B — Docker:**
```bash
docker compose up -d
# Opens at http://localhost:<PORT>  (see .env)
```

### Multi-Project Dashboard

Running BetterAgents across multiple projects? A single central container serves all of them:

```bash
# Each project registers automatically on install.
# To unregister a project:
bash installer/install.sh --unregister

# View all projects at: http://localhost:3000
```

---

## Hooks (Automation)

BetterAgents configures Claude Code hooks in `.claude/settings.local.json`:

| Hook | Trigger | Action |
|------|---------|--------|
| `UserPromptSubmit` | Each user message | Inject memory debt reminder if pending |
| `PreToolUse (EnterPlanMode)` | Plan mode entered | Log plan mode trigger to metrics |
| `PostToolUse (Write/Edit)` | File written/edited | Update active context timestamp |
| `PostToolUse (Write/Edit)` | File written/edited | Syntax verification (py/ts/js/json/sh) |
| `PostToolUse (Bash)` | Bash command runs | Rebuild dashboard on memory file writes |
| `Stop` | Session ends | Write session summary, token stats, debt check |

---

## Project Structure

```
YourProject/
├── CLAUDE.md                    # AgentX orchestrator (installed by installer)
├── .env                         # Container name + port config
├── docker-compose.yml           # Optional single-project container
└── .claude/
    ├── agents/                  # 12 agent definitions
    │   ├── architect.md
    │   ├── coder.md
    │   └── ... (12 total)
    ├── commands/                # 77 slash commands / skills
    │   ├── architect.md         # /architect
    │   ├── memory.md            # /memory
    │   └── ...
    ├── memory/                  # Persistent memory
    │   ├── MEMORY.md            # Auto-loaded summary
    │   ├── session-last.md      # Last session — read on startup
    │   ├── workflow-prefs.md    # Stable user preferences
    │   ├── active-context.json
    │   ├── decision-log.json
    │   ├── progress.json
    │   ├── patterns.json
    │   ├── token-accounting.json
    │   ├── metrics-analytics.json
    │   ├── alerts-registry.json
    │   ├── memory-stats.json
    │   ├── project-metrics.json
    │   ├── historical-data.json
    │   └── dashboard.html
    ├── scripts/                 # Hook automation
    │   ├── on-session-stop.sh
    │   ├── on-file-change.sh
    │   ├── add-task.sh          # Write to progress.json
    │   ├── add-decision.sh      # Write to decision-log.json
    │   ├── add-pattern.sh       # Write to patterns.json
    │   ├── start-dashboard.sh   # Launch Node.js dashboard
    │   └── ...
    └── settings.local.json      # Claude Code hooks config
```

## Maintenance

```bash
# Reset session data (keep decisions/tasks/patterns)
bash reset-memory.sh

# Full reset (clear everything)
bash reset-memory.sh --full

# Unregister from central dashboard
bash installer/install.sh --unregister
# or directly:
bash installer/.claude/scripts/generate-central-compose.sh "<project-name>" "" --unregister
docker compose -f ~/.betteragents/docker-compose.yml down && \
docker compose -f ~/.betteragents/docker-compose.yml up -d
```

---

## Updating BetterAgents

```bash
# In the BetterAgents repository
git pull origin main

# In your project
bash scripts/update.sh
```

The update script uses MD5 hash comparison to only update changed files, preserving your memory data.

---

## Documentation

### Guides
- [Getting Started](docs/guides/getting-started.md)
- [Agent Guide](docs/agents/README.md)
- [Memory System](docs/memory/README.md)
- [Installation (Linux)](docs/installation/linux.md)

### Platform-Specific
- [Claude Code](docs/platforms/claude.md)
- [Kiro](docs/platforms/kiro.md)

### Architecture & Planning
- [Multi-Platform Blueprint](docs/architecture/multi-platform-blueprint.md)
- [Multi-Platform Summary](docs/architecture/multi-platform-summary.md)
- [Migration Plan](docs/migration/agents-md-migration-plan.md)

### Project Status
- [Phase 1 Complete](docs/project/phase-1-complete.md)
- [Phase 3 Complete](docs/project/phase-3-complete.md)
- [Current Status](docs/project/status-multi-platform.md)
- [Implementation Tasks](docs/project/tasks-implementation.md)

---

## Memory Dashboard

```bash
# Node.js (recommended, no Docker required)
bash .claude/scripts/start-dashboard.sh

# Docker
docker compose up -d
```

The dashboard shows decisions, patterns, task progress, token usage, and live alerts with interactive charts.

The SAFETY tab Session Activity includes:
- Files modified per session with per-file `+added / -removed` line counts and heat-map background colors (green < 10 lines, yellow 10–50, red > 50, purple > 200 or heavy rewrites)
- Token distribution bar showing input vs output percentage with totals
- Last git commit message per session
- Decisions and tasks correlated by date from `decision-log.json` and `progress.json`
- Clickable session cards that open a modal showing the actual user prompts typed during the session

---

## License

MIT License — see [license](license) file.

---

**Version:** 4.0.0 (Claude Code Edition)
**Platform:** Claude Code
