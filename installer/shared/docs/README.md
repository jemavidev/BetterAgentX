# Shared Documentation

This directory contains documentation that applies across all BetterAgents platforms (Claude Code, Kiro IDE, and future platforms).

## Documentation Index

### Core Documentation

- **[installation-guide.md](installation-guide.md)** - Common installation patterns and best practices
- **[architecture.md](architecture.md)** - System architecture overview with diagrams
- **[troubleshooting.md](troubleshooting.md)** - Common issues and solutions across platforms
- **[upgrading.md](upgrading.md)** - Guide for upgrading from legacy to modular installer
- **[contributing.md](contributing.md)** - How to add new platforms to the modular installer

## Platform-Specific Documentation

For platform-specific documentation, see:

- **Claude Code:** `platforms/claude/README.md`
- **Kiro IDE:** `platforms/kiro/README.md`
- **Template:** `platforms/_template/README.md`

## Quick Links

- **Main README:** `../../README-MODULAR.md`
- **Health Check:** `../../scripts/health-check.sh`
- **Platform Detection:** `../../scripts/detect-platform.sh`
- **Migration Script:** `../../scripts/migrate-legacy.sh`

## Documentation Standards

When contributing to shared documentation:

1. **Keep it universal** - Avoid platform-specific details
2. **Use examples** - Include bash snippets and code examples
3. **Cross-reference** - Link to related documentation
4. **Stay current** - Update when system changes
5. **Be concise** - Respect the reader's time

## Version

**Documentation Version:** 1.0.0  
**Last Updated:** 2026-03-02  
**Installer Version:** 4.0.0
