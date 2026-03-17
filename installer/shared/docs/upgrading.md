# BetterAgents Upgrading Guide

**Version:** 4.0.0  
**Last Updated:** 2026-03-02

## Overview

This guide covers upgrading BetterAgents installations, including migrating from legacy monolithic installations to the new modular architecture.

## Quick Upgrade

### Upgrade Existing Modular Installation

```bash
# Navigate to your project
cd /path/to/project

# Run installer (auto-detects and upgrades)
bash /path/to/installer/install.sh

# Verify upgrade
bash /path/to/installer/scripts/health-check.sh
```

The installer automatically:
- Detects existing installation
- Creates backup before upgrading
- Preserves user data (memory, custom agents)
- Updates system files
- Validates upgraded installation

## Migration from Legacy to Modular

### What's Changed?

**Legacy (v3.x):**
```
project/
├── CLAUDE.md
├── .claude/
│   └── (monolithic structure)
└── install.sh (single file)
```

**Modular (v4.x):**
```
project/
├── CLAUDE.md (or AGENTS.md)
├── .claude/ (or .kiro/)
│   └── (platform-specific structure)
└── installer/
    ├── install.sh (orchestrator)
    ├── platforms/
    │   ├── claude/
    │   └── kiro/
    └── lib/
```

### Migration Steps

#### Step 1: Backup Current Installation

```bash
# Create full backup
cd /path/to/project
tar -czf betteragents-backup-$(date +%Y%m%d-%H%M%S).tar.gz .claude/

# Or use cp
cp -r .claude .claude.backup-$(date +%Y%m%d-%H%M%S)
```

#### Step 2: Run Migration Script

```bash
# Clone new installer
git clone https://github.com/jemavidev/BetterAgentX
cd BetterAgentX/installer

# Run migration
bash scripts/migrate-legacy.sh /path/to/project
```

#### Step 3: Verify Migration

```bash
# Run health check
bash scripts/health-check.sh /path/to/project

# Expected output:
# ✓ Claude Code: VALID
# ALL SYSTEMS OPERATIONAL
```

#### Step 4: Test Functionality

```bash
cd /path/to/project

# Test memory system
bash .claude/scripts/add-task.sh "Test migration" "Verify migration successful"

# Check memory files
cat .claude/memory/progress.json

# Start dashboard
bash .claude/scripts/start-dashboard.sh
```

### What Gets Preserved?

**Preserved during migration:**
- ✅ Memory files (active-context.json, decision-log.json, progress.json, patterns.json)
- ✅ Custom agents (.claude/agents/custom-*.md)
- ✅ Custom skills (.claude/commands/custom-*.md)
- ✅ User configuration (.claudecode.json)
- ✅ Session history (llm-usage.json)
- ✅ Dashboard data

**Updated during migration:**
- 🔄 System agents (architect, coder, etc.)
- 🔄 Core skills (76+ commands)
- 🔄 Protocols
- 🔄 Scripts
- 🔄 CLAUDE.md orchestrator

**Not affected:**
- ⚪ Your project code
- ⚪ Git history
- ⚪ Other configuration files

## Version-Specific Upgrades

### Upgrading from 3.7.x to 4.0.0

**Major Changes:**
- Modular installer architecture
- Multi-platform support (Claude + Kiro)
- Plugin-based platform modules
- Shared documentation

**Breaking Changes:**
- None (backward compatible)

**Migration:**
```bash
# Automatic migration
bash install.sh

# Or manual migration
bash scripts/migrate-legacy.sh .
```

### Upgrading from 3.6.x to 3.7.x

**Major Changes:**
- Memory governance (Protocol 5b)
- Autonomous memory updates
- Memory debt tracking

**Breaking Changes:**
- None

**Migration:**
```bash
# Standard upgrade
bash install.sh
```

### Upgrading from 3.5.x to 3.6.x

**Major Changes:**
- Dashboard with activity tracking
- LLM usage metrics
- Session history

**Breaking Changes:**
- None

**Migration:**
```bash
# Standard upgrade
bash install.sh

# New files added:
# - .claude/memory/dashboard.html
# - .claude/memory/llm-usage.json
# - .claude/scripts/start-dashboard.sh
```

## Upgrade Scenarios

### Scenario 1: Upgrade Single Platform

