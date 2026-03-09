# 🤝 Contributing Guide - BetterAgentX

Thank you for your interest in contributing to BetterAgentX! This document will guide you through the process.

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How to Contribute](#how-to-contribute)
3. [Reporting Bugs](#reporting-bugs)
4. [Suggesting Improvements](#suggesting-improvements)
5. [Pull Requests](#pull-requests)
6. [Style Guide](#style-guide)
7. [Project Structure](#project-structure)

---

## 📜 Code of Conduct

This project follows a simple code of conduct:

- Be respectful and professional
- Accept constructive criticism
- Focus on what is best for the project
- Help other contributors

---

## 🚀 How to Contribute

### 1. Fork the Repository

```bash
# Fork from GitHub
# Then clone your fork
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX
```

### 2. Create a Branch

```bash
# Create a descriptive branch
git checkout -b feature/new-feature
# or
git checkout -b fix/bug-fix
# or
git checkout -b docs/improve-documentation
```

### 3. Make Your Changes

- Follow the [Style Guide](#style-guide)
- Test your changes
- Document what you did

### 4. Commit

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new feature X"
# or
git commit -m "fix: fix bug in agent Y"
# or
git commit -m "docs: update README with Z"
```

### 5. Push and Pull Request

```bash
# Push to your fork
git push origin feature/new-feature

# Then open a Pull Request on GitHub
```

---

## 🐛 Reporting Bugs

### Before Reporting

1. Verify it is not a configuration issue
2. Search existing issues
3. Test with the latest version

### How to Report

Open an issue with:

**Title:** Brief description of the bug

**Description:**
```markdown
## Bug Description
[Clear description of the problem]

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS: Ubuntu 22.04
- Claude Code: v1.2.3
- Node.js: v20.0.0
- BetterAgents: v3.0.0

## Logs/Screenshots
[If applicable]
```

---

## 💡 Suggesting Improvements

### Welcome Ideas

- New specialized agents
- Improvements to existing agents
- New features
- Documentation improvements
- Performance optimizations

### Suggestion Format

```markdown
## Suggestion Title

### Problem It Solves
[What problem or need it addresses]

### Proposed Solution
[How it would work]

### Alternatives Considered
[Other options you thought about]

### Benefits
- Benefit 1
- Benefit 2

### Potential Drawbacks
- Drawback 1
- Drawback 2
```

---

## 🔀 Pull Requests

### Pre-PR Checklist

- [ ] The code works correctly
- [ ] You followed the style guide
- [ ] You updated the documentation if necessary
- [ ] You added/updated tests if applicable
- [ ] The commit message is descriptive
- [ ] There are no conflicts with main

### Review Process

1. A maintainer will review your PR
2. There may be comments or change requests
3. Make the requested changes
4. Once approved, it will be merged

### Types of Contributions

#### New Agents

If you want to add a new agent:

1. Create the file at `.claude/steering/agents/new-agent.md`
2. Follow the structure of existing agents
3. Include:
   - Identity section
   - Role description
   - Expertise areas
   - Guidelines
   - Output formats
   - Recommended skills
4. Update `betteragents.json`
5. Update `README.md`

#### Improvements to Existing Agents

1. Identify which agent to improve
2. Make incremental changes
3. Document why the improvement is needed
4. Test that the agent still works correctly

#### Documentation

1. Identify what to document
2. Use clear and concise Markdown
3. Include examples where possible
4. Check spelling and grammar

#### Bugs

1. Identify the root cause
2. Implement the simplest solution
3. Explain why your solution works
4. Add tests if possible

---

## 📝 Style Guide

### Markdown Files

```markdown
# Main Title (H1)

## Section (H2)

### Subsection (H3)

- Use lists for multiple items
- Keep lines short (80-100 characters)
- Use code blocks with specified language

\`\`\`bash
# Code example
echo "Hello"
\`\`\`

**Bold** for important emphasis
*Italic* for soft emphasis
`inline code` for commands or code
```

### Agent Structure

```markdown
# 🎯 Agent: Agent Name

## Identity
[Identification format]

## Role
[Role description]

## Expertise
[Expertise areas]

## Core Principles
[Fundamental principles]

## Guidelines
[Behavioral guidelines]

## Output Format
[Response formats]

## Available Skills
[Recommended skills]

## Remember
[Key points]
```

### Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: fix a bug
docs: documentation changes
style: formatting, semicolons, etc
refactor: code refactoring
test: add tests
chore: maintenance tasks
```

Examples:
```bash
git commit -m "feat: add ML Engineer agent"
git commit -m "fix: fix response format in Architect"
git commit -m "docs: update installation guide"
git commit -m "refactor: simplify memory system"
```

---

## 🏗️ Project Structure

```
BetterAgentX/
├── .agents/
│   └── skills/              # Shared skills
│       └── ui-ux-pro-max/
├── .claude/
│   └── steering/
│       ├── agents/          # 12 specialized agents
│       │   ├── architect.md
│       │   ├── coder.md
│       │   ├── critic.md
│       │   ├── data-scientist.md
│       │   ├── devops.md
│       │   ├── product-manager.md
│       │   ├── researcher.md
│       │   ├── security.md
│       │   ├── teacher.md
│       │   ├── tester.md
│       │   ├── ux-designer.md
│       │   └── writer.md
│       └── _common/         # Common configuration
│           ├── collaboration-rules.md
│           ├── identity-template.md
│           └── memory-contribution.md
├── config/
│   ├── betteragents.json    # Main configuration
│   └── agent-skills.json    # Recommended skills
├── docs/                    # Full documentation
├── scripts/
│   ├── init-betteragentx.sh      # Initialize integration
│   ├── verify-betteragentx.sh    # Verify integration
│   ├── install.sh                # System installation
│   └── verify-system.sh          # System verification
├── templates/
│   └── memory/              # Memory templates
├── .gitignore
├── CHANGELOG.md             # Change history
├── CONTRIBUTING.md          # This guide
├── INDEX.md                 # Documentation index
├── INTEGRATION.md           # Integration guide
├── QUICKSTART-INTEGRATION.md # Quick start
├── LICENSE                  # MIT License
└── README.md                # Main documentation
```

### Important Files

- **config/betteragents.json**: Main system configuration
- **config/agent-skills.json**: Recommended skills per agent
- **README.md**: Main documentation
- **INTEGRATION.md**: Full integration guide
- **QUICKSTART-INTEGRATION.md**: Quick start integration
- **INDEX.md**: Index of all documentation
- **CHANGELOG.md**: Version and change history
- **CLAUDE.md**: The central orchestrator (AgentX)
- **.claude/agents/**: The 12 specialized agents
- **.claude/commands/**: 76+ slash commands
- **scripts/**: Installation and integration scripts
- **templates/memory/**: Memory system templates

---

## 🧪 Testing

### Testing Agents

```bash
# Open Kiro
kiro .

# Test each agent
@architect Hello, are you working correctly?
@coder Hello, are you working correctly?
# ... etc
```

### Verify Structure

```bash
# Run verification script
./verify.sh

# Or manually
ls -1 .claude/steering/agents/*.md | wc -l  # Should be 12
ls -1 .claude/memory/*.md | wc -l           # Should be 5
```

---

## 📚 Resources

- [Kiro Documentation](https://kiro.ai/docs)
- [Skills.sh](https://skills.sh)
- [Markdown Guide](https://www.markdownguide.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## ❓ Questions

If you have questions:

1. Review the existing documentation
2. Search closed issues
3. Open an issue with your question
4. Join the discussions on GitHub

---

## 🎉 Recognition

All contributors will be recognized in README.md

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the project's MIT license.

---

**Thank you for contributing to BetterAgentX! 🚀**
