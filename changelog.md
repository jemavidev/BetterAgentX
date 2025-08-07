# Changelog - BetterAgentX

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased] - 2026-02-27

### 🎯 Focus
Mandatory enforcement of semantic memory writes — closing the gap between CLAUDE.md intent and actual runtime behavior.

### ✨ Added

#### Memory Write Enforcement (3-layer system)

**Layer 1 — Helper scripts**
- ✅ `.claude/scripts/add-task.sh` — CLI to append entries to `progress.json` with full validation, atomic write, and summary counter updates
- ✅ `.claude/scripts/add-decision.sh` — CLI to append entries to `decision-log.json`
- ✅ `.claude/scripts/add-pattern.sh` — CLI to append entries to `patterns.json` and `categories[category][]` in a single jq pass

**Layer 2 — CLAUDE.md mandatory triggers**
- ✅ Section 5 rewritten: vague "use jq" replaced with exact CLI commands per trigger event
- ✅ ID naming convention enforced: `TASK-NN`, `DEC-NN`, `PAT-NN`
- ✅ Rule: "write immediately — not at end of session"

**Layer 3 — Cross-session debt hook**
- ✅ `on-session-stop.sh` — detects sessions with >3 git changes and 0 tasks/decisions → writes `.memory-debt.md`
- ✅ `on-user-prompt.sh` — injects debt warning at start of next session, then self-deletes (fires once)

### 📚 Documentation
- ✅ `docs/memory/quick-reference.md` — rewritten to reflect new scripts (v2.0.0)
- ✅ `docs/memory/tools-usage-guide.md` — replaced outdated `add-memory-entry.sh` proposal with actual implementation (v2.0.0)

### 🗃️ Memory
- ✅ `decision-log.json` — first real entry: DEC-01 "3-layer memory write enforcement"

---

## [Unreleased] - 2026-02-17

### 🎯 Focus
Project structure cleanup and documentation consolidation for better maintainability.

### 📚 Documentation

#### Skills-On-Demand Project Consolidation
- ✅ Created comprehensive project documentation: `docs/development/skills-on-demand-project.md`
  - Consolidated information from 5 temporary files
  - Documented project overview and expected impact (94-96% token savings)
  - Preserved Phase 0 validation results (all tests passed)
  - Documented Phase 1 completion (56 skills cataloged, 217K tokens analyzed)
  - Included architecture, detection algorithm, and technical decisions
  - Documented risk mitigation strategies and lessons learned
  - Outlined next steps (Phase 2-5 roadmap)

#### Project Structure Analysis
- ✅ Analyzed complete repository structure
- ✅ Identified temporary vs permanent documentation
- ✅ Recommended organization improvements

### 🧹 Project Cleanup

#### Removed Temporary Files
- ✅ Deleted 5 temporary project files from root:
  - `SKILLS-ON-DEMAND-IMPLEMENTATION.md` (3,441 lines)
  - `SKILLS-ON-DEMAND-STATUS.md` (project status tracking)
  - `RISK-MITIGATION-PLAN.md` (risk analysis)
  - `PHASE0-MANUAL-TESTS.md` (testing guide)
  - `PHASE0-RESULTS.md` (results template)

#### Information Preservation
- ✅ All valuable information preserved in permanent documentation
- ✅ Technical decisions documented
- ✅ Implementation phases and status captured
- ✅ Lessons learned and best practices recorded
- ✅ Scripts and configuration references maintained

### 📊 Impact
- Cleaner project root (5 fewer files)
- Better separation of temporary vs permanent documentation
- Improved discoverability of project information
- Maintained complete project history and context

### 🔄 Skills-On-Demand Project Status
- Phase 0 (Validation): ✅ Complete
- Phase 1 (Skills Registry): ✅ Complete
- Backup System: ✅ Operational
- Phase 2 (Detection Algorithm): 🟡 Ready to start
- Expected savings: 94-96% token reduction (~$670/month)

---

## [2.1.0] - 2026-02-15 - Consistency & Quality Update

