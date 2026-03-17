# 📋 Tareas de Implementación: Sistema de Adaptadores Multi-Plataforma

**Proyecto:** BetterAgents Multi-Platform  
**Fecha:** 2026-03-02  
**Estimación Total:** 89 horas (~2.5 semanas)

---

## 🎯 Objetivo

Crear adaptadores que permitan usar el sistema BetterAgents (actualmente 100% funcional en Claude Code) en Kiro, manteniendo el sistema Claude como núcleo y fuente de verdad.

**Principio:** `.claude/` NO se modifica. Solo se crean adaptadores.

---

## 📊 Resumen Ejecutivo

| Fase | Tareas | Horas | Prioridad | Descripción |
|------|--------|-------|-----------|-------------|
| **Fase 1** | 4 | 9h | 🔴 Alta | Análisis y fundamentos |
| **Fase 2** | 5 | 30h | 🔴 Alta | Traductor Claude → Kiro |
| **Fase 3** | 3 | 16h | 🟡 Media | Sincronización |
| **Fase 4** | 6 | 30h | 🟡 Media | Traductor Kiro → Claude (opcional) |
| **Fase 5** | 4 | 20h | 🟢 Baja | Extensibilidad (opcional) |
| **TOTAL** | **22** | **89h** | - | - |

**Mínimo viable:** Fases 1-3 = 55 horas  
**Recomendado:** Fases 1-4 = 85 horas

---

## 🔴 FASE 1: Análisis y Fundamentos (9 horas)

### ✅ 1.1 Análisis profundo del sistema Claude actual
**Estimación:** 2 horas  
**Prioridad:** Alta  
**Asignado:** Architect + Researcher

**Objetivo:** Documentar completamente el sistema Claude Code como referencia para crear adaptadores.

**Tareas específicas:**

