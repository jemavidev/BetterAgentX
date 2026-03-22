# 🚀 Getting Started with BetterAgents

Welcome to BetterAgents! This guide will help you get up and running quickly with **AgentX**, the intelligent orchestrator, and the **Memory System**.

## 🎯 What is BetterAgents?

BetterAgents is an intelligent multi-agent system for Claude Code featuring:

- **AgentX** - Smart orchestrator that routes queries to specialized agents
- **12 Specialized Agents** - Experts in architecture, coding, testing, security, and more
- **Memory System** - Automatic documentation of decisions, progress, and patterns
- **Interactive Dashboard** - Visual interface to manage project memory
- **Skills Integration** - Enhanced capabilities through skills.sh

## 📋 Prerequisites

Before you begin, ensure you have:
- **Claude Code** installed ([Installation Guide](../installation/linux.md))
- **Node.js** 16.x or higher
- **Git** for cloning the repository
- **Bash** shell (Linux/macOS) or WSL (Windows)
- **jq** (required for memory system — `sudo apt install jq`)

## ⚡ Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX
```

### 2. Run Installation

```bash
bash scripts/init.sh
```

The installer will:
- ✅ Verify system requirements
- ✅ Set up configuration
- ✅ Create memory system
- ✅ Install recommended skills (optional)
- ✅ Verify installation

### 3. Open Claude Code

```bash
claude .
```

### 4. Try AgentX (Your First Interaction)

AgentX is the intelligent orchestrator. All queries go through AgentX by default:

```
I need to design an authentication system for my API
```

AgentX will:
1. Analyze your request
2. Determine it's an architecture task
3. Route to the Architect agent
4. Provide a refined prompt

You should see:
```markdown
---
🧠 AgentX
🔀 Routing to: Architect
---

