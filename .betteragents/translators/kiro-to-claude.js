#!/usr/bin/env node
/**
 * BetterAgents Multi-Platform — Kiro to Claude Translator
 * Translates changes from .kiro/ back to .claude/ format
 * 
 * Usage:
 *   node .betteragents/translators/kiro-to-claude.js [type] [options]
 * 
 * Types:
 *   memory       Sync steering changes back to memory
 *   validate     Validate Kiro files before sync
 *   diff         Show differences between Kiro and Claude
 */

const fs = require('fs');
const path = require('path');

const KIRO_DIR = path.join(__dirname, '../../.kiro');
const CLAUDE_DIR = path.join(__dirname, '../../.claude');
const MEMORY_DIR = path.join(CLAUDE_DIR, 'memory');

// ── Helper Functions ──────────────────────────────────────────────────────────

function readJSON(filepath) {
    if (!fs.existsSync(filepath)) {
        throw new Error(`File not found: ${filepath}`);
    }
    return JSON.parse(fs.readFileSync(filepath, 'utf8'));
}

function writeJSON(filepath, data) {
    fs.writeFileSync(filepath, JSON.stringify(data, null, 2) + '\n');
}

function parseSteeringFile(content) {
    // Extract frontmatter and body
    const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!match) return { frontmatter: {}, body: content };
    
    const frontmatter = {};
    match[1].split('\n').forEach(line => {
        const [key, ...valueParts] = line.split(':');
        if (key && valueParts.length) {
            frontmatter[key.trim()] = valueParts.join(':').trim();
        }
    });
    
    return { frontmatter, body: match[2] };
}

// ── Memory Sync (Steering → JSON) ─────────────────────────────────────────────

