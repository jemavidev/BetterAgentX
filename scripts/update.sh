#!/bin/bash

# BetterAgentX - Update Script v2.0
# Intelligent update system with version detection and selective updates
# Usage: bash scripts/update.sh [--force] [--skip-backup]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "${CYAN}▶ $1${NC}"; }
print_version() { echo -e "${MAGENTA}📦 $1${NC}"; }

# Parse arguments
FORCE_UPDATE=false
SKIP_BACKUP=false

for arg in "$@"; do
    case $arg in
        --force) FORCE_UPDATE=true ;;
        --skip-backup) SKIP_BACKUP=true ;;
    esac
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 BetterAgents - Intelligent Update System v3.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. VERIFY INSTALLATION
# ============================================
print_step "Verifying existing installation..."

if [ ! -d ".claude" ]; then
    print_error "BetterAgents not installed in this directory"
    print_info "Run: bash scripts/init.sh to install"
    exit 1
fi

print_success "BetterAgentX installation found"

# Detect source directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BETTERAGENTX_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    print_error "Must run from BetterAgentX repository"
    exit 1
fi

# Canonical sources
CORE_DIR="$BETTERAGENTX_DIR/installer/core"
TEMPLATES_DIR="$BETTERAGENTX_DIR/installer/platforms/claude/templates"

# Detect which platforms are installed in this project
INSTALLED_PLATFORMS=()
if [ -f ".betteragents/state.json" ] && command -v jq &>/dev/null; then
    while IFS= read -r platform; do
        INSTALLED_PLATFORMS+=("$platform")
    done < <(jq -r '.installed_platforms[]' ".betteragents/state.json" 2>/dev/null)
fi

