#!/usr/bin/env bash
# BetterAgents Multi-Platform — Auto Sync
# Automatically syncs .claude/ to platform-specific directories
#
# Usage:
#   bash .betteragents/sync/auto-sync.sh [--watch]
#
# Options:
#   --watch    Watch for changes and sync automatically

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── Detect Platform ───────────────────────────────────────────────────────────

PLATFORM=$(bash "$SCRIPT_DIR/detect-platform.sh")
echo "🔍 Detected platform: $PLATFORM"

# ── Sync Function ─────────────────────────────────────────────────────────────

sync_to_platform() {
    case "$PLATFORM" in
        kiro)
            echo "🔄 Syncing to Kiro..."
            node "$SCRIPT_DIR/../translators/claude-to-kiro.js" all
            echo "✅ Kiro sync complete"
            ;;
        claude-code)
            echo "ℹ️  Running on Claude Code (source platform) - no sync needed"
            ;;
        *)
            echo "⚠️  Unknown platform: $PLATFORM - no sync performed"
            ;;
    esac
}

# ── Watch Mode ────────────────────────────────────────────────────────────────

if [ "$1" = "--watch" ]; then
    echo "👀 Watching .claude/ for changes..."
    echo "   Press Ctrl+C to stop"
    
    # Initial sync
    sync_to_platform
    
    # Watch for changes (requires inotify-tools on Linux)
    if command -v inotifywait &>/dev/null; then
        while inotifywait -r -e modify,create,delete "$PROJECT_ROOT/.claude/"; do
            echo ""
            echo "📝 Change detected in .claude/"
            sync_to_platform
        done
    else
        echo "⚠️  inotifywait not found. Install inotify-tools for watch mode."
        echo "   Falling back to manual sync..."
        sync_to_platform
    fi
else
    # Single sync
    sync_to_platform
fi
