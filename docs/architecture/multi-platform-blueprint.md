# 🎯 Blueprint: Sistema de Integración Multi-Plataforma BetterAgents

**Versión:** 1.0.0  
**Fecha:** 2026-03-02  
**Estado:** Planificación  

---

## 📋 Resumen Ejecutivo

Este blueprint define la arquitectura y plan de implementación para crear adaptadores multi-plataforma que permitan usar el sistema BetterAgents (actualmente 100% funcional en Claude Code) en Kiro y futuras IDEs.

**PRINCIPIO FUNDAMENTAL:** El sistema actual de Claude Code ES el núcleo. NO se reinventa, se adapta.

### Objetivos Clave
1. **Preservar el Core:** Sistema actual de Claude Code permanece intacto como referencia
2. **Adaptadores, no Reescritura:** Crear traductores que adapten el sistema a otras plataformas
3. **Memoria Unificada:** Historial compartido entre todas las plataformas
4. **Sincronización:** Cambios detectados y aplicados automáticamente
5. **Extensibilidad:** Agregar nuevas plataformas en < 8 horas usando el core existente

---

## 🏗️ Arquitectura Propuesta

### Principio de Diseño

```
┌─────────────────────────────────────────────────────────────┐
│  SISTEMA ACTUAL (Claude Code) = NÚCLEO FUNCIONAL            │
│  ✅ 12 Agentes | ✅ 76 Skills | ✅ Memoria | ✅ Protocolos   │
│                                                              │
│  Este sistema NO se modifica. Es la REFERENCIA.             │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │  ADAPTADORES  │
                    └───────────────┘
                    ↓               ↓
            ┌──────────┐      ┌──────────┐
            │   Kiro   │      │  Cursor  │
            └──────────┘      └──────────┘
```

### Estructura de Directorios

```
BetterAgents-K/
├── .claude/                          # ✅ SISTEMA ACTUAL (NO TOCAR)
│   ├── agents/                       # 12 agentes funcionando
│   ├── commands/                     # 76 skills funcionando
│   ├── memory/                       # Sistema de memoria funcionando
│   ├── protocols/                    # Protocolos funcionando
│   └── scripts/                      # Scripts funcionando
│
├── CLAUDE.md                         # ✅ Orchestrator funcionando
├── .claudecode.json                  # ✅ Configuración funcionando
├── config/betteragents.json          # ✅ Metadata funcionando
│
├── .betteragents/                    # 🆕 Capa de adaptación
│   ├── core/                         # 🔗 Referencia al sistema Claude
│   │   ├── README.md                 # "El core ES .claude/"
│   │   └── reference.json            # Apunta a .claude/ como fuente
│   │
│   ├── adapters/                     # Traductores por plataforma
│   │   ├── kiro/
│   │   │   ├── translator.js         # Claude → Kiro
│   │   │   ├── reverse-translator.js # Kiro → Claude
│   │   │   ├── KIRO.md               # Orchestrator adaptado
│   │   │   └── sync-hook.sh
│   │   │
│   │   ├── cursor/                   # Futuro
│   │   │   └── translator.js
│   │   │
│   │   └── template/                 # Template base
│   │       ├── README.md
│   │       ├── translator-template.js
│   │       └── integration-guide.md
│   │
│   ├── sync/                         # Sistema de sincronización
│   │   ├── changelog.json            # Registro de cambios
│   │   ├── sync-engine.js            # Motor principal
│   │   └── memory-bridge.js          # Puente de memoria
│   │
│   └── config.json                   # Configuración de adaptadores
│
├── .kiro/                            # 🆕 Generado por adaptador
│   ├── agents/                       # Traducidos desde .claude/agents/
│   ├── skills/                       # Traducidos desde .claude/commands/
│   └── steering/                     # Adaptado desde .claude/memory/
│
└── KIRO.md                           # 🆕 Generado desde CLAUDE.md
```

**REGLA DE ORO:** `.claude/` es la fuente de verdad. Todo lo demás se genera/adapta desde ahí.

---

## 🔄 Sistema de Memoria Unificada

### Formato Agnóstico

