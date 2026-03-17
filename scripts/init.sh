#!/bin/bash

# BetterAgents - Complete Installer v3.5
# Claude Code Edition — installs .claude/ system
# Usage: bash scripts/init.sh [--target /path/to/project]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step()    { echo -e "${CYAN}▶ $1${NC}"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 BetterAgents - Claude Code Installer v3.5"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. DETECT EXECUTION CONTEXT
# ============================================
print_step "Detecting execution context..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BETTERAGENTS_DIR="$(dirname "$SCRIPT_DIR")"

# Parse --target flag
TARGET_DIR="$(pwd)"
UNREGISTER=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --unregister) UNREGISTER=true; shift ;;
        *)
            shift
            ;;
    esac
done

# Check if running from BetterAgents repository
if [ ! -f "$BETTERAGENTS_DIR/config/betteragents.json" ]; then
    print_error "Must run from BetterAgents repository"
    print_info "Clone first: git clone <BetterAgents repository URL>"
    print_info "Then run: bash scripts/init.sh [--target /path/to/project]"
    exit 1
fi

print_info "BetterAgents source: $BETTERAGENTS_DIR"
print_info "Installation target: $TARGET_DIR"

# ============================================
# 1b. HANDLE --unregister
# ============================================
if [ "$UNREGISTER" = true ]; then
    print_step "Unregistering project from central container..."
    PROJECT_NAME=$(basename "$TARGET_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    if command -v jq &>/dev/null; then
        bash "$BETTERAGENTS_DIR/.claude/scripts/generate-central-compose.sh" "$PROJECT_NAME" "" --unregister 2>/dev/null || true
        CENTRAL_DIR="$HOME/.betteragents"
        if [ -f "$CENTRAL_DIR/docker-compose.yml" ]; then
            docker compose -f "$CENTRAL_DIR/docker-compose.yml" up -d --force-recreate 2>/dev/null \
                && print_success "Project '$PROJECT_NAME' removed from central dashboard" \
                || print_warning "Container restart failed. Run: docker compose -f ~/.betteragents/docker-compose.yml up -d --force-recreate"
        fi
    else
        print_warning "jq not found — cannot unregister project"
    fi
    exit 0
fi

# Detect project type
cd "$TARGET_DIR"
if [ -d ".git" ] || [ -f "package.json" ] || [ -f "requirements.txt" ] || [ -f "go.mod" ]; then
    print_info "Existing project detected"
    PROJECT_TYPE="existing"
else
    print_info "New project detected"
    PROJECT_TYPE="new"
fi

echo ""

# ============================================
# 2. VERIFY REQUIREMENTS
# ============================================
print_step "Verifying requirements..."

# Claude Code (optional — graceful if not found)
if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    print_success "Claude Code detected ($CLAUDE_VERSION)"
else
    print_warning "Claude Code not found in PATH (install from: https://claude.ai/claude-code)"
    print_info "Continuing installation — you can run Claude Code manually"
fi

# jq (required for scripts)
if command -v jq &>/dev/null; then
    print_success "jq detected (required for memory scripts)"
else
    print_warning "jq not found — install with: sudo apt install jq"
    print_info "Memory scripts will not function without jq"
fi

# git (optional)
if command -v git &>/dev/null; then
    print_success "git detected"
else
    print_warning "git not found (optional)"
fi

echo ""

# ============================================
# 3. CREATE DIRECTORY STRUCTURE
# ============================================
print_step "Creating .claude/ directory structure..."

mkdir -p .claude/agents
mkdir -p .claude/commands
mkdir -p .claude/memory
mkdir -p .claude/scripts
mkdir -p .claude/skills
mkdir -p .claude/cache
mkdir -p .claude/backups

print_success "Directory structure created"
echo ""

# ============================================
# 4. INSTALL CLAUDE.MD (ORCHESTRATOR)
# ============================================
print_step "Installing CLAUDE.md (AgentX orchestrator)..."

if [ -f "$BETTERAGENTS_DIR/CLAUDE.md" ]; then
    if [ -f "CLAUDE.md" ]; then
        # Backup existing CLAUDE.md
        BACKUP_NAME="CLAUDE.md.backup.$(date +%Y%m%d%H%M%S)"
        cp "CLAUDE.md" ".claude/backups/$BACKUP_NAME"
        print_info "Existing CLAUDE.md backed up to .claude/backups/$BACKUP_NAME"
    fi
    cp "$BETTERAGENTS_DIR/CLAUDE.md" "CLAUDE.md"
    print_success "CLAUDE.md installed (AgentX orchestrator)"
else
    print_warning "CLAUDE.md not found in BetterAgents source"
fi

echo ""

# ============================================
# 4b. INSTALL .CLAUDECODE.JSON (SAFETY CONFIG)
# ============================================
print_step "Installing .claudecode.json (safety config)..."

if [ -f "$BETTERAGENTS_DIR/.claudecode.json" ]; then
    if [ ! -f "$TARGET_DIR/.claudecode.json" ]; then
        cp "$BETTERAGENTS_DIR/.claudecode.json" "$TARGET_DIR/.claudecode.json"
        print_success ".claudecode.json installed"
    else
        print_info ".claudecode.json already exists — skipping"
    fi
else
    print_warning ".claudecode.json not found in BetterAgents source"
fi

echo ""

# ============================================
# 5. INSTALL AGENTS
# ============================================
print_step "Installing agent definitions..."

AGENTS_INSTALLED=0

if [ -d "$BETTERAGENTS_DIR/.claude/agents" ]; then
    for agent in "$BETTERAGENTS_DIR/.claude/agents"/*.md; do
        if [ -f "$agent" ]; then
            filename=$(basename "$agent")
            if cp "$agent" ".claude/agents/$filename" 2>/dev/null; then
                AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
            fi
        fi
    done
    print_success "Agent definitions installed ($AGENTS_INSTALLED agents)"
else
    print_error "Agents directory not found in BetterAgents source"
    exit 1
fi

echo ""

# ============================================
# 5b. INSTALL PROTOCOLS
# ============================================
print_step "Installing protocols..."

PROTOCOLS_INSTALLED=0

mkdir -p .claude/protocols

if [ -d "$BETTERAGENTS_DIR/.claude/protocols" ]; then
    for protocol in "$BETTERAGENTS_DIR/.claude/protocols"/*.md; do
        if [ -f "$protocol" ]; then
            filename=$(basename "$protocol")
            if cp "$protocol" ".claude/protocols/$filename" 2>/dev/null; then
                PROTOCOLS_INSTALLED=$((PROTOCOLS_INSTALLED + 1))
            fi
        fi
    done
    if [ "$PROTOCOLS_INSTALLED" -lt 1 ]; then
        print_error "No protocol files found in source"
        exit 1
    fi
    print_success "Protocols installed ($PROTOCOLS_INSTALLED protocols)"
else
    print_error "Protocols directory not found in BetterAgents source"
    exit 1
fi

echo ""

# ============================================
# 6. INSTALL SLASH COMMANDS
# ============================================
print_step "Installing slash commands..."

COMMANDS_INSTALLED=0

if [ -d "$BETTERAGENTS_DIR/.claude/commands" ]; then
    for cmd in "$BETTERAGENTS_DIR/.claude/commands"/*.md; do
        if [ -f "$cmd" ]; then
            filename=$(basename "$cmd")
            if cp "$cmd" ".claude/commands/$filename" 2>/dev/null; then
                COMMANDS_INSTALLED=$((COMMANDS_INSTALLED + 1))
            fi
        fi
    done
    print_success "Slash commands installed ($COMMANDS_INSTALLED commands)"
else
    print_warning "Commands directory not found"
fi

echo ""

# ============================================
# 7. INSTALL MEMORY SYSTEM
# ============================================
print_step "Installing memory system..."

MEMORY_FILES=0

# Copy JSON templates (don't overwrite existing user data)
if [ -d "$BETTERAGENTS_DIR/templates/memory" ]; then
    for template in "$BETTERAGENTS_DIR/templates/memory"/*.json; do
        if [ -f "$template" ]; then
            filename=$(basename "$template")
            if [ ! -f ".claude/memory/$filename" ]; then
                if cp "$template" ".claude/memory/$filename" 2>/dev/null; then
                    MEMORY_FILES=$((MEMORY_FILES + 1))
                fi
            else
                print_info "Preserving existing .claude/memory/$filename"
            fi
        fi
    done

    # Always install/update dashboard template
    if [ -f "$BETTERAGENTS_DIR/templates/memory/dashboard.html" ]; then
        cp "$BETTERAGENTS_DIR/templates/memory/dashboard.html" ".claude/memory/dashboard.html"
        print_success "Memory dashboard installed"
    fi

    # Also create templates/memory/ in target project (required for Docker volume mount)
    mkdir -p templates/memory
    cp "$BETTERAGENTS_DIR/templates/memory/dashboard.html" "templates/memory/dashboard.html" 2>/dev/null || true
    for template in "$BETTERAGENTS_DIR/templates/memory"/*.json; do
        [ -f "$template" ] || continue
        cp "$template" "templates/memory/$(basename "$template")" 2>/dev/null || true
    done
    print_success "templates/memory/ created (required for Docker volume)"

    print_success "Memory system initialized ($MEMORY_FILES new files)"
fi

# Install MEMORY.md from generic template (not from live project data)
if [ ! -f ".claude/memory/MEMORY.md" ]; then
    if [ -f "$BETTERAGENTS_DIR/templates/memory/MEMORY.md" ]; then
        cp "$BETTERAGENTS_DIR/templates/memory/MEMORY.md" ".claude/memory/MEMORY.md"
        print_success "MEMORY.md installed (generic template)"
    elif [ -f "$BETTERAGENTS_DIR/.claude/memory/MEMORY.md" ]; then
        cp "$BETTERAGENTS_DIR/.claude/memory/MEMORY.md" ".claude/memory/MEMORY.md"
        print_warning "MEMORY.md installed from source (no generic template found)"
    fi
fi

# Install session-last.md placeholder if not present
if [ ! -f ".claude/memory/session-last.md" ]; then
    if [ -f "$BETTERAGENTS_DIR/templates/memory/session-last.md" ]; then
        cp "$BETTERAGENTS_DIR/templates/memory/session-last.md" ".claude/memory/session-last.md"
        print_success "session-last.md initialized"
    fi
fi

echo ""

# ============================================
# 8. INSTALL HOOK SCRIPTS
# ============================================
print_step "Installing hook scripts..."

SCRIPTS_INSTALLED=0

if [ -d "$BETTERAGENTS_DIR/.claude/scripts" ]; then
    # Legacy scripts excluded from installation
    LEGACY_SCRIPTS=("on-session-stop-summary.sh")

    for script in "$BETTERAGENTS_DIR/.claude/scripts"/*.sh; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            # Skip legacy scripts
            skip=false
            for legacy in "${LEGACY_SCRIPTS[@]}"; do
                [ "$filename" = "$legacy" ] && skip=true && break
            done
            [ "$skip" = true ] && continue

            if cp "$script" ".claude/scripts/$filename" 2>/dev/null; then
                chmod +x ".claude/scripts/$filename"
                SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
            fi
        fi
    done
    # Also install serve-dashboard.js
    if [ -f "$BETTERAGENTS_DIR/.claude/scripts/serve-dashboard.js" ]; then
        cp "$BETTERAGENTS_DIR/.claude/scripts/serve-dashboard.js" ".claude/scripts/serve-dashboard.js"
    fi

    # Install reset-memory.sh utility at project root for easy access
    if [ -f "$BETTERAGENTS_DIR/reset-memory.sh" ]; then
        cp "$BETTERAGENTS_DIR/reset-memory.sh" "reset-memory.sh"
        chmod +x "reset-memory.sh"
    fi

    print_success "Hook scripts installed ($SCRIPTS_INSTALLED scripts)"
else
    print_warning "Scripts directory not found in source"
fi

echo ""

# ============================================
# 9. INSTALL UTILITY SCRIPTS
# ============================================
print_step "Installing utility scripts..."

UTIL_SCRIPTS_INSTALLED=0

mkdir -p scripts

if [ -d "$BETTERAGENTS_DIR/scripts" ]; then
    for script in "$BETTERAGENTS_DIR/scripts"/*.sh; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            # Don't overwrite init.sh in target
            if [ "$filename" != "init.sh" ]; then
                if cp "$script" "scripts/$filename" 2>/dev/null; then
                    chmod +x "scripts/$filename"
                    UTIL_SCRIPTS_INSTALLED=$((UTIL_SCRIPTS_INSTALLED + 1))
                fi
            fi
        fi
    done
    print_success "Utility scripts installed ($UTIL_SCRIPTS_INSTALLED scripts)"
fi

echo ""

# ============================================
# 9b. INSTALL DOCKER ASSETS + .ENV
# ============================================
print_step "Installing Docker assets..."

# Derive a clean project name from the target folder
PROJECT_NAME=$(basename "$TARGET_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
PROJECT_NAME="${PROJECT_NAME:-project}"

DOCKER_INSTALLED=0

if [ -f "$BETTERAGENTS_DIR/installer/Dockerfile" ]; then
    cp "$BETTERAGENTS_DIR/installer/Dockerfile" "Dockerfile"
    DOCKER_INSTALLED=$((DOCKER_INSTALLED + 1))
    print_success "Dockerfile installed"
fi

if [ -f "$BETTERAGENTS_DIR/installer/docker-compose.yml" ]; then
    if [ ! -f "docker-compose.yml" ]; then
        cp "$BETTERAGENTS_DIR/installer/docker-compose.yml" "docker-compose.yml"
        DOCKER_INSTALLED=$((DOCKER_INSTALLED + 1))
        print_success "docker-compose.yml installed"
    else
        print_info "docker-compose.yml already exists — skipping"
    fi
fi

# Find a free port starting from 3000
find_free_port() {
    local port=3000
    while [ "$port" -le 3099 ]; do
        if ! ss -tlnp 2>/dev/null | grep -qE ":${port}[^0-9]"; then
            echo "$port"
            return 0
        fi
        port=$((port + 1))
    done
    echo "3000"
}

# Write/update .env with project-specific container name and free port
ENV_FILE="$TARGET_DIR/.env"
if [ -f "$ENV_FILE" ] && grep -q "^BETTERAGENTS_PORT=" "$ENV_FILE" 2>/dev/null; then
    ASSIGNED_PORT=$(grep "^BETTERAGENTS_PORT=" "$ENV_FILE" | cut -d= -f2 | tr -d '[:space:]')
    sed -i "s/^BETTERAGENTS_PROJECT=.*/BETTERAGENTS_PROJECT=$PROJECT_NAME/" "$ENV_FILE" 2>/dev/null || \
        echo "BETTERAGENTS_PROJECT=$PROJECT_NAME" >> "$ENV_FILE"
    print_info "Keeping existing port ${ASSIGNED_PORT} from .env"
else
    ASSIGNED_PORT=$(find_free_port)
    if [ -f "$ENV_FILE" ]; then
        grep -q "^BETTERAGENTS_PROJECT=" "$ENV_FILE" 2>/dev/null && \
            sed -i "s/^BETTERAGENTS_PROJECT=.*/BETTERAGENTS_PROJECT=$PROJECT_NAME/" "$ENV_FILE" || \
            echo "BETTERAGENTS_PROJECT=$PROJECT_NAME" >> "$ENV_FILE"
        echo "BETTERAGENTS_PORT=$ASSIGNED_PORT" >> "$ENV_FILE"
    else
        cat > "$ENV_FILE" << EOF
# BetterAgents Dashboard
BETTERAGENTS_PROJECT=$PROJECT_NAME
BETTERAGENTS_PORT=$ASSIGNED_PORT
EOF
    fi
fi

print_success "Container: betteragents-${PROJECT_NAME}  →  http://localhost:${ASSIGNED_PORT}"
[ "${ASSIGNED_PORT}" != "3000" ] && print_info "Port 3000 was in use — assigned port ${ASSIGNED_PORT} automatically"
[ "$DOCKER_INSTALLED" -eq 0 ] && print_info "No Docker assets found in installer/ (optional)"

echo ""

# ============================================
# 10. WRITE SETTINGS.LOCAL.JSON (HOOKS)
# ============================================
print_step "Configuring Claude Code hooks..."

if [ ! -f ".claude/settings.local.json" ]; then
    cp "$BETTERAGENTS_DIR/.claude/settings.local.json" ".claude/settings.local.json"
    print_success "Claude Code hooks configured (settings.local.json — all hooks included)"
else
    print_info "settings.local.json already exists — skipping (to avoid overwriting customizations)"
    print_info "Manually add hooks from: $BETTERAGENTS_DIR/.claude/settings.local.json"
fi

echo ""

# ============================================
# 10b. REGISTER WITH CENTRAL CONTAINER
# ============================================
print_step "Registering with central BetterAgents container..."

MEMORY_ABSOLUTE="$(cd "$TARGET_DIR/.claude/memory" 2>/dev/null && pwd || echo "$TARGET_DIR/.claude/memory")"
CENTRAL_SCRIPTS="$BETTERAGENTS_DIR/.claude/scripts"

if command -v docker &>/dev/null && command -v jq &>/dev/null; then
    if [ -f "$CENTRAL_SCRIPTS/generate-central-compose.sh" ]; then
        bash "$CENTRAL_SCRIPTS/generate-central-compose.sh" "$PROJECT_NAME" "$MEMORY_ABSOLUTE"
        CENTRAL_DIR="$HOME/.betteragents"

        if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^betteragents-central$"; then
            print_info "Restarting central container to add new project..."
            docker compose -f "$CENTRAL_DIR/docker-compose.yml" up -d --force-recreate 2>/dev/null \
                && print_success "Central container updated" \
                || print_warning "Could not restart container. Run: docker compose -f ~/.betteragents/docker-compose.yml up -d --force-recreate"
        else
            print_info "Starting central container for the first time..."
            docker compose -f "$CENTRAL_DIR/docker-compose.yml" up -d 2>/dev/null \
                && print_success "Central container started → http://localhost:3000" \
                || print_warning "Could not start container. Run: docker compose -f ~/.betteragents/docker-compose.yml up -d"
        fi
    else
        print_info "generate-central-compose.sh not found — skipping central registration"
    fi
else
    ! command -v docker &>/dev/null && print_info "Docker not found — skipping central container registration"
    ! command -v jq &>/dev/null && print_info "jq not found — skipping central container registration"
    print_info "Install Docker + jq to enable multi-project dashboard"
fi

echo ""

# ============================================
# 11. INITIALIZE CACHE
# ============================================
print_step "Initializing cache..."

cat > .claude/cache/skills-detection-cache.json << 'CACHE_EOF'
{}
CACHE_EOF

print_success "Cache initialized"
echo ""

# ============================================
# 12. CONFIGURE .GITIGNORE
# ============================================
print_step "Configuring .gitignore..."

GITIGNORE_ENTRIES='
# BetterAgents - Memory and cache (auto-generated)
.claude/memory/*.json
!.claude/memory/MEMORY.md
.claude/cache/
.claude/backups/
'

if [ ! -f ".gitignore" ]; then
    echo "$GITIGNORE_ENTRIES" > .gitignore
    print_success ".gitignore created"
else
    if ! grep -q ".claude/cache/" .gitignore 2>/dev/null; then
        echo "$GITIGNORE_ENTRIES" >> .gitignore
        print_success ".gitignore updated with BetterAgents entries"
    else
        print_info ".gitignore already configured"
    fi
fi

echo ""

# ============================================
# 13. WRITE VERSION FILE
# ============================================
NEW_VERSION=$(jq -r '.version' "$BETTERAGENTS_DIR/config/betteragents.json" 2>/dev/null || echo "3.5.0")
echo "$NEW_VERSION" > .claude/.version
print_success "Version file written: $NEW_VERSION"

echo ""

# ============================================
# 13b. INITIALIZE MEMORY STATS
# ============================================
print_step "Initializing memory stats..."

if command -v jq &>/dev/null && [ -f ".claude/scripts/memory-stats.sh" ]; then
    bash .claude/scripts/memory-stats.sh 2>/dev/null
    print_success "memory-stats.json generated (File Breakdown ready)"
else
    print_info "Skipping memory stats (jq not found or script missing)"
fi

echo ""

# ============================================
# 14. VERIFY INSTALLATION
# ============================================
print_step "Verifying installation..."

VERIFY_OK=true

[ -f "CLAUDE.md" ] || { print_warning "CLAUDE.md missing"; VERIFY_OK=false; }
[ -d ".claude/agents" ] && [ "$(ls -A .claude/agents/*.md 2>/dev/null | wc -l)" -gt 0 ] || { print_warning "No agent files found"; VERIFY_OK=false; }
[ -d ".claude/commands" ] && [ "$(ls -A .claude/commands/*.md 2>/dev/null | wc -l)" -gt 0 ] || { print_warning "No command files found"; VERIFY_OK=false; }
[ -d ".claude/memory" ] || { print_warning ".claude/memory directory missing"; VERIFY_OK=false; }
[ -f ".claude/settings.local.json" ] || { print_warning "settings.local.json missing"; VERIFY_OK=false; }
[ -f ".claude/memory/MEMORY.md" ] || { print_warning "MEMORY.md missing"; VERIFY_OK=false; }
[ -f ".claude/memory/dashboard.html" ] || { print_warning "dashboard.html missing"; VERIFY_OK=false; }

if [ "$VERIFY_OK" = true ]; then
    print_success "Installation verified"
else
    print_warning "Some verification checks failed — review warnings above"
fi

echo ""

# ============================================
# 15. INSTALLATION SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ BetterAgents v${NEW_VERSION} Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installation Summary:"
echo ""
echo "  ✅ CLAUDE.md:         AgentX orchestrator"
echo "  ✅ .claudecode.json:  Safety & efficiency config"
echo "  ✅ Agents:            $AGENTS_INSTALLED specialist agents"
echo "  ✅ Protocols:         $PROTOCOLS_INSTALLED protocol files"
echo "  ✅ Commands:          $COMMANDS_INSTALLED slash commands"
echo "  ✅ Memory:            $MEMORY_FILES files + MEMORY.md + dashboard"
echo "  ✅ Hook scripts:      $SCRIPTS_INSTALLED automation scripts"
echo "  ✅ Utility scripts:   $UTIL_SCRIPTS_INSTALLED scripts"
echo "  ✅ Hooks:             Stop + PostToolUse configured"
echo "  ✅ Central dashboard: http://localhost:3000 (multi-project)"
echo "  ✅ Cache:             Initialized"
echo ""
echo "🚀 Quick Start:"
echo ""
echo "  1. Open your project in Claude Code:"
echo "     $ claude ."
echo ""
echo "  2. Test AgentX:"
echo "     Just chat — AgentX will route your requests automatically"
echo ""
echo "  3. Use specific agents with slash commands:"
echo "     /architect  — System design"
echo "     /coder      — Implementation"
echo "     /critic     — Risk analysis"
echo "     /security   — Security audit"
echo "     /tester     — Test strategy"
echo ""
echo "  4. View memory and stats:"
echo "     /memory     — View project memory"
echo "     /metrics    — View usage stats"
echo ""
echo "📊 Open Dashboard:"
echo ""
echo "  Node.js (local):"
echo "     \$ bash .claude/scripts/start-dashboard.sh"
echo ""
echo "  Docker:"
echo "     \$ docker compose up -d"
echo "     \$ open http://localhost:3000"
echo ""
echo "🔄 Updates:"
echo ""
echo "  $ git pull origin main  (in BetterAgents repo)"
echo "  $ bash scripts/update.sh"
echo ""
echo "📚 Documentation:"
echo ""
echo "  • README: ./README.md"
echo "  • Memory: ./.claude/memory/MEMORY.md"
echo "  • Agents: ./.claude/agents/"
echo ""
print_success "Happy coding! 🎉"
echo ""

# ============================================
# 16. AUTO-START DASHBOARD
# ============================================
print_step "Starting dashboard..."
echo ""

if command -v docker &>/dev/null && [ -f "docker-compose.yml" ]; then
    echo -e "${CYAN}▶ Launching Docker container: betteragents-${PROJECT_NAME}...${NC}"
    if docker compose up -d 2>/dev/null; then
        echo -e "${GREEN}✅ Container started — waiting for initialization...${NC}"
        sleep 3
        bash ".claude/scripts/start-dashboard.sh" &
    else
        print_warning "Docker failed to start. Try manually: docker compose up -d"
        print_info "Or use Node.js: bash .claude/scripts/start-dashboard.sh &"
    fi
elif command -v node &>/dev/null; then
    print_info "Docker not available — starting Node.js dashboard server..."
    bash ".claude/scripts/start-dashboard.sh" &
else
    print_info "Start the dashboard manually when ready:"
    print_info "  Docker:  docker compose up -d"
    print_info "  Node.js: bash .claude/scripts/start-dashboard.sh"
fi
