#!/usr/bin/env node
/**
 * BetterAgents Multi-Platform — AGENTS.md Synchronization
 * Syncs changes between AGENTS.md (universal) and platform-specific files
 * 
 * Usage:
 *   node .betteragents/sync/agents-md-sync.js [command]
 * 
 * Commands:
 *   sync        Sync AGENTS.md to CLAUDE.md and KIRO.md
 *   validate    Validate AGENTS.md format
 *   diff        Show differences between files
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PROJECT_ROOT = path.join(__dirname, '../..');
const AGENTS_MD = path.join(PROJECT_ROOT, 'AGENTS.md');
const CLAUDE_MD = path.join(PROJECT_ROOT, 'CLAUDE.md');
const KIRO_MD = path.join(PROJECT_ROOT, 'KIRO.md');
const CACHE_FILE = path.join(__dirname, '.agents-md-cache.json');

// ── Helper Functions ──────────────────────────────────────────────────────────

function getFileHash(filepath) {
    if (!fs.existsSync(filepath)) return null;
    const content = fs.readFileSync(filepath, 'utf8');
    return crypto.createHash('md5').update(content).digest('hex');
}

function loadCache() {
    if (!fs.existsSync(CACHE_FILE)) {
        return { agentsMd: null, claudeMd: null, kiroMd: null, lastSync: null };
    }
    return JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
}

function saveCache(cache) {
    cache.lastSync = new Date().toISOString();
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
}

// ── Validation ────────────────────────────────────────────────────────────────

function validateAgentsMd() {
    console.log('\n🔍 Validating AGENTS.md...');
    
    if (!fs.existsSync(AGENTS_MD)) {
        console.error('❌ AGENTS.md not found');
        return false;
    }
    
    const content = fs.readFileSync(AGENTS_MD, 'utf8');
    const errors = [];
    const warnings = [];
    
    // Check required sections
    const requiredSections = [
        '## 🧠 Identity',
        '## 🎯 4-D Methodology',
        '## 👥 Agent Ecosystem',
        '## 🚀 Dispatch Rules',
        '## 📋 Mandatory Protocols'
    ];
    
    requiredSections.forEach(section => {
        if (!content.includes(section)) {
            errors.push(`Missing required section: ${section}`);
        }
    });
    
    // Check for AgentX identity
    if (!content.includes('You are **AgentX**')) {
        errors.push('Missing AgentX identity declaration');
    }
    
    // Check for Agent-First policy
    if (!content.includes('Agent-First Policy')) {
        warnings.push('Agent-First Policy not explicitly mentioned');
    }
    
    // Check for dispatch rules
    if (!content.includes('ALWAYS DISPATCH')) {
        warnings.push('ALWAYS DISPATCH rule not found');
    }
    
    // Report results
    if (errors.length > 0) {
        console.log('\n❌ Validation failed:');
        errors.forEach(e => console.log(`  - ${e}`));
        return false;
    }
    
    if (warnings.length > 0) {
        console.log('\n⚠️  Warnings:');
        warnings.forEach(w => console.log(`  - ${w}`));
    }
    
    console.log('\n✅ Validation passed');
    console.log(`  File size: ${(content.length / 1024).toFixed(2)} KB`);
    console.log(`  Lines: ${content.split('\n').length}`);
    
    return true;
}

// ── Synchronization ───────────────────────────────────────────────────────────

function syncToClaude() {
    console.log('\n🔄 Syncing AGENTS.md → CLAUDE.md...');
    
    const agentsContent = fs.readFileSync(AGENTS_MD, 'utf8');
    const claudeContent = fs.existsSync(CLAUDE_MD) 
        ? fs.readFileSync(CLAUDE_MD, 'utf8')
        : '';
    
    // Extract core sections from AGENTS.md
    const coreStart = agentsContent.indexOf('## 🧠 Identity');
    const coreEnd = agentsContent.indexOf('## 🧩 Advanced Features');
    
    if (coreStart === -1 || coreEnd === -1) {
        console.error('❌ Could not find core sections in AGENTS.md');
        return false;
    }
    
    const coreContent = agentsContent.substring(coreStart, coreEnd);
    
    // Extract Claude-specific sections (if they exist)
    const claudeSpecificStart = claudeContent.indexOf('## MANDATORY PROTOCOLS');
    const claudeSpecific = claudeSpecificStart !== -1
        ? claudeContent.substring(claudeSpecificStart)
        : '';
    
    // Build new CLAUDE.md
    const newClaudeMd = `# 🧠 AgentX — BetterAgents Orchestrator

**Core Philosophy:** "I am the router, not the executor. I ensure the right expert handles each task."

**⚠️ NOTE:** This file is generated from AGENTS.md. Edit AGENTS.md for universal changes.

---

${coreContent}

---

${claudeSpecific || '## MANDATORY PROTOCOLS\n\n(See AGENTS.md for protocol details)\n\n---\n\n**Version:** 4.0.0 | **Platform:** Claude Code | **Generated from:** AGENTS.md'}
`;
    
    // Write new CLAUDE.md
    fs.writeFileSync(CLAUDE_MD, newClaudeMd);
    console.log('✓ CLAUDE.md updated');
    
    return true;
}

function syncToKiro() {
    console.log('\n🔄 Syncing AGENTS.md → KIRO.md...');
    
    const agentsContent = fs.readFileSync(AGENTS_MD, 'utf8');
    
    // Extract core sections
    const coreStart = agentsContent.indexOf('## 🧠 Identity');
    const platformStart = agentsContent.indexOf('## 🔧 Platform-Specific Instructions');
    
    if (coreStart === -1 || platformStart === -1) {
        console.error('❌ Could not find sections in AGENTS.md');
        return false;
    }
    
    const coreContent = agentsContent.substring(coreStart, platformStart);
    
    // Build KIRO.md
    const newKiroMd = `# 🧠 BetterAgents for Kiro

**Adapted from:** AgentX (AGENTS.md)
**Version:** 4.0.0
**Platform:** Kiro

**⚠️ NOTE:** This file is generated from AGENTS.md. Edit AGENTS.md for universal changes.

---

${coreContent}

---

## 🔧 Kiro-Specific Instructions

### Agent Invocation
- Use custom agents from \`.kiro/agents/\`
- Agents are invoked via Kiro's custom agent system
- See \`.kiro/agents/\` for available agents

### Memory System
- Steering files in \`.kiro/steering/\` provide persistent context
- Files are auto-loaded on session start
- Update steering files to persist knowledge

### Skills Library
- Skills available in \`.kiro/skills/\`
- Auto-injected based on task context
- 76+ specialized skills covering all domains

### Advanced Features
- Full BetterAgents system in \`.betteragents/\`
- Memory bridge: \`.betteragents/sync/memory-bridge.js\`
- Dashboard: \`.claude/memory/dashboard.html\`

---

**Generated from:** AGENTS.md  
**Last Updated:** ${new Date().toISOString()}  
**Platform:** Kiro
`;
    
    fs.writeFileSync(KIRO_MD, newKiroMd);
    console.log('✓ KIRO.md updated');
    
    return true;
}

function sync() {
    console.log('\n📊 Checking for changes...');
    
    const cache = loadCache();
    const currentHash = getFileHash(AGENTS_MD);
    
    if (!currentHash) {
        console.error('❌ AGENTS.md not found');
        return false;
    }
    
    if (cache.agentsMd === currentHash) {
        console.log('✓ No changes detected in AGENTS.md');
        return true;
    }
    
    console.log('📝 Changes detected in AGENTS.md');
    
    // Validate before syncing
    if (!validateAgentsMd()) {
        console.error('❌ Validation failed. Sync aborted.');
        return false;
    }
    
    // Sync to platform-specific files
    const claudeSuccess = syncToClaude();
    const kiroSuccess = syncToKiro();
    
    if (claudeSuccess && kiroSuccess) {
        // Update cache
        cache.agentsMd = currentHash;
        cache.claudeMd = getFileHash(CLAUDE_MD);
        cache.kiroMd = getFileHash(KIRO_MD);
        saveCache(cache);
        
        console.log('\n✅ Sync complete!');
        console.log(`  Timestamp: ${new Date().toISOString()}`);
        return true;
    }
    
    console.error('\n❌ Sync failed');
    return false;
}

// ── Diff Detection ────────────────────────────────────────────────────────────

function showDiff() {
    console.log('\n📊 Comparing files...');
    
    const agentsHash = getFileHash(AGENTS_MD);
    const claudeHash = getFileHash(CLAUDE_MD);
    const kiroHash = getFileHash(KIRO_MD);
    const cache = loadCache();
    
    console.log('\nCurrent state:');
    console.log(`  AGENTS.md: ${agentsHash || 'NOT FOUND'}`);
    console.log(`  CLAUDE.md: ${claudeHash || 'NOT FOUND'}`);
    console.log(`  KIRO.md: ${kiroHash || 'NOT FOUND'}`);
    
    console.log('\nCached state:');
    console.log(`  AGENTS.md: ${cache.agentsMd || 'NONE'}`);
    console.log(`  CLAUDE.md: ${cache.claudeMd || 'NONE'}`);
    console.log(`  KIRO.md: ${cache.kiroMd || 'NONE'}`);
    console.log(`  Last sync: ${cache.lastSync || 'NEVER'}`);
    
    const changes = [];
    
    if (agentsHash !== cache.agentsMd) {
        changes.push('AGENTS.md has changed');
    }
    if (claudeHash !== cache.claudeMd) {
        changes.push('CLAUDE.md has changed');
    }
    if (kiroHash !== cache.kiroMd) {
        changes.push('KIRO.md has changed');
    }
    
    if (changes.length > 0) {
        console.log('\n📝 Changes detected:');
        changes.forEach(c => console.log(`  - ${c}`));
    } else {
        console.log('\n✓ No changes detected');
    }
    
    console.log('');
}

// ── CLI Interface ─────────────────────────────────────────────────────────────

const [,, command] = process.argv;

try {
    switch (command) {
        case 'sync':
            const success = sync();
            process.exit(success ? 0 : 1);
            break;
        case 'validate':
            const valid = validateAgentsMd();
            process.exit(valid ? 0 : 1);
            break;
        case 'diff':
            showDiff();
            break;
        default:
            console.error('Usage: node agents-md-sync.js [sync|validate|diff]');
            console.error('');
            console.error('Commands:');
            console.error('  sync      - Sync AGENTS.md to CLAUDE.md and KIRO.md');
            console.error('  validate  - Validate AGENTS.md format');
            console.error('  diff      - Show differences between files');
            process.exit(1);
    }
} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
