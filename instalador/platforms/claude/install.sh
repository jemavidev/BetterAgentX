#!/bin/bash
# BetterAgents — Claude Code Platform Installer
# Called by: bash platforms/claude/install.sh TARGET_DIR
# Installs the full .claude/ agent system into TARGET_DIR

set -e

PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$PLATFORM_DIR/../.." && pwd)"

# Source core libraries
source "$INSTALLER_DIR/lib/core.sh"

# Parse arguments
TARGET_DIR="$1"
if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR"
fi

validate_directory "$TARGET_DIR"
cd "$TARGET_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 BetterAgents — Claude Code Platform v3.8.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. DETECT EXECUTION CONTEXT
# ============================================
print_step "Detecting project context..."

if [ -d ".git" ] || [ -f "package.json" ] || [ -f "requirements.txt" ] || [ -f "go.mod" ]; then
    print_info "Existing project detected"
    PROJECT_TYPE="existing"
else
    print_info "New project detected"
    PROJECT_TYPE="new"
fi

# Detect if an existing BetterAgents installation is present
IS_BETTERAGENTS=false
PREV_VERSION=""
if [ -f ".claude/.version" ]; then
    IS_BETTERAGENTS=true
    PREV_VERSION=$(cat ".claude/.version" 2>/dev/null || echo "unknown")
    print_info "BetterAgents v${PREV_VERSION} detected → memory files will be preserved"
else
    print_info "No prior BetterAgents installation → memory files will be initialized from clean templates"
fi

echo ""

# ============================================
# 2. VERIFY REQUIREMENTS
# ============================================
print_step "Verifying requirements..."

if command -v claude &>/dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    print_success "Claude Code detected ($CLAUDE_VERSION)"
else
    print_warning "Claude Code not found in PATH (install from: https://claude.ai/claude-code)"
    print_info "Continuing installation — you can run Claude Code manually"
fi

if command -v jq &>/dev/null; then
    print_success "jq detected (required for memory scripts)"
else
    print_warning "jq not found — install with: sudo apt install jq"
    print_info "Memory scripts will not function without jq"
fi

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
mkdir -p .claude/memory/archive
mkdir -p .claude/scripts
mkdir -p .claude/skills
mkdir -p .claude/cache
mkdir -p .claude/backups
mkdir -p .claude/protocols

print_success "Directory structure created"
echo ""

# ============================================
# 4. INSTALL CLAUDE.MD (ORCHESTRATOR)
# ============================================
print_step "Installing CLAUDE.md (AgentX orchestrator)..."

if [ -f "$INSTALLER_DIR/CLAUDE.md" ]; then
    if [ -f "CLAUDE.md" ]; then
        BACKUP_NAME="CLAUDE.md.backup.$(date +%Y%m%d%H%M%S)"
        cp "CLAUDE.md" ".claude/backups/$BACKUP_NAME"
        print_info "Existing CLAUDE.md backed up to .claude/backups/$BACKUP_NAME"
    fi
    cp "$INSTALLER_DIR/CLAUDE.md" "CLAUDE.md"
    print_success "CLAUDE.md installed (AgentX orchestrator)"
else
    print_error "CLAUDE.md not found in installer — instalador/ folder may be incomplete"
    exit 1
fi

echo ""

# ============================================
# 4b. INSTALL .CLAUDECODE.JSON (SAFETY CONFIG)
# ============================================
print_step "Installing .claudecode.json (safety config)..."

if [ -f "$INSTALLER_DIR/.claudecode.json" ]; then
    if [ ! -f "$TARGET_DIR/.claudecode.json" ]; then
        cp "$INSTALLER_DIR/.claudecode.json" "$TARGET_DIR/.claudecode.json"
        print_success ".claudecode.json installed"
    else
        print_info ".claudecode.json already exists — skipping"
    fi
else
    print_warning ".claudecode.json not found in installer"
fi

echo ""

# ============================================
# 5. INSTALL AGENTS
# ============================================
print_step "Installing agent definitions..."

AGENTS_INSTALLED=0