### 🎯 Focus
Major consistency improvements, bug fixes, and pre-release quality assurance for GitHub publication.

### ✨ Fixed

#### Configuration Consistency
- ✅ Fixed memory file references in `betteragents.json` (.md → .json)
- ✅ Corrected agent count description (13 specialized → 12 specialized + 1 orchestrator)
- ✅ Fixed skills count in `agent-skills.json` (61 → 58)
- ✅ Corrected individual skill counts (tester: 5, data-scientist: 3)
- ✅ Unified version to 2.1.0 across all files

#### Scripts
- ✅ Fixed `verify-system.sh` to search for .md files instead of .json
- ✅ Updated agent count verification (12 → 13 total including AgentX)

#### Documentation
- ✅ Removed contradictory version number in README (4.0.0 → 2.1.0)
- ✅ Clarified agent system description throughout documentation
- ✅ Cleaned up .gitignore unnecessary references

### 📊 Quality Metrics
- Consistency score improved: 62/100 → 95/100
- All blocker issues resolved
- All critical issues resolved
- Ready for GitHub publication

---

## [2.0.0] - 2026-02-14 - Initial Public Release

### 🎯 Objective
First stable public release with complete agent system, memory management, and skills integration.

### ✨ Features

#### Agent System
- ✅ 12 specialized agents (Architect, Coder, Critic, Security, Tester, UX-Designer, Writer, Teacher, Product-Manager, DevOps, Data-Scientist, Researcher)
- ✅ AgentX orchestrator with 4-D methodology
- ✅ Intelligent routing and multi-agent workflows

#### Memory System
- ✅ JSON-based persistent memory (active-context, decision-log, progress, patterns)
- ✅ Interactive HTML dashboard
- ✅ Automatic documentation by agents

#### Skills Integration
- ✅ Integration with skills.sh ecosystem
- ✅ Pre-included ui-ux-pro-max skill
- ✅ 58 recommended skills across all agents
- ✅ Global skills directory (~/.claude/skills/)

#### Installation & Setup
- ✅ Automated init.sh script
- ✅ Automated install.sh script
- ✅ System verification script
- ✅ Symlink-based architecture (no duplication)

#### Documentation
- ✅ Complete README with installation guide
- ✅ Agent documentation
- ✅ Memory system guide
- ✅ Troubleshooting guide
- ✅ Contributing guidelines

### 🏗️ Architecture
- Symlink-based structure for easy updates
- Project-specific memory (not shared)
- Global skills (shared across projects)
- Non-invasive integration (only .claude/ folder)

---

## [1.0.0] - 2026-02-12 - Initial Development

### 🎯 Objective
Initial development and testing of multi-agent system concept.

### ✨ Features
- Basic agent system
- Initial memory implementation
- Core documentation

---

**Repository:** https://github.com/jemavidev/BetterAgentX  
**License:** MIT  
**Author:** JEMAVI (Jesus Maria Villalobos)

### 🎯 Objective
Major consistency update: unified version numbering, JSON-based memory system, and improved documentation.

### ✨ Changes

#### Version Unification
- ✅ **Unified version to 2.1.0** across all files
- ✅ Single source of truth in betteragents.json
- ✅ Consistent versioning in README, config, and changelog

#### Memory System Standardization
- ✅ **Memory files now use JSON format** (.json instead of .md)
- ✅ Updated all documentation to reflect JSON format
- ✅ Updated init.sh to copy .json templates
- ✅ Removed Python dependency (no sync-memory.py needed)
- ✅ Dashboard reads JSON files directly

#### File Structure Cleanup
- ✅ **Removed empty example folders** (collaborative-dev, custom-agent)
- ✅ **Fixed circular symlink** in .claude/steering/agentx/
- ✅ Cleaned up inconsistent references

#### Documentation Improvements
- ✅ **Documented agents-map.json** structure and purpose
- ✅ Updated all memory file references (.md → .json)
- ✅ Clarified dashboard functionality
- ✅ Removed Python script references

