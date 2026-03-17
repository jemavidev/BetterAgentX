# 🧠 BetterAgents Memory System

The memory system gives AgentX **persistent context** across sessions — decisions, tasks, patterns, and project state survive between conversations.

---

## Memory Files

All files live in `.claude/memory/`:

| File | Format | Purpose | Updated by |
|------|--------|---------|-----------|
| `MEMORY.md` | Markdown | Auto-loaded summary — always in Claude's context | AgentX / hooks |
| `session-last.md` | Markdown | Last session summary — read on every startup | `on-session-stop.sh` |
| `active-context.json` | JSON | Current project state (version, focus, stack) | `on-file-change.sh` |
| `decision-log.json` | JSON | Architecture decisions (ADR format) | `add-decision.sh` |
| `progress.json` | JSON | Task tracking | `add-task.sh` |
| `patterns.json` | JSON | Reusable patterns and solutions | `add-pattern.sh` |
| `llm-usage.json` | JSON | Session activity log — `activity.files` (array of `{path, added, removed}` objects), `activity.prompts` (array of user inputs), `activity.firstPrompt`, `activity.lastCommit` | `track-usage.sh` |
| `token-accounting.json` | JSON | Token usage breakdown per component | `on-session-stop.sh` |
| `metrics-analytics.json` | JSON | Efficiency and quality metrics | `on-session-stop.sh` |
| `alerts-registry.json` | JSON | Live alerts and alert rules | `on-session-stop.sh` |
| `memory-stats.json` | JSON | File size breakdown | `memory-stats.sh` |
| `project-metrics.json` | JSON | Project size, complexity | `update-project-metrics.sh` |
| `dashboard.html` | HTML | Interactive web UI | Installer |

---

## Writing to Memory

AgentX writes to memory using three mandatory helper scripts:

### Add a Task

```bash
bash .claude/scripts/add-task.sh \
  <id> "<title>" <status> <agent> "<outcome>" <priority> "<tags>" <duration_minutes>
```

| Argument | Values |
|----------|--------|
| `status` | `todo` \| `in-progress` \| `blocked` \| `completed` \| `cancelled` |
| `priority` | `critical` \| `high` \| `medium` (default) \| `low` |
| `outcome` | Specific result: files changed, root cause found, approach used |
| `tags` | Comma-separated string |
| `duration_minutes` | Estimated or actual minutes |

```bash
# Examples
bash .claude/scripts/add-task.sh TASK-01 "Implement JWT auth" completed coder \
  "Added auth middleware in src/middleware/auth.js" high "auth,security" 45
bash .claude/scripts/add-task.sh TASK-02 "Dashboard UI dark theme" in-progress ux-designer \
  "Dark theme tokens added to tailwind.config.js" high "ui,theme" 30
```

### Add a Decision

```bash
bash .claude/scripts/add-decision.sh \
  <id> "<title>" "<context>" <agent> <status> "<tags>"
```

| Argument | Values |
|----------|--------|
| `context` | The problem that forced this decision (not the solution) |
| `agent` | `architect` \| `critic` \| `agentx` \| etc. |
| `status` | `proposed` \| `approved` \| `implemented` (default) \| `rejected` \| `superseded` |
| `tags` | Comma-separated string |

```bash
# Examples
bash .claude/scripts/add-decision.sh DEC-01 "Use JWT auth" \
  "Need stateless auth that scales horizontally without session store" architect implemented "auth,security"
bash .claude/scripts/add-decision.sh DEC-02 "PostgreSQL over MongoDB" \
  "Data has relational structure requiring ACID transactions" architect implemented "database"
```

### Add a Pattern

```bash
bash .claude/scripts/add-pattern.sh \
  "<kebab-case-name>" <category> "<problem>" <agent> "<solution>" "<tags>"
```

| Argument | Categories |
|----------|-----------|
| `category` | `architectural` \| `implementation` \| `testing` \| `deployment` \| `security` \| `design` |
| `problem` | The problem this pattern solves |
| `solution` | Concrete implementation approach |

```bash
# Examples
bash .claude/scripts/add-pattern.sh "repository-pattern" architectural \
  "Tight coupling between data access and business logic" architect \
  "Wrap DB calls in a repository class with a consistent interface" "architecture,db"
bash .claude/scripts/add-pattern.sh "jwt-refresh-rotation" security \
  "Refresh tokens can be reused after theft" security \
  "Invalidate old refresh token on each use, issue new one" "auth,security"
```

---

## Atomic Write Pattern

All three scripts use atomic writes to prevent corruption:

```bash
jq '.key += [...]' file.json > /tmp/_mem_tmp.json && mv /tmp/_mem_tmp.json file.json
```

---

## Memory Debt System

If a session ends with significant code changes (>3 git-changed files) but no tasks or decisions were logged, the hook system writes a **memory debt** reminder.

**Detection** (`on-session-stop.sh`):
- Counts `GIT_CHANGES`, `TASK_COUNT`, `DECISION_COUNT`
- If `GIT_CHANGES > 3` AND `TASK_COUNT == 0` AND `DECISION_COUNT == 0` → writes `.claude/memory/.memory-debt.md`

