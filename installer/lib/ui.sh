#!/bin/bash
# Interactive UI components
# Provides menus, prompts, and progress indicators

# Display selection menu
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo
    print_info "$title"
    echo
    
    local i=1
    for option in "${options[@]}"; do
        echo "  ${CYAN}${i})${NC} $option"
        ((i++))
    done
    echo
}

# Yes/no confirmation prompt
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    local yn_prompt
    if [[ "$default" == "y" ]]; then
        yn_prompt="[Y/n]"
    else
        yn_prompt="[y/N]"
    fi
    
    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} ${prompt} ${yn_prompt}: ")" response
        response=${response:-$default}
        
        case "$response" in
            [Yy]*)
                return 0
                ;;
            [Nn]*)
                return 1
                ;;
            *)
                print_warning "Please answer yes or no"
                ;;
        esac
    done
}

# Multi-select platform picker
select_platforms() {
    local registry="${1:-$SCRIPT_DIR/config/platforms.json}"
    local available_platforms=$(jq -r '.platforms | keys[]' "$registry")
    local selected=()
    
    echo
    print_info "Select platforms to install (space to toggle, enter to confirm):"
    echo
    
    # Simple implementation - can be enhanced with arrow key navigation
    local platforms_array=()
    while IFS= read -r platform; do
        if is_platform_enabled "$platform" "$registry"; then
            platforms_array+=("$platform")
        fi
    done <<< "$available_platforms"
    
    # Display options
    local i=1
    for platform in "${platforms_array[@]}"; do
        local name=$(get_platform_property "$platform" "name" "$registry")
        echo "  ${CYAN}${i})${NC} ${name} (${platform})"
        ((i++))
    done
    echo "  ${CYAN}0)${NC} All platforms"
    echo
    
    # Get selection
    read -p "$(echo -e "${YELLOW}?${NC} Enter numbers separated by spaces (e.g., 1 2): ")" selection
    
    if [[ "$selection" == "0" ]]; then
        selected=("${platforms_array[@]}")
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -gt 0 ]] && [[ $num -le ${#platforms_array[@]} ]]; then
                selected+=("${platforms_array[$((num-1))]}")
            fi
        done
    fi
    
    if [[ ${#selected[@]} -eq 0 ]]; then
        print_error "No platforms selected"
        return 1
    fi
    
    echo "${selected[@]}"
}

# Show progress indicator
show_progress() {
    local message="$1"
    local current="${2:-0}"
    local total="${3:-0}"
    
    if [[ $total -gt 0 ]]; then
        local percent=$((current * 100 / total))
        echo -ne "\r${CYAN}→${NC} ${message} [${current}/${total}] ${percent}%"
    else
        echo -ne "\r${CYAN}→${NC} ${message}..."
    fi
}

# Clear progress line
clear_progress() {
    echo -ne "\r\033[K"
}

# Display header
show_header() {
    local title="$1"
    local width=60
    
    echo
    echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "${CYAN}  $title${NC}"
    echo -e "${CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo
}

# Display summary box
show_summary() {
    local title="$1"
    shift
    local items=("$@")
    
    echo
    echo -e "${BLUE}┌─ ${title}${NC}"
    for item in "${items[@]}"; do
        echo -e "${BLUE}│${NC}  $item"
    done
    echo -e "${BLUE}└─${NC}"
    echo
}

# Simple input prompt
prompt_input() {
    local prompt="$1"
    local default="$2"
    local value
    
    if [[ -n "$default" ]]; then
        read -p "$(echo -e "${YELLOW}?${NC} ${prompt} [${default}]: ")" value
        echo "${value:-$default}"
    else
        read -p "$(echo -e "${YELLOW}?${NC} ${prompt}: ")" value
        echo "$value"
    fi
}

# Select from list
select_from_list() {
    local prompt="$1"
    shift
    local options=("$@")
    
    show_menu "$prompt" "${options[@]}"
    
    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} Enter selection (1-${#options[@]}): ")" selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#options[@]} ]]; then
            echo "${options[$((selection-1))]}"
            return 0
        else
            print_warning "Invalid selection. Please enter a number between 1 and ${#options[@]}"
        fi
    done
}
