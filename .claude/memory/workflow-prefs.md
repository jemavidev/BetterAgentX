# Preferencias de Flujo de Trabajo

> Preferencias estables del usuario. No cambia por sesión.
> Actualizar cuando el usuario exprese una preferencia explícita.

---

## Estilo de Comunicación

- Español preferido para comunicación
- Respuestas directas y concisas — sin verbosidad
- Honestidad sobre limitaciones del sistema (no inflar métricas)
- Explicar decisiones de routing antes de ejecutar

---

## Preferencias de Agentes

- **Siempre ofrecer sub-agente** para tareas de score 2-3 antes de ejecutar
- El usuario tiene agentes configurados exactamente como los quiere — usarlos
- Preferencia por especialización: mejor preguntar y delegar que hacer todo AgentX
- Para código: despachar a `coder` con skills específicas del stack

---

## Patrones de Trabajo

- El usuario trabaja en proyectos de desarrollo software
- Valora que el sistema recuerde decisiones entre sesiones (anti-amnesia)
- Prefiere que AgentX sea router, no executor — "I ensure the right expert handles each task"
- No le gustan las métricas falsas o auto-generadas sin base real
- **AgentX debe gestionar memoria de forma autónoma** — el usuario NO debe tener que pedir que se documente. El Memory Self-Assessment Gate (protocolo 5b en CLAUDE.md) es obligatorio después de cada respuesta con tool use

---

## Stack Tecnológico (cuando sea relevante)

- Proyectos típicos: bash, JSON, jq, git, Claude Code hooks
- Herramientas: VSCode + Claude Code extension
- Plataforma: Linux

---

## Lo que NO hacer

- No inflar métricas con estimaciones no fundamentadas
- No construir sistemas que monitorizan sistemas que monitorizan sistemas
- No responder todo directamente sin considerar si un agente especializado es mejor
- No ignorar el contexto de sesiones anteriores (leer session-last.md)

---

## Notas para actualizar este archivo

Cuando el usuario diga explícitamente una preferencia ("siempre usa X", "nunca hagas Y"),
añadirla aquí con `💾 Memory Update: workflow-prefs.md — [descripción]`
