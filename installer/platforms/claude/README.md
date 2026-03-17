# Claude Code Platform Module

**Version:** 3.7.0  
**Platform:** Claude Code IDE  
**Module Type:** BetterAgents Platform Integration

---

## Overview

This module provides Claude Code IDE integration for the BetterAgents multi-agent orchestration system. It includes:

- **AgentX Orchestrator** - Main routing and coordination system
- **12 Specialized Agents** - Expert agents for different domains
- **76+ Slash Commands** - Skills library for specialized tasks
- **7 Protocols** - Mandatory workflows and safety checks
- **Memory System** - Persistent cross-session memory with dashboard
- **Hook Scripts** - Automated memory updates and safety checks

---

## Installation

### Prerequisites

**Required:**
- `jq` - JSON processor for memory scripts
  - Linux: `sudo apt install jq`
  - macOS: `brew install jq`
  - Windows: Download from https://stedolan.github.io/jq/

**Optional:**
- `git` - Version control
- `docker` - For centralized dashboard
- `node` - For local dashboard server
- Claude Code IDE - https://claude.ai/claude-code

### Quick Install

From the installer root directory:

```bash
bash install.sh --platform=claude --target=/path/to/project
```

### Interactive Install

```bash
bash install.sh --interactive
```

### Manual Install

```bash
cd installer
bash platforms/claude/install.sh /path/to/project
```

---

## Directory Structure

After installation, your project will have:

```
project/
├── CLAUDE.md                      # AgentX orchestrator
├── .claudecode.json               # Safety configuration
├── .claude/
│   ├── .version                   # Installation version
│   ├── agents/                    # 12 specialized agents
│   │   ├── architect.md
│   │   ├── coder.md
│   │   ├── critic.md
│   │   ├── security.md
│   │   ├── tester.md
│   │   ├── ux-designer.md
│   │   ├── writer.md
│   │   ├── teacher.md
│   │   ├── product-manager.md
│   │   ├── devops.md
│   │   ├── data-scientist.md
│   │   └── researcher.md
│   ├── commands/                  # 76+ slash commands (skills)
│   ├── protocols/                 # 7 mandatory protocols
│   ├── memory/                    # Memory system
│   │   ├── MEMORY.md             # Main memory file
│   │   ├── active-context.json   # Current project state
│   │   ├── decision-log.json     # Architecture decisions
│   │   ├── progress.json         # Task tracking
│   │   ├── patterns.json         # Reusable patterns
│   │   ├── dashboard.html        # Interactive dashboard
│   │   └── ...                   # Other memory files
│   ├── scripts/                   # Hook scripts
│   │   ├── update-memory.sh
│   │   ├── add-decision.sh
│   │   ├── add-task.sh
│   │   ├── start-dashboard.sh
│   │   └── ...
│   ├── settings.local.json        # Hook configuration
│   ├── cache/                     # Temporary cache
│   └── backups/                   # Automatic backups
└── templates/
    └── memory/                    # Docker volume templates
```

---

## Memory System

### Case A/B/C Logic

The installer uses intelligent memory initialization:

- **Case A: New Project**
  - No existing project indicators
  - Installs clean memory templates
  - Initializes empty memory files

- **Case B: Existing BetterAgents**
  - Has `.claude/.version` file
  - **Preserves all existing memory files**
  - Only updates dashboard.html
  - Adds missing memory files if needed

- **Case C: Existing Non-BetterAgents Project**
  - Has git/package.json/etc but no `.claude/.version`
  - Installs clean memory templates
  - Does not overwrite existing files

### Memory Files

| File | Purpose | Preserved in Case B |
|------|---------|---------------------|
| `MEMORY.md` | Main memory file (auto-generated) | ✓ |
| `active-context.json` | Current project state | ✓ |
| `decision-log.json` | Architecture decisions | ✓ |
| `progress.json` | Task tracking | ✓ |
| `patterns.json` | Reusable patterns | ✓ |
| `dashboard.html` | Interactive dashboard | ✗ (always updated) |
| `session-last.md` | Last session summary | ✓ |
| `llm-usage.json` | Token usage tracking | ✓ |

---

## Central Container

### What is it?

The central container is a shared Docker container that serves dashboards for all BetterAgents projects on your machine. Instead of running separate dashboard servers for each project, all projects register with a single central container.

### Location

- **Registry:** `~/.betteragents/projects.json`
- **Docker Compose:** `~/.betteragents/docker-compose.yml`
- **Container Name:** `betteragents-central-dashboard`

### How it works

1. During installation, the project registers itself in `~/.betteragents/projects.json`
2. The installer generates/updates `~/.betteragents/docker-compose.yml`
3. The central container mounts all registered projects
4. Access dashboards at: `http://localhost:3000/projects/{project-name}/`

### Manual Registration

If automatic registration fails:

```bash
bash .claude/scripts/generate-central-compose.sh
```

---

## Hooks Configuration

Hooks are configured in `.claude/settings.local.json`:

```json
{
  "hooks": {
    "on_user_prompt": "bash .claude/scripts/on-user-prompt.sh",
    "on_session_stop": "bash .claude/scripts/on-session-stop.sh",
    "on_file_change": "bash .claude/scripts/on-file-change.sh"
  }
}
```

### Available Hooks

| Hook | Trigger | Purpose |
|------|---------|---------|
| `on_user_prompt` | User sends message | Load memory context |
| `on_session_stop` | Session ends | Update memory, generate summary |
| `on_file_change` | File edited | Track changes, update metrics |
| `on_bash_change` | Bash script edited | Syntax validation |

---

## Usage

### Starting Claude Code

