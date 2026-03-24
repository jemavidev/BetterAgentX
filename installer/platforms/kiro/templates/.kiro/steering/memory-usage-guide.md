# Memory Usage Guide

BetterAgents memory system lives in `.kiro/memory/`.

## Quick Commands

```bash
# Add a completed task
bash .kiro/scripts/add-task.sh \
  TASK-NN "Title" completed agentx \
  "Outcome description" high "tag1,tag2" 30

# Add an architectural decision
bash .kiro/scripts/add-decision.sh \
  DEC-NN "Title" "Context/problem" architect implemented "tag1,tag2"

# Add a reusable pattern
bash .kiro/scripts/add-pattern.sh \
  "pattern-name" architectural "Problem it solves" \
  agentx "How to apply it" "tag1,tag2"

# Update current focus/phase
bash .kiro/scripts/update-context.sh \
  --focus "Current feature" \
  --objective "One-line goal" \
  --stats-completed N --stats-pending M

# View memory dashboard
bash .kiro/scripts/update-memory.sh status
```

## Memory Files

| File | Purpose | Updated by |
|------|---------|-----------|
| `MEMORY.md` | Index summary | Auto |
| `session-last.md` | Last session summary | Stop hook |
| `active-context.json` | Current state | update-context.sh |
| `decision-log.json` | ADR log | add-decision.sh |
| `progress.json` | Task tracking | add-task.sh |
| `patterns.json` | Patterns | add-pattern.sh |
| `dashboard.html` | Visual UI | Auto |

## When to Write Memory

- After completing any significant task → `add-task.sh`
- After making an architectural choice → `add-decision.sh`
- After identifying a reusable pattern → `add-pattern.sh`
- When focus or phase changes → `update-context.sh`
