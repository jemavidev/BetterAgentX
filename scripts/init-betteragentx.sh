#!/bin/bash

# BetterAgentX - Script de Inicialización para Proyectos
# Integra BetterAgentX en cualquier proyecto mediante enlaces simbólicos

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

echo "🚀 BetterAgentX - Inicialización de Proyecto"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. DETECTAR UBICACIÓN DE BETTERAGENTX
# ============================================
print_section "1. Detectando BetterAgentX"
echo ""

# Buscar BetterAgentX en ubicaciones comunes
BETTERAGENTX_PATH=""

if [ -d "BetterAgentX" ]; then
    BETTERAGENTX_PATH="BetterAgentX"
    print_success "BetterAgentX encontrado en: ./BetterAgentX"
elif [ -d "../BetterAgentX" ]; then
    BETTERAGENTX_PATH="../BetterAgentX"
    print_success "BetterAgentX encontrado en: ../BetterAgentX"
elif [ -d "betteragentx" ]; then
    BETTERAGENTX_PATH="betteragentx"
    print_success "BetterAgentX encontrado en: ./betteragentx"
else
    print_error "BetterAgentX no encontrado"
    echo ""
    echo "Por favor, clona BetterAgentX primero:"
    echo "  git clone https://github.com/jemavidev/BetterAgentX.git"
    echo ""
    exit 1
fi

# Convertir a ruta absoluta
BETTERAGENTX_ABS=$(cd "$BETTERAGENTX_PATH" && pwd)
print_info "Ruta absoluta: $BETTERAGENTX_ABS"

# Verificar que tiene la estructura correcta
if [ ! -d "$BETTERAGENTX_PATH/.kiro/steering/agents" ]; then
    print_error "Estructura de BetterAgentX inválida"
    print_error "Falta: .kiro/steering/agents/"
    exit 1
fi

print_success "Estructura de BetterAgentX verificada"
echo ""

# ============================================
# 2. CREAR ESTRUCTURA DEL PROYECTO
# ============================================
print_section "2. Creando Estructura del Proyecto"
echo ""

# Crear directorios necesarios
mkdir -p .kiro/steering
mkdir -p .kiro/memory
mkdir -p .kiro/settings
mkdir -p .agents

print_success "Estructura .kiro/ creada"
print_success "Estructura .agents/ creada"
echo ""

# ============================================
# 3. CREAR ENLACES SIMBÓLICOS
# ============================================
print_section "3. Creando Enlaces Simbólicos"
echo ""

# Función para crear symlink seguro
create_symlink() {
    local source=$1
    local target=$2
    local name=$3
    
    if [ -L "$target" ]; then
        print_warning "$name ya existe (symlink), eliminando..."
        rm "$target"
    elif [ -d "$target" ]; then
        print_warning "$name ya existe (directorio), respaldando..."
        mv "$target" "${target}.backup.$(date +%s)"
    fi
    
    ln -s "$source" "$target"
    print_success "$name → enlazado"
}

# Crear enlaces simbólicos
create_symlink "$BETTERAGENTX_ABS/.kiro/steering/agents" ".kiro/steering/agents" "Agentes"
create_symlink "$BETTERAGENTX_ABS/.kiro/steering/agentx" ".kiro/steering/agentx" "AgentX"
create_symlink "$BETTERAGENTX_ABS/.kiro/steering/_common" ".kiro/steering/_common" "Common"
create_symlink "$BETTERAGENTX_ABS/.agents/skills" ".agents/skills" "Skills"

echo ""

# ============================================
# 4. COPIAR CONFIGURACIONES
# ============================================
print_section "4. Copiando Configuraciones"
echo ""

# Copiar configuraciones si no existen
if [ ! -f ".kiro/settings/betteragents.json" ]; then
    if [ -f "$BETTERAGENTX_PATH/config/betteragents.json" ]; then
        cp "$BETTERAGENTX_PATH/config/betteragents.json" .kiro/settings/
        print_success "betteragents.json copiado"
    fi
else
    print_info "betteragents.json ya existe (no sobrescrito)"
fi

if [ ! -f ".kiro/settings/agent-skills.json" ]; then
    if [ -f "$BETTERAGENTX_PATH/config/agent-skills.json" ]; then
        cp "$BETTERAGENTX_PATH/config/agent-skills.json" .kiro/settings/
        print_success "agent-skills.json copiado"
    fi
else
    print_info "agent-skills.json ya existe (no sobrescrito)"
fi

echo ""

# ============================================
# 5. INICIALIZAR SISTEMA DE MEMORIA
# ============================================
print_section "5. Inicializando Sistema de Memoria"
echo ""

# Obtener nombre del proyecto
PROJECT_NAME=$(basename "$(pwd)")

# Crear archivos de memoria si no existen
if [ ! -f ".kiro/memory/active-context.md" ]; then
    cat > .kiro/memory/active-context.md << EOF
# 📋 Contexto Activo - $PROJECT_NAME

**Fecha de inicio:** $(date +%Y-%m-%d)  
**Proyecto:** $PROJECT_NAME  
**Sistema:** BetterAgentX v3.1.0

