#!/usr/bin/env bash
###############################################################################
# Kiro Memory Update Wrapper — BetterAgents v3.8.0
# Bridges Kiro to Claude memory system
#
# Usage: bash .kiro/scripts/update-memory.sh <action> [args...]
#
# Actions:
#   task     <id> <title> <status> <agent> [outcome] [priority] [tags] [duration]
#   decision <id> <title> <status> <agent> <context> <decision> [alternatives] [consequences]
#   pattern  <id> <name> <category> <problem> <solution>
#   context  <field> <value>
#   sync-all
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_SCRIPTS="$PROJECT_ROOT/.claude/scripts"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ACTION="${1:-}"
shift || true

# Verify Claude memory bridge is available
check_bridge() {
    if [[ ! -d "$CLAUDE_SCRIPTS" ]]; then
        echo -e "${YELLOW}⚠  Claude memory bridge not found at $CLAUDE_SCRIPTS${NC}"
        echo -e "${YELLOW}   Install Claude platform first: bash instalador/install.sh --platform=claude --target=.${NC}"
        exit 1
    fi
}

case "$ACTION" in
    task)
        check_bridge
        echo -e "${BLUE}📝 Adding task to memory...${NC}"
        bash "$CLAUDE_SCRIPTS/add-task.sh" "$@"
        echo -e "${GREEN}✓ Task added${NC}"
        ;;

    decision)
        check_bridge
        echo -e "${BLUE}🎯 Adding decision to memory...${NC}"
        bash "$CLAUDE_SCRIPTS/add-decision.sh" "$@"
        echo -e "${GREEN}✓ Decision added${NC}"
        ;;

    pattern)
        check_bridge
        echo -e "${BLUE}🔄 Adding pattern to memory...${NC}"
        bash "$CLAUDE_SCRIPTS/add-pattern.sh" "$@"
        echo -e "${GREEN}✓ Pattern added${NC}"
        ;;

    context)
        check_bridge
        echo -e "${BLUE}📍 Updating context...${NC}"
        bash "$CLAUDE_SCRIPTS/update-context.sh" "$@"
        echo -e "${GREEN}✓ Context updated${NC}"
        ;;

    sync-all)
        check_bridge
        echo -e "${BLUE}🔄 Syncing memory stats...${NC}"
        if [[ -f "$CLAUDE_SCRIPTS/memory-stats.sh" ]]; then
            bash "$CLAUDE_SCRIPTS/memory-stats.sh" 2>/dev/null || true
            echo -e "${GREEN}✓ Memory stats synced${NC}"
        else
            echo -e "${YELLOW}⚠  memory-stats.sh not found — skipping${NC}"
        fi
        ;;

    *)
        echo -e "${RED}Usage: bash .kiro/scripts/update-memory.sh <action> [args...]${NC}"
        echo ""
        echo "Actions:"
        echo "  task     <id> <title> <status> <agent> [outcome] [priority] [tags] [duration_min]"
        echo "  decision <id> <title> <status> <agent> <context> <decision> [alternatives] [consequences]"
        echo "  pattern  <id> <name> <category> <problem> <solution>"
        echo "  context  <field> <value>  (e.g., version 2.0.0, phase \"2.0 — Feature\", focus \"Auth\")"
        echo "  sync-all"
        echo ""
        echo "Examples:"
        echo "  bash .kiro/scripts/update-memory.sh task TASK-01 \"Fix auth bug\" completed coder \"Fixed JWT expiry\""
        echo "  bash .kiro/scripts/update-memory.sh decision DEC-01 \"Use Redis\" implemented architect \"Need session storage\" \"Redis for sessions\""
        echo "  bash .kiro/scripts/update-memory.sh pattern PAT-01 \"repository-pattern\" architectural \"Logic coupled to DB\" \"Repository interface\""
        echo "  bash .kiro/scripts/update-memory.sh context version 2.0.0"
        echo "  bash .kiro/scripts/update-memory.sh sync-all"
        exit 1
        ;;
esac
