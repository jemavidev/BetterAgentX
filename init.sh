#!/usr/bin/env bash
# BetterAgents Dashboard — Initialization Script
# Starts the memory dashboard via Docker (preferred) or Node.js (fallback)

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ─── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_SCRIPT="$SCRIPT_DIR/.claude/scripts/serve-dashboard.js"

# ─── Helpers ──────────────────────────────────────────────────────────────────
print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  BetterAgents Memory Dashboard${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_success() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}  BetterAgents Dashboard${NC}"
  echo -e "${GREEN}  http://localhost:3000${NC}"
  echo -e "${GREEN}  Memory: .claude/memory/${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_docker_commands() {
  echo -e "  ${YELLOW}Useful commands:${NC}"
  echo -e "    Stop:     ${BLUE}docker compose down${NC}"
  echo -e "    Logs:     ${BLUE}docker compose logs -f${NC}"
  echo -e "    Restart:  ${BLUE}docker compose restart${NC}"
  echo ""
}

# ─── Prerequisite checks ──────────────────────────────────────────────────────
check_docker() {
  # 1. docker binary present?
  if ! command -v docker &>/dev/null; then
    return 1
  fi

  # 2. daemon running?
  if ! docker info &>/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Docker is installed but the daemon is not running.${NC}"
    echo -e "  Start it with:  ${BLUE}sudo systemctl start docker${NC}  (Linux)"
    echo -e "              or open Docker Desktop (macOS/Windows)"
    return 1
  fi

  return 0
}

detect_compose_cmd() {
  # Prefer v2 plugin; fall back to v1 standalone
  if docker compose version &>/dev/null 2>&1; then
    echo "docker compose"
  elif command -v docker-compose &>/dev/null; then
    echo "docker-compose"
  else
    echo ""
  fi
}

# ─── Docker path ──────────────────────────────────────────────────────────────
start_with_docker() {
  local compose_cmd="$1"

  # Check if the container is already running
  if docker ps --filter "name=betteragents-dashboard" --filter "status=running" \
       --format "{{.Names}}" 2>/dev/null | grep -q "betteragents-dashboard"; then
    echo -e "${GREEN}Container already running — skipping start.${NC}"
    print_success
    print_docker_commands
    return 0
  fi

  echo -e "  Building and starting container..."
  cd "$SCRIPT_DIR"

  if ! $compose_cmd up -d --build; then
    echo -e "${RED}Error: docker compose up failed.${NC}"
    return 1
  fi

  # Wait for healthcheck (max 15s)
  echo -e "  Waiting for healthcheck..."
  local elapsed=0
  local max=15
  while [ $elapsed -lt $max ]; do
    local health
    health=$(docker inspect --format='{{.State.Health.Status}}' betteragents-dashboard 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
      break
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  if [ $elapsed -ge $max ]; then
    echo -e "${YELLOW}Warning: healthcheck did not pass within ${max}s — container may still be starting.${NC}"
  fi

  print_success
  print_docker_commands
}

# ─── Node.js fallback path ────────────────────────────────────────────────────
start_with_node() {
  if ! command -v node &>/dev/null; then
    echo -e "${RED}Neither Docker nor Node.js is available.${NC}"
    echo ""
    echo -e "  Install Node.js:  ${BLUE}https://nodejs.org${NC}"
    echo -e "  Install Docker:   ${BLUE}https://docs.docker.com/get-docker/${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Docker not available — falling back to Node.js server.${NC}"
  echo ""

  if [ ! -f "$SERVER_SCRIPT" ]; then
    echo -e "${RED}Error: server script not found at $SERVER_SCRIPT${NC}"
    exit 1
  fi

  print_success
  echo -e "  ${YELLOW}Press Ctrl+C to stop the server.${NC}"
  echo ""

  # Blocking — user must Ctrl+C to stop
  cd "$SCRIPT_DIR"
  node "$SERVER_SCRIPT"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  print_header

  if check_docker; then
    compose_cmd="$(detect_compose_cmd)"
    if [ -z "$compose_cmd" ]; then
      echo -e "${YELLOW}Docker is running but docker compose is not available.${NC}"
      echo -e "  Install it:  ${BLUE}https://docs.docker.com/compose/install/${NC}"
      start_with_node
    else
      echo -e "  Using: ${BLUE}${compose_cmd}${NC}"
      start_with_docker "$compose_cmd"
    fi
  else
    start_with_node
  fi
}

main "$@"
