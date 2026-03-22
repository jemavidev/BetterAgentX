#!/bin/bash
# BetterAgents — Generate Integrity Lock
# Run by installer after setup, or manually after intentional system upgrades.
# Creates integrity.lock with SHA256 hashes of all system files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$SYSTEM_DIR/.." && pwd)"
SYSTEM_DIRNAME="$(basename "$SYSTEM_DIR")"
LOCK="$SYSTEM_DIR/integrity.lock"

cd "$PROJECT_ROOT" || { echo "ERROR: Cannot cd to project root ($PROJECT_ROOT)"; exit 1; }

FILES_TO_HASH=()

# CLAUDE.md at project root
[ -f "CLAUDE.md" ] && FILES_TO_HASH+=("CLAUDE.md")

# All scripts in system dir (deterministic order)
for f in $(ls "$SYSTEM_DIR/scripts/"*.sh "$SYSTEM_DIR/scripts/"*.js 2>/dev/null | sort); do
    [ -f "$f" ] && FILES_TO_HASH+=("$SYSTEM_DIRNAME/scripts/$(basename "$f")")
done

# settings.local.json (Claude platform only — optional)
[ -f "$SYSTEM_DIRNAME/settings.local.json" ] && FILES_TO_HASH+=("$SYSTEM_DIRNAME/settings.local.json")

if [ ${#FILES_TO_HASH[@]} -eq 0 ]; then
    echo "ERROR: No files to hash. Verify you are running from the project root."
    exit 1
fi

# Generate lock (overwrite if exists)
sha256sum "${FILES_TO_HASH[@]}" > "$LOCK"

echo "✅ Integrity lock generated: $SYSTEM_DIRNAME/integrity.lock"
echo "   Hashed ${#FILES_TO_HASH[@]} files:"
printf '   \u2022 %s\n' "${FILES_TO_HASH[@]}"
