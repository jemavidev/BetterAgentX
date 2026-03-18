#!/bin/bash
# BetterAgents Modular Installer
# Usage: bash install.sh [--platform=claude|kiro|both] [--target=/path] [--interactive]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source core libraries
source "$SCRIPT_DIR/lib/core.sh"
source "$SCRIPT_DIR/lib/platform-registry.sh"
source "$SCRIPT_DIR/lib/config-manager.sh"
source "$SCRIPT_DIR/lib/ui.sh"

# Default values
TARGET_DIR="."
PLATFORMS=()
INTERACTIVE=false

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
        --interactive|-i)
            INTERACTIVE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --platform=PLATFORM    Platform to install (claude|kiro|both)"
            echo "  --target=PATH          Target directory (default: current)"
            echo "  --interactive, -i      Interactive mode"
            echo "  --help, -h             Show this help"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Show header
show_header "BetterAgents Modular Installer v1.0.0"

# Check dependencies
print_step "Checking dependencies..."
if ! check_dependencies jq; then
    die "Please install jq: https://stedolan.github.io/jq/"
fi
print_success "Dependencies OK"

# Resolve target directory
TARGET_DIR="$(get_absolute_path "$TARGET_DIR")"
validate_directory "$TARGET_DIR"
print_info "Target directory: $TARGET_DIR"

# Interactive platform selection
if [[ $INTERACTIVE == true ]] || [[ ${#PLATFORMS[@]} -eq 0 ]]; then
    print_step "Platform selection..."
    SELECTED=$(select_platforms "$SCRIPT_DIR/config/platforms.json")
    PLATFORMS=($SELECTED)
fi

# Validate platforms
if [[ ${#PLATFORMS[@]} -eq 0 ]]; then
    die "No platforms selected"
fi

print_info "Selected platforms: ${PLATFORMS[*]}"

# Detect existing installations
print_step "Detecting existing installations..."
DETECTED=$(bash "$SCRIPT_DIR/scripts/detect-platform.sh" "$TARGET_DIR")

# Show summary
show_summary "Installation Summary" \
    "Target: $TARGET_DIR" \
    "Platforms: ${PLATFORMS[*]}" \
    "Mode: $([ $INTERACTIVE == true ] && echo 'Interactive' || echo 'Automated')"

# Confirm installation
if ! confirm "Proceed with installation?" "y"; then
    print_info "Installation cancelled"
    exit 0
fi

# ── STEP 1: Always install core layer (.betteragents/) ──────────────────────
echo
show_header "Installing Core Layer"
CORE_SCRIPT="$SCRIPT_DIR/core/install.sh"

if [[ -f "$CORE_SCRIPT" ]]; then
    if bash "$CORE_SCRIPT" "$TARGET_DIR"; then
        print_success "Core layer ready (.betteragents/)"
    else
        print_error "Core layer installation failed — aborting"
        exit 1
    fi
else
    print_error "Core installer not found: $CORE_SCRIPT"
    exit 1
fi

echo

# ── STEP 2: Install selected platform adapters ──────────────────────────────
echo
show_header "Installing Platform Adapters"

INSTALLED=()
FAILED=()

for platform in "${PLATFORMS[@]}"; do
    print_step "Installing platform: $platform"

    # Validate platform
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
    if bash "$INSTALL_SCRIPT" "$TARGET_DIR"; then
        INSTALLED+=("$platform")
        print_success "Platform installed: $platform"
    else
        FAILED+=("$platform")
        print_error "Platform installation failed: $platform"
    fi

    echo
done

# Show results
echo
show_header "Installation Results"

if [[ ${#INSTALLED[@]} -gt 0 ]]; then
    print_success "Successfully installed: ${INSTALLED[*]}"
fi

if [[ ${#FAILED[@]} -gt 0 ]]; then
    print_error "Failed to install: ${FAILED[*]}"
    exit 1
fi

print_success "Installation complete!"

# ── STEP 3: Register project in central Docker dashboard ─────────────────────
echo
show_header "Docker Dashboard Registration"

# Derive a slug from the target directory name
DEFAULT_PROJECT_NAME=$(basename "$TARGET_DIR" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//')

COMPOSE_SCRIPT="$TARGET_DIR/.betteragents/scripts/generate-central-compose.sh"
MEMORY_PATH="$TARGET_DIR/.betteragents/memory"

if [[ ! -f "$COMPOSE_SCRIPT" ]]; then
    print_warning "generate-central-compose.sh not found — skipping Docker registration"
elif confirm "Register this project in the central Docker dashboard?" "y"; then
    PROJECT_NAME=$(prompt_input "Project name" "$DEFAULT_PROJECT_NAME")

    if bash "$COMPOSE_SCRIPT" "$PROJECT_NAME" "$MEMORY_PATH"; then
        print_success "Project '$PROJECT_NAME' registered"
        echo

        # Offer container restart if Docker is available
        if command -v docker &>/dev/null; then
            CENTRAL_COMPOSE="$HOME/.betteragents/docker-compose.yml"
            IS_RUNNING=$(docker ps --format '{{.Names}}' 2>/dev/null \
                | grep -c "^betteragents-central$" || true)

            if [[ "$IS_RUNNING" -gt 0 ]]; then
                if confirm "Restart central container to apply changes?" "y"; then
                    docker compose -f "$CENTRAL_COMPOSE" restart 2>/dev/null \
                        && print_success "Container restarted — dashboard updated" \
                        || print_warning "Could not restart — run: docker compose -f ~/.betteragents/docker-compose.yml restart"
                fi
            else
                print_info "Start dashboard: bash $TARGET_DIR/.betteragents/scripts/start-dashboard.sh"
            fi
        else
            check_or_install_docker
            print_info "Node.js fallback (no Docker required):"
            print_info "bash $TARGET_DIR/.betteragents/scripts/start-dashboard.sh"
        fi
    else
        print_warning "Registration failed. Register manually:"
        print_info "bash $COMPOSE_SCRIPT $DEFAULT_PROJECT_NAME $MEMORY_PATH"
    fi
else
    print_info "Skipped. Register later with:"
    print_info "bash $COMPOSE_SCRIPT <name> $MEMORY_PATH"
fi

echo

# Auto-cleanup: only remove installer if it lives INSIDE the target directory
# (i.e., the user downloaded the installer directly into their project)
# If the installer is external to the target (e.g., cloned repo), do NOT delete it
if [[ "$SCRIPT_DIR" == "$TARGET_DIR"* ]] && [[ "$SCRIPT_DIR" != "$TARGET_DIR" ]]; then
    INSTALLER_DIR="$SCRIPT_DIR"
    (sleep 0.5 && rm -rf "$INSTALLER_DIR") &
    disown
    print_info "Installer folder will be removed automatically."
fi
