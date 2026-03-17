#!/bin/bash

# BetterAgents — Memory Reset
# Clears all session data back to clean defaults (preserves MEMORY.md)
# Usage: bash reset-memory.sh [--full]

MEMORY_DIR=".claude/memory"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 BetterAgents — Memory Reset"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -d "$MEMORY_DIR" ]; then
    echo "Memory directory not found. Is BetterAgents installed?"
    exit 1
fi

command -v jq &>/dev/null || { echo "jq required. Install: sudo apt install jq"; exit 1; }

# Reset session/activity data (in-place — safe for Docker bind mounts)
jq '.sessions = [] | .totals = {input: 0, output: 0, total: 0}' \
    "$MEMORY_DIR/llm-usage.json" > /tmp/_ba.json && mv /tmp/_ba.json "$MEMORY_DIR/llm-usage.json"
echo -e "${GREEN}✅ llm-usage.json${NC}        — sessions cleared"

jq '.tokenHistory = [] | .metadata.dataPointsCollected = 0 | .metadata.newestEntry = ""' \
    "$MEMORY_DIR/historical-data.json" > /tmp/_ba.json && mv /tmp/_ba.json "$MEMORY_DIR/historical-data.json"
echo -e "${GREEN}✅ historical-data.json${NC}   — token history cleared"

# --full flag: also reset decisions, tasks, patterns
if [[ "$1" == "--full" ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  Full reset — clearing decisions, tasks, patterns...${NC}"

    jq '.decisions = [] | .summary.totalDecisions = 0' \
        "$MEMORY_DIR/decision-log.json" > /tmp/_ba.json && mv /tmp/_ba.json "$MEMORY_DIR/decision-log.json"
    echo -e "${GREEN}✅ decision-log.json${NC}     — decisions cleared"

    jq '.tasks = []' \
        "$MEMORY_DIR/progress.json" > /tmp/_ba.json && mv /tmp/_ba.json "$MEMORY_DIR/progress.json"
    echo -e "${GREEN}✅ progress.json${NC}         — tasks cleared"

    jq '.patterns = [] | .summary.totalPatterns = 0' \
        "$MEMORY_DIR/patterns.json" > /tmp/_ba.json && mv /tmp/_ba.json "$MEMORY_DIR/patterns.json"
    echo -e "${GREEN}✅ patterns.json${NC}         — patterns cleared"
fi

# Regenerate memory stats
if [ -f ".claude/scripts/memory-stats.sh" ]; then
    bash .claude/scripts/memory-stats.sh 2>/dev/null
    echo -e "${GREEN}✅ memory-stats.json${NC}     — regenerated"
fi

echo ""
echo -e "${BLUE}ℹ️  MEMORY.md and workflow-prefs.md preserved${NC}"
echo ""
echo "Refresh the dashboard to see the changes."
echo ""
