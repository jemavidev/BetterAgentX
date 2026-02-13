# 🔧 Guía de Integración - BetterAgentX

**Integra BetterAgentX en cualquier proyecto mediante enlaces simbólicos**

---

## 📋 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Conceptos Clave](#conceptos-clave)
3. [Métodos de Integración](#métodos-de-integración)
4. [Estructura del Proyecto](#estructura-del-proyecto)
5. [Configuración](#configuración)
6. [Sistema de Memoria](#sistema-de-memoria)
7. [Actualización](#actualización)
8. [Solución de Problemas](#solución-de-problemas)
9. [Casos de Uso](#casos-de-uso)

---

## 🎯 Introducción

BetterAgentX puede integrarse en cualquier proyecto existente o nuevo mediante un sistema de **enlaces simbólicos** que:

✅ No duplica archivos  
✅ Mantiene BetterAgentX actualizable  
✅ Permite personalización por proyecto  
✅ Separa configuración de código  

---

## 🔑 Conceptos Clave

### Enlaces Simbólicos (Symlinks)

En lugar de copiar archivos:
```bash
# ❌ Copia (duplicación)
cp -r BetterAgentX/.kiro/steering/agents .kiro/steering/
```

Usamos enlaces simbólicos:
```bash
# ✅ Symlink (sin duplicación)
ln -s BetterAgentX/.kiro/steering/agents .kiro/steering/agents
```

**Ventajas:**
- Sin duplicación de archivos
- Actualizar BetterAgentX actualiza todo
- Mantiene BetterAgentX como subproyecto
- Fácil de mantener

### Qué se Enlaza vs Qué se Copia

**Se ENLAZA (symlink):**
- Agentes (`.kiro/steering/agents/`)
- AgentX (`.kiro/steering/agentx/`)
- Common (`.kiro/steering/_common/`)
- Skills (`.agents/skills/`)

**Se COPIA (personalización):**
- Configuraciones (`.kiro/settings/*.json`)
- Memoria (`.kiro/memory/*.md`) - se crea nueva

---

## 🚀 Métodos de Integración

### Método 1: Script Automático (Recomendado)

```bash
# 1. Clona BetterAgentX en tu proyecto
git clone https://github.com/jemavidev/BetterAgentX.git

# 2. Ejecuta el script de inicialización
./BetterAgentX/scripts/init-betteragentx.sh

# 3. Verifica
./BetterAgentX/scripts/verify-betteragentx.sh
```

### Método 2: Como Submódulo de Git

```bash
# 1. Añade como submódulo
git submodule add https://github.com/jemavidev/BetterAgentX.git

# 2. Inicializa submódulo
git submodule update --init --recursive

# 3. Ejecuta script de inicialización
./BetterAgentX/scripts/init-betteragentx.sh
```

### Método 3: Manual

```bash
# 1. Crear estructura
mkdir -p .kiro/steering
mkdir -p .kiro/memory
mkdir -p .kiro/settings
mkdir -p .agents

# 2. Crear enlaces simbólicos
ln -s "$(pwd)/BetterAgentX/.kiro/steering/agents" .kiro/steering/agents
ln -s "$(pwd)/BetterAgentX/.kiro/steering/agentx" .kiro/steering/agentx
ln -s "$(pwd)/BetterAgentX/.kiro/steering/_common" .kiro/steering/_common
ln -s "$(pwd)/BetterAgentX/.agents/skills" .agents/skills

# 3. Copiar configuraciones
cp BetterAgentX/config/betteragents.json .kiro/settings/
cp BetterAgentX/config/agent-skills.json .kiro/settings/

# 4. Crear archivos de memoria
touch .kiro/memory/active-context.md
touch .kiro/memory/decision-log.md
touch .kiro/memory/progress.md
touch .kiro/memory/patterns.md
```

---

## 📦 Estructura del Proyecto

### Estructura Completa

```
tu-proyecto/
├── BetterAgentX/                    # Subproyecto (fuente)
│   ├── .kiro/
│   │   └── steering/
│   │       ├── agents/              # 12 agentes especializados
│   │       │   ├── architect.md
│   │       │   ├── coder.md
│   │       │   ├── critic.md
│   │       │   ├── tester.md
│   │       │   ├── writer.md
│   │       │   ├── researcher.md
│   │       │   ├── teacher.md
│   │       │   ├── devops.md
│   │       │   ├── security.md
│   │       │   ├── ux-designer.md
│   │       │   ├── data-scientist.md
│   │       │   └── product-manager.md
│   │       ├── agentx/              # Orquestador
│   │       │   ├── core.md
│   │       │   └── agents-map.json
│   │       └── _common/             # Configuración común
│   │           ├── collaboration-rules.md
│   │           ├── identity-template.md
│   │           └── memory-contribution.md
│   ├── .agents/
│   │   └── skills/                  # Skills disponibles
│   ├── config/
│   │   ├── betteragents.json
│   │   └── agent-skills.json
│   ├── scripts/
│   │   ├── init-betteragentx.sh
│   │   └── verify-betteragentx.sh
│   └── README.md
│
├── .kiro/                           # Config Kiro (tu proyecto)
│   ├── steering/
│   │   ├── agents/      → symlink   # Enlace a BetterAgentX/...
│   │   ├── agentx/      → symlink   # Enlace a BetterAgentX/...
│   │   └── _common/     → symlink   # Enlace a BetterAgentX/...
│   ├── memory/                      # Memoria (local, NO se sube a Git)
│   │   ├── active-context.md        # Contexto actual del proyecto
│   │   ├── decision-log.md          # Decisiones técnicas (ADR)
│   │   ├── progress.md              # Progreso y tareas
│   │   └── patterns.md              # Patrones y soluciones
│   └── settings/                    # Config (local, personalizable)
│       ├── betteragents.json        # Configuración de agentes
│       └── agent-skills.json        # Skills recomendados
│
├── .agents/
│   └── skills/          → symlink   # Enlace a BetterAgentX/...
│
├── .betteragentx                    # Archivo de configuración
├── .gitignore                       # Ignora archivos locales
└── tu-codigo/                       # Tu proyecto
```

### Archivos Locales vs Compartidos

**Archivos LOCALES (no se suben a Git):**
- `.kiro/memory/` - Memoria específica del proyecto
- `.kiro/settings/` - Configuración personalizada
- `.betteragentx` - Config de integración

**Archivos COMPARTIDOS (via symlinks):**
- `.kiro/steering/agents/` - Agentes
- `.kiro/steering/agentx/` - AgentX
- `.kiro/steering/_common/` - Config común
- `.agents/skills/` - Skills

---

## ⚙️ Configuración

### Archivo .betteragentx

Creado automáticamente por `init-betteragentx.sh`:

```bash
# BetterAgentX - Configuración del Proyecto
PROJECT_NAME="mi-proyecto"
BETTERAGENTX_PATH="BetterAgentX"
BETTERAGENTX_VERSION="3.1.0"
INITIALIZED_DATE="2026-02-12"

# Rutas
KIRO_DIR=".kiro"
MEMORY_DIR=".kiro/memory"
SETTINGS_DIR=".kiro/settings"
AGENTS_DIR=".agents"

# Estado
INITIALIZED=true
```

### Configuración de Agentes

Edita `.kiro/settings/betteragents.json`:

```json
{
  "name": "mi-proyecto",
  "version": "1.0.0",
  "agents": {
    "agentx": {
      "enabled": true,
      "isDefault": true
    },
    "architect": {
      "enabled": true
    }
  }
}
```

### .gitignore

El script añade automáticamente:

```gitignore
# BetterAgentX - Archivos locales
.kiro/memory/
.kiro/settings/
.betteragentx
```

---

## 💾 Sistema de Memoria

### Archivos de Memoria

Cada proyecto tiene su propia memoria en `.kiro/memory/`:

#### active-context.md
Contexto actual del proyecto:
- Objetivo principal
- Stack tecnológico
- Estado actual
- Equipo

#### decision-log.md
Registro de decisiones técnicas (ADR):
- Decisiones arquitectónicas
- Elección de tecnologías
- Trade-offs considerados

#### progress.md
Seguimiento de progreso:
- Tareas pendientes
- Tareas completadas
- Métricas de progreso

#### patterns.md
Patrones y soluciones reutilizables:
- Soluciones a problemas comunes
- Patrones de diseño usados
- Mejores prácticas del proyecto

### Personalizar Memoria

```bash
# Editar contexto
nano .kiro/memory/active-context.md

# Ver progreso
cat .kiro/memory/progress.md

# Añadir decisión
nano .kiro/memory/decision-log.md

# Documentar patrón
nano .kiro/memory/patterns.md
```

---

## 🔄 Actualización

### Actualizar BetterAgentX

```bash
# Método 1: Git pull
cd BetterAgentX
git pull
cd ..

# Método 2: Si es submódulo
git submodule update --remote BetterAgentX
```

Los cambios se reflejan automáticamente gracias a los symlinks.

### Verificar Actualización

```bash
./BetterAgentX/scripts/verify-betteragentx.sh
```

---

## 🔧 Solución de Problemas

### Problema: "BetterAgentX no encontrado"

**Solución:**
```bash
git clone https://github.com/jemavidev/BetterAgentX.git
./BetterAgentX/scripts/init-betteragentx.sh
```

### Problema: "Enlaces simbólicos rotos"

**Causa:** BetterAgentX movido o eliminado

**Solución:**
```bash
# Reinicializar
./BetterAgentX/scripts/init-betteragentx.sh
```

### Problema: "Agentes no responden en Kiro"

**Diagnóstico:**
```bash
./BetterAgentX/scripts/verify-betteragentx.sh
```

**Soluciones comunes:**
1. Verificar que Kiro Code está instalado
2. Verificar que los symlinks existen
3. Reiniciar Kiro Code

### Problema: "Cambios en BetterAgentX no se reflejan"

**Causa:** Archivos copiados en lugar de symlinks

**Solución:**
```bash
# Eliminar copias
rm -rf .kiro/steering/agents
rm -rf .kiro/steering/agentx

# Reinicializar con symlinks
./BetterAgentX/scripts/init-betteragentx.sh
```

### Problema: "Conflictos con .gitignore"

**Solución:**
```bash
# Añadir manualmente a .gitignore
echo "" >> .gitignore
echo "# BetterAgentX - Archivos locales" >> .gitignore
echo ".kiro/memory/" >> .gitignore
echo ".kiro/settings/" >> .gitignore
echo ".betteragentx" >> .gitignore
```

---

## 🎯 Casos de Uso

### Caso 1: Proyecto Nuevo

```bash
mkdir mi-app
cd mi-app
git init
git clone https://github.com/jemavidev/BetterAgentX.git
./BetterAgentX/scripts/init-betteragentx.sh
kiro .
```

### Caso 2: Proyecto Existente

```bash
cd proyecto-existente
git clone https://github.com/jemavidev/BetterAgentX.git
./BetterAgentX/scripts/init-betteragentx.sh
# Editar .kiro/memory/active-context.md con info del proyecto
kiro .
```

### Caso 3: Múltiples Proyectos Compartiendo BetterAgentX

```bash
# Estructura:
# ~/proyectos/
#   ├── BetterAgentX/          # Compartido
#   ├── proyecto-1/
#   ├── proyecto-2/
#   └── proyecto-3/

# En cada proyecto:
cd ~/proyectos/proyecto-1
ln -s ../BetterAgentX BetterAgentX
./BetterAgentX/scripts/init-betteragentx.sh
```

### Caso 4: Monorepo

```bash
# Estructura:
# monorepo/
#   ├── BetterAgentX/
#   ├── packages/
#   │   ├── frontend/
#   │   ├── backend/
#   │   └── shared/
#   └── .kiro/

# Inicializar en raíz del monorepo
./BetterAgentX/scripts/init-betteragentx.sh
```

---

## 📚 Recursos Adicionales

- **Inicio Rápido:** [QUICKSTART-INTEGRATION.md](QUICKSTART-INTEGRATION.md)
- **README Principal:** [README.md](README.md)
- **Documentación de Agentes:** [docs/agents/README.md](docs/agents/README.md)
- **Guía de Instalación:** [docs/installation/linux.md](docs/installation/linux.md)

---

## 🆘 Soporte

Si tienes problemas:

1. Ejecuta el script de verificación:
   ```bash
   ./BetterAgentX/scripts/verify-betteragentx.sh
   ```

2. Revisa los logs de Kiro Code

3. Abre un issue en GitHub:
   https://github.com/jemavidev/BetterAgentX/issues

---

**¡BetterAgentX está listo para integrarse en tu proyecto!** 🚀
