# Troubleshooting: verify-system.sh

Guide to diagnosing and fixing errors in the system verification script.

## Debug Mode

For detailed information on what the script is checking:

```bash
bash scripts/verify-system.sh --debug
```

This will show:
- Exact paths being verified
- Files found in each directory
- Variable values during execution
- Commands executed internally

## Common Errors

### 1. "Not found config/betteragents.json"

**Cause:** The script is not being run from the correct directory.

**Solution:**
```bash
# Make sure you are in the root directory of the project
cd /path/to/BetterAgents
bash scripts/verify-system.sh
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug
# Check the lines:
# [DEBUG] Script directory: ...
# [DEBUG] Project root: ...
```

---

### 2. "Only X agents (expected 13)"

**Cause:** Agent files are missing or there are extra files.

**Solution:**
```bash
# Check which agents exist
ls -1 .claude/agents/*.md

# You should see 12 files:
# - architect.md
# - coder.md
# - critic.md
# - data-scientist.md
# - devops.md
# - product-manager.md
# - researcher.md
# - security.md
# - teacher.md
# - tester.md
# - ux-designer.md
# - writer.md
# (AgentX lives in CLAUDE.md, not in .claude/agents/)
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep "Found.*agent files"
```

---

### 3. "AgentX not responding correctly"

**Cause:** `CLAUDE.md` is incomplete or missing from the project root.

**Solution:**
```bash
# Verify that CLAUDE.md exists and has the AgentX header
grep "AgentX" CLAUDE.md | head -3

# If missing, reinstall:
bash installer/install.sh
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep -A 5 "CLAUDE.md"
```

---

### 4. "[agent]: Missing sections"

**Cause:** A specialized agent does not have the `## Role` and `## Expertise` sections.

**Solution:**
```bash
# Verify the agent's structure
grep "^##" .claude/agents/[agent].md | head -5
```

**Expected structure:**
```markdown
## Role
...role description...

## Expertise
...areas of expertise...
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep -A 3 "Checking agent: [agent]"
```

---

### 5. "Memory system: X JSON files found"

**Cause:** Exactly 4 JSON files are not found in `.claude/memory/`.

**Solution:**
```bash
# Check which JSON files exist
ls -1 .claude/memory/*.json

# You should have:
# - active-context.json
# - decision-log.json
# - patterns.json
# - progress.json
```

**If files are missing:**
```bash
# Copy the templates
cp templates/memory/*.json .claude/memory/
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep -A 10 "Memory JSON files"
```

---

### 6. "Skills folder not found"

**Cause:** The `.claude/skills/` directory does not exist.

**Solution:**
```bash
# Check if it exists
ls -la .claude/skills/

# If it doesn't exist, create it:
mkdir -p .claude/skills/
```

**Debug:**
```bash
bash scripts/verify-system.sh --debug 2>&1 | grep "skills"
```

---

### 7. Bash syntax errors

**Symptoms:**
```
verify-system.sh: line X: syntax error near unexpected token 'Y'
```

**Cause:** Syntax error in the script (unclosed parentheses, quotes, or structures).

**Solution:**
```bash
# Check the script syntax
bash -n scripts/verify-system.sh

# If there is an error, check the indicated line
sed -n 'X,Xp' scripts/verify-system.sh  # where X is the line number
```

**Common errors:**
- `fi` without corresponding `if`
- `done` without corresponding `for`/`while`
- Unclosed quotes
- Unbalanced parentheses

---

### 8. "command not found: grep/find/ls"

**Cause:** Basic commands are not in PATH.

**Solution:**
```bash
# Check your PATH
echo $PATH

# Use absolute paths if needed
/bin/ls -1 .claude/memory/*.json
```

---

## Manual Verification Step by Step

If the script fails completely, you can verify manually:

### 1. Directory structure
```bash
# Check that the main directories exist
test -d .claude/steering/agents && echo "✅ Agents" || echo "❌ Agents"
test -d .claude/memory && echo "✅ Memory" || echo "❌ Memory"
test -d .claude/skills && echo "✅ Skills" || echo "❌ Skills"
test -d scripts && echo "✅ Scripts" || echo "❌ Scripts"
```

### 2. Configuration files
```bash
# Check critical files
test -f config/betteragents.json && echo "✅ Config" || echo "❌ Config"
test -f .gitignore && echo "✅ Gitignore" || echo "❌ Gitignore"
```

### 3. Agents
```bash
# Count agents
ls -1 .claude/agents/*.md 2>/dev/null | wc -l
# Should show: 13
```

### 4. Memory
```bash
# Count JSON files
find .claude/memory -maxdepth 1 -name "*.json" -type f | wc -l
# Should show: 4
```

### 5. Skills
```bash
# Count skills
ls -1 .claude/skills/ 2>/dev/null | wc -l
# Should show: 56 (or however many you have installed)
```

---

## Logs and Advanced Diagnostics

### Save complete output
```bash
bash scripts/verify-system.sh --debug > verify-output.log 2>&1
```

### Search for specific errors
```bash
# Find lines with ERROR
grep -i "error" verify-output.log

# Find lines with WARNING
grep -i "warning" verify-output.log

# Show only sections with issues
grep -E "❌|⚠️" verify-output.log
```

### Verify permissions
```bash
# Check that scripts are executable
ls -la scripts/*.sh

# If they're not executable:
chmod +x scripts/*.sh
```

---

## Troubleshooting by Section

### Section 1: File Structure
- Check `.claude/agents/`
- Check `.claude/memory/`
- Check `.claude/skills/`

### Section 2: Agent Analysis
- Review format of each `.md` file
- Check `## Role` and `## Expertise` headers
- For agentx: check `## ROLE DEFINITION`

### Section 3: Recommended Skills
- Look for `npx skills add` commands in agent files
- Check correct syntax (with space, not `skillsadd`)

### Section 4: Installed Skills
- Check `.claude/skills/` exists
- Count subdirectories in `.claude/skills/`

### Sections 5-9: Other verifications
- Use `--debug` to see what is being checked
- Review specific paths and files mentioned

---

## Contact and Support

If after following this guide you still have issues:

1. Run: `bash scripts/verify-system.sh --debug > debug.log 2>&1`
2. Review `debug.log` to identify the exact problem
3. Look up the error in this guide
4. If no solution is found, report the issue with the complete log

---

**Last updated:** 2026-02-16
