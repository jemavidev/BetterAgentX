#!/bin/bash
# Configuration management
# Handles JSON config read/write operations

# Read JSON config file
read_config() {
    local file="$1"
    validate_file "$file"
    validate_json "$file"
    cat "$file"
}

# Write JSON config file
write_config() {
    local file="$1"
    local content="$2"

    # Validate JSON before writing
    if ! echo "$content" | jq empty 2>/dev/null; then
        die "Invalid JSON content for $file"
    fi

    # Backup existing file
    if [[ -f "$file" ]]; then
        backup_file "$file"
    fi

    # Write with atomic operation
    atomic_write "$file" "$content"
}

# Get value from JSON config
get_config_value() {
    local file="$1"
    local path="$2"
    local default="${3:-}"

    if [[ ! -f "$file" ]]; then
        echo "$default"
        return
    fi

    local value=$(jq -r "$path // empty" "$file" 2>/dev/null)
    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Set value in JSON config
set_config_value() {
    local file="$1"
    local path="$2"
    local value="$3"

    if [[ ! -f "$file" ]]; then
        die "Config file does not exist: $file"
    fi

    # Backup before modification
    backup_file "$file"

    # Update value
    local temp="${file}.tmp.$$"
    jq "$path = \"$value\"" "$file" > "$temp" || die "Failed to update config"
    mv "$temp" "$file" || die "Failed to save config"
}

# Merge two JSON configs
merge_config() {
    local base="$1"
    local overlay="$2"

    if [[ ! -f "$base" ]]; then
        die "Base config does not exist: $base"
    fi

    if [[ ! -f "$overlay" ]]; then
        die "Overlay config does not exist: $overlay"
    fi

    validate_json "$base"
    validate_json "$overlay"

    # Merge with overlay taking precedence
    jq -s '.[0] * .[1]' "$base" "$overlay"
}

# Check if config key exists
config_has_key() {
    local file="$1"
    local path="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local value=$(jq -r "$path // empty" "$file" 2>/dev/null)
    [[ -n "$value" ]]
}

# Add item to JSON array
config_array_add() {
    local file="$1"
    local path="$2"
    local item="$3"

    if [[ ! -f "$file" ]]; then
        die "Config file does not exist: $file"
    fi

    backup_file "$file"

    local temp="${file}.tmp.$$"
    jq "$path += [\"$item\"]" "$file" > "$temp" || die "Failed to add item to array"
    mv "$temp" "$file" || die "Failed to save config"
}

# Remove item from JSON array
config_array_remove() {
    local file="$1"
    local path="$2"
    local item="$3"

    if [[ ! -f "$file" ]]; then
        die "Config file does not exist: $file"
    fi

    backup_file "$file"

    local temp="${file}.tmp.$$"
    jq "$path -= [\"$item\"]" "$file" > "$temp" || die "Failed to remove item from array"
    mv "$temp" "$file" || die "Failed to save config"
}

# Pretty print JSON config
print_config() {
    local file="$1"
    validate_file "$file"
    validate_json "$file"
    jq '.' "$file"
}
