# BetterAgents Modular Installer

**Version:** 1.0.0  
**Architecture:** Plugin-based modular system  
**Status:** Phase 1 Complete - Foundation Ready

## Overview

The modular installer is a complete rewrite of the BetterAgents installation system, designed to support multiple AI IDE platforms through a plugin-based architecture.

## Architecture

### 3-Layer Design

```
┌─────────────────────────────────────────┐
│         Orchestrator Layer              │
│  (install.sh - thin coordinator)        │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│         Core Libraries Layer            │
│  • core.sh - utilities & logging        │
│  • platform-registry.sh - management    │
│  • config-manager.sh - JSON ops         │
│  • ui.sh - interactive menus            │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│         Platform Modules Layer          │
│  • claude/ - Claude Code integration    │
│  • kiro/ - Kiro IDE integration         │
│  • _template/ - new platform template   │
└─────────────────────────────────────────┘
```

## Directory Structure

```
installer/
├── install.sh                    # Main orchestrator (~100 lines)
├── lib/                          # Core libraries
│   ├── core.sh                   # Utilities, logging, colors
│   ├── platform-registry.sh      # Platform detection & management
│   ├── config-manager.sh         # Config read/write operations
│   └── ui.sh                     # Interactive menus
├── platforms/                    # Platform modules
│   └── _template/                # Template for new platforms
│       ├── manifest.json         # Platform metadata
│       ├── install.sh            # Installation script
│       ├── uninstall.sh          # Uninstallation script
│       ├── validate.sh           # Validation script
│       └── README.md             # Documentation
├── shared/                       # Shared components (Phase 4)
├── config/
│   └── platforms.json            # Platform registry
└── scripts/
    ├── detect-platform.sh        # Auto-detect installed platforms
    └── migrate-legacy.sh         # Migrate from legacy installer
```

## Usage

### Basic Installation

```bash
# Interactive mode
bash install.sh --interactive

# Install specific platform
bash install.sh --platform=claude

# Install multiple platforms
bash install.sh --platform=both

# Custom target directory
bash install.sh --platform=claude --target=/path/to/project
```

### Options

- `--platform=PLATFORM` - Platform to install (claude|kiro|both)
- `--target=PATH` - Target directory (default: current)
- `--interactive, -i` - Interactive mode with platform selection
- `--help, -h` - Show help message

## Core Libraries

### core.sh

Provides essential utilities:

- **Colors**: `print_success`, `print_error`, `print_warning`, `print_info`, `print_step`
- **File Operations**: `backup_file`, `atomic_write`, `ensure_directory`
- **Validation**: `command_exists`, `validate_directory`, `validate_file`, `validate_json`
- **Error Handling**: `die`, `check_dependencies`

### platform-registry.sh

Platform management functions:

- `load_platforms()` - Load platforms from registry
- `get_platform_manifest()` - Get platform manifest path
- `is_platform_installed()` - Check if platform exists
- `list_available_platforms()` - Display available platforms
- `validate_platform()` - Validate platform module
- `get_platform_property()` - Get property from registry
- `is_platform_enabled()` - Check if platform is enabled

### config-manager.sh

JSON configuration operations:

- `read_config()` - Read JSON file
- `write_config()` - Write JSON file with backup
- `get_config_value()` - Extract value from JSON
- `set_config_value()` - Update value in JSON
- `merge_config()` - Merge two JSON configs
- `config_has_key()` - Check if key exists
- `config_array_add()` - Add item to array
- `config_array_remove()` - Remove item from array

### ui.sh

Interactive UI components:

- `show_menu()` - Display selection menu
- `confirm()` - Yes/no prompt
- `select_platforms()` - Multi-select platform picker
- `show_progress()` - Progress indicator
- `show_header()` - Display header
- `show_summary()` - Display summary box
- `prompt_input()` - Simple input prompt
- `select_from_list()` - Select from list

## Platform Module Structure

Each platform module must contain:

```
platforms/PLATFORM/
├── manifest.json      # Required: Platform metadata
├── install.sh         # Required: Installation script
├── uninstall.sh       # Optional: Uninstallation script
├── validate.sh        # Optional: Validation script
└── README.md          # Optional: Documentation
```

### manifest.json Schema

```json
{
  "name": "platform-name",
  "version": "1.0.0",
  "description": "Platform description",
  "requires": {
    "commands": ["jq"],
    "optional": ["git", "docker"]
  },
  "dependencies": [],
  "shared": ["betteragents-core", "memory-system"],
  "files": {
    "orchestrator": "PLATFORM.md",
    "agents": ".platform/agents",
    "commands": ".platform/commands",
    "memory": ".platform/memory",
    "scripts": ".platform/scripts"
  },
  "hooks": {
    "pre_install": "",
    "post_install": "",
    "pre_uninstall": "",
    "post_uninstall": ""
  }
}
```

