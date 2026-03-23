#!/bin/bash
# Claude Code Platform Installer
# Installs Claude-specific files only. Core (.betteragents/) is handled by core/install.sh
# Called by: bash platforms/claude/install.sh TARGET_DIR

set -e

TARGET_DIR="$1"
PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$PLATFORM_DIR/../.." && pwd)"

source "$INSTALLER_DIR/lib/core.sh"

if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR"
fi

validate_directory "$TARGET_DIR"
cd "$TARGET_DIR"

print_step "Installing Claude Code platform..."

# ============================================
# 1. DETECT PROJECT TYPE (Case A/B/C)
# ============================================

print_step "Detecting project type..."

PROJECT_CASE="A"
if [[ -f ".claude/.version" ]]; then
    PROJECT_CASE="B"
    EXISTING_VERSION=$(cat ".claude/.version" 2>/dev/null || echo "unknown")
    print_info "Case B: Existing Claude installation (v$EXISTING_VERSION)"
elif [[ -d ".git" ]] || [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "go.mod" ]] || [[ -f "Cargo.toml" ]]; then
    PROJECT_CASE="C"
    print_info "Case C: Existing project (non-BetterAgents)"
else
    print_info "Case A: New project"
fi

echo ""

# ============================================
# 2. CHECK DEPENDENCIES
# ============================================

print_step "Checking dependencies..."

! command_exists jq && print_warning "jq not found — install: sudo apt install jq / brew install jq"
command_exists claude && print_success "Claude Code: $(claude --version 2>/dev/null | head -1 || echo 'detected')"
command_exists git    && print_success "git detected"
command_exists docker && print_success "docker detected (dashboard available)"
command_exists node   && print_success "node detected: $(node --version 2>/dev/null)"

echo ""

# ============================================
# 3. CREATE CLAUDE-SPECIFIC DIRECTORIES
# ============================================

print_step "Creating Claude directory structure..."

DIRECTORIES=(
    ".claude/agents"
    ".claude/commands"
    ".claude/protocols"
    ".claude/scripts"
    ".claude/memory"
    ".claude/cache"
    ".claude/backups"
)

for dir in "${DIRECTORIES[@]}"; do
    ensure_directory "$dir"
done

print_success "Claude directories created"
echo ""

# ============================================
# 4. INSTALL ORCHESTRATOR (CLAUDE.md)
# ============================================

print_step "Installing CLAUDE.md orchestrator..."

if [[ -f "$PLATFORM_DIR/templates/CLAUDE.md" ]]; then
    [[ -f "CLAUDE.md" ]] && backup_file "CLAUDE.md"
    cp "$PLATFORM_DIR/templates/CLAUDE.md" "CLAUDE.md" || die "Failed to install CLAUDE.md"
    print_success "CLAUDE.md installed"
else
    die "CLAUDE.md template not found"
fi

echo ""

# ============================================
# 5. INSTALL .CLAUDECODE.JSON
# ============================================

print_step "Installing .claudecode.json..."

if [[ -f "$PLATFORM_DIR/templates/.claudecode.json" ]]; then
    if [[ ! -f ".claudecode.json" ]]; then
        cp "$PLATFORM_DIR/templates/.claudecode.json" ".claudecode.json"
        print_success ".claudecode.json installed"
    else
        print_info ".claudecode.json already exists — preserving"
    fi
else
    print_warning ".claudecode.json template not found"
fi

echo ""

# ============================================
# 6. INSTALL AGENTS (12 specialists)
# ============================================

print_step "Installing agent definitions..."

