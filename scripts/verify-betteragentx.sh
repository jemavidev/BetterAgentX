#!/bin/bash

# BetterAgentX - Script de Verificación
# Verifica que la integración de BetterAgentX esté correcta

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

echo "🔍 BetterAgentX - Verificación de Integración"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0
WARNINGS=0

# ============================================
# 1. VERIFICAR ARCHIVO DE CONFIGURACIÓN
# ============================================
print_section "1. Configuración del Proyecto"
echo ""

if [ -f ".betteragentx" ]; then
    print_success "Archivo .betteragentx encontrado"
    source .betteragentx
    print_info "Proyecto: $PROJECT_NAME"
    print_info "BetterAgentX: $BETTERAGENTX_PATH"
    print_info "Inicializado: $INITIALIZED_DATE"
else
    print_error "Archivo .betteragentx no encontrado"
    print_info "Ejecuta: ./scripts/init-betteragentx.sh"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 2. VERIFICAR ESTRUCTURA DE DIRECTORIOS
# ============================================
print_section "2. Estructura de Directorios"
echo ""

check_dir() {
    if [ -d "$1" ]; then
        print_success "$1"
    else
        print_error "$1 no existe"
        ERRORS=$((ERRORS + 1))
    fi
}

check_dir ".kiro"
check_dir ".kiro/steering"
check_dir ".kiro/memory"
check_dir ".kiro/settings"
check_dir ".agents"

echo ""

# ============================================
# 3. VERIFICAR ENLACES SIMBÓLICOS
# ============================================
print_section "3. Enlaces Simbólicos"
echo ""

check_symlink() {
    local link=$1
    local name=$2
    
    if [ -L "$link" ]; then
        local target=$(readlink "$link")
        if [ -e "$link" ]; then
            print_success "$name → $target"
        else
            print_error "$name → $target (destino no existe)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        if [ -d "$link" ]; then
            print_warning "$name existe pero NO es symlink"
            WARNINGS=$((WARNINGS + 1))
        else
            print_error "$name no existe"
            ERRORS=$((ERRORS + 1))
        fi
    fi
}

check_symlink ".kiro/steering/agents" "Agentes"
check_symlink ".kiro/steering/agentx" "AgentX"
check_symlink ".kiro/steering/_common" "Common"
check_symlink ".agents/skills" "Skills"

echo ""

# ============================================
# 4. VERIFICAR AGENTES
# ============================================
print_section "4. Agentes Disponibles"
echo ""