### 📊 Impact
- Consistency improved from 65% to 95%
- Clearer system architecture
- Easier maintenance
- Better user experience

---

## [3.2.0] - 2026-02-13 - Integration System (DEPRECATED)

### 🎯 Objective
Enable BetterAgentX integration into any project using symbolic links without file duplication, with automatic memory activation.

### ✨ New Features

#### Automatic Memory Activation (NEW!)
- ✅ **Automatic memory activation on initialization**
  - Creates `.kirorc` file with memory.enabled=true
  - Creates `.claude/settings/kiro.json` with memory configuration
  - Memory files load automatically when opening Kiro
  - No manual activation needed
  - Improves user experience significantly
  - `.kirorc` is included in repository (not ignored)

#### Integration System
- ✅ **init-betteragentx.sh** - Automatic integration script
  - Detects BetterAgentX location
  - Creates project structure (.claude/, .agents/)
  - Creates symbolic links to agents, agentx, common, skills
  - Copies personalizable configurations
  - Initializes project-specific memory system
  - Creates .betteragentx configuration file
  - Updates .gitignore automatically

- ✅ **verify-betteragentx.sh** - Integration verification script
  - Verifies symbolic links
  - Checks project structure
  - Validates available agents
  - Verifies memory system
  - Diagnoses common problems
  - Provides detailed solutions

#### Complete Documentation
- ✅ **INTEGRATION.md** - Complete integration guide
  - Key concepts (symbolic links)
  - Integration methods (automatic, submodule, manual)
  - Complete project structure
  - Configuration and personalization
  - Memory system per project
  - Update and maintenance
  - Troubleshooting
  - Use cases (new project, existing, monorepo)

- ✅ **QUICKSTART-INTEGRATION.md** - Quick start in 3 steps
  - Option A: New project
  - Option B: Existing project
  - Option C: Git submodule
  - Structure created
  - Installation verification
  - Personalization
  - Common problems

- ✅ **INDEX.md** - Complete documentation navigation
  - Quick start
  - Integration
  - Agents
  - Memory system
  - Guides
  - Scripts
  - Configuration
  - Examples

#### README Updates
- ✅ Added integration section
- ✅ Two installation options (standalone vs integrated)
- ✅ Integration benefits explanation
- ✅ Created structure visualization

#### .gitignore Updates
- ✅ Ignores .claude/settings/ (local configurations)
- ✅ Ignores .betteragentx (integration config)
- ✅ Maintains .claude/memory/ ignored

### 🔧 Technical Improvements

#### Symbolic Links System
- No file duplication
- Automatic updates with git pull
- Separation between source and configuration
- Multiple projects can share one BetterAgentX

#### Project-Specific Memory
- Each project has its own memory
- Initialized from templates
- Not uploaded to Git
- Personalizable per project

#### Local Configuration
- Personalizable configurations per project
- Not uploaded to Git
- Copied from BetterAgentX templates

### 📊 Benefits

- ✅ Use BetterAgentX in any project
- ✅ No file duplication
- ✅ Easy updates
- ✅ Project-specific memory
- ✅ Local configurations
- ✅ Multiple projects sharing BetterAgentX

### 🎯 Use Cases

1. **New Project** - Initialize with BetterAgentX from start
2. **Existing Project** - Add BetterAgentX to existing project
3. **Monorepo** - Use in monorepo root
4. **Multiple Projects** - Share one BetterAgentX between projects

### 📚 New Files

- `scripts/init-betteragentx.sh` - Integration initialization
- `scripts/verify-betteragentx.sh` - Integration verification
- `INTEGRATION.md` - Complete guide
- `QUICKSTART-INTEGRATION.md` - Quick start
- `INDEX.md` - Documentation navigation
- `PUSH-INSTRUCTIONS.md` - GitHub push instructions

---

## [3.0.0] - 2026-02-12 - Radical Simplification + GitHub Guide

### 🎯 Objective
Simplify the system to the maximum and create complete guide for installation from GitHub.

### ✨ New in This Version