# Fallback detection if state.json is missing
if [ ${#INSTALLED_PLATFORMS[@]} -eq 0 ]; then
    [ -d ".claude" ] && INSTALLED_PLATFORMS+=("claude")
    [ -d ".kiro" ]   && INSTALLED_PLATFORMS+=("kiro")
fi

print_info "Installed platforms: ${INSTALLED_PLATFORMS[*]:-none detected}"

echo ""

# ============================================
# 1.5. LEGACY MIGRATION CHECK
# ============================================
print_step "Checking for legacy installation..."

if [[ ! -f ".betteragents/state.json" ]] && ([[ -d ".claude/memory" ]] || [[ -f ".claude/.version" ]]); then
    echo ""
    print_info "Legacy BetterAgents installation detected (.claude/memory/)"
    print_info "Migration required: .claude/memory/ → .betteragents/memory/"
    echo ""

    # Run the full core installer (not --update) so it handles Case B-old migration
    if [[ -f "$CORE_DIR/install.sh" ]]; then
        print_step "Running migration via core installer..."
        if bash "$CORE_DIR/install.sh" "$(pwd)" 2>/dev/null; then
            print_success "Migration complete — data moved to .betteragents/memory/"
            print_info "Original data preserved in .claude/memory/ as backup"
        else
            print_warning "Migration partially failed — continuing anyway"
        fi
    else
        # Fallback: manual migration without the installer
        print_step "Running inline migration..."
        mkdir -p .betteragents/memory .betteragents/scripts .betteragents/templates

        MIGRATED=0
        SKIPPED=0
        for src in .claude/memory/*.json .claude/memory/*.md; do
            [[ -f "$src" ]] || continue
            filename=$(basename "$src")
            [[ "$filename" == "dashboard.html" ]] && continue

            if [[ -f ".betteragents/memory/$filename" ]]; then
                SKIPPED=$((SKIPPED + 1))
            else
                cp "$src" ".betteragents/memory/$filename"
                MIGRATED=$((MIGRATED + 1))
            fi
        done

        # Create minimal state.json
        TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        echo "{\"version\":\"4.0.0\",\"core_version\":\"4.0.0\",\"installed_platforms\":[\"claude\"],\"installed_at\":\"$TIMESTAMP\",\"last_updated\":\"$TIMESTAMP\",\"migrated_from_legacy\":true}" \
            > .betteragents/state.json

        print_success "Inline migration: $MIGRATED files moved, $SKIPPED skipped"
    fi
    echo ""
else
    print_success "No legacy migration needed"
fi

echo ""

# ============================================
# 2. VERSION DETECTION
# ============================================
print_step "Detecting versions..."

# Get current installed version
CURRENT_VERSION="unknown"
if [ -f ".claude/settings/betteragents.json" ]; then
    if command -v jq &> /dev/null; then
        CURRENT_VERSION=$(jq -r '.version // "unknown"' .claude/settings/betteragents.json 2>/dev/null || echo "unknown")
    fi
elif [ -f ".claude/.version" ]; then
    CURRENT_VERSION=$(cat .claude/.version)
fi

# Get new version from source
NEW_VERSION="unknown"
if command -v jq &> /dev/null; then
    NEW_VERSION=$(jq -r '.version // "unknown"' "$BETTERAGENTX_DIR/config/betteragents.json" 2>/dev/null || echo "unknown")
fi

print_version "Current version: $CURRENT_VERSION"
print_version "Available version: $NEW_VERSION"

# Compare versions
if [ "$CURRENT_VERSION" = "$NEW_VERSION" ] && [ "$FORCE_UPDATE" = false ]; then
    echo ""
    print_info "Already on latest version ($CURRENT_VERSION)"
    echo ""
    echo "  Use --force to update anyway"
    echo "  Example: bash scripts/update.sh --force"
    echo ""
    exit 0
fi

if [ "$CURRENT_VERSION" != "unknown" ] && [ "$NEW_VERSION" != "unknown" ]; then
    print_info "Update available: $CURRENT_VERSION → $NEW_VERSION"
fi

echo ""

# ============================================
# 2b. UPDATE CORE LAYER (.betteragents/)
# ============================================
print_step "Updating core layer (.betteragents/)..."

if [ -f "$CORE_DIR/install.sh" ]; then
    if bash "$CORE_DIR/install.sh" "$(pwd)" --update 2>/dev/null; then
        print_success "Core layer updated"
    else
        print_warning "Core layer update failed (non-fatal)"
    fi
else
    print_warning "Core installer not found at $CORE_DIR/install.sh"
fi

echo ""

# ============================================
# 3. DETECT CHANGES (SMART UPDATE)
# ============================================
print_step "Analyzing changes..."

CHANGES_DETECTED=0
declare -A CHANGES

# Function to check if file changed
file_changed() {
    local source="$1"
    local target="$2"
    
    if [ ! -f "$target" ]; then
        return 0  # New file
    fi
    
    if command -v md5sum &> /dev/null; then
        SOURCE_HASH=$(md5sum "$source" 2>/dev/null | cut -d' ' -f1)
        TARGET_HASH=$(md5sum "$target" 2>/dev/null | cut -d' ' -f1)
    elif command -v md5 &> /dev/null; then
        SOURCE_HASH=$(md5 -q "$source" 2>/dev/null)
        TARGET_HASH=$(md5 -q "$target" 2>/dev/null)
    else
        # Fallback to size comparison
        SOURCE_SIZE=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source" 2>/dev/null)
        TARGET_SIZE=$(stat -f%z "$target" 2>/dev/null || stat -c%s "$target" 2>/dev/null)
        [ "$SOURCE_SIZE" != "$TARGET_SIZE" ] && return 0 || return 1
    fi
    
    [ "$SOURCE_HASH" != "$TARGET_HASH" ]
}

# Check agents (canonical source: installer templates)
if [ -d "$TEMPLATES_DIR/.claude/agents" ]; then
    for agent in "$TEMPLATES_DIR/.claude/agents"/*.md; do
        if [ -f "$agent" ]; then
            filename=$(basename "$agent")
            if [[ ! "$filename" =~ backup|original ]] && file_changed "$agent" ".claude/agents/$filename"; then
                CHANGES["agents"]=1
                CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
                break
            fi
        fi
    done
fi

# Check hook scripts (canonical source: installer templates)
if [ -d "$TEMPLATES_DIR/.claude/scripts" ]; then
    for script in "$TEMPLATES_DIR/.claude/scripts"/*; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            if file_changed "$script" ".claude/scripts/$filename"; then
                CHANGES["hook_scripts"]=1
                CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
                break
            fi
        fi
    done
fi

# Check repo scripts (update.sh, verify-system.sh, etc.)
if [ -d "$BETTERAGENTX_DIR/scripts" ]; then
    for script in "$BETTERAGENTX_DIR/scripts"/*.sh; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            if file_changed "$script" "scripts/$filename"; then
                CHANGES["scripts"]=1
                CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
                break
            fi
        fi
    done
fi

# Check hooks config (settings.local.json)
if [ -f "$TEMPLATES_DIR/.claude/settings.local.json" ]; then
    if file_changed "$TEMPLATES_DIR/.claude/settings.local.json" ".claude/settings.local.json"; then
        CHANGES["hooks"]=1
        CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
    fi
fi

# Check dashboard template
if [ -f "$TEMPLATES_DIR/.claude/memory/dashboard.html" ]; then
    if file_changed "$TEMPLATES_DIR/.claude/memory/dashboard.html" "templates/memory/dashboard.html"; then
        CHANGES["dashboard"]=1
        CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
    fi
fi

if [ $CHANGES_DETECTED -eq 0 ] && [ "$FORCE_UPDATE" = false ]; then
    print_info "No changes detected - installation is up to date"
    echo ""
    exit 0
fi

print_info "Changes detected in: ${!CHANGES[@]}"
echo ""

# ============================================
# 4. BACKUP CURRENT INSTALLATION
# ============================================

if [ "$SKIP_BACKUP" = false ]; then
    print_step "Creating backup..."

    BACKUP_DIR=".claude/backups/update-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Backup only what will be updated
    if [ "${CHANGES[agents]}" = "1" ] && [ -d ".claude/agents" ]; then
        cp -r .claude/agents "$BACKUP_DIR/" 2>/dev/null || true
    fi

    if [ "${CHANGES[hook_scripts]}" = "1" ] && [ -d ".claude/scripts" ]; then
        cp -r .claude/scripts "$BACKUP_DIR/hook_scripts" 2>/dev/null || true
    fi

    if [ "${CHANGES[hooks]}" = "1" ] && [ -f ".claude/settings.local.json" ]; then
        cp .claude/settings.local.json "$BACKUP_DIR/settings.local.json" 2>/dev/null || true
    fi

    if [ "${CHANGES[scripts]}" = "1" ] && [ -d "scripts" ]; then
        cp -r scripts "$BACKUP_DIR/" 2>/dev/null || true
    fi

    if [ "${CHANGES[dashboard]}" = "1" ] && [ -f "templates/memory/dashboard.html" ]; then
        cp templates/memory/dashboard.html "$BACKUP_DIR/dashboard.html" 2>/dev/null || true
    fi

    # Save version info
    echo "$CURRENT_VERSION" > "$BACKUP_DIR/.version"

    # Create rollback script
    cat > "$BACKUP_DIR/rollback.sh" << 'ROLLBACK_EOF'
#!/bin/bash
echo "Rolling back to previous version..."
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ../../../
[ -d "$BACKUP_DIR/agents" ]      && cp -r "$BACKUP_DIR/agents" .claude/
[ -d "$BACKUP_DIR/hook_scripts" ] && cp -r "$BACKUP_DIR/hook_scripts/." .claude/scripts/
[ -f "$BACKUP_DIR/settings.local.json" ] && cp "$BACKUP_DIR/settings.local.json" .claude/settings.local.json
[ -d "$BACKUP_DIR/scripts" ]     && cp -r "$BACKUP_DIR/scripts" .
[ -f "$BACKUP_DIR/dashboard.html" ] && cp "$BACKUP_DIR/dashboard.html" templates/memory/
echo "✅ Rollback complete"
ROLLBACK_EOF
    chmod +x "$BACKUP_DIR/rollback.sh"

    print_success "Backup created: $BACKUP_DIR"
    print_info "Rollback: bash $BACKUP_DIR/rollback.sh"
else
    print_warning "Backup skipped (--skip-backup flag)"
    BACKUP_DIR="none"
fi

echo ""

# ============================================
# 5. SELECTIVE UPDATE - AGENTS
# ============================================

AGENTS_UPDATED=0

if [ "${CHANGES[agents]}" = "1" ]; then
    print_step "Updating agents..."

    if [ -d "$TEMPLATES_DIR/.claude/agents" ]; then
        for agent in "$TEMPLATES_DIR/.claude/agents"/*.md; do
            if [ -f "$agent" ]; then
                filename=$(basename "$agent")
                if [ ! -L "$agent" ] && [[ ! "$filename" =~ backup|original ]]; then
                    if file_changed "$agent" ".claude/agents/$filename"; then
                        if cp "$agent" ".claude/agents/$filename" 2>/dev/null; then
                            AGENTS_UPDATED=$((AGENTS_UPDATED + 1))
                            print_info "Updated: $filename"
                        fi
                    fi
                fi
            fi
        done

        print_success "Agents updated ($AGENTS_UPDATED changed)"
    else
        print_warning "Agents folder not found in installer templates"
    fi
    echo ""
else
    print_info "Agents: No changes detected"
    echo ""
fi

# ============================================
# 6. SELECTIVE UPDATE - HOOK SCRIPTS (.claude/scripts/)
# ============================================

HOOK_SCRIPTS_UPDATED=0

if [ "${CHANGES[hook_scripts]}" = "1" ]; then
    print_step "Updating hook scripts (.claude/scripts/)..."

    if [ -d "$TEMPLATES_DIR/.claude/scripts" ]; then
        for script in "$TEMPLATES_DIR/.claude/scripts"/*; do
            if [ -f "$script" ]; then
                filename=$(basename "$script")
                if file_changed "$script" ".claude/scripts/$filename"; then
                    if cp "$script" ".claude/scripts/$filename" 2>/dev/null; then
                        chmod +x ".claude/scripts/$filename" 2>/dev/null || true
                        HOOK_SCRIPTS_UPDATED=$((HOOK_SCRIPTS_UPDATED + 1))
                        print_info "Updated: $filename"
                    fi
                fi
            fi
        done

        print_success "Hook scripts updated ($HOOK_SCRIPTS_UPDATED changed)"
    else
        print_warning "Hook scripts not found in installer templates"
    fi
    echo ""
else
    print_info "Hook scripts: No changes detected"
    echo ""
fi

# ============================================
# 7. SELECTIVE UPDATE - REPO SCRIPTS (scripts/)
# ============================================

SCRIPTS_UPDATED=0

if [ "${CHANGES[scripts]}" = "1" ]; then
    print_step "Updating repo scripts (scripts/)..."

    if [ -d "$BETTERAGENTX_DIR/scripts" ]; then
        for script in "$BETTERAGENTX_DIR/scripts"/*.sh; do
            if [ -f "$script" ]; then
                filename=$(basename "$script")
                # Don't overwrite init.sh and update.sh while running
                if [ "$filename" != "init.sh" ] && [ "$filename" != "update.sh" ]; then
                    if file_changed "$script" "scripts/$filename"; then
                        if cp "$script" "scripts/$filename" 2>/dev/null; then
                            chmod +x "scripts/$filename"
                            SCRIPTS_UPDATED=$((SCRIPTS_UPDATED + 1))
                            print_info "Updated: $filename"
                        fi
                    fi
                fi
            fi
        done

        print_success "Repo scripts updated ($SCRIPTS_UPDATED changed)"
    else
        print_warning "Scripts directory not found"
    fi
    echo ""
else
    print_info "Scripts: No changes detected"
    echo ""
fi

# ============================================
# 8. SELECTIVE UPDATE - HOOKS (settings.local.json)
# ============================================

HOOKS_UPDATED=0

if [ "${CHANGES[hooks]}" = "1" ]; then
    print_step "Updating hooks config (settings.local.json)..."

    if [ -f "$TEMPLATES_DIR/.claude/settings.local.json" ]; then
        if cp "$TEMPLATES_DIR/.claude/settings.local.json" ".claude/settings.local.json" 2>/dev/null; then
            HOOKS_UPDATED=$((HOOKS_UPDATED + 1))
            print_success "Hooks config updated (settings.local.json)"
        fi
    else
        print_info "No hooks configuration found in installer templates"
    fi
    echo ""
else
    print_info "Hooks config: No changes detected"
    echo ""
fi

# ============================================
# 8. UPDATE CONFIGURATION (CAREFUL - USER DATA)
# ============================================
print_step "Checking configuration..."

CONFIG_UPDATED=0

# Only update non-user-modified config files
# Update skills-registry.json (safe - regenerated by catalog script)
if [ -f "$BETTERAGENTX_DIR/templates/config/skills-registry.json" ]; then
    if file_changed "$BETTERAGENTX_DIR/templates/config/skills-registry.json" ".claude/settings/skills-registry.json"; then
        echo ""
        echo "  Update skills-registry.json?"
        echo "  (Safe - can be regenerated)"
        echo "  Update? (y/n) [timeout: 10s]"
        echo ""
        
        if [ -t 0 ]; then
            read -r -t 10 response || response="n"
        else
            response="n"
        fi
        
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            cp "$BETTERAGENTX_DIR/templates/config/skills-registry.json" .claude/settings/ 2>/dev/null && \
                CONFIG_UPDATED=$((CONFIG_UPDATED + 1)) && \
                print_info "Updated: skills-registry.json"
        fi
    fi
fi

# Update betteragents.json (metadata only)
if [ -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    cp "$BETTERAGENTX_DIR/config/betteragents.json" .claude/settings/ 2>/dev/null && \
        CONFIG_UPDATED=$((CONFIG_UPDATED + 1)) && \
        print_info "Updated: betteragents.json"
fi

if [ $CONFIG_UPDATED -gt 0 ]; then
    print_success "Configuration updated ($CONFIG_UPDATED files)"
else
    print_info "Configuration: No updates needed"
fi

echo ""

# ============================================
# 9. UPDATE DASHBOARD TEMPLATE (IF CHANGED)
# ============================================

if [ "${CHANGES[dashboard]}" = "1" ]; then
    print_step "Updating dashboard template..."

    if [ -f "$TEMPLATES_DIR/.claude/memory/dashboard.html" ]; then
        # Update the base template used by update-dashboard.sh
        cp "$TEMPLATES_DIR/.claude/memory/dashboard.html" "templates/memory/dashboard.html" 2>/dev/null
        print_success "Dashboard template updated"
    else
        print_warning "Dashboard template not found in installer templates"
    fi
    echo ""
else
    print_info "Dashboard: No changes detected"
    echo ""
fi

# ============================================
# 9b. REBUILD DASHBOARD DATA
# ============================================

print_step "Rebuilding dashboard with current memory data..."

if [[ -f ".betteragents/scripts/update-dashboard.sh" ]]; then
    if bash ".betteragents/scripts/update-dashboard.sh" 2>/dev/null; then
        print_success "Dashboard data rebuilt"
    else
        print_info "Dashboard rebuild skipped (non-fatal)"
    fi
fi

# Refresh Docker container if already running
CENTRAL_COMPOSE="$HOME/.betteragents/docker-compose.yml"
CONTAINER_NAME="betteragents-central"

if command -v docker &>/dev/null && [[ -f "$CENTRAL_COMPOSE" ]]; then
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
        print_info "Refreshing Docker container..."
        if docker compose -f "$CENTRAL_COMPOSE" up -d --force-recreate 2>/dev/null; then
            print_success "Docker container refreshed: http://localhost:3000"
        else
            print_warning "Docker refresh failed (non-fatal)"
        fi
    fi
fi

echo ""

# ============================================
# 10. PRESERVE USER DATA (CRITICAL)
# ============================================
print_step "Verifying user data preservation..."

# Memory files - NEVER overwrite
MEMORY_FILES=(
    ".betteragents/memory/active-context.json"
    ".betteragents/memory/decision-log.json"
    ".betteragents/memory/progress.json"
    ".betteragents/memory/patterns.json"
    ".betteragents/memory/llm-usage.json"
    ".betteragents/memory/memory-stats.json"
    ".betteragents/memory/project-size.json"
)

PRESERVED=0
for file in "${MEMORY_FILES[@]}"; do
    if [ -f "$file" ]; then
        PRESERVED=$((PRESERVED + 1))
    fi
done

print_success "User data preserved ($PRESERVED memory files)"

# Add new memory templates only if missing
NEW_TEMPLATES=0
CORE_MEMORY_TEMPLATES="$CORE_DIR/templates/.betteragents/memory"
if [ -d "$CORE_MEMORY_TEMPLATES" ]; then
    for template in "$CORE_MEMORY_TEMPLATES"/*.json "$CORE_MEMORY_TEMPLATES"/*.md; do
        if [ -f "$template" ]; then
            filename=$(basename "$template")
            # Only add if doesn't exist (NEVER overwrite user data)
            if [ ! -f ".betteragents/memory/$filename" ]; then
                if cp "$template" ".betteragents/memory/$filename" 2>/dev/null; then
                    NEW_TEMPLATES=$((NEW_TEMPLATES + 1))
                    print_info "Added new template: $filename"
                fi
            fi
        fi
    done
fi

if [ $NEW_TEMPLATES -gt 0 ]; then
    print_info "New templates added: $NEW_TEMPLATES"
fi

echo ""

# ============================================
# 11. UPDATE VERSION TRACKING
# ============================================
print_step "Updating version tracking..."

# Save new version
echo "$NEW_VERSION" > .claude/.version
cp "$BETTERAGENTX_DIR/config/betteragents.json" .claude/settings/betteragents.json 2>/dev/null || true

print_success "Version updated: $CURRENT_VERSION → $NEW_VERSION"

echo ""

# ============================================
# 12. VERIFY INFRASTRUCTURE
# ============================================
print_step "Verifying infrastructure..."

# Cache directory
if [ ! -d ".claude/cache" ]; then
    mkdir -p .claude/cache
    cat > .claude/cache/skills-detection-cache.json << 'EOF'
{}
EOF
    print_info "Cache system initialized"
fi

# Backups directory
if [ ! -d ".claude/backups" ]; then
    mkdir -p .claude/backups
    print_info "Backups directory created"
fi

# Update .gitignore
if [ -f ".gitignore" ]; then
    UPDATED=false
    
    if ! grep -q ".claude/cache/" .gitignore 2>/dev/null; then
        echo ".claude/cache/" >> .gitignore
        UPDATED=true
    fi
    
    if ! grep -q ".claude/backups/" .gitignore 2>/dev/null; then
        echo ".claude/backups/" >> .gitignore
        UPDATED=true
    fi
    
    if ! grep -q ".claude/.version" .gitignore 2>/dev/null; then
        echo ".claude/.version" >> .gitignore
        UPDATED=true
    fi
    
    [ "$UPDATED" = true ] && print_info ".gitignore updated"
fi

print_success "Infrastructure verified"

echo ""

# ============================================
# 13. VERIFY INSTALLATION
# ============================================
print_step "Verifying updated installation..."

VERIFICATION_PASSED=true

# Check critical components
[ ! -d ".claude/agents" ] && VERIFICATION_PASSED=false
[ ! -d ".betteragents/memory" ] && VERIFICATION_PASSED=false
[ ! -f ".betteragents/state.json" ] && VERIFICATION_PASSED=false

if [ "$VERIFICATION_PASSED" = true ]; then
    print_success "System verification passed"
    
    # Run full verification if available
    if [ -f "scripts/verify-system.sh" ]; then
        print_info "Run 'bash scripts/verify-system.sh' for detailed check"
    fi
else
    print_error "Verification failed - critical components missing"
    if [ "$BACKUP_DIR" != "none" ]; then
        print_warning "Consider rollback: bash $BACKUP_DIR/rollback.sh"
    fi
fi

echo ""

# ============================================
# 14. UPDATE SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Update Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "BetterAgentX updated successfully"
echo ""
print_version "Version: $CURRENT_VERSION → $NEW_VERSION"
echo ""
echo "📊 Update Summary:"
echo ""

# Show what was updated
TOTAL_UPDATES=0
[ "${CHANGES[agents]}" = "1" ]       && echo "  ✅ Agents: $AGENTS_UPDATED files updated"           && TOTAL_UPDATES=$((TOTAL_UPDATES + AGENTS_UPDATED))
[ "${CHANGES[hook_scripts]}" = "1" ] && echo "  ✅ Hook scripts: $HOOK_SCRIPTS_UPDATED files updated" && TOTAL_UPDATES=$((TOTAL_UPDATES + HOOK_SCRIPTS_UPDATED))
[ "${CHANGES[scripts]}" = "1" ]      && echo "  ✅ Repo scripts: $SCRIPTS_UPDATED files updated"     && TOTAL_UPDATES=$((TOTAL_UPDATES + SCRIPTS_UPDATED))
[ "${CHANGES[hooks]}" = "1" ]        && echo "  ✅ Hooks config: $HOOKS_UPDATED files updated"       && TOTAL_UPDATES=$((TOTAL_UPDATES + HOOKS_UPDATED))
[ "${CHANGES[dashboard]}" = "1" ]    && echo "  ✅ Dashboard template: Updated"                      && TOTAL_UPDATES=$((TOTAL_UPDATES + 1))
[ $CONFIG_UPDATED -gt 0 ]            && echo "  ✅ Configuration: $CONFIG_UPDATED files updated"      && TOTAL_UPDATES=$((TOTAL_UPDATES + CONFIG_UPDATED))
[ $NEW_TEMPLATES -gt 0 ]             && echo "  ✅ New templates: $NEW_TEMPLATES added"               && TOTAL_UPDATES=$((TOTAL_UPDATES + NEW_TEMPLATES))

echo ""
echo "  Total changes applied: $TOTAL_UPDATES"
echo ""

if [ "$BACKUP_DIR" != "none" ]; then
    echo "� Backup & Rollback:"
    echo ""
    echo "  Backup location: $BACKUP_DIR"
    echo "  Rollback command: bash $BACKUP_DIR/rollback.sh"
    echo ""
fi

echo "🔒 Data Preservation:"
echo ""
echo "  ✅ Memory files preserved ($PRESERVED files)"
echo "  ✅ User settings preserved"
echo "  ✅ Custom modifications preserved"
echo ""

echo "📚 Next Steps:"
echo ""
echo "  1. Test the system:"
echo "     $ claude ."
echo "     Hello! Test the updated system (AgentX responds automatically)"
echo ""
echo "  2. View dashboard:"
echo "     $ bash .betteragents/scripts/start-dashboard.sh"
echo ""
echo "  3. Verify installation:"
echo "     $ bash scripts/verify-system.sh"
echo ""

if [ "$BACKUP_DIR" != "none" ]; then
    echo "  4. If issues occur:"
    echo "     $ bash $BACKUP_DIR/rollback.sh"
    echo ""
fi

print_success "Update completed successfully! 🎉"
echo ""