## Creating a New Platform Module

1. Copy the template:
   ```bash
   cp -r platforms/_template platforms/YOUR_PLATFORM
   ```

2. Edit `manifest.json` with platform details

3. Implement `install.sh` with installation logic

4. Implement `uninstall.sh` (optional)

5. Implement `validate.sh` (optional)

6. Register in `config/platforms.json`:
   ```json
   {
     "platforms": {
       "your-platform": {
         "name": "Your Platform Name",
         "description": "Platform description",
         "enabled": true,
         "module": "platforms/your-platform"
       }
     }
   }
   ```

## Development Phases

### ✅ Phase 1: Foundation (COMPLETE)
- Directory structure
- Core libraries (core.sh, platform-registry.sh, config-manager.sh, ui.sh)
- Platform registry (platforms.json)
- Template module
- Main orchestrator
- Utility scripts

### ✅ Phase 2: Claude Platform Module (COMPLETE)
- Extract Claude-specific logic from legacy installer
- Create platforms/claude/ module (507 lines install.sh)
- Implement install.sh, uninstall.sh, validate.sh
- Deploy 142 templates (agents, commands, protocols, memory)
- Test installation flow

### ✅ Phase 3: Kiro Platform Module (COMPLETE)
- Create platforms/kiro/ module (379 lines install.sh)
- Implement Kiro-specific installation
- Deploy 7 templates (steering files, scripts)
- Memory bridge integration
- Test multi-platform installation

### ✅ Phase 4: Shared Components (COMPLETE)
- Created shared/docs/ directory structure
- Universal health check script (scripts/health-check.sh)
- Comprehensive documentation:
  - architecture.md - System architecture overview
  - installation-guide.md - Common installation patterns
  - troubleshooting.md - Common issues and solutions
  - upgrading.md - Upgrade and migration guide
  - contributing.md - How to add new platforms
- Cross-platform validation
- Documentation standards

### 📋 Phase 5: Documentation & Testing (NEXT)
- Integration tests
- End-to-end testing
- Performance benchmarks
- Release preparation

## Migration from Legacy Installer

The legacy monolithic installer (`install.sh` ~500 lines) will be migrated in Phase 2.

To backup existing installation:

```bash
bash scripts/migrate-legacy.sh /path/to/project
```

This creates a timestamped backup before migration.

## Benefits

1. **Modularity**: Each platform is self-contained
2. **Extensibility**: Easy to add new platforms
3. **Maintainability**: Clear separation of concerns
4. **Testability**: Each module can be tested independently
5. **Reusability**: Shared components reduce duplication
6. **Flexibility**: Mix and match platforms as needed

## Dependencies

- **Required**: `jq` (JSON processor)
- **Optional**: `git`, `docker` (platform-specific)

## Testing

```bash
# Test platform detection
bash scripts/detect-platform.sh /path/to/project

# Test platform validation
bash install.sh --platform=claude --target=/tmp/test

# Test interactive mode
bash install.sh --interactive
```

## Contributing

When adding a new platform:

1. Use the `_template` as starting point
2. Follow the manifest.json schema
3. Use core libraries for common operations
4. Add comprehensive error handling
5. Document platform-specific requirements
6. Update platforms.json registry

## License

Same as BetterAgents project

## Related Documents

- **Architecture Decision**: See `.claude/memory/decision-log.json` (DEC-07)
- **Platform Template**: See `platforms/_template/README.md`
- **Legacy Installer**: See `install.sh` (to be migrated)

---

**Status**: Phase 4 Complete - Shared Components Ready  
**Next**: Phase 5 - Documentation & Testing

## Shared Documentation

Comprehensive cross-platform documentation available in `shared/docs/`:

- **[README.md](shared/docs/README.md)** - Documentation index
- **[architecture.md](shared/docs/architecture.md)** - System architecture with diagrams
- **[installation-guide.md](shared/docs/installation-guide.md)** - Installation patterns and best practices
- **[troubleshooting.md](shared/docs/troubleshooting.md)** - Common issues and solutions
- **[upgrading.md](shared/docs/upgrading.md)** - Upgrade and migration guide
- **[contributing.md](shared/docs/contributing.md)** - How to add new platforms

## Health Check

Universal health check script validates all installed platforms:

```bash
# Run health check
bash scripts/health-check.sh

# Expected output:
# ✓ Claude Code: VALID
# ✓ Kiro IDE: VALID
# ALL SYSTEMS OPERATIONAL
```
