#!/bin/bash

# BetterAgentX - Script de Verificación Completa del Sistema
# Analiza agentes, skills, y compatibilidad

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

echo "🔍 BetterAgentX - Verificación Completa del Sistema"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar directorio
if [ ! -f "config/betteragents.json" ]; then
    print_error "No se encontró config/betteragents.json"
    print_error "Asegúrate de estar en el directorio raíz de BetterAgentX"
    exit 1
fi

ISSUES_FOUND=0
WARNINGS_FOUND=0

# ============================================
# 1. VERIFICAR ESTRUCTURA DE ARCHIVOS
# ============================================
print_section "1. Estructura de Archivos"
echo ""

# Verificar agentes
if [ -d ".kiro/steering/agents" ]; then
    AGENT_COUNT=$(ls -1 .kiro/steering/agents/*.md 2>/dev/null | wc -l)
    if [ "$AGENT_COUNT" -eq 12 ]; then
        print_success "12 agentes encontrados"
    else
        print_error "Solo $AGENT_COUNT agentes (se esperan 12)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    print_error "Carpeta de agentes no encontrada"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Verificar memoria
if [ -d ".kiro/memory" ]; then
    MEMORY_COUNT=$(ls -1 .kiro/memory/*.md 2>/dev/null | wc -l)
    if [ "$MEMORY_COUNT" -eq 5 ]; then
        print_success "Sistema de memoria completo (5 archivos)"
    else
        print_warning "Sistema de memoria incompleto ($MEMORY_COUNT/5)"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
else
    print_warning "Sistema de memoria no encontrado"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

# Verificar skills
if [ -d ".agents/skills" ]; then
    print_success "Carpeta de skills presente"
else
    print_warning "Carpeta de skills no encontrada"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

# Verificar symlink
if [ -L ".kiro/skills" ]; then
    print_success "Symlink de skills correcto"
else
    print_warning "Symlink de skills no encontrado"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

echo ""

# ============================================
# 2. VERIFICAR AGENTES
# ============================================
print_section "2. Análisis de Agentes"
echo ""

AGENTS_OK=0
AGENTS_ISSUES=0

for agent_file in .kiro/steering/agents/*.md; do
    agent_name=$(basename "$agent_file" .md)
    
    # Verificar secciones requeridas
    has_identity=$(grep -c "## Identity" "$agent_file" || echo 0)
    has_role=$(grep -c "## Role" "$agent_file" || echo 0)
    has_expertise=$(grep -c "## Expertise" "$agent_file" || echo 0)
    has_skills=$(grep -c "## 🎯 Available Skills" "$agent_file" || echo 0)
    
    if [ "$has_identity" -gt 0 ] && [ "$has_role" -gt 0 ] && [ "$has_expertise" -gt 0 ]; then
        print_success "$agent_name: Estructura completa"
        AGENTS_OK=$((AGENTS_OK + 1))
    else
        print_warning "$agent_name: Faltan secciones"
        AGENTS_ISSUES=$((AGENTS_ISSUES + 1))
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
done

echo ""
print_info "Agentes OK: $AGENTS_OK/12"
if [ "$AGENTS_ISSUES" -gt 0 ]; then
    print_warning "Agentes con issues: $AGENTS_ISSUES"
fi

echo ""

# ============================================
# 3. VERIFICAR SKILLS RECOMENDADOS
# ============================================
print_section "3. Skills Recomendados en Agentes"
echo ""

# Extraer todos los skills recomendados
TOTAL_SKILLS=$(grep -h "npx skills" .kiro/steering/agents/*.md | grep -c "add" || echo 0)
print_info "Total de skills recomendados: $TOTAL_SKILLS"

# Verificar sintaxis correcta
WRONG_SYNTAX=$(grep -h "npx skillsadd" .kiro/steering/agents/*.md | wc -l || echo 0)
if [ "$WRONG_SYNTAX" -gt 0 ]; then
    print_error "Encontrados $WRONG_SYNTAX comandos con sintaxis incorrecta (skillsadd)"
    print_info "Debería ser: 'npx skills add' (con espacio)"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    print_success "Sintaxis de comandos correcta"
fi

# Listar skills únicos recomendados
echo ""
print_info "Skills únicos recomendados:"
grep -h "npx skills" .kiro/steering/agents/*.md | \
    sed 's/.*npx skills add //' | \
    sed 's/npx skillsadd //' | \
    sort -u | \
    head -10 | \
    while read skill; do
        echo "  • $skill"
    done

echo ""

# ============================================
# 4. VERIFICAR SKILLS INSTALADOS
# ============================================
print_section "4. Skills Instalados"
echo ""

if command -v npm &> /dev/null; then
    INSTALLED_SKILLS=$(npx skills list 2>/dev/null | grep -c "^  " || echo 0)
    
    if [ "$INSTALLED_SKILLS" -gt 0 ]; then
        print_success "$INSTALLED_SKILLS skills instalados"
        
        # Verificar actualizaciones
        print_info "Verificando actualizaciones..."
        CHECK_OUTPUT=$(npx skills check 2>&1)
        
        if echo "$CHECK_OUTPUT" | grep -q "up to date\|No updates"; then
            print_success "Todos los skills están actualizados"
        else
            print_warning "Hay actualizaciones disponibles"
            print_info "Ejecuta: ./scripts/update-skills.sh"
            WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
        fi
    else
        print_warning "No hay skills instalados"
        print_info "Ejecuta: ./scripts/install.sh para instalar"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
else
    print_warning "npm no está disponible, no se pueden verificar skills"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

echo ""

# ============================================
# 5. VERIFICAR COMPLEMENTARIEDAD
# ============================================
print_section "5. Análisis de Complementariedad"
echo ""

print_info "Verificando workflows complementarios..."

# Workflow típico: Architect -> Critic -> Coder -> Tester -> Writer
WORKFLOW_AGENTS=("architect" "critic" "coder" "tester" "writer")
WORKFLOW_OK=true

for agent in "${WORKFLOW_AGENTS[@]}"; do
    if [ -f ".kiro/steering/agents/$agent.md" ]; then
        print_success "$agent presente"
    else
        print_error "$agent faltante"
        WORKFLOW_OK=false
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

echo ""
if [ "$WORKFLOW_OK" = true ]; then
    print_success "Workflow básico completo"
else
    print_error "Workflow básico incompleto"
fi

echo ""

# ============================================
# 6. VERIFICAR SCRIPTS
# ============================================
print_section "6. Scripts del Sistema"
echo ""

SCRIPTS=("scripts/install.sh" "scripts/update-skills.sh" "scripts/check-updates.sh" "scripts/verify-system.sh")
SCRIPTS_OK=0

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_success "$script (ejecutable)"
            SCRIPTS_OK=$((SCRIPTS_OK + 1))
        else
            print_warning "$script (no ejecutable)"
            print_info "Ejecuta: chmod +x $script"
            WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
        fi
    else
        print_error "$script no encontrado"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

echo ""

# ============================================
# 7. VERIFICAR DOCUMENTACIÓN
# ============================================
print_section "7. Documentación"
echo ""

DOCS=("README.md" "docs/installation/linux.md" "CHANGELOG.md" "CONTRIBUTING.md" "LICENSE" "docs/guides/skills-management.md")
DOCS_OK=0

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        SIZE=$(du -h "$doc" | cut -f1)
        print_success "$doc ($SIZE)"
        DOCS_OK=$((DOCS_OK + 1))
    else
        print_warning "$doc no encontrado"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
done

echo ""

# ============================================
# 8. VERIFICAR CONFIGURACIÓN
# ============================================
print_section "8. Configuración"
echo ""

if [ -f "config/.betteragents-config" ]; then
    print_success "Archivo de configuración presente"
    
    # Verificar configuración
    AUTO_UPDATE=$(grep "AUTO_UPDATE_SKILLS" config/.betteragents-config | cut -d'=' -f2)
    UPDATE_FREQ=$(grep "UPDATE_CHECK_FREQUENCY" config/.betteragents-config | cut -d'=' -f2)
    
    print_info "Auto-actualización: $AUTO_UPDATE"
    print_info "Frecuencia de verificación: $UPDATE_FREQ días"
else
    print_warning "Archivo de configuración no encontrado"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

if [ -f ".gitignore" ]; then
    print_success "Archivo .gitignore presente"
else
    print_warning "Archivo .gitignore no encontrado"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi

echo ""

# ============================================
# 9. VERIFICAR COMPATIBILIDAD DE SKILLS
# ============================================
print_section "9. Compatibilidad de Skills por Agente"
echo ""

# Mapeo de agentes y sus skills recomendados
declare -A AGENT_SKILLS=(
    ["architect"]="architecture-patterns api-design-principles microservices-patterns"
    ["coder"]="vercel-react-best-practices next-best-practices typescript-advanced-types"
    ["critic"]="systematic-debugging verification-before-completion"
    ["tester"]="webapp-testing e2e-testing-patterns"
    ["writer"]="doc-coauthoring writing-skills"
    ["researcher"]="find-skills competitor-alternatives"
    ["teacher"]="skill-creator prompt-engineering-patterns"
    ["devops"]="docker-expert deployment-pipeline-design"
    ["security"]="code-reviewer auth-implementation-patterns"
    ["ux-designer"]="frontend-design web-design-guidelines ui-ux-pro-max"
    ["data-scientist"]="sql-optimization-patterns postgresql-table-design"
    ["product-manager"]="writing-plans executing-plans brainstorming"
)

COMPATIBILITY_OK=0
COMPATIBILITY_ISSUES=0

for agent in "${!AGENT_SKILLS[@]}"; do
    if [ -f ".kiro/steering/agents/$agent.md" ]; then
        skills_count=$(echo "${AGENT_SKILLS[$agent]}" | wc -w)
        print_success "$agent: $skills_count skills recomendados"
        COMPATIBILITY_OK=$((COMPATIBILITY_OK + 1))
    else
        print_error "$agent: agente no encontrado"
        COMPATIBILITY_ISSUES=$((COMPATIBILITY_ISSUES + 1))
    fi
done

echo ""

# ============================================
# RESUMEN FINAL
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

print_info "Agentes: $AGENTS_OK/12 OK"
print_info "Scripts: $SCRIPTS_OK/${#SCRIPTS[@]} OK"
print_info "Documentación: $DOCS_OK/${#DOCS[@]} OK"
print_info "Compatibilidad: $COMPATIBILITY_OK/${#AGENT_SKILLS[@]} OK"
echo ""

if [ "$ISSUES_FOUND" -eq 0 ] && [ "$WARNINGS_FOUND" -eq 0 ]; then
    print_success "✨ Sistema completamente funcional"
    print_success "No se encontraron problemas"
    echo ""
    print_info "El sistema está listo para usar:"
    echo "  kiro ."
    exit 0
elif [ "$ISSUES_FOUND" -eq 0 ]; then
    print_warning "⚠️  Sistema funcional con advertencias"
    print_warning "Advertencias encontradas: $WARNINGS_FOUND"
    echo ""
    print_info "El sistema funciona pero hay mejoras recomendadas"
    exit 0
else
    print_error "❌ Se encontraron problemas críticos"
    print_error "Problemas: $ISSUES_FOUND"
    print_warning "Advertencias: $WARNINGS_FOUND"
    echo ""
    print_info "Revisa los errores arriba y corrígelos"
    exit 1
fi