```bash
# Open project in Claude Code
claude /path/to/project
```

### Viewing Dashboard

```bash
# Start dashboard (Docker or Node.js)
bash .claude/scripts/start-dashboard.sh

# Quick dashboard (text-based)
bash .claude/scripts/quick-dashboard.sh
```

### Memory Commands

```bash
# Add architecture decision
bash .claude/scripts/add-decision.sh "DEC-ID" "Title" "Context" "Decision"

# Add task
bash .claude/scripts/add-task.sh "TASK-ID" "Description" "in-progress"

# Update project context
bash .claude/scripts/update-context.sh --version "1.0.0" --focus "New feature"

# Generate memory summary
bash .claude/scripts/update-memory.sh
```

### Validation

```bash
# Validate installation
bash installer/platforms/claude/validate.sh /path/to/project
```

---

## Agents

### Available Agents

| Agent | Domain | Use Cases |
|-------|--------|-----------|
| **architect** | System design, API, scalability | Architecture decisions, system audits |
| **coder** | Implementation, debugging | Code implementation, bug fixes |
| **critic** | Risk assessment, validation | Critical analysis, Tenth Man Rule |
| **security** | OWASP, auth, cryptography | Security audits, vulnerability analysis |
| **tester** | TDD, unit/integration/E2E | Testing strategy, test implementation |
| **ux-designer** | UI/UX, accessibility | Interface design, user experience |
| **writer** | Documentation, technical writing | README, API docs, guides |
| **teacher** | Concepts, learning paths | Explanations, tutorials |
| **product-manager** | Strategy, roadmaps | Product planning, prioritization |
| **devops** | CI/CD, Docker, Kubernetes | Infrastructure, deployment |
| **data-scientist** | ML, statistics, data analysis | Data analysis, machine learning |
| **researcher** | Tech research, comparisons | Technology evaluation, research |

### Invoking Agents

In Claude Code, AgentX automatically routes tasks to specialized agents based on complexity and domain.

---

## Protocols

### Mandatory Protocols

1. **Protocol 0:** Session Start - Read memory at session start
2. **Protocol 0.5:** Triviality Gate - Score complexity before execution
3. **Protocol 1:** Memory Context Injection - Inject project context
4. **Protocol 2:** Skill Injection - Auto-inject relevant skills
5. **Protocol 3:** Critic Gate - Mandatory review for architecture decisions
6. **Protocol 4:** Feedback Loop - Check completeness, prevent loops
7. **Protocol 5b:** Memory Self-Assessment - Autonomous memory updates

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

**Problem:** Memory files not created
```bash
# Check Case detection
ls -la .claude/.version

# Reinstall with clean templates
rm -rf .claude
bash installer/platforms/claude/install.sh .
```

**Problem:** Hooks not triggering
```bash
# Check settings.local.json
cat .claude/settings.local.json

# Verify script permissions
chmod +x .claude/scripts/*.sh
```

### Dashboard Issues

**Problem:** Dashboard not accessible
```bash
# Check Docker container
docker ps | grep betteragents

# Restart dashboard
bash .claude/scripts/start-dashboard.sh

# Check central registry
cat ~/.betteragents/projects.json
```

**Problem:** Project not in central container
```bash
# Regenerate central compose
bash .claude/scripts/generate-central-compose.sh

# Restart container
cd ~/.betteragents
docker-compose down
docker-compose up -d
```

### Memory Issues

**Problem:** Memory not updating
```bash
# Check jq installation
jq --version

# Manually update memory
bash .claude/scripts/update-memory.sh

# Check memory stats
bash .claude/scripts/memory-stats.sh
```

---

## Uninstallation

### Safe Uninstall

```bash
bash installer/platforms/claude/uninstall.sh /path/to/project
```

This will:
1. Backup all memory files to `.claude/backups/`
2. Unregister from central container
3. Move `.claude/` to `.claude-removed-{timestamp}`
4. Move `CLAUDE.md` to `CLAUDE.md.removed.{timestamp}`
5. Move `.claudecode.json` to `.claudecode.json.removed.{timestamp}`
6. Clean `.gitignore` entries

### Manual Cleanup

```bash
# Remove all BetterAgents files
rm -rf .claude
rm CLAUDE.md
rm .claudecode.json
rm -rf templates/memory

# Clean .gitignore
# Remove lines containing .claude/
```

---

## Upgrading

### From Previous Version

```bash
# Backup current installation
cp -r .claude .claude.backup

# Run installer (Case B will preserve memory)
bash installer/platforms/claude/install.sh .

# Validate upgrade
bash installer/platforms/claude/validate.sh .
```

---

## Configuration

### .claudecode.json

Safety configuration for Claude Code:

```json
{
  "safety": {
    "confirmBeforeExecute": true,
    "maxTokensPerSession": 100000,
    "allowedCommands": ["bash", "node", "python3"]
  }
}
```

### settings.local.json

Hook configuration:

```json
{
  "hooks": {
    "on_user_prompt": "bash .claude/scripts/on-user-prompt.sh",
    "on_session_stop": "bash .claude/scripts/on-session-stop.sh"
  }
}
```

---

## Support

### Documentation

- **Main Guide:** `CLAUDE.md` in project root
- **Agent Specs:** `.claude/agents/*.md`
- **Protocol Specs:** `.claude/protocols/*.md`
- **Memory System:** `.claude/memory/MEMORY.md`

### Issues

Report issues at: https://github.com/jemavidev/BetterAgentX/issues

---

## License

MIT License - See LICENSE file in repository root

---

**Last Updated:** 2026-03-02  
**Module Version:** 3.7.0  
**Installer Version:** 1.0.0
