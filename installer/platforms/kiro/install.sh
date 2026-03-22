#!/bin/bash
# Kiro IDE Platform Installation Script
# Called by orchestrator: bash platforms/kiro/install.sh TARGET_DIR

set -e

# ============================================
# SETUP
# ============================================

# Get directories
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
    
# Case C: Existing non-BetterAgents project (has git/package.json/etc but no .kiro/.version)
elif [[ -d ".git" ]] || [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "go.mod" ]] || [[ -f "Cargo.toml" ]]; then
    PROJECT_CASE="C"
    print_info "Case C: Existing project detected (non-BetterAgents)"
    print_info "Clean steering templates will be installed"
    
# Case A: New project (no indicators)
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

# jq (required for memory bridge)
if ! command_exists jq; then
    print_warning "jq not found — memory bridge requires jq"
    print_info "Install: sudo apt install jq (Linux) or brew install jq (macOS)"
fi

# Kiro (optional)
if command_exists kiro; then
    KIRO_VERSION=$(kiro --version 2>/dev/null | head -1 || echo "unknown")
    print_success "Kiro IDE detected: $KIRO_VERSION"
else
    print_warning "Kiro IDE not found in PATH"
    print_info "Install from: https://kiro.ai"
fi

# git (optional)
if command_exists git; then
    print_success "git detected"
fi

# node (optional)
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
    ".kiro/agents"
    ".kiro/skills"
    ".kiro/steering"
    ".kiro/scripts"
    ".kiro/settings"
    ".kiro/hooks"
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
    # Backup existing if present
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
    
    # Case B: Preserve existing steering files
    if [[ "$PROJECT_CASE" == "B" ]]; then
        print_info "Preserving existing steering files (Case B)"
        
        # Check for missing steering files and install them
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
        
        # Install all steering templates
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
# 6. INSTALL SKILLS
# ============================================

print_step "Installing skills..."

SKILLS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.kiro/skills" ]]; then
    for skill in "$PLATFORM_DIR/templates/.kiro/skills"/*.md; do
        if [[ -f "$skill" ]]; then
            filename=$(basename "$skill")
            
            # Don't overwrite existing skills
            if [[ -f ".kiro/skills/$filename" ]]; then
                print_info "Preserving existing skill: $filename"
                continue
            fi
            
            cp "$skill" ".kiro/skills/$filename" || die "Failed to install skill: $filename"
            SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
        fi
    done
    
    if [[ $SKILLS_INSTALLED -gt 0 ]]; then
        print_success "Skills installed ($SKILLS_INSTALLED skills)"
    else
        print_info "No new skills to install"
    fi
else
    print_warning "Skills directory not found in templates"
fi

echo ""

# ============================================
# 7. INSTALL CUSTOM AGENTS (if any)
# ============================================

print_step "Installing custom agents..."

AGENTS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.kiro/agents" ]]; then
    for agent in "$PLATFORM_DIR/templates/.kiro/agents"/*.md; do
        if [[ -f "$agent" ]]; then
            filename=$(basename "$agent")
            
            # Don't overwrite existing agents
            if [[ -f ".kiro/agents/$filename" ]]; then
                print_info "Preserving existing agent: $filename"
                continue
            fi
            
            cp "$agent" ".kiro/agents/$filename" || die "Failed to install agent: $filename"
            AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
        fi
    done
    
    if [[ $AGENTS_INSTALLED -gt 0 ]]; then
        print_success "Custom agents installed ($AGENTS_INSTALLED agents)"
    else
        print_info "No custom agents to install"
    fi
else
    print_info "No custom agents directory in templates"
fi

echo ""

# ============================================
# 8. INSTALL SCRIPTS (Memory Bridge)
# ============================================

print_step "Installing scripts..."

SCRIPTS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.kiro/scripts" ]]; then
    for script in "$PLATFORM_DIR/templates/.kiro/scripts"/*; do
        if [[ -f "$script" ]]; then
            filename=$(basename "$script")
            cp "$script" ".kiro/scripts/$filename" || die "Failed to install script: $filename"
            
            # Make scripts executable
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
# 9. INSTALL HOOKS (Protocol Enforcement)
# ============================================

print_step "Installing hooks (protocol enforcement)..."

HOOKS_INSTALLED=0

if [[ -d "$PLATFORM_DIR/templates/.kiro/hooks" ]]; then
    for hook in "$PLATFORM_DIR/templates/.kiro/hooks"/*.hook; do
        if [[ -f "$hook" ]]; then
            filename=$(basename "$hook")
            cp "$hook" ".kiro/hooks/$filename" || die "Failed to install hook: $filename"
            HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
        fi
    done

    if [[ $HOOKS_INSTALLED -gt 0 ]]; then
        print_success "Hooks installed ($HOOKS_INSTALLED hooks: memory gate, session stop)"
    else
        print_info "No hooks to install"
    fi
else
    print_warning "Hooks directory not found in templates — skipping"
fi

echo ""

# ============================================
# 10. CHECK MEMORY BRIDGE COMPATIBILITY
# ============================================

print_step "Checking memory bridge compatibility..."


# Check if Claude memory system exists
if [[ -d ".betteragents/memory" ]]; then
    print_success "BetterAgents core detected — memory system available"
    print_info "Memory scripts: bash .betteragents/scripts/add-task.sh"
else
    print_warning "BetterAgents core not found — run core installer first"
fi

echo ""

# ============================================
# 10. CONFIGURE .GITIGNORE
# ============================================

print_step "Configuring .gitignore..."

GITIGNORE_ENTRIES=(
    ".kiro/cache/"
)

if [[ -f ".gitignore" ]]; then
    ADDED=0
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "$entry" ".gitignore"; then
            echo "$entry" >> ".gitignore"
            ADDED=$((ADDED + 1))
        fi
    done
    
    if [[ $ADDED -gt 0 ]]; then
        print_success ".gitignore updated ($ADDED entries added)"
    else
        print_info ".gitignore already configured"
    fi
else
    # Create new .gitignore
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        echo "$entry" >> ".gitignore"
    done
    print_success ".gitignore created"
fi

echo ""

# ============================================
# 11. WRITE VERSION FILE
# ============================================

print_step "Writing version file..."

VERSION="4.0.0"
echo "$VERSION" > ".kiro/.version"
print_success "Version file created (v$VERSION)"

echo ""

# ============================================
# 12. REGISTER PLATFORM IN state.json
# ============================================

print_step "Registering Kiro platform in state.json..."

if [[ -f ".betteragents/state.json" ]] && command_exists jq; then
    ALREADY=$(jq -r '.installed_platforms | index("kiro") // empty' ".betteragents/state.json" 2>/dev/null)
    if [[ -z "$ALREADY" ]]; then
        jq '.installed_platforms += ["kiro"]' ".betteragents/state.json" \
            > ".betteragents/state.json.tmp" && \
            mv ".betteragents/state.json.tmp" ".betteragents/state.json"
        print_success "Registered: kiro"
    else
        print_info "Already registered"
    fi
fi

echo ""

# ============================================
# INSTALLATION COMPLETE
# ============================================

print_success "Kiro IDE platform installed!"
echo ""
print_info "Next steps:"
echo "  1. Open this project in Kiro IDE"
echo "  2. Read AGENTS.md to understand AgentX orchestrator"
echo "  3. Steering files: .kiro/steering/"
echo "  4. Skills: .kiro/skills/"
echo "  5. Memory: .betteragents/memory/"
echo "  6. Dashboard: bash .betteragents/scripts/start-dashboard.sh"
echo ""

exit 0
