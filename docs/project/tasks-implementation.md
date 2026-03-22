# 📋 Implementation Tasks: Multi-Platform Adapter System

**Project:** BetterAgents Multi-Platform
**Date:** 2026-03-02
**Total Estimate:** 89 hours (~2.5 weeks)

---

## 🎯 Objective

Create adapters that allow using the BetterAgents system (currently 100% functional in Claude Code) in Kiro, keeping the Claude system as the core and source of truth.

**Principle:** `.claude/` is NOT modified. Only adapters are created.

---

## 📊 Executive Summary

| Phase | Tasks | Hours | Priority | Description |
|-------|-------|-------|----------|-------------|
| **Phase 1** | 4 | 9h | 🔴 High | Analysis and foundations |
| **Phase 2** | 5 | 30h | 🔴 High | Claude → Kiro translator |
| **Phase 3** | 3 | 16h | 🟡 Medium | Synchronization |
| **Phase 4** | 6 | 30h | 🟡 Medium | Kiro → Claude translator (optional) |
| **Phase 5** | 4 | 20h | 🟢 Low | Extensibility (optional) |
| **TOTAL** | **22** | **89h** | - | - |

**Minimum viable:** Phases 1–3 = 55 hours
**Recommended:** Phases 1–4 = 85 hours

---

## 🔴 PHASE 1: Analysis and Foundations (9 hours)

### ✅ 1.1 Deep analysis of the current Claude system
**Estimate:** 2 hours
**Priority:** High
**Assigned:** Architect + Researcher

**Objective:** Fully document the Claude Code system as a reference for creating adapters.

**Specific tasks:**

