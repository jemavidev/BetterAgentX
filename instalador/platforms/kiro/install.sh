#!/bin/bash
# Kiro IDE Platform Installation Script
# Called by orchestrator: bash platforms/kiro/install.sh TARGET_DIR

set -e

# ============================================
# SETUP
# ============================================

TARGET_DIR="$1"
PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$PLATFORM_DIR/../.." && pwd)"

# Source core libraries
source "$INSTALLER_DIR/lib/core.sh"

# Validate target
if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR"
fi

validate_directory "$TARGET_DIR"
cd "$TARGET_DIR"

print_step "Installing Kiro IDE platform..."

# ============================================
# 1. DETECT PROJECT TYPE (Case A/B/C)
# ============================================

print_step "Detecting project type..."

PROJECT_CASE=""

# Case B: Existing BetterAgents installation (has .kiro/.version)
if [[ -f ".kiro/.version" ]]; then
    PROJECT_CASE="B"
    EXISTING_VERSION=$(cat ".kiro/.version" 2>/dev/null || echo "unknown")
    print_info "Case B: Existing BetterAgents installation detected (v$EXISTING_VERSION)"
    print_info "Steering files will be preserved"

# Case C: Existing non-BetterAgents project
elif [[ -d ".git" ]] || [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "go.mod" ]] || [[ -f "Cargo.toml" ]]; then
    PROJECT_CASE="C"
    print_info "Case C: Existing project detected (non-BetterAgents)"
    print_info "Clean steering templates will be installed"

# Case A: New project
else
    PROJECT_CASE="A"
    print_info "Case A: New project detected"
    print_info "Clean steering templates will be installed"
fi

echo ""

# ============================================
# 2. CHECK DEPENDENCIES
# ============================================

print_step "Checking dependencies..."

if ! command_exists jq; then
    print_warning "jq not found — memory bridge requires jq"
    print_info "Install: sudo apt install jq (Linux) or brew install jq (macOS)"
fi

if command_exists kiro; then
    KIRO_VERSION=$(kiro --version 2>/dev/null | head -1 || echo "unknown")
    print_success "Kiro IDE detected: $KIRO_VERSION"
else
    print_warning "Kiro IDE not found in PATH"
    print_info "Install from: https://kiro.ai"
fi

if command_exists git; then
    print_success "git detected"
fi

if command_exists node; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
    print_success "node detected: $NODE_VERSION"
fi

echo ""

# ============================================
# 3. CREATE DIRECTORY STRUCTURE
# ============================================

print_step "Creating directory structure..."

DIRECTORIES=(
    ".kiro/steering"
    ".kiro/scripts"
)

for dir in "${DIRECTORIES[@]}"; do
    ensure_directory "$dir"
done

print_success "Directory structure created"
echo ""

# ============================================
# 4. INSTALL ORCHESTRATOR (AGENTS.md)
# ============================================

print_step "Installing AGENTS.md orchestrator..."

if [[ -f "$PLATFORM_DIR/templates/AGENTS.md" ]]; then
    if [[ -f "AGENTS.md" ]]; then
        backup_file "AGENTS.md"
    fi
    cp "$PLATFORM_DIR/templates/AGENTS.md" "AGENTS.md" || die "Failed to install AGENTS.md"
    print_success "AGENTS.md installed"
else
    die "AGENTS.md template not found"
fi

echo ""

# ============================================
# 5. INSTALL STEERING FILES (Kiro's Memory System)
# ============================================

print_step "Installing steering files..."

STEERING_FILES=0

if [[ -d "$PLATFORM_DIR/templates/.kiro/steering" ]]; then

    # Case B: Preserve existing steering files — only install missing ones
    if [[ "$PROJECT_CASE" == "B" ]]; then
        print_info "Preserving existing steering files (Case B)"
        for template in "$PLATFORM_DIR/templates/.kiro/steering"/*.md; do
            if [[ -f "$template" ]]; then
                filename=$(basename "$template")
                if [[ ! -f ".kiro/steering/$filename" ]]; then
                    cp "$template" ".kiro/steering/$filename"
                    STEERING_FILES=$((STEERING_FILES + 1))
                    print_info "Installed missing: $filename"
                fi
            fi
        done
        print_success "Steering files updated ($STEERING_FILES new files)"

    # Case A & C: Install clean templates
    else
        print_info "Installing clean steering templates (Case $PROJECT_CASE)"
        for template in "$PLATFORM_DIR/templates/.kiro/steering"/*.md; do
            if [[ -f "$template" ]]; then
                filename=$(basename "$template")
                # Don't overwrite existing files in Case C
                if [[ "$PROJECT_CASE" == "C" ]] && [[ -f ".kiro/steering/$filename" ]]; then
                    print_info "Preserving existing: $filename"
                    continue
                fi
                cp "$template" ".kiro/steering/$filename"
                STEERING_FILES=$((STEERING_FILES + 1))
            fi
        done
        print_success "Steering files initialized ($STEERING_FILES files)"
    fi

else
    die "Steering templates not found"
fi

echo ""

# ============================================
# 6. INSTALL SCRIPTS (Memory Bridge)
# ============================================

print_step "Installing scripts..."

SCRIPTS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.kiro/scripts" ]]; then
    for script in "$PLATFORM_DIR/templates/.kiro/scripts"/*; do
        if [[ -f "$script" ]]; then
            filename=$(basename "$script")
            cp "$script" ".kiro/scripts/$filename" || die "Failed to install script: $filename"
            chmod +x ".kiro/scripts/$filename" 2>/dev/null || true
            SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
        fi
    done
    print_success "Scripts installed ($SCRIPTS_INSTALLED scripts)"
else
    die "Scripts directory not found in templates"
fi

echo ""

# ============================================
# 7. SET RUNTIME MODE
# ============================================
# Note: Kiro does not install .claude/ — runtime mode file goes in project root

echo "installed" > ".betteragents-mode"
print_success "Runtime mode set: installed"

echo ""

# ============================================
# 8. CHECK MEMORY BRIDGE COMPATIBILITY
# ============================================

print_step "Checking memory bridge compatibility..."

if [[ -d ".claude/memory" ]] && [[ -d ".claude/scripts" ]]; then
    print_success "Claude memory system detected — memory bridge available"
    print_info "Kiro can use: bash .kiro/scripts/update-memory.sh"
else
    print_warning "Claude memory system not found"
    print_info "Memory bridge requires Claude platform to be installed"
    print_info "Install Claude platform for full memory functionality"
fi

echo ""

# ============================================
# 9. CONFIGURE .GITIGNORE
# ============================================

print_step "Configuring .gitignore..."

if [[ -f ".gitignore" ]]; then
    if ! grep -qF ".kiro/cache/" ".gitignore"; then
        echo ".kiro/cache/" >> ".gitignore"
        print_success ".gitignore updated"
    else
        print_info ".gitignore already configured"
    fi
else
    echo ".kiro/cache/" > ".gitignore"
    print_success ".gitignore created"
fi

echo ""

# ============================================
# 10. WRITE VERSION FILE
# ============================================

print_step "Writing version file..."

VERSION="3.8.0"
echo "$VERSION" > ".kiro/.version"
print_success "Version file created (v$VERSION)"

echo ""

# ============================================
# INSTALLATION COMPLETE
# ============================================

print_success "Kiro IDE platform installed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Open this project in Kiro IDE"
echo "  2. Read AGENTS.md to understand AgentX orchestrator"
echo "  3. Steering files available in .kiro/steering/"
echo ""
print_info "Memory Bridge:"
echo "  • bash .kiro/scripts/update-memory.sh — Update project memory"
echo ""

exit 0
