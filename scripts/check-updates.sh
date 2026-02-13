#!/bin/bash

# BetterAgentX - Verificación Rápida de Actualizaciones
# Script ligero para verificar si hay actualizaciones disponibles

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cargar configuración
if [ -f "config/.betteragents-config" ]; then
    source config/.betteragents-config
fi

# Verificar si es momento de chequear
CURRENT_TIME=$(date +%s)
DAYS_SINCE_CHECK=$(( ($CURRENT_TIME - ${LAST_UPDATE_CHECK:-0}) / 86400 ))

if [ "$DAYS_SINCE_CHECK" -lt "${UPDATE_CHECK_FREQUENCY:-7}" ]; then
    # No es momento de verificar aún
    exit 0
fi

# Verificar Node.js
if ! command -v node &> /dev/null; then
    exit 0
fi

# Verificar skills instalados
SKILLS_COUNT=$(npx skills list 2>/dev/null | grep -c "^  " || echo "0")

if [ "$SKILLS_COUNT" -eq 0 ]; then
    exit 0
fi

# Verificar actualizaciones disponibles
echo -e "${BLUE}🔍 Verificando actualizaciones de skills...${NC}"
CHECK_OUTPUT=$(npx skills check 2>&1)

# Actualizar timestamp
sed -i "s/LAST_UPDATE_CHECK=.*/LAST_UPDATE_CHECK=$CURRENT_TIME/" config/.betteragents-config 2>/dev/null || true

# Verificar si hay actualizaciones
if echo "$CHECK_OUTPUT" | grep -q "up to date" || echo "$CHECK_OUTPUT" | grep -q "No updates"; then
    echo -e "${GREEN}✅ Todos los skills están actualizados${NC}"
else
    echo -e "${YELLOW}⚠️  Hay actualizaciones disponibles para tus skills${NC}"
    echo ""
    echo "Para actualizar, ejecuta:"
    echo "  ./scripts/update-skills.sh"
    echo ""
    echo "O actualiza manualmente:"
    echo "  npx skills update"
fi
