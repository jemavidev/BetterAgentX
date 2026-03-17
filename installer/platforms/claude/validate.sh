#!/bin/bash
# Claude Code Platform Validation Script
# Called by orchestrator: bash platforms/claude/validate.sh TARGET_DIR

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

print_step "Validating Claude Code installation..."
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
    "CLAUDE.md"
    ".claude/agents"
    ".claude/commands"
    ".claude/protocols"
    ".claude/memory/MEMORY.md"
    ".claude/scripts"
    ".claude/settings.local.json"
    ".claude/.version"
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
# 2. CHECK AGENT COUNT
# ============================================

print_step "Checking agents..."

if [[ -d ".claude/agents" ]]; then
    AGENT_COUNT=$(find ".claude/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $AGENT_COUNT -eq 12 ]]; then
        print_success "Agents: $AGENT_COUNT/12 ✓"
    elif [[ $AGENT_COUNT -lt 12 ]]; then
        print_warning "Agents: $AGENT_COUNT/12 (expected 12)"
        WARNINGS=$((WARNINGS + 1))
    else
        print_info "Agents: $AGENT_COUNT/12 (more than expected)"
    fi
    
    # List agents
    echo "  Installed agents:"
    for agent in .claude/agents/*.md; do
        if [[ -f "$agent" ]]; then
            echo "    • $(basename "$agent" .md)"
        fi
    done
else
    print_error "Agents directory not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 3. CHECK COMMAND COUNT
# ============================================

print_step "Checking commands..."

if [[ -d ".claude/commands" ]]; then
    COMMAND_COUNT=$(find ".claude/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $COMMAND_COUNT -ge 76 ]]; then
        print_success "Commands: $COMMAND_COUNT/76+ ✓"
    elif [[ $COMMAND_COUNT -ge 70 ]]; then
        print_warning "Commands: $COMMAND_COUNT/76+ (slightly below expected)"
        WARNINGS=$((WARNINGS + 1))
    else
        print_error "Commands: $COMMAND_COUNT/76+ (too few)"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_error "Commands directory not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 4. CHECK PROTOCOL COUNT
# ============================================

print_step "Checking protocols..."

if [[ -d ".claude/protocols" ]]; then
    PROTOCOL_COUNT=$(find ".claude/protocols" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ $PROTOCOL_COUNT -eq 7 ]]; then
        print_success "Protocols: $PROTOCOL_COUNT/7 ✓"
    elif [[ $PROTOCOL_COUNT -lt 7 ]]; then
        print_warning "Protocols: $PROTOCOL_COUNT/7 (expected 7)"
        WARNINGS=$((WARNINGS + 1))
    else
        print_info "Protocols: $PROTOCOL_COUNT/7 (more than expected)"
    fi
else
    print_error "Protocols directory not found"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 5. CHECK MEMORY SYSTEM
# ============================================

print_step "Checking memory system..."

MEMORY_FILES=(
    ".claude/memory/MEMORY.md"
    ".claude/memory/active-context.json"
    ".claude/memory/decision-log.json"
    ".claude/memory/progress.json"
    ".claude/memory/patterns.json"
    ".claude/memory/dashboard.html"
)

MEMORY_MISSING=0
for file in "${MEMORY_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        print_warning "Missing memory file: $file"
        MEMORY_MISSING=$((MEMORY_MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done

if [[ $MEMORY_MISSING -eq 0 ]]; then
    print_success "Memory system: All core files present ✓"
else
    print_warning "Memory system: $MEMORY_MISSING files missing"
fi

echo ""

# ============================================
# 6. CHECK SCRIPTS
# ============================================

print_step "Checking scripts..."

CRITICAL_SCRIPTS=(
    ".claude/scripts/update-memory.sh"
    ".claude/scripts/add-decision.sh"
    ".claude/scripts/add-task.sh"
    ".claude/scripts/update-context.sh"
    ".claude/scripts/start-dashboard.sh"
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
    fi
done

if [[ $SCRIPTS_MISSING -eq 0 ]]; then
    print_success "Scripts: All critical scripts present ✓"
else
    print_warning "Scripts: $SCRIPTS_MISSING scripts missing"
fi

echo ""

# ============================================
# 7. CHECK VERSION FILE
# ============================================

print_step "Checking version..."

if [[ -f ".claude/.version" ]]; then
    VERSION=$(cat ".claude/.version" 2>/dev/null || echo "unknown")
    print_success "Version: $VERSION"
else
    print_warning "Version file not found"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# 8. VALIDATE JSON FILES
# ============================================

print_step "Validating JSON files..."

if command_exists jq; then
    JSON_ERRORS=0
    
    for json_file in .claude/memory/*.json; do
        if [[ -f "$json_file" ]]; then
            if jq empty "$json_file" 2>/dev/null; then
                print_success "Valid JSON: $(basename "$json_file")"
            else
                print_error "Invalid JSON: $(basename "$json_file")"
                JSON_ERRORS=$((JSON_ERRORS + 1))
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done
    
    if [[ $JSON_ERRORS -eq 0 ]]; then
        echo ""
        print_success "All JSON files valid ✓"
    fi
else
    print_warning "jq not found — skipping JSON validation"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# 9. CHECK DIRECTORY STRUCTURE
# ============================================

print_step "Checking directory structure..."

REQUIRED_DIRS=(
    ".claude/agents"
    ".claude/commands"
    ".claude/protocols"
    ".claude/memory"
    ".claude/scripts"
    ".claude/cache"
    ".claude/backups"
)

DIRS_MISSING=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        print_warning "Missing directory: $dir"
        DIRS_MISSING=$((DIRS_MISSING + 1))
        WARNINGS=$((WARNINGS + 1))
    fi
done

if [[ $DIRS_MISSING -eq 0 ]]; then
    print_success "Directory structure: Complete ✓"
else
    print_warning "Directory structure: $DIRS_MISSING directories missing"
fi

echo ""

# ============================================
# 10. CHECK CONFIGURATION FILES
# ============================================

print_step "Checking configuration..."

if [[ -f ".claudecode.json" ]]; then
    if command_exists jq; then
        if jq empty ".claudecode.json" 2>/dev/null; then
            print_success ".claudecode.json: Valid ✓"
        else
            print_error ".claudecode.json: Invalid JSON"
            ERRORS=$((ERRORS + 1))
        fi
    else
        print_info ".claudecode.json: Present (validation skipped)"
    fi
else
    print_warning ".claudecode.json not found"
    WARNINGS=$((WARNINGS + 1))
fi

if [[ -f ".claude/settings.local.json" ]]; then
    if command_exists jq; then
        if jq empty ".claude/settings.local.json" 2>/dev/null; then
            print_success "settings.local.json: Valid ✓"
        else
            print_error "settings.local.json: Invalid JSON"
            ERRORS=$((ERRORS + 1))
        fi
    else
        print_info "settings.local.json: Present (validation skipped)"
    fi
else
    print_warning "settings.local.json not found"
    WARNINGS=$((WARNINGS + 1))
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
    print_info "Claude Code platform is fully functional"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    print_success "✓ Installation is VALID — $WARNINGS warnings"
    echo ""
    print_info "Claude Code platform is functional with minor issues"
    exit 0
else
    print_error "✗ Installation is INVALID — $ERRORS errors, $WARNINGS warnings"
    echo ""
    print_error "Claude Code platform may not function correctly"
    print_info "Run installation again to fix errors"
    exit 1
fi
