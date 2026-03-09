#!/bin/bash
# Auto-detect which platforms are already installed in target directory
# Usage: bash detect-platform.sh [TARGET_DIR]
# Output: JSON object with platform detection results

set -e

TARGET_DIR="${1:-.}"

# Validate target directory
if [[ ! -d "$TARGET_DIR" ]]; then
    echo '{"error": "Target directory does not exist"}' >&2
    exit 1
fi

# Get absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Initialize result object
declare -A detected

# Check for Claude Code
if [[ -d "$TARGET_DIR/.claude" ]]; then
    detected[claude]=true
else
    detected[claude]=false
fi

# Check for Kiro
if [[ -d "$TARGET_DIR/.kiro" ]]; then
    detected[kiro]=true
else
    detected[kiro]=false
fi

# Check for generic BetterAgents installation
if [[ -d "$TARGET_DIR/.betteragents" ]]; then
    detected[betteragents]=true
else
    detected[betteragents]=false
fi

# Build JSON output
json="{"
first=true
for platform in "${!detected[@]}"; do
    if [[ "$first" == true ]]; then
        first=false
    else
        json+=","
    fi
    json+="\"$platform\":${detected[$platform]}"
done
json+="}"

echo "$json"
