#!/usr/bin/env bash
# BetterAgents Multi-Platform — Platform Detection
# Detects which AI IDE is currently running this project
#
# Returns:
#   claude-code | kiro | windsurf | cursor | unknown
#
# Usage:
#   PLATFORM=$(bash .betteragents/sync/detect-platform.sh)
#   echo "Running on: $PLATFORM"

set -e

# ── Detection Logic ───────────────────────────────────────────────────────────

# Check for Kiro-specific environment variables or files
if [ -n "$KIRO_SESSION_ID" ] || [ -n "$KIRO_WORKSPACE" ]; then
    echo "kiro"
    exit 0
fi

# Check for Kiro settings directory
if [ -d ".kiro/settings" ] && [ -f ".kiro/settings/mcp.json" ]; then
    echo "kiro"
    exit 0
fi

# Check for Claude Code specific files
if [ -f ".claude/settings.local.json" ] && [ -f "CLAUDE.md" ]; then
    # Verify it's actually Claude Code by checking for AgentX signature
    if grep -q "AgentX" "CLAUDE.md" 2>/dev/null; then
        echo "claude-code"
        exit 0
    fi
fi

# Check for Windsurf-specific markers
if [ -n "$WINDSURF_SESSION" ] || [ -d ".windsurf" ]; then
    echo "windsurf"
    exit 0
fi

# Check for Cursor-specific markers
if [ -n "$CURSOR_SESSION" ] || [ -d ".cursor" ]; then
    echo "cursor"
    exit 0
fi

# Check for VS Code with Continue extension
if [ -d ".vscode" ] && [ -f ".vscode/settings.json" ]; then
    if grep -q "continue" ".vscode/settings.json" 2>/dev/null; then
        echo "vscode-continue"
        exit 0
    fi
fi

# Default: unknown platform
echo "unknown"
exit 0
