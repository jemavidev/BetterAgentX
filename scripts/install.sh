#!/bin/bash

# BetterAgentX - Script de Instalación Automática
# Para Ubuntu/Debian Linux

set -e  # Salir si hay errores

echo "🚀 Instalando BetterAgentX..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "config/betteragents.json" ]; then
    print_error "No se encontró config/betteragents.json"
    print_error "Asegúrate de estar en el directorio raíz de BetterAgentX"
    exit 1
fi

print_success "Directorio correcto detectado"
echo ""

# Verificar Node.js
echo "🔍 Verificando Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        print_success "Node.js $(node --version) detectado"
    else
        print_warning "Node.js $(node --version) es muy antiguo"
        print_warning "Se recomienda Node.js 18 o superior"
        echo ""
        echo "¿Deseas instalar Node.js 20 con nvm? (s/n)"
        read -r response
        if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
            echo "Instalando nvm y Node.js 20..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install 20
            print_success "Node.js 20 instalado"
        fi
    fi
else
    print_warning "Node.js no está instalado"
    echo ""
    echo "¿Deseas instalar Node.js 20 con nvm? (s/n)"
    read -r response
    if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
        echo "Instalando nvm y Node.js 20..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install 20
        print_success "Node.js 20 instalado"
    else
        print_error "Node.js es requerido para instalar skills"
        print_warning "Puedes continuar sin skills, pero se recomienda instalarlos"
    fi
fi
echo ""

# Verificar npm
echo "🔍 Verificando npm..."
if command -v npm &> /dev/null; then
    print_success "npm $(npm --version) detectado"
else
    print_error "npm no está instalado"
    print_warning "npm debería venir con Node.js"
fi
echo ""

# Verificar Kiro Code
echo "🔍 Verificando Kiro Code..."
if command -v kiro &> /dev/null; then
    print_success "Kiro Code detectado"
else
    print_warning "Kiro Code no está instalado"
    echo ""
    echo "Kiro Code es REQUERIDO para usar BetterAgentX"
    echo "Descárgalo desde: https://kiro.ai"
    echo ""
    echo "Después de instalar Kiro, ejecuta este script nuevamente"
    exit 1
fi
echo ""

# Verificar estructura del proyecto
echo "🔍 Verificando estructura del proyecto..."

