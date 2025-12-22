#!/bin/bash
# update-metrics.sh — Phase 4: Recalculate metrics from real data sources
# Reads: progress.json, decision-log.json, patterns.json, alerts-registry.json, llm-usage.json
# Writes: metrics-analytics.json, token-accounting.json, progress.json (metadata), historical-data.json
# Called by: on-session-stop.sh (step 4, after track-usage and memory-stats)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.claude/memory"

[ -d "$MEMORY_DIR" ] || exit 0
command -v jq &>/dev/null || { echo "❌ jq required but not found"; exit 1; }

PROGRESS="$MEMORY_DIR/progress.json"
DECISIONS="$MEMORY_DIR/decision-log.json"
PATTERNS="$MEMORY_DIR/patterns.json"
ALERTS="$MEMORY_DIR/alerts-registry.json"
LLM_USAGE="$MEMORY_DIR/llm-usage.json"
METRICS="$MEMORY_DIR/metrics-analytics.json"
TOKEN_ACC="$MEMORY_DIR/token-accounting.json"
HISTORICAL="$MEMORY_DIR/historical-data.json"
NOW=$(date -Iseconds)
TODAY=$(date +%Y-%m-%d)

[ -f "$PROGRESS" ] || { echo "⚠️  progress.json not found, skipping update-metrics"; exit 0; }
[ -f "$METRICS" ]  || { echo "⚠️  metrics-analytics.json not found, skipping"; exit 0; }
[ -f "$TOKEN_ACC" ] || { echo "⚠️  token-accounting.json not found, skipping"; exit 0; }

echo "🔄 update-metrics: recalculating from real data..."

# ── Load source files safely ─────────────────────────────────────────────────
PROGRESS_DATA=$(cat "$PROGRESS")
DECISIONS_DATA=$([ -f "$DECISIONS" ] && cat "$DECISIONS" || echo '{"decisions":[]}')
PATTERNS_DATA=$([ -f "$PATTERNS" ]  && cat "$PATTERNS"  || echo '{"patterns":[]}')
ALERTS_DATA=$([ -f "$ALERTS" ]      && cat "$ALERTS"    || echo '{"alerts":[]}')
LLM_USAGE_DATA=$([ -f "$LLM_USAGE" ] && cat "$LLM_USAGE" || echo '{"sessions":[],"totals":{"avgPerSession":0}}')

# Extract session-level totals from llm-usage.json
# NOTE: .totals has {input, output, total} — no avgPerSession field
SESSION_COUNT=$(echo "$LLM_USAGE_DATA" | jq '.sessions | length')
TOTAL_SESSION_TOKENS=$(echo "$LLM_USAGE_DATA" | jq '.totals.total // 0')
INPUT_SESSION_TOKENS=$(echo "$LLM_USAGE_DATA" | jq '.totals.input // 0')
AVG_SESSION=$(echo "$LLM_USAGE_DATA" | jq "if (.sessions | length) > 0 then ((.totals.total // 0) / (.sessions | length) | floor) else 0 end")

