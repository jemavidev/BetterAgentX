# BetterAgents Installation Guide

**Version:** 4.0.0  
**Last Updated:** 2026-03-02

## Overview

This guide covers common installation patterns and best practices for BetterAgents across all supported platforms.

## Quick Start

### Basic Installation

```bash
# Install to current directory (auto-detect platform)
bash install.sh

# Install specific platform
bash install.sh --platform claude
bash install.sh --platform kiro

# Install to specific directory
bash install.sh --target /path/to/project

# Install both platforms
bash install.sh --platform claude,kiro
```

### Verification

```bash
# Run health check
bash scripts/health-check.sh

# Validate specific platform
bash platforms/claude/validate.sh .
bash platforms/kiro/validate.sh .
```

## Installation Modes

### Mode A: Fresh Installation (New Project)

**Scenario:** Installing BetterAgents in a new project with no existing configuration.

**Behavior:**
- Creates all directories and files
- Deploys all templates
- Initializes memory system (Claude)
- Sets up default configuration

**Command:**
```bash
cd /path/to/new/project
bash /path/to/installer/install.sh
```

**Result:**
```
project/
├── CLAUDE.md (or AGENTS.md)
├── .claudecode.json (or equivalent)
└── .claude/ (or .kiro/)
    ├── agents/
    ├── commands/
    ├── memory/
    └── ...
```

### Mode B: Upgrade (Existing BetterAgents)

**Scenario:** Upgrading an existing BetterAgents installation to the latest version.

**Behavior:**
- Backs up existing files
- Preserves user data (memory, custom agents)
- Updates system files
- Migrates configuration if needed

**Command:**
```bash
cd /path/to/existing/project
bash /path/to/installer/install.sh
```

**Backup Location:**
```
.claude/backups/backup-YYYYMMDD-HHMMSS/
```

### Mode C: Add Platform (Multi-Platform)

**Scenario:** Adding a second platform to an existing installation.

**Behavior:**
- Detects existing platform
- Installs new platform alongside
- Sets up memory bridge (if applicable)
- Preserves existing configuration

**Command:**
```bash
# Already have Claude, adding Kiro
cd /path/to/project
bash /path/to/installer/install.sh --platform kiro
```

**Result:**
```
project/
├── CLAUDE.md              # Existing
├── AGENTS.md              # New
├── .claudecode.json       # Existing
├── .claude/               # Existing
└── .kiro/                 # New
```

## Platform-Specific Installation

### Claude Code Platform

**Requirements:**
- Claude Code IDE installed
- Bash 4.0+
- jq (for JSON operations)

**Installation:**
```bash
bash install.sh --platform claude
```

**What Gets Installed:**
```
.claude/
├── agents/           # 12 specialized agents
├── commands/         # 76+ skills
├── protocols/        # 7 protocols
├── memory/           # Memory system
│   ├── MEMORY.md
│   ├── active-context.json
│   ├── decision-log.json
│   ├── progress.json
│   ├── patterns.json
│   ├── llm-usage.json
│   ├── session-last.md
│   └── dashboard.html
├── scripts/          # Memory management scripts
├── cache/            # Cache directory
├── backups/          # Backup directory
├── settings.local.json
└── .version
```

**Configuration:**
```json
// .claudecode.json
{
  "betteragents": {
    "enabled": true,
    "version": "4.0.0",
    "memory": true,
    "dashboard": true
  }
}
```

**Validation:**
```bash
bash platforms/claude/validate.sh .
```

### Kiro IDE Platform

**Requirements:**
- Kiro IDE installed (optional)
- Bash 4.0+
- jq (for memory bridge)

**Installation:**
```bash
bash install.sh --platform kiro
```

**What Gets Installed:**
```
.kiro/
├── steering/         # Steering files (context)
│   ├── agentx-identity.md
│   ├── project-context.md
│   ├── architecture-decisions.md
│   └── reusable-patterns.md
├── agents/           # Custom agents (optional)
├── skills/           # Skills (optional)
├── scripts/          # Utility scripts
│   └── update-memory.sh
├── settings/         # Settings (optional)
└── .version
```

**Configuration:**
```
# AGENTS.md (root level)
Universal orchestrator configuration
```

**Validation:**
```bash
bash platforms/kiro/validate.sh .
```

## Advanced Installation Scenarios

### Scenario 1: Docker Container

```bash
# Build installer image
docker build -t betteragents-installer .

# Run installation
docker run -v $(pwd):/workspace betteragents-installer \
  bash install.sh --target /workspace --platform claude
```

### Scenario 2: CI/CD Pipeline

```yaml
# .github/workflows/install-betteragents.yml
name: Install BetterAgents
on: [push]
jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install BetterAgents
        run: |
          git clone https://github.com/jemavidev/BetterAgentX
          cd BetterAgentX/installer
          bash install.sh --target $GITHUB_WORKSPACE --platform claude
      - name: Validate Installation
        run: |
          cd BetterAgentX/installer
          bash scripts/health-check.sh $GITHUB_WORKSPACE
```

### Scenario 3: Monorepo

```bash
# Install in multiple packages
for package in packages/*; do
  echo "Installing in $package"
  bash install.sh --target "$package" --platform claude
done
```

### Scenario 4: Remote Installation

```bash
# Install from remote script
curl -fsSL https://raw.githubusercontent.com/jemavidev/BetterAgentX/main/installer/install.sh | bash

# Or with wget
wget -qO- https://raw.githubusercontent.com/jemavidev/BetterAgentX/main/installer/install.sh | bash
```

## Configuration Options

### Command-Line Arguments

