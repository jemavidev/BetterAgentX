# Memory Tools Usage Guide

## Semantic Memory Scripts (AgentX writes, sub-agents never write)

Three dedicated scripts handle all semantic memory writes. Each is atomic (tmp + mv), validates inputs, and updates summary counters automatically.

### add-task.sh — Tasks & Work Tracking

```bash
bash .claude/scripts/add-task.sh <id> "<title>" <status> <agent> [description] [priority]
```

| Arg | Required | Values |
|-----|----------|--------|
| id | ✅ | `TASK-NN` format |
| title | ✅ | quoted string |
| status | ✅ | `todo` `in-progress` `blocked` `completed` `cancelled` |
| agent | ✅ | agent name (e.g. `coder`, `agentx`) |
| description | optional | longer explanation |
| priority | optional | `critical` `high` `medium` `low` (default: medium) |

**When to call:** immediately after a sub-agent dispatch completes.

### add-decision.sh — Architectural Decisions

```bash
bash .claude/scripts/add-decision.sh <id> "<title>" "<rationale>" <agent> [status]
```

| Arg | Required | Values |
|-----|----------|--------|
| id | ✅ | `DEC-NN` format |
| title | ✅ | short decision name |
| rationale | ✅ | why this decision was made |
| agent | ✅ | who made the decision |
| status | optional | `proposed` `approved` `implemented` (default) `rejected` `superseded` |

**When to call:** after any Architect or Critic decision.

### add-pattern.sh — Reusable Patterns

```bash
bash .claude/scripts/add-pattern.sh "<name>" <category> "<description>" [agent]
```

| Arg | Required | Values |
|-----|----------|--------|
| name | ✅ | kebab-case name |
| category | ✅ | `architectural` `design` `implementation` `testing` `deployment` `security` |
| description | ✅ | what the pattern does |
| agent | optional | who identified it |

**When to call:** when a pattern is identified or used 2+ times.

---

## Automatic Memory (hooks — no action needed)

| File | Updated by | Trigger |
|------|-----------|---------|
| `llm-usage.json` | `on-session-stop.sh` | Session end |
| `session-last.md` | `on-session-stop.sh` | Session end |
| `active-context.json` | `on-file-change.sh` | Every Write/Edit |
| `.memory-debt.md` | `on-session-stop.sh` | When semantic files empty after work |

---

## Statistics & Diagnostics

```bash
bash .claude/scripts/memory-stats.sh     # Entry counts + token usage
bash .claude/scripts/audit-memory.sh    # Documentation balance check
```

---

## Workflow: AgentX Memory Protocol

```
1. Dispatch agent
2. Agent completes work
3. AgentX runs:
   bash .claude/scripts/add-task.sh TASK-NN "..." completed <agent>
4. If a decision was made:
   bash .claude/scripts/add-decision.sh DEC-NN "..." "..." architect
5. If a pattern was identified:
   bash .claude/scripts/add-pattern.sh "..." architectural "..."
6. Show: 💾 Memory Update: [file] — [description]
```

**Rule:** Write IMMEDIATELY — not at end of session.

---

## Troubleshooting

### Script fails with "jq not found"

```bash
sudo apt install jq
```

### Script fails with "file not found"

```bash
ls .claude/memory/progress.json   # verify path
```

### JSON corrupted after manual edit

```bash
jq empty .claude/memory/progress.json && echo "OK" || echo "INVALID"
git checkout HEAD -- .claude/memory/progress.json   # restore from git
```

### Memory debt warning appears at session start

Previous session left `progress.json` and `decision-log.json` empty despite significant git changes.
Log the missing entries now with `add-task.sh` / `add-decision.sh`.

---

**Version:** 2.0.0
**Last Updated:** 2026-02-27
**Related:** quick-reference.md, dashboard-auto-update.md
