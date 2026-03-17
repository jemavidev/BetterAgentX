#!/usr/bin/env node
/**
 * BetterAgents Multi-Platform — Change Detector
 * Detects changes between .claude/ and .kiro/ directories
 * 
 * Usage:
 *   node .betteragents/sync/change-detector.js [options]
 * 
 * Options:
 *   --watch     Watch for changes continuously
 *   --json      Output in JSON format
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const CLAUDE_DIR = path.join(__dirname, '../../.claude');
const KIRO_DIR = path.join(__dirname, '../../.kiro');
const CACHE_FILE = path.join(__dirname, '.sync-cache.json');

// ── Helper Functions ──────────────────────────────────────────────────────────

function getFileHash(filepath) {
    if (!fs.existsSync(filepath)) return null;
    const content = fs.readFileSync(filepath, 'utf8');
    return crypto.createHash('md5').update(content).digest('hex');
}

function loadCache() {
    if (!fs.existsSync(CACHE_FILE)) {
        return { claude: {}, kiro: {}, lastSync: null };
    }
    return JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
}

function saveCache(cache) {
    cache.lastSync = new Date().toISOString();
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
}

function scanDirectory(dir, baseDir) {
    const files = {};
    
    function scan(currentDir) {
        if (!fs.existsSync(currentDir)) return;
        
        const entries = fs.readdirSync(currentDir, { withFileTypes: true });
        
        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);
            const relativePath = path.relative(baseDir, fullPath);
            
            if (entry.isDirectory()) {
                scan(fullPath);
            } else if (entry.isFile() && (entry.name.endsWith('.md') || entry.name.endsWith('.json'))) {
                files[relativePath] = getFileHash(fullPath);
            }
        }
    }
    
    scan(dir);
    return files;
}

function scanRootFiles() {
    const files = {};
    const rootFiles = ['AGENTS.md', 'CLAUDE.md', 'KIRO.md'];
    
    rootFiles.forEach(file => {
        const fullPath = path.join(__dirname, '../../', file);
        if (fs.existsSync(fullPath)) {
            files[file] = getFileHash(fullPath);
        }
    });
    
    return files;
}

// ── Change Detection ──────────────────────────────────────────────────────────

function detectChanges() {
    const cache = loadCache();
    const changes = {
        claude: { added: [], modified: [], deleted: [] },
        kiro: { added: [], modified: [], deleted: [] },
        root: { added: [], modified: [], deleted: [] },
        timestamp: new Date().toISOString()
    };
    
    // Scan root orchestrator files
    const rootFiles = scanRootFiles();
    const cachedRoot = cache.root || {};
    
    for (const [file, hash] of Object.entries(rootFiles)) {
        if (!cachedRoot[file]) {
            changes.root.added.push(file);
        } else if (cachedRoot[file] !== hash) {
            changes.root.modified.push(file);
        }
    }
    
    for (const file of Object.keys(cachedRoot)) {
        if (!rootFiles[file]) {
            changes.root.deleted.push(file);
        }
    }
    
    // Scan current state
    const claudeFiles = {
        agents: scanDirectory(path.join(CLAUDE_DIR, 'agents'), CLAUDE_DIR),
        commands: scanDirectory(path.join(CLAUDE_DIR, 'commands'), CLAUDE_DIR),
        memory: scanDirectory(path.join(CLAUDE_DIR, 'memory'), CLAUDE_DIR)
    };
    
    const kiroFiles = {
        agents: scanDirectory(path.join(KIRO_DIR, 'agents'), KIRO_DIR),
        skills: scanDirectory(path.join(KIRO_DIR, 'skills'), KIRO_DIR),
        steering: scanDirectory(path.join(KIRO_DIR, 'steering'), KIRO_DIR)
    };
    
    // Detect Claude changes
    const allClaudeFiles = { ...claudeFiles.agents, ...claudeFiles.commands, ...claudeFiles.memory };
    const cachedClaude = cache.claude || {};
    
    for (const [file, hash] of Object.entries(allClaudeFiles)) {
        if (!cachedClaude[file]) {
            changes.claude.added.push(file);
        } else if (cachedClaude[file] !== hash) {
            changes.claude.modified.push(file);
        }
    }
    
    for (const file of Object.keys(cachedClaude)) {
        if (!allClaudeFiles[file]) {
            changes.claude.deleted.push(file);
        }
    }
    
    // Detect Kiro changes
    const allKiroFiles = { ...kiroFiles.agents, ...kiroFiles.skills, ...kiroFiles.steering };
    const cachedKiro = cache.kiro || {};
    
    for (const [file, hash] of Object.entries(allKiroFiles)) {
        if (!cachedKiro[file]) {
            changes.kiro.added.push(file);
        } else if (cachedKiro[file] !== hash) {
            changes.kiro.modified.push(file);
        }
    }
    
    for (const file of Object.keys(cachedKiro)) {
        if (!allKiroFiles[file]) {
            changes.kiro.deleted.push(file);
        }
    }
    
    // Update cache
    cache.root = rootFiles;
    cache.claude = allClaudeFiles;
    cache.kiro = allKiroFiles;
    saveCache(cache);
    
    return changes;
}

// ── Output Formatting ─────────────────────────────────────────────────────────

function formatChanges(changes, jsonOutput = false) {
    if (jsonOutput) {
        console.log(JSON.stringify(changes, null, 2));
        return;
    }
    
    const hasChanges = 
        changes.claude.added.length > 0 ||
        changes.claude.modified.length > 0 ||
        changes.claude.deleted.length > 0 ||
        changes.kiro.added.length > 0 ||
        changes.kiro.modified.length > 0 ||
        changes.kiro.deleted.length > 0;
    
    if (!hasChanges) {
        console.log('✓ No changes detected');
        return;
    }
    
    console.log('\n📝 Changes detected:\n');
    
    // Claude changes
    if (changes.claude.added.length > 0 || changes.claude.modified.length > 0 || changes.claude.deleted.length > 0) {
        console.log('Claude (.claude/):');
        if (changes.claude.added.length > 0) {
            console.log(`  + Added: ${changes.claude.added.length} files`);
            changes.claude.added.forEach(f => console.log(`    - ${f}`));
        }
        if (changes.claude.modified.length > 0) {
            console.log(`  ~ Modified: ${changes.claude.modified.length} files`);
            changes.claude.modified.forEach(f => console.log(`    - ${f}`));
        }
        if (changes.claude.deleted.length > 0) {
            console.log(`  - Deleted: ${changes.claude.deleted.length} files`);
            changes.claude.deleted.forEach(f => console.log(`    - ${f}`));
        }
        console.log('');
    }
    
    // Kiro changes
    if (changes.kiro.added.length > 0 || changes.kiro.modified.length > 0 || changes.kiro.deleted.length > 0) {
        console.log('Kiro (.kiro/):');
        if (changes.kiro.added.length > 0) {
            console.log(`  + Added: ${changes.kiro.added.length} files`);
            changes.kiro.added.forEach(f => console.log(`    - ${f}`));
        }
        if (changes.kiro.modified.length > 0) {
            console.log(`  ~ Modified: ${changes.kiro.modified.length} files`);
            changes.kiro.modified.forEach(f => console.log(`    - ${f}`));
        }
        if (changes.kiro.deleted.length > 0) {
            console.log(`  - Deleted: ${changes.kiro.deleted.length} files`);
            changes.kiro.deleted.forEach(f => console.log(`    - ${f}`));
        }
        console.log('');
    }
    
    console.log(`Timestamp: ${changes.timestamp}\n`);
}

// ── CLI Interface ─────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const jsonOutput = args.includes('--json');
const watchMode = args.includes('--watch');

if (watchMode) {
    console.log('👀 Watching for changes... (Press Ctrl+C to stop)\n');
    
    // Initial scan
    const changes = detectChanges();
    formatChanges(changes, jsonOutput);
    
    // Watch for changes every 5 seconds
    setInterval(() => {
        const changes = detectChanges();
        const hasChanges = 
            changes.claude.added.length > 0 ||
            changes.claude.modified.length > 0 ||
            changes.claude.deleted.length > 0 ||
            changes.kiro.added.length > 0 ||
            changes.kiro.modified.length > 0 ||
            changes.kiro.deleted.length > 0;
        
        if (hasChanges) {
            formatChanges(changes, jsonOutput);
        }
    }, 5000);
} else {
    // Single scan
    const changes = detectChanges();
    formatChanges(changes, jsonOutput);
}
