# Contributing to BetterAgents

**Version:** 4.0.0  
**Last Updated:** 2026-03-02

## Overview

This guide explains how to contribute to BetterAgents, including adding new platforms, creating custom agents, and improving documentation.

## Table of Contents

1. [Adding a New Platform](#adding-a-new-platform)
2. [Creating Custom Agents](#creating-custom-agents)
3. [Adding Skills](#adding-skills)
4. [Improving Documentation](#improving-documentation)
5. [Testing](#testing)
6. [Code Style](#code-style)
7. [Submitting Changes](#submitting-changes)

## Adding a New Platform

### Overview

BetterAgents uses a plugin-based architecture. Each platform is a self-contained module in `platforms/`.

### Step 1: Copy Template

```bash
cd installer/platforms
cp -r _template/ your-platform/
cd your-platform/
```

### Step 2: Update config.json

```json
{
  "name": "your-platform",
  "displayName": "Your Platform IDE",
  "version": "4.0.0",
  "description": "BetterAgents integration for Your Platform IDE",
  "author": "Your Name",
  "homepage": "https://your-platform.com",
  "repository": "https://github.com/your-org/your-platform",
  "dependencies": {
    "required": ["bash", "jq"],
    "optional": ["git", "node"]
  },
  "paths": {
    "config": ".yourplatform",
    "orchestrator": "YOURPLATFORM.md",
    "agents": ".yourplatform/agents",
    "skills": ".yourplatform/skills",
    "memory": ".yourplatform/memory",
    "scripts": ".yourplatform/scripts"
  },
  "features": {
    "memory": true,
    "dashboard": false,
    "hooks": true,
    "memoryBridge": false
  },
  "markers": [
    ".yourplatform",
    "YOURPLATFORM.md",
    ".yourplatformconfig.json"
  ]
}
```

### Step 3: Implement install.sh

```bash
#!/bin/bash
# Your Platform IDE Installation Script
# Called by orchestrator: bash platforms/your-platform/install.sh TARGET_DIR

set -e

# ============================================
# SETUP
# ============================================

TARGET_DIR="$1"
PLATFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_DIR="$(cd "$PLATFORM_DIR/../.." && pwd)"

# Source core libraries
source "$INSTALLER_DIR/lib/core.sh"

# Validate target
if [[ -z "$TARGET_DIR" ]]; then
    die "Usage: $0 TARGET_DIR"
fi

validate_directory "$TARGET_DIR"
cd "$TARGET_DIR"

print_step "Installing Your Platform IDE platform..."
echo ""

# ============================================
# DETECT EXISTING INSTALLATION
# ============================================

EXISTING=false
if [[ -d ".yourplatform" ]]; then
    EXISTING=true
    print_info "Existing installation detected"
    
    # Create backup
    BACKUP_DIR=".yourplatform/backups/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    print_step "Creating backup..."
    cp -r .yourplatform/* "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Backup created: $BACKUP_DIR"
    echo ""
fi

# ============================================
# CREATE DIRECTORY STRUCTURE
# ============================================

print_step "Creating directory structure..."

mkdir -p .yourplatform/{agents,skills,memory,scripts,cache,backups}

print_success "Directories created"
echo ""

# ============================================
# DEPLOY TEMPLATES
# ============================================

print_step "Deploying templates..."

# Deploy orchestrator
cp "$PLATFORM_DIR/templates/YOURPLATFORM.md" "YOURPLATFORM.md"
print_success "Orchestrator: YOURPLATFORM.md"

# Deploy agents
if [[ -d "$PLATFORM_DIR/templates/agents" ]]; then
    cp "$PLATFORM_DIR/templates/agents/"*.md .yourplatform/agents/
    AGENT_COUNT=$(find .yourplatform/agents -name "*.md" | wc -l | tr -d ' ')
    print_success "Agents: $AGENT_COUNT installed"
fi

# Deploy skills
if [[ -d "$PLATFORM_DIR/templates/skills" ]]; then
    cp "$PLATFORM_DIR/templates/skills/"*.md .yourplatform/skills/
    SKILL_COUNT=$(find .yourplatform/skills -name "*.md" | wc -l | tr -d ' ')
    print_success "Skills: $SKILL_COUNT installed"
fi

# Deploy scripts
if [[ -d "$PLATFORM_DIR/templates/scripts" ]]; then
    cp "$PLATFORM_DIR/templates/scripts/"*.sh .yourplatform/scripts/
    chmod +x .yourplatform/scripts/*.sh
    print_success "Scripts: Installed and executable"
fi

# Deploy memory templates (if feature enabled)
if [[ -d "$PLATFORM_DIR/templates/memory" ]]; then
    cp "$PLATFORM_DIR/templates/memory/"* .yourplatform/memory/
    print_success "Memory: Templates deployed"
fi

echo ""

# ============================================
# CONFIGURATION
# ============================================

print_step "Configuring platform..."

# Create version file
echo "4.0.0" > .yourplatform/.version

# Create platform config
cat > .yourplatformconfig.json << 'EOF'
{
  "betteragents": {
    "enabled": true,
    "version": "4.0.0",
    "platform": "your-platform"
  }
}
EOF

print_success "Configuration complete"
echo ""

# ============================================
# FINALIZE
# ============================================

print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "  YOUR PLATFORM IDE INSTALLATION COMPLETE"
print_success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_info "Next steps:"
print_info "  1. Open project in Your Platform IDE"
print_info "  2. Verify YOURPLATFORM.md is loaded"
print_info "  3. Test agent dispatch"
echo ""

exit 0
```

### Step 4: Implement uninstall.sh

```bash
#!/bin/bash
# Your Platform IDE Uninstallation Script

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

print_step "Uninstalling Your Platform IDE platform..."
echo ""

# Create final backup
if [[ -d ".yourplatform" ]]; then
    BACKUP_DIR=".yourplatform/backups/backup-final-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r .yourplatform/* "$BACKUP_DIR/" 2>/dev/null || true
    print_success "Final backup: $BACKUP_DIR"
fi

# Remove files
rm -rf .yourplatform/
rm -f YOURPLATFORM.md
rm -f .yourplatformconfig.json

print_success "Your Platform IDE platform uninstalled"
echo ""

exit 0
```

### Step 5: Implement validate.sh

```bash
#!/bin/bash
# Your Platform IDE Validation Script

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

print_step "Validating Your Platform IDE installation..."
echo ""

ERRORS=0
WARNINGS=0

# Check required files
REQUIRED_FILES=(
    "YOURPLATFORM.md"
    ".yourplatform/agents"
    ".yourplatform/skills"
    ".yourplatform/.version"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -e "$file" ]]; then
        print_error "Missing: $file"
        ERRORS=$((ERRORS + 1))
    else
        print_success "Found: $file"
    fi
done

echo ""

# Summary
if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    print_success "✓ Installation is VALID"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    print_success "✓ Installation is VALID — $WARNINGS warnings"
    exit 0
else
    print_error "✗ Installation is INVALID — $ERRORS errors, $WARNINGS warnings"
    exit 1
fi
```

### Step 6: Create Templates

```bash
# Create template directory structure
mkdir -p templates/{agents,skills,scripts,memory}

# Add your platform-specific templates
# - YOURPLATFORM.md (orchestrator)
# - agents/*.md (custom agents)
# - skills/*.md (platform-specific skills)
# - scripts/*.sh (utility scripts)
```

### Step 7: Update Platform Registry

```bash
# Edit config/platforms.json
{
  "platforms": [
    {
      "name": "claude",
      "enabled": true
    },
    {
      "name": "kiro",
      "enabled": true
    },
    {
      "name": "your-platform",
      "enabled": true
    }
  ]
}
```

### Step 8: Write README.md

```markdown
# Your Platform IDE Platform Module

BetterAgents integration for Your Platform IDE.

## Features

- Multi-agent orchestration
- Custom agents
- Skills library
- Memory system (optional)

## Installation

\`\`\`bash
bash install.sh --platform your-platform
\`\`\`

## Validation

\`\`\`bash
bash platforms/your-platform/validate.sh .
\`\`\`

## Documentation

See [shared/docs/](../../shared/docs/) for detailed documentation.
```

### Step 9: Test Your Platform

```bash
# Test installation
bash install.sh --platform your-platform --target /tmp/test-project

# Validate
bash platforms/your-platform/validate.sh /tmp/test-project

# Test uninstallation
bash platforms/your-platform/uninstall.sh /tmp/test-project
```

## Creating Custom Agents

### Agent Structure

```markdown
# Agent Name

**Role:** Brief description of agent's role
**Domain:** Specific domain expertise
**Capabilities:** What this agent can do

## When to Use

- Scenario 1
- Scenario 2
- Scenario 3

## Skills

- Skill 1
- Skill 2
- Skill 3

## Protocols

1. Protocol step 1
2. Protocol step 2
3. Protocol step 3

## Examples

### Example 1: Task Description

\`\`\`bash
# Example command or code
\`\`\`

### Example 2: Another Task

\`\`\`bash
# Another example
\`\`\`

## Notes

- Important note 1
- Important note 2
```

### Adding Custom Agent

```bash
# Create agent file
cat > .claude/agents/custom-my-agent.md << 'EOF'
# My Custom Agent

**Role:** Specialized task handler
**Domain:** Specific domain
**Capabilities:** What it does

## When to Use

- When you need X
- When you need Y

## Skills

- Skill A
- Skill B

## Protocols

1. Step 1
2. Step 2
3. Step 3
EOF

# Verify agent
cat .claude/agents/custom-my-agent.md
```

## Adding Skills

### Skill Structure

```markdown
# Skill Name

**Category:** Category name
**Complexity:** Low | Medium | High
**Prerequisites:** Required knowledge or tools

## Description

Brief description of what this skill does.

## When to Use

- Use case 1
- Use case 2
- Use case 3

## Implementation

\`\`\`bash
# Code example
\`\`\`

## Examples

### Example 1

\`\`\`bash
# Example usage
\`\`\`

### Example 2

\`\`\`bash
# Another example
\`\`\`

## Best Practices

- Best practice 1
- Best practice 2

## Common Pitfalls

- Pitfall 1
- Pitfall 2

## References

- Reference 1
- Reference 2
```

### Adding Custom Skill

```bash
# Create skill file
cat > .claude/commands/custom-my-skill.md << 'EOF'
# My Custom Skill

**Category:** Custom
**Complexity:** Medium
**Prerequisites:** Basic knowledge

## Description

This skill does something specific.

## When to Use

- When you need to do X
- When you need to do Y

## Implementation

\`\`\`bash
# Implementation code
\`\`\`
EOF
```

## Improving Documentation

### Documentation Standards

1. **Clear and concise:** Get to the point quickly
2. **Examples:** Include code examples
3. **Cross-references:** Link to related docs
4. **Up-to-date:** Keep documentation current
5. **Tested:** Verify all examples work

### Adding Documentation

```bash
# Create new doc in shared/docs/
cat > shared/docs/new-guide.md << 'EOF'
# New Guide Title

**Version:** 4.0.0
**Last Updated:** 2026-03-02

## Overview

Brief overview of what this guide covers.

## Content

Main content here.

## References

- [Related Guide](related-guide.md)
EOF

# Update README.md
# Add link to new guide in shared/docs/README.md
```

## Testing

### Manual Testing

```bash
# Test installation
bash install.sh --platform your-platform --target /tmp/test

# Test validation
bash platforms/your-platform/validate.sh /tmp/test

# Test health check
bash scripts/health-check.sh /tmp/test

# Test uninstallation
bash platforms/your-platform/uninstall.sh /tmp/test
```

### Automated Testing (Optional)

```bash
# Create test script
cat > test-platform.sh << 'EOF'
#!/bin/bash
set -e

TEST_DIR="/tmp/betteragents-test-$$"
mkdir -p "$TEST_DIR"

echo "Testing installation..."
bash install.sh --platform your-platform --target "$TEST_DIR"

echo "Testing validation..."
bash platforms/your-platform/validate.sh "$TEST_DIR"

echo "Testing health check..."
bash scripts/health-check.sh "$TEST_DIR"

echo "Testing uninstallation..."
bash platforms/your-platform/uninstall.sh "$TEST_DIR"

rm -rf "$TEST_DIR"
echo "All tests passed!"
EOF

chmod +x test-platform.sh
./test-platform.sh
```

## Code Style

### Bash Scripts

```bash
#!/bin/bash
# Script description
# Usage: script.sh ARG1 ARG2

set -e  # Exit on error

# ============================================
# SECTION HEADER
# ============================================

# Function definition
function_name() {
    local arg1="$1"
    local arg2="$2"
    
    # Implementation
    echo "Result"
}

# Main logic
main() {
    # Step 1
    print_step "Doing something..."
    
    # Step 2
    print_success "Done"
}

main "$@"
```

### Markdown Documentation

```markdown
# Title (H1)

**Metadata:** Value

## Section (H2)

Content here.

### Subsection (H3)

More content.

#### Sub-subsection (H4)

Detailed content.

## Code Examples

\`\`\`bash
# Bash example
echo "Hello"
\`\`\`

\`\`\`json
{
  "key": "value"
}
\`\`\`

## Lists

- Item 1
- Item 2
  - Sub-item 2.1
  - Sub-item 2.2

## Tables

| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |

## Links

- [Internal Link](other-doc.md)
- [External Link](https://example.com)
```

## Submitting Changes

### 1. Fork Repository

```bash
# Fork on GitHub
# Clone your fork
git clone https://github.com/your-username/BetterAgentX
cd BetterAgentX
```

### 2. Create Branch

```bash
# Create feature branch
git checkout -b feature/your-platform

# Or bugfix branch
git checkout -b fix/issue-description
```

### 3. Make Changes

```bash
# Add your platform
cd installer/platforms
cp -r _template/ your-platform/
# ... implement platform ...

# Test changes
bash install.sh --platform your-platform --target /tmp/test
bash scripts/health-check.sh /tmp/test
```

### 4. Commit Changes

```bash
# Stage changes
git add installer/platforms/your-platform/

# Commit with descriptive message
git commit -m "feat: add Your Platform IDE integration

- Implement install.sh, uninstall.sh, validate.sh
- Add platform templates
- Update platform registry
- Add documentation"
```

### 5. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-platform

# Create Pull Request on GitHub
# - Describe changes
# - Reference any issues
# - Include test results
```

### Commit Message Format

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Tests
- `chore`: Maintenance

**Examples:**
```
feat(platform): add Cursor IDE integration
fix(claude): resolve memory bridge issue
docs(shared): improve installation guide
```

## Review Process

1. **Automated checks:** CI/CD runs tests
2. **Code review:** Maintainers review code
3. **Testing:** Manual testing if needed
4. **Approval:** At least one approval required
5. **Merge:** Squash and merge to main

## Getting Help

- **GitHub Issues:** https://github.com/jemavidev/BetterAgentX/issues
- **Discussions:** https://github.com/jemavidev/BetterAgentX/discussions
- **Documentation:** See [shared/docs/](.)

## References

- **Architecture:** [architecture.md](architecture.md)
- **Installation Guide:** [installation-guide.md](installation-guide.md)
- **Troubleshooting:** [troubleshooting.md](troubleshooting.md)

---

**Thank you for contributing to BetterAgents!**
