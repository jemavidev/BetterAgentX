# Platform Module Template

This is a template for creating new platform modules in the BetterAgents modular installer.

## Structure

```
_template/
├── manifest.json      # Platform metadata and configuration
├── install.sh         # Installation script
├── uninstall.sh       # Uninstallation script
├── validate.sh        # Validation script
└── README.md          # This file
```

## Creating a New Platform Module

1. **Copy this template:**
   ```bash
   cp -r platforms/_template platforms/YOUR_PLATFORM
   ```

2. **Edit manifest.json:**
   - Update `name`, `version`, `description`
   - Define required and optional dependencies
   - Specify file paths for platform-specific directories
   - Add hooks if needed

3. **Implement install.sh:**
   - Copy platform files to target directory
   - Create necessary directories
   - Configure platform-specific settings
   - Run any initialization scripts

4. **Implement uninstall.sh:**
   - Remove platform files
   - Clean up directories
   - Backup important data before removal

5. **Implement validate.sh:**
   - Check required directories exist
   - Verify configuration files
   - Validate dependencies

6. **Register in platforms.json:**
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

## Available Libraries

Your scripts have access to these libraries:

- **core.sh**: Colors, logging, file operations, validation
- **platform-registry.sh**: Platform management functions
- **config-manager.sh**: JSON config operations
- **ui.sh**: Interactive UI components

## Script Arguments

All scripts receive the target directory as the first argument:

```bash
bash install.sh /path/to/target
bash uninstall.sh /path/to/target
bash validate.sh /path/to/target
```

## Hooks

You can define hooks in manifest.json:

- `pre_install`: Run before installation
- `post_install`: Run after installation
- `pre_uninstall`: Run before uninstallation
- `post_uninstall`: Run after uninstallation

Hooks are bash scripts relative to the platform directory.

## Best Practices

1. Always validate inputs
2. Use atomic operations for file writes
3. Backup before modifying existing files
4. Provide clear error messages
5. Check dependencies before installation
6. Clean up temporary files
7. Use the provided logging functions
