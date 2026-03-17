# BetterAgents Troubleshooting Guide

**Version:** 4.0.0  
**Last Updated:** 2026-03-02

## Quick Diagnostics

### Run Health Check

```bash
# Universal health check
bash scripts/health-check.sh

# Platform-specific validation
bash platforms/claude/validate.sh .
bash platforms/kiro/validate.sh .
```

### Check Installation Status

```bash
# Detect installed platforms
bash scripts/detect-platform.sh .

# Expected output:
# {
#   "claude": true,
#   "kiro": true,
#   "legacy": false
# }
```

## Common Issues

### Installation Issues

#### Issue: "Permission denied" when running install.sh

**Symptoms:**
```
bash: ./install.sh: Permission denied
```

**Cause:** Script is not executable

**Solution:**
```bash
# Make script executable
chmod +x install.sh
chmod +x scripts/*.sh
chmod +x platforms/*/install.sh
chmod +x platforms/*/*.sh

# Or run with bash
bash install.sh
```

---

#### Issue: "jq: command not found"

**Symptoms:**
```
install.sh: line 42: jq: command not found
```

**Cause:** jq JSON processor not installed

**Solution:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# Fedora
sudo dnf install jq

# Arch Linux
sudo pacman -S jq

# Windows (WSL)
sudo apt-get install jq
```

---

#### Issue: "Target directory does not exist"

**Symptoms:**
```
ERROR: Target directory does not exist: /path/to/project
```

**Cause:** Specified directory doesn't exist

**Solution:**
```bash
# Create directory first
mkdir -p /path/to/project

# Or install to current directory
cd /path/to/project
bash /path/to/installer/install.sh
```

---

#### Issue: "Platform not detected"

**Symptoms:**
```
WARNING: No platform detected
```

**Cause:** Auto-detection failed or no platform specified

**Solution:**
```bash
# Specify platform explicitly
bash install.sh --platform claude
bash install.sh --platform kiro
bash install.sh --platform claude,kiro
```

---

#### Issue: "Backup failed"

**Symptoms:**
```
ERROR: Failed to create backup
```

**Cause:** Insufficient permissions or disk space

**Solution:**
```bash
# Check disk space
df -h

# Check permissions
ls -la .claude/

# Create backup directory manually
mkdir -p .claude/backups

# Or skip backup (not recommended)
bash install.sh --no-backup
```

---

### Validation Issues

#### Issue: "Missing required files"

**Symptoms:**
```
ERROR: Missing: .claude/agents
ERROR: Missing: CLAUDE.md
```

**Cause:** Incomplete installation

**Solution:**
```bash
# Reinstall platform
bash install.sh --platform claude --force

# Or repair installation
bash platforms/claude/install.sh .
```

---

#### Issue: "Invalid JSON"

**Symptoms:**
```
ERROR: Invalid JSON: active-context.json
```

**Cause:** Corrupted JSON file

**Solution:**
```bash
# Validate JSON manually
jq empty .claude/memory/active-context.json

# If invalid, restore from backup
cp .claude/backups/backup-*/memory/active-context.json .claude/memory/

# Or reset to template
cp installer/templates/memory/active-context.json .claude/memory/
```

---

#### Issue: "Agent count mismatch"

**Symptoms:**
```
WARNING: Agents: 10/12 (expected 12)
```

**Cause:** Some agent files missing

**Solution:**
```bash
# List installed agents
ls -la .claude/agents/

# Reinstall agents
bash platforms/claude/install.sh . --force