```bash
# Platform selection
--platform claude          # Install Claude Code only
--platform kiro            # Install Kiro IDE only
--platform claude,kiro     # Install both platforms

# Target directory
--target /path/to/project  # Install to specific directory

# Installation mode
--mode fresh               # Fresh installation (default)
--mode upgrade             # Upgrade existing installation
--mode add                 # Add platform to existing

# Options
--skip-validation          # Skip validation after install
--no-backup                # Don't create backup (not recommended)
--force                    # Force installation (overwrite)
--quiet                    # Minimal output
--verbose                  # Detailed output
```

### Environment Variables

```bash
# Override default paths
export BETTERAGENTS_INSTALL_DIR="/custom/path"

# Skip interactive prompts
export BETTERAGENTS_AUTO_CONFIRM=1

# Custom backup location
export BETTERAGENTS_BACKUP_DIR="/backups"

# Debug mode
export BETTERAGENTS_DEBUG=1
```

### Configuration Files

#### `config/betteragents.json`

```json
{
  "version": "4.0.0",
  "project": {
    "name": "MyProject",
    "version": "1.0.0",
    "phase": "development",
    "focus": "Feature implementation"
  },
  "platforms": {
    "claude": {
      "enabled": true,
      "memory": true,
      "dashboard": true,
      "hooks": true
    },
    "kiro": {
      "enabled": true,
      "memoryBridge": true
    }
  },
  "features": {
    "autoBackup": true,
    "validation": true,
    "healthCheck": true
  }
}
```

## Post-Installation

### Verify Installation

```bash
# Run health check
bash scripts/health-check.sh

# Expected output:
# ✓ Claude Code: VALID
# ✓ Kiro IDE: VALID
# ALL SYSTEMS OPERATIONAL
```

### Test Functionality

#### Claude Code

```bash
# Test memory system
bash .claude/scripts/add-task.sh "Test task" "Testing installation"

# Start dashboard
bash .claude/scripts/start-dashboard.sh

# Verify agents
ls -la .claude/agents/
```

#### Kiro IDE

```bash
# Test memory bridge
bash .kiro/scripts/update-memory.sh

# Verify steering files
ls -la .kiro/steering/
```

### Configure IDE

#### Claude Code

1. Open project in Claude Code
2. Verify `.claudecode.json` is recognized
3. Check that `CLAUDE.md` is loaded
4. Test agent dispatch: "Create a new feature"

#### Kiro IDE

1. Open project in Kiro
2. Verify `AGENTS.md` is loaded
3. Check steering files in context
4. Test orchestration: "Analyze this codebase"

## Troubleshooting

### Common Issues

#### Issue: "Platform not detected"

**Solution:**
```bash
# Manually specify platform
bash install.sh --platform claude --force
```

#### Issue: "Permission denied"

**Solution:**
```bash
# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh
chmod +x platforms/*/install.sh
```

#### Issue: "jq: command not found"

**Solution:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

#### Issue: "Backup failed"

**Solution:**
```bash
# Create backup directory manually
mkdir -p .claude/backups

# Or skip backup (not recommended)
bash install.sh --no-backup
```

### Validation Failures

If validation fails, check:

1. **File permissions:** All scripts should be executable
2. **Directory structure:** All required directories exist
3. **JSON files:** Valid JSON syntax (use `jq` to validate)
4. **Dependencies:** All required commands available

### Getting Help

- **Documentation:** See [troubleshooting.md](troubleshooting.md)
- **Health Check:** Run `bash scripts/health-check.sh`
- **Verbose Mode:** Run with `--verbose` flag
- **GitHub Issues:** https://github.com/jemavidev/BetterAgentX/issues

## Best Practices

### 1. Always Validate

```bash
# After installation
bash scripts/health-check.sh

# Before committing
bash scripts/health-check.sh
```

### 2. Backup Before Upgrade

```bash
# Manual backup
cp -r .claude .claude.backup-$(date +%Y%m%d)

# Automatic backup (default)
bash install.sh  # Creates backup automatically
```

### 3. Use Version Control

```bash
# .gitignore
.claude/cache/
.claude/backups/
.kiro/cache/

# Commit configuration
git add .claudecode.json CLAUDE.md AGENTS.md
git commit -m "Add BetterAgents configuration"
```

### 4. Test in Development First

```bash
# Test in dev branch
git checkout -b test-betteragents
bash install.sh
bash scripts/health-check.sh

# If successful, merge to main
git checkout main
git merge test-betteragents
```

### 5. Document Customizations

```bash
# Create BETTERAGENTS.md in project root
cat > BETTERAGENTS.md << 'EOF'
# BetterAgents Configuration

## Installed Platforms
- Claude Code (v4.0.0)
- Kiro IDE (v4.0.0)

## Custom Agents
- custom-agent-1: Description
- custom-agent-2: Description

## Custom Skills
- custom-skill-1: Description

## Notes
- Memory bridge enabled
- Dashboard on port 3000
EOF
```

## Next Steps

After successful installation:

1. **Read the documentation:** [architecture.md](architecture.md)
2. **Explore agents:** `.claude/agents/` or `.kiro/agents/`
3. **Try the dashboard:** `bash .claude/scripts/start-dashboard.sh`
4. **Test orchestration:** Ask Claude/Kiro to perform a task
5. **Customize:** Add custom agents, skills, or steering files

## References

- **Architecture:** [architecture.md](architecture.md)
- **Troubleshooting:** [troubleshooting.md](troubleshooting.md)
- **Upgrading:** [upgrading.md](upgrading.md)
- **Contributing:** [contributing.md](contributing.md)

---

**Need Help?** Open an issue on GitHub or check the troubleshooting guide.
