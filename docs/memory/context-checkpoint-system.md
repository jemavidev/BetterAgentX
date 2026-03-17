# Context Checkpoint System

## Overview

Automatic checkpoint system that tracks your project state and lets you resume work easily.

## How It Works

### Automatic Updates

The system updates `active-context.json` automatically after every agent execution via hook:

**What gets captured:**
- Current focus (last task you worked on)
- Recent tasks (last 5)
- Recent decisions (last 3)
- Active patterns (last 3)
- Progress stats (pending/completed)
- Last update timestamp

**When it updates:**
- After completing a task
- After making a decision
- After identifying a pattern
- Whenever AgentX finishes execution

### Manual Check

When you resume work, check where you left off:

```bash
bash .claude/scripts/quick-dashboard.sh
```

**Output shows:**
- 🕐 Last update time
- 🎯 What you were working on
- 📊 Progress (completed/pending tasks)
- 📝 Recent work
- 💡 Recent decisions
- ⚠️ Blockers (if any)
- 🚀 Next steps (if defined)

## Usage Scenarios

### Scenario 1: Starting Your Day

```bash
# Check where you left off yesterday
bash .claude/scripts/quick-dashboard.sh

# Output:
# 🎯 Current Focus: Dashboard auto-update system
# ✅ Completed: 7 tasks
# ⏳ Pending: 0 tasks
```

### Scenario 2: After a Break

```bash
# Quick checkpoint
bash .claude/scripts/quick-dashboard.sh

# See what you were doing
# Continue from there
```

### Scenario 3: Switching Projects

```bash
# Context is project-specific
cd /path/to/project-a
bash .claude/scripts/quick-dashboard.sh  # Shows project A context

cd /path/to/project-b
bash .claude/scripts/quick-dashboard.sh  # Shows project B context
```

### Scenario 4: Team Handoff

```bash
# Share context with team member
bash .claude/scripts/quick-dashboard.sh > project-status.txt

# Or open dashboard for visual view
bash .claude/scripts/start-dashboard.sh
```

## What Gets Tracked

### Automatically Captured

```json
{
  "lastUpdated": "2026-02-18T07:27:10-05:00",
  "currentFocus": {
    "feature": "Last task you worked on",
    "objective": "Continue work on current tasks"
  },
  "context": {
    "recentDecisions": [...],  // Last 3 decisions
    "activePatterns": [...],   // Last 3 patterns
    "recentTasks": [...],      // Last 5 tasks
    "stats": {
      "pendingTasks": 0,
      "completedTasks": 7,
      "lastUpdate": "2026-02-18 07:27:10"
    }
  }
}
```

### Manually Added (Optional)

You can manually add:
- Blockers
- Next steps
- Project description
- Tech stack details
- Team information

**Edit directly:**
```bash
code .claude/memory/active-context.json
```

## Configuration

### Hook Settings

Located at: `.claude/scripts/auto-update-context.claude hook`

```json
{
  "enabled": true,
  "name": "Auto-Update Project Context",
  "when": {
    "type": "agentStop"
  },
  "then": {
    "type": "runCommand",
    "command": "bash scripts/update-context.sh",
    "timeout": 5
  }
}
```

### Disable Auto-Update

If you want manual control only:

```bash
# Disable hook
# Edit .claude/scripts/auto-update-context.claude hook
# Set "enabled": false
```

## Commands Reference

### View Context
```bash
bash .claude/scripts/quick-dashboard.sh
```

### Force Update
```bash
bash scripts/update-context.sh
```

### View in Dashboard
```bash
bash .claude/scripts/start-dashboard.sh
# Click "Context" tab
```

### Edit Manually
```bash
code .claude/memory/active-context.json
```

## Benefits

✅ **Never lose track** - Always know where you left off
✅ **Quick resume** - Start working immediately
✅ **Team visibility** - Share project state easily
✅ **Automatic** - No manual updates needed
✅ **Lightweight** - Updates in <1 second

## Troubleshooting

### Context not updating

```bash
# Check hook is enabled
cat .claude/scripts/auto-update-context.claude hook | jq '.enabled'

# Should return: true

# Manually trigger update
bash scripts/update-context.sh
```

### Context shows old data

```bash
# Force update
bash scripts/update-context.sh

# Check timestamp
bash .claude/scripts/quick-dashboard.sh | grep "Last Updated"
```

### Want to reset context

```bash
# Copy template
cp templates/memory/active-context.json .claude/memory/active-context.json

# Or let it auto-populate
bash scripts/update-context.sh
```

## Integration with Dashboard

The Context tab in the dashboard shows:
- Project overview
- Current focus
- Recent decisions
- Active patterns
- Open tasks

All automatically populated from the same data.

## Best Practices

1. **Check context when resuming** - Run `quick-dashboard.sh` first thing
2. **Let it auto-update** - Don't disable the hook
3. **Add blockers manually** - If you hit a blocker, add it to the JSON
4. **Define next steps** - Before ending work, add next steps
5. **Use dashboard for details** - Context gives overview, dashboard gives depth

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-18  
**Related:** dashboard-auto-update.md, quick-reference.md
