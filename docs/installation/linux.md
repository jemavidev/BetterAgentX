# 🚀 Installation Guide - BetterAgents

**12-agent AI orchestration system for Claude Code**

**Platform:** Ubuntu/Debian (Linux .deb-based)
**Estimated time:** 10-15 minutes
**Level:** Beginner to Advanced

---

## 📋 Table of Contents

1. [System Requirements](#system-requirements)
2. [Quick Installation](#quick-installation)
3. [Step-by-Step Installation](#step-by-step-installation)
4. [Skills Installation](#skills-installation)
5. [Verification](#verification)
6. [Using the System](#using-the-system)
7. [Troubleshooting](#troubleshooting)
8. [Updating](#updating)

---

## 📦 System Requirements

### Operating System
- ✅ Ubuntu 20.04 LTS or higher
- ✅ Debian 11 or higher
- ✅ Linux Mint 20 or higher
- ✅ Pop!_OS 20.04 or higher

### Minimum Hardware
- CPU: 2 cores
- RAM: 4GB
- Disk: 1GB free

### Required Software
| Software | Minimum Version | Installation |
|----------|-----------------|-------------|
| **Claude Code** | Latest | [claude.ai/claude-code](https://claude.ai/claude-code) |
| **Node.js** | 18.x | Installed in this guide |
| **npm** | 9.x | Included with Node.js |
| **Git** | 2.x | Installed in this guide |

---

## ⚡ Quick Installation

For experienced users who already have Node.js 18+ and Claude Code installed:

**Option A — Self-contained installer (recommended):**
```bash
# 1. Copy installer to your project
cp -r installer/ /path/to/your-project/
cd /path/to/your-project

# 2. Run automatic installation
bash installer/install.sh

# 3. Open Claude Code
claude .
```

**Option B — Repository-based installer:**
```bash
# 1. Clone the repository
git clone https://github.com/jemavidev/BetterAgentX.git

# 2. Run automatic installation from your project
cd /path/to/your-project
bash /path/to/BetterAgentX/scripts/init.sh

# 3. Open Claude Code
claude .
```

**Done!** All 12 agents are available.

---

## 🔧 Step-by-Step Installation

### Step 1: Update the System

```bash
# Update package list
sudo apt update

# Update installed packages (optional but recommended)
sudo apt upgrade -y
```

---

### Step 2: Install Git

```bash
# Check if Git is installed
git --version

# If not installed:
sudo apt install git -y

# Verify installation
git --version
# Should show: git version 2.x.x
```

---

### Step 3: Install Node.js and npm

#### Option A: Installation with nvm (Recommended)

```bash
# 1. Download and install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# 2. Load nvm in the current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. Install Node.js 20 LTS
nvm install 20

# 4. Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

#### Option B: Installation from NodeSource

```bash
# 1. Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# 2. Install Node.js
sudo apt install -y nodejs

# 3. Verify installation
node --version
npm --version
```

---

### Step 4: Install Claude Code

#### Download Claude Code

1. Visit [claude.ai/claude-code](https://claude.ai/claude-code)
2. Download the Linux version (.deb)
3. Install the package:

```bash
# Navigate to downloads folder
cd ~/Downloads

# Install (replace X.X.X with downloaded version)
npm install -g @anthropic-ai/claude-code

# If dependency errors, run:
sudo apt install -f -y

# Verify installation
claude --version
```

#### Alternative: Terminal installation

```bash
# If Claude Code provides an installation script
npm install -g @anthropic-ai/claude-code # | bash

# Or using snap (if available)
# snap not available — use npm install above
```

---

### Step 5: Clone the Repository

```bash
# 1. Navigate to your projects folder
cd ~/Documents
mkdir -p GIT
cd GIT

# 2. Clone BetterAgents
git clone https://github.com/jemavidev/BetterAgentX.git

# 3. Enter the directory
cd BetterAgentX

# 4. Verify contents
ls -la
# You should see: .agents/, .claude/, README.md, etc.
```

---

### Step 6: Verify Structure

```bash
# Verify the 12 agents are present
ls -1 .claude/agents/

# You should see:
# architect.md
# coder.md
# critic.md
# data-scientist.md
# devops.md
# product-manager.md
# researcher.md
# security.md
# teacher.md
# tester.md
# ux-designer.md
# writer.md

# Count agents
ls -1 .claude/agents/ | wc -l
# Should show: 12
```

---

### Step 7: Verify Memory System

```bash
# Verify memory files
ls -la .claude/memory/

# You should see:
# MEMORY.md
# session-last.md
# active-context.json
# decision-log.json
# progress.json
# patterns.json
# token-accounting.json
# metrics-analytics.json
# alerts-registry.json
# dashboard.html
```

---

## 📚 Skills Installation

Skills are optional but significantly improve agent capabilities.

### Essential Skills (Recommended)

```bash
# Install the 5 most important skills
npx skills add wshobson/agents/architecture-patterns
npx skills add obra/superpowers/systematic-debugging
npx skills add vercel-labs/agent-skills/vercel-react-best-practices
npx skills add anthropics/skills/webapp-testing
npx skills add anthropics/skills/doc-coauthoring
```

### Full Skills Installation

To install all recommended skills (~60 skills):

```bash
# Run skills installation script
chmod +x install-skills.sh
./install-skills.sh
```

The script will ask you:
1. **Install all** - Recommended for full use
2. **Install by agent** - Selective
3. **Install essentials** - Only the 5 basics

### Verify Installed Skills

```bash
# List installed skills
npx skills list

# Search available skills
npx skills find

# View skill information
npx skills info wshobson/agents/architecture-patterns
```

---

## ✅ Verification

### Automatic Verification Script

```bash
# Create verification script
cat > verify.sh << 'EOF'
#!/bin/bash

echo "🔍 Verifying BetterAgents installation..."
echo ""

# Check Node.js
echo "=== Node.js ==="
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js is not installed"
fi

# Check npm
if command -v npm &> /dev/null; then
    echo "✅ npm: $(npm --version)"
else
    echo "❌ npm is not installed"
fi
echo ""

# Check Claude Code
echo "=== Claude Code ==="
if command -v claude &> /dev/null; then
    echo "✅ Claude Code: $(claude --version)"
else
    echo "❌ Claude Code is not installed"
fi
echo ""

# Check structure
echo "=== Project Structure ==="
if [ -d ".claude/steering/agents" ]; then
    AGENT_COUNT=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l)
    echo "✅ Agents installed: $AGENT_COUNT/12"

    if [ "$AGENT_COUNT" -eq 12 ]; then
        echo "✅ All agents are present"
    else
        echo "⚠️  Missing agents"
    fi
else
    echo "❌ Agents folder not found"
fi
echo ""

# Check memory
echo "=== Memory System ==="
if [ -d ".claude/memory" ]; then
    MEMORY_COUNT=$(ls -1 .claude/memory/*.md 2>/dev/null | wc -l)
    echo "✅ Memory files: $MEMORY_COUNT/5"
else
    echo "❌ Memory system not found"
fi
echo ""

# Check skills
echo "=== Skills ==="
if [ -d ".agents/skills" ]; then
    echo "✅ Skills folder present"
else
    echo "⚠️  Skills folder not found"
fi
echo ""

# Summary
echo "=== Summary ==="
if [ "$AGENT_COUNT" -eq 12 ] && command -v claude &> /dev/null && command -v node &> /dev/null; then
    echo "✅ Installation complete and successful!"
    echo ""
    echo "🚀 To get started, run:"
    echo "   claude ."
else
    echo "⚠️  Installation is incomplete"
    echo "   Check the errors above"
fi
EOF

chmod +x verify.sh
./verify.sh
```

### Manual Verification

```bash
# 1. Verify Node.js and npm
node --version && npm --version

# 2. Verify Claude Code
claude --version

# 3. Count agents
ls -1 .claude/agents/*.md | wc -l
# Should show: 12

# 4. Verify memory
ls -1 .claude/memory/*.md | wc -l
# Should show: 5

# 5. View project size
du -sh .
# Should show: ~850KB
```

---

## 🚀 Using the System

### Start Claude Code

```bash
# From the project directory
cd ~/Documents/GIT/BetterAgents
claude .
```

### Using the Agents

In the Claude Code chat, invoke an agent with `/`:

```
/architect Design an authentication system with JWT
```

Expected response:
```
---
🧠 AgentX/Architect
---

[Structured agent response...]
```

### The 12 Available Agents

| Command | Agent | Specialty |
|---------|-------|-----------|
| `/architect` | 🏗️ Architect | System design and architecture |
| `/coder` | 💻 Coder | Code implementation |
| `/critic` | 🎭 Critic | Critical analysis (Tenth Man Rule) |
| `/tester` | 🧪 Tester | Testing and QA |
| `/writer` | ✍️ Writer | Technical documentation |
| `/researcher` | 🔍 Researcher | Research and analysis |
| `/teacher` | 👨‍🏫 Teacher | Step-by-step explanations |
| `/devops` | 🚀 DevOps | Infrastructure and deployment |
| `/security` | 🔒 Security | Security and vulnerabilities |
| `/ux-designer` | 🎨 UX Designer | UI/UX design |
| `/data-scientist` | 📊 Data Scientist | Data analysis |
| `/product-manager` | 📋 Product Manager | Product management |

### Collaborative Workflow

```
1. /architect → Design the architecture
2. /critic → Review and find issues
3. /security → Analyze vulnerabilities
4. /coder → Implement the code
5. /tester → Define testing strategy
6. /writer → Document the solution
```

### Using the Memory System

```bash
# View current context
cat .claude/memory/MEMORY.md

# Add task
bash .claude/scripts/add-task.sh TASK-01 "My task" in_progress coder

# Add decision
bash .claude/scripts/add-decision.sh DEC-01 "Use JWT" "Stateless auth" architect

# Add pattern
bash .claude/scripts/add-pattern.sh "my-pattern" architecture "Description" architect

# Open dashboard
bash .claude/scripts/start-dashboard.sh
```

---

## 🔧 Troubleshooting

### Problem: "claude: command not found"

**Solution:**
```bash
# Check if Claude Code is installed
which claude

# If not in PATH, add manually
echo 'export PATH="$PATH:/opt/claude/bin"' >> ~/.bashrc
source ~/.bashrc

# Or reinstall Claude Code
sudo dpkg -i ~/Downloads/claude-*.deb
```

---

### Problem: "node: command not found"

**Solution:**
```bash
# Reinstall Node.js with nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install 20
```

---

### Problem: "Agents not found"

**Solution:**
```bash
# Verify you are in the correct directory
pwd
# Should show: /home/your-user/Documents/GIT/BetterAgents

# Verify structure
ls -la .claude/agents/

# If folder is empty, the repository was not cloned correctly
# Re-clone:
cd ..
rm -rf BetterAgents
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX
```

---

### Problem: "npx: command not found"

**Solution:**
```bash
# npx comes with npm, verify npm
npm --version

# If npm is installed but npx doesn't work
npm install -g npx

# Or update npm
npm install -g npm@latest
```

---

### Problem: Permission denied

**Solution:**
```bash
# If you have npm permission issues
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Reinstall global packages if necessary
npm install -g npx
```

---

### Problem: Skills won't install

**Solution:**
```bash
# Check internet connection
ping -c 3 google.com

# Clear npm cache
npm cache clean --force

# Try installing specific skill with verbose
npx skills add wshobson/agents/architecture-patterns --verbose

# If it persists, check Node.js version
node --version
# Must be 18.x or higher
```

---

### Problem: Claude Code won't open the project

**Solution:**
```bash
# Verify you are in the correct directory
pwd

# Try opening with absolute path
claude ~/Documents/GIT/BetterAgents

# Check Claude Code logs
claude --help

# Reinstall Claude Code if necessary
sudo apt remove claude-code
sudo dpkg -i ~/Downloads/claude-*.deb
```

---

## 🔄 Updating

### Update BetterAgents

```bash
# Navigate to directory
cd ~/Documents/GIT/BetterAgents

# Save local changes (if any)
git stash

# Update from GitHub
git pull origin main

# Restore local changes
git stash pop

# Verify update
cat betteragents.json | grep version
```

### Update Skills (Recommended)

BetterAgents includes a dedicated script to keep skills up to date:

```bash
# Run update script
./update-skills.sh
```

The script:
1. ✅ Checks installed skills
2. ✅ Detects available updates
3. ✅ Updates all skills automatically
4. ✅ Shows change summary

#### Manual Skills Update

```bash
# Check for available updates
npx skills check

# Update all skills
npx skills update

# Update specific skill
npx skills update wshobson/agents/architecture-patterns

# View installed skills
npx skills list
```

#### Recommended Frequency

- **Weekly:** For active projects
- **Monthly:** For maintenance projects
- **Before starting a new project:** Always

#### Automate Updates (Optional)

You can create a cron job to update automatically:

```bash
# Edit crontab
crontab -e

# Add line to update every Monday at 9 AM
0 9 * * 1 cd ~/Documents/GIT/BetterAgents && ./update-skills.sh -y >> ~/betteragents-update.log 2>&1
```

### Update Node.js

```bash
# With nvm
nvm install 20
nvm use 20

# Verify version
node --version
```

### Update Claude Code

```bash
# Download new version from claude.ai/claude-code
# Then install:
sudo dpkg -i ~/Downloads/claude-new-version.deb
```

---

## 📊 Useful Commands

### System Information

```bash
# View BetterAgents version
cat betteragents.json | grep version

# View project size
du -sh .

# Count files
find . -type f | wc -l

# View full structure
tree -L 3 -a
```

### Skills Management

```bash
# List installed skills
npx skills list

# Search skills
npx skills find architecture

# View skill info
npx skills info wshobson/agents/architecture-patterns

# Check for updates
npx skills check

# Update all skills
npx skills update

# Update specific skill
npx skills update wshobson/agents/architecture-patterns

# Uninstall skill
npx skills remove wshobson/agents/architecture-patterns

# Install new skill
npx skills add new/skill
```

### Update Script

```bash
# Update skills automatically
./update-skills.sh

# The script:
# - Checks installed skills
# - Detects available updates
# - Updates all skills
# - Shows summary
```

### Maintenance

```bash
# Clear npm cache
npm cache clean --force

# Verify integrity
./verify.sh

# Backup memory system
cp -r .claude/memory .claude/memory.backup

# Restore memory
cp -r .claude/memory.backup .claude/memory
```

### Multi-Project Dashboard Management

When BetterAgents is running across multiple projects, a single central container serves them all.

**Register a project:**
```bash
bash installer/.claude/scripts/generate-central-compose.sh \
  "<project-name>" "<absolute-path>/.claude/memory"
docker compose -f ~/.betteragents/docker-compose.yml down && \
docker compose -f ~/.betteragents/docker-compose.yml up -d
```

**Unregister / remove a project:**
```bash
bash installer/.claude/scripts/generate-central-compose.sh \
  "<project-name>" "" --unregister
docker compose -f ~/.betteragents/docker-compose.yml down && \
docker compose -f ~/.betteragents/docker-compose.yml up -d
# Or from the project itself:
bash installer/install.sh --unregister
```

All active projects are visible at `http://localhost:3000` using the dashboard project selector.

---

## 🎯 Next Steps

After successful installation:

1. **Explore the agents**
   ```
   /teacher Explain how the agents work
   ```

2. **Set up your first project**
   ```
   nano .claude/memory/active-context.md
   ```

3. **Test a complete workflow**
   ```
   /architect Design a simple system
   /critic Review the design
   /coder Implement a basic function
   ```

4. **Install additional skills**
   ```bash
   npx skills find
   npx skills add [skill-you-need]
   ```

5. **Read the full documentation**
   ```bash
   cat README.md
   cat .claude/memory/README.md
   ```

---

## 📚 Additional Resources

- **Claude Code documentation:** [claude.ai/claude-code/docs](https://claude.ai/claude-code/docs)
- **Available skills:** [skills.sh](https://skills.sh)
- **GitHub repository:** [github.com/jemavidev/BetterAgentX](https://github.com/jemavidev/BetterAgentX)
- **Report issues:** [github.com/jemavidev/BetterAgentX/issues](https://github.com/jemavidev/BetterAgentX/issues)

---

## 🤝 Contributing

Want to improve BetterAgents?

1. Fork the repository
2. Create a branch: `git checkout -b feature/improvement`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push: `git push origin feature/improvement`
5. Open a Pull Request

---

## 📄 License

MIT License - See [license](license) for more details

---

## ✨ Ready!

Your BetterAgents system is installed and running.

**Command to get started:**
```bash
claude .
```

**First test command:**
```
/architect Hello! Can you explain how you work?
```

---

**Problems?** Check the [Troubleshooting](#troubleshooting) section or open an issue on GitHub.

**Happy coding with your 12 specialized agents! 🚀**
