#!/bin/bash
# Claude Code Platform Uninstallation Script
# Called by orchestrator: bash platforms/claude/uninstall.sh TARGET_DIR

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

print_step "Uninstalling Claude Code platform..."
echo ""

# ============================================
# 1. CONFIRM UNINSTALLATION
# ============================================

print_warning "This will remove:"
echo "  • .claude/ directory (agents, commands, protocols, scripts)"
echo "  • CLAUDE.md orchestrator"
echo "  • .claudecode.json configuration"
echo ""
print_info "Memory files will be backed up to .claude/backups/"
echo ""

read -p "Continue with uninstallation? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    print_info "Uninstallation cancelled"
    exit 0
fi

echo ""

# ============================================
# 2. BACKUP MEMORY FILES
# ============================================

print_step "Backing up memory files..."

if [[ -d ".claude/memory" ]]; then
    BACKUP_DIR=".claude/backups/uninstall-$(date +%Y%m%d_%H%M%S)"
    ensure_directory "$BACKUP_DIR"
    
    # Backup all memory files
    if cp -r .claude/memory/* "$BACKUP_DIR/" 2>/dev/null; then
        print_success "Memory files backed up to: $BACKUP_DIR"
    else
        print_warning "Failed to backup some memory files"
    fi
else
    print_info "No memory files to backup"
fi

echo ""

# ============================================
# 3. UNREGISTER FROM CENTRAL CONTAINER
# ============================================

print_step "Unregistering from central container..."

# Get project path
PROJECT_PATH="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_PATH")"

# Remove from central registry if it exists
CENTRAL_DIR="$HOME/.betteragents"
REGISTRY_FILE="$CENTRAL_DIR/projects.json"

if [[ -f "$REGISTRY_FILE" ]]; then
    if command_exists jq; then
        # Remove this project from registry
        TEMP_FILE="${REGISTRY_FILE}.tmp"
        jq "del(.projects[] | select(.path == \"$PROJECT_PATH\"))" "$REGISTRY_FILE" > "$TEMP_FILE" 2>/dev/null || true
        
        if [[ -f "$TEMP_FILE" ]]; then
            mv "$TEMP_FILE" "$REGISTRY_FILE"
            print_success "Unregistered from central container"
        fi
    else
        print_warning "jq not found — manual registry cleanup may be needed"
    fi
else
    print_info "No central registry found"
fi

# Regenerate central docker-compose.yml if script exists
if [[ -f ".claude/scripts/generate-central-compose.sh" ]]; then
    bash ".claude/scripts/generate-central-compose.sh" 2>/dev/null || true
fi

echo ""

# ============================================
# 4. REMOVE .CLAUDE/ DIRECTORY
# ============================================

print_step "Removing .claude/ directory..."

if [[ -d ".claude" ]]; then
    # Move to trash instead of rm -rf for safety
    TRASH_DIR=".claude-removed-$(date +%Y%m%d_%H%M%S)"
    
    if mv ".claude" "$TRASH_DIR"; then
        print_success ".claude/ moved to: $TRASH_DIR"
        print_info "You can safely delete $TRASH_DIR after verifying the uninstallation"
    else
        print_error "Failed to remove .claude/ directory"
    fi
else
    print_info ".claude/ directory not found"
fi

echo ""

# ============================================
# 5. REMOVE CLAUDE.MD
# ============================================

print_step "Removing CLAUDE.md..."

if [[ -f "CLAUDE.md" ]]; then
    # Backup before removing
    BACKUP_NAME="CLAUDE.md.removed.$(date +%Y%m%d_%H%M%S)"
    
    if mv "CLAUDE.md" "$BACKUP_NAME"; then
        print_success "CLAUDE.md moved to: $BACKUP_NAME"
    else
        print_error "Failed to remove CLAUDE.md"
    fi
else
    print_info "CLAUDE.md not found"
fi

echo ""

# ============================================
# 6. REMOVE .CLAUDECODE.JSON
# ============================================

print_step "Removing .claudecode.json..."

if [[ -f ".claudecode.json" ]]; then
    # Backup before removing
    BACKUP_NAME=".claudecode.json.removed.$(date +%Y%m%d_%H%M%S)"
    
    if mv ".claudecode.json" "$BACKUP_NAME"; then
        print_success ".claudecode.json moved to: $BACKUP_NAME"
    else
        print_error "Failed to remove .claudecode.json"
    fi
else
    print_info ".claudecode.json not found"
fi

echo ""

# ============================================
# 7. CLEAN .GITIGNORE ENTRIES
# ============================================

print_step "Cleaning .gitignore entries..."

if [[ -f ".gitignore" ]]; then
    GITIGNORE_ENTRIES=(
        ".claude/cache/"
        ".claude/backups/"
        ".claude/memory/session-last.md"
        ".claude/memory/llm-usage.json"
        ".claude/memory/token-accounting.json"
        ".claude/memory/memory-stats.json"
    )
    
    TEMP_GITIGNORE=".gitignore.tmp"
    cp ".gitignore" "$TEMP_GITIGNORE"
    
    REMOVED=0
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if grep -qF "$entry" "$TEMP_GITIGNORE"; then
            # Remove the entry
            grep -vF "$entry" "$TEMP_GITIGNORE" > "$TEMP_GITIGNORE.new"
            mv "$TEMP_GITIGNORE.new" "$TEMP_GITIGNORE"
            REMOVED=$((REMOVED + 1))
        fi
    done
    
    if [[ $REMOVED -gt 0 ]]; then
        mv "$TEMP_GITIGNORE" ".gitignore"
        print_success ".gitignore cleaned ($REMOVED entries removed)"
    else
        rm "$TEMP_GITIGNORE"
        print_info ".gitignore already clean"
    fi
else
    print_info ".gitignore not found"
fi

echo ""

# ============================================
# 8. REMOVE TEMPLATES/MEMORY/ (OPTIONAL)
# ============================================

print_step "Checking templates/memory/..."

if [[ -d "templates/memory" ]]; then
    read -p "Remove templates/memory/ directory? (yes/no): " REMOVE_TEMPLATES
    
    if [[ "$REMOVE_TEMPLATES" == "yes" ]]; then
        if rm -rf "templates/memory"; then
            print_success "templates/memory/ removed"
        else
            print_warning "Failed to remove templates/memory/"
        fi
    else
        print_info "templates/memory/ preserved"
    fi
else
    print_info "templates/memory/ not found"
fi

echo ""

# ============================================
# UNINSTALLATION COMPLETE
# ============================================

print_success "Claude Code platform uninstalled successfully!"
echo ""
print_info "Backup locations:"
echo "  • Memory files: $BACKUP_DIR (if created)"
echo "  • .claude/ directory: $TRASH_DIR (if created)"
echo "  • CLAUDE.md: CLAUDE.md.removed.* (if existed)"
echo "  • .claudecode.json: .claudecode.json.removed.* (if existed)"
echo ""
print_warning "You can safely delete backup files after verifying the uninstallation"
echo ""

exit 0
