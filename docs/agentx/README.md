# 🎯 AgentX - Orquestador Inteligente

**AgentX** es el cerebro central del ecosistema BetterAgents. No implementa soluciones directamente, sino que actúa como el **orquestador estratégico** que analiza, valida y enruta consultas a los agentes más capacitados.

## 🧠 ¿Qué es AgentX?

AgentX es un **meta-agente** que:

1. **Procesa** requisitos humanos con análisis profundo
2. **Traduce** consultas en instrucciones técnicas precisas
3. **Enruta** tareas al agente o skill más apropiado
4. **Valida** completitud antes de la ejecución
5. **Sintetiza** respuestas cuando se necesitan múltiples agentes
6. **Orquesta** workflows complejos multi-agente
7. **Gestiona** el sistema de memoria automáticamente

## 🎯 Filosofía Core

> **"Soy el router, no el ejecutor. Aseguro que el experto correcto maneje cada tarea."**

AgentX es la **primera línea de inteligencia** - analizando, validando y dirigiendo. Puede responder preguntas simples directamente, pero para tareas complejas, orquesta todo el ecosistema.

## 🔄 Metodología 4-D

AgentX utiliza una metodología estructurada de 4 fases:

### 1. 🔍 DECONSTRUCT (Análisis de Intención)

**Extrae e identifica:**
- Arquitectura técnica implícita
- Stack tecnológico
- Entidades clave y lógica de negocio
- Nivel de complejidad
- Clasificación de dominio

**Preguntas críticas:**
- ¿Qué está pidiendo REALMENTE el usuario?
- ¿A qué dominio(s) pertenece esto?
- ¿Es tarea de un solo agente o colaboración multi-agente?
- ¿Hay requisitos implícitos no declarados?

### 2. 🩺 DIAGNOSE (Control de Calidad)

**Evalúa completitud y riesgos:**
- ¿El requisito tiene información suficiente?
- ¿Hay dependencias críticas o riesgos técnicos?
- ¿Qué suposiciones se están haciendo?
- ¿Qué podría salir mal?

**Umbrales de acción:**
- **Si ambigüedad > 30%** → Solicitar clarificación
- **Si implicaciones de seguridad** → Marcar para revisión de Security
- **Si impacto arquitectónico** → Marcar para revisión de Architect
- **Si multi-dominio** → Planificar workflow multi-agente

### 3. 🛠️ DEVELOP (Ingeniería de Prompts)

**Diseña la instrucción para el agente objetivo:**
- Aplica **Chain-of-Thought (CoT)** para tareas lógicas complejas
- Incluye contexto relevante del historial
- Establece **restricciones negativas** (qué NO hacer)
- Especifica formato de salida esperado
- Incluye criterios de éxito y puntos de validación

### 4. 📤 DISPATCH (Salida Estructurada)

**Tres modos de salida:**

#### Modo A: Respuesta Directa
Para preguntas informativas simples

#### Modo B: Decisión de Enrutamiento
Para tareas complejas que requieren un agente especializado

#### Modo C: Workflow Multi-Agente
Para proyectos complejos que involucran múltiples dominios

## 🤖 Ecosistema de Agentes

AgentX puede enrutar a **12 agentes especializados**:

### Agentes Core (7)
1. **Architect** - Diseño de sistemas y arquitectura
2. **Coder** - Implementación y código limpio
3. **Critic** - Análisis crítico (Tenth Man Rule)
4. **Tester** - Testing y QA
5. **Writer** - Documentación técnica
6. **Researcher** - Investigación tecnológica
7. **Teacher** - Explicaciones educativas

### Agentes Especializados (5)
8. **DevOps** - Infraestructura y CI/CD
9. **Security** - Auditoría de seguridad
10. **UX-Designer** - Diseño UI/UX
11. **Data-Scientist** - Análisis de datos
12. **Product-Manager** - Gestión de producto

## 📋 Matriz de Decisión de Enrutamiento

### Tareas de Un Solo Agente

```
Patrón de Consulta → Agente Objetivo

"Diseña una arquitectura de microservicios" → Architect
"Implementa autenticación JWT en Node.js" → Coder
"¿Qué podría salir mal con este diseño?" → Critic
"Audita este código por vulnerabilidades" → Security
"Escribe tests unitarios para esta función" → Tester
"Diseña un formulario de login accesible" → UX-Designer
"Documenta esta API REST" → Writer
"Explica cómo funcionan las promesas en JS" → Teacher
"Escribe user stories para autenticación" → Product-Manager
"Configura pipeline CI/CD con GitHub Actions" → DevOps
"Analiza este dataset para insights" → Data-Scientist
"Compara React vs Vue para nuestro caso" → Researcher
```

### Workflows Multi-Agente

**Patrón 1: Diseño → Implementar → Testear → Documentar**
```
1. Architect: Diseña arquitectura del sistema
2. Coder: Implementa el diseño
3. Tester: Escribe tests comprehensivos
4. Writer: Documenta la implementación
```

**Patrón 2: Diseño → Crítica → Refinar → Implementar**
```
1. Architect: Propone diseño inicial
2. Critic: Desafía suposiciones e identifica riesgos
3. Architect: Refina diseño basado en feedback
4. Coder: Implementa diseño refinado
```

**Patrón 3: Investigar → Diseñar → Implementar → Desplegar**
```
1. Researcher: Evalúa opciones tecnológicas
2. Architect: Diseña arquitectura con tech elegida
3. Coder: Implementa solución
4. DevOps: Configura pipeline de deployment
```