if [ -d "$INSTALLER_DIR/.claude/agents" ]; then
    for agent in "$INSTALLER_DIR/.claude/agents"/*.md; do
        [ -f "$agent" ] || continue
        filename=$(basename "$agent")
        cp "$agent" ".claude/agents/$filename" 2>/dev/null && AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
    done
    print_success "Agent definitions installed ($AGENTS_INSTALLED agents)"
else
    print_error "Agents directory not found in installer"
    exit 1
fi

echo ""

# ============================================
# 5b. INSTALL PROTOCOLS
# ============================================
print_step "Installing protocols..."

PROTOCOLS_INSTALLED=0

if [ -d "$INSTALLER_DIR/.claude/protocols" ]; then
    for protocol in "$INSTALLER_DIR/.claude/protocols"/*.md; do
        [ -f "$protocol" ] || continue
        filename=$(basename "$protocol")
        cp "$protocol" ".claude/protocols/$filename" 2>/dev/null && PROTOCOLS_INSTALLED=$((PROTOCOLS_INSTALLED + 1))
    done
    [ "$PROTOCOLS_INSTALLED" -lt 1 ] && { print_error "No protocol files found"; exit 1; }
    print_success "Protocols installed ($PROTOCOLS_INSTALLED protocols)"
else
    print_error "Protocols directory not found in installer"
    exit 1
fi

echo ""

# ============================================
# 6. INSTALL SLASH COMMANDS
# ============================================
print_step "Installing slash commands..."

COMMANDS_INSTALLED=0

if [ -d "$INSTALLER_DIR/.claude/commands" ]; then
    for cmd in "$INSTALLER_DIR/.claude/commands"/*.md; do
        [ -f "$cmd" ] || continue
        filename=$(basename "$cmd")
        cp "$cmd" ".claude/commands/$filename" 2>/dev/null && COMMANDS_INSTALLED=$((COMMANDS_INSTALLED + 1))
    done
    print_success "Slash commands installed ($COMMANDS_INSTALLED commands)"
else
    print_warning "Commands directory not found in installer"
fi

echo ""

# ============================================
# 7. INSTALL MEMORY SYSTEM
# ============================================
print_step "Installing memory system..."

MEMORY_FILES=0
MEMORY_TMPL="$INSTALLER_DIR/templates/memory"

if [ -d "$MEMORY_TMPL" ]; then

    if [ "$IS_BETTERAGENTS" = true ]; then
        # ── CASE B: Existing BetterAgents project ────────────────────────────
        # Preserve all user data — only copy files that don't exist yet
        print_info "Case B: Preserving existing memory data (v${PREV_VERSION})"
        for template in "$MEMORY_TMPL"/*.json; do
            [ -f "$template" ] || continue
            filename=$(basename "$template")
            if [ ! -f ".claude/memory/$filename" ]; then
                cp "$template" ".claude/memory/$filename" 2>/dev/null \
                    && MEMORY_FILES=$((MEMORY_FILES + 1)) \
                    && print_info "Added missing: $filename"
            fi
        done
        [ ! -f ".claude/memory/MEMORY.md" ] \
            && [ -f "$MEMORY_TMPL/MEMORY.md" ] \
            && cp "$MEMORY_TMPL/MEMORY.md" ".claude/memory/MEMORY.md" \
            && print_info "Added missing: MEMORY.md"
        [ ! -f ".claude/memory/session-last.md" ] \
            && [ -f "$MEMORY_TMPL/session-last.md" ] \
            && cp "$MEMORY_TMPL/session-last.md" ".claude/memory/session-last.md" \
            && print_info "Added missing: session-last.md"
        [ ! -f ".claude/memory/workflow-prefs.md" ] \
            && [ -f "$MEMORY_TMPL/workflow-prefs.md" ] \
            && cp "$MEMORY_TMPL/workflow-prefs.md" ".claude/memory/workflow-prefs.md" \
            && print_info "Added missing: workflow-prefs.md"
        print_success "Memory preserved — existing data kept intact"

    else
        # ── CASE A / C: New project or existing non-BetterAgents project ─────
        # Initialize everything from clean templates
        print_info "Case A/C: Initializing memory from clean templates"
        for template in "$MEMORY_TMPL"/*.json; do
            [ -f "$template" ] || continue
            filename=$(basename "$template")
            cp "$template" ".claude/memory/$filename" 2>/dev/null \
                && MEMORY_FILES=$((MEMORY_FILES + 1))
        done
        [ -f "$MEMORY_TMPL/MEMORY.md" ] \
            && cp "$MEMORY_TMPL/MEMORY.md" ".claude/memory/MEMORY.md" \
            && print_success "MEMORY.md initialized (clean template)"
        [ -f "$MEMORY_TMPL/session-last.md" ] \
            && cp "$MEMORY_TMPL/session-last.md" ".claude/memory/session-last.md" \
            && print_success "session-last.md initialized"
        [ -f "$MEMORY_TMPL/workflow-prefs.md" ] \
            && cp "$MEMORY_TMPL/workflow-prefs.md" ".claude/memory/workflow-prefs.md" \
            && print_success "workflow-prefs.md initialized"
        print_success "Memory system initialized from scratch ($MEMORY_FILES files)"
    fi

    # Always update dashboard HTML (non-data UI artifact)
    if [ -f "$MEMORY_TMPL/dashboard.html" ]; then
        cp "$MEMORY_TMPL/dashboard.html" ".claude/memory/dashboard.html"
        print_success "Memory dashboard installed"
    fi

    # Always create templates/memory/ in target project (required for Docker volume)
    mkdir -p templates/memory
    cp "$MEMORY_TMPL/dashboard.html" "templates/memory/dashboard.html" 2>/dev/null || true
    for template in "$MEMORY_TMPL"/*.json; do
        [ -f "$template" ] || continue
        cp "$template" "templates/memory/$(basename "$template")" 2>/dev/null || true
    done
    print_success "templates/memory/ created (required for Docker volume)"
fi

echo ""

# ============================================
# 8. INSTALL HOOK SCRIPTS
# ============================================
print_step "Installing hook scripts..."

SCRIPTS_INSTALLED=0
LEGACY_SCRIPTS=("on-session-stop-summary.sh")

if [ -d "$INSTALLER_DIR/.claude/scripts" ]; then
    for script in "$INSTALLER_DIR/.claude/scripts"/*.sh; do
        [ -f "$script" ] || continue
        filename=$(basename "$script")
        skip=false
        for legacy in "${LEGACY_SCRIPTS[@]}"; do
            [ "$filename" = "$legacy" ] && skip=true && break
        done
        [ "$skip" = true ] && continue
        cp "$script" ".claude/scripts/$filename" 2>/dev/null && chmod +x ".claude/scripts/$filename" && SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
    done

    # Also install serve-dashboard.js
    if [ -f "$INSTALLER_DIR/.claude/scripts/serve-dashboard.js" ]; then
        cp "$INSTALLER_DIR/.claude/scripts/serve-dashboard.js" ".claude/scripts/serve-dashboard.js"
    fi

    # Install reset-memory.sh utility at project root for easy access
    if [ -f "$INSTALLER_DIR/reset-memory.sh" ]; then
        cp "$INSTALLER_DIR/reset-memory.sh" "reset-memory.sh"
        chmod +x "reset-memory.sh"
    fi

    print_success "Hook scripts installed ($SCRIPTS_INSTALLED scripts)"
else
    print_warning "Scripts directory not found in installer"
fi

echo ""

# ============================================
# 8b. SET RUNTIME MODE
# ============================================
echo "installed" > ".claude/.betteragents-mode"
print_success "Runtime mode set: installed (system files locked)"

echo ""

# ============================================
# 9. REGISTER PROJECT (CENTRAL CONTAINER)
# ============================================
print_step "Registering project..."

PROJECT_NAME=$(basename "$TARGET_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
PROJECT_NAME="${PROJECT_NAME:-project}"

ENV_FILE="$TARGET_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    grep -q "^BETTERAGENTS_PROJECT=" "$ENV_FILE" 2>/dev/null \
        && sed -i "s/^BETTERAGENTS_PROJECT=.*/BETTERAGENTS_PROJECT=$PROJECT_NAME/" "$ENV_FILE" \
        || echo "BETTERAGENTS_PROJECT=$PROJECT_NAME" >> "$ENV_FILE"
    sed -i '/^BETTERAGENTS_PORT=/d' "$ENV_FILE" 2>/dev/null || true