```bash
# Upgrade Claude Code only
cd /path/to/project
bash /path/to/installer/install.sh --platform claude

# Verify
bash /path/to/installer/platforms/claude/validate.sh .
```

### Scenario 2: Add Second Platform

```bash
# Already have Claude, add Kiro
cd /path/to/project
bash /path/to/installer/install.sh --platform kiro

# Verify both platforms
bash /path/to/installer/scripts/health-check.sh
```

### Scenario 3: Upgrade Both Platforms

```bash
# Upgrade both simultaneously
cd /path/to/project
bash /path/to/installer/install.sh --platform claude,kiro

# Verify
bash /path/to/installer/scripts/health-check.sh
```

### Scenario 4: Upgrade in CI/CD

```yaml
# .github/workflows/upgrade-betteragents.yml
name: Upgrade BetterAgents
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  upgrade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Backup current installation
        run: |
          tar -czf betteragents-backup.tar.gz .claude/
      
      - name: Clone installer
        run: |
          git clone https://github.com/jemavidev/BetterAgentX
      
      - name: Upgrade BetterAgents
        run: |
          cd BetterAgentX/installer
          bash install.sh --target $GITHUB_WORKSPACE --platform claude
      
      - name: Validate upgrade
        run: |
          cd BetterAgentX/installer
          bash scripts/health-check.sh $GITHUB_WORKSPACE
      
      - name: Commit changes
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add .claude/
          git commit -m "chore: upgrade BetterAgents to latest version"
          git push
```

## Rollback Procedures

### Rollback from Backup

```bash
# List available backups
ls -la .claude/backups/

# Identify backup to restore
BACKUP_DIR=".claude/backups/backup-20260302-120000"

# Stop any running processes
pkill -f "start-dashboard.sh"

# Restore from backup
rm -rf .claude/
cp -r "$BACKUP_DIR" .claude/

# Verify restoration
bash /path/to/installer/platforms/claude/validate.sh .
```

### Rollback to Previous Version

```bash
# If you have version control
git log --oneline | grep "BetterAgents"

# Checkout previous version
git checkout <commit-hash> -- .claude/

# Or restore from tar backup
tar -xzf betteragents-backup-20260302-120000.tar.gz

# Verify
bash /path/to/installer/scripts/health-check.sh
```

### Emergency Rollback

```bash
# Complete removal and reinstall previous version
bash /path/to/installer/platforms/claude/uninstall.sh .

# Clone previous version
git clone --branch v3.7.0 https://github.com/jemavidev/BetterAgentX

# Install previous version
cd BetterAgentX/installer
bash install.sh --target /path/to/project
```

## Post-Upgrade Tasks

### 1. Verify Installation

```bash
# Run health check
bash scripts/health-check.sh

# Check version
cat .claude/.version
cat .kiro/.version
```

### 2. Test Core Functionality

```bash
# Test memory system
bash .claude/scripts/add-task.sh "Post-upgrade test" "Verify functionality"

# Test dashboard
bash .claude/scripts/start-dashboard.sh

# Test memory bridge (if Kiro installed)
bash .kiro/scripts/update-memory.sh
```

### 3. Review Changes

```bash
# Check what changed
git diff HEAD .claude/

# Review new files
find .claude -type f -mtime -1

# Check for deprecated files
# (None in 4.0.0 upgrade)
```

### 4. Update Documentation

```bash
# Update project README if needed
# Document any custom configurations
# Note upgrade date and version
```

### 5. Notify Team

```bash
# If working in a team
git add .claude/ .kiro/ CLAUDE.md AGENTS.md
git commit -m "chore: upgrade BetterAgents to v4.0.0"
git push

# Notify team members to pull changes
```

## Troubleshooting Upgrades

### Issue: "Upgrade failed"

**Solution:**
```bash
# Restore from automatic backup
ls -la .claude/backups/
cp -r .claude/backups/backup-latest/* .claude/

# Or retry upgrade
bash install.sh --force
```

### Issue: "Custom agents lost"

**Solution:**
```bash
# Custom agents are backed up
ls -la .claude/backups/backup-*/agents/custom-*

# Restore custom agents
cp .claude/backups/backup-latest/agents/custom-*.md .claude/agents/
```

### Issue: "Memory data corrupted"

