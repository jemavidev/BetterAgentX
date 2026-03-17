# BetterAgents Architecture

**Version:** 4.0.0  
**Last Updated:** 2026-03-02

## Overview

BetterAgents is a modular, plugin-based multi-agent orchestration system designed to work across multiple AI IDE platforms (Claude Code, Kiro IDE, and future platforms).

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER PROJECT                             │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  CLAUDE.md   │  │  AGENTS.md   │  │  .claudecode │         │
│  │ (Claude Code)│  │  (Kiro IDE)  │  │    .json     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              PLATFORM-SPECIFIC DIRECTORIES              │   │
│  │                                                         │   │
│  │  ┌──────────────────┐      ┌──────────────────┐       │   │
│  │  │   .claude/       │      │    .kiro/        │       │   │
│  │  │                  │      │                  │       │   │
│  │  │  • agents/       │      │  • steering/     │       │   │
│  │  │  • commands/     │      │  • agents/       │       │   │
│  │  │  • protocols/    │      │  • skills/       │       │   │
│  │  │  • memory/       │      │  • scripts/      │       │   │
│  │  │  • scripts/      │      │  • settings/     │       │   │
│  │  │  • settings.json │      │  • .version      │       │   │
│  │  │  • .version      │      │                  │       │   │
│  │  └──────────────────┘      └──────────────────┘       │   │
│  │                                                         │   │
│  │         Memory Bridge (when both installed)            │   │
│  │         Kiro → .claude/memory/ (read-only)             │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Modular Installer Architecture

```
installer/
│
├── install.sh                    # Main orchestrator
│
├── lib/                          # Core libraries
│   ├── core.sh                   # Logging, validation, utilities
│   ├── ui.sh                     # User interface functions
│   ├── config-manager.sh         # Configuration management
│   └── platform-registry.sh      # Platform discovery & loading
│
├── platforms/                    # Platform modules (plugins)
│   ├── _template/                # Template for new platforms
│   │   ├── install.sh
│   │   ├── uninstall.sh
│   │   ├── validate.sh
│   │   ├── config.json
│   │   ├── templates/
│   │   └── README.md
│   │
│   ├── claude/                   # Claude Code platform
│   │   ├── install.sh            # 507 lines
│   │   ├── uninstall.sh          # 142 lines
│   │   ├── validate.sh           # 380 lines
│   │   ├── config.json
│   │   ├── templates/            # 142 template files
│   │   └── README.md
│   │
│   └── kiro/                     # Kiro IDE platform
│       ├── install.sh            # 379 lines
│       ├── uninstall.sh          # 98 lines
│       ├── validate.sh           # 285 lines
│       ├── config.json
│       ├── templates/            # 7 template files
│       └── README.md
│
├── scripts/                      # Utility scripts
│   ├── detect-platform.sh        # Platform detection
│   ├── migrate-legacy.sh         # Legacy migration
│   └── health-check.sh           # Universal validation
│
├── shared/                       # Shared components
│   └── docs/                     # Cross-platform documentation
│       ├── README.md
│       ├── architecture.md       # This file
│       ├── installation-guide.md
│       ├── troubleshooting.md
│       ├── upgrading.md
│       └── contributing.md
│
├── config/                       # Configuration files
│   ├── betteragents.json         # Core config
│   ├── platforms.json            # Platform registry
│   └── agent-skills.json         # Skills catalog
│
└── templates/                    # Shared templates
    └── memory/                   # Memory system templates
```

## Component Responsibilities

### 1. Main Orchestrator (`install.sh`)

**Responsibilities:**
- Parse command-line arguments
- Load platform registry
- Detect existing installations
- Coordinate platform installation/uninstallation
- Handle multi-platform scenarios

**Flow:**
```
1. Parse args (--platform, --target, --mode)
2. Load core libraries
3. Detect existing platforms
4. Load platform modules
5. Execute platform install/uninstall
6. Validate installation
7. Display summary
```

### 2. Core Libraries (`lib/`)

#### `core.sh`
- Logging functions (print_step, print_success, print_error, etc.)
- Validation functions (validate_directory, validate_file, etc.)
- Utility functions (command_exists, backup_file, etc.)
- Error handling (die, trap handlers)

#### `ui.sh`
- Interactive prompts (confirm, select_option, etc.)
- Progress indicators
- Formatted output
- Color management

#### `config-manager.sh`
- Load/save configuration
- Merge configurations
- Validate configuration schema
- Environment variable handling

#### `platform-registry.sh`
- Discover available platforms
- Load platform modules
- Validate platform structure
- Platform metadata management

### 3. Platform Modules (`platforms/*/`)

Each platform module is a self-contained plugin with:

#### `install.sh`
- Platform-specific installation logic
- Template deployment
- Configuration setup
- Dependency checks

#### `uninstall.sh`
- Clean removal of platform files
- Backup creation
- Dependency cleanup
- Validation of removal

#### `validate.sh`
- Installation verification
- File structure checks
- Configuration validation
- Dependency verification

#### `config.json`
- Platform metadata (name, version, description)
- Dependencies (required commands, files)
- Installation paths
- Template mappings

#### `templates/`
- Platform-specific template files
- Organized by category (agents, commands, protocols, etc.)
- Variable substitution support

### 4. Utility Scripts (`scripts/`)

#### `detect-platform.sh`
- Scans target directory for platform markers
- Returns JSON with detection results
- Supports legacy detection
- Used by health-check and orchestrator

#### `migrate-legacy.sh`
- Migrates from monolithic to modular installer
- Preserves user data
- Updates configuration
- Validates migration

