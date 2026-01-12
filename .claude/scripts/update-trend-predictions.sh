#!/bin/bash
# update-trend-predictions.sh — Recalculate trend-predictions.json from historical data
# Reads:  historical-data.json, metrics-analytics.json, token-accounting.json
# Writes: trend-predictions.json
# Called by: on-session-stop.sh (after update-metrics.sh, needs fresh metrics)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.claude/memory"

[ -d "$MEMORY_DIR" ] || exit 0
command -v jq &>/dev/null || { echo "❌ jq required"; exit 1; }

HISTORICAL="$MEMORY_DIR/historical-data.json"
METRICS="$MEMORY_DIR/metrics-analytics.json"
TOKEN_ACC="$MEMORY_DIR/token-accounting.json"
PREDICTIONS="$MEMORY_DIR/trend-predictions.json"
NOW=$(date -Iseconds)

[ -f "$HISTORICAL" ]   || { echo "⚠️  historical-data.json missing, skipping"; exit 0; }
[ -f "$PREDICTIONS" ]  || { echo "⚠️  trend-predictions.json missing, skipping"; exit 0; }

echo "🔄 update-trend-predictions: computing from $(jq '.tokenHistory | length' "$HISTORICAL") data points..."

# ── Load sources ──────────────────────────────────────────────────────────────
HIST_DATA=$(cat "$HISTORICAL")
METRICS_DATA=$([ -f "$METRICS" ] && cat "$METRICS" || echo '{}')
TOKEN_DATA=$([ -f "$TOKEN_ACC" ] && cat "$TOKEN_ACC" || echo '{}')