```json
{
  "meta": {
    "version": "1.0.0",
    "lastSync": "2026-03-02T07:00:00Z",
    "activePlatform": "kiro",
    "platforms": ["claude-code", "kiro"]
  },
  "project": {
    "name": "BetterAgentX",
    "version": "3.7.0",
    "description": "Multi-agent orchestration system"
  },
  "decisions": [
    {
      "id": "DEC-001",
      "timestamp": "2026-03-01T10:00:00Z",
      "title": "Implementar sistema multi-plataforma",
      "context": "Necesidad de trabajar en múltiples IDEs",
      "decision": "Crear núcleo compartido con traductores",
      "platform": "shared",
      "agent": "architect",
      "status": "proposed",
      "tags": ["architecture", "multi-platform"]
    }
  ],
  "tasks": [
    {
      "id": "TASK-001",
      "timestamp": "2026-03-01T11:00:00Z",
      "title": "Crear estructura .betteragents/",
      "status": "pending",
      "platform": "shared",
      "agent": "coder",
      "priority": "high",
      "outcome": null,
      "duration": null
    }
  ],
  "patterns": [
    {
      "id": "PAT-001",
      "name": "platform-translator",
      "category": "architectural",
      "problem": "Diferentes formatos entre plataformas",
      "solution": "Traductor bidireccional con validación",
      "platform": "shared",
      "usageCount": 0
    }
  ],
  "sessions": [
    {
      "id": "sess-20260302-070000",
      "platform": "kiro",
      "startTime": "2026-03-02T07:00:00Z",
      "endTime": null,
      "summary": "Creación de blueprint multi-plataforma",
      "filesModified": ["BLUEPRINT-MULTI-PLATFORM.md"],
      "tokensUsed": 0
    }
  ]
}
```

### APIs de Memoria

```javascript
// Leer memoria
const memory = await Memory.read({ 
  filter: { platform: 'shared', status: 'active' } 
});

// Escribir decisión
await Memory.writeDecision({
  title: "Nueva decisión",
  context: "Por qué se tomó",
  decision: "Qué se decidió",
  agent: "architect"
});

// Sincronizar entre plataformas
await Memory.sync();

// Exportar a formato específico
const claudeFormat = await Memory.export('claude-code');
const kiroFormat = await Memory.export('kiro');
```

---

## 🔀 Sistema de Traducción

### Traductor de Agentes

**Formato Core (agnóstico):**
```json
{
  "id": "architect",
  "name": "Architect",
  "description": "System design and architecture specialist",
  "capabilities": [
    "system-design",
    "api-design",
    "scalability",
    "patterns"
  ],
  "protocols": ["critic-gate", "plan-mode"],
  "contextWindow": 45000,
  "routing": {
    "keywords": ["design", "architecture", "api", "scalability"],
    "complexity": "high"
  }
}
```

**Traducción a Claude Code:**
```markdown
# 🏗️ Architect Agent

**Identity:** System design and architecture specialist

## Capabilities
- System design
- API design
- Scalability planning
- Architecture patterns

## Protocols
- Critic Gate: mandatory review
- Plan Mode: required for complex changes

## Routing
Keywords: design, architecture, api, scalability
Complexity: high
```

**Traducción a Kiro:**
```markdown
# Architect Skill

System design and architecture specialist

## Capabilities
- System design
- API design  
- Scalability
- Patterns

## Context Window
45000 tokens

## Routing
- Keywords: design, architecture, api, scalability
- Complexity: high
```

### Traductor de Skills

Similar al de agentes, convierte entre formatos manteniendo funcionalidad.

---

## 📝 Sistema de Changelog

### Formato de Cambios

```json
{
  "version": "1.0.0",
  "changes": [
    {
      "id": "CHG-001",
      "timestamp": "2026-03-02T08:00:00Z",
      "platform": "kiro",
      "type": "agent",
      "action": "update",
      "component": "architect",
      "description": "Agregado soporte para DDD",
      "files": [
        ".betteragents/platforms/kiro/.kiro/agents/architect.md"
      ],
      "appliedTo": [],
      "status": "pending",
      "diff": {
        "added": ["DDD support"],
        "removed": [],
        "modified": ["capabilities section"]
      }
    }
  ]
}
```

### Flujo de Sincronización

```
1. Usuario abre proyecto en Kiro
   ↓
2. Hook detecta plataforma activa
   ↓
3. Compara con última plataforma usada (claude-code)
   ↓
4. Busca cambios pendientes en changelog.json
   ↓
5. Muestra resumen al usuario:
   "📦 3 cambios pendientes desde Claude Code:
    - CHG-001: Architect agent actualizado
    - CHG-002: Nuevo skill: database-migration
    - CHG-003: Protocol anti-loop mejorado"
   ↓
6. Usuario elige: [Aplicar Todo] [Revisar] [Ignorar]
   ↓
7. Sistema aplica cambios usando traductores
   ↓
8. Actualiza changelog: status = "applied"
   ↓
9. Crea backup automático
   ↓
10. Valida integridad
```

---

## 🎯 Estado Actual vs Estado Deseado

### ✅ Lo que TENEMOS (Sistema Base - Claude Code)

