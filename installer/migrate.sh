#!/bin/bash
# BetterAgents Migration Script v1.0
# Migrates legacy BetterAgents installations (.claude/memory/) to the new
# platform-neutral structure (.betteragents/memory/)
#
# Usage:
#   bash installer/migrate.sh [TARGET_DIR]
#   bash installer/migrate.sh /path/to/project
#   bash installer/migrate.sh .                   # current directory

set -e

# ============================================
# SETUP
# ============================================

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step()    { echo -e "${CYAN}▶ $1${NC}"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 BetterAgents — Migration Tool v1.0"
echo "   .claude/memory/ → .betteragents/memory/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate target directory
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    print_error "Directory not found: $1"
    exit 1
}

print_info "Target directory: $TARGET_DIR"
cd "$TARGET_DIR"

echo ""

# ============================================
# 1. DETECT STATE
# ============================================

print_step "Detecting installation state..."

HAS_LEGACY=false
HAS_NEW=false
ALREADY_MIGRATED=false

[[ -d ".claude/memory" ]] || [[ -f ".claude/.version" ]] && HAS_LEGACY=true
[[ -f ".betteragents/state.json" ]] && HAS_NEW=true

if [[ "$HAS_NEW" == true ]]; then
    # Check if migration already done
    if command -v jq &>/dev/null; then
        MIGRATED_FLAG=$(jq -r '.migrated_from_legacy // false' ".betteragents/state.json" 2>/dev/null)
        [[ "$MIGRATED_FLAG" == "true" ]] && ALREADY_MIGRATED=true
    fi
fi

echo ""

if [[ "$HAS_LEGACY" == false ]]; then
    print_info "No legacy installation found (.claude/memory/ does not exist)"
    print_info "Nothing to migrate"
    echo ""
    exit 0
fi

if [[ "$ALREADY_MIGRATED" == true ]] && [[ "$HAS_NEW" == true ]]; then
    print_success "Migration already completed (migrated_from_legacy=true in state.json)"
    echo ""
    print_info "If you want to re-run anyway, remove .betteragents/state.json first"
    echo ""
    exit 0
fi

if [[ "$HAS_LEGACY" == true ]]; then
    print_info "Legacy installation detected:"
    [[ -d ".claude/memory" ]] && print_info "  .claude/memory/ found ($(ls .claude/memory 2>/dev/null | wc -l | tr -d ' ') files)"
    [[ -f ".claude/.version" ]] && print_info "  .claude/.version: $(cat .claude/.version 2>/dev/null || echo 'unknown')"
fi

echo ""

# ============================================
# 2. CONFIRM
# ============================================

echo "This script will:"
echo "  1. Create .betteragents/memory/ structure"
echo "  2. Copy data from .claude/memory/ → .betteragents/memory/"
echo "  3. Preserve originals in .claude/memory/ as backup"
echo "  4. Create/update .betteragents/state.json"
echo ""
echo "No data will be deleted. The old .claude/memory/ remains intact as backup."
echo ""

if [ -t 0 ]; then
    read -rp "Proceed with migration? (y/N): " CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || { print_info "Migration cancelled"; exit 0; }
else
    print_info "Non-interactive mode — proceeding automatically"
fi

echo ""

# ============================================
# 3. USE CORE INSTALLER IF AVAILABLE
# ============================================

CORE_INSTALLER="$SCRIPT_DIR/core/install.sh"

if [[ -f "$CORE_INSTALLER" ]]; then
    print_step "Running core installer (handles migration automatically)..."
    echo ""
    if bash "$CORE_INSTALLER" "$TARGET_DIR"; then
        echo ""
        print_success "Migration completed via core installer"
        echo ""
        print_info "Data is now in: .betteragents/memory/"
        print_info "Backup remains: .claude/memory/"
        echo ""
        exit 0
    else
        print_warning "Core installer failed — falling back to inline migration"
        echo ""
    fi
fi

# ============================================
# 4. INLINE MIGRATION (fallback)
# ============================================

print_step "Creating .betteragents/ structure..."

mkdir -p .betteragents/memory
mkdir -p .betteragents/scripts
mkdir -p .betteragents/templates

print_success "Directories created"
echo ""

