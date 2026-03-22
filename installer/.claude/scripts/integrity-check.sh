#!/bin/bash
# BetterAgents — System Integrity Check
# Verifies system files haven't been modified outside designated channels.
# Called by on-user-prompt.sh on every UserPromptSubmit.
# Layer B: SHA256 hash comparison (blocks on violation)
# Layer C: Git uncommitted changes (warns, does not block)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SYSTEM_DIR/.." && pwd)"
LOCK="$SYSTEM_DIR/integrity.lock"

# No lock file → silent pass (dev mode or pre-lock install)
[ -f "$LOCK" ] || exit 0

cd "$PROJECT_ROOT" || exit 0

# ── Layer B: SHA256 ────────────────────────────────────────────────────────────
FAILED=$(sha256sum -c "$LOCK" --quiet 2>/dev/null | grep ": FAILED$" || true)
if [ -n "$FAILED" ]; then
    echo ""
    echo "🔒 INTEGRITY VIOLATION — BetterAgents system files modified outside designated channels."
    echo "   Affected files:"
    echo "$FAILED" | sed 's/: FAILED$//' | sed 's/^/   \u2717 /'
    echo ""
    echo "   System files are read-only infrastructure. Allowed channels:"
    echo "   → Add agents : project-agent-creator skill"
    echo "   → Add skills : project-skill-creator skill"
    echo "   → Memory     : bash $(basename "$SYSTEM_DIR")/scripts/add-task.sh / add-decision.sh"
    echo "   → Restore    : git checkout HEAD -- $(basename "$SYSTEM_DIR")/scripts/ CLAUDE.md"
    echo "   → Re-lock    : bash $(basename "$SYSTEM_DIR")/scripts/generate-integrity-lock.sh"
    echo ""
    exit 2
fi

# ── Layer C: Git uncommitted changes ─────────────────────────────────────────
if git -C "$PROJECT_ROOT" rev-parse --git-dir > /dev/null 2>&1; then
    SYSTEM_DIRNAME="$(basename "$SYSTEM_DIR")"
    GIT_CHANGED=$(git -C "$PROJECT_ROOT" diff HEAD --name-only -- \
        "$SYSTEM_DIRNAME/scripts/" \
        "$SYSTEM_DIRNAME/settings.local.json" \
        "CLAUDE.md" 2>/dev/null | grep -v "^$" || true)
    if [ -n "$GIT_CHANGED" ]; then
        echo ""
        echo "⚠️  GIT WARNING — Uncommitted changes detected in system files:"
        echo "$GIT_CHANGED" | sed 's/^/   \u2022 /'
        echo "   If intentional, re-lock: bash $(basename "$SYSTEM_DIR")/scripts/generate-integrity-lock.sh"
        echo ""
        # Warn only — do not block
    fi
fi

exit 0
