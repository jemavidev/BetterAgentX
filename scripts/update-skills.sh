#!/bin/bash

# BetterAgentX - Script de Actualización de Skills
# Mantiene todos los skills en su versión más reciente

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🔄 BetterAgentX - Actualización de Skills"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "config/betteragents.json" ]; then
    print_error "No se encontró config/betteragents.json"
    print_error "Asegúrate de estar en el directorio raíz de BetterAgentX"
    exit 1
fi

# Verificar Node.js y npm
if ! command -v node &> /dev/null; then
    print_error "Node.js no está instalado"
    print_error "Instala Node.js primero: ./install.sh"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm no está instalado"
    print_error "Instala Node.js primero: ./scripts/install.sh"
    exit 1
fi

print_success "Entorno verificado"
echo ""

# Verificar skills instalados
print_info "Verificando skills instalados..."
SKILLS_COUNT=$(npx skills list 2>/dev/null | grep -c "^  " || echo "0")

if [ "$SKILLS_COUNT" -eq 0 ]; then
    print_warning "No hay skills instalados"
    echo ""
    echo "¿Deseas instalar skills ahora? (s/n)"
    read -r response
    if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
        echo ""
        echo "Opciones de instalación:"
        echo "1) Skills esenciales (5 skills - rápido)"
        echo "2) Todos los skills (~60 skills - completo)"
        echo "3) Cancelar"
        echo ""
        read -p "Selecciona una opción (1-3): " install_option
        
        case $install_option in
            1)
                echo ""
                print_info "Instalando skills esenciales..."
                npx skills add wshobson/agents/architecture-patterns -y
                npx skills add obra/superpowers/systematic-debugging -y
                npx skills add vercel-labs/agent-skills/vercel-react-best-practices -y
                npx skills add anthropics/skills/webapp-testing -y
                npx skills add anthropics/skills/doc-coauthoring -y
                print_success "Skills esenciales instalados"
                ;;
            2)
                if [ -f "install-skills.sh" ]; then
                    print_info "Ejecutando instalación completa..."
                    chmod +x install-skills.sh
                    ./install-skills.sh
                else
                    print_warning "Script install-skills.sh no encontrado"
                    print_info "Instalando skills esenciales en su lugar..."
                    npx skills add wshobson/agents/architecture-patterns -y
                    npx skills add obra/superpowers/systematic-debugging -y
                    npx skills add vercel-labs/agent-skills/vercel-react-best-practices -y
                    npx skills add anthropics/skills/webapp-testing -y
                    npx skills add anthropics/skills/doc-coauthoring -y
                fi
                ;;
            3)
                print_info "Instalación cancelada"
                exit 0
                ;;
            *)
                print_error "Opción inválida"
                exit 1
                ;;
        esac
    else
        print_info "Saliendo sin instalar skills"
        exit 0
    fi
    echo ""
fi

# Listar skills actuales
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Skills instalados actualmente:"
echo ""
npx skills list
echo ""

# Verificar actualizaciones disponibles
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Verificando actualizaciones disponibles..."
echo ""

# Ejecutar check y capturar resultado
CHECK_OUTPUT=$(npx skills check 2>&1)
echo "$CHECK_OUTPUT"
echo ""

# Determinar si hay actualizaciones
if echo "$CHECK_OUTPUT" | grep -q "up to date" || echo "$CHECK_OUTPUT" | grep -q "No updates"; then
    print_success "Todos los skills están actualizados"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "No se requieren actualizaciones"
    exit 0
fi

# Hay actualizaciones disponibles
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_warning "Hay actualizaciones disponibles"
echo ""
echo "¿Deseas actualizar todos los skills ahora? (s/n)"
read -r response

if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
    echo ""
    print_info "Actualizando skills..."
    echo ""
    
    # Actualizar todos los skills
    npx skills update
    
    echo ""
    print_success "Skills actualizados exitosamente"
    echo ""
    
    # Mostrar skills actualizados
    print_info "Skills después de la actualización:"
    echo ""
    npx skills list
    echo ""
else
    print_info "Actualización cancelada"
    echo ""
    print_warning "Puedes actualizar manualmente con: npx skills update"
fi

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Proceso completado"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_info "Comandos útiles:"
echo "  • Verificar actualizaciones: npx skills check"
echo "  • Actualizar skills:         npx skills update"
echo "  • Listar skills:             npx skills list"
echo "  • Buscar skills:             npx skills find"
echo ""
print_success "¡Listo! 🎉"