# ── Compute trends in one jq pass ────────────────────────────────────────────
COMPUTED=$(jq -n \
    --argjson hist    "$HIST_DATA" \
    --argjson metrics "$METRICS_DATA" \
    --argjson tokens  "$TOKEN_DATA" \
    '
    def safe_div(a;b): if b > 0 then a / b else 0 end;
    def pct_chg(old;new): if old > 0 then ((new - old) * 100 / old | floor) else 0 end;

    def history: $hist.tokenHistory // [];
    def n: history | length;

    # Trend direction from last N vs prior N values (slope sign)
    def trend_dir(field; window):
        if n < 2 then "stable"
        else
            (history | .[-window:] | map(.[field] // 0) | ((add // 0) / length)) as $recent |
            (history | .[-(window*2):-window] | if length > 0 then (map(.[field] // 0) | ((add // 0) / length)) else $recent end) as $prior |
            if $recent > $prior * 1.05 then "improving"
            elif $recent < $prior * 0.95 then "degrading"
            else "stable" end
        end;

    # Confidence based on data points available
    def confidence:
        if n >= 14 then "high"
        elif n >= 7  then "medium"
        elif n >= 3  then "low"
        else "insufficient" end;

    # Latest values
    def latest: history | last // {};
    def avg_recent(field; w): history | .[-w:] | map(.[field] // 0) | (if length > 0 then ((add // 0) / length) else 0 end | floor);

    # Token runway from token-accounting projections
    def runway: $tokens.projections.estimatedRunwayDays // 999;
    def utilization: $tokens.metadata.utilizationPercent // 0;
    def remaining: $tokens.metadata.totalTokensRemaining // 200000;

    # Efficiency
    def cur_eff: $metrics.efficiency.tokenReductionPercent // (latest.tokenReduction // 0);
    def eff_trend: trend_dir("tokenReduction"; 5);

    # Session avg trend
    def cur_session: avg_recent("avgSessionTokens"; 5);
    def session_trend: trend_dir("avgSessionTokens"; 5);

    {
        n:             n,
        confidence:    confidence,
        cur_eff:       cur_eff,
        eff_trend:     eff_trend,
        cur_session:   cur_session,
        session_trend: session_trend,
        runway:        runway,
        utilization:   utilization,
        remaining:     remaining,
        # Projected efficiency in 30d (linear extrapolation, capped 0-95)
        proj_eff_30d: (
            if n >= 3 then
                (cur_eff + (pct_chg(avg_recent("tokenReduction";3); cur_eff) * 0.5) | floor |
                if . > 95 then 95 elif . < 0 then 0 else . end)
            else cur_eff end
        ),
        # Projected session tokens in 30d
        proj_session_30d: (
            if n >= 3 then
                (cur_session + (cur_session * pct_chg(avg_recent("avgSessionTokens";3); cur_session) / 100) | floor |
                if . < 1000 then 1000 else . end)
            else cur_session end
        )
    }
    ')

if [ -z "$COMPUTED" ]; then
    echo "  ❌ jq computation failed"; exit 1
fi

N=$(echo "$COMPUTED" | jq '.n')
CONF=$(echo "$COMPUTED" | jq -r '.confidence')
EFF=$(echo "$COMPUTED" | jq '.cur_eff')
EFF_TREND=$(echo "$COMPUTED" | jq -r '.eff_trend')
RUNWAY=$(echo "$COMPUTED" | jq '.runway')
UTIL=$(echo "$COMPUTED" | jq '.utilization')
REMAINING=$(echo "$COMPUTED" | jq '.remaining')
PROJ_EFF=$(echo "$COMPUTED" | jq '.proj_eff_30d')
CUR_SES=$(echo "$COMPUTED" | jq '.cur_session')
SES_TREND=$(echo "$COMPUTED" | jq -r '.session_trend')

# ── Atomic write to trend-predictions.json ───────────────────────────────────
TMP=$(mktemp)
if jq \
    --arg     now          "$NOW" \
    --argjson n            "$N" \
    --arg     confidence   "$CONF" \
    --argjson eff          "$EFF" \
    --arg     eff_trend    "$EFF_TREND" \
    --argjson runway       "$RUNWAY" \
    --argjson utilization  "$UTIL" \
    --argjson remaining    "$REMAINING" \
    --argjson proj_eff     "$PROJ_EFF" \
    --argjson cur_session  "$CUR_SES" \
    --arg     ses_trend    "$SES_TREND" \
    '
    .lastUpdated                                           = $now |
    .metadata.dataPointsAvailable                         = $n |
    .metadata.confidenceLevel                             = $confidence |

    .tokenRunwayPrediction.currentUtilization             = $utilization |
    .tokenRunwayPrediction.projectedRunwayDays            = $runway |
    .tokenRunwayPrediction.confidence                     = $confidence |
    .tokenRunwayPrediction.status                         = (
        if $runway > 60 then "healthy"
        elif $runway > 14 then "monitor"
        else "critical" end ) |

    .efficiencyPrediction.currentEfficiency               = $eff |
    .efficiencyPrediction.projectedEfficiency30d          = $proj_eff |
    .efficiencyPrediction.trend                           = $eff_trend |
    .efficiencyPrediction.confidence                      = $confidence |
    .efficiencyPrediction.status                          = $eff_trend |

    .qualityTrendPrediction.confidence                    = $confidence |
    .qualityTrendPrediction.status                        = "stable" |

    .safetyMetricsPrediction.trend                        = $ses_trend |
    .safetyMetricsPrediction.confidence                   = $confidence
    ' "$PREDICTIONS" > "$TMP"; then
    mv "$TMP" "$PREDICTIONS"
    echo "  ✅ trend-predictions.json updated (${N} pts, conf=${CONF}, eff=${EFF}%, runway=${RUNWAY}d)"
else
    rm -f "$TMP"
    echo "  ❌ Failed to update trend-predictions.json"
fi

# ── Governance: degradation alerts ──────────────────────────────────────────
# Write to alerts-registry.json when key metrics degrade or hit thresholds
ALERTS="$MEMORY_DIR/alerts-registry.json"
if [ -f "$ALERTS" ]; then
    ALERT_ID="ALERT-$(date +%s)"
    ALERTS_TO_ADD="[]"

    # 1. Efficiency degrading (trend = "degrading")
    if [ "$EFF_TREND" = "degrading" ]; then
        ALERTS_TO_ADD=$(echo "$ALERTS_TO_ADD" | jq \
            --arg id    "$ALERT_ID-eff" \
            --arg now   "$NOW" \
            --argjson eff "$EFF" \
            '. += [{
                "id": $id, "timestamp": $now,
                "level": "warning",
                "title": "Token Efficiency Degrading",
                "message": ("Current efficiency: \($eff)% — trending downward over last 5 sessions"),
                "source": "update-trend-predictions",
                "category": "efficiency",
                "dismissed": false
            }]')
    fi

    # 2. Session token usage increasing (degrading = sessions getting heavier)
    if [ "$SES_TREND" = "degrading" ]; then
        ALERTS_TO_ADD=$(echo "$ALERTS_TO_ADD" | jq \
            --arg id    "$ALERT_ID-ses" \
            --arg now   "$NOW" \
            --argjson ses "$CUR_SES" \
            '. += [{
                "id": $id, "timestamp": $now,
                "level": "warning",
                "title": "Session Token Usage Increasing",
                "message": ("Avg session: \($ses) tokens — trending upward (efficiency loss)"),
                "source": "update-trend-predictions",
                "category": "efficiency",
                "dismissed": false
            }]')
    fi

    # 3. Token runway critical (<14 days)
    if [ "$RUNWAY" -lt 14 ] 2>/dev/null; then
        ALERTS_TO_ADD=$(echo "$ALERTS_TO_ADD" | jq \
            --arg id     "$ALERT_ID-run" \
            --arg now    "$NOW" \
            --argjson run "$RUNWAY" \
            '. += [{
                "id": $id, "timestamp": $now,
                "level": "critical",
                "title": "Token Runway Critical",
                "message": ("Only \($run) days of token budget remaining at current usage rate"),
                "source": "update-trend-predictions",
                "category": "budget",
                "dismissed": false
            }]')
    fi

    # 4. High utilization warning (>75%)
    if [ "$(echo "$UTIL >= 75" | bc 2>/dev/null)" = "1" ]; then
        ALERTS_TO_ADD=$(echo "$ALERTS_TO_ADD" | jq \
            --arg id    "$ALERT_ID-util" \
            --arg now   "$NOW" \
            --argjson u "$UTIL" \
            '. += [{
                "id": $id, "timestamp": $now,
                "level": "warning",
                "title": "High Token Utilization",
                "message": ("Token budget \($u)% consumed — monitor usage"),
                "source": "update-trend-predictions",
                "category": "budget",
                "dismissed": false
            }]')
    fi

    # Only write if we have new alerts
    COUNT=$(echo "$ALERTS_TO_ADD" | jq 'length')
    if [ "$COUNT" -gt 0 ]; then
        TMP=$(mktemp)
        if jq --argjson new "$ALERTS_TO_ADD" \
            '.alerts = ($new + (.alerts // [])) | .alerts = .alerts[0:100]' \
            "$ALERTS" > "$TMP"; then
            mv "$TMP" "$ALERTS"
            echo "  ⚠️  ${COUNT} governance alert(s) written to alerts-registry.json"
        else
            rm -f "$TMP"
        fi
    fi
fi

echo "✅ update-trend-predictions complete"