1. **Analyze agents** (.claude/agents/*.md)
   - Format: YAML frontmatter + markdown
   - Required fields: name, description
   - Sections: Role, Expertise, Core Principles, Guidelines, Output Format
   - Identify common patterns among the 12 agents
   - Example: architect.md has 450 lines, coder.md has 380 lines

2. **Analyze skills** (.claude/commands/*.md)
   - Format: YAML frontmatter + markdown
   - Fields: description (required)
   - Sections: When to Use, Core Concepts, Patterns, Best Practices, Resources
   - 76 skills total
   - Categories: architecture (8), implementation (15), testing (6), deployment (4), etc.
   - Example: api-design-principles.md has 600+ lines with code examples

3. **Analyze memory** (.claude/memory/*.json)
   - `decision-log.json`: {id, title, date, agent, status, tags, context, decision, consequences}
   - `progress.json`: {tasks[], milestones[], summary, timeline, metadata}
   - `patterns.json`: {patterns[], categories, summary, suggestions}
   - `active-context.json`: {project, techStack, currentFocus, nextSteps}
   - All use ISO-8601 timestamps with timezone

4. **Analyze scripts** (.claude/scripts/*.sh)
   - `add-task.sh`: 8 parameters, validations, atomic writes with jq
   - `add-decision.sh`: 6 parameters, enrich fields afterwards
   - `add-pattern.sh`: 6 parameters, auto-generates PAT-NN
   - `update-context.sh`: multiple flags, complex operations
   - All use `/tmp/_mem_*.json && mv` for atomicity

5. **Analyze CLAUDE.md** (orchestrator)
   - 450+ lines
   - Sections: Identity, 4-D Methodology, Agent Ecosystem, Dispatch Rules, Protocols
   - Memory Context Injection: ~150 tokens max
   - Skill Injection: max 3 skills via detect-skills.sh
   - Memory Writes: 5 mandatory triggers
   - Protocol 5b: autonomous self-assessment gate

**Deliverable:** `.betteragents/CORE-REFERENCE.md` (100+ page document)

**Document structure:**
```markdown
# BetterAgents Core System Reference

## 1. General Architecture
## 2. Agent System
### 2.1 Agent Format
### 2.2 Available Agents (12)
### 2.3 Common Patterns
## 3. Skills System
### 3.1 Skills Format
### 3.2 Skills Categories
### 3.3 Critical Skills
## 4. Memory System
### 4.1 Memory Files
### 4.2 Data Formats
### 4.3 Write Scripts
## 5. Orchestrator (CLAUDE.md)
### 5.1 4-D Methodology
### 5.2 Mandatory Protocols
### 5.3 Memory Injection
## 6. Adapter Guide
### 6.1 What to translate
### 6.2 What to preserve
### 6.3 Known limitations
```

---

### ✅ 1.2 Create `.betteragents/` structure
**Estimate:** 1 hour
**Priority:** High
**Assigned:** Coder

**Objective:** Create the directory structure for the adapters.

**Commands:**
```bash
# Create directories
mkdir -p .betteragents/core
mkdir -p .betteragents/adapters/kiro
mkdir -p .betteragents/adapters/template
mkdir -p .betteragents/sync
mkdir -p .betteragents/backups

# Create base files
touch .betteragents/core/README.md
touch .betteragents/core/reference.json
touch .betteragents/config.json
touch .betteragents/sync/changelog.json
```

**Files to create:**

1. `.betteragents/core/README.md`
```markdown
# BetterAgents Core

**IMPORTANT:** The system core IS `.claude/`

This directory does NOT contain a copy of the system, only references.

## Structure

- `reference.json`: Points to the Claude system location
- `CORE-REFERENCE.md`: Complete system documentation

## For Adapter Developers

The Claude Code system in `.claude/` is the source of truth.
Adapters READ from `.claude/` and GENERATE files for other platforms.

Do NOT duplicate data. Do NOT modify `.claude/`.
```

2. `.betteragents/core/reference.json`
```json
{
  "version": "1.0.0",
  "coreLocation": ".claude/",
  "corePlatform": "claude-code",
  "coreVersion": "3.7.0",
  "components": {
    "agents": {
      "path": ".claude/agents/",
      "count": 12,
      "format": "markdown with YAML frontmatter"
    },
    "skills": {
      "path": ".claude/commands/",
      "count": 76,
      "format": "markdown with YAML frontmatter"
    },
    "memory": {
      "path": ".claude/memory/",
      "files": [
        "decision-log.json",
        "progress.json",
        "patterns.json",
        "active-context.json",
        "MEMORY.md",
        "session-last.md"
      ]
    },
    "scripts": {
      "path": ".claude/scripts/",
      "critical": [
        "add-task.sh",
        "add-decision.sh",
        "add-pattern.sh",
        "update-context.sh"
      ]
    },
    "orchestrator": {
      "file": "CLAUDE.md",
      "lines": 450
    }
  },
  "lastAnalyzed": "2026-03-02T07:00:00-05:00"
}
```

3. `.betteragents/config.json`
```json
{
  "version": "1.0.0",
  "created": "2026-03-02T07:00:00-05:00",
  "activePlatform": "claude-code",
  "platforms": {
    "claude-code": {
      "enabled": true,
      "isCore": true,
      "path": ".claude/"
    },
    "kiro": {
      "enabled": false,
      "isCore": false,
      "path": ".kiro/",
      "adapter": ".betteragents/adapters/kiro/"
    }
  },
  "sync": {
    "autoSync": false,
    "backupBeforeSync": true,
    "maxBackups": 10
  }
}
```

4. `.betteragents/sync/changelog.json`
```json
{
  "version": "1.0.0",
  "lastUpdated": "2026-03-02T07:00:00-05:00",
  "changes": []
}
```

**Deliverable:** Complete directory structure with base files

---

### ✅ 1.3 Implement platform detection
**Estimate:** 2 hours
**Priority:** High
**Assigned:** Coder

**Objective:** Script that detects which platform is running.

**File:** `.betteragents/sync/detect-platform.sh`

```bash
#!/usr/bin/env bash
# BetterAgents — detect-platform.sh
# Detects the active platform
# Priority: ENV > config files > auto-detection

set -e

# 1. Check environment variable (highest priority)
if [ -n "$BETTERAGENTS_PLATFORM" ]; then
    echo "$BETTERAGENTS_PLATFORM"
    exit 0
fi

# 2. Check config file
CONFIG_FILE=".betteragents/config.json"
if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
    ACTIVE=$(jq -r '.activePlatform // empty' "$CONFIG_FILE")
    if [ -n "$ACTIVE" ]; then
        echo "$ACTIVE"
        exit 0
    fi
fi

# 3. Auto-detect based on files present
# Kiro takes priority if both exist (user is working in Kiro)
if [ -d ".kiro" ] && [ -f "KIRO.md" ]; then
    echo "kiro"
    exit 0
fi

# 4. Claude Code (default)
if [ -d ".claude" ] && [ -f "CLAUDE.md" ]; then
    echo "claude-code"
    exit 0
fi

# 5. Unknown
echo "unknown" >&2
exit 1
```

**File:** `.betteragents/sync/platform-info.sh`

```bash
#!/usr/bin/env bash
# BetterAgents — platform-info.sh
# Shows information about the detected platform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM=$("$SCRIPT_DIR/detect-platform.sh")

echo "🔍 BetterAgents Platform Detection"
echo "=================================="
echo ""
echo "Active Platform: $PLATFORM"
echo ""

case "$PLATFORM" in
    claude-code)
        echo "✅ Claude Code detected"
        echo "   Core: .claude/"
        echo "   Orchestrator: CLAUDE.md"
        [ -d ".kiro" ] && echo "   Kiro adapter: .kiro/ (generated)"
        ;;
    kiro)
        echo "✅ Kiro detected"
        echo "   Core: .claude/ (source of truth)"
        echo "   Kiro files: .kiro/ (generated from .claude/)"
        echo "   Orchestrator: KIRO.md (generated from CLAUDE.md)"
        ;;
    unknown)
        echo "❌ No platform detected"
        echo "   Missing .claude/ or .kiro/ directories"
        exit 1
        ;;
esac

echo ""
echo "Adapters available:"
[ -d ".betteragents/adapters/kiro" ] && echo "  - Kiro"
[ -d ".betteragents/adapters/cursor" ] && echo "  - Cursor"

echo ""
echo "Sync status:"
if [ -f ".betteragents/sync/changelog.json" ]; then
    PENDING=$(jq '[.changes[] | select(.status == "pending")] | length' .betteragents/sync/changelog.json 2>/dev/null || echo "0")
    echo "  Pending changes: $PENDING"
else
    echo "  No changelog found"
fi
```

**Tests:**

```bash
# Test 1: With environment variable
export BETTERAGENTS_PLATFORM="kiro"
bash .betteragents/sync/detect-platform.sh
# Expected: kiro

# Test 2: Without variable, with .kiro/
unset BETTERAGENTS_PLATFORM
mkdir -p .kiro
touch KIRO.md
bash .betteragents/sync/detect-platform.sh
# Expected: kiro

# Test 3: Without variable, only .claude/
rm -rf .kiro KIRO.md
bash .betteragents/sync/detect-platform.sh
# Expected: claude-code

# Test 4: Both present (Kiro takes priority)
mkdir -p .kiro
touch KIRO.md
bash .betteragents/sync/detect-platform.sh
# Expected: kiro
```

**Deliverable:** Functional detection scripts with tests passing

---

### ✅ 1.4 Create memory bridge (memory-bridge.js)
**Estimate:** 4 hours
**Priority:** High
**Assigned:** Coder

**Objective:** JavaScript API that reads from `.claude/memory/` and exposes data in a unified format.

**File:** `.betteragents/sync/memory-bridge.js`

```javascript
#!/usr/bin/env node
/**
 * BetterAgents Memory Bridge
 *
 * Unified API for reading memory from .claude/memory/
 * Does NOT duplicate data, only reads and exposes in consistent format
 */

const fs = require('fs').promises;
const path = require('path');

class MemoryBridge {
  constructor(corePath = '.claude/memory/') {
    this.corePath = corePath;
    this.cache = new Map();
    this.cacheTTL = 60000; // 60 seconds
  }

  /**
   * Reads decision-log.json with optional filters
   */
  async readDecisions(filter = {}) {
    const data = await this._readJSON('decision-log.json');
    let decisions = data.decisions || [];

    // Apply filters
    if (filter.status) {
      decisions = decisions.filter(d => d.status === filter.status);
    }
    if (filter.agent) {
      decisions = decisions.filter(d => d.agent === filter.agent);
    }
    if (filter.tags) {
      const tags = Array.isArray(filter.tags) ? filter.tags : [filter.tags];
      decisions = decisions.filter(d =>
        d.tags && tags.some(tag => d.tags.includes(tag))
      );
    }
    if (filter.since) {
      decisions = decisions.filter(d => new Date(d.date) >= new Date(filter.since));
    }

    return decisions;
  }

  /**
   * Reads progress.json with optional filters
   */
  async readTasks(filter = {}) {
    const data = await this._readJSON('progress.json');
    let tasks = data.tasks || [];

    // Apply filters
    if (filter.status) {
      tasks = tasks.filter(t => t.status === filter.status);
    }
    if (filter.priority) {
      tasks = tasks.filter(t => t.priority === filter.priority);
    }
    if (filter.agent) {
      tasks = tasks.filter(t => t.agent === filter.agent);
    }
    if (filter.tags) {
      const tags = Array.isArray(filter.tags) ? filter.tags : [filter.tags];
      tasks = tasks.filter(t =>
        t.tags && tags.some(tag => t.tags.includes(tag))
      );
    }

    return tasks;
  }

  /**
   * Reads patterns.json with optional filters
   */
  async readPatterns(filter = {}) {
    const data = await this._readJSON('patterns.json');
    let patterns = data.patterns || [];

    // Apply filters
    if (filter.category) {
      patterns = patterns.filter(p => p.category === filter.category);
    }
    if (filter.agent) {
      patterns = patterns.filter(p => p.agent === filter.agent);
    }
    if (filter.minApplications) {
      patterns = patterns.filter(p => p.applications >= filter.minApplications);
    }

    return patterns;
  }

  /**
   * Reads active-context.json
   */
  async readContext() {
    return await this._readJSON('active-context.json');
  }

  /**
   * Gets complete memory summary
   */
  async getMemorySummary() {
    const [decisions, tasks, patterns, context] = await Promise.all([
      this.readDecisions(),
      this.readTasks(),
      this.readPatterns(),
      this.readContext()
    ]);

    return {
      decisions: {
        total: decisions.length,
        byStatus: this._groupBy(decisions, 'status'),
        byAgent: this._groupBy(decisions, 'agent'),
        recent: decisions.slice(-5)
      },
      tasks: {
        total: tasks.length,
        byStatus: this._groupBy(tasks, 'status'),
        byPriority: this._groupBy(tasks, 'priority'),
        byAgent: this._groupBy(tasks, 'agent'),
        recent: tasks.slice(-5)
      },
      patterns: {
        total: patterns.length,
        byCategory: this._groupBy(patterns, 'category'),
        mostUsed: patterns.sort((a, b) => b.applications - a.applications).slice(0, 5)
      },
      context: {
        project: context.project?.name,
        phase: context.project?.phase,
        focus: context.currentFocus?.feature
      }
    };
  }

  /**
   * Reads JSON file with optional cache
   */
  async _readJSON(filename, useCache = true) {
    const cacheKey = filename;

    // Check cache
    if (useCache && this.cache.has(cacheKey)) {
      const cached = this.cache.get(cacheKey);
      if (Date.now() - cached.timestamp < this.cacheTTL) {
        return cached.data;
      }
    }

    // Read file
    const filePath = path.join(this.corePath, filename);
    try {
      const content = await fs.readFile(filePath, 'utf8');
      const data = JSON.parse(content);

      // Update cache
      if (useCache) {
        this.cache.set(cacheKey, {
          data,
          timestamp: Date.now()
        });
      }

      return data;
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error(`Memory file not found: ${filename}`);
      }
      throw error;
    }
  }

  /**
   * Groups array by field
   */
  _groupBy(array, field) {
    return array.reduce((acc, item) => {
      const key = item[field] || 'unknown';
      acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {});
  }

  /**
   * Invalidates cache
   */
  clearCache() {
    this.cache.clear();
  }
}

// CLI interface
if (require.main === module) {
  const bridge = new MemoryBridge();
  const command = process.argv[2];

  (async () => {
    try {
      switch (command) {
        case 'decisions':
          const decisions = await bridge.readDecisions();
          console.log(JSON.stringify(decisions, null, 2));
          break;

        case 'tasks':
          const tasks = await bridge.readTasks();
          console.log(JSON.stringify(tasks, null, 2));
          break;

        case 'patterns':
          const patterns = await bridge.readPatterns();
          console.log(JSON.stringify(patterns, null, 2));
          break;

        case 'context':
          const context = await bridge.readContext();
          console.log(JSON.stringify(context, null, 2));
          break;

        case 'summary':
          const summary = await bridge.getMemorySummary();
          console.log(JSON.stringify(summary, null, 2));
          break;

        default:
          console.error('Usage: node memory-bridge.js <command>');
          console.error('Commands: decisions, tasks, patterns, context, summary');
          process.exit(1);
      }
    } catch (error) {
      console.error('Error:', error.message);
      process.exit(1);
    }
  })();
}

module.exports = MemoryBridge;
```

**Tests:** `.betteragents/sync/memory-bridge.test.js`

```javascript
const MemoryBridge = require('./memory-bridge');
const assert = require('assert');

async function runTests() {
  const bridge = new MemoryBridge();

  console.log('Running MemoryBridge tests...\n');

  // Test 1: Read decisions
  console.log('Test 1: Read decisions');
  const decisions = await bridge.readDecisions();
  assert(Array.isArray(decisions), 'Decisions should be an array');
  console.log(`✅ Found ${decisions.length} decisions\n`);

  // Test 2: Filter decisions by status
  console.log('Test 2: Filter decisions by status');
  const implemented = await bridge.readDecisions({ status: 'implemented' });
  assert(implemented.every(d => d.status === 'implemented'), 'All should be implemented');
  console.log(`✅ Found ${implemented.length} implemented decisions\n`);

  // Test 3: Read tasks
  console.log('Test 3: Read tasks');
  const tasks = await bridge.readTasks();
  assert(Array.isArray(tasks), 'Tasks should be an array');
  console.log(`✅ Found ${tasks.length} tasks\n`);

  // Test 4: Filter tasks by status
  console.log('Test 4: Filter tasks by status');
  const completed = await bridge.readTasks({ status: 'completed' });
  assert(completed.every(t => t.status === 'completed'), 'All should be completed');
  console.log(`✅ Found ${completed.length} completed tasks\n`);

  // Test 5: Read patterns
  console.log('Test 5: Read patterns');
  const patterns = await bridge.readPatterns();
  assert(Array.isArray(patterns), 'Patterns should be an array');
  console.log(`✅ Found ${patterns.length} patterns\n`);

  // Test 6: Read context
  console.log('Test 6: Read context');
  const context = await bridge.readContext();
  assert(context.project, 'Context should have project');
  console.log(`✅ Project: ${context.project.name}\n`);

  // Test 7: Get summary
  console.log('Test 7: Get memory summary');
  const summary = await bridge.getMemorySummary();
  assert(summary.decisions, 'Summary should have decisions');
  assert(summary.tasks, 'Summary should have tasks');
  assert(summary.patterns, 'Summary should have patterns');
  console.log(`✅ Summary generated\n`);

  // Test 8: Cache
  console.log('Test 8: Cache functionality');
  const start1 = Date.now();
  await bridge.readDecisions();
  const time1 = Date.now() - start1;

  const start2 = Date.now();
  await bridge.readDecisions(); // Should use cache
  const time2 = Date.now() - start2;

  assert(time2 < time1, 'Cached read should be faster');
  console.log(`✅ Cache working (${time1}ms vs ${time2}ms)\n`);

  console.log('All tests passed! ✅');
}

runTests().catch(console.error);
```

**Usage:**

```bash
# CLI
node .betteragents/sync/memory-bridge.js summary
node .betteragents/sync/memory-bridge.js decisions
node .betteragents/sync/memory-bridge.js tasks

# Tests
node .betteragents/sync/memory-bridge.test.js

# As module
const MemoryBridge = require('./.betteragents/sync/memory-bridge');
const bridge = new MemoryBridge();
const decisions = await bridge.readDecisions({ status: 'implemented' });
```

**Deliverable:** Functional memory-bridge.js with tests passing

---

## 📊 Phase 1 Status

| Task | Estimate | Status | Deliverable |
|------|----------|--------|-------------|
| 1.1 Analysis | 2h | ⏳ Pending | CORE-REFERENCE.md |
| 1.2 Structure | 1h | ⏳ Pending | Directories + base files |
| 1.3 Detection | 2h | ⏳ Pending | detect-platform.sh |
| 1.4 Memory bridge | 4h | ⏳ Pending | memory-bridge.js |
| **PHASE 1 TOTAL** | **9h** | **0/4** | **4 deliverables** |

---

## 🚀 Next Steps

Once Phase 1 is complete:
1. Review CORE-REFERENCE.md with the team
2. Validate that detect-platform.sh works correctly
3. Validate that memory-bridge.js reads correctly from .claude/
4. Proceed to Phase 2: Kiro Translator

---

**Note:** This document contains only Phase 1. Phases 2–5 are documented in `.kiro/specs/multi-platform-integration/tasks.md`
