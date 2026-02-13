# 🔄 Guía de Actualización de Skills - BetterAgents

Esta guía explica cómo mantener tus skills siempre actualizados para obtener las últimas mejoras y características.

---

## 📋 Tabla de Contenidos

1. [¿Por qué actualizar?](#por-qué-actualizar)
2. [Métodos de Actualización](#métodos-de-actualización)
3. [Actualización Automática](#actualización-automática)
4. [Actualización Manual](#actualización-manual)
5. [Verificación de Actualizaciones](#verificación-de-actualizaciones)
6. [Configuración](#configuración)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 ¿Por qué actualizar?

Los skills se actualizan frecuentemente con:

- ✅ **Nuevas características** - Capacidades mejoradas
- ✅ **Correcciones de bugs** - Mejor estabilidad
- ✅ **Mejoras de rendimiento** - Respuestas más rápidas
- ✅ **Nuevos patrones** - Mejores prácticas actualizadas
- ✅ **Compatibilidad** - Soporte para nuevas versiones

**Recomendación:** Actualiza semanalmente para proyectos activos.

---

## 🚀 Métodos de Actualización

### Método 1: Script Automático (Recomendado)

El método más simple y seguro:

```bash
./update-skills.sh
```

**Características:**
- ✅ Verifica skills instalados
- ✅ Detecta actualizaciones disponibles
- ✅ Actualiza todos los skills
- ✅ Muestra resumen de cambios
- ✅ Maneja errores automáticamente

**Proceso:**
1. Ejecuta el script
2. Revisa las actualizaciones disponibles
3. Confirma la actualización
4. Espera a que termine
5. ¡Listo!

---

### Método 2: Comandos del CLI

Para más control manual:

```bash
# 1. Verificar actualizaciones
npx skills check

# 2. Actualizar todos los skills
npx skills update

# 3. Verificar que se actualizaron
npx skills list
```

---

### Método 3: Durante la Instalación

Al ejecutar `install.sh`, si ya tienes skills instalados:

```bash
./install.sh
```

El script detectará los skills existentes y ofrecerá:
1. Actualizar skills existentes
2. Instalar skills adicionales
3. Saltar gestión de skills

---

## 🤖 Actualización Automática

### Configurar Actualización Automática

Edita `.betteragents-config`:

```bash
# Habilitar actualización automática
AUTO_UPDATE_SKILLS=true

# Frecuencia de verificación (en días)
UPDATE_CHECK_FREQUENCY=7

# Actualizar sin preguntar
SILENT_UPDATE=true
```

### Crear Tarea Programada (Cron)

Para actualizar automáticamente cada semana:

```bash
# Editar crontab
crontab -e

# Añadir línea (actualiza cada lunes a las 9 AM)
0 9 * * 1 cd ~/Documents/GIT/BetterAgents && ./update-skills.sh -y >> ~/betteragents-update.log 2>&1
```

**Explicación del cron:**
- `0 9 * * 1` - Lunes a las 9:00 AM
- `cd ~/Documents/GIT/BetterAgents` - Ir al directorio
- `./update-skills.sh -y` - Ejecutar actualización (sin preguntar)
- `>> ~/betteragents-update.log 2>&1` - Guardar log

### Verificar Tarea Programada

```bash
# Ver tareas programadas
crontab -l

# Ver logs de actualización
tail -f ~/betteragents-update.log
```

---

## 🔍 Verificación de Actualizaciones

### Verificación Rápida

```bash
# Script de verificación rápida
./check-updates.sh
```

Este script:
- ✅ Verifica si es momento de chequear (según configuración)
- ✅ Detecta actualizaciones disponibles
- ✅ Notifica si hay actualizaciones
- ✅ No actualiza automáticamente (solo informa)

### Verificación Manual

```bash
# Ver actualizaciones disponibles
npx skills check

# Ver skills instalados y sus versiones
npx skills list

# Ver información detallada de un skill
npx skills info wshobson/agents/architecture-patterns
```

### Verificación Detallada

```bash
# Ver todos los skills con detalles
npx skills list --verbose

# Buscar skill específico
npx skills find architecture

# Ver changelog de un skill (si está disponible)
npx skills info wshobson/agents/architecture-patterns --changelog
```

---

## ⚙️ Configuración

### Archivo de Configuración

El archivo `.betteragents-config` controla el comportamiento de las actualizaciones:

```bash
# Actualización automática de skills
AUTO_UPDATE_SKILLS=false          # true para habilitar

# Frecuencia de verificación (en días)
UPDATE_CHECK_FREQUENCY=7          # Verificar cada 7 días

# Última verificación (timestamp)
LAST_UPDATE_CHECK=0               # Actualizado automáticamente

# Notificar cuando hay actualizaciones disponibles
NOTIFY_UPDATES=true               # Mostrar notificaciones

# Actualizar skills automáticamente sin preguntar
SILENT_UPDATE=false               # true para actualizar sin confirmar

# Skills a excluir de actualizaciones automáticas
EXCLUDE_SKILLS=""                 # Separados por coma

# Nivel de log (info, warning, error)
LOG_LEVEL=info                    # Nivel de detalle

# Guardar logs de actualización
SAVE_LOGS=true                    # Guardar historial

# Ruta de logs
LOG_PATH="./betteragents-update.log"  # Ubicación del log
```

### Personalizar Configuración

```bash
# Editar configuración
nano .betteragents-config

# O con tu editor preferido
code .betteragents-config
```

### Ejemplos de Configuración

#### Configuración Conservadora
```bash
AUTO_UPDATE_SKILLS=false
UPDATE_CHECK_FREQUENCY=30
SILENT_UPDATE=false
NOTIFY_UPDATES=true
```

#### Configuración Agresiva
```bash
AUTO_UPDATE_SKILLS=true
UPDATE_CHECK_FREQUENCY=1
SILENT_UPDATE=true
NOTIFY_UPDATES=true
```

#### Configuración Balanceada (Recomendada)
```bash
AUTO_UPDATE_SKILLS=false
UPDATE_CHECK_FREQUENCY=7
SILENT_UPDATE=false
NOTIFY_UPDATES=true
```

---

## 🔧 Actualización Manual Avanzada

### Actualizar Skill Específico

```bash
# Actualizar solo un skill
npx skills update wshobson/agents/architecture-patterns

# Actualizar múltiples skills específicos
npx skills update wshobson/agents/architecture-patterns obra/superpowers/systematic-debugging
```

### Reinstalar Skill

Si un skill tiene problemas:

```bash
# 1. Desinstalar
npx skills remove wshobson/agents/architecture-patterns

# 2. Reinstalar
npx skills add wshobson/agents/architecture-patterns
```

### Actualizar con Opciones

```bash
# Actualizar sin confirmación
npx skills update -y

# Actualizar con output verbose
npx skills update --verbose

# Actualizar y mostrar changelog
npx skills update --show-changes
```

---

## 🐛 Troubleshooting

### Problema: "No se pueden actualizar los skills"

**Solución:**
```bash
# Limpiar caché de npm
npm cache clean --force

# Intentar actualizar nuevamente
npx skills update
```

---

### Problema: "Error de permisos"

**Solución:**
```bash
# Verificar permisos del directorio
ls -la ~/.npm

# Cambiar propietario si es necesario
sudo chown -R $USER:$USER ~/.npm

# Intentar nuevamente
npx skills update
```

---

### Problema: "Skill no se actualiza"

**Solución:**
```bash
# Verificar versión actual
npx skills list | grep nombre-del-skill

# Forzar reinstalación
npx skills remove nombre-del-skill
npx skills add nombre-del-skill

# Verificar nueva versión
npx skills list | grep nombre-del-skill
```

---

### Problema: "Actualización interrumpida"

**Solución:**
```bash
# Verificar estado
npx skills check

# Completar actualización
npx skills update

# Si persiste, reinstalar skills problemáticos
npx skills list  # Ver cuáles faltan
npx skills add skill-faltante
```

---

### Problema: "Skills desactualizados después de actualizar"

**Solución:**
```bash
# Verificar que la actualización se completó
npx skills check

# Si aún hay actualizaciones pendientes
npx skills update --force

# Verificar versiones
npx skills list --verbose
```

---

## 📊 Monitoreo de Actualizaciones

### Ver Historial de Actualizaciones

```bash
# Ver log de actualizaciones
cat betteragents-update.log

# Ver últimas 20 líneas
tail -20 betteragents-update.log

# Seguir log en tiempo real
tail -f betteragents-update.log
```

### Estadísticas de Skills

```bash
# Contar skills instalados
npx skills list | grep -c "^  "

# Ver skills por categoría
npx skills list | grep "architecture"
npx skills list | grep "testing"

# Ver skills globales vs locales
npx skills list -g  # Globales
npx skills list     # Locales (proyecto)
```

---

## 🎯 Mejores Prácticas

### Frecuencia de Actualización

| Tipo de Proyecto | Frecuencia Recomendada |
|------------------|------------------------|
| Desarrollo activo | Semanal |
| Mantenimiento | Mensual |
| Producción estable | Trimestral |
| Antes de nuevo proyecto | Siempre |

### Antes de Actualizar

1. ✅ Hacer backup de tu trabajo
2. ✅ Verificar que no hay cambios sin guardar
3. ✅ Leer changelog de skills importantes
4. ✅ Tener tiempo para probar después

### Después de Actualizar

1. ✅ Verificar que los agentes funcionan
2. ✅ Probar funcionalidades críticas
3. ✅ Revisar logs por errores
4. ✅ Actualizar documentación si es necesario

### Workflow Recomendado

```bash
# 1. Verificar actualizaciones disponibles
./check-updates.sh

# 2. Si hay actualizaciones, revisar qué cambió
npx skills check

# 3. Hacer backup (opcional)
cp -r .kiro .kiro.backup

# 4. Actualizar
./update-skills.sh

# 5. Probar
kiro .
# Probar algunos agentes

# 6. Si todo funciona, eliminar backup
rm -rf .kiro.backup
```

---

## 📚 Comandos de Referencia Rápida

```bash
# Verificación
npx skills check                    # Ver actualizaciones disponibles
./check-updates.sh                  # Verificación rápida

# Actualización
npx skills update                   # Actualizar todos
./update-skills.sh                  # Script automático
npx skills update skill-name        # Actualizar uno específico

# Información
npx skills list                     # Listar instalados
npx skills list -g                  # Listar globales
npx skills info skill-name          # Info de un skill

# Gestión
npx skills add skill-name           # Instalar nuevo
npx skills remove skill-name        # Desinstalar
npx skills find keyword             # Buscar skills

# Configuración
nano .betteragents-config           # Editar config
cat betteragents-update.log         # Ver logs
```

---

## 🎉 Conclusión

Mantener tus skills actualizados es crucial para:
- Obtener las últimas características
- Mejorar el rendimiento de los agentes
- Corregir bugs y problemas
- Mantener compatibilidad

**Recomendación final:** Ejecuta `./update-skills.sh` semanalmente.

---

**¿Preguntas?** Abre un issue en GitHub o consulta la documentación principal.
