#!/bin/bash
# BetterAgents - Session Stop Hook
# Runs at end of Claude Code session (Stop hook)
# Updates: llm-usage.json, project-size.json, memory-stats.json,
#          metrics-analytics.json, token-accounting.json, project-metrics.json,
#          trend-predictions.json, patterns.json (suggestions), alerts-registry.json, dashboard.html
# Usage: Called automatically by .claude/settings.local.json Stop hook

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.claude/memory"

# Run silently — errors must not interrupt the user
exec 2>/dev/null

[ -d "$MEMORY_DIR" ] || exit 0

# ── Step 0: Compute real token estimate from char-count accumulator ───────────
TOKENS_TMP="$MEMORY_DIR/.session-tokens-tmp"
FIXED_OVERHEAD=2386   # CLAUDE.md (~1359) + MEMORY.md (~1027) tokens per session

if [ -f "$TOKENS_TMP" ]; then
    INPUT_CHARS=$(awk '{sum+=$1} END {print sum+0}' "$TOKENS_TMP" 2>/dev/null || echo 0)
    INPUT_TOKENS=$(echo "scale=0; $INPUT_CHARS / 4 + $FIXED_OVERHEAD" | bc 2>/dev/null || echo $FIXED_OVERHEAD)
    rm -f "$TOKENS_TMP"
else
    INPUT_TOKENS=$FIXED_OVERHEAD
fi

# Write session-last.md — anti-amnesia recovery for next session
SESSION_DATE=$(date '+%Y-%m-%d %H:%M')
SESSION_LAST="$MEMORY_DIR/session-last.md"
# Include both modified tracked files AND new untracked files (exclude tmp/archive)
RECENT_FILES=$(cd "$PROJECT_ROOT" && {
  git diff --name-only HEAD 2>/dev/null
  git ls-files --others --exclude-standard 2>/dev/null
} | grep -v 'archive/\|\.session-tokens-tmp\|\.json\.bak' | sort -u | head -12 | sed 's/^/- /' || echo "- (no git changes)")
RECENT_COMMIT=$(cd "$PROJECT_ROOT" && git log --oneline -1 2>/dev/null || echo "(no commits)")

cat > "$SESSION_LAST" <<EOF
# Última sesión — $SESSION_DATE

## Archivos modificados
$RECENT_FILES

## Último commit
$RECENT_COMMIT

## Tokens input estimados (char-count ±20%)
$INPUT_TOKENS tokens de entrada esta sesión

## Estado al finalizar
- Fase actual: ver active-context.json → currentFocus
- Próximos pasos: ver progress.json → pending tasks
- Preferencias: ver workflow-prefs.md

## Para continuar
Leer este archivo + MEMORY.md al inicio de sesión.
EOF

# ── Ordered pipeline (each step feeds into the next) ──────────────────────────

# 1. Track session usage (char-count → llm-usage.json)
if [ -f "$SCRIPT_DIR/track-usage.sh" ]; then
    bash "$SCRIPT_DIR/track-usage.sh" "$INPUT_TOKENS" 2>/dev/null || true
fi

# 2. Calculate project size (file scan → project-size.json)
if [ -f "$SCRIPT_DIR/calculate-project-size.sh" ]; then
    bash "$SCRIPT_DIR/calculate-project-size.sh" 2>/dev/null || true
fi

# 3. Update memory entry counts (→ memory-stats.json)
if [ -f "$SCRIPT_DIR/memory-stats.sh" ]; then
    bash "$SCRIPT_DIR/memory-stats.sh" 2>/dev/null || true
fi

# 3.5 Pattern learning: update applications counters + detect clusters (→ patterns.json)
if [ -f "$SCRIPT_DIR/update-pattern-suggestions.sh" ]; then
    bash "$SCRIPT_DIR/update-pattern-suggestions.sh" 2>/dev/null || true
fi

# 4. Recalculate real metrics from tasks/decisions/patterns (→ metrics-analytics.json, token-accounting.json)
#    MUST run AFTER steps 1-3 (reads llm-usage.json and memory-stats.json)
if [ -f "$SCRIPT_DIR/update-metrics.sh" ]; then
    bash "$SCRIPT_DIR/update-metrics.sh" 2>/dev/null || true
fi

# 5. Consolidate all memory files into project-metrics.json
if [ -f "$SCRIPT_DIR/update-project-metrics.sh" ]; then
    bash "$SCRIPT_DIR/update-project-metrics.sh" 2>/dev/null || true
fi

# 5.5 Recalculate trend predictions from historical data (Phase 3.3)
if [ -f "$SCRIPT_DIR/update-trend-predictions.sh" ]; then
    bash "$SCRIPT_DIR/update-trend-predictions.sh" 2>/dev/null || true
fi

# 6. Regenerate dashboard HTML in background (non-blocking, uses all updated files)
if [ -f "$SCRIPT_DIR/update-dashboard.sh" ]; then
    bash "$SCRIPT_DIR/update-dashboard.sh" 2>/dev/null &
fi

# ── Memory Debt Check: warn if semantic memory is still empty ─────────────────
DEBT_FILE="$MEMORY_DIR/.memory-debt.md"
TASK_COUNT=$(jq '.tasks | length' "$MEMORY_DIR/progress.json" 2>/dev/null || echo 0)
DECISION_COUNT=$(jq '.decisions | length' "$MEMORY_DIR/decision-log.json" 2>/dev/null || echo 0)
PATTERN_COUNT=$(jq '.patterns | length' "$MEMORY_DIR/patterns.json" 2>/dev/null || echo 0)
GIT_CHANGES=$(cd "$PROJECT_ROOT" && git diff --name-only HEAD 2>/dev/null | wc -l || echo 0)

if [ "$GIT_CHANGES" -gt 3 ] && [ "$TASK_COUNT" -eq 0 ] && [ "$DECISION_COUNT" -eq 0 ]; then
    cat > "$DEBT_FILE" <<DEBT
⚠️ MEMORY DEBT DETECTED from session $(date '+%Y-%m-%d %H:%M')
Files changed: $GIT_CHANGES | Tasks logged: $TASK_COUNT | Decisions: $DECISION_COUNT | Patterns: $PATTERN_COUNT

MANDATORY: Before responding to the user, update memory files:
- Completed work → bash .claude/scripts/add-task.sh ...
- Decisions made → bash .claude/scripts/add-decision.sh ...
- Patterns found → bash .claude/scripts/add-pattern.sh ...

Use 'jq .tasks .claude/memory/progress.json' to check current state.
DEBT
fi

exit 0