## 📋 Analysis
[AgentX's analysis of your request]

## 🎯 Routing Decision
[Why Architect was chosen]

## 📝 Refined Prompt for Architect
[Detailed instructions for Architect]
```

Then Architect will respond with the system design.

### 5. Direct Agent Access (Optional)

You can also go directly to any agent:

```
/architect Hello! Can you explain how you work?
```

### 6. Explore the Memory System

Check your project memory:

```bash
# Open the interactive dashboard (Node.js)
bash .claude/scripts/start-dashboard.sh

# Or Docker
docker compose up -d

# Or view memory files directly
cat .claude/memory/MEMORY.md
cat .claude/memory/session-last.md
```

## 🎯 Your First Workflow with AgentX

Let's build a simple REST API with AgentX orchestrating the workflow:

### Step 1: Start with AgentX (No prefix needed!)

```
I need to create a REST API for user authentication with JWT
```

AgentX will analyze and route to Product Manager for requirements.

### Step 2: Let AgentX Guide You

AgentX will automatically:
- Route to **Product Manager** for user stories
- Route to **Architect** for system design
- Suggest **Critic** for design review
- Route to **Security** for security analysis
- Route to **Coder** for implementation
- Route to **Tester** for test cases
- Route to **Writer** for documentation

### Step 3: AgentX Documents Everything

AgentX automatically updates memory using mandatory helper scripts:
- **Decisions** → `decision-log.json` (via `add-decision.sh`)
- **Progress** → `progress.json` (via `add-task.sh`)
- **Patterns** → `patterns.json` (via `add-pattern.sh`)
- **Context** → `active-context.json`

You'll see:
```markdown
---
🧠 AgentX
💾 Memory Update: decision-log.json — DEC-01: JWT over session tokens
---
```

### Step 4: Review in Dashboard

```bash
# Node.js (recommended)
bash .claude/scripts/start-dashboard.sh

# Docker
docker compose up -d
```

See all decisions, progress, and patterns in a visual interface at http://localhost:3000!

## 📚 Understanding the System

### AgentX - The Orchestrator

**AgentX** is the brain of BetterAgents. It:
- Analyzes your requests using 4-D Methodology
- Routes to the best agent for the task
- Validates completeness before execution
- Orchestrates multi-agent workflows
- Manages memory automatically

**Learn more:** [AgentX Documentation](../agentx/README.md)

### 12 Specialized Agents

AgentX can route to these agents:

#### Core Agents (7)
- **Architect** - System design and architecture
- **Coder** - Code implementation
- **Critic** - Critical analysis (Tenth Man Rule)
- **Tester** - Testing and QA
- **Writer** - Technical documentation
- **Researcher** - Research and analysis
- **Teacher** - Educational explanations

#### Specialized Agents (5)
- **DevOps** - Infrastructure and deployment
- **Security** - Security analysis
- **UX Designer** - UI/UX design
- **Data Scientist** - Data analysis
- **Product Manager** - Product management

**Learn more:** [Agent Directory](../agents/README.md)

### Memory System

The memory system automatically documents:
- **Decisions** - Technical choices and trade-offs
- **Progress** - Tasks completed and in progress
- **Patterns** - Reusable solutions and learnings
- **Context** - Current project state

**Learn more:** [Memory System Documentation](../memory/README.md)

## 🔧 Configuration

### AgentX Configuration

AgentX is configured via `CLAUDE.md` in your project root. Key settings:

- **Triviality Gate** — Score 0–5 determines if a task is dispatched to an agent or handled directly
- **Plan Mode** — Triggered automatically for complex/multi-file tasks
- **Memory Writes** — Mandatory triggers defined in Section 5 of CLAUDE.md

### Memory System Configuration

The memory system is configured via hooks in `.claude/settings.local.json`:

| Hook | Trigger | Action |
|------|---------|--------|
| `UserPromptSubmit` | Each message | Inject memory debt reminders |
| `PostToolUse (Write/Edit)` | File written | Update active context timestamp |
| `Stop` | Session ends | Write session summary, check memory debt |

### Main Configuration

The version and metadata is at `config/betteragents.json`:

```json
{
  "name": "BetterAgents",
  "version": "3.7.0"
}
```

### Dashboard Port Configuration

Each project gets its own port via `.env`:
```bash
BETTERAGENTS_PROJECT=my-project-name
BETTERAGENTS_PORT=3000   # change if running multiple projects simultaneously
```

## 📖 Memory System

BetterAgents includes an intelligent memory system managed by AgentX:

### Memory Files

Located in `.claude/memory/`:
- **MEMORY.md** — Auto-loaded context summary (always in Claude's context)
- **session-last.md** — Last session summary (read on every startup)
- **active-context.json** — Current project state
- **decision-log.json** — Architecture decisions (ADR format)
- **progress.json** — Task tracking
- **patterns.json** — Reusable patterns and solutions
- **token-accounting.json** — Token usage breakdown
- **metrics-analytics.json** — Efficiency and quality metrics
- **alerts-registry.json** — Live alerts and rules

### Automatic Documentation

AgentX automatically detects and documents:
- Technical decisions → `decision-log.json` (via `bash .claude/scripts/add-decision.sh`)
- Task completions → `progress.json` (via `bash .claude/scripts/add-task.sh`)
- Useful patterns → `patterns.json` (via `bash .claude/scripts/add-pattern.sh`)
- Context changes → `active-context.json`

### Interactive Dashboard

View and manage memory visually:

```bash
# Node.js (recommended, no Docker required)
bash .claude/scripts/start-dashboard.sh

# Docker
docker compose up -d
```

**Dashboard features:**
- 6 TABs: Decisions, Tasks, Patterns, Context, Tokens, Metrics
- Live alerts system (4 severity levels)
- Auto-refresh every 30 seconds
- Multi-project support

**Learn more:** [Memory System Guide](../memory/README.md)

## 🎓 Learning More

### Core Documentation
- **[AgentX Guide](../agentx/README.md)** - Learn about the intelligent orchestrator
- **[Memory System](../memory/README.md)** - Understand automatic documentation
- **[Agent Directory](../agents/README.md)** - Complete agent reference

### Guides
- [Skills Management](./skills-management.md) - Managing and updating skills
- [Workflows](./workflows.md) - Collaborative workflows
- [Advanced Usage](./advanced-usage.md) - Advanced features

### Examples
- [Basic Workflow](../../examples/basic-workflow/) - Complete multi-agent API development walkthrough

## 🆘 Troubleshooting

### AgentX Not Routing

1. Check `CLAUDE.md` exists in your project root (AgentX orchestrator)
2. Verify agent files exist in `.claude/agents/`
3. Check `config/betteragents.json` for project configuration
4. Try explicit routing: `AgentX (via /memory or natural conversation) test`

### Agent Not Responding

1. Check Claude Code is running
2. Verify agent files exist in `.claude/agents/`
3. Check syntax with `/architect test`
4. Review logs if enabled

### Memory Not Updating

1. Check memory files exist in `.claude/memory/`
2. Run a memory script manually: `bash .claude/scripts/add-task.sh TASK-01 "Test task" pending coder`
3. Verify hooks are configured: `cat .claude/settings.local.json`
4. Tell AgentX explicitly: "Document this in memory"

### Dashboard Not Loading

1. Check `dashboard.html` exists in `.claude/memory/`
2. Try Node.js: `bash .claude/scripts/start-dashboard.sh`
3. Try Docker: `docker compose up -d`
4. Check browser console for errors at http://localhost:3000

### Skills Not Working

1. Verify skills are installed: `npx skills list`
2. Update skills: `./scripts/update-skills.sh`
3. Check configuration in `config/`

### Installation Issues

1. Verify Node.js version: `node --version`
2. Check Claude Code installation: `claude --version`
3. Review installation logs
4. See [Troubleshooting Guide](../installation/linux.md#troubleshooting)

## 💡 Tips

1. **Let AgentX Route** - Don't use `@agent` unless you know exactly which agent you need
2. **Trust the Memory System** - AgentX documents important decisions automatically
3. **Use the Dashboard** - Visual interface makes memory management easy
4. **Be Specific** - More context = better routing and results
5. **Review Memory Weekly** - Keep context files up to date
6. **Update Regularly** - Run `./scripts/check-updates.sh` weekly
7. **Explore Skills** - Install recommended skills for better results
8. **Read Agent Docs** - Each agent has detailed documentation
9. **Use Multi-Agent Workflows** - Let AgentX orchestrate complex tasks
10. **Contribute to Memory** - Agents can suggest memory updates

## 🎯 Next Steps

1. ✅ Complete installation
2. ✅ Try AgentX with a simple query
3. ✅ Explore the memory dashboard
4. ✅ Install recommended skills
5. ✅ Try a multi-agent workflow
6. ✅ Read AgentX documentation
7. ✅ Explore agent capabilities
8. ✅ Join the community

## 📞 Getting Help

- 📖 [Documentation](../README.md)
- 🐛 [Report Issues](https://github.com/jemavidev/BetterAgentX/issues)
- 💬 [Discussions](https://github.com/jemavidev/BetterAgentX/discussions)
- 📧 [Contact](mailto:your-email@example.com)

---

**Ready to build something amazing with AgentX? Let's go! 🚀**
