#!/usr/bin/env node
/**
 * BetterAgents Multi-Platform — Memory Bridge
 * Reads memory from .claude/memory/ and provides unified access
 * 
 * Usage:
 *   node .betteragents/sync/memory-bridge.js [command] [options]
 * 
 * Commands:
 *   read <file>          Read a specific memory file
 *   summary              Get memory summary
 *   decisions [limit]    Get recent decisions
 *   tasks [status]       Get tasks by status
 *   patterns [category]  Get patterns by category
 */

const fs = require('fs');
const path = require('path');

const MEMORY_DIR = path.join(__dirname, '../../.claude/memory');

// ── Helper Functions ──────────────────────────────────────────────────────────

function readJSON(filename) {
    const filepath = path.join(MEMORY_DIR, filename);
    if (!fs.existsSync(filepath)) {
        throw new Error(`File not found: ${filename}`);
    }
    return JSON.parse(fs.readFileSync(filepath, 'utf8'));
}

function readMarkdown(filename) {
    const filepath = path.join(MEMORY_DIR, filename);
    if (!fs.existsSync(filepath)) {
        throw new Error(`File not found: ${filename}`);
    }
    return fs.readFileSync(filepath, 'utf8');
}

// ── Command Handlers ──────────────────────────────────────────────────────────

function handleRead(file) {
    if (file.endsWith('.json')) {
        return readJSON(file);
    } else if (file.endsWith('.md')) {
        return readMarkdown(file);
    } else {
        throw new Error('Unsupported file type. Use .json or .md');
    }
}

function handleSummary() {
    const activeContext = readJSON('active-context.json');
    const progress = readJSON('progress.json');
    const decisions = readJSON('decision-log.json');
    const patterns = readJSON('patterns.json');
    
    return {
        project: activeContext.project,
        currentFocus: activeContext.currentFocus,
        stats: {
            tasks: progress.summary,
            decisions: decisions.summary,
            patterns: patterns.summary
        },
        lastUpdated: activeContext.lastUpdated
    };
}

function handleDecisions(limit = 5) {
    const decisions = readJSON('decision-log.json');
    return decisions.decisions.slice(-limit).reverse();
}

function handleTasks(status = null) {
    const progress = readJSON('progress.json');
    if (!status) {
        return progress.tasks;
    }
    return progress.tasks.filter(t => t.status === status);
}

function handlePatterns(category = null) {
    const patterns = readJSON('patterns.json');
    if (!category) {
        return patterns.patterns;
    }
    return patterns.patterns.filter(p => p.category === category);
}

// ── CLI Interface ─────────────────────────────────────────────────────────────

const [,, command, ...args] = process.argv;

try {
    let result;
    
    switch (command) {
        case 'read':
            result = handleRead(args[0]);
            break;
        case 'summary':
            result = handleSummary();
            break;
        case 'decisions':
            result = handleDecisions(parseInt(args[0]) || 5);
            break;
        case 'tasks':
            result = handleTasks(args[0]);
            break;
        case 'patterns':
            result = handlePatterns(args[0]);
            break;
        default:
            console.error('Unknown command. Available: read, summary, decisions, tasks, patterns');
            process.exit(1);
    }
    
    console.log(JSON.stringify(result, null, 2));
} catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
}
