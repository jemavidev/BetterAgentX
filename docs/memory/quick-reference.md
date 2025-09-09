# Memory Tools Quick Reference

## ✅ Add Semantic Memory Entries (AgentX — use these)

### Add Task (after sub-agent dispatch completes)

```bash
bash .claude/scripts/add-task.sh <id> "<title>" <status> <agent> [description] [priority]
```

**status:** `todo` | `in-progress` | `blocked` | `completed` | `cancelled`
**priority:** `critical` | `high` | `medium` (default) | `low`

```bash
# Examples
bash .claude/scripts/add-task.sh TASK-01 "Implement auth JWT" completed coder
bash .claude/scripts/add-task.sh TASK-02 "Dashboard UI" in-progress ux-designer "Dark theme" high
```

### Add Decision (after Architect/Critic decision)

```bash
bash .claude/scripts/add-decision.sh <id> "<title>" "<rationale>" <agent> [status]
```

**status:** `proposed` | `approved` | `implemented` (default) | `rejected` | `superseded`

```bash
# Examples
bash .claude/scripts/add-decision.sh DEC-01 "Use JWT auth" "Stateless, scalable, no session store needed" architect
bash .claude/scripts/add-decision.sh DEC-02 "PostgreSQL over MongoDB" "Relational data model fits domain better" architect implemented
```

### Add Pattern (when pattern identified or used 2+ times)

```bash
bash .claude/scripts/add-pattern.sh "<name>" <category> "<description>" [agent]
```

**category:** `architectural` | `design` | `implementation` | `testing` | `deployment` | `security`

```bash
# Examples
bash .claude/scripts/add-pattern.sh "atomic-json-write" implementation "Write to tmp then mv to prevent partial writes" agentx
bash .claude/scripts/add-pattern.sh "agent-isolation" architectural "Sub-agents never inherit CLAUDE.md context" agentx
```

---

## 👁️ View Memory

```bash
# Raw JSON
jq '.tasks' .claude/memory/progress.json
jq '.patterns' .claude/memory/patterns.json
jq '.decisions' .claude/memory/decision-log.json

# Entry counts
jq '.tasks | length' .claude/memory/progress.json
jq '.decisions | length' .claude/memory/decision-log.json

# Statistics
bash .claude/scripts/memory-stats.sh
```

---

## 🔧 Advanced Updates

### Manual jq (complex or bulk)

```bash
jq '.tasks += [{"id":"TASK-XX","title":"..."}]' .claude/memory/progress.json \
  > /tmp/_mem.json && mv /tmp/_mem.json .claude/memory/progress.json
```

### Update context/focus

```bash
bash .claude/scripts/update-context.sh
```

---

## 📚 File Locations

```
.claude/memory/
├── progress.json        # Tasks — use add-task.sh
├── decision-log.json    # Decisions — use add-decision.sh
├── patterns.json        # Patterns — use add-pattern.sh
├── active-context.json  # Project state — use update-context.sh
├── llm-usage.json       # Session tokens — auto via hook
├── session-last.md      # Last session summary — auto via hook
└── .memory-debt.md      # Cross-session debt warning — auto via hook
```

---

## 🚨 Troubleshooting

### Entry not appearing

```bash
# Verify it was added
jq '.tasks | length' .claude/memory/progress.json

# Check JSON is still valid
jq empty .claude/memory/progress.json && echo "OK"
```

### Memory debt warning appears at session start

The previous session had >3 git changes but no tasks or decisions logged.
Run `add-task.sh` / `add-decision.sh` to clear the debt.

### JSON corrupted

```bash
# Validate
jq empty .claude/memory/progress.json

# If invalid, restore from git
git checkout HEAD -- .claude/memory/progress.json
```

---

**Version:** 2.0.0
**Last Updated:** 2026-02-27
**See also:** tools-usage-guide.md, dashboard-auto-update.md
