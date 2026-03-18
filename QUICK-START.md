# 🚀 BetterAgents — Quick Start

Get up and running in under 5 minutes.

---

## Prerequisites

- **Claude Code** installed (`claude --version`)
- **jq** (`sudo apt install jq` / `brew install jq`)
- **bash** and **git**

---

## Installation

### Option A — Self-Contained (no clone required)

```bash
# Copy installer into your project, then:
cd /path/to/your-project
bash installer/install.sh

# Open in Claude Code
claude .
```

### Option B — From Repo

```bash
git clone https://github.com/jemavidev/BetterAgentX.git
cd /path/to/your-project
bash /path/to/BetterAgentX/installer/install.sh
claude .
```

That's it. AgentX is now active. Ask anything naturally.

---

## First Steps

```bash
# View memory dashboard
bash .claude/scripts/start-dashboard.sh

# Reset session data (keep decisions/tasks/patterns)
bash reset-memory.sh

# Full reset
bash reset-memory.sh --full
```

### Slash Commands

```
/architect   — System design
/coder       — Implement or debug code
/critic      — Critical analysis / risk review
/security    — Security audit
/tester      — Write or review tests
/ux-designer — UI/UX design
/writer      — Documentation
/memory      — View project memory
/metrics     — Token usage stats
```

---

## Multi-Platform Sync (Claude Code ↔ Kiro)

If you use both Claude Code and Kiro IDE, the `.betteragents/` layer keeps them in sync.

### Detect current platform

```bash
bash .betteragents/sync/detect-platform.sh
```

**Expected output:** `claude-code` or `kiro`

### First-time sync: generate Kiro files from Claude

```bash
node .betteragents/translators/claude-to-kiro.js all
```

**Result:** ~96 files generated in `.kiro/`

### Verify state

```bash
node .betteragents/sync/change-detector.js
node .betteragents/translators/kiro-to-claude.js validate
```

### Bidirectional sync

```bash
# Interactive (recommended)
bash .betteragents/sync/bidirectional-sync.sh

# Auto (no confirmation)
bash .betteragents/sync/bidirectional-sync.sh --auto

# Dry run
bash .betteragents/sync/bidirectional-sync.sh --dry-run
```

### Access memory via bridge

```bash
node .betteragents/sync/memory-bridge.js summary
node .betteragents/sync/memory-bridge.js decisions 5
node .betteragents/sync/memory-bridge.js tasks completed
```

---

## Common Sync Troubleshooting

| Problem | Fix |
|---------|-----|
| "Platform not detected" | `export KIRO_SESSION_ID="manual"` then re-run detect |
| "Validation failed" | `node .betteragents/translators/claude-to-kiro.js all` |
| "Changes not detected" | `rm .betteragents/sync/.sync-cache.json` then retry |
| "Sync conflicts" | Run `--dry-run` first, then interactive mode |

---

## Post-install Verification Checklist

```bash
# Run full verification
bash scripts/verify-system.sh

# Or manually check:
ls .claude/agents/          # Should show 12 agents
ls .claude/commands/ | wc -l  # Should show 79 commands
cat .claude/memory/MEMORY.md  # Should show project context
```

---

**Version:** 4.0.0 | **Docs:** [README.md](README.md) | **Repo:** https://github.com/jemavidev/BetterAgentX
