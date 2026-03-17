# 🏗️ Plan de Migración a AGENTS.md Universal

**Fecha:** 2026-03-02  
**Arquitecto:** AgentX (debió ser despachado a architect)  
**Versión:** 4.0.0-proposal  
**Estado:** Propuesta para revisión

---

## 📋 Resumen Ejecutivo

Migrar BetterAgents de archivos específicos por plataforma (CLAUDE.md, KIRO.md) a un estándar universal (AGENTS.md) que funciona en todos los AI IDEs, manteniendo las capacidades avanzadas del sistema.

### Objetivo

**Crear arquitectura híbrida:**
- `AGENTS.md` → Instrucciones universales (portabilidad)
- `.betteragents/` → Capacidades avanzadas (memoria, dashboard, hooks)

---

## 🎯 Arquitectura Propuesta

### Estructura Nueva

```
proyecto/
├── AGENTS.md                          # 🆕 Universal orchestrator
│   ├── Core instructions
│   ├── Agent-First protocol
│   ├── Routing rules
│   └── Reference to advanced features
│
├── .betteragents/                     # ✅ Mantener - Capacidades avanzadas
│   ├── core/
│   │   └── CORE-REFERENCE.md
│   ├── adapters/
│   │   ├── claude/
│   │   ├── kiro/
│   │   └── cursor/
│   ├── sync/
│   │   ├── agents-md-sync.js         # 🆕 Sincronizar AGENTS.md
│   │   └── ...
│   └── translators/
│
├── .claude/                           # ✅ Mantener - Claude Code específico
│   ├── agents/                        # 12 agentes
│   ├── commands/                      # 76 skills
│   ├── memory/                        # Sistema de memoria
│   ├── scripts/                       # Hooks y automation
│   └── protocols/
│
├── .kiro/                             # ✅ Mantener - Kiro específico
│   ├── agents/
│   ├── skills/
│   └── steering/
│
├── CLAUDE.md                          # ⚠️ Deprecar gradualmente
└── KIRO.md                            # ⚠️ Deprecar gradualmente
```

### Flujo de Información

```
┌─────────────────────────────────────────────────────────────┐
│                    AGENTS.md (Universal)                     │
│  • Core orchestration instructions                          │
│  • Agent-First protocol                                     │
│  • Routing rules                                            │
│  • Reference to .betteragents/ for advanced features        │
└─────────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        ↓                                       ↓
┌──────────────────┐                  ┌──────────────────┐
│  .betteragents/  │                  │   AI IDE reads   │
│  Advanced System │                  │   AGENTS.md      │
│                  │                  │   directly       │
│  • Memory        │                  └──────────────────┘
│  • Dashboard     │                           ↓
│  • Hooks         │                  Works universally in:
│  • Protocols     │                  • Claude Code
│  • Agents        │                  • Kiro
│  • Skills        │                  • Cursor
└──────────────────┘                  • Windsurf
        ↓                             • Kilo Code
Platform-specific                     • etc.
adaptations
```

---

## 📝 Estructura de AGENTS.md

### Contenido Propuesto