# Or copy missing agents manually
cp installer/platforms/claude/templates/agents/*.md .claude/agents/
```

---

### Runtime Issues

#### Issue: "Memory scripts not working"

**Symptoms:**
```
bash: .claude/scripts/add-task.sh: No such file or directory
```

**Cause:** Scripts not installed or not executable

**Solution:**
```bash
# Check if scripts exist
ls -la .claude/scripts/

# Make scripts executable
chmod +x .claude/scripts/*.sh

# Reinstall scripts
bash platforms/claude/install.sh . --force
```

---

#### Issue: "Dashboard won't start"

**Symptoms:**
```
ERROR: Failed to start dashboard
```

**Cause:** Port already in use or Node.js not installed

**Solution:**
```bash
# Check if port 3000 is in use
lsof -i :3000

# Kill process using port
kill -9 $(lsof -t -i:3000)

# Or use different port
PORT=3001 bash .claude/scripts/start-dashboard.sh

# Check Node.js installation
node --version
npm --version

# Install Node.js if missing
# macOS: brew install node
# Ubuntu: sudo apt-get install nodejs npm
```

---

#### Issue: "Memory bridge not working (Kiro)"

**Symptoms:**
```
ERROR: Cannot write to .claude/memory/
```

**Cause:** Claude platform not installed or permissions issue

**Solution:**
```bash
# Check if Claude platform installed
bash scripts/detect-platform.sh .

# Install Claude platform
bash install.sh --platform claude

# Check permissions
ls -la .claude/memory/

# Fix permissions
chmod 755 .claude/memory/
chmod 644 .claude/memory/*.json
```

---

### Platform-Specific Issues

#### Claude Code Issues

##### Issue: "CLAUDE.md not recognized"

**Symptoms:**
- Claude Code doesn't load orchestrator
- Agents not available

**Solution:**
```bash
# Verify CLAUDE.md exists
ls -la CLAUDE.md

# Check file content
head -20 CLAUDE.md

# Reinstall
bash platforms/claude/install.sh . --force

# Restart Claude Code
```

---

##### Issue: "Hooks not triggering"

**Symptoms:**
- Memory not updating automatically
- Scripts not running on events

**Solution:**
```bash
# Check settings.local.json
cat .claude/settings.local.json

# Verify hooks configuration
jq '.hooks' .claude/settings.local.json

# Reinstall hooks
bash platforms/claude/install.sh . --force

# Restart Claude Code
```

---

##### Issue: "Commands not showing up"

**Symptoms:**
- Skills not available in Claude Code
- Command palette empty

**Solution:**
```bash
# Check commands directory
ls -la .claude/commands/

# Count commands
find .claude/commands -name "*.md" | wc -l

# Should be 76+
# If not, reinstall
bash platforms/claude/install.sh . --force
```

---

#### Kiro IDE Issues

##### Issue: "AGENTS.md not loaded"

**Symptoms:**
- Kiro doesn't recognize orchestrator
- AgentX not active

**Solution:**
```bash
# Verify AGENTS.md exists
ls -la AGENTS.md

# Check file content
head -20 AGENTS.md

# Reinstall
bash platforms/kiro/install.sh . --force

# Restart Kiro IDE
```

---

##### Issue: "Steering files not in context"

**Symptoms:**
- AgentX doesn't have project context
- Memory not accessible

**Solution:**
```bash
# Check steering directory
ls -la .kiro/steering/

# Verify steering files
cat .kiro/steering/project-context.md

# Reinstall steering files
bash platforms/kiro/install.sh . --force

# Restart Kiro IDE
```

---

##### Issue: "Custom agents not working"

**Symptoms:**
- Custom agents not available
- Agent dispatch fails

**Solution:**
```bash
# Check agents directory
ls -la .kiro/agents/

# Verify agent format
cat .kiro/agents/your-agent.md

# Check agent metadata
# Should have: name, description, capabilities

# Restart Kiro IDE
```

---

### Multi-Platform Issues

#### Issue: "Platforms conflicting"

**Symptoms:**
- Both platforms installed but interfering
- Configuration conflicts

**Solution:**
```bash
# Check for conflicts
bash scripts/health-check.sh

# Platforms should coexist peacefully
# CLAUDE.md and AGENTS.md are independent
# .claude/ and .kiro/ are separate

# If conflicts persist, reinstall both
bash install.sh --platform claude,kiro --force
```

---

#### Issue: "Memory bridge not syncing"

**Symptoms:**
- Kiro can't access Claude memory
- Memory updates not visible

**Solution:**
```bash
# Verify both platforms installed
bash scripts/detect-platform.sh .

# Check memory bridge script
ls -la .kiro/scripts/update-memory.sh

# Test memory bridge
bash .kiro/scripts/update-memory.sh

# Check Claude memory
ls -la .claude/memory/

# Verify permissions
chmod 755 .claude/memory/
chmod 644 .claude/memory/*.json
```

---

## Advanced Troubleshooting

### Debug Mode

```bash
# Enable debug output
export BETTERAGENTS_DEBUG=1
bash install.sh --verbose

# Check logs
tail -f /tmp/betteragents-install.log
```

### Manual Validation

```bash
# Check directory structure
tree -L 3 .claude/
tree -L 3 .kiro/

# Validate JSON files
for json in .claude/memory/*.json; do
  echo "Validating $json"
  jq empty "$json" && echo "✓ Valid" || echo "✗ Invalid"
done

# Check script permissions
find .claude/scripts -name "*.sh" -exec ls -la {} \;
find .kiro/scripts -name "*.sh" -exec ls -la {} \;

# Count files
echo "Agents: $(find .claude/agents -name "*.md" | wc -l)"
echo "Commands: $(find .claude/commands -name "*.md" | wc -l)"
echo "Protocols: $(find .claude/protocols -name "*.md" | wc -l)"
```

### Reset Installation

```bash
# Backup current installation
cp -r .claude .claude.backup-$(date +%Y%m%d-%H%M%S)
cp -r .kiro .kiro.backup-$(date +%Y%m%d-%H%M%S)

# Uninstall platforms
bash platforms/claude/uninstall.sh .
bash platforms/kiro/uninstall.sh .

# Clean reinstall
bash install.sh --platform claude,kiro --force

# Validate
bash scripts/health-check.sh
```

### Restore from Backup

```bash
# List backups
ls -la .claude/backups/

# Restore from backup
BACKUP_DIR=".claude/backups/backup-20260302-120000"
cp -r "$BACKUP_DIR"/* .claude/

# Validate restoration
bash platforms/claude/validate.sh .
```

## Performance Issues

### Issue: "Installation is slow"

**Symptoms:**
- Installation takes >10 seconds
- System feels sluggish

**Diagnosis:**
```bash
# Check disk I/O
iostat -x 1 5

# Check CPU usage
top -l 1 | grep "CPU usage"

# Check available disk space
df -h
```

**Solution:**
```bash
# Free up disk space
rm -rf .claude/cache/*
rm -rf .claude/backups/backup-*

# Close other applications
# Restart terminal
# Try installation again
```

---

### Issue: "Validation is slow"

**Symptoms:**
- Health check takes >5 seconds
- Validation hangs

**Diagnosis:**
```bash
# Run validation with timing
time bash scripts/health-check.sh

# Check for large files
find .claude -type f -size +1M

# Check for many files
find .claude -type f | wc -l
```

**Solution:**
```bash
# Clean cache
rm -rf .claude/cache/*

# Remove old backups
find .claude/backups -type d -mtime +30 -exec rm -rf {} \;

# Optimize JSON files
for json in .claude/memory/*.json; do
  jq -c . "$json" > "$json.tmp" && mv "$json.tmp" "$json"
done
```

## Getting Help

### Before Asking for Help

1. **Run health check:**
   ```bash
   bash scripts/health-check.sh > health-check.txt
   ```

2. **Collect system info:**
   ```bash
   uname -a > system-info.txt
   bash --version >> system-info.txt
   jq --version >> system-info.txt
   ```

3. **Check logs:**
   ```bash
   cat /tmp/betteragents-install.log
   ```

4. **Document steps to reproduce:**
   - What command did you run?
   - What was the expected result?
   - What actually happened?
   - Any error messages?

### Support Channels

- **GitHub Issues:** https://github.com/jemavidev/BetterAgentX/issues
- **Documentation:** See [installation-guide.md](installation-guide.md)
- **Architecture:** See [architecture.md](architecture.md)

### Reporting Bugs

When reporting bugs, include:

1. **Health check output:** `bash scripts/health-check.sh`
2. **System information:** OS, bash version, jq version
3. **Installation command:** Exact command you ran
4. **Error messages:** Full error output
5. **Steps to reproduce:** Detailed steps
6. **Expected vs actual:** What should happen vs what happened

## FAQ

### Q: Can I install both Claude and Kiro platforms?

**A:** Yes! They coexist peacefully. Run:
```bash
bash install.sh --platform claude,kiro
```

### Q: Will installation overwrite my existing files?

**A:** No. Installation creates backups before modifying files. Backups are stored in `.claude/backups/` or `.kiro/backups/`.

### Q: How do I uninstall BetterAgents?

**A:** Run the uninstall script:
```bash
bash platforms/claude/uninstall.sh .
bash platforms/kiro/uninstall.sh .
```

### Q: Can I customize agents and skills?

**A:** Yes! Add custom agents to `.claude/agents/` or `.kiro/agents/`. Add custom skills to `.claude/commands/` or `.kiro/skills/`.

### Q: How do I upgrade to the latest version?

**A:** Run the installer again:
```bash
bash install.sh
```
It will detect the existing installation and upgrade it.

### Q: Is my data safe during upgrade?

**A:** Yes. Automatic backups are created before any modifications. You can restore from `.claude/backups/` if needed.

### Q: What if health check fails?

**A:** Check the specific errors reported. Most issues can be fixed by reinstalling:
```bash
bash install.sh --force
```

### Q: Can I use BetterAgents in a monorepo?

**A:** Yes! Install in each package:
```bash
for package in packages/*; do
  bash install.sh --target "$package"
done
```

### Q: Does BetterAgents work in Docker?

**A:** Yes! See [installation-guide.md](installation-guide.md) for Docker instructions.

### Q: How do I migrate from legacy to modular?

**A:** Run the migration script:
```bash
bash scripts/migrate-legacy.sh
```

## References

- **Installation Guide:** [installation-guide.md](installation-guide.md)
- **Architecture:** [architecture.md](architecture.md)
- **Upgrading:** [upgrading.md](upgrading.md)
- **Contributing:** [contributing.md](contributing.md)

---

**Still having issues?** Open an issue on GitHub with your health check output and system information.