| Componente | Estado | Ubicación | Acción |
|------------|--------|-----------|--------|
| 12 Agentes | ✅ 100% Funcional | `.claude/agents/` | **PRESERVAR** |
| 76 Skills | ✅ 100% Funcional | `.claude/commands/` | **PRESERVAR** |
| Sistema de Memoria | ✅ 100% Funcional | `.claude/memory/` | **USAR COMO BASE** |
| Orchestrator (AgentX) | ✅ 100% Funcional | `CLAUDE.md` | **ADAPTAR** |
| Hooks | ✅ 100% Funcional | `.claude/scripts/` | **PRESERVAR** |
| Protocolos | ✅ 100% Funcional | `.claude/protocols/` | **PRESERVAR** |
| Dashboard | ✅ 100% Funcional | `.claude/memory/dashboard.html` | **PRESERVAR** |

**ESTE SISTEMA ES PERFECTO. NO SE TOCA. ES LA REFERENCIA.**

### 🔨 Lo que FALTA (Capa de Adaptación)

| Componente | Estado | Prioridad | Propósito |
|------------|--------|-----------|-----------|
| Estructura `.betteragents/` | ❌ No existe | 🔴 Alta | Contener adaptadores |
| Traductor Claude → Kiro | ❌ No existe | 🔴 Alta | Generar .kiro/ desde .claude/ |
| Traductor Kiro → Claude | ❌ No existe | 🔴 Alta | Sincronizar cambios de vuelta |
| Sistema de changelog | ❌ No existe | 🟡 Media | Registrar cambios entre plataformas |
| Detección de plataforma | ❌ No existe | 🔴 Alta | Saber qué adaptador usar |
| Sincronización automática | ❌ No existe | 🟡 Media | Aplicar cambios automáticamente |
| KIRO.md (adaptado) | ❌ No existe | 🔴 Alta | Orchestrator para Kiro |
| Template para nuevas plataformas | ❌ No existe | 🟢 Baja | Facilitar nuevos adaptadores |
| Tests de integración | ❌ No existe | 🟡 Media | Validar traducciones |

---

## 📅 Plan de Implementación

### Fase 1: Fundamentos (Semana 1) 🔴 CRÍTICO

**Objetivo:** Crear infraestructura de adaptación SIN tocar el sistema actual