AGENTS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.claude/agents" ]]; then
    for agent in "$PLATFORM_DIR/templates/.claude/agents"/*.md; do
        if [[ -f "$agent" ]]; then
            filename=$(basename "$agent")
            cp "$agent" ".claude/agents/$filename" || die "Failed to install agent: $filename"
            AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
        fi
    done
    [[ $AGENTS_INSTALLED -lt 12 ]] \
        && print_warning "Expected 12 agents, installed $AGENTS_INSTALLED" \
        || print_success "Agents installed ($AGENTS_INSTALLED)"
else
    die "Agents directory not found in templates"
fi

echo ""

# ============================================
# 7. INSTALL PROTOCOLS
# ============================================

print_step "Installing protocols..."

PROTOCOLS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.claude/protocols" ]]; then
    for protocol in "$PLATFORM_DIR/templates/.claude/protocols"/*.md; do
        if [[ -f "$protocol" ]]; then
            filename=$(basename "$protocol")
            cp "$protocol" ".claude/protocols/$filename" || die "Failed to install protocol: $filename"
            PROTOCOLS_INSTALLED=$((PROTOCOLS_INSTALLED + 1))
        fi
    done
    print_success "Protocols installed ($PROTOCOLS_INSTALLED)"
else
    die "Protocols directory not found in templates"
fi

echo ""

# ============================================
# 8. INSTALL COMMANDS (slash skills)
# ============================================

print_step "Installing slash commands..."

COMMANDS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.claude/commands" ]]; then
    for cmd in "$PLATFORM_DIR/templates/.claude/commands"/*.md; do
        if [[ -f "$cmd" ]]; then
            filename=$(basename "$cmd")
            cp "$cmd" ".claude/commands/$filename" || die "Failed to install command: $filename"
            COMMANDS_INSTALLED=$((COMMANDS_INSTALLED + 1))
        fi
    done
    [[ $COMMANDS_INSTALLED -lt 70 ]] \
        && print_warning "Expected 76+ commands, installed $COMMANDS_INSTALLED" \
        || print_success "Commands installed ($COMMANDS_INSTALLED)"
else
    die "Commands directory not found in templates"
fi

echo ""

# ============================================
# 8.5. INSTALL SCRIPTS
# ============================================

print_step "Installing scripts..."

SCRIPTS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.claude/scripts" ]]; then
    for script in "$PLATFORM_DIR/templates/.claude/scripts"/*.sh "$PLATFORM_DIR/templates/.claude/scripts"/*.js; do
        if [[ -f "$script" ]]; then
            filename=$(basename "$script")
            cp "$script" ".claude/scripts/$filename" || die "Failed to install script: $filename"
            chmod +x ".claude/scripts/$filename"
            SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
        fi
    done
    print_success "Scripts installed ($SCRIPTS_INSTALLED)"
else
    print_warning "Scripts directory not found in templates — memory protocols will be limited"
fi

echo ""

# ============================================
# 8.7. INITIALIZE MEMORY FILES
# ============================================

print_step "Initializing memory files..."

MEMORY_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.claude/memory" ]]; then
    for memfile in "$PLATFORM_DIR/templates/.claude/memory"/*; do
        if [[ -f "$memfile" ]]; then
            filename=$(basename "$memfile")
            if [[ ! -f ".claude/memory/$filename" ]]; then
                cp "$memfile" ".claude/memory/$filename" || die "Failed to install memory file: $filename"
                MEMORY_INSTALLED=$((MEMORY_INSTALLED + 1))
            fi
        fi
    done
    print_success "Memory files initialized ($MEMORY_INSTALLED new files)"
else
    print_warning "Memory templates not found — AgentX will start without persistent memory"
fi

echo ""

# ============================================
# 9. CONFIGURE HOOKS (settings.local.json)
# ============================================

print_step "Configuring hooks..."

if [[ -f "$PLATFORM_DIR/templates/.claude/settings.local.json" ]]; then
    if [[ ! -f ".claude/settings.local.json" ]]; then
        cp "$PLATFORM_DIR/templates/.claude/settings.local.json" ".claude/settings.local.json"
        print_success "Hooks configured (settings.local.json)"
    else
        print_info "settings.local.json exists — preserving"
    fi
else
    print_warning "settings.local.json template not found"
fi

echo ""

# ============================================
# 10. INITIALIZE CACHE
# ============================================

print_step "Initializing cache..."

ensure_directory ".claude/cache/skills"
ensure_directory ".claude/cache/agents"

if [[ ! -f ".claude/cache/index.json" ]]; then
    echo '{"skills": {}, "agents": {}, "last_updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' \
        > ".claude/cache/index.json"
fi

print_success "Cache initialized"
echo ""

# ============================================
# 11. WRITE VERSION FILE
# ============================================

print_step "Writing version file..."

VERSION="4.0.0"
echo "$VERSION" > ".claude/.version"
print_success "Version file created (v$VERSION)"

echo ""

# ============================================
# 12. REGISTER PLATFORM IN state.json
# ============================================

print_step "Registering Claude platform in state.json..."

if [[ -f ".betteragents/state.json" ]] && command_exists jq; then
    ALREADY=$(jq -r '.installed_platforms | index("claude") // empty' ".betteragents/state.json" 2>/dev/null)
    if [[ -z "$ALREADY" ]]; then
        jq '.installed_platforms += ["claude"]' ".betteragents/state.json" \
            > ".betteragents/state.json.tmp" && \
            mv ".betteragents/state.json.tmp" ".betteragents/state.json"
        print_success "Registered: claude"
    else
        print_info "Already registered"
    fi
fi

echo ""

# ============================================
# 13. CONFIGURE .GITIGNORE
# ============================================

GITIGNORE_ENTRIES=(
    ".claude/cache/"
    ".claude/backups/"
)

if [[ -f ".gitignore" ]]; then
    ADDED=0
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "$entry" ".gitignore"; then
            echo "$entry" >> ".gitignore"
            ADDED=$((ADDED + 1))
        fi
    done
    [[ $ADDED -gt 0 ]] && print_info ".gitignore updated ($ADDED entries)"
fi

echo ""

# ============================================
# 14. DOCKER CONTAINER SETUP (OPTIONAL)
# ============================================

print_step "Configuring dashboard container..."

CENTRAL_DIR="$HOME/.betteragents"
CENTRAL_COMPOSE="$CENTRAL_DIR/docker-compose.yml"
CONTAINER_NAME="betteragents-central"

if command_exists docker; then
    print_info "Docker detected — configuring central container..."

    if [[ -f ".betteragents/scripts/generate-central-compose.sh" ]]; then
        bash ".betteragents/scripts/generate-central-compose.sh" 2>/dev/null || true
    fi

    if [[ -f "$CENTRAL_COMPOSE" ]]; then
        if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
            print_info "Existing container — updating..."
            docker compose -f "$CENTRAL_COMPOSE" up -d --force-recreate 2>/dev/null \
                && print_success "Docker container updated: http://localhost:3000" \
                || print_warning "Docker update failed — use: bash .betteragents/scripts/start-dashboard.sh"
        else
            print_info "Creating container..."
            docker compose -f "$CENTRAL_COMPOSE" up -d 2>/dev/null \
                && print_success "Docker container created: http://localhost:3000" \
                || print_warning "Docker creation failed — use: bash .betteragents/scripts/start-dashboard.sh"
        fi
    else
        print_warning "Compose not generated — use Node.js fallback"
        print_info "Start dashboard: bash .betteragents/scripts/start-dashboard.sh"
    fi
else
    print_info "Docker not installed — Node.js mode available"
    print_info "Start dashboard: bash .betteragents/scripts/start-dashboard.sh"
fi

echo ""

# ============================================
# COMPLETE
# ============================================

print_success "Claude Code platform installed!"
echo ""
print_info "Next steps:"
echo "  1. Open this project in Claude Code"
echo "  2. Read CLAUDE.md to understand AgentX orchestrator"
echo "  3. Try: 'Show me the agents' or '/memory'"
echo "  4. Dashboard: bash .betteragents/scripts/start-dashboard.sh"
echo ""

exit 0
