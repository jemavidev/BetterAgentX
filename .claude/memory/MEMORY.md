# 🧠 BetterAgents — Memory Index

> Indice compacto. Leer tambien `session-last.md` al inicio de sesion.
> Detalles en archivos de tema. Mantener <=120 lineas activas.

---

## ESTADO ACTUAL

**Proyecto:** BetterAgentX Multi-Agent Orchestration System
**Version:** 3.8.0 — Multi-platform installer (Claude Code + Kiro IDE)
**Ultima actualizacion:** 2026-03-07

**Fase actual:** 3.8 — Installer multi-plataforma completo
**Tareas:** 18 completadas | **Sesiones:** 92 | **Tokens estimados:** ~2.95M total

---

## LO QUE FUNCIONA (confirmado con codigo real)

- Hooks reales: `on-user-prompt.sh`, `on-file-write-verification.sh`, `on-session-stop.sh`
- Post-change verification: ejecuta compiladores/linters en cada Write/Edit
- Memory debt cross-session: sesion sin logs -> inyeccion en siguiente sesion
- 78 skills en `.claude/commands/` | 12 agentes en `.claude/agents/`
- Token tracking: char-count/4 + overhead (input) | git-diff-lines*20 (output)
- Dashboard: `.claude/memory/dashboard.html` -> `bash .claude/scripts/start-dashboard.sh`
- Installer multi-plataforma: `installer/install.sh --platform=claude|kiro|both`

---

## ARCHIVOS CLAVE

| Archivo | Proposito | Datos reales |
|---------|-----------|-------------|
| `session-last.md` | **LEER AL INICIO** | ultima sesion |
| `workflow-prefs.md` | Preferencias estables | - |
| `active-context.json` | Estado actual + cambios | fase 3.8.0 |
| `decision-log.json` | Decisiones arquitectonicas | 10 entradas |
| `progress.json` | Tareas | 18 completadas |
| `patterns.json` | Patrones reutilizables | 3 entradas |
| `llm-usage.json` | Sesiones + tokens | 92 sesiones, avg 32k/sesion |
| `alerts-registry.json` | Alertas activas + reglas | - |

---

## SAFETY GATES

| Gate | Implementacion | Tipo |
|------|----------------|------|
| Post-change verification | `on-file-write-verification.sh` (PostToolUse hook) | REAL |
| Plan mode tracking | `on-plan-mode.sh` (PreToolUse hook) | REAL |
| Session pipeline | `on-session-stop.sh` (Stop hook, 8 pasos) | REAL |
| Memory debt | `on-session-stop.sh` + `on-user-prompt.sh` | REAL |
| Anti-loop | CLAUDE.md instruccion + `on-loop-detected.sh` | BEHAVIORAL |
| Triviality filter | CLAUDE.md instruccion + triviality-detector skill | BEHAVIORAL |

---

## REGLAS CRITICAS

1. **Session start:** leer este archivo + `session-last.md`
2. **Dispatch agent-first:** score 2-3 -> despachar sub-agente automaticamente
3. **Sub-agentes aislados:** inyectar `[CONTEXT]` + `LastSession` en cada Task()
4. **Memory writes:** solo AgentX, usar scripts: `add-task.sh`, `add-decision.sh`, etc.
5. **MEMORY.md:** mantener <=120 lineas — detalles en archivos de tema

---

## COMANDOS DE ESCRITURA

```bash
# Tarea completada
bash .claude/scripts/add-task.sh TASK-NN "titulo" completed agentx "outcome" medium "tag1,tag2" 30

# Decision arquitectonica
bash .claude/scripts/add-decision.sh DEC-NN "titulo" "contexto/problema" architect implemented "tag1,tag2"

# Cambio de contexto/fase
bash .claude/scripts/update-context.sh --phase "3.9 — descripcion" --focus "feature" --next-step "paso"
```
Siempre mostrar: `💾 Memory Update: [archivo] — [descripcion]`

---

## DECISIONES RECIENTES

| ID | Titulo |
|----|--------|
| DEC-07 | Runtime Mode Isolation — development vs installed |
| DEC-08 | Multi-platform modular installer via lib/ + platforms/ |
| DEC-10 | Single central Docker container (no per-project) |

---

## TOKEN ACCOUNTING (estimado, no billing-real)

```
Sessions: 92  |  Input: ~231k  |  Output: ~2.7M  |  Total: ~2.95M
Avg/sesion: ~32k tokens
Input: char-count/4 + 2386 overhead (via on-user-prompt.sh)
Output: git-diff-lines * 20 (via track-usage.sh)
Fuente: .claude/memory/llm-usage.json
```

---

## PROXIMOS PASOS

- [ ] Test Kiro platform end-to-end en proyecto real
- [ ] Phase 3.3: 7-day rolling metrics (update-trend-predictions.sh existe, validar)
- [ ] Enriquecer DEC-07/DEC-08 campos .decision en decision-log.json
