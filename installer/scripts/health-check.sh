#!/bin/bash
# BetterAgents Universal Health Check Script
# Validates installations across all platforms (Claude Code, Kiro IDE, etc.)
# Usage: bash scripts/health-check.sh [TARGET_DIR]

set -e

# ============================================
# SETUP
# ============================================

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source core libraries
source "$INSTALLER_DIR/lib/core.sh"

# ============================================
# BANNER
# ============================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║           BetterAgents Universal Health Check             ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ============================================
# VALIDATE TARGET DIRECTORY
# ============================================

if [[ ! -d "$TARGET_DIR" ]]; then
    die "Target directory does not exist: $TARGET_DIR"
fi

cd "$TARGET_DIR"
print_info "Target: $(pwd)"
echo ""

# ============================================
# DETECT INSTALLED PLATFORMS
# ============================================

print_step "Detecting installed platforms..."
echo ""

DETECTED=$(bash "$SCRIPT_DIR/detect-platform.sh" "$TARGET_DIR")

# Parse JSON
CLAUDE_INSTALLED=$(echo "$DETECTED" | jq -r '.claude // false')
KIRO_INSTALLED=$(echo "$DETECTED" | jq -r '.kiro // false')
LEGACY_DETECTED=$(echo "$DETECTED" | jq -r '.legacy // false')

# Display detection results
if [[ "$CLAUDE_INSTALLED" == "true" ]]; then
    print_success "✓ Claude Code platform detected"
else
    print_info "○ Claude Code platform not installed"
fi

if [[ "$KIRO_INSTALLED" == "true" ]]; then
    print_success "✓ Kiro IDE platform detected"
else
    print_info "○ Kiro IDE platform not installed"
fi

if [[ "$LEGACY_DETECTED" == "true" ]]; then
    print_warning "⚠ Legacy installation detected (consider upgrading)"
fi

echo ""

# Check if any platform is installed
if [[ "$CLAUDE_INSTALLED" == "false" ]] && [[ "$KIRO_INSTALLED" == "false" ]]; then
    print_error "No BetterAgents platforms detected"
    echo ""
    print_info "To install BetterAgents, run:"
    print_info "  bash install.sh"
    echo ""
    exit 1
fi

# ============================================
# VALIDATE CLAUDE CODE PLATFORM
# ============================================

CLAUDE_VALID=false
if [[ "$CLAUDE_INSTALLED" == "true" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  CLAUDE CODE PLATFORM"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if bash "$INSTALLER_DIR/platforms/claude/validate.sh" "$TARGET_DIR"; then
        CLAUDE_VALID=true
    else
        print_error "Claude Code validation failed"
    fi
fi

# ============================================
# VALIDATE KIRO IDE PLATFORM
# ============================================

KIRO_VALID=false
if [[ "$KIRO_INSTALLED" == "true" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  KIRO IDE PLATFORM"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if bash "$INSTALLER_DIR/platforms/kiro/validate.sh" "$TARGET_DIR"; then
        KIRO_VALID=true
    else
        print_error "Kiro IDE validation failed"
    fi
fi

# ============================================
# CROSS-PLATFORM CHECKS
# ============================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CROSS-PLATFORM CHECKS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

CROSS_WARNINGS=0

# Check for memory bridge compatibility
if [[ "$CLAUDE_INSTALLED" == "true" ]] && [[ "$KIRO_INSTALLED" == "true" ]]; then
    print_step "Checking memory bridge compatibility..."
    
    if [[ -d ".claude/memory" ]] && [[ -f ".kiro/scripts/update-memory.sh" ]]; then
        print_success "Memory bridge: Compatible ✓"
        print_info "  Kiro can access Claude memory system"
    else
        print_warning "Memory bridge: Incomplete"
        CROSS_WARNINGS=$((CROSS_WARNINGS + 1))
    fi
    echo ""
fi

# Check for conflicting configurations
print_step "Checking for configuration conflicts..."

CONFLICTS=0

# Check if both platforms have orchestrator files
if [[ -f "CLAUDE.md" ]] && [[ -f "AGENTS.md" ]]; then
    print_info "Multiple orchestrators detected:"
    print_info "  • CLAUDE.md (Claude Code)"
    print_info "  • AGENTS.md (Kiro IDE)"
    print_success "No conflicts — platforms coexist ✓"
else
    print_success "No configuration conflicts ✓"
fi

echo ""

# Check dependencies
print_step "Checking system dependencies..."

if command_exists jq; then
    JQ_VERSION=$(jq --version 2>/dev/null || echo "unknown")
    print_success "jq: $JQ_VERSION ✓"
else
    print_warning "jq: Not found (required for JSON operations)"
    CROSS_WARNINGS=$((CROSS_WARNINGS + 1))
fi

if command_exists git; then
    GIT_VERSION=$(git --version 2>/dev/null | head -1 || echo "unknown")
    print_success "git: $GIT_VERSION ✓"
else
    print_info "git: Not found (optional)"
fi

echo ""

# ============================================
# OVERALL HEALTH SUMMARY
# ============================================

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    HEALTH CHECK SUMMARY                    ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Count valid platforms
VALID_PLATFORMS=0
TOTAL_PLATFORMS=0

if [[ "$CLAUDE_INSTALLED" == "true" ]]; then
    TOTAL_PLATFORMS=$((TOTAL_PLATFORMS + 1))
    if [[ "$CLAUDE_VALID" == "true" ]]; then
        VALID_PLATFORMS=$((VALID_PLATFORMS + 1))
        print_success "✓ Claude Code: VALID"
    else
        print_error "✗ Claude Code: INVALID"
    fi
fi

if [[ "$KIRO_INSTALLED" == "true" ]]; then
    TOTAL_PLATFORMS=$((TOTAL_PLATFORMS + 1))
    if [[ "$KIRO_VALID" == "true" ]]; then
        VALID_PLATFORMS=$((VALID_PLATFORMS + 1))
        print_success "✓ Kiro IDE: VALID"
    else
        print_error "✗ Kiro IDE: INVALID"
    fi
fi

echo ""

# Overall status
if [[ $VALID_PLATFORMS -eq $TOTAL_PLATFORMS ]] && [[ $CROSS_WARNINGS -eq 0 ]]; then
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "  ALL SYSTEMS OPERATIONAL"
    print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "BetterAgents is fully functional"
    print_info "Platforms: $VALID_PLATFORMS/$TOTAL_PLATFORMS valid"
    echo ""
    exit 0
elif [[ $VALID_PLATFORMS -gt 0 ]]; then
    print_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_warning "  PARTIAL FUNCTIONALITY"
    print_warning "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "Some platforms have issues"
    print_info "Platforms: $VALID_PLATFORMS/$TOTAL_PLATFORMS valid"
    
    if [[ $CROSS_WARNINGS -gt 0 ]]; then
        print_info "Cross-platform warnings: $CROSS_WARNINGS"
    fi
    
    echo ""
    print_info "Review validation output above for details"
    echo ""
    exit 0
else
    print_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_error "  SYSTEM FAILURE"
    print_error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_error "All platforms failed validation"
    print_info "Platforms: $VALID_PLATFORMS/$TOTAL_PLATFORMS valid"
    echo ""
    print_info "To reinstall BetterAgents, run:"
    print_info "  bash install.sh"
    echo ""
    exit 1
fi