1. **Analizar agentes** (.claude/agents/*.md)
   - Formato: frontmatter YAML + markdown
   - Campos obligatorios: name, description
   - Secciones: Role, Expertise, Core Principles, Guidelines, Output Format
   - Identificar patrones comunes entre los 12 agentes
   - Ejemplo: architect.md tiene 450 líneas, coder.md tiene 380 líneas

2. **Analizar skills** (.claude/commands/*.md)
   - Formato: frontmatter YAML + markdown
   - Campos: description (obligatorio)
   - Secciones: When to Use, Core Concepts, Patterns, Best Practices, Resources
   - 76 skills totales
   - Categorías: architecture (8), implementation (15), testing (6), deployment (4), etc.
   - Ejemplo: api-design-principles.md tiene 600+ líneas con ejemplos de código

3. **Analizar memoria** (.claude/memory/*.json)
   - `decision-log.json`: {id, title, date, agent, status, tags, context, decision, consequences}
   - `progress.json`: {tasks[], milestones[], summary, timeline, metadata}
   - `patterns.json`: {patterns[], categories, summary, suggestions}
   - `active-context.json`: {project, techStack, currentFocus, nextSteps}
   - Todos usan ISO-8601 timestamps con timezone

4. **Analizar scripts** (.claude/scripts/*.sh)
   - `add-task.sh`: 8 parámetros, validaciones, atomic writes con jq
   - `add-decision.sh`: 6 parámetros, enrich fields después
   - `add-pattern.sh`: 6 parámetros, auto-genera PAT-NN
   - `update-context.sh`: múltiples flags, operaciones complejas
   - Todos usan `/tmp/_mem_*.json && mv` para atomicidad

5. **Analizar CLAUDE.md** (orchestrator)
   - 450+ líneas
   - Secciones: Identity, 4-D Methodology, Agent Ecosystem, Dispatch Rules, Protocols
   - Memory Context Injection: ~150 tokens max
   - Skill Injection: max 3 skills via detect-skills.sh
   - Memory Writes: 5 mandatory triggers
   - Protocol 5b: autonomous self-assessment gate

**Entregable:** `.betteragents/CORE-REFERENCE.md` (documento de 100+ páginas)

**Estructura del documento:**
```markdown
# BetterAgents Core System Reference

## 1. Arquitectura General
## 2. Sistema de Agentes
### 2.1 Formato de Agentes
### 2.2 Agentes Disponibles (12)
### 2.3 Patrones Comunes
## 3. Sistema de Skills
### 3.1 Formato de Skills
### 3.2 Categorías de Skills
### 3.3 Skills Críticos
## 4. Sistema de Memoria
### 4.1 Archivos de Memoria
### 4.2 Formato de Datos
### 4.3 Scripts de Escritura
## 5. Orchestrator (CLAUDE.md)
### 5.1 Metodología 4-D
### 5.2 Protocolos Obligatorios
### 5.3 Memory Injection
## 6. Guía para Adaptadores
### 6.1 Qué traducir
### 6.2 Qué preservar
### 6.3 Limitaciones conocidas
```

---

### ✅ 1.2 Crear estructura `.betteragents/`
**Estimación:** 1 hora  
**Prioridad:** Alta  
**Asignado:** Coder

**Objetivo:** Crear la estructura de directorios para los adaptadores.

**Comandos:**
```bash
# Crear directorios
mkdir -p .betteragents/core
mkdir -p .betteragents/adapters/kiro
mkdir -p .betteragents/adapters/template
mkdir -p .betteragents/sync
mkdir -p .betteragents/backups

# Crear archivos base
touch .betteragents/core/README.md
touch .betteragents/core/reference.json
touch .betteragents/config.json
touch .betteragents/sync/changelog.json
```

**Archivos a crear:**

1. `.betteragents/core/README.md`
```markdown
# BetterAgents Core

**IMPORTANTE:** El core del sistema ES `.claude/`

Este directorio NO contiene una copia del sistema, solo referencias.

## Estructura

- `reference.json`: Apunta a la ubicación del sistema Claude
- `CORE-REFERENCE.md`: Documentación completa del sistema

## Para Desarrolladores de Adaptadores

El sistema Claude Code en `.claude/` es la fuente de verdad.
Los adaptadores LEEN desde `.claude/` y GENERAN archivos para otras plataformas.

NO duplicar datos. NO modificar `.claude/`.
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

**Entregable:** Estructura de directorios completa con archivos base

---

### ✅ 1.3 Implementar detección de plataforma
**Estimación:** 2 horas  
**Prioridad:** Alta  
**Asignado:** Coder

**Objetivo:** Script que detecta en qué plataforma se está ejecutando.

**Archivo:** `.betteragents/sync/detect-platform.sh`

```bash
#!/usr/bin/env bash
# BetterAgents — detect-platform.sh
# Detecta la plataforma activa
# Prioridad: ENV > archivos config > detección automática

set -e

# 1. Check environment variable (máxima prioridad)
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
# Kiro tiene prioridad si ambos existen (usuario está trabajando en Kiro)
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

**Archivo:** `.betteragents/sync/platform-info.sh`

```bash
#!/usr/bin/env bash
# BetterAgents — platform-info.sh
# Muestra información de la plataforma detectada

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
# Test 1: Con variable de entorno
export BETTERAGENTS_PLATFORM="kiro"
bash .betteragents/sync/detect-platform.sh
# Expected: kiro

# Test 2: Sin variable, con .kiro/
unset BETTERAGENTS_PLATFORM
mkdir -p .kiro
touch KIRO.md
bash .betteragents/sync/detect-platform.sh
# Expected: kiro

# Test 3: Sin variable, solo .claude/
rm -rf .kiro KIRO.md
bash .betteragents/sync/detect-platform.sh
# Expected: claude-code

# Test 4: Ambos presentes (prioridad a Kiro)
mkdir -p .kiro
touch KIRO.md
bash .betteragents/sync/detect-platform.sh
# Expected: kiro
```

**Entregable:** Scripts de detección funcionales con tests pasando

---

### ✅ 1.4 Crear puente de memoria (memory-bridge.js)
**Estimación:** 4 horas  
**Prioridad:** Alta  
**Asignado:** Coder

**Objetivo:** API JavaScript que lee desde `.claude/memory/` y expone datos en formato unificado.

**Archivo:** `.betteragents/sync/memory-bridge.js`

```javascript
#!/usr/bin/env node
/**
 * BetterAgents Memory Bridge
 * 
 * API unificada para leer memoria desde .claude/memory/
 * NO duplica datos, solo lee y expone en formato consistente
 */

const fs = require('fs').promises;
const path = require('path');

class MemoryBridge {
  constructor(corePath = '.claude/memory/') {
    this.corePath = corePath;
    this.cache = new Map();
    this.cacheTTL = 60000; // 60 segundos
  }

  /**
   * Lee decision-log.json con filtros opcionales
   */
  async readDecisions(filter = {}) {
    const data = await this._readJSON('decision-log.json');
    let decisions = data.decisions || [];

    // Aplicar filtros
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
   * Lee progress.json con filtros opcionales
   */
  async readTasks(filter = {}) {
    const data = await this._readJSON('progress.json');
    let tasks = data.tasks || [];

    // Aplicar filtros
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
   * Lee patterns.json con filtros opcionales
   */
  async readPatterns(filter = {}) {
    const data = await this._readJSON('patterns.json');
    let patterns = data.patterns || [];

    // Aplicar filtros
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
   * Lee active-context.json
   */
  async readContext() {
    return await this._readJSON('active-context.json');
  }

  /**
   * Obtiene resumen completo de memoria
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
   * Lee archivo JSON con caché opcional
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
   * Agrupa array por campo
   */
  _groupBy(array, field) {
    return array.reduce((acc, item) => {
      const key = item[field] || 'unknown';
      acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {});
  }

  /**
   * Invalida caché
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

**Uso:**

```bash
# CLI
node .betteragents/sync/memory-bridge.js summary
node .betteragents/sync/memory-bridge.js decisions
node .betteragents/sync/memory-bridge.js tasks

# Tests
node .betteragents/sync/memory-bridge.test.js

# Como módulo
const MemoryBridge = require('./.betteragents/sync/memory-bridge');
const bridge = new MemoryBridge();
const decisions = await bridge.readDecisions({ status: 'implemented' });
```

**Entregable:** memory-bridge.js funcional con tests pasando

---

## 📊 Estado de Fase 1

| Tarea | Estimación | Estado | Entregable |
|-------|------------|--------|------------|
| 1.1 Análisis | 2h | ⏳ Pendiente | CORE-REFERENCE.md |
| 1.2 Estructura | 1h | ⏳ Pendiente | Directorios + archivos base |
| 1.3 Detección | 2h | ⏳ Pendiente | detect-platform.sh |
| 1.4 Puente memoria | 4h | ⏳ Pendiente | memory-bridge.js |
| **TOTAL FASE 1** | **9h** | **0/4** | **4 entregables** |

---

## 🚀 Próximos Pasos

Una vez completada la Fase 1:
1. Revisar CORE-REFERENCE.md con el equipo
2. Validar que detect-platform.sh funciona correctamente
3. Validar que memory-bridge.js lee correctamente desde .claude/
4. Proceder a Fase 2: Traductor Kiro

---

**Nota:** Este documento contiene solo la Fase 1. Las fases 2-5 están documentadas en `.kiro/specs/multi-platform-integration/tasks.md`
