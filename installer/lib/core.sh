#!/bin/bash
# Core utilities for BetterAgents installer
# Provides: colors, logging, file operations, validation, error handling

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Logging functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
    echo -e "${CYAN}→${NC} $1"
}

# Error handling
die() {
    print_error "$1"
    exit "${2:-1}"
}

# File operations
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup" || die "Failed to backup $file"
        print_info "Backed up: $backup"
    fi
}

atomic_write() {
    local target="$1"
    local content="$2"
    local temp="${target}.tmp.$$"
    
    echo "$content" > "$temp" || die "Failed to write temporary file"
    mv "$temp" "$target" || die "Failed to move file to $target"
}

# Validation helpers
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

validate_directory() {
    local dir="$1"
    [[ -d "$dir" ]] || die "Directory does not exist: $dir"
}

validate_file() {
    local file="$1"
    [[ -f "$file" ]] || die "File does not exist: $file"
}

is_writable() {
    local path="$1"
    [[ -w "$path" ]] || [[ -w "$(dirname "$path")" ]]
}

# JSON validation
validate_json() {
    local file="$1"
    if ! jq empty "$file" 2>/dev/null; then
        die "Invalid JSON in file: $file"
    fi
}

# Dependency checking
check_dependencies() {
    local deps=("$@")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

# Safe directory creation
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || die "Failed to create directory: $dir"
    fi
}

# Check if Docker is installed; print install instructions if not.
# Returns 0 if Docker is available, 1 otherwise.
check_or_install_docker() {
    if command_exists docker; then
        return 0
    fi

    echo
    print_warning "Docker is not installed on this system."
    print_info "Docker enables the central multi-project dashboard (optional)."
    echo

    # Detect OS / distro
    local os=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os="macos"
    elif [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        os=$(. /etc/os-release && echo "$ID")
    fi

    echo -e "  ${CYAN}Install Docker on your system:${NC}"
    case "$os" in
        ubuntu|debian|linuxmint|pop)
            echo
            echo -e "  ${CYAN}# Ubuntu / Debian${NC}"
            echo "  curl -fsSL https://get.docker.com | sh"
            echo "  sudo usermod -aG docker \$USER   # then log out and back in"
            ;;
        fedora|centos|rhel|rocky|almalinux)
            echo
            echo -e "  ${CYAN}# Fedora / RHEL / CentOS${NC}"
            echo "  sudo dnf install -y docker"
            echo "  sudo systemctl enable --now docker"
            echo "  sudo usermod -aG docker \$USER"
            ;;
        arch|manjaro|endeavouros)
            echo
            echo -e "  ${CYAN}# Arch Linux${NC}"
            echo "  sudo pacman -S docker"
            echo "  sudo systemctl enable --now docker"
            echo "  sudo usermod -aG docker \$USER"
            ;;
        macos)
            echo
            echo -e "  ${CYAN}# macOS${NC}"
            echo "  brew install --cask docker"
            echo "  # Then open Docker Desktop from Applications"
            ;;
        *)
            echo
            echo -e "  ${CYAN}# Universal (any Linux)${NC}"
            echo "  curl -fsSL https://get.docker.com | sh"
            echo "  sudo usermod -aG docker \$USER"
            ;;
    esac

    echo
    print_info "After installing, restart your terminal and run:"
    print_info "  cd ~/.betteragents && docker compose up -d"
    echo

    return 1
}

# Get absolute path
get_absolute_path() {
    local path="$1"
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -f "$path" ]]; then
        local dir=$(cd "$(dirname "$path")" && pwd)
        local base=$(basename "$path")
        echo "${dir}/${base}"
    else
        echo "$path"
    fi
}
