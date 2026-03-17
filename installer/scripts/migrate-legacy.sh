#!/bin/bash
# Migrate from legacy monolithic installer to modular architecture
# Usage: bash migrate-legacy.sh TARGET_DIR

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source core libraries
source "$INSTALLER_DIR/lib/core.sh"

TARGET_DIR="${1:-.}"

# Validate target directory
validate_directory "$TARGET_DIR"
TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"

print_step "Migrating legacy installation to modular architecture..."

# Detect existing platforms
print_info "Detecting installed platforms..."
DETECTED=$(bash "$SCRIPT_DIR/detect-platform.sh" "$TARGET_DIR")

echo "$DETECTED" | jq '.'

# Check if migration is needed
HAS_CLAUDE=$(echo "$DETECTED" | jq -r '.claude // false')
HAS_KIRO=$(echo "$DETECTED" | jq -r '.kiro // false')
HAS_BETTERAGENTS=$(echo "$DETECTED" | jq -r '.betteragents // false')

if [[ "$HAS_CLAUDE" == "false" ]] && [[ "$HAS_KIRO" == "false" ]] && [[ "$HAS_BETTERAGENTS" == "false" ]]; then
    print_info "No existing installation detected. No migration needed."
    exit 0
fi

# Backup existing installation
print_step "Creating backup..."
BACKUP_DIR="$TARGET_DIR/.betteragents-backup-$(date +%Y%m%d_%H%M%S)"
ensure_directory "$BACKUP_DIR"

if [[ "$HAS_CLAUDE" == "true" ]]; then
    print_info "Backing up Claude installation..."
    cp -r "$TARGET_DIR/.claude" "$BACKUP_DIR/" 2>/dev/null || true
fi

if [[ "$HAS_KIRO" == "true" ]]; then
    print_info "Backing up Kiro installation..."
    cp -r "$TARGET_DIR/.kiro" "$BACKUP_DIR/" 2>/dev/null || true
fi

if [[ "$HAS_BETTERAGENTS" == "true" ]]; then
    print_info "Backing up BetterAgents core..."
    cp -r "$TARGET_DIR/.betteragents" "$BACKUP_DIR/" 2>/dev/null || true
fi

print_success "Backup created: $BACKUP_DIR"

# Migration logic will be implemented in Phase 2
print_warning "Migration logic not yet implemented - backup created only"
print_info "Run the new modular installer to complete migration"

print_success "Legacy backup complete"