#### Tareas:
1. **Crear estructura `.betteragents/`**
   - Directorios: adapters/, sync/
   - Archivo: config.json con referencia a .claude/
   - **NO crear core/ - el core ES .claude/**
   - Duración: 1 hora

2. **Implementar detección de plataforma**
   - Script: detect-platform.sh
   - Lógica: variables de entorno > archivos config
   - Duración: 2 horas

3. **Crear puente de memoria (memory-bridge.js)**
   - Lee desde .claude/memory/ (fuente de verdad)
   - Expone API unificada para adaptadores
   - NO duplica datos, solo referencia
   - Duración: 4 horas

4. **Documentar sistema actual como referencia**
   - Archivo: .betteragents/CORE-REFERENCE.md
   - Documenta estructura de .claude/
   - Guía para crear adaptadores
   - Duración: 2 horas

**Entregables:**
- ✅ Estructura de adaptadores creada
- ✅ Detección de plataforma funcional
- ✅ Puente de memoria operativo
- ✅ Documentación de referencia completa

**Criterios de Éxito:**
- ✅ Sistema actual de Claude Code funciona EXACTAMENTE igual
- ✅ Ningún archivo en .claude/ fue modificado
- ✅ Puente de memoria lee correctamente desde .claude/memory/
- ✅ Detección identifica correctamente Claude Code

---

### Fase 2: Traductor Kiro (Semana 2) 🔴 CRÍTICO

**Objetivo:** Crear traductor que lee .claude/ y genera .kiro/

#### Tareas:
1. **Implementar traductor Claude → Kiro (agentes)**
   - Archivo: .betteragents/adapters/kiro/translator.js
   - Lee .claude/agents/*.md
   - Genera .kiro/agents/*.md en formato Kiro
   - Duración: 8 horas

2. **Implementar traductor Claude → Kiro (skills)**
   - Lee .claude/commands/*.md
   - Genera .kiro/skills/*.md en formato Kiro
   - Duración: 6 horas

3. **Implementar traductor Claude → Kiro (memoria)**
   - Lee .claude/memory/*.json
   - Genera .kiro/steering/*.md en formato Kiro
   - Duración: 4 horas

4. **Crear KIRO.md desde CLAUDE.md**
   - Parser inteligente de CLAUDE.md
   - Adapta sintaxis a Kiro
   - Mantiene lógica de orchestración
   - Duración: 8 horas

5. **Implementar validador de traducción**
   - Archivo: .betteragents/adapters/kiro/validator.js
   - Verifica que traducción es correcta
   - Duración: 4 horas

**Entregables:**
- ✅ Traductor de agentes funcional
- ✅ Traductor de skills funcional
- ✅ Traductor de memoria funcional
- ✅ KIRO.md generado y funcional
- ✅ Validador operativo

**Criterios de Éxito:**
- ✅ .kiro/ se genera completamente desde .claude/
- ✅ Agentes traducidos mantienen funcionalidad
- ✅ Skills traducidos son ejecutables
- ✅ KIRO.md funciona como orchestrator
- ✅ Sistema Claude Code NO fue modificado

---

### Fase 3: Sincronización (Semana 3) 🟡 IMPORTANTE

**Objetivo:** Detectar y aplicar cambios entre plataformas

#### Tareas:
1. **Implementar sistema de changelog**
   - Archivo: .betteragents/sync/changelog.json
   - Formato de cambios definido
   - Duración: 4 horas

2. **Crear motor de sincronización**
   - Archivo: .betteragents/sync/sync-engine.js
   - Detectar cambios pendientes
   - Duración: 8 horas

3. **Implementar aplicación de cambios**
   - Modos: automático, manual, selectivo
   - Backup antes de aplicar
   - Duración: 6 horas

4. **Crear sistema de rollback**
   - Revertir cambios aplicados
   - Restaurar desde backup
   - Duración: 4 horas

5. **Implementar hooks de sincronización**
   - Hook al iniciar proyecto
   - Hook al cerrar proyecto
   - Duración: 3 horas

**Entregables:**
- ✅ Sistema de changelog funcional
- ✅ Motor de sincronización operativo
- ✅ Aplicación de cambios implementada
- ✅ Rollback funcional
- ✅ Hooks configurados

**Criterios de Éxito:**
- Cambios detectados automáticamente
- Usuario puede revisar antes de aplicar
- Rollback funciona correctamente
- No hay pérdida de datos

---

### Fase 4: Traductor Inverso (Semana 4) 🔴 CRÍTICO

**Objetivo:** Sincronizar cambios de Kiro de vuelta a Claude

#### Tareas:
1. **Implementar traductor Kiro → Claude (agentes)**
   - Archivo: .betteragents/adapters/kiro/reverse-translator.js
   - Lee .kiro/agents/*.md
   - Actualiza .claude/agents/*.md
   - Duración: 8 horas

2. **Implementar traductor Kiro → Claude (skills)**
   - Lee .kiro/skills/*.md
   - Actualiza .claude/commands/*.md
   - Duración: 6 horas

3. **Implementar traductor Kiro → Claude (memoria)**
   - Lee .kiro/steering/*.md
   - Actualiza .claude/memory/*.json
   - Duración: 4 horas

4. **Configurar hooks de sincronización**
   - Hook al iniciar: genera .kiro/ desde .claude/
   - Hook al cerrar: actualiza .claude/ desde .kiro/
   - Duración: 4 horas

5. **Sistema de detección de cambios**
   - Detecta qué archivos cambiaron en .kiro/
   - Solo traduce lo modificado
   - Duración: 4 horas

6. **Tests de integración bidireccional**
   - Probar Claude → Kiro → Claude
   - Validar que no hay pérdida de datos
   - Duración: 4 horas

**Entregables:**
- ✅ Traductor inverso funcional
- ✅ Hooks de sincronización configurados
- ✅ Detección de cambios operativa
- ✅ Tests bidireccionales pasando

**Criterios de Éxito:**
- ✅ Cambios en Kiro se reflejan en .claude/
- ✅ Cambios en Claude se reflejan en .kiro/
- ✅ No hay pérdida de datos en ninguna dirección
- ✅ Sistema Claude sigue siendo la fuente de verdad

---

### Fase 5: Template y Extensibilidad (Semana 5) 🟢 OPCIONAL

**Objetivo:** Facilitar agregar nuevas plataformas usando el sistema Claude como base

#### Tareas:
1. **Crear template de adaptador**
   - Directorio: .betteragents/adapters/template/
   - Archivos: translator-template.js, reverse-translator-template.js
   - Comentarios explicando cada función
   - Duración: 4 horas

2. **Documentar proceso de creación de adaptadores**
   - Guía: "Cómo crear un adaptador en 8 horas"
   - Explica cómo leer .claude/ y generar formato destino
   - Ejemplos de código
   - Duración: 4 horas

3. **Crear adaptador de ejemplo: Cursor**
   - Implementar traductor Claude → Cursor
   - Implementar traductor Cursor → Claude
   - Demostrar que el proceso es replicable
   - Duración: 8 horas

4. **Sistema de registro de adaptadores**
   - Archivo: .betteragents/adapters/registry.json
   - Lista de adaptadores disponibles
   - Carga dinámica según plataforma detectada
   - Duración: 4 horas

**Entregables:**
- ✅ Template de adaptador completo
- ✅ Documentación clara y detallada
- ✅ Adaptador Cursor funcional como ejemplo
- ✅ Sistema de registro operativo

**Criterios de Éxito:**
- ✅ Nueva plataforma se puede agregar en < 8 horas
- ✅ Documentación permite crear adaptador sin ayuda
- ✅ Adaptador Cursor funciona correctamente
- ✅ Sistema Claude permanece intacto

---

## 🎯 Métricas de Éxito

### Técnicas
- ✅ Tasa de sincronización exitosa: > 99%
- ✅ Tiempo de detección de cambios: < 200ms
- ✅ Tiempo de aplicación de cambios: < 2s por componente
- ✅ Cobertura de tests: > 85%

### Operacionales
- ✅ Tiempo para agregar nueva plataforma: < 8 horas
- ✅ Satisfacción del usuario: > 4.5/5
- ✅ Bugs críticos: 0
- ✅ Pérdida de datos: 0

### Funcionales
- ✅ Proyecto funciona en Claude Code: SÍ
- ✅ Proyecto funciona en Kiro: SÍ
- ✅ Sincronización bidireccional: SÍ
- ✅ Memoria unificada: SÍ
- ✅ Rollback funcional: SÍ

---

## ⚠️ Riesgos y Mitigaciones

### Riesgo 1: Incompatibilidades entre formatos
**Probabilidad:** Alta  
**Impacto:** Alto  
**Mitigación:**
- Validación exhaustiva en traductores
- Tests de integración completos
- Versionado de formatos

### Riesgo 2: Pérdida de datos durante sincronización
**Probabilidad:** Media  
**Impacto:** Crítico  
**Mitigación:**
- Backups automáticos antes de cada cambio
- Transacciones atómicas
- Sistema de rollback robusto

### Riesgo 3: Performance degradada
**Probabilidad:** Media  
**Impacto:** Medio  
**Mitigación:**
- Sincronización incremental
- Caché de traducciones
- Lazy loading de componentes

### Riesgo 4: Usuario confundido
**Probabilidad:** Alta  
**Impacto:** Medio  
**Mitigación:**
- UI clara y descriptiva
- Mensajes de ayuda contextuales
- Documentación completa

### Riesgo 5: Conflictos de merge
**Probabilidad:** Media  
**Impacto:** Alto  
**Mitigación:**
- Estrategia de resolución de conflictos
- Timestamps para determinar versión más reciente
- Opción de merge manual

---

## 📊 Estimación de Esfuerzo

| Fase | Duración | Complejidad | Prioridad |
|------|----------|-------------|-----------|
| Fase 1: Fundamentos | 15 horas | Media | 🔴 Alta |
| Fase 2: Traducción | 28 horas | Alta | 🔴 Alta |
| Fase 3: Sincronización | 25 horas | Alta | 🟡 Media |
| Fase 4: Integración Kiro | 30 horas | Alta | 🔴 Alta |
| Fase 5: Extensibilidad | 20 horas | Media | 🟢 Baja |
| **TOTAL** | **118 horas** | **~3 semanas** | - |

**Nota:** Estimación para 1 desarrollador a tiempo completo (40h/semana)

---

## 🚀 Próximos Pasos Inmediatos

### Esta Semana (Fase 1)
1. ✅ Crear este blueprint
2. ⏳ Crear estructura `.betteragents/`
3. ⏳ Implementar detección de plataforma
4. ⏳ Migrar memoria actual a formato unificado

### Próxima Semana (Fase 2)
1. ⏳ Convertir agentes a formato agnóstico
2. ⏳ Implementar traductores Claude Code
3. ⏳ Convertir skills a formato agnóstico

### Semana 3 (Fase 3)
1. ⏳ Implementar sistema de changelog
2. ⏳ Crear motor de sincronización

---

## 📚 Referencias

- Spec completo: `.kiro/specs/multi-platform-integration/requirements.md`
- Sistema actual: `.claude/memory/MEMORY.md`
- Configuración: `config/betteragents.json`
- Documentación: `docs/`

---

**Última actualización:** 2026-03-02  
**Autor:** BetterAgents Team  
**Versión:** 1.0.0