#### Complete Documentation
- ✅ **AgentX.md** - Complete installation guide from GitHub
  - Step-by-step installation for Ubuntu/Debian
  - Detailed troubleshooting
  - Useful commands and maintenance
  - Additional resources
- ✅ **install.sh** - Automatic installation script
  - Verifies dependencies
  - Installs Node.js if needed
  - Option to install skills
  - Complete system verification
- ✅ **contributing.md** - Guide for contributors
  - How to contribute to the project
  - Style guide
  - Pull Request process
- ✅ **.gitignore** - Git configuration
- ✅ **license** - MIT License

#### System Improvements
- ✅ **Skills update system**
  - `update-skills.sh` script to update all skills
  - `check-updates.sh` script for quick verification
  - Configuration in `.betteragents-config`
  - Integration in `install.sh` to detect existing skills
  - Support for automatic updates
- ✅ **Intelligent detection in install.sh**
  - Detects if skills are already installed
  - Offers to update instead of reinstall
  - Option to install additional skills

### ✅ Maintained (Essential)
- 12 specialized agents in `.claude/steering/agents/`
  - architect.md
  - coder.md
  - critic.md
  - data-scientist.md
  - devops.md
  - product-manager.md
  - researcher.md
  - security.md
  - teacher.md
  - tester.md
  - ux-designer.md
  - writer.md
- Skills system in `.claude/skills/` (template)
- Skills globales en `~/.claude/skills/` (compartidos)
- Main documentation (README.md, AgentX.md)
- Simplified manifest (betteragents.json)

### ❌ Removed (Unnecessary Complexity)

#### Complete Folders
- `.backups/` - 60 automatic backup files
- `scripts/` - 4 CLI scripts (betteragents, validators)
- `hooks/` - Complex hooks system
- `src/` - Unnecessary source code
- `templates/` - Unused templates
- `.claude/config/` - Redundant configurations
- `.claude/memory/` - Non-essential memory system

#### Files
- 169 `.backup*` files (incremental backups)
- 6 `.sh` scripts (bash scripts)
- 8 redundant documentation files
- 2 configuration files

### 📊 Impact

#### Before (v2.1.0)
```
Total files:          ~200+
Backup files:         169
Scripts:              4
Folders:              10+
Size:                 ~2.5MB
Complexity:           High
```

#### After (v3.0.0)
```
Total files:          ~15
Backup files:         0
Scripts:              0
Folders:              4
Size:                 812KB
Complexity:           Minimal
```

#### Improvements
- 📉 92% reduction in number of files
- 📉 68% reduction in total size
- ⚡ Faster and lighter system
- 🎯 Focus on essentials
- 🔧 Simplified maintenance
- 🚀 Faster installation

### 🏗️ Final Structure

```
BetterAgents/
├── .agents/
│   └── skills/
│       └── ui-ux-pro-max/
├── .claude/
│   ├── skills/ (symlink)
│   └── steering/
│       └── agents/ (12 agents)
├── AgentX.md
├── betteragents.json
├── CHANGELOG.md
└── README.md
```

### 🎯 Philosophy of Change

**Before:** Complex system with multiple layers of abstraction, automatic backups, CLI, menus, hooks, and fragmented documentation.

**After:** Minimalist system that maintains only what's essential to function: the 12 agents and the skills system.

### 💡 Applied Principles

1. **KISS (Keep It Simple, Stupid)** - Remove all unnecessary complexity
2. **YAGNI (You Aren't Gonna Need It)** - Remove unused features
3. **Minimalism** - Only essentials to function
4. **Maintainability** - Fewer files = easier to maintain

### 🚀 Usage

The system works exactly the same as before, but without the complexity:

```bash
# Open Kiro
kiro .

# Use agents
@architect Design a system...
@coder Implement this...
@critic Review this design...
```

### 📝 Notes

- Agents work perfectly without backups
- Skills are installed with `npx skills add`
- No scripts needed for validation
- Documentation is consolidated in README.md and AgentX.md

---

**Result:** 92% simpler system, maintaining 100% of essential functionality.