if [ -L ".kiro/steering/agents" ] && [ -d ".kiro/steering/agents" ]; then
    AGENT_COUNT=$(ls -1 .kiro/steering/agents/*.md 2>/dev/null | wc -l)
    
    if [ "$AGENT_COUNT" -ge 12 ]; then
        print_success "$AGENT_COUNT agentes encontrados"
        
        # Listar agentes
        print_info "Agentes disponibles:"
        ls -1 .kiro/steering/agents/*.md 2>/dev/null | while read agent; do
            agent_name=$(basename "$agent" .md)
            echo "  • $agent_name"
        done
    else
        print_warning "Solo $AGENT_COUNT agentes (se esperan 12+)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    print_error "Directorio de agentes no accesible"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# ============================================
# 5. VERIFICAR SISTEMA DE MEMORIA
# ============================================
print_section "5. Sistema de Memoria"
echo ""

check_file() {
    if [ -f "$1" ]; then
        local size=$(du -h "$1" | cut -f1)
        print_success "$1 ($size)"
    else
        print_error "$1 no existe"
        ERRORS=$((ERRORS + 1))
    fi
}

check_file ".kiro/memory/active-context.md"
check_file ".kiro/memory/decision-log.md"
check_file ".kiro/memory/progress.md"
check_file ".kiro/memory/patterns.md"

echo ""

# ============================================
# 6. VERIFICAR CONFIGURACIONES
# ============================================
print_section "6. Archivos de Configuración"
echo ""

check_file ".kiro/settings/betteragents.json"
check_file ".kiro/settings/agent-skills.json"

echo ""

# ============================================
# 7. VERIFICAR .gitignore
# ============================================
print_section "7. Configuración de Git"
echo ""

if [ -f ".gitignore" ]; then
    if grep -q "BetterAgentX" .gitignore; then
        print_success ".gitignore configurado para BetterAgentX"
    else
        print_warning ".gitignore no tiene configuración de BetterAgentX"
        print_info "Añade estas líneas:"
        echo ""
        echo "  # BetterAgentX - Archivos locales"
        echo "  .kiro/memory/"
        echo "  .kiro/settings/"
        echo "  .betteragentx"
        echo ""
        WARNINGS=$((WARNINGS + 1))
    fi
else
    print_warning ".gitignore no existe"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# 8. VERIFICAR BETTERAGENTX
# ============================================
print_section "8. BetterAgentX (Fuente)"
echo ""

if [ -f ".betteragentx" ]; then
    source .betteragentx
    
    if [ -d "$BETTERAGENTX_PATH" ]; then
        print_success "BetterAgentX encontrado: $BETTERAGENTX_PATH"
        
        # Verificar estructura de BetterAgentX
        if [ -f "$BETTERAGENTX_PATH/README.md" ]; then
            print_success "README.md presente"
        fi
        
        if [ -d "$BETTERAGENTX_PATH/.kiro/steering/agents" ]; then
            local ba_agents=$(ls -1 "$BETTERAGENTX_PATH/.kiro/steering/agents"/*.md 2>/dev/null | wc -l)
            print_success "Agentes en fuente: $ba_agents"
        fi
        
        # Verificar si es repositorio git
        if [ -d "$BETTERAGENTX_PATH/.git" ]; then
            print_success "BetterAgentX es repositorio Git"
            
            # Verificar remote
            cd "$BETTERAGENTX_PATH"
            if git remote -v | grep -q "jemavidev/BetterAgentX"; then
                print_success "Remote configurado correctamente"
            else
                print_warning "Remote no apunta a jemavidev/BetterAgentX"
                WARNINGS=$((WARNINGS + 1))
            fi
            cd - > /dev/null
        else
            print_warning "BetterAgentX no es repositorio Git"
            print_info "No podrás actualizar con git pull"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        print_error "BetterAgentX no encontrado en: $BETTERAGENTX_PATH"
        ERRORS=$((ERRORS + 1))
    fi
fi

echo ""

# ============================================
# 9. VERIFICAR KIRO CODE
# ============================================
print_section "9. Kiro Code"
echo ""

if command -v kiro &> /dev/null; then
    print_success "Kiro Code instalado: $(kiro --version 2>/dev/null || echo 'versión desconocida')"
else
    print_warning "Kiro Code no encontrado en PATH"
    print_info "Instala desde: https://kiro.ai"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================
# 10. DIAGNÓSTICO DE PROBLEMAS COMUNES
# ============================================
if [ $ERRORS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    print_section "10. Diagnóstico de Problemas"
    echo ""
    
    if [ $ERRORS -gt 0 ]; then
        print_error "Se encontraron $ERRORS errores críticos"
        echo ""
        echo "Soluciones comunes:"
        echo ""
        echo "1. Si faltan enlaces simbólicos:"
        echo "   ./scripts/init-betteragentx.sh"
        echo ""
        echo "2. Si BetterAgentX no se encuentra:"
        echo "   git clone https://github.com/jemavidev/BetterAgentX.git"
        echo "   ./scripts/init-betteragentx.sh"
        echo ""
        echo "3. Si faltan archivos de memoria:"
        echo "   Ejecuta init-betteragentx.sh de nuevo"
        echo ""
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        print_warning "Se encontraron $WARNINGS advertencias"
        echo ""
        echo "Las advertencias no impiden el funcionamiento pero se recomienda resolverlas."
        echo ""
    fi
fi

# ============================================
# RESUMEN FINAL
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resumen de Verificación"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_success "✨ Todo está correcto"
    echo ""
    echo "🚀 BetterAgentX está listo para usar"
    echo ""
    echo "Comandos útiles:"
    echo "  • Abrir proyecto: kiro ."
    echo "  • Usar AgentX: @agentx [tu consulta]"
    echo "  • Ver memoria: cat .kiro/memory/active-context.md"
    echo "  • Actualizar BetterAgentX: cd $BETTERAGENTX_PATH && git pull"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    print_warning "⚠️  Sistema funcional con advertencias"
    echo ""
    print_info "Errores: 0"
    print_warning "Advertencias: $WARNINGS"
    echo ""
    exit 0
else
    print_error "❌ Se encontraron problemas"
    echo ""
    print_error "Errores: $ERRORS"
    print_warning "Advertencias: $WARNINGS"
    echo ""
    echo "Ejecuta init-betteragentx.sh para corregir problemas"
    exit 1
fi
