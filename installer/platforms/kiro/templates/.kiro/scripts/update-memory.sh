#!/bin/bash
# BetterAgents — Kiro Memory Update Helper
# Self-contained wrapper for Kiro memory operations
# Usage: bash .kiro/scripts/update-memory.sh [task|decision|pattern|context|status] [args...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

if [[ ! -d "$MEMORY_DIR" ]]; then
    echo "❌ Memory directory not found at $MEMORY_DIR"
    echo "   Run the BetterAgents Kiro installer first."
    exit 1
fi

COMMAND="${1:-help}"
shift 2>/dev/null

case "$COMMAND" in
    task)
        bash "$SCRIPT_DIR/add-task.sh" "$@"
        ;;
    decision)
        bash "$SCRIPT_DIR/add-decision.sh" "$@"
        ;;
    pattern)
        bash "$SCRIPT_DIR/add-pattern.sh" "$@"
        ;;
    context)
        bash "$SCRIPT_DIR/update-context.sh" "$@"
        ;;
    status)
        echo "📊 Memory Status"
        echo "────────────────"
        jq -r '"Tasks: " + (.tasks | length | tostring)' "$MEMORY_DIR/progress.json" 2>/dev/null || echo "Tasks: 0"
        jq -r '"Decisions: " + (.decisions | length | tostring)' "$MEMORY_DIR/decision-log.json" 2>/dev/null || echo "Decisions: 0"
        jq -r '"Patterns: " + (.patterns | length | tostring)' "$MEMORY_DIR/patterns.json" 2>/dev/null || echo "Patterns: 0"
        echo ""
        echo "Memory location: $MEMORY_DIR"
        ;;
    help|*)
        echo "Usage: bash .kiro/scripts/update-memory.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  task      <id> <title> <status> <agent> <outcome> <priority> <tags> <minutes>"
        echo "  decision  <id> <title> <context> <agent> <status> <tags>"
        echo "  pattern   <name> <category> <problem> <agent> <solution> <tags>"
        echo "  context   --focus <feature> --objective <goal> [--phase <phase>]"
        echo "  status    Show memory counts"
        echo ""
        echo "Memory location: $MEMORY_DIR"
        ;;
esac
