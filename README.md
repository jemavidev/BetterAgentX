# 🎯 BetterAgentX

Intelligent multi-agent system for software development with automatic memory management and centralized orchestration powered by AgentX.

## ✨ Key Features

- **🤖 12 Specialized Agents** - Each expert in their domain
- **🎯 AgentX Dispatcher** - Intelligent orchestrator that routes tasks to the right agent
- **💾 Automatic Memory System** - Documents decisions, progress, and patterns automatically
- **📊 Visual Dashboard** - Web interface to navigate and manage memory
- **🔄 Intelligent Routing** - Automatic detection of the appropriate agent for each task
- **🎨 Skills Integration** - Compatible with skills.sh for specialized knowledge

## 🚀 Quick Start

### Option A: Standalone Installation

```bash
# Clone the repository
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX

# Verify system
./scripts/verify-system.sh

# Install (if needed)
./scripts/install.sh
```

### Option B: Integrate into Your Project (Recommended)

```bash
# 1. Clone BetterAgentX into your project
cd your-project
git clone https://github.com/jemavidev/BetterAgentX.git

# 2. Initialize integration
./BetterAgentX/scripts/init-betteragentx.sh

# 3. Verify
./BetterAgentX/scripts/verify-betteragentx.sh

# 4. Start using
kiro .
```

**See:** [Integration Guide](INTEGRATION.md) | [Quick Integration](QUICKSTART-INTEGRATION.md)

### Basic Usage

```bash
# Interact with AgentX (main entry point)
@agentx "I need to design an authentication system"

# Or directly with a specific agent
@architect "Design a microservices architecture"
@coder "Implement JWT authentication in Node.js"
@security "Audit this code for vulnerabilities"
```

### Open Memory Dashboard

```bash
# Open visual dashboard
./.kiro/memory/open-dashboard.sh

# Or manually
xdg-open .kiro/memory/dashboard.html
```

## 🤖 Available Agents

### AgentX - Dispatcher (Orchestrator)
**The central brain** that analyzes your request and routes it to the appropriate agent.

- Automatic intent detection
- Intelligent routing
- Automatic memory management
- Multi-agent workflow orchestration

### Specialized Agents

| Agent | Specialty | Use |
|-------|-----------|-----|
| **Architect** | System design, architecture | High-level design, technical decisions |
| **Coder** | Implementation, clean code | Write code, refactoring, debugging |
| **Critic** | Critical analysis, risks | Review decisions, identify problems |
| **Security** | Security, OWASP | Audits, secure coding |
| **Tester** | Testing, QA | Test strategy, coverage |
| **UX-Designer** | UI/UX, accessibility | Interface design |
| **Writer** | Technical documentation | API docs, tutorials, README |
| **Teacher** | Concept explanation | Learn technologies, tutorials |
| **Product-Manager** | Product, user stories | Planning, prioritization |
| **DevOps** | CI/CD, infrastructure | Deployment, monitoring |
| **Data-Scientist** | Data analysis, ML | Data analysis, models |
| **Researcher** | Technical research | Compare technologies, best practices |

## 🔧 Integration with Your Projects

BetterAgentX can be integrated into any project using **symbolic links** (no file duplication):

### Why Integration?

- ✅ Use BetterAgentX in existing projects
- ✅ No file duplication
- ✅ Easy updates with `git pull`
- ✅ Project-specific memory and configuration
- ✅ Multiple projects can share one BetterAgentX installation

### Quick Integration

```bash
# In your project directory
git clone https://github.com/jemavidev/BetterAgentX.git
./BetterAgentX/scripts/init-betteragentx.sh
```

This creates:
- Symbolic links to agents, AgentX, and skills
- Project-specific memory system
- Local configuration files

### What Gets Created

```
your-project/
├── BetterAgentX/           # Source (shared)
├── .kiro/
│   ├── steering/           # → symlinks to BetterAgentX
│   ├── memory/             # Your project's memory (local)
│   └── settings/           # Your project's config (local)
└── .agents/
    └── skills/             # → symlink to BetterAgentX
```

**Learn more:** [Integration Guide](INTEGRATION.md) | [Quick Start](QUICKSTART-INTEGRATION.md)

## 💾 Memory System

BetterAgents maintains persistent memory of your project:

### Memory Files

- **`active-context.md`** - Current project context
- **`decision-log.md`** - Technical decisions (ADR)
- **`progress.md`** - Task tracking
- **`patterns.md`** - Reusable patterns

### Automatic Management

AgentX automatically documents:
- ✅ Important technical decisions
- ✅ Completed tasks
- ✅ Identified patterns
- ✅ Context changes

### Visual Dashboard

Navigate and manage memory visually:

```bash
./.kiro/memory/open-dashboard.sh
```

Features:
- 🔍 Real-time search
- ✏️ Full CRUD
- 📊 Visual statistics
- 📅 Timeline view
- 💾 Markdown synchronization

## 📖 Documentation

- [Getting Started Guide](docs/guides/getting-started.md)
- [Agent System](docs/agents/README.md)
- [Memory System](docs/guides/memory-system.md)
- [Memory Dashboard](docs/guides/memory-dashboard.md)
- [Workflows](docs/guides/workflows.md)
- [Skills Management](docs/guides/skills-management.md)

## 💡 Examples

### Example 1: Feature Development

```bash
# 1. AgentX analyzes and routes
@agentx "I need to add JWT authentication to my API"

# AgentX detects you need:
# - Architect for design
# - Security for review
# - Coder for implementation
# - Tester for tests

# 2. AgentX automatically documents in memory
# 3. You can review in the dashboard
```

### Example 2: Code Review

```bash
@agentx "Review this code for security issues"

# AgentX routes to Security
# Security audits and suggests improvements
# AgentX documents findings in memory
```

See more examples in [examples/](examples/)

## 🔧 Configuration

### Agent Configuration

Edit `.kiro/steering/agents/` to customize agent behavior.

### System Configuration

```json
// config/betteragents.json
{
  "version": "1.0.0",
  "agents": {
    "enabled": true,
    "default_agent": "agentx"
  },
  "memory": {
    "auto_save": true,
    "sync_interval": 300
  }
}
```

## 🤝 Contributing

Contributions are welcome! See [contributing.md](contributing.md)

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Changelog

See [changelog.md](changelog.md) for change history.

## 📄 License

This project is licensed under the MIT License - see [license](license) for details.

## 🙏 Acknowledgments

- Inspired by multi-agent systems and agile methodologies
- Built for developers by developers
- [skills.sh](https://skills.sh) community for specialized skills

## 📞 Support

- 📖 [Documentation](docs/)
- 🐛 [Report Bug](https://github.com/jemavidev/BetterAgentX/issues)
- 💡 [Request Feature](https://github.com/jemavidev/BetterAgentX/issues)
- 💬 [Discussions](https://github.com/jemavidev/BetterAgentX/discussions)

---

**Made with ❤️ by the developer community**