---

## 🎯 Objetivo Actual

[Describe el objetivo principal del proyecto]

---

## 🔧 Stack Tecnológico

- **Lenguajes:** 
- **Frameworks:** 
- **Base de datos:** 
- **Herramientas:** 

---

## 📊 Estado del Proyecto

**Fase actual:** Inicialización

---

## 🤝 Equipo

- **Desarrolladores:** 
- **Roles:** 

---

## 📝 Notas

[Notas importantes sobre el proyecto]
EOF
    print_success "active-context.md creado"
else
    print_info "active-context.md ya existe"
fi

if [ ! -f ".kiro/memory/decision-log.md" ]; then
    cat > .kiro/memory/decision-log.md << EOF
# 📋 Registro de Decisiones - $PROJECT_NAME

Registro de decisiones técnicas importantes (ADR - Architecture Decision Records)

---

## $(date +%Y-%m-%d) - Decisión #001: Integración de BetterAgentX

### Contexto
Inicialización del proyecto con sistema de agentes especializados

### Decisión
Integrar BetterAgentX como sistema de agentes para desarrollo

### Razones
- 13 agentes especializados disponibles
- Sistema de memoria automático
- Orquestación inteligente con AgentX
- Documentación completa

### Consecuencias
✅ Acceso a agentes especializados
✅ Sistema de memoria persistente
✅ Workflows colaborativos

### Agentes Involucrados
- AgentX: Orquestación

---
EOF
    print_success "decision-log.md creado"
else
    print_info "decision-log.md ya existe"
fi

if [ ! -f ".kiro/memory/progress.md" ]; then
    cat > .kiro/memory/progress.md << EOF
# 📊 Progreso del Proyecto - $PROJECT_NAME

---

## 🎯 Tareas Pendientes

### Alta Prioridad
- [ ] Definir objetivos del proyecto
- [ ] Configurar entorno de desarrollo
- [ ] Planificar arquitectura inicial

### Media Prioridad
- [ ] Configurar CI/CD
- [ ] Documentar APIs
- [ ] Configurar testing

### Baja Prioridad
- [ ] Optimizaciones
- [ ] Documentación adicional

---

## ✅ Tareas Completadas

### $(date +%Y-%m-%d)
- ✅ Integración de BetterAgentX
- ✅ Inicialización del sistema de memoria
- ✅ Configuración de agentes

---

## 📈 Métricas

- **Progreso general:** 5%
- **Tareas completadas:** 3
- **Tareas pendientes:** 6

---
EOF
    print_success "progress.md creado"
else
    print_info "progress.md ya existe"
fi

if [ ! -f ".kiro/memory/patterns.md" ]; then
    cat > .kiro/memory/patterns.md << EOF
# 🎨 Patrones y Soluciones - $PROJECT_NAME

Registro de patrones útiles y soluciones reutilizables

---

## Patrón #001: Integración de BetterAgentX

**Fecha:** $(date +%Y-%m-%d)  
**Categoría:** Configuración

### Problema
Necesidad de integrar sistema de agentes en proyecto existente

### Solución
Uso de enlaces simbólicos para mantener BetterAgentX como subproyecto