function syncMemoryFromSteering() {
    console.log('\n🔄 Syncing memory from Kiro steering files...');
    
    const steeringDir = path.join(KIRO_DIR, 'steering');
    
    // Check if steering files exist
    const projectContextFile = path.join(steeringDir, 'project-context.md');
    const decisionsFile = path.join(steeringDir, 'architecture-decisions.md');
    const patternsFile = path.join(steeringDir, 'reusable-patterns.md');
    
    let changesMade = false;
    
    // Sync project context
    if (fs.existsSync(projectContextFile)) {
        const content = fs.readFileSync(projectContextFile, 'utf8');
        const { body } = parseSteeringFile(content);
        
        // Extract key information from markdown
        const projectMatch = body.match(/\*\*Project:\*\* (.+)/);
        const phaseMatch = body.match(/\*\*Phase:\*\* (.+)/);
        const focusMatch = body.match(/\*\*Focus:\*\* (.+)/);
        const objectiveMatch = body.match(/## Current Objective\n(.+)/);
        
        if (projectMatch || phaseMatch || focusMatch || objectiveMatch) {
            const activeContext = readJSON(path.join(MEMORY_DIR, 'active-context.json'));
            
            if (phaseMatch && activeContext.project.phase !== phaseMatch[1]) {
                activeContext.project.phase = phaseMatch[1];
                changesMade = true;
                console.log(`  ✓ Updated phase: ${phaseMatch[1]}`);
            }
            
            if (focusMatch && activeContext.currentFocus.feature !== focusMatch[1]) {
                activeContext.currentFocus.feature = focusMatch[1];
                changesMade = true;
                console.log(`  ✓ Updated focus: ${focusMatch[1]}`);
            }
            
            if (objectiveMatch && activeContext.currentFocus.objective !== objectiveMatch[1]) {
                activeContext.currentFocus.objective = objectiveMatch[1];
                changesMade = true;
                console.log(`  ✓ Updated objective: ${objectiveMatch[1]}`);
            }
            
            if (changesMade) {
                activeContext.lastUpdated = new Date().toISOString();
                writeJSON(path.join(MEMORY_DIR, 'active-context.json'), activeContext);
            }
        }
    }
    
    if (changesMade) {
        console.log('✅ Memory synced from steering files\n');
    } else {
        console.log('ℹ️  No changes detected in steering files\n');
    }
    
    return changesMade;
}

// ── Validation ────────────────────────────────────────────────────────────────

function validateKiroFiles() {
    console.log('\n🔍 Validating Kiro files...');
    
    const errors = [];
    const warnings = [];
    
    // Check agents directory
    const agentsDir = path.join(KIRO_DIR, 'agents');
    if (!fs.existsSync(agentsDir)) {
        errors.push('Missing .kiro/agents/ directory');
    } else {
        const agents = fs.readdirSync(agentsDir).filter(f => f.endsWith('.md'));
        if (agents.length === 0) {
            warnings.push('No agents found in .kiro/agents/');
        } else {
            console.log(`  ✓ Found ${agents.length} agents`);
        }
    }
    
    // Check skills directory
    const skillsDir = path.join(KIRO_DIR, 'skills');
    if (!fs.existsSync(skillsDir)) {
        errors.push('Missing .kiro/skills/ directory');
    } else {
        const skills = fs.readdirSync(skillsDir).filter(f => f.endsWith('.md'));
        if (skills.length === 0) {
            warnings.push('No skills found in .kiro/skills/');
        } else {
            console.log(`  ✓ Found ${skills.length} skills`);
        }
    }
    
    // Check steering directory
    const steeringDir = path.join(KIRO_DIR, 'steering');
    if (!fs.existsSync(steeringDir)) {
        errors.push('Missing .kiro/steering/ directory');
    } else {
        const steering = fs.readdirSync(steeringDir).filter(f => f.endsWith('.md'));
        if (steering.length === 0) {
            warnings.push('No steering files found in .kiro/steering/');
        } else {
            console.log(`  ✓ Found ${steering.length} steering files`);
        }
    }
    
    // Check KIRO.md
    if (!fs.existsSync(path.join(__dirname, '../../KIRO.md'))) {
        warnings.push('KIRO.md not found in project root');
    } else {
        console.log('  ✓ KIRO.md exists');
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
    
    console.log('\n✅ Validation passed\n');
    return true;
}

// ── Diff Detection ────────────────────────────────────────────────────────────

function showDiff() {
    console.log('\n📊 Comparing Kiro and Claude files...');
    
    const differences = [];
    
    // Compare agent counts
    const claudeAgents = fs.readdirSync(path.join(CLAUDE_DIR, 'agents')).filter(f => f.endsWith('.md'));
    const kiroAgents = fs.existsSync(path.join(KIRO_DIR, 'agents')) 
        ? fs.readdirSync(path.join(KIRO_DIR, 'agents')).filter(f => f.endsWith('.md'))
        : [];
    
    if (claudeAgents.length !== kiroAgents.length) {
        differences.push({
            type: 'count',
            component: 'agents',
            claude: claudeAgents.length,
            kiro: kiroAgents.length
        });
    }
    
    // Compare skill counts
    const claudeSkills = fs.readdirSync(path.join(CLAUDE_DIR, 'commands')).filter(f => f.endsWith('.md'));
    const kiroSkills = fs.existsSync(path.join(KIRO_DIR, 'skills'))
        ? fs.readdirSync(path.join(KIRO_DIR, 'skills')).filter(f => f.endsWith('.md'))
        : [];
    
    if (claudeSkills.length !== kiroSkills.length) {
        differences.push({
            type: 'count',
            component: 'skills',
            claude: claudeSkills.length,
            kiro: kiroSkills.length
        });
    }
    
    // Report differences
    if (differences.length === 0) {
        console.log('  ✓ No differences detected');
    } else {
        console.log('\n  Differences found:');
        differences.forEach(d => {
            console.log(`    ${d.component}: Claude has ${d.claude}, Kiro has ${d.kiro}`);
        });
    }
    
    console.log('');
    return differences;
}

// ── CLI Interface ─────────────────────────────────────────────────────────────

const [,, command] = process.argv;

try {
    switch (command) {
        case 'memory':
            syncMemoryFromSteering();
            break;
        case 'validate':
            const valid = validateKiroFiles();
            process.exit(valid ? 0 : 1);
            break;
        case 'diff':
            showDiff();
            break;
        default:
            console.error('Usage: node kiro-to-claude.js [memory|validate|diff]');
            console.error('');
            console.error('Commands:');
            console.error('  memory    - Sync steering changes back to memory');
            console.error('  validate  - Validate Kiro files');
            console.error('  diff      - Show differences between Kiro and Claude');
            process.exit(1);
    }
} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
