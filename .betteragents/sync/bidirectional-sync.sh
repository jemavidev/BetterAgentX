#!/usr/bin/env bash
# BetterAgents Multi-Platform — Bidirectional Sync
# Synchronizes changes between .claude/ and .kiro/ in both directions
#
# Usage:
#   bash .betteragents/sync/bidirectional-sync.sh [--auto] [--dry-run]
#
# Options:
#   --auto      Auto-sync without confirmation
#   --dry-run   Show what would be synced without making changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

AUTO_MODE=false
DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --auto) AUTO_MODE=true ;;
        --dry-run) DRY_RUN=true ;;
    esac
done

# ── Detect Platform ───────────────────────────────────────────────────────────

PLATFORM=$(bash "$SCRIPT_DIR/detect-platform.sh")
echo "🔍 Platform: $PLATFORM"

# ── Detect Changes ────────────────────────────────────────────────────────────

echo "📊 Detecting changes..."
CHANGES=$(node "$SCRIPT_DIR/change-detector.js" --json)

# Parse changes
CLAUDE_CHANGES=$(echo "$CHANGES" | jq -r '(.claude.added + .claude.modified + .claude.deleted) | length')
KIRO_CHANGES=$(echo "$CHANGES" | jq -r '(.kiro.added + .kiro.modified + .kiro.deleted) | length')

echo "   Claude: $CLAUDE_CHANGES changes"
echo "   Kiro: $KIRO_CHANGES changes"
echo ""

# ── No Changes ────────────────────────────────────────────────────────────────

if [ "$CLAUDE_CHANGES" -eq 0 ] && [ "$KIRO_CHANGES" -eq 0 ]; then
    echo "✓ No changes detected. Everything is in sync."
    exit 0
fi

# ── Show Changes ──────────────────────────────────────────────────────────────

if [ "$CLAUDE_CHANGES" -gt 0 ]; then
    echo "📝 Changes in Claude (.claude/):"
    echo "$CHANGES" | jq -r '.claude | 
        if (.added | length) > 0 then "  + Added: \(.added | length) files" else empty end,
        if (.modified | length) > 0 then "  ~ Modified: \(.modified | length) files" else empty end,
        if (.deleted | length) > 0 then "  - Deleted: \(.deleted | length) files" else empty end'
    echo ""
fi

if [ "$KIRO_CHANGES" -gt 0 ]; then
    echo "📝 Changes in Kiro (.kiro/):"
    echo "$CHANGES" | jq -r '.kiro | 
        if (.added | length) > 0 then "  + Added: \(.added | length) files" else empty end,
        if (.modified | length) > 0 then "  ~ Modified: \(.modified | length) files" else empty end,
        if (.deleted | length) > 0 then "  - Deleted: \(.deleted | length) files" else empty end'
    echo ""
fi

# ── Dry Run ───────────────────────────────────────────────────────────────────

if [ "$DRY_RUN" = true ]; then
    echo "🔍 Dry run mode - no changes will be made"
    echo ""
    echo "Would sync:"
    if [ "$CLAUDE_CHANGES" -gt 0 ]; then
        echo "  → Claude → Kiro: $CLAUDE_CHANGES files"
    fi
    if [ "$KIRO_CHANGES" -gt 0 ]; then
        echo "  → Kiro → Claude: $KIRO_CHANGES files"
    fi
    exit 0
fi

# ── Confirmation ──────────────────────────────────────────────────────────────

if [ "$AUTO_MODE" = false ]; then
    echo "🤔 Sync these changes?"
    echo "   [y] Yes, sync now"
    echo "   [n] No, cancel"
    echo "   [d] Show detailed diff"
    echo ""
    read -p "Choice: " -n 1 -r
    echo ""
    
    case "$REPLY" in
        d|D)
            echo ""
            node "$SCRIPT_DIR/change-detector.js"
            echo ""
            read -p "Proceed with sync? [y/N]: " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "❌ Sync cancelled"
                exit 0
            fi
            ;;
        y|Y)
            # Continue
            ;;
        *)
            echo "❌ Sync cancelled"
            exit 0
            ;;
    esac
fi

# ── Sync Claude → Kiro ────────────────────────────────────────────────────────

if [ "$CLAUDE_CHANGES" -gt 0 ]; then
    echo "🔄 Syncing Claude → Kiro..."
    node "$SCRIPT_DIR/../translators/claude-to-kiro.js" all
    echo ""
fi

# ── Sync Kiro → Claude ────────────────────────────────────────────────────────

if [ "$KIRO_CHANGES" -gt 0 ]; then
    echo "🔄 Syncing Kiro → Claude..."
    node "$SCRIPT_DIR/../translators/kiro-to-claude.js" memory
    echo ""
fi

# ── Validation ────────────────────────────────────────────────────────────────

echo "✅ Validation..."
node "$SCRIPT_DIR/../translators/kiro-to-claude.js" validate

# ── Update Cache ──────────────────────────────────────────────────────────────

echo "💾 Updating sync cache..."
node "$SCRIPT_DIR/change-detector.js" > /dev/null 2>&1

echo ""
echo "✅ Sync complete!"
echo "   Timestamp: $(date -Iseconds)"