## 💾 Gestión de Memoria

AgentX es el **único administrador** del sistema de memoria. Detecta automáticamente contenido digno de documentar:

### Triggers de Detección

**1. Decisiones Técnicas (→ decision-log.md)**
- Elección de arquitectura
- Selección de stack tecnológico
- Selección de patrón de diseño
- Análisis de trade-offs

**2. Progreso de Tareas (→ progress.md)**
- Tarea completada
- Nueva tarea iniciada
- Milestone alcanzado
- Implementación finalizada

**3. Patrones y Aprendizajes (→ patterns.md)**
- Solución reutilizable identificada
- Problema resuelto elegantemente
- Anti-patrón descubierto
- Best practice aprendida

**4. Cambios de Contexto (→ active-context.md)**
- Cambio de fase del proyecto
- Nueva feature iniciada
- Cambio de objetivo
- Cambio de tecnología

### Protocolo de Decisión de Memoria

Para CADA interacción, AgentX se pregunta:

```
1. ¿Hay una decisión técnica? → decision-log.md
2. ¿Se completó o inició una tarea? → progress.md
3. ¿Se identificó un patrón útil? → patterns.md
4. ¿Cambió el contexto del proyecto? → active-context.md
```

**Si SÍ a cualquiera:** Actualiza memoria AUTOMÁTICAMENTE
**Si INCIERTO:** Pregunta al usuario

## 🎯 Cómo Usar AgentX

### Invocación por Defecto

Todas las consultas sin prefijo `@agent` van a AgentX primero:

```
Usuario: "Necesito diseñar un sistema de autenticación"
→ AgentX analiza y enruta a Architect
```

### Invocación Explícita

```
@agentx ¿Qué agente debería usar para implementar JWT?
```

### Override Directo

Puedes saltarte AgentX y ir directo a un agente:

```
@architect Diseña un sistema de autenticación
```

## 📊 Formatos de Salida

### Respuesta Directa (Preguntas Simples)

```markdown
---
🎯 AgentX/Dispatcher
---

[Respuesta clara y directa]

💡 **¿Necesitas más ayuda?**
- Para [tarea específica] → Puedo enrutarte a [Nombre Agente]
```

### Decisión de Enrutamiento (Agente Único)

```markdown
---
🎯 AgentX
🔀 Enrutando a: [Nombre Agente]
---

## 📋 Análisis
[Clasificación y evaluación]

## 🎯 Decisión de Enrutamiento
[Por qué este agente]

## 📝 Prompt Refinado para [Agente]
[Instrucciones precisas y detalladas]

## 📊 Metadata
```json
{
  "request_id": "[UUID]",
  "status": "READY",
  "routing": {...}
}
```
```

### Solicitud Incompleta (Necesita Clarificación)

```markdown
---
🎯 AgentX
⚠️ Status: INCOMPLETE
---

## ❓ Preguntas de Clarificación
[Preguntas específicas necesarias]

## 💡 Lo Que Entendí Hasta Ahora
[Resumen de lo claro]
```

### Workflow Multi-Agente

```markdown
---
🎯 AgentX
🔀 Workflow Multi-Agente Requerido
---

## 🔄 Workflow Propuesto

### Fase 1: [Nombre Fase]
**Agente:** [Nombre]
**Tarea:** [Tarea específica]
**Entregable:** [Salida esperada]

### Fase 2: [Nombre Fase]
[...]
```

## 🔧 Configuración

AgentX se configura en `config/.betteragents-config`:

```bash
# Habilitar AgentX como orquestador por defecto
AGENTX_ENABLED=true

# Temperatura para decisiones de enrutamiento (0.0-1.0)
AGENTX_TEMPERATURE=0.3

# Umbral de ambigüedad para solicitar clarificación (0-100)
AGENTX_AMBIGUITY_THRESHOLD=30

# Habilitar workflows multi-agente
AGENTX_MULTI_AGENT_WORKFLOWS=true

# Guardar logs de enrutamiento
AGENTX_LOG_ROUTING=true
```

## 💡 Mejores Prácticas

### Para Usuarios

1. **Sé específico** - Más contexto = mejor enrutamiento
2. **Confía en AgentX** - Deja que analice y enrute
3. **Proporciona feedback** - Ayuda a mejorar decisiones
4. **Usa override cuando sepas** - `@specific-agent` si estás seguro

### Para Desarrolladores

1. **Mantén agentes especializados** - Un dominio, un agente
2. **Documenta capacidades** - AgentX necesita saber qué puede cada agente
3. **Actualiza keywords** - Ayuda a AgentX a identificar dominios
4. **Contribuye a memoria** - Sugiere contenido digno de documentar

## 🚀 Ventajas de AgentX

✅ **Enrutamiento Inteligente** - Siempre el agente correcto
✅ **Validación Previa** - Detecta información faltante
✅ **Prompts Refinados** - Instrucciones precisas y accionables
✅ **Workflows Complejos** - Orquesta múltiples agentes
✅ **Memoria Automática** - Documenta decisiones y progreso
✅ **Aprendizaje Continuo** - Mejora con cada interacción

## 📚 Recursos Relacionados

- [Guía de Inicio Rápido](../guides/getting-started.md)
- [Sistema de Memoria](../memory/README.md)
- [Directorio de Agentes](../agents/README.md)
- [Workflows](../guides/workflows.md)
- [Ejemplos](../../examples/)

---

**AgentX: El cerebro que conecta todo el ecosistema BetterAgents 🧠**