else
    printf '# BetterAgents\nBETTERAGENTS_PROJECT=%s\n' "$PROJECT_NAME" > "$ENV_FILE"
fi

print_success "Project name: ${PROJECT_NAME}"

echo ""

# ============================================
# 10. CONFIGURE HOOKS (SETTINGS.LOCAL.JSON)
# ============================================
print_step "Configuring Claude Code hooks..."

if [ ! -f ".claude/settings.local.json" ]; then
    if [ -f "$INSTALLER_DIR/.claude/settings.local.json" ]; then
        cp "$INSTALLER_DIR/.claude/settings.local.json" ".claude/settings.local.json"
        print_success "Claude Code hooks configured (settings.local.json)"
    else
        print_warning "settings.local.json not found in installer"
    fi
else
    print_info "settings.local.json already exists — skipping (to avoid overwriting customizations)"
fi

echo ""

# ============================================
# 10b. REGISTER WITH CENTRAL CONTAINER
# ============================================
print_step "Registering with central BetterAgents container..."

MEMORY_ABSOLUTE="$(cd "$TARGET_DIR/.claude/memory" 2>/dev/null && pwd || echo "$TARGET_DIR/.claude/memory")"
INSTALLER_SCRIPTS="$INSTALLER_DIR/.claude/scripts"