### Implementación
\`\`\`bash
# Estructura con symlinks
.kiro/steering/agents/  → BetterAgentX/.kiro/steering/agents/
.kiro/steering/agentx/  → BetterAgentX/.kiro/steering/agentx/
.agents/skills/         → BetterAgentX/.agents/skills/
\`\`\`

### Ventajas
- No duplica archivos
- Actualizable con git pull
- Mantiene separación de concerns

### Cuándo Usar
- Proyectos que necesitan sistema de agentes
- Múltiples proyectos compartiendo BetterAgentX

---
EOF
    print_success "patterns.md creado"
else
    print_info "patterns.md ya existe"
fi

echo ""

# ============================================
# 6. CREAR ARCHIVO DE CONFIGURACIÓN DEL PROYECTO
# ============================================
print_section "6. Configuración del Proyecto"
echo ""

if [ ! -f ".betteragentx" ]; then
    cat > .betteragentx << EOF
# BetterAgentX - Configuración del Proyecto
# Generado: $(date +%Y-%m-%d)

PROJECT_NAME="$PROJECT_NAME"
BETTERAGENTX_PATH="$BETTERAGENTX_PATH"
BETTERAGENTX_VERSION="3.1.0"
INITIALIZED_DATE="$(date +%Y-%m-%d)"

# Rutas
KIRO_DIR=".kiro"
MEMORY_DIR=".kiro/memory"
SETTINGS_DIR=".kiro/settings"
AGENTS_DIR=".agents"

# Estado
INITIALIZED=true
EOF
    print_success "Archivo .betteragentx creado"
else
    print_info "Archivo .betteragentx ya existe"
fi

echo ""

# ============================================
# 7. ACTUALIZAR .gitignore
# ============================================
print_section "7. Actualizando .gitignore"
echo ""

if [ -f ".gitignore" ]; then
    # Verificar si ya tiene las entradas
    if ! grep -q "# BetterAgentX" .gitignore; then
        cat >> .gitignore << EOF

# BetterAgentX - Archivos locales
.kiro/memory/
.kiro/settings/
.betteragentx

# NOTA: .kirorc se incluye en el repositorio para activar memoria automáticamente
EOF
        print_success ".gitignore actualizado"
    else
        print_info ".gitignore ya tiene configuración de BetterAgentX"
    fi
else
    cat > .gitignore << EOF
# BetterAgentX - Archivos locales
.kiro/memory/
.kiro/settings/
.betteragentx

# NOTA: .kirorc se incluye en el repositorio para activar memoria automáticamente
EOF
    print_success ".gitignore creado"
fi

echo ""

# ============================================
# 8. VERIFICACIÓN FINAL
# ============================================
print_section "8. Verificación Final"
echo ""

ERRORS=0

# Verificar enlaces simbólicos
if [ -L ".kiro/steering/agents" ]; then
    print_success "Enlace a agentes: OK"
else
    print_error "Enlace a agentes: FALLO"
    ERRORS=$((ERRORS + 1))
fi

if [ -L ".kiro/steering/agentx" ]; then
    print_success "Enlace a agentx: OK"
else
    print_error "Enlace a agentx: FALLO"
    ERRORS=$((ERRORS + 1))
fi

if [ -L ".agents/skills" ]; then
    print_success "Enlace a skills: OK"
else
    print_error "Enlace a skills: FALLO"
    ERRORS=$((ERRORS + 1))
fi

# Verificar archivos de memoria
if [ -f ".kiro/memory/active-context.md" ]; then
    print_success "Memoria: active-context.md"
else
    print_error "Memoria: active-context.md faltante"
    ERRORS=$((ERRORS + 1))
fi

if [ -f ".kiro/memory/decision-log.md" ]; then
    print_success "Memoria: decision-log.md"
else
    print_error "Memoria: decision-log.md faltante"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 9. ACTIVAR SISTEMA DE MEMORIA EN KIRO
# ============================================
print_section "9. Activando Sistema de Memoria"
echo ""

# Crear archivo de configuración de Kiro si no existe
if [ ! -d ".kiro/settings" ]; then
    mkdir -p .kiro/settings
fi

# Crear o actualizar configuración de Kiro para activar memoria
if [ ! -f ".kiro/settings/kiro.json" ]; then
    cat > .kiro/settings/kiro.json << EOF
{
  "memory": {
    "enabled": true,
    "autoLoad": true,
    "files": [
      ".kiro/memory/active-context.md",
      ".kiro/memory/decision-log.md",
      ".kiro/memory/progress.md",
      ".kiro/memory/patterns.md"
    ]
  },
  "agents": {
    "enabled": true,
    "autoLoad": true
  }
}
EOF
    print_success "Configuración de Kiro creada con memoria activada"
else
    print_info "Configuración de Kiro ya existe"
fi

# Crear archivo .kirorc en el proyecto para activar memoria automáticamente
cat > .kirorc << EOF
# BetterAgentX - Configuración de Kiro
# Generado automáticamente por init-betteragentx.sh

# Activar memoria automáticamente
memory.enabled=true
memory.autoLoad=true

# Archivos de memoria a cargar
memory.files=.kiro/memory/active-context.md,.kiro/memory/decision-log.md,.kiro/memory/progress.md,.kiro/memory/patterns.md

# Activar agentes
agents.enabled=true
agents.autoLoad=true
EOF

print_success "Archivo .kirorc creado (memoria activada automáticamente)"
print_info "La memoria se cargará automáticamente al abrir Kiro"

echo ""

# ============================================
# 10. RESUMEN FINAL
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Inicialización Completada"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ]; then
    print_success "BetterAgentX integrado exitosamente"
    echo ""
    echo "📊 Resumen:"
    echo "  • Proyecto: $PROJECT_NAME"
    echo "  • BetterAgentX: $BETTERAGENTX_PATH"
    echo "  • Agentes: 13 disponibles"
    echo "  • Memoria: Inicializada"
    echo ""
    echo "🚀 Próximos pasos:"
    echo "   1. Abre Kiro Code: kiro ."
    echo "   2. Prueba AgentX: @agentx Hola!"
    echo "   3. Edita contexto: nano .kiro/memory/active-context.md"
    echo ""
    echo "📚 Documentación:"
    echo "   • Guía rápida: $BETTERAGENTX_PATH/QUICKSTART-INTEGRATION.md"
    echo "   • Guía completa: $BETTERAGENTX_PATH/INTEGRATION.md"
    echo ""
    echo "🔧 Verificar instalación:"
    echo "   ./scripts/verify-betteragentx.sh"
    echo ""
    print_success "¡Listo para usar! 🎉"
else
    print_error "Se encontraron $ERRORS errores"
    echo ""
    echo "Ejecuta el script de verificación para más detalles:"
    echo "  ./scripts/verify-betteragentx.sh"
    exit 1
fi
