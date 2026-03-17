#!/bin/bash
# Kiro IDE Platform Validation Script
# Called by orchestrator: bash platforms/kiro/validate.sh TARGET_DIR

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

print_step "Validating Kiro IDE installation..."
echo ""

# ============================================
# VALIDATION CHECKS
# ============================================

ERRORS=0
WARNINGS=0

# ============================================
# 1. CHECK REQUIRED FILES
# ============================================

print_step "Checking required files..."

REQUIRED_FILES=(
    "AGENTS.md"
    ".kiro/steering"
    ".kiro/scripts"
    ".kiro/.version"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -e "$file" ]]; then
        print_error "Missing: $file"
        ERRORS=$((ERRORS + 1))
    else
        print_success "Found: $file"
    fi
done

echo ""

# ============================================
# 2. CHECK STEERING FILES
# ============================================

print_step "Checking steering files..."

if [[ -d ".kiro/steering" ]]; then
    STEERING_COUNT=$(find ".kiro/steering" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $STEERING_COUNT -ge 1 ]]; then
        print_success "Steering files: $STEERING_COUNT found ✓"
        
        # List steering files
        echo "  Installed steering files:"
        for steering in .kiro/steering/*.md; do
            if [[ -f "$steering" ]]; then
                echo "    • $(basename "$steering")"
            fi
        done
    else
        print_warning "No steering files found"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    print_error "Steering directory not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 3. CHECK SKILLS
# ============================================

print_step "Checking skills..."

if [[ -d ".kiro/skills" ]]; then
    SKILL_COUNT=$(find ".kiro/skills" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $SKILL_COUNT -ge 1 ]]; then
        print_success "Skills: $SKILL_COUNT found ✓"
    else
        print_info "Skills: No skills installed (optional)"
    fi
else
    print_info "Skills directory not found (optional)"
fi

echo ""

# ============================================
# 4. CHECK CUSTOM AGENTS
# ============================================

print_step "Checking custom agents..."

if [[ -d ".kiro/agents" ]]; then
    AGENT_COUNT=$(find ".kiro/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $AGENT_COUNT -ge 1 ]]; then
        print_success "Custom agents: $AGENT_COUNT found ✓"
        
        # List agents
        echo "  Installed agents:"
        for agent in .kiro/agents/*.md; do
            if [[ -f "$agent" ]]; then
                echo "    • $(basename "$agent" .md)"
            fi
        done
    else
        print_info "Custom agents: None installed (optional)"
    fi
else
    print_info "Agents directory not found (optional)"
fi

echo ""

# ============================================
# 5. CHECK SCRIPTS
# ============================================

print_step "Checking scripts..."

CRITICAL_SCRIPTS=(
    ".kiro/scripts/update-memory.sh"
)

SCRIPTS_MISSING=0
for script in "${CRITICAL_SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
        print_warning "Missing script: $script"
        SCRIPTS_MISSING=$((SCRIPTS_MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
    elif [[ ! -x "$script" ]]; then
        print_warning "Script not executable: $script"
        WARNINGS=$((WARNINGS + 1))
    else
        print_success "Found: $(basename "$script")"
    fi
done

if [[ $SCRIPTS_MISSING -eq 0 ]]; then
    echo ""
    print_success "Scripts: All critical scripts present ✓"
fi

echo ""

# ============================================
# 6. CHECK VERSION FILE
# ============================================

print_step "Checking version..."

if [[ -f ".kiro/.version" ]]; then
    VERSION=$(cat ".kiro/.version" 2>/dev/null || echo "unknown")
    print_success "Version: $VERSION"
else
    print_warning "Version file not found"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# 7. CHECK MEMORY BRIDGE COMPATIBILITY
# ============================================

print_step "Checking memory bridge compatibility..."

if [[ -d ".claude/memory" ]] && [[ -d ".claude/scripts" ]]; then
    print_success "Claude memory system detected ✓"
    print_info "Memory bridge available"
    
    # Check if Claude memory scripts exist
    CLAUDE_SCRIPTS=(
        ".claude/scripts/add-decision.sh"
        ".claude/scripts/add-task.sh"
        ".claude/scripts/update-context.sh"
    )
    
    CLAUDE_SCRIPTS_FOUND=0
    for script in "${CLAUDE_SCRIPTS[@]}"; do
        if [[ -f "$script" ]]; then
            CLAUDE_SCRIPTS_FOUND=$((CLAUDE_SCRIPTS_FOUND + 1))
        fi
    done
    
    if [[ $CLAUDE_SCRIPTS_FOUND -eq 3 ]]; then
        print_success "Claude memory scripts: $CLAUDE_SCRIPTS_FOUND/3 ✓"
    else
        print_warning "Claude memory scripts: $CLAUDE_SCRIPTS_FOUND/3 (incomplete)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    print_info "Claude memory system not found (optional)"
    print_info "Install Claude platform for memory bridge functionality"
fi

echo ""

# ============================================
# 8. CHECK DIRECTORY STRUCTURE
# ============================================

print_step "Checking directory structure..."

REQUIRED_DIRS=(
    ".kiro/steering"
    ".kiro/scripts"
)

OPTIONAL_DIRS=(
    ".kiro/agents"
    ".kiro/skills"
    ".kiro/settings"
)

DIRS_MISSING=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        print_error "Missing required directory: $dir"
        DIRS_MISSING=$((DIRS_MISSING + 1))
        ERRORS=$((ERRORS + 1))
    fi
done

for dir in "${OPTIONAL_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        print_info "Optional directory not found: $dir"
    fi
done

if [[ $DIRS_MISSING -eq 0 ]]; then
    print_success "Directory structure: Complete ✓"
else
    print_error "Directory structure: $DIRS_MISSING required directories missing"
fi

echo ""

# ============================================
# 9. CHECK AGENTS.MD CONTENT
# ============================================

print_step "Checking AGENTS.md..."

if [[ -f "AGENTS.md" ]]; then
    # Check if it contains Kiro-specific content
    if grep -q "Kiro" "AGENTS.md" 2>/dev/null; then
        print_success "AGENTS.md: Contains Kiro configuration ✓"
    else
        print_info "AGENTS.md: Universal format (compatible)"
    fi
    
    # Check if it's the BetterAgents orchestrator
    if grep -q "AgentX" "AGENTS.md" 2>/dev/null; then
        print_success "AGENTS.md: AgentX orchestrator detected ✓"
    else
        print_warning "AGENTS.md: May not be BetterAgents orchestrator"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    print_error "AGENTS.md not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 10. CHECK DEPENDENCIES
# ============================================

print_step "Checking dependencies..."

# jq (required for memory bridge)
if command_exists jq; then
    print_success "jq: Installed ✓"
else
    print_warning "jq: Not found (required for memory bridge)"
    WARNINGS=$((WARNINGS + 1))
fi

# Kiro IDE (optional)
if command_exists kiro; then
    KIRO_VERSION=$(kiro --version 2>/dev/null | head -1 || echo "unknown")
    print_success "Kiro IDE: $KIRO_VERSION ✓"
else
    print_info "Kiro IDE: Not found in PATH (optional)"
fi

echo ""

# ============================================
# VALIDATION SUMMARY
# ============================================

echo ""
print_step "Validation Summary"
echo ""

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    print_success "✓ Installation is VALID — No errors or warnings"
    echo ""
    print_info "Kiro IDE platform is fully functional"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    print_success "✓ Installation is VALID — $WARNINGS warnings"
    echo ""
    print_info "Kiro IDE platform is functional with minor issues"
    exit 0
else
    print_error "✗ Installation is INVALID — $ERRORS errors, $WARNINGS warnings"
    echo ""
    print_error "Kiro IDE platform may not function correctly"
    print_info "Run installation again to fix errors"
    exit 1
fi
