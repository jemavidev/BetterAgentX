#!/bin/bash
# BetterAgents Core Installer
# Installs the platform-agnostic layer: .betteragents/memory, scripts, dashboard
# Called by: bash installer/core/install.sh TARGET_DIR [--update]

set -e

TARGET_DIR="$1"
MODE="${2:-install}"   # install | update
CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$CORE_DIR/.." && pwd)"

source "$INSTALLER_DIR/lib/core.sh"

if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR [--update]"
fi

validate_directory "$TARGET_DIR"
cd "$TARGET_DIR"

# ============================================
# 1. CREATE DIRECTORY STRUCTURE
# ============================================

print_step "Creating .betteragents/ structure..."

DIRECTORIES=(
    ".betteragents"
    ".betteragents/memory"
    ".betteragents/scripts"
    ".betteragents/templates"
)

for dir in "${DIRECTORIES[@]}"; do
    ensure_directory "$dir"
done

print_success ".betteragents/ structure ready"
echo ""

# ============================================
# 2. INSTALL / UPDATE SCRIPTS
# ============================================

print_step "Installing core scripts..."

SCRIPTS_INSTALLED=0

for script in "$CORE_DIR/templates/.betteragents/scripts"/*; do
    if [[ -f "$script" ]]; then
        filename=$(basename "$script")

        # In update mode: only update changed files (MD5 comparison)
        if [[ "$MODE" == "--update" ]] && [[ -f ".betteragents/scripts/$filename" ]]; then
            SRC_HASH=$(md5sum "$script" 2>/dev/null | cut -d' ' -f1 || md5 -q "$script" 2>/dev/null)
            DST_HASH=$(md5sum ".betteragents/scripts/$filename" 2>/dev/null | cut -d' ' -f1 || md5 -q ".betteragents/scripts/$filename" 2>/dev/null)
            if [[ "$SRC_HASH" == "$DST_HASH" ]]; then
                continue
            fi
        fi

        cp "$script" ".betteragents/scripts/$filename"
        chmod +x ".betteragents/scripts/$filename" 2>/dev/null || true
        SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
    fi
done

if [[ $SCRIPTS_INSTALLED -gt 0 ]]; then
    print_success "Scripts installed/updated ($SCRIPTS_INSTALLED files)"
else
    print_info "Scripts: already up to date"
fi

echo ""

# ============================================
# 3. INSTALL DASHBOARD TEMPLATE
# ============================================

print_step "Installing dashboard template..."

if [[ -f "$CORE_DIR/templates/.betteragents/templates/dashboard.html" ]]; then
    cp "$CORE_DIR/templates/.betteragents/templates/dashboard.html" \
       ".betteragents/templates/dashboard.html"
    print_success "Dashboard template installed"
else
    print_warning "dashboard.html template not found"
fi

echo ""

# ============================================
# 4. INSTALL MEMORY TEMPLATES (Case A/B/C)
# ============================================

print_step "Installing memory templates..."

# Detect project case
# Case B-new: already migrated to .betteragents/
# Case B-old: old BetterAgents installation still using .claude/memory/
# Case C:     existing non-BetterAgents project
# Case A:     brand new project
if [[ -f ".betteragents/state.json" ]]; then
    PROJECT_CASE="B"
    print_info "Case B: Existing installation — preserving memory files"
elif [[ -f ".claude/.version" ]] || [[ -d ".claude/memory" ]]; then
    PROJECT_CASE="B-old"
    print_info "Case B-old: Legacy BetterAgents installation detected (.claude/memory/)"
    print_info "Memory will be migrated to .betteragents/memory/ automatically"
elif [[ -d ".git" ]] || [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "go.mod" ]] || [[ -f "Cargo.toml" ]]; then
    PROJECT_CASE="C"
    print_info "Case C: Existing project — installing missing memory files only"
else
    PROJECT_CASE="A"
    print_info "Case A: New project — installing clean memory templates"
fi

# ── MIGRATION: move data from .claude/memory/ → .betteragents/memory/ ────────
if [[ "$PROJECT_CASE" == "B-old" ]]; then
    print_step "Migrating legacy memory data..."
    MIGRATED=0
    SKIPPED=0

    for src in .claude/memory/*.json .claude/memory/*.md; do
        [[ -f "$src" ]] || continue
        filename=$(basename "$src")

        # Skip dashboard.html — it will be regenerated
        [[ "$filename" == "dashboard.html" ]] && continue

        if [[ -f ".betteragents/memory/$filename" ]]; then
            # Already exists in destination — keep destination (more recent)
            SKIPPED=$((SKIPPED + 1))
        else
            cp "$src" ".betteragents/memory/$filename"
            MIGRATED=$((MIGRATED + 1))
        fi
    done

    print_success "Migration complete: $MIGRATED files migrated, $SKIPPED already present"
    print_info "Original data preserved in .claude/memory/ as backup"
    echo ""
fi

# ── Install any missing template files ───────────────────────────────────────
MEMORY_FILES=0

for template in "$CORE_DIR/templates/.betteragents/memory"/*; do
    if [[ -f "$template" ]]; then
        filename=$(basename "$template")

        # dashboard.html lives in templates/, not memory/
        [[ "$filename" == "dashboard.html" ]] && continue

        # All cases: only install if file is missing
        if [[ ! -f ".betteragents/memory/$filename" ]]; then
            cp "$template" ".betteragents/memory/$filename"
            MEMORY_FILES=$((MEMORY_FILES + 1))
        fi
    fi
done

print_success "Memory files ready ($MEMORY_FILES new files installed)"
echo ""

# ============================================
# 5. WRITE / UPDATE state.json
# ============================================

print_step "Updating state.json..."

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CORE_VERSION=$(jq -r '.version' "$CORE_DIR/manifest.json" 2>/dev/null || echo "4.0.0")

if [[ -f ".betteragents/state.json" ]]; then
    # Update last_updated and core_version, preserve installed_platforms
    jq --arg v "$CORE_VERSION" --arg ts "$TIMESTAMP" \
       '.core_version = $v | .last_updated = $ts' \
       ".betteragents/state.json" > ".betteragents/state.json.tmp" && \
       mv ".betteragents/state.json.tmp" ".betteragents/state.json"
    print_success "state.json updated"
else
    # Detect already-installed platforms for legacy migration
    DETECTED_PLATFORMS="[]"
    if [[ "$PROJECT_CASE" == "B-old" ]]; then
        DETECTED_PLATFORMS="[]"
        [[ -f ".claude/.version" ]] && \
            DETECTED_PLATFORMS=$(echo "$DETECTED_PLATFORMS" | jq '. + ["claude"]')
        [[ -f ".kiro/.version" ]] && \
            DETECTED_PLATFORMS=$(echo "$DETECTED_PLATFORMS" | jq '. + ["kiro"]')
        [[ -n "$DETECTED_PLATFORMS" ]] && \
            print_info "Detected legacy platforms: $(echo "$DETECTED_PLATFORMS" | jq -r '.[]' | tr '\n' ' ')"
    fi

    # Create state.json
    jq -n \
        --arg v "$CORE_VERSION" \
        --arg ts "$TIMESTAMP" \
        --argjson p "$DETECTED_PLATFORMS" \
        '{version: $v, core_version: $v, installed_platforms: $p, installed_at: $ts, last_updated: $ts, migrated_from_legacy: ($p | length > 0)}' \
        > ".betteragents/state.json"
    print_success "state.json created"
fi

echo ""

# ============================================
# 6. INITIALIZE MEMORY STATS
# ============================================

print_step "Initializing memory stats..."

if [[ -f ".betteragents/scripts/memory-stats.sh" ]]; then
    if bash ".betteragents/scripts/memory-stats.sh" init 2>/dev/null; then
        print_success "Memory stats initialized"
    else
        print_info "Memory stats initialization skipped"
    fi
fi

echo ""

# ============================================
# 7. BUILD INITIAL DASHBOARD
# ============================================

print_step "Building initial dashboard..."

if [[ -f ".betteragents/scripts/update-dashboard.sh" ]]; then
    if bash ".betteragents/scripts/update-dashboard.sh" 2>/dev/null; then
        print_success "Dashboard built"
    else
        print_warning "Dashboard build skipped (non-fatal)"
        print_info "Run manually: bash .betteragents/scripts/update-dashboard.sh"
    fi
fi

echo ""

# ============================================
# 8. CONFIGURE .GITIGNORE
# ============================================

GITIGNORE_ENTRIES=(
    ".betteragents/memory/session-last.md"
    ".betteragents/memory/llm-usage.json"
    ".betteragents/memory/token-accounting.json"
    ".betteragents/memory/memory-stats.json"
)

if [[ -f ".gitignore" ]]; then
    ADDED=0
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "$entry" ".gitignore"; then
            echo "$entry" >> ".gitignore"
            ADDED=$((ADDED + 1))
        fi
    done
    [[ $ADDED -gt 0 ]] && print_info ".gitignore updated ($ADDED entries)"
fi

echo ""

print_success "Core layer installed successfully"