if [ -d ".kiro/steering/agents" ]; then
    AGENT_COUNT=$(ls -1 .kiro/steering/agents/*.md 2>/dev/null | wc -l)
    if [ "$AGENT_COUNT" -eq 12 ]; then
        print_success "12 agentes encontrados"
    else
        print_warning "Solo se encontraron $AGENT_COUNT agentes (se esperan 12)"
    fi
else
    print_error "Carpeta de agentes no encontrada"
    exit 1
fi

# Crear sistema de memoria desde templates si no existe
if [ ! -d ".kiro/memory" ]; then
    print_warning "Sistema de memoria no encontrado, creando desde templates..."
    mkdir -p .kiro/memory
    if [ -d "templates/memory" ]; then
        cp templates/memory/*.md .kiro/memory/
        print_success "Sistema de memoria creado desde templates"
    else
        print_error "Templates de memoria no encontrados"
    fi
fi

if [ -d ".kiro/memory" ]; then
    MEMORY_COUNT=$(ls -1 .kiro/memory/*.md 2>/dev/null | wc -l)
    if [ "$MEMORY_COUNT" -eq 5 ]; then
        print_success "Sistema de memoria completo (5 archivos)"
    else
        print_warning "Sistema de memoria incompleto ($MEMORY_COUNT/5 archivos)"
    fi
fi

if [ -d ".agents/skills" ]; then
    print_success "Carpeta de skills presente"
else
    print_warning "Carpeta de skills no encontrada"
fi
echo ""

# Verificar si ya hay skills instalados
EXISTING_SKILLS=0
if command -v npm &> /dev/null; then
    EXISTING_SKILLS=$(npx skills list 2>/dev/null | grep -c "^  " || echo "0")
fi

# Preguntar sobre instalación/actualización de skills
if command -v npm &> /dev/null; then
    if [ "$EXISTING_SKILLS" -gt 0 ]; then
        echo "📚 Se detectaron $EXISTING_SKILLS skills instalados"
        echo "1) Actualizar skills existentes"
        echo "2) Instalar skills adicionales"
        echo "3) Saltar gestión de skills"
        echo ""
        read -p "Selecciona una opción (1-3): " skill_option
        
        case $skill_option in
            1)
                echo ""
                print_success "Actualizando skills existentes..."
                echo ""
                
                # Verificar actualizaciones
                print_success "Verificando actualizaciones disponibles..."
                npx skills check
                echo ""
                
                # Actualizar
                print_success "Actualizando todos los skills..."
                npx skills update
                echo ""
                print_success "Skills actualizados"
                ;;
            2)
                echo ""
                echo "Opciones de instalación adicional:"
                echo "1) Skills esenciales (5 skills)"
                echo "2) Todos los skills (~60 skills)"
                echo "3) Cancelar"
                echo ""
                read -p "Selecciona una opción (1-3): " install_option
                
                case $install_option in
                    1)
                        echo ""
                        echo "📦 Instalando skills esenciales..."
                        npx skills add wshobson/agents/architecture-patterns -y
                        npx skills add obra/superpowers/systematic-debugging -y
                        npx skills add vercel-labs/agent-skills/vercel-react-best-practices -y
                        npx skills add anthropics/skills/webapp-testing -y
                        npx skills add anthropics/skills/doc-coauthoring -y
                        print_success "Skills esenciales instalados"
                        ;;
                    2)
                        echo ""
                        if [ -f "install-skills.sh" ]; then
                            echo "📦 Instalando todos los skills..."
                            chmod +x install-skills.sh
                            ./install-skills.sh
                        else
                            print_warning "Script install-skills.sh no encontrado"
                        fi
                        ;;
                    3)
                        print_warning "Instalación adicional cancelada"
                        ;;
                esac
                ;;
            3)
                print_warning "Saltando gestión de skills"
                ;;
        esac
    else
        echo "📚 ¿Deseas instalar skills? (Recomendado)"
        echo "1) Instalar skills esenciales (5 skills - rápido)"
        echo "2) Instalar todos los skills (~60 skills - completo)"
        echo "3) Saltar instalación de skills"
        echo ""
        read -p "Selecciona una opción (1-3): " skill_option
        
        case $skill_option in
            1)
                echo ""
                echo "📦 Instalando skills esenciales..."
                npx skills add wshobson/agents/architecture-patterns -y
                npx skills add obra/superpowers/systematic-debugging -y
                npx skills add vercel-labs/agent-skills/vercel-react-best-practices -y
                npx skills add anthropics/skills/webapp-testing -y
                npx skills add anthropics/skills/doc-coauthoring -y
                print_success "Skills esenciales instalados"
                ;;
            2)
                echo ""
                if [ -f "install-skills.sh" ]; then
                    echo "📦 Instalando todos los skills..."
                    chmod +x install-skills.sh
                    ./install-skills.sh
                else
                    print_warning "Script install-skills.sh no encontrado"
                    print_warning "Instalando skills esenciales en su lugar..."
                    npx skills add wshobson/agents/architecture-patterns -y
                    npx skills add obra/superpowers/systematic-debugging -y
                    npx skills add vercel-labs/agent-skills/vercel-react-best-practices -y
                    npx skills add anthropics/skills/webapp-testing -y
                    npx skills add anthropics/skills/doc-coauthoring -y
                fi
                ;;
            3)
                print_warning "Saltando instalación de skills"
                print_warning "Puedes instalarlos después con: npx skills add <skill-name>"
                ;;
            *)
                print_warning "Opción inválida, saltando instalación de skills"
                ;;
        esac
    fi
fi
echo ""

# Resumen final
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Instalación Completada"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "BetterAgentX está listo para usar"
echo ""
echo "📊 Resumen:"
echo "  • Agentes: $AGENT_COUNT/12"
echo "  • Memoria: $MEMORY_COUNT/5 archivos"
echo "  • Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
echo "  • Kiro Code: Instalado"
echo ""
echo "🚀 Para empezar:"
echo "   kiro ."
echo ""
echo "💡 Primer comando de prueba:"
echo "   @architect Hola! ¿Puedes explicarme cómo funcionas?"
echo ""
echo "🔄 Actualizar skills:"
echo "   ./scripts/update-skills.sh"
echo ""
echo "📚 Documentación:"
echo "   • README.md - Guía general"
echo "   • docs/guides/getting-started.md - Tutorial de inicio"
echo "   • docs/installation/linux.md - Guía de instalación"
echo "   • docs/guides/workflows.md - Workflows colaborativos"
echo "   • templates/memory/README.md - Sistema de memoria"
echo ""
print_success "¡Feliz coding! 🎉"