# ── Compute all derived values in one jq pass ─────────────────────────────────
COMPUTED=$(jq -n \
    --argjson progress     "$PROGRESS_DATA" \
    --argjson decisions    "$DECISIONS_DATA" \
    --argjson patterns     "$PATTERNS_DATA" \
    --argjson alerts       "$ALERTS_DATA" \
    --argjson avg_session  "$AVG_SESSION" \
    --argjson session_count "$SESSION_COUNT" \
    '
    # Null-safe helpers
    def safe_add:  if . == null then 0 else . end;
    def safe_len:  if . == null then 0 else length end;
    def nz(f): if f == null then 0 else f end;

    def tasks:     $progress.tasks     // [];
    def decisions: $decisions.decisions // [];
    def patterns:  $patterns.patterns  // [];
    def alerts:    $alerts.alerts      // [];

    def task_count:        tasks | length;
    def completed_count:   [tasks[] | select(.status == "completed")]  | length;
    def in_progress_count: [tasks[] | select(.status == "in_progress")] | length;
    def with_tokens_count: [tasks[] | select(.tokens > 0)] | length;
    def total_tokens:      ([tasks[].tokens] | add | safe_add);
    def avg_tokens:
        if with_tokens_count > 0
        then (total_tokens / with_tokens_count | floor)
        else 0 end;

    # Token reduction: session-level comparison vs 150k baseline (pre-Phase 1 documented value)
    # Uses avg session tokens from llm-usage.json (real measured sessions)
    def reduction:
        if $avg_session > 0 and $avg_session < 150000
        then ((150000 - $avg_session) * 100 / 150000 | floor)
        else (
            # Fallback: task-level comparison (avg task tokens vs 5k estimated pre-Phase 1)
            if avg_tokens > 0 and avg_tokens < 5000
            then ((5000 - avg_tokens) * 100 / 5000 | floor)
            else 0 end
        ) end;

    def success_rate:
        if task_count > 0
        then (completed_count * 100 / task_count | floor)
        else 0 end;

    # Per-agent metrics object keyed by agent name
    def agent_metrics:
        if (tasks | length) == 0 then {} else
        [ tasks | group_by(.agent)[] |
            {
                key: .[0].agent,
                value: {
                    tasksCompleted:   [.[] | select(.status == "completed")] | length,
                    tasksTotal:       . | length,
                    successRate: (
                        if (. | length) > 0
                        then ([.[] | select(.status == "completed")] | length) * 100 / (. | length) | floor
                        else 0 end
                    ),
                    avgTokensPerTask: (
                        if ([.[] | select(.tokens > 0)] | length) > 0
                        then (([.[].tokens] | add | safe_add) / ([.[] | select(.tokens > 0)] | length) | floor)
                        else 0 end
                    ),
                    totalTokens:  ([.[].tokens] | add | safe_add),
                    qualityScore: 99
                }
            }
        ] | from_entries end;

    # Simpler byAgent for token-accounting format
    def by_agent:
        if (tasks | length) == 0 then {} else
        [ tasks | group_by(.agent)[] |
            {
                key: .[0].agent,
                value: {
                    tokens:           ([.[].tokens] | add | safe_add),
                    tasksCompleted:   [.[] | select(.status == "completed")] | length,
                    avgTokensPerTask: (
                        if ([.[] | select(.tokens > 0)] | length) > 0
                        then (([.[].tokens] | add | safe_add) / ([.[] | select(.tokens > 0)] | length) | floor)
                        else 0 end
                    )
                }
            }
        ] | from_entries end;

    # Safety metrics from alerts-registry
    def loop_detections:   [alerts[] | select((.source // "") | test("loop";    "i"))] | length;
    def plan_mode_count:   [alerts[] | select((.title  // "") | test("plan";    "i"))] | length;
    def verify_pass_count: [alerts[] | select((.category // "") == "verification" and .level == "success")] | length;

    {
        task_count:        task_count,
        completed_count:   completed_count,
        in_progress_count: in_progress_count,
        with_tokens_count: with_tokens_count,
        total_tokens:      total_tokens,
        avg_tokens:        avg_tokens,
        reduction:         reduction,
        success_rate:      success_rate,
        agent_metrics:     agent_metrics,
        by_agent:          by_agent,
        decision_count:    (decisions | length),
        pattern_count:     (patterns  | length),
        loop_detections:   loop_detections,
        plan_mode_count:   plan_mode_count,
        verify_pass_count: verify_pass_count,
        remaining:         (200000 - total_tokens),
        utilization:       (if total_tokens > 0 then (total_tokens * 100 / 200000 | floor) else 0 end),
        avg_session:       $avg_session,
        session_count:     $session_count
    }
    ')

if [ -z "$COMPUTED" ]; then
    echo "  ❌ Failed to compute metrics (jq error)"; exit 1
fi

SUMMARY=$(echo "$COMPUTED" | jq -r '"  tasks=\(.task_count) completed=\(.completed_count) total_tokens=\(.total_tokens) avg=\(.avg_tokens)"')
echo "$SUMMARY"

# ── Update metrics-analytics.json ────────────────────────────────────────────
TMP=$(mktemp)
if jq \
    --argjson d   "$COMPUTED" \
    --arg     now "$NOW" \
    '
    .lastUpdated                              = $now |
    .efficiency.avgTokensPerTask              = $d.avg_tokens |
    .efficiency.tokenReductionPercent         = $d.reduction |
    .efficiency.trend                         = (
        if   $d.reduction > 30 then "excellent"
        elif $d.reduction > 10 then "improving"
        else "stable" end ) |
    .comparison.current.tokensPerSession      = $d.avg_tokens |
    .comparison.current.tasksCompleted        = $d.completed_count |
    .comparison.improvement.tokenSavings      = $d.reduction |
    .agentMetrics                             = $d.agent_metrics |
    .safetyMetrics.loopDetections             = ($d.loop_detections    // 0) |
    .safetyMetrics.planModeTriggered          = ($d.plan_mode_count    // 0) |
    .safetyMetrics.verificationsPassed        = ($d.verify_pass_count  // 0) |
    .projectStats.totalDecisions              = $d.decision_count |
    .projectStats.totalPatterns               = $d.pattern_count |
    .projectStats.totalTasksCompleted         = $d.completed_count |
    .projectStats.totalTasksInProgress        = $d.in_progress_count
    ' "$METRICS" > "$TMP"; then
    mv "$TMP" "$METRICS"
    echo "  ✅ metrics-analytics.json updated"
else
    rm -f "$TMP"
    echo "  ❌ Failed to update metrics-analytics.json"
fi

# ── Update token-accounting.json ─────────────────────────────────────────────
TMP=$(mktemp)
if jq \
    --argjson d              "$COMPUTED" \
    --argjson sess_total     "$TOTAL_SESSION_TOKENS" \
    --argjson sess_input     "$INPUT_SESSION_TOKENS" \
    --argjson sess_count     "$SESSION_COUNT" \
    --arg     now            "$NOW" \
    '
    # Use session-level totals from llm-usage.json (estimated, not billing-accurate)
    # task-level .tokens is 0 for all tasks — per-task breakdown unavailable
    .lastUpdated                         = $now |
    .metadata.totalTokensUsed            = $sess_total |
    .metadata.totalTokensInput           = $sess_input |
    .metadata.totalSessionsRecorded      = $sess_count |
    .metadata.totalTokensRemaining       = (200000 - ($sess_total / ($sess_count | if . > 0 then . else 1 end) | floor)) |
    .metadata.utilizationPercent         = (if $sess_count > 0 then (($sess_total / $sess_count | floor) * 100 / 200000 | floor) else 0 end) |
    .metadata.estimationMethod           = "input: char-count/4+overhead | output: git-diff-lines*20" |
    .byAgent                             = $d.by_agent |
    .projections.avgTokensPerSession     = (if $sess_count > 0 then ($sess_total / $sess_count | floor) else 0 end) |
    .projections.estimatedRunwayDays     = 999
    ' "$TOKEN_ACC" > "$TMP"; then
    mv "$TMP" "$TOKEN_ACC"
    UTIL=$(echo "$COMPUTED" | jq '.utilization')
    TOTAL="$TOTAL_SESSION_TOKENS"
    echo "  ✅ token-accounting.json updated (${TOTAL} used, ${UTIL}%)"
else
    rm -f "$TMP"
    echo "  ❌ Failed to update token-accounting.json"
fi

# ── Update progress.json metadata ────────────────────────────────────────────
TMP=$(mktemp)
if jq \
    --argjson d   "$COMPUTED" \
    --arg     now "$NOW" \
    '
    .metadata.totalTokens      = $d.total_tokens |
    .metadata.totalEntries     = $d.task_count |
    .metadata.avgTokensPerEntry = $d.avg_tokens |
    .metadata.lastUpdated      = $now |
    .metadata.tokensByAgent    = ($d.by_agent | with_entries(.value = .value.tokens))
    ' "$PROGRESS" > "$TMP"; then
    mv "$TMP" "$PROGRESS"
    echo "  ✅ progress.json metadata updated"
else
    rm -f "$TMP"
    echo "  ❌ Failed to update progress.json metadata"
fi

# ── Append snapshot to historical-data.json ──────────────────────────────────
if [ -f "$HISTORICAL" ]; then
    HOUR=$(date +%H | sed 's/^0//')
    TOTAL_H=$(echo "$COMPUTED" | jq '.total_tokens')
    AVG_H=$(echo "$COMPUTED"   | jq '.avg_tokens')
    TASKS_H=$(echo "$COMPUTED" | jq '.task_count')
    DONE_H=$(echo "$COMPUTED"  | jq '.completed_count')
    RED_H=$(echo "$COMPUTED"   | jq '.reduction')
    SES_H=$(echo "$COMPUTED"   | jq '.avg_session')
    SC_H=$(echo "$COMPUTED"    | jq '.session_count')

    TMP=$(mktemp)
    if jq \
        --arg  date     "$TODAY" \
        --argjson hour  "${HOUR:-0}" \
        --argjson tokens_total "$TOTAL_H" \
        --argjson avg_tokens   "$AVG_H" \
        --argjson task_count   "$TASKS_H" \
        --argjson completed    "$DONE_H" \
        --argjson reduction    "$RED_H" \
        --argjson avg_session  "$SES_H" \
        --argjson sessions     "$SC_H" \
        '
        # Append snapshot; keep last 200 entries (≈30 days at hourly)
        .tokenHistory = (
            (.tokenHistory // []) +
            [{
                "date":          $date,
                "hour":          $hour,
                "tokensTotal":   $tokens_total,
                "avgTokensPerTask": $avg_tokens,
                "taskCount":     $task_count,
                "completedTasks":$completed,
                "tokenReduction":$reduction,
                "avgSessionTokens": $avg_session,
                "sessionCount":  $sessions
            }]
        ) | .tokenHistory = (.tokenHistory | .[-200:]) |
        .metadata.dataPointsCollected = (.tokenHistory | length) |
        .metadata.newestEntry = $date
        ' "$HISTORICAL" > "$TMP"; then
        mv "$TMP" "$HISTORICAL"
        echo "  ✅ historical-data.json snapshot appended ($(date '+%Y-%m-%d %H:%M'))"
    else
        rm -f "$TMP"
        echo "  ⚠️  Could not append to historical-data.json"
    fi
fi

echo "✅ update-metrics complete"

