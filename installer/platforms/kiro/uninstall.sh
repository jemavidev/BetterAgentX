#!/bin/bash
# Kiro IDE Platform Uninstallation Script
# Called by orchestrator: bash platforms/kiro/uninstall.sh TARGET_DIR

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

print_step "Uninstalling Kiro IDE platform..."
echo ""

# ============================================
# 1. CONFIRM UNINSTALLATION
# ============================================

print_warning "This will remove:"
echo "  • .kiro/ directory (agents, skills, steering, scripts)"
echo "  • AGENTS.md orchestrator (if not used by Claude)"
echo ""
print_info "Steering files will be backed up to .kiro-backup/"
echo ""

read -p "Continue with uninstallation? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    print_info "Uninstallation cancelled"
    exit 0
fi

echo ""

# ============================================
# 2. BACKUP STEERING FILES
# ============================================

print_step "Backing up steering files..."

if [[ -d ".kiro/steering" ]]; then
    BACKUP_DIR=".kiro-backup/uninstall-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup all steering files
    if cp -r .kiro/steering/* "$BACKUP_DIR/" 2>/dev/null; then
        print_success "Steering files backed up to: $BACKUP_DIR"
    else
        print_warning "Failed to backup some steering files"
    fi
    
    # Also backup custom agents and skills if they exist
    if [[ -d ".kiro/agents" ]] && [[ -n "$(ls -A .kiro/agents 2>/dev/null)" ]]; then
        mkdir -p "$BACKUP_DIR/agents"
        cp -r .kiro/agents/* "$BACKUP_DIR/agents/" 2>/dev/null || true
        print_info "Custom agents backed up"
    fi
    
    if [[ -d ".kiro/skills" ]] && [[ -n "$(ls -A .kiro/skills 2>/dev/null)" ]]; then
        mkdir -p "$BACKUP_DIR/skills"
        cp -r .kiro/skills/* "$BACKUP_DIR/skills/" 2>/dev/null || true
        print_info "Skills backed up"
    fi
else
    print_info "No steering files to backup"
fi

echo ""

# ============================================
# 3. REMOVE .KIRO/ DIRECTORY
# ============================================

print_step "Removing .kiro/ directory..."

if [[ -d ".kiro" ]]; then
    # Move to trash instead of rm -rf for safety
    TRASH_DIR=".kiro-removed-$(date +%Y%m%d_%H%M%S)"
    
    if mv ".kiro" "$TRASH_DIR"; then
        print_success ".kiro/ moved to: $TRASH_DIR"
        print_info "You can safely delete $TRASH_DIR after verifying the uninstallation"
    else
        print_error "Failed to remove .kiro/ directory"
    fi
else
    print_info ".kiro/ directory not found"
fi

echo ""

# ============================================
# 4. REMOVE AGENTS.MD (if not used by Claude)
# ============================================

print_step "Checking AGENTS.md..."

# Only remove AGENTS.md if Claude is not installed
if [[ ! -d ".claude" ]]; then
    if [[ -f "AGENTS.md" ]]; then
        # Backup before removing
        BACKUP_NAME="AGENTS.md.removed.$(date +%Y%m%d_%H%M%S)"
        
        if mv "AGENTS.md" "$BACKUP_NAME"; then
            print_success "AGENTS.md moved to: $BACKUP_NAME"
        else
            print_error "Failed to remove AGENTS.md"
        fi
    else
        print_info "AGENTS.md not found"
    fi
else
    print_info "AGENTS.md preserved (Claude platform still installed)"
fi

echo ""

# ============================================
# 5. CLEAN .GITIGNORE ENTRIES
# ============================================

print_step "Cleaning .gitignore entries..."

if [[ -f ".gitignore" ]]; then
    GITIGNORE_ENTRIES=(
        ".kiro/cache/"
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
# UNINSTALLATION COMPLETE
# ============================================

print_success "Kiro IDE platform uninstalled successfully!"
echo ""
print_info "Backup locations:"
echo "  • Steering files: $BACKUP_DIR (if created)"
echo "  • .kiro/ directory: $TRASH_DIR (if created)"
echo "  • AGENTS.md: AGENTS.md.removed.* (if removed)"
echo ""
print_warning "You can safely delete backup files after verifying the uninstallation"
echo ""

exit 0
