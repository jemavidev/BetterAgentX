#!/bin/bash
# Gemini Platform Installer

set -e

TARGET_DIR="$1"
PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$PLATFORM_DIR/../.." && pwd)"

source "$INSTALLER_DIR/lib/core.sh"

if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR"
fi

validate_directory "$TARGET_DIR"
cd "$TARGET_DIR"

print_step "Installing Gemini platform..."

# 1. CREATE GEMINI-SPECIFIC DIRECTORIES
print_step "Creating Gemini directory structure..."
DIRECTORIES=(
    ".gemini/agents"
    ".gemini/skills"
    ".gemini/steering"
)
for dir in "${DIRECTORIES[@]}"; do
    ensure_directory "$dir"
done
print_success "Gemini directories created"
echo ""

# 2. INSTALL ORCHESTRATOR (GEMINI.md)
print_step "Installing GEMINI.md orchestrator..."
if [[ -f "$PLATFORM_DIR/templates/GEMINI.md" ]]; then
    [[ -f "GEMINI.md" ]] && backup_file "GEMINI.md"
    cp "$PLATFORM_DIR/templates/GEMINI.md" "GEMINI.md" || die "Failed to install GEMINI.md"
    print_success "GEMINI.md installed"
else
    die "GEMINI.md template not found"
fi
echo ""

# 3. INSTALL AGENTS
print_step "Installing agent definitions..."
AGENTS_INSTALLED=0
if [[ -d "$PLATFORM_DIR/templates/.gemini/agents" ]]; then
    for agent in "$PLATFORM_DIR/templates/.gemini/agents"/*.md; do
        if [[ -f "$agent" ]]; then
            filename=$(basename "$agent")
            cp "$agent" ".gemini/agents/$filename" || die "Failed to install agent: $filename"
            AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
        fi
    done
    print_success "Agents installed ($AGENTS_INSTALLED)"
else
    die "Agents directory not found in templates"
fi
echo ""

# 4. INSTALL SKILLS
print_step "Installing skills..."
SKILLS_INSTALLED=0
if [[ -d "$PLATFORM_DIR/templates/.gemini/skills" ]]; then
    for skill in "$PLATFORM_DIR/templates/.gemini/skills"/*.md; do
        if [[ -f "$skill" ]]; then
            filename=$(basename "$skill")
            cp "$skill" ".gemini/skills/$filename" || die "Failed to install skill: $filename"
            SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
        fi
    done
    print_success "Skills installed ($SKILLS_INSTALLED)"
else
    # This is not a fatal error for now
    print_warning "Skills directory not found in templates. Continuing without skills."
fi
echo ""

# 5. WRITE VERSION FILE
print_step "Writing version file..."
VERSION="1.0.0"
echo "$VERSION" > ".gemini/.version"
print_success "Version file created (v$VERSION)"
echo ""

# 6. REGISTER PLATFORM IN state.json
print_step "Registering Gemini platform in state.json..."
if [[ -f ".betteragents/state.json" ]] && command_exists jq; then
    ALREADY=$(jq -r '.installed_platforms | index("gemini") // empty' ".betteragents/state.json" 2>/dev/null)
    if [[ -z "$ALREADY" ]]; then
        jq '.installed_platforms += ["gemini"]' ".betteragents/state.json" 
            > ".betteragents/state.json.tmp" && 
            mv ".betteragents/state.json.tmp" ".betteragents/state.json"
        print_success "Registered: gemini"
    else
        print_info "Already registered"
    fi
fi
echo ""

print_success "Gemini platform installed!"
exit 0