#### `health-check.sh`
- Universal validation across all platforms
- Cross-platform compatibility checks
- Dependency verification
- Detailed reporting

## Data Flow

### Installation Flow

```
User Command
    ↓
Main Orchestrator (install.sh)
    ↓
Platform Registry (discover platforms)
    ↓
Platform Detection (detect existing)
    ↓
Platform Module (install.sh)
    ↓
Template Deployment
    ↓
Configuration Setup
    ↓
Validation (validate.sh)
    ↓
Success/Failure Report
```

### Validation Flow

```
Health Check Script
    ↓
Platform Detection
    ↓
For Each Platform:
    ↓
    Platform Validate Script
    ↓
    File Structure Check
    ↓
    Configuration Validation
    ↓
    Dependency Check
    ↓
Cross-Platform Checks
    ↓
Summary Report
```

## Platform Coexistence

BetterAgents supports multiple platforms installed simultaneously:

### Claude Code + Kiro IDE

```
project/
├── CLAUDE.md              # Claude orchestrator
├── AGENTS.md              # Kiro orchestrator
├── .claudecode.json       # Claude config
├── .claude/               # Claude platform
│   ├── agents/
│   ├── commands/
│   ├── protocols/
│   ├── memory/            # ← Shared via memory bridge
│   └── scripts/
└── .kiro/                 # Kiro platform
    ├── steering/
    ├── agents/
    ├── skills/
    └── scripts/
        └── update-memory.sh  # ← Writes to .claude/memory/
```

### Memory Bridge

When both platforms are installed:
- Kiro can read from `.claude/memory/`
- Kiro's `update-memory.sh` writes to `.claude/memory/`
- Claude remains the source of truth for memory
- No conflicts or duplication

## Design Principles

### 1. Modularity
- Each platform is a self-contained plugin
- No cross-dependencies between platforms
- Easy to add new platforms

### 2. Separation of Concerns
- Core libraries handle common functionality
- Platform modules handle platform-specific logic
- Shared components eliminate duplication

### 3. Extensibility
- Template-based platform creation
- Plugin architecture
- Configuration-driven behavior

### 4. Robustness
- Comprehensive validation
- Error handling at every level
- Rollback on failure
- Backup before destructive operations

### 5. User Experience
- Clear progress indicators
- Helpful error messages
- Interactive prompts
- Detailed documentation

## Configuration Management

### Configuration Hierarchy

```
1. Default Config (config/betteragents.json)
    ↓
2. Platform Config (platforms/*/config.json)
    ↓
3. User Config (.claudecode.json, etc.)
    ↓
4. Environment Variables
    ↓
5. Command-line Arguments
```

Later sources override earlier ones.

### Configuration Schema

```json
{
  "project": {
    "name": "string",
    "version": "string",
    "phase": "string",
    "focus": "string"
  },
  "platforms": {
    "claude": {
      "enabled": "boolean",
      "version": "string",
      "paths": {}
    },
    "kiro": {
      "enabled": "boolean",
      "version": "string",
      "paths": {}
    }
  },
  "features": {
    "memory": "boolean",
    "dashboard": "boolean",
    "hooks": "boolean"
  }
}
```

## Extension Points

### Adding a New Platform

1. Copy `platforms/_template/` to `platforms/your-platform/`
2. Implement `install.sh`, `uninstall.sh`, `validate.sh`
3. Create `config.json` with platform metadata
4. Add templates to `templates/`
5. Update `config/platforms.json`
6. Test with `bash install.sh --platform your-platform`

See [contributing.md](contributing.md) for detailed guide.

## Security Considerations

### File Permissions
- Scripts are executable (755)
- Configuration files are readable (644)
- Sensitive data never committed

### Validation
- All user inputs validated
- Directory traversal prevented
- Command injection prevented
- JSON schema validation

### Backups
- Automatic backups before destructive operations
- Timestamped backup directories
- Easy rollback mechanism

## Performance

### Installation Time
- Claude Code: ~2-3 seconds (142 templates)
- Kiro IDE: ~1-2 seconds (7 templates)
- Both platforms: ~3-5 seconds

### Validation Time
- Claude Code: ~1-2 seconds
- Kiro IDE: ~1 second
- Health check (both): ~2-3 seconds

### Resource Usage
- Disk space: ~2-5 MB per platform
- Memory: Minimal (bash scripts)
- CPU: Negligible

## Future Enhancements

### Planned Features
- [ ] Cursor IDE platform module
- [ ] Windsurf IDE platform module
- [ ] Web-based installer UI
- [ ] Automatic updates
- [ ] Plugin marketplace
- [ ] Cloud sync for memory

### Under Consideration
- [ ] Docker-based installation
- [ ] Remote installation
- [ ] Multi-project management
- [ ] Team collaboration features

## Version History

- **4.0.0** (2026-03-02) - Modular installer with Claude + Kiro
- **3.7.0** (2026-03-01) - Memory governance + Protocol 5b
- **3.6.0** (2026-02-28) - Dashboard + activity tracking
- **3.5.0** (2026-02-27) - Multi-agent orchestration
- **3.0.0** (2026-02-25) - BetterAgents foundation

## References

- **Main README:** `../../README-MODULAR.md`
- **Installation Guide:** [installation-guide.md](installation-guide.md)
- **Contributing Guide:** [contributing.md](contributing.md)
- **Troubleshooting:** [troubleshooting.md](troubleshooting.md)

---

**Maintained by:** BetterAgents Team  
**License:** MIT  
**Repository:** https://github.com/jemavidev/BetterAgentX
