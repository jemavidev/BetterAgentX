#!/bin/bash
# BetterAgents Modular Installer v3.8.0
# Usage: bash install.sh [--platform=claude|kiro|both] [--target=PATH] [--interactive]
#
# Platforms: claude (Claude Code), kiro (Amazon Kiro IDE)
# Add new platforms by dropping a module into platforms/ and registering in config/platforms.json

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core libraries
source "$SCRIPT_DIR/lib/core.sh"
source "$SCRIPT_DIR/lib/platform-registry.sh"
source "$SCRIPT_DIR/lib/config-manager.sh"
source "$SCRIPT_DIR/lib/ui.sh"

# Default values
TARGET_DIR="$(pwd)"
PLATFORMS=()
INTERACTIVE=false
UNREGISTER=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform=*)
            PLATFORM_ARG="${1#*=}"
            if [[ "$PLATFORM_ARG" == "both" ]]; then
                PLATFORMS=(claude kiro)
            else
                PLATFORMS+=("$PLATFORM_ARG")
            fi
            shift
            ;;
        --target=*)
            TARGET_DIR="${1#*=}"
            shift
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --interactive|-i)
            INTERACTIVE=true
            shift
            ;;
        --unregister)
            UNREGISTER=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --platform=PLATFORM    Platform to install (claude|kiro|both)"
            echo "  --target=PATH          Target directory (default: current)"
            echo "  --interactive, -i      Interactive platform selection"
            echo "  --unregister           Unregister project from central dashboard (Claude only)"
            echo "  --help, -h             Show this help"
            echo ""
            echo "Examples:"
            echo "  bash install.sh --platform=claude --target=/path/to/project"
            echo "  bash install.sh --platform=kiro --target=/path/to/project"
            echo "  bash install.sh --platform=both --target=/path/to/project"
            echo "  bash install.sh --interactive"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate that core config exists
if [[ ! -f "$SCRIPT_DIR/config/betteragents.json" ]]; then
    print_error "Installer is missing config/betteragents.json — the instalador/ folder may be incomplete"
    exit 1
fi

# Guard: never install inside the installer folder itself
mkdir -p "$TARGET_DIR"
TARGET_ABS="$(cd "$TARGET_DIR" && pwd)"
if [[ "$SCRIPT_DIR" == "$TARGET_ABS" ]]; then
    print_error "The installer is running from inside the target project directory."
    echo ""
    echo "  Correct usage — keep the instalador/ folder intact and run from outside:"
    echo ""
    echo "    cd /path/to/your-project"
    echo "    bash instalador/install.sh"
    echo ""
    echo "  Or point to the target explicitly:"
    echo ""
    echo "    bash /path/to/instalador/install.sh --target=/path/to/your-project"
    echo ""
    exit 1
fi

# Show header
show_header "BetterAgents Modular Installer v3.8.0"

# Handle --unregister (Claude platform only)
if [[ "$UNREGISTER" == true ]]; then
    print_step "Unregistering project from central container..."
    PROJECT_NAME=$(basename "$TARGET_ABS" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    if command -v jq &>/dev/null; then
        bash "$SCRIPT_DIR/.claude/scripts/generate-central-compose.sh" "$PROJECT_NAME" "" --unregister 2>/dev/null || true
        CENTRAL_DIR="$HOME/.betteragents"
        docker --context default compose -f "$CENTRAL_DIR/docker-compose.yml" up -d --force-recreate 2>/dev/null \
            && print_success "Project '$PROJECT_NAME' removed from central dashboard" \
            || print_warning "Container restart failed. Run: docker --context default compose -f ~/.betteragents/docker-compose.yml up -d --force-recreate"
    else
        print_warning "jq not found — cannot unregister project"
    fi
    exit 0
fi

# Check dependencies
print_step "Checking dependencies..."
if ! check_dependencies jq; then
    die "Please install jq: sudo apt install jq  OR  brew install jq"
fi
print_success "Dependencies OK"
echo

print_info "Target directory: $TARGET_ABS"
echo

# Interactive platform selection (if no platform specified)
if [[ $INTERACTIVE == true ]] || [[ ${#PLATFORMS[@]} -eq 0 ]]; then
    print_step "Platform selection..."
    SELECTED=$(select_platforms "$SCRIPT_DIR/config/platforms.json")
    PLATFORMS=($SELECTED)
fi

# Validate platforms
if [[ ${#PLATFORMS[@]} -eq 0 ]]; then
    die "No platforms selected. Use --platform=claude|kiro|both or --interactive"
fi

print_info "Selected platforms: ${PLATFORMS[*]}"
echo

# Detect existing installations
print_step "Detecting existing installations..."
DETECTED=$(bash "$SCRIPT_DIR/scripts/detect-platform.sh" "$TARGET_ABS" 2>/dev/null || echo "{}")
echo

# Show summary
show_summary "Installation Summary" \
    "Target: $TARGET_ABS" \
    "Platforms: ${PLATFORMS[*]}" \
    "Mode: $([ $INTERACTIVE == true ] && echo 'Interactive' || echo 'Automated')"

# Confirm installation
if ! confirm "Proceed with installation?" "y"; then
    print_info "Installation cancelled"
    exit 0
fi

echo

# Install each platform
INSTALLED=()
FAILED=()

for platform in "${PLATFORMS[@]}"; do
    print_step "Installing platform: $platform"
    echo

    # Validate platform exists and is properly structured
    if ! validate_platform "$platform" "$SCRIPT_DIR/config/platforms.json"; then
        print_error "Platform validation failed: $platform"
        FAILED+=("$platform")
        continue
    fi

    # Get platform module path
    MODULE=$(get_platform_property "$platform" "module" "$SCRIPT_DIR/config/platforms.json")
    INSTALL_SCRIPT="$SCRIPT_DIR/$MODULE/install.sh"

    if [[ ! -f "$INSTALL_SCRIPT" ]]; then
        print_error "Install script not found: $INSTALL_SCRIPT"
        FAILED+=("$platform")
        continue
    fi

    # Execute platform install script
    if bash "$INSTALL_SCRIPT" "$TARGET_ABS"; then
        INSTALLED+=("$platform")
        print_success "Platform installed: $platform"
    else
        FAILED+=("$platform")
        print_error "Platform installation failed: $platform"
    fi

    echo
done

# Show results
show_header "Installation Results"

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
    print_success "Successfully installed: ${INSTALLED[*]}"
fi

if [[ ${#FAILED[@]} -gt 0 ]]; then
    print_error "Failed to install: ${FAILED[*]}"
    exit 1
fi

print_success "All platforms installed. Happy coding!"

