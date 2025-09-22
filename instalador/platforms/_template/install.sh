#!/bin/bash
# Platform installation script template
# Called by orchestrator with: bash platforms/PLATFORM/install.sh TARGET_DIR

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
PLATFORM_VERSION=$(jq -r '.version' "$MANIFEST")

print_step "Installing $PLATFORM_NAME v$PLATFORM_VERSION..."

# Check required dependencies
REQUIRED_DEPS=$(jq -r '.requires.commands[]' "$MANIFEST" 2>/dev/null)
if [[ -n "$REQUIRED_DEPS" ]]; then
    print_info "Checking dependencies..."
    while IFS= read -r dep; do
        if ! command_exists "$dep"; then
            die "Missing required dependency: $dep"
        fi
    done <<< "$REQUIRED_DEPS"
fi

# Run pre-install hook if defined
PRE_INSTALL=$(jq -r '.hooks.pre_install // empty' "$MANIFEST")
if [[ -n "$PRE_INSTALL" ]] && [[ -f "$PLATFORM_DIR/$PRE_INSTALL" ]]; then
    print_info "Running pre-install hook..."
    bash "$PLATFORM_DIR/$PRE_INSTALL" "$TARGET_DIR" || die "Pre-install hook failed"
fi

# ============================================
# PLATFORM-SPECIFIC INSTALLATION LOGIC HERE
# ============================================

# Example:
# ensure_directory "$TARGET_DIR/.platform"
# cp -r "$PLATFORM_DIR/files/"* "$TARGET_DIR/.platform/"

print_warning "Template install script - implement platform-specific logic"

# Run post-install hook if defined
POST_INSTALL=$(jq -r '.hooks.post_install // empty' "$MANIFEST")
if [[ -n "$POST_INSTALL" ]] && [[ -f "$PLATFORM_DIR/$POST_INSTALL" ]]; then
    print_info "Running post-install hook..."
    bash "$PLATFORM_DIR/$POST_INSTALL" "$TARGET_DIR" || die "Post-install hook failed"
fi

print_success "$PLATFORM_NAME installed successfully"