**Injection** (`on-user-prompt.sh`):
- At next session start, debt reminder is printed to conversation and file is deleted.

---

## Dashboard

### Start (Node.js — recommended)

```bash
bash .claude/scripts/start-dashboard.sh
# Opens at http://localhost:3000
```

### Start (Docker)

```bash
docker compose up -d
# Opens at http://localhost:<PORT>  (see .env)
```

### Dashboard Tabs

| Tab | Data source |
|-----|------------|
| DECISIONS | `decision-log.json` |
| TAREAS | `progress.json` |
| PATRONES | `patterns.json` |
| CONTEXTO | `active-context.json` |
| TOKENS | `token-accounting.json` |
| MÉTRICAS | `metrics-analytics.json` |

Alerts overlay from `alerts-registry.json` — 4 levels: INFO, WARNING, ERROR, CRITICAL.
Auto-refresh every 30 seconds.

The SAFETY tab Session Activity shows:
- Files modified per session with per-file `+added / -removed` line counts and heat-map background colors:
  - Green (`rgba(16,185,129,0.08)`) — fewer than 10 lines total (small change)
  - Yellow (`rgba(245,158,11,0.12)`) — 10–50 lines (moderate)
  - Red (`rgba(239,68,68,0.12)`) — more than 50 lines (large change)
  - Purple (`rgba(139,92,246,0.15)`) — more than 200 lines, or removed/added ratio above 70% (rewrite)
- Token distribution bar — input vs output percentage with raw totals
- Last git commit message for the session
- Decisions and tasks logged on the same date, correlated from `decision-log.json` and `progress.json`
- Clickable session cards that open a modal with the full list of user prompts from that session

### llm-usage.json Schema

`track-usage.sh` writes a `sessions[]` entry at the end of each session. The `activity` field uses this format:

```json
{
  "activity": {
    "filesChanged": 14,
    "files": [
      {"path": "path/to/file.sh", "added": 38, "removed": 5},
      {"path": "path/to/other.md", "added": 12, "removed": 0}
    ],
    "lastCommit": "abc1234 commit message",
    "firstPrompt": "first user input text",
    "prompts": ["first user input text", "second user input text"]
  }
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `filesChanged` | number | Total count of files modified in the session |
| `files` | array of objects | One entry per file: `path` (string), `added` (lines added), `removed` (lines removed). Untracked files have `removed: 0`. Binary files have `added: 0, removed: 0`. |
| `lastCommit` | string | Short hash + message of the last git commit |
| `firstPrompt` | string | Text of the first user message in the session |
| `prompts` | array of strings | All user prompts captured during the session (via `on-user-prompt.sh`) |

Backwards compatible: sessions recorded before this format still render correctly — the dashboard accepts both `files` as an array of strings (old) and as an array of objects (new).

**How prompts are captured:**

The `on-user-prompt.sh` hook fires on each `UserPromptSubmit` event, strips XML tags from the input, and appends the cleaned text to `.session-prompts-tmp`. At session end, `track-usage.sh` reads that file and stores the contents as `activity.firstPrompt` and `activity.prompts`.

---

## Multi-Project Dashboard

A single central container serves N projects simultaneously:

```bash
# Each project auto-registers on install.
# All projects visible at http://localhost:3000 (project selector dropdown).

# Unregister a project:
bash installer/install.sh --unregister
# or (repo-based):
bash scripts/init.sh --unregister
```

### Managing Projects

**Add a project:**
```bash
bash installer/.claude/scripts/generate-central-compose.sh \
  "<project-name>" "<absolute-path>/.claude/memory"
docker compose -f ~/.betteragents/docker-compose.yml down && \
docker compose -f ~/.betteragents/docker-compose.yml up -d
```

**Remove a project:**
```bash
bash installer/.claude/scripts/generate-central-compose.sh \
  "<project-name>" "" --unregister
docker compose -f ~/.betteragents/docker-compose.yml down && \
docker compose -f ~/.betteragents/docker-compose.yml up -d
# Or from the project itself:
bash installer/install.sh --unregister
```

---

## Hook Automation

| Hook | Trigger | Script | Action |
|------|---------|--------|--------|
| `UserPromptSubmit` | Each user message | `on-user-prompt.sh` | Inject debt reminder; capture prompt text to `.session-prompts-tmp` |
| `PreToolUse (EnterPlanMode)` | Plan mode | `on-plan-mode.sh` | Log trigger |
| `PostToolUse (Write/Edit)` | File written | `on-file-change.sh` | Update context timestamp |
| `PostToolUse (Write/Edit)` | File written | `on-file-write-verification.sh` | Syntax verification |
| `PostToolUse (Bash)` | Bash runs | `on-bash-change.sh` | Rebuild dashboard |
| `Stop` | Session ends | `on-session-stop.sh` | Write session summary, check debt |

---

## Reset Memory

```bash
bash reset-memory.sh           # Reset session data only
bash reset-memory.sh --full    # Full reset
```

---

## Related

- [Quick Reference](./quick-reference.md) — Commands cheat sheet
- [Tools Usage Guide](./tools-usage-guide.md) — Detailed guide
- [Dashboard Architecture](./dashboard-architecture.md) — Technical design
