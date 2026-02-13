# 🤝 Guía de Contribución - BetterAgentX

¡Gracias por tu interés en contribuir a BetterAgentX! Este documento te guiará en el proceso.

---

## 📋 Tabla de Contenidos

1. [Código de Conducta](#código-de-conducta)
2. [Cómo Contribuir](#cómo-contribuir)
3. [Reportar Bugs](#reportar-bugs)
4. [Sugerir Mejoras](#sugerir-mejoras)
5. [Pull Requests](#pull-requests)
6. [Guía de Estilo](#guía-de-estilo)
7. [Estructura del Proyecto](#estructura-del-proyecto)

---

## 📜 Código de Conducta

Este proyecto sigue un código de conducta simple:

- Sé respetuoso y profesional
- Acepta críticas constructivas
- Enfócate en lo mejor para el proyecto
- Ayuda a otros contribuidores

---

## 🚀 Cómo Contribuir

### 1. Fork el Repositorio

```bash
# Haz fork desde GitHub
# Luego clona tu fork
git clone https://github.com/jemavidev/BetterAgentX.git
cd BetterAgentX
```

### 2. Crea una Rama

```bash
# Crea una rama descriptiva
git checkout -b feature/nueva-funcionalidad
# o
git checkout -b fix/correccion-bug
# o
git checkout -b docs/mejora-documentacion
```

### 3. Haz tus Cambios

- Sigue la [Guía de Estilo](#guía-de-estilo)
- Prueba tus cambios
- Documenta lo que hiciste

### 4. Commit

```bash
# Añade tus cambios
git add .

# Commit con mensaje descriptivo
git commit -m "feat: añade nueva funcionalidad X"
# o
git commit -m "fix: corrige bug en agente Y"
# o
git commit -m "docs: actualiza README con Z"
```

### 5. Push y Pull Request

```bash
# Push a tu fork
git push origin feature/nueva-funcionalidad

# Luego abre un Pull Request en GitHub
```

---

## 🐛 Reportar Bugs

### Antes de Reportar

1. Verifica que no sea un problema de configuración
2. Busca en los issues existentes
3. Prueba con la última versión

### Cómo Reportar

Abre un issue con:

**Título:** Descripción breve del bug

**Descripción:**
```markdown
## Descripción del Bug
[Descripción clara del problema]

## Pasos para Reproducir
1. Paso 1
2. Paso 2
3. Paso 3

## Comportamiento Esperado
[Qué debería pasar]

## Comportamiento Actual
[Qué pasa realmente]

## Entorno
- OS: Ubuntu 22.04
- Kiro Code: v1.2.3
- Node.js: v20.0.0
- BetterAgents: v3.0.0

## Logs/Screenshots
[Si aplica]
```

---

## 💡 Sugerir Mejoras

### Ideas Bienvenidas

- Nuevos agentes especializados
- Mejoras a agentes existentes
- Nuevas funcionalidades
- Mejoras de documentación
- Optimizaciones de rendimiento

### Formato de Sugerencia

```markdown
## Título de la Sugerencia

### Problema que Resuelve
[Qué problema o necesidad aborda]

### Solución Propuesta
[Cómo funcionaría]

### Alternativas Consideradas
[Otras opciones que pensaste]

### Beneficios
- Beneficio 1
- Beneficio 2

### Posibles Desventajas
- Desventaja 1
- Desventaja 2
```

---

## 🔀 Pull Requests

### Checklist antes de PR

- [ ] El código funciona correctamente
- [ ] Seguiste la guía de estilo
- [ ] Actualizaste la documentación si es necesario
- [ ] Añadiste/actualizaste tests si aplica
- [ ] El commit message es descriptivo
- [ ] No hay conflictos con main

### Proceso de Review

1. Un mantenedor revisará tu PR
2. Puede haber comentarios o solicitudes de cambios
3. Haz los cambios solicitados
4. Una vez aprobado, se hará merge

### Tipos de Contribuciones

#### Nuevos Agentes

Si quieres añadir un nuevo agente:

1. Crea el archivo en `.kiro/steering/agents/nuevo-agente.md`
2. Sigue la estructura de agentes existentes
3. Incluye:
   - Identity section
   - Role description
   - Expertise areas
   - Guidelines
   - Output formats
   - Skills recomendados
4. Actualiza `betteragents.json`
5. Actualiza `README.md`

#### Mejoras a Agentes Existentes

1. Identifica qué agente mejorar
2. Haz cambios incrementales
3. Documenta por qué la mejora es necesaria
4. Prueba que el agente sigue funcionando

#### Documentación

1. Identifica qué documentar
2. Usa Markdown claro y conciso
3. Incluye ejemplos cuando sea posible
4. Verifica ortografía y gramática

#### Bugs

1. Identifica la causa raíz
2. Implementa la solución más simple
3. Explica por qué tu solución funciona
4. Añade tests si es posible

---

## 📝 Guía de Estilo

### Archivos Markdown

```markdown
# Título Principal (H1)

## Sección (H2)

### Subsección (H3)

- Usa listas para items múltiples
- Mantén líneas cortas (80-100 caracteres)
- Usa bloques de código con lenguaje especificado

\`\`\`bash
# Ejemplo de código
echo "Hola"
\`\`\`

**Negrita** para énfasis importante
*Cursiva* para énfasis suave
`código inline` para comandos o código
```

### Estructura de Agentes

```markdown
# 🎯 Agent: Nombre del Agente

## Identity
[Formato de identificación]

## Role
[Descripción del rol]

## Expertise
[Áreas de expertise]

## Core Principles
[Principios fundamentales]

## Guidelines
[Guías de comportamiento]

## Output Format
[Formatos de respuesta]

## Available Skills
[Skills recomendados]

## Remember
[Puntos clave]
```

### Commits

Usa [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: añade nueva funcionalidad
fix: corrige un bug
docs: cambios en documentación
style: formato, punto y coma, etc
refactor: refactorización de código
test: añade tests
chore: tareas de mantenimiento
```

Ejemplos:
```bash
git commit -m "feat: añade agente de ML Engineer"
git commit -m "fix: corrige formato de respuesta en Architect"
git commit -m "docs: actualiza guía de instalación"
git commit -m "refactor: simplifica sistema de memoria"
```

---

## 🏗️ Estructura del Proyecto

```
BetterAgentX/
├── .agents/
│   └── skills/              # Skills compartidos
│       └── ui-ux-pro-max/
├── .kiro/
│   └── steering/
│       ├── agents/          # 12 agentes especializados
│       │   ├── architect.md
│       │   ├── coder.md
│       │   ├── critic.md
│       │   ├── data-scientist.md
│       │   ├── devops.md
│       │   ├── product-manager.md
│       │   ├── researcher.md
│       │   ├── security.md
│       │   ├── teacher.md
│       │   ├── tester.md
│       │   ├── ux-designer.md
│       │   └── writer.md
│       ├── agentx/          # Orquestador central
│       │   ├── agentx.md
│       │   └── agents-map.json
│       └── _common/         # Configuración común
│           ├── collaboration-rules.md
│           ├── identity-template.md
│           └── memory-contribution.md
├── config/
│   ├── betteragents.json    # Configuración principal
│   └── agent-skills.json    # Skills recomendados
├── docs/                    # Documentación completa
├── scripts/
│   ├── init-betteragentx.sh      # Inicializar integración
│   ├── verify-betteragentx.sh    # Verificar integración
│   ├── install.sh                # Instalación del sistema
│   └── verify-system.sh          # Verificación del sistema
├── templates/
│   └── memory/              # Plantillas de memoria
├── .gitignore
├── CHANGELOG.md             # Historial de cambios
├── CONTRIBUTING.md          # Esta guía
├── INDEX.md                 # Índice de documentación
├── INTEGRATION.md           # Guía de integración
├── QUICKSTART-INTEGRATION.md # Inicio rápido
├── LICENSE                  # Licencia MIT
└── README.md                # Documentación principal
```

### Archivos Importantes

- **config/betteragents.json**: Configuración principal del sistema
- **config/agent-skills.json**: Skills recomendados por agente
- **README.md**: Documentación principal
- **INTEGRATION.md**: Guía completa de integración
- **QUICKSTART-INTEGRATION.md**: Inicio rápido de integración
- **INDEX.md**: Índice de toda la documentación
- **CHANGELOG.md**: Historial de versiones y cambios
- **.kiro/steering/agents/**: Los 12 agentes especializados
- **.kiro/steering/agentx/**: El orquestador central
- **.kiro/steering/_common/**: Configuración común de agentes
- **scripts/**: Scripts de instalación e integración
- **templates/memory/**: Plantillas del sistema de memoria

---

## 🧪 Testing

### Probar Agentes

```bash
# Abrir Kiro
kiro .

# Probar cada agente
@architect Hola, ¿funcionas correctamente?
@coder Hola, ¿funcionas correctamente?
# ... etc
```

### Verificar Estructura

```bash
# Ejecutar script de verificación
./verify.sh

# O manualmente
ls -1 .kiro/steering/agents/*.md | wc -l  # Debe ser 12
ls -1 .kiro/memory/*.md | wc -l           # Debe ser 5
```

---

## 📚 Recursos

- [Documentación de Kiro](https://kiro.ai/docs)
- [Skills.sh](https://skills.sh)
- [Markdown Guide](https://www.markdownguide.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## ❓ Preguntas

Si tienes preguntas:

1. Revisa la documentación existente
2. Busca en issues cerrados
3. Abre un issue con tu pregunta
4. Únete a las discusiones en GitHub

---

## 🎉 Reconocimientos

Todos los contribuidores serán reconocidos en el README.md

---

## 📄 Licencia

Al contribuir, aceptas que tus contribuciones se licencien bajo la licencia MIT del proyecto.

---

**¡Gracias por contribuir a BetterAgentX! 🚀**
