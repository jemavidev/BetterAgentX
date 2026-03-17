#!/usr/bin/env node
/**
 * BetterAgents Multi-Platform — Claude to Kiro Translator
 * Translates .claude/ files to .kiro/ format
 * 
 * Usage:
 *   node .betteragents/translators/claude-to-kiro.js [type] [options]
 * 
 * Types:
 *   agents       Translate all agents
 *   skills       Translate all skills
 *   memory       Translate memory to steering
 *   orchestrator Translate CLAUDE.md to KIRO.md
 *   all          Translate everything
 */

const fs = require('fs');
const path = require('path');

const CLAUDE_DIR = path.join(__dirname, '../../.claude');
const KIRO_DIR = path.join(__dirname, '../../.kiro');

// ── Helper Functions ──────────────────────────────────────────────────────────

function ensureDir(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
}

function parseFrontmatter(content) {
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

// ── Agent Translation ─────────────────────────────────────────────────────────

function translateAgent(agentFile) {
    const content = fs.readFileSync(
        path.join(CLAUDE_DIR, 'agents', agentFile),
        'utf8'
    );
    
    const { frontmatter, body } = parseFrontmatter(content);
    
    // Kiro agent format (custom agent structure)
    const kiroAgent = `# ${frontmatter.name || 'Agent'}

## Description
${frontmatter.description || 'No description available'}

## Content
${body}

---
**Source:** .claude/agents/${agentFile}
**Generated:** ${new Date().toISOString()}
**Platform:** Kiro
`;
    
    const outputPath = path.join(KIRO_DIR, 'agents', agentFile);
    ensureDir(path.dirname(outputPath));
    fs.writeFileSync(outputPath, kiroAgent);
    
    console.log(`✓ Translated agent: ${agentFile}`);
}

function translateAllAgents() {
    const agentsDir = path.join(CLAUDE_DIR, 'agents');
    const agents = fs.readdirSync(agentsDir).filter(f => f.endsWith('.md'));
    
    console.log(`\nTranslating ${agents.length} agents...`);
    agents.forEach(translateAgent);
    console.log(`✓ All agents translated\n`);
}

// ── Skill Translation ─────────────────────────────────────────────────────────

function translateSkill(skillFile) {
    const content = fs.readFileSync(
        path.join(CLAUDE_DIR, 'commands', skillFile),
        'utf8'
    );
    
    const { frontmatter, body } = parseFrontmatter(content);
    
    // Kiro skill format
    const kiroSkill = `# ${skillFile.replace('.md', '')}

## Description
${frontmatter.description || 'No description available'}

## Content
${body}

---
**Source:** .claude/commands/${skillFile}
**Generated:** ${new Date().toISOString()}
**Platform:** Kiro
`;
    
    const outputPath = path.join(KIRO_DIR, 'skills', skillFile);
    ensureDir(path.dirname(outputPath));
    fs.writeFileSync(outputPath, kiroSkill);
    
    console.log(`✓ Translated skill: ${skillFile}`);
}

function translateAllSkills() {
    const commandsDir = path.join(CLAUDE_DIR, 'commands');
    const skills = fs.readdirSync(commandsDir).filter(f => f.endsWith('.md'));
    
    console.log(`\nTranslating ${skills.length} skills...`);
    skills.forEach(translateSkill);
    console.log(`✓ All skills translated\n`);
}

// ── Memory to Steering Translation ────────────────────────────────────────────

function translateMemoryToSteering() {
    console.log('\nTranslating memory to steering files...');
    
    // Read memory files
    const activeContext = JSON.parse(
        fs.readFileSync(path.join(CLAUDE_DIR, 'memory/active-context.json'), 'utf8')
    );
    const decisions = JSON.parse(
        fs.readFileSync(path.join(CLAUDE_DIR, 'memory/decision-log.json'), 'utf8')
    );
    const patterns = JSON.parse(
        fs.readFileSync(path.join(CLAUDE_DIR, 'memory/patterns.json'), 'utf8')
    );
    
    // Create project context steering
    const projectContext = `---
inclusion: always
---

# Project Context

**Project:** ${activeContext.project.name}
**Phase:** ${activeContext.project.phase}
**Focus:** ${activeContext.currentFocus.feature}

## Current Objective
${activeContext.currentFocus.objective}

## Tech Stack
- Languages: ${activeContext.techStack.languages.join(', ')}
- Frameworks: ${activeContext.techStack.frameworks.join(', ')}
- Tools: ${activeContext.techStack.tools.join(', ')}

## Next Steps
${activeContext.nextSteps.map(s => `- ${s}`).join('\n')}

---
**Source:** .claude/memory/active-context.json
**Generated:** ${new Date().toISOString()}
`;
    
    // Create decisions steering
    const recentDecisions = decisions.decisions.slice(-5).reverse();
    const decisionsContent = `---
inclusion: always
---

# Architecture Decisions

Recent architecture decisions from the team:

${recentDecisions.map(d => `
## ${d.id}: ${d.title}
**Date:** ${d.date}
**Agent:** ${d.agent}
**Status:** ${d.status}

**Context:** ${d.context}

**Decision:** ${d.decision || 'See decision-log.json for details'}
`).join('\n')}

---
**Source:** .claude/memory/decision-log.json
**Generated:** ${new Date().toISOString()}
`;
    
    // Create patterns steering
    const recentPatterns = patterns.patterns.slice(-5).reverse();
    const patternsContent = `---
inclusion: always
---

# Reusable Patterns

Patterns identified and used in this project:

${recentPatterns.map(p => `
## ${p.name}
**Category:** ${p.category}
**Used:** ${p.usageCount} times

**Problem:** ${p.description}

**Solution:** ${p.solution}
`).join('\n')}

---
**Source:** .claude/memory/patterns.json
**Generated:** ${new Date().toISOString()}
`;
    
    // Write steering files
    ensureDir(path.join(KIRO_DIR, 'steering'));
    fs.writeFileSync(path.join(KIRO_DIR, 'steering/project-context.md'), projectContext);
    fs.writeFileSync(path.join(KIRO_DIR, 'steering/architecture-decisions.md'), decisionsContent);
    fs.writeFileSync(path.join(KIRO_DIR, 'steering/reusable-patterns.md'), patternsContent);
    
    console.log('✓ Memory translated to steering files\n');
}

// ── Orchestrator Translation ──────────────────────────────────────────────────

function translateOrchestrator() {
    console.log('\nTranslating CLAUDE.md to KIRO.md...');
    
    const claudeContent = fs.readFileSync(
        path.join(__dirname, '../../CLAUDE.md'),
        'utf8'
    );
    
    // Adapt for Kiro (simplified, Kiro has different subagent system)
    const kiroContent = `# 🧠 BetterAgents for Kiro

**Adapted from:** AgentX (Claude Code)
**Version:** 3.7.0
**Platform:** Kiro

---

## Overview

This is an adaptation of the BetterAgents system for Kiro. The core system lives in \`.claude/\` and this file provides Kiro-specific guidance.

## Available Agents

The following specialized agents are available in \`.kiro/agents/\`:

- **architect** - System design and architecture
- **coder** - Implementation and debugging
- **critic** - Critical analysis and risk assessment
- **security** - Security auditing
- **tester** - Testing and QA
- **ux-designer** - UI/UX design
- **writer** - Documentation
- **teacher** - Concept explanation
- **product-manager** - Product strategy
- **devops** - Infrastructure and deployment
- **data-scientist** - Data analysis and ML
- **researcher** - Technology research

## Available Skills

76+ skills are available in \`.kiro/skills/\` covering:
- Architecture patterns
- API design
- Testing strategies
- DevOps practices
- Security best practices
- And more...

## Memory System

Project memory is maintained in \`.claude/memory/\` and synchronized to \`.kiro/steering/\`:

- **project-context.md** - Current project state
- **architecture-decisions.md** - Recent decisions
- **reusable-patterns.md** - Identified patterns

## Usage in Kiro

When working in Kiro, the system will:
1. Load steering files automatically
2. Provide access to specialized agents
3. Inject relevant skills based on context
4. Maintain memory across sessions

## Synchronization

Changes made in Kiro are synchronized back to \`.claude/memory/\` through the \`.betteragents/sync/\` system.

---

**Original System:** CLAUDE.md (AgentX)
**Generated:** ${new Date().toISOString()}
**Platform:** Kiro
`;
    
    fs.writeFileSync(path.join(__dirname, '../../KIRO.md'), kiroContent);
    console.log('✓ KIRO.md created\n');
}

// ── CLI Interface ─────────────────────────────────────────────────────────────

const [,, type] = process.argv;

try {
    switch (type) {
        case 'agents':
            translateAllAgents();
            break;
        case 'skills':
            translateAllSkills();
            break;
        case 'memory':
            translateMemoryToSteering();
            break;
        case 'orchestrator':
            translateOrchestrator();
            break;
        case 'all':
            translateAllAgents();
            translateAllSkills();
            translateMemoryToSteering();
            translateOrchestrator();
            break;
        default:
            console.error('Usage: node claude-to-kiro.js [agents|skills|memory|orchestrator|all]');
            process.exit(1);
    }
    
    console.log('✅ Translation complete!');
} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
