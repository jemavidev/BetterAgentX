#!/bin/bash
# BetterAgents — Kiro Memory Update Helper
# Wrapper to update memory from Kiro IDE context
# Usage: bash .kiro/scripts/update-memory.sh [task|decision|pattern|context] [args...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEMORY_SCRIPTS="$PROJECT_ROOT/.betteragents/scripts"

if [[ ! -d "$MEMORY_SCRIPTS" ]]; then
    echo "❌ BetterAgents memory scripts not found at $MEMORY_SCRIPTS"
    echo "   Run the BetterAgents installer first."
    exit 1
fi

COMMAND="${1:-help}"
shift 2>/dev/null

case "$COMMAND" in
    task)
        bash "$MEMORY_SCRIPTS/add-task.sh" "$@"
        ;;
    decision)
        bash "$MEMORY_SCRIPTS/add-decision.sh" "$@"
        ;;
    pattern)
        bash "$MEMORY_SCRIPTS/add-pattern.sh" "$@"
        ;;
    context)
        bash "$MEMORY_SCRIPTS/update-context.sh" "$@"
        ;;
    dashboard)
        bash "$MEMORY_SCRIPTS/start-dashboard.sh"
        ;;
    status)
        echo "📊 Memory Status"
        echo "────────────────"
        jq -r '"Tasks: " + (.tasks | length | tostring)' "$PROJECT_ROOT/.betteragents/memory/progress.json" 2>/dev/null || echo "Tasks: 0"
        jq -r '"Decisions: " + (.decisions | length | tostring)' "$PROJECT_ROOT/.betteragents/memory/decision-log.json" 2>/dev/null || echo "Decisions: 0"
        jq -r '"Patterns: " + (.patterns | length | tostring)' "$PROJECT_ROOT/.betteragents/memory/patterns.json" 2>/dev/null || echo "Patterns: 0"
        ;;
    help|*)
        echo "Usage: bash .kiro/scripts/update-memory.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  task      <id> <title> <status> <agent> <outcome> <priority> <tags> <minutes>"
        echo "  decision  <id> <title> <context> <agent> <status> <tags>"
        echo "  pattern   <name> <category> <problem> <agent> <solution> <tags>"
        echo "  context   --focus <feature> --objective <goal> [--phase <phase>]"
        echo "  dashboard  Open memory dashboard"
        echo "  status     Show memory counts"
        ;;
esac