if command -v docker &>/dev/null && command -v jq &>/dev/null; then
    bash "$INSTALLER_SCRIPTS/generate-central-compose.sh" "$PROJECT_NAME" "$MEMORY_ABSOLUTE"
    CENTRAL_DIR="$HOME/.betteragents"

    if docker --context default ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^betteragents-central$"; then
        print_info "Restarting central container to add new project..."
        docker --context default compose -f "$CENTRAL_DIR/docker-compose.yml" up -d --force-recreate 2>/dev/null \
            && print_success "Central container updated → http://localhost:3000" \
            || print_warning "Could not restart. Run: docker --context default compose -f ~/.betteragents/docker-compose.yml up -d --force-recreate"
    else
        print_info "Starting central container for the first time..."
        docker --context default compose -f "$CENTRAL_DIR/docker-compose.yml" up -d 2>/dev/null \
            && print_success "Central container started → http://localhost:3000" \
            || print_warning "Could not start. Run: docker --context default compose -f ~/.betteragents/docker-compose.yml up -d"
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

echo '{}' > .claude/cache/skills-detection-cache.json
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
instalador/
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
NEW_VERSION=$(jq -r '.version' "$INSTALLER_DIR/config/betteragents.json" 2>/dev/null || echo "3.8.0")
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

[ -f "CLAUDE.md" ]                      || { print_warning "CLAUDE.md missing";              VERIFY_OK=false; }
[ -d ".claude/agents" ] && ls .claude/agents/*.md &>/dev/null \
                                        || { print_warning "No agent files found";            VERIFY_OK=false; }
[ -d ".claude/commands" ] && ls .claude/commands/*.md &>/dev/null \
                                        || { print_warning "No command files found";          VERIFY_OK=false; }
[ -d ".claude/memory" ]                 || { print_warning ".claude/memory missing";          VERIFY_OK=false; }
[ -f ".claude/settings.local.json" ]    || { print_warning "settings.local.json missing";     VERIFY_OK=false; }
[ -f ".claude/memory/MEMORY.md" ]       || { print_warning "MEMORY.md missing";               VERIFY_OK=false; }
[ -f ".claude/memory/dashboard.html" ]  || { print_warning "dashboard.html missing";          VERIFY_OK=false; }
[ -f ".claude/.betteragents-mode" ]     || { print_warning ".betteragents-mode missing";       VERIFY_OK=false; }

if [ "$VERIFY_OK" = true ]; then
    print_success "Installation verified ✓"
else
    print_warning "Some checks failed — review warnings above"
fi

echo ""

# ============================================
# 15. INSTALLATION SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ BetterAgents v${NEW_VERSION} — Claude Code Platform"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✅ CLAUDE.md:         AgentX orchestrator"
echo "  ✅ .claudecode.json:  Safety & efficiency config"
echo "  ✅ Agents:            $AGENTS_INSTALLED specialist agents"
echo "  ✅ Protocols:         $PROTOCOLS_INSTALLED protocol files"
echo "  ✅ Commands:          $COMMANDS_INSTALLED slash commands"
echo "  ✅ Memory:            $MEMORY_FILES files + MEMORY.md + dashboard"
echo "  ✅ Hook scripts:      $SCRIPTS_INSTALLED automation scripts"
echo "  ✅ Runtime mode:      installed (system files locked)"
echo "  ✅ Central dashboard: http://localhost:3000 (multi-project)"
echo ""
echo "🚀 Quick Start:"
echo ""
echo "  1. Open your project in Claude Code:  claude ."
echo "  2. AgentX responds automatically — just start chatting"
echo "  3. Open multi-project dashboard: http://localhost:3000"
echo ""

# ============================================
# 16. AUTO-START DASHBOARD
# ============================================
if command -v docker &>/dev/null || command -v node &>/dev/null; then
    bash ".claude/scripts/start-dashboard.sh" >/dev/null 2>&1 &
    disown
fi