# ── Migrate memory files ──────────────────────────────────────────────────────

print_step "Migrating memory files..."

MIGRATED=0
SKIPPED=0
ERRORS=0

for src in .claude/memory/*.json .claude/memory/*.md; do
    [[ -f "$src" ]] || continue
    filename=$(basename "$src")

    # Skip dashboard.html — it will be regenerated
    [[ "$filename" == "dashboard.html" ]] && continue

    if [[ -f ".betteragents/memory/$filename" ]]; then
        print_info "  Skipped (already exists): $filename"
        SKIPPED=$((SKIPPED + 1))
    else
        if cp "$src" ".betteragents/memory/$filename"; then
            print_info "  Migrated: $filename"
            MIGRATED=$((MIGRATED + 1))
        else
            print_warning "  Failed: $filename"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""
print_success "Memory migration: $MIGRATED files migrated, $SKIPPED skipped, $ERRORS errors"
print_info "Originals preserved in .claude/memory/ as backup"
echo ""

# ── Migrate scripts if present ────────────────────────────────────────────────

if [[ -d ".claude/scripts" ]]; then
    print_step "Migrating hook scripts..."
    SCRIPTS_MIGRATED=0

    for src in .claude/scripts/*; do
        [[ -f "$src" ]] || continue
        filename=$(basename "$src")

        if [[ ! -f ".betteragents/scripts/$filename" ]]; then
            if cp "$src" ".betteragents/scripts/$filename"; then
                chmod +x ".betteragents/scripts/$filename" 2>/dev/null || true
                SCRIPTS_MIGRATED=$((SCRIPTS_MIGRATED + 1))
            fi
        fi
    done

    print_success "Scripts migrated: $SCRIPTS_MIGRATED files"
    echo ""
fi

# ── Write state.json ──────────────────────────────────────────────────────────

print_step "Creating .betteragents/state.json..."

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Detect existing platforms
DETECTED_PLATFORMS="[]"
if [[ -f ".claude/.version" ]] && command -v jq &>/dev/null; then
    DETECTED_PLATFORMS=$(echo "$DETECTED_PLATFORMS" | jq '. + ["claude"]')
fi
if [[ -f ".kiro/.version" ]] && command -v jq &>/dev/null; then
    DETECTED_PLATFORMS=$(echo "$DETECTED_PLATFORMS" | jq '. + ["kiro"]')
fi

if command -v jq &>/dev/null; then
    jq -n \
        --arg v "4.0.0" \
        --arg ts "$TIMESTAMP" \
        --argjson p "$DETECTED_PLATFORMS" \
        '{version: $v, core_version: $v, installed_platforms: $p, installed_at: $ts, last_updated: $ts, migrated_from_legacy: true}' \
        > ".betteragents/state.json"
else
    echo "{\"version\":\"4.0.0\",\"core_version\":\"4.0.0\",\"installed_platforms\":[\"claude\"],\"installed_at\":\"$TIMESTAMP\",\"last_updated\":\"$TIMESTAMP\",\"migrated_from_legacy\":true}" \
        > ".betteragents/state.json"
fi

print_success "state.json created"
echo ""

# ── Update .gitignore ─────────────────────────────────────────────────────────

if [[ -f ".gitignore" ]]; then
    GITIGNORE_ENTRIES=(
        ".betteragents/memory/session-last.md"
        ".betteragents/memory/llm-usage.json"
        ".betteragents/memory/token-accounting.json"
        ".betteragents/memory/memory-stats.json"
    )
    ADDED=0
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "$entry" ".gitignore"; then
            echo "$entry" >> ".gitignore"
            ADDED=$((ADDED + 1))
        fi
    done
    [[ $ADDED -gt 0 ]] && print_info ".gitignore updated ($ADDED entries)"
fi

# ============================================
# 5. SUMMARY
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Migration Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📂 Memory now in: .betteragents/memory/"
echo "📦 Backup kept:   .claude/memory/"
echo ""
echo "Next steps:"
echo "  1. Run the platform installer to complete setup:"
echo "     bash installer/install.sh --platform=claude --target=."
echo ""
echo "  2. Or just run the full update:"
echo "     bash scripts/update.sh --force"
echo ""

exit 0
