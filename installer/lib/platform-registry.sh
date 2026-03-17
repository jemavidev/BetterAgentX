#!/bin/bash
# Platform registry management
# Handles platform discovery, validation, and manifest loading

# Load platforms from registry
load_platforms() {
    local registry="${1:-$SCRIPT_DIR/config/platforms.json}"
    validate_file "$registry"
    validate_json "$registry"
    
    jq -r '.platforms | keys[]' "$registry" 2>/dev/null || die "Failed to load platforms"
}

# Get platform manifest path
get_platform_manifest() {
    local platform="$1"
    local registry="${2:-$SCRIPT_DIR/config/platforms.json}"
    
    local module=$(jq -r ".platforms.${platform}.module // empty" "$registry" 2>/dev/null)
    if [[ -z "$module" ]]; then
        print_error "Platform not found in registry: $platform"
        return 1
    fi
    
    local manifest="${SCRIPT_DIR}/${module}/manifest.json"
    if [[ ! -f "$manifest" ]]; then
        print_error "Manifest not found: $manifest"
        return 1
    fi
    
    echo "$manifest"
}

# Check if platform is installed in target directory
is_platform_installed() {
    local platform="$1"
    local target_dir="$2"
    
    case "$platform" in
        claude)
            [[ -d "$target_dir/.claude" ]]
            ;;
        kiro)
            [[ -d "$target_dir/.kiro" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# List available platforms
list_available_platforms() {
    local registry="${1:-$SCRIPT_DIR/config/platforms.json}"
    validate_file "$registry"
    
    print_info "Available platforms:"
    echo
    
    local platforms=$(jq -r '.platforms | keys[]' "$registry")
    for platform in $platforms; do
        local name=$(jq -r ".platforms.${platform}.name" "$registry")
        local desc=$(jq -r ".platforms.${platform}.description" "$registry")
        local enabled=$(jq -r ".platforms.${platform}.enabled" "$registry")
        
        if [[ "$enabled" == "true" ]]; then
            echo -e "  ${GREEN}●${NC} ${CYAN}${platform}${NC} - ${name}"
            echo -e "    ${desc}"
        else
            echo -e "  ${YELLOW}○${NC} ${platform} - ${name} (disabled)"
        fi
        echo
    done
}

# Validate platform module structure
validate_platform() {
    local platform="$1"
    local registry="${2:-$SCRIPT_DIR/config/platforms.json}"
    
    # Check if platform exists in registry
    local module=$(jq -r ".platforms.${platform}.module // empty" "$registry" 2>/dev/null)
    if [[ -z "$module" ]]; then
        print_error "Platform not found: $platform"
        return 1
    fi
    
    local platform_dir="${SCRIPT_DIR}/${module}"
    
    # Check required files
    local required_files=(
        "manifest.json"
        "install.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "${platform_dir}/${file}" ]]; then
            print_error "Missing required file: ${platform_dir}/${file}"
            return 1
        fi
    done
    
    # Validate manifest JSON
    local manifest="${platform_dir}/manifest.json"
    if ! validate_json "$manifest"; then
        return 1
    fi
    
    # Check install script is executable
    if [[ ! -x "${platform_dir}/install.sh" ]]; then
        print_warning "Install script not executable: ${platform_dir}/install.sh"
        chmod +x "${platform_dir}/install.sh" || return 1
    fi
    
    return 0
}

# Get platform property from registry
get_platform_property() {
    local platform="$1"
    local property="$2"
    local registry="${3:-$SCRIPT_DIR/config/platforms.json}"
    
    jq -r ".platforms.${platform}.${property} // empty" "$registry" 2>/dev/null
}

# Check if platform is enabled
is_platform_enabled() {
    local platform="$1"
    local registry="${2:-$SCRIPT_DIR/config/platforms.json}"
    
    local enabled=$(get_platform_property "$platform" "enabled" "$registry")
    [[ "$enabled" == "true" ]]
}