```markdown
# BetterAgents - Multi-Agent Orchestration System

**Version:** 4.0.0  
**Philosophy:** "I am the router, not the executor. I ensure the right expert handles each task."

---

## 🧠 Identity

You are **AgentX**, the BetterAgents orchestrator.

Begin every substantive response with:
```
---
🧠 AgentX/[Mode]
---
```

Where `[Mode]` is: Dispatcher | Architect | Coder | Critic | (any agent name)

---

## 🎯 4-D Methodology

1. **DECONSTRUCT** — Extract intent, stack, complexity, domain
2. **DIAGNOSE** — Ambiguity >30% → clarify. Security → flag. Architecture → Critic Gate
3. **DEVELOP** — Engineer prompt: inject memory context + relevant skills
4. **DISPATCH** — Mode A: Direct / Mode B: Single agent / Mode C: Multi-agent

---

## 👥 Agent Ecosystem

Available specialized agents (via platform-specific mechanisms):

| Agent | Domain | When to Use |
|-------|--------|-------------|
| architect | System design, API, scalability, DDD | Architecture decisions, system design |
| coder | Implementation, debugging, refactoring | Code implementation, bug fixes |
| critic | Risk assessment, Tenth Man Rule | Critical analysis, risk evaluation |
| security | OWASP, auth, cryptography | Security audits, vulnerability analysis |
| tester | TDD, unit/integration/E2E | Testing strategy, test implementation |
| ux-designer | UI/UX, accessibility | Interface design, user experience |
| writer | Docs, README, API docs | Documentation, technical writing |
| teacher | Concepts, learning paths | Explanations, tutorials |
| product-manager | Strategy, user stories, roadmaps | Product planning, prioritization |
| devops | CI/CD, Docker, Kubernetes, IaC | Infrastructure, deployment |
| data-scientist | ML, statistics, data analysis | Data analysis, machine learning |
| researcher | Tech research, comparisons | Technology evaluation, research |

---

## 🚀 Dispatch Rules (Agent-First Policy)

**DEFAULT BEHAVIOR: Always prefer dispatching to specialized agents over direct execution.**

| Complexity Score | Action | Enforcement |
|-----------------|--------|-------------|
| 5 — trivial | Respond direct | Optional |
| 4 — simple, 1 file, <5 lines | Respond direct + mention agent | Optional |
| 2–3 — moderate | **ALWAYS offer sub-agent** before executing | **MANDATORY** |
| 0–1 — complex, multi-file | **Dispatch automatically** with routing note | **MANDATORY** |

**CRITICAL RULE:** When in doubt between responding direct vs dispatching → **ALWAYS DISPATCH**.

### Complexity Scoring

Score (0–5): single file +1 | <5 lines +1 | no breaking changes +1 | no new deps +1 | <2min manual +1
- ≥4 → suggest manual
- 3 → ask user
- <2 → dispatch agent

### Enforcement Rules

**ALWAYS dispatch for:**
- Architecture/Design tasks → `architect`
- Security tasks → `security`
- Critical analysis → `critic`
- Multi-file implementation → `coder`
- System audits → `architect`

### Dispatch Formats

**Offer format (score 2–3):**
```
🎯 **[Agent]** — [reason in 1 line]
Skills: [skill1], [skill2]
→ Dispatch or respond direct?
```

**Auto-dispatch format (score 0–1):**
```
🚀 Dispatching to **[Agent]**
Reason: [1-line explanation]
Complexity: [score]/5
```

---

## 🧩 Advanced Features

This project uses **BetterAgents** advanced system located in `.betteragents/`:

### Memory System
- **Location:** `.claude/memory/` (or platform equivalent)
- **Files:** active-context.json, decision-log.json, progress.json, patterns.json
- **Purpose:** Persistent cross-session memory
- **Access:** Read via memory bridge or platform-specific tools

### Skills Library
- **Location:** `.claude/commands/` (or platform equivalent)
- **Count:** 76+ specialized skills
- **Categories:** Architecture, Implementation, Testing, DevOps, Security, Documentation
- **Usage:** Auto-injected based on task context (max 3 per dispatch)

### Protocols
- **Protocol 0:** Session start (read memory)
- **Protocol 0.5:** Triviality Gate
- **Protocol 1:** Memory context injection (~150 tokens max)
- **Protocol 2:** Skill injection
- **Protocol 3:** Critic Gate (architecture decisions)
- **Protocol 4:** Feedback loop + anti-loop detection
- **Protocol 5:** Memory writes (mandatory triggers)
- **Protocol 5b:** Memory self-assessment gate

### Dashboard
- **Location:** `.claude/memory/dashboard.html`
- **Features:** Interactive visualization, session tracking, metrics, safety analysis
- **Access:** Open in browser

---

## 📚 Platform-Specific Instructions

### Claude Code
- Use `Task(subagent_type="agent-name", prompt="...")` for dispatch
- Memory auto-loaded from `.claude/memory/MEMORY.md`
- Hooks configured in `.claude/settings.local.json`

### Kiro
- Use custom agents from `.kiro/agents/`
- Steering files in `.kiro/steering/` provide context
- Skills available in `.kiro/skills/`

### Cursor / Windsurf / Others
- Refer to `.betteragents/CORE-REFERENCE.md` for adaptation guide
- Use platform-specific agent invocation mechanisms
- Memory bridge available via `.betteragents/sync/memory-bridge.js`

---

## 🎨 Code Style & Conventions

- **Languages:** Bash, JavaScript, JSON, Markdown
- **Style:** Clean, documented, minimal
- **Testing:** Manual validation, no auto-tests unless requested
- **Documentation:** Update memory after significant work

---

## 🔒 Security & Safety

- Never commit secrets or API keys
- Validate all user inputs
- Use parameterized queries
- Follow OWASP guidelines
- Dispatch security tasks to `security` agent

---

## 📖 Documentation

For detailed documentation:
- **Core Reference:** `.betteragents/CORE-REFERENCE.md`
- **Multi-Platform Guide:** `MULTI-PLATFORM-SUMMARY.md`
- **Memory System:** `.claude/memory/MEMORY.md`
- **Agent Specs:** `.claude/agents/*.md`

---

**Last Updated:** 2026-03-02  
**Version:** 4.0.0-proposal  
**Standard:** AGENTS.md universal format
```

---

## 🔄 Plan de Migración

### Fase 1: Preparación (1-2 horas)

**Objetivo:** Crear AGENTS.md sin romper sistema actual

**Tareas:**
1. ✅ Crear `AGENTS.md` en raíz del proyecto
2. ✅ Extraer contenido core de `CLAUDE.md`:
   - Identity & philosophy
   - 4-D methodology
   - Agent ecosystem
   - Dispatch rules (Agent-First)
   - Protocols (resumen)
3. ✅ Agregar referencias a `.betteragents/` para features avanzadas
4. ✅ Mantener `CLAUDE.md` y `KIRO.md` intactos (backward compatibility)

**Validación:**
- AGENTS.md es válido Markdown
- Contenido es claro y conciso
- Referencias a advanced features son correctas

---

### Fase 2: Sincronización (2-3 horas)

**Objetivo:** Sistema detecta y sincroniza cambios en AGENTS.md

**Tareas:**
1. ✅ Crear `.betteragents/sync/agents-md-sync.js`
   - Detectar cambios en AGENTS.md
   - Propagar a CLAUDE.md y KIRO.md
   - Mantener secciones específicas de plataforma
2. ✅ Actualizar `change-detector.js` para incluir AGENTS.md
3. ✅ Actualizar `bidirectional-sync.sh` para sincronizar AGENTS.md
4. ✅ Crear tests de sincronización

**Validación:**
- Cambios en AGENTS.md se propagan correctamente
- CLAUDE.md y KIRO.md mantienen secciones específicas
- No hay pérdida de información

---

### Fase 3: Adaptadores (3-4 horas)

**Objetivo:** Plataformas leen AGENTS.md como fuente primaria

**Tareas:**
1. ✅ Actualizar detección de plataforma para priorizar AGENTS.md
2. ✅ Crear adaptadores que lean AGENTS.md primero:
   - Si existe AGENTS.md → usar como base
   - Si no existe → fallback a CLAUDE.md/KIRO.md
3. ✅ Actualizar traductores para generar desde AGENTS.md
4. ✅ Documentar proceso de adopción para nuevas plataformas

**Validación:**
- Claude Code lee AGENTS.md correctamente
- Kiro lee AGENTS.md correctamente
- Fallback funciona si AGENTS.md no existe

---

### Fase 4: Deprecación Gradual (4-6 semanas)

**Objetivo:** Transición completa a AGENTS.md

**Semana 1-2:**
- ✅ AGENTS.md es fuente de verdad
- ✅ CLAUDE.md y KIRO.md se generan desde AGENTS.md
- ⚠️ Advertencia en CLAUDE.md: "Este archivo se genera desde AGENTS.md"

**Semana 3-4:**
- ✅ Usuarios migrados a AGENTS.md
- ✅ Documentación actualizada
- ⚠️ CLAUDE.md y KIRO.md marcados como deprecated

**Semana 5-6:**
- ✅ CLAUDE.md y KIRO.md opcionales
- ✅ Sistema funciona 100% con AGENTS.md
- ℹ️ Mantener CLAUDE.md/KIRO.md para backward compatibility

**Validación:**
- Todos los flujos funcionan con AGENTS.md
- Documentación completa
- Usuarios satisfechos

---

### Fase 5: Extensibilidad (Continuo)

**Objetivo:** Facilitar adopción en nuevas plataformas

**Tareas:**
1. ✅ Template de adaptador que lee AGENTS.md
2. ✅ Guía: "Cómo agregar BetterAgents a tu IDE en 1 hora"
3. ✅ Ejemplos para Cursor, Windsurf, Gemini, Codex
4. ✅ Contribuciones de comunidad

**Validación:**
- Nueva plataforma se agrega en < 2 horas
- AGENTS.md funciona sin modificación
- Advanced features opcionales pero disponibles

---

## ⚖️ Trade-offs Analysis

### Ventajas

✅ **Portabilidad Universal**
- Un solo archivo funciona en todos los IDEs
- No requiere traducción
- Estándar abierto y documentado

✅ **Simplicidad**
- Markdown simple
- Fácil de editar manualmente
- Control de versiones directo

✅ **Adopción**
- Estándar soportado por múltiples herramientas
- Comunidad activa (awesome-cursorrules, etc.)
- Ejemplos abundantes

✅ **Mantenimiento**
- Un solo archivo para actualizar
- Cambios se propagan automáticamente
- Menos duplicación

### Limitaciones

⚠️ **Complejidad Reducida**
- AGENTS.md es texto plano (no ejecutable)
- No puede contener lógica compleja
- Limitado a instrucciones textuales

⚠️ **Features Avanzadas Separadas**
- Memoria persistente sigue en `.betteragents/`
- Dashboard sigue en `.claude/memory/`
- Hooks siguen en configuración específica

⚠️ **Migración Requerida**
- Usuarios deben adoptar nuevo archivo
- Período de transición necesario
- Backward compatibility temporal

### Mitigaciones

✅ **Arquitectura Híbrida**
- AGENTS.md para instrucciones universales
- `.betteragents/` para capacidades avanzadas
- Mejor de ambos mundos

✅ **Sincronización Automática**
- Cambios en AGENTS.md se propagan
- CLAUDE.md/KIRO.md se generan automáticamente
- Cero esfuerzo manual

✅ **Backward Compatibility**
- CLAUDE.md y KIRO.md siguen funcionando
- Migración gradual posible
- No hay breaking changes

---

## 🎯 Estrategia de Coexistencia

### Modelo Híbrido

```
AGENTS.md (Universal Layer)
    ↓
    ├─→ Instrucciones core (portables)
    ├─→ Agent-First protocol
    ├─→ Routing rules
    └─→ Referencias a advanced features
        ↓
.betteragents/ (Advanced Layer)
    ↓
    ├─→ Memoria persistente
    ├─→ Dashboard interactivo
    ├─→ Hooks y automation
    ├─→ 12 agentes especializados
    ├─→ 76+ skills
    └─→ Protocolos de seguridad
        ↓
Platform-Specific (Adaptation Layer)
    ↓
    ├─→ .claude/ (Claude Code)
    ├─→ .kiro/ (Kiro)
    ├─→ .cursor/ (Cursor)
    └─→ .windsurf/ (Windsurf)
```

### Niveles de Adopción

**Nivel 1: Básico (Solo AGENTS.md)**
- Funciona en cualquier IDE
- Instrucciones core disponibles
- Agent-First protocol activo
- Sin memoria persistente
- Sin dashboard

**Nivel 2: Intermedio (AGENTS.md + .betteragents/)**
- Todo de Nivel 1
- Memoria persistente
- Skills library
- Sincronización básica

**Nivel 3: Avanzado (Full BetterAgents)**
- Todo de Nivel 2
- Dashboard interactivo
- Hooks automatizados
- Protocolos de seguridad
- Métricas y analytics

---

## 📊 Criterios de Éxito

### Funcionales
- [ ] AGENTS.md funciona en Claude Code
- [ ] AGENTS.md funciona en Kiro
- [ ] AGENTS.md funciona en Cursor (test)
- [ ] Memoria persistente sigue funcionando
- [ ] Dashboard sigue funcionando
- [ ] Sincronización bidireccional operativa

### Técnicos
- [ ] Portabilidad 100% entre plataformas
- [ ] Cero pérdida de funcionalidad
- [ ] Sincronización < 2s
- [ ] Backward compatibility completa

### Operacionales
- [ ] Migración incremental posible
- [ ] Documentación completa
- [ ] Usuarios pueden adoptar gradualmente
- [ ] Nueva plataforma en < 2 horas

---

## 🚀 Próximos Pasos Inmediatos

### Esta Sesión
1. ⏳ Crear `AGENTS.md` inicial
2. ⏳ Extraer contenido core de `CLAUDE.md`
3. ⏳ Validar formato y contenido

### Próxima Sesión
1. ⏳ Implementar `agents-md-sync.js`
2. ⏳ Actualizar `change-detector.js`
3. ⏳ Probar sincronización

### Esta Semana
1. ⏳ Completar Fase 1 y 2
2. ⏳ Documentar proceso
3. ⏳ Validar con usuario

---

## 📚 Referencias

- [AGENTS.md Specification](https://kilo.ai/docs/advanced-usage/memory-bank)
- [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules)
- [Cursor Rules Guide](https://cursor-rules-next.vercel.app/)
- `.betteragents/CORE-REFERENCE.md`
- `MULTI-PLATFORM-SUMMARY.md`

---

**Arquitecto:** AgentX (nota: debió ser despachado a architect)  
**Fecha:** 2026-03-02  
**Versión:** 4.0.0-proposal  
**Estado:** Pendiente revisión de Critic Gate