**Solution:**
```bash
# Restore memory from backup
cp -r .claude/backups/backup-latest/memory/*.json .claude/memory/

# Validate JSON
for json in .claude/memory/*.json; do
  jq empty "$json" && echo "✓ $json" || echo "✗ $json"
done
```

### Issue: "Version mismatch"

**Solution:**
```bash
# Check installed version
cat .claude/.version

# Check installer version
cat installer/config/betteragents.json | jq -r '.version'

# Force reinstall
bash install.sh --force
```

## Best Practices

### 1. Always Backup Before Upgrade

```bash
# Automatic backup (default)
bash install.sh  # Creates backup automatically

# Manual backup (extra safety)
tar -czf betteragents-backup-$(date +%Y%m%d-%H%M%S).tar.gz .claude/ .kiro/
```

### 2. Test in Development First

```bash
# Create test branch
git checkout -b test-upgrade

# Run upgrade
bash install.sh

# Test thoroughly
bash scripts/health-check.sh

# If successful, merge to main
git checkout main
git merge test-upgrade
```

### 3. Review Release Notes

Before upgrading, check:
- **GitHub Releases:** https://github.com/jemavidev/BetterAgentX/releases
- **CHANGELOG.md:** Review breaking changes
- **Migration guides:** Platform-specific notes

### 4. Schedule Upgrades

```bash
# Don't upgrade during:
# - Active development sprints
# - Before major releases
# - During critical bug fixes

# Best times to upgrade:
# - Start of sprint
# - After major release
# - During maintenance windows
```

### 5. Communicate with Team

```bash
# Before upgrade
# - Notify team members
# - Schedule upgrade window
# - Ensure everyone commits changes

# After upgrade
# - Share upgrade notes
# - Document any issues
# - Help team members pull changes
```

## Upgrade Checklist

### Pre-Upgrade

- [ ] Backup current installation
- [ ] Review release notes
- [ ] Check for breaking changes
- [ ] Notify team members
- [ ] Commit all pending changes
- [ ] Close IDE/editor

### During Upgrade

- [ ] Run installer
- [ ] Monitor output for errors
- [ ] Note any warnings
- [ ] Wait for completion

### Post-Upgrade

- [ ] Run health check
- [ ] Verify version numbers
- [ ] Test core functionality
- [ ] Check custom agents/skills
- [ ] Review memory data
- [ ] Test dashboard
- [ ] Commit changes
- [ ] Notify team

## FAQ

### Q: Will upgrade overwrite my custom agents?

**A:** No. Custom agents are preserved. Only system agents are updated.

### Q: How long does upgrade take?

**A:** Typically 3-5 seconds for single platform, 5-10 seconds for both platforms.

### Q: Can I upgrade without internet?

**A:** Yes, if you have the installer locally. No internet required.

### Q: Will upgrade affect my project code?

**A:** No. BetterAgents only modifies `.claude/`, `.kiro/`, and orchestrator files.

### Q: Can I downgrade after upgrade?

**A:** Yes. Restore from backup or reinstall previous version.

### Q: Do I need to restart my IDE?

**A:** Recommended but not always required. Restart ensures new configuration is loaded.

### Q: Will memory data be preserved?

**A:** Yes. All memory files are backed up and preserved during upgrade.

### Q: Can I upgrade one platform at a time?

**A:** Yes. Use `--platform` flag to upgrade specific platform.

## Version Compatibility

| Installer Version | Claude Platform | Kiro Platform | Compatible |
|------------------|-----------------|---------------|------------|
| 4.0.0 | 4.0.0 | 4.0.0 | ✅ Yes |
| 4.0.0 | 3.7.0 | - | ✅ Yes (auto-upgrade) |
| 4.0.0 | - | 4.0.0 | ✅ Yes |
| 3.7.0 | 3.7.0 | - | ⚠️ Upgrade recommended |
| 3.6.0 | 3.6.0 | - | ⚠️ Upgrade recommended |

## References

- **Installation Guide:** [installation-guide.md](installation-guide.md)
- **Architecture:** [architecture.md](architecture.md)
- **Troubleshooting:** [troubleshooting.md](troubleshooting.md)
- **Contributing:** [contributing.md](contributing.md)

---

**Need help upgrading?** Open an issue on GitHub or check the troubleshooting guide.
