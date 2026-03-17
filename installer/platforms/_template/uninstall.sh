#!/bin/bash
# Platform uninstallation script template
# Called by orchestrator with: bash platforms/PLATFORM/uninstall.sh TARGET_DIR

set -e

# Get script directory
PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$PLATFORM_DIR/../.." && pwd)"

# Source core libraries
source "$INSTALLER_DIR/lib/core.sh"

# Parse arguments
TARGET_DIR="$1"
if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR"
fi

# Validate target directory
validate_directory "$TARGET_DIR"

# Load manifest
MANIFEST="$PLATFORM_DIR/manifest.json"
validate_file "$MANIFEST"
validate_json "$MANIFEST"

PLATFORM_NAME=$(jq -r '.name' "$MANIFEST")

print_step "Uninstalling $PLATFORM_NAME..."

# Run pre-uninstall hook if defined
PRE_UNINSTALL=$(jq -r '.hooks.pre_uninstall // empty' "$MANIFEST")
if [[ -n "$PRE_UNINSTALL" ]] && [[ -f "$PLATFORM_DIR/$PRE_UNINSTALL" ]]; then
    print_info "Running pre-uninstall hook..."
    bash "$PLATFORM_DIR/$PRE_UNINSTALL" "$TARGET_DIR" || print_warning "Pre-uninstall hook failed"
fi

# ============================================
# PLATFORM-SPECIFIC UNINSTALLATION LOGIC HERE
# ============================================

# Example:
# if [[ -d "$TARGET_DIR/.platform" ]]; then
#     backup_file "$TARGET_DIR/.platform"
#     rm -rf "$TARGET_DIR/.platform"
# fi

print_warning "Template uninstall script - implement platform-specific logic"

# Run post-uninstall hook if defined
POST_UNINSTALL=$(jq -r '.hooks.post_uninstall // empty' "$MANIFEST")
if [[ -n "$POST_UNINSTALL" ]] && [[ -f "$PLATFORM_DIR/$POST_UNINSTALL" ]]; then
    print_info "Running post-uninstall hook..."
    bash "$PLATFORM_DIR/$POST_UNINSTALL" "$TARGET_DIR" || print_warning "Post-uninstall hook failed"
fi

print_success "$PLATFORM_NAME uninstalled successfully"
