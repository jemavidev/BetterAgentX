# 💾 Activación Automática de Memoria

**Guía sobre cómo funciona la activación automática del sistema de memoria en BetterAgentX**

---

## 🎯 Resumen

A partir de la versión 3.2.0, BetterAgentX activa automáticamente el sistema de memoria cuando inicializas un proyecto. Esto significa que los archivos de memoria se cargan automáticamente al abrir Kiro, sin necesidad de configuración manual.

---

## ✨ Qué se Activa Automáticamente

Cuando ejecutas `./BetterAgentX/scripts/init-betteragentx.sh`, el script:

1. ✅ Crea los archivos de memoria:
   - `.kiro/memory/active-context.md`
   - `.kiro/memory/decision-log.md`
   - `.kiro/memory/progress.md`
   - `.kiro/memory/patterns.md`

2. ✅ Crea archivo `.kirorc` con configuración:
   ```ini
   # Activar memoria automáticamente
   memory.enabled=true
   memory.autoLoad=true
   
   # Archivos de memoria a cargar
   memory.files=.kiro/memory/active-context.md,.kiro/memory/decision-log.md,.kiro/memory/progress.md,.kiro/memory/patterns.md
   
   # Activar agentes
   agents.enabled=true
   agents.autoLoad=true
   ```

3. ✅ Crea archivo `.kiro/settings/kiro.json` con configuración JSON:
   ```json
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
   ```

---

## 🔧 Cómo Funciona

### Al Inicializar el Proyecto

```bash
./BetterAgentX/scripts/init-betteragentx.sh
```

El script:
1. Crea la estructura del proyecto
2. Inicializa archivos de memoria con contenido base
3. **Crea .kirorc con memoria activada**
4. **Crea .kiro/settings/kiro.json con configuración**
5. Actualiza .gitignore (NO ignora .kirorc)

### Al Abrir Kiro

```bash
kiro .
```

Kiro automáticamente:
1. Lee el archivo `.kirorc`
2. Detecta `memory.enabled=true`
3. Carga los archivos especificados en `memory.files`
4. Los agentes tienen acceso inmediato a la memoria del proyecto

---

## 📁 Archivos Creados

### .kirorc (Raíz del Proyecto)

**Ubicación:** `./kirorc`  
**Propósito:** Configuración de Kiro para el proyecto  
**Se sube a Git:** ✅ SÍ (importante para que otros usuarios tengan memoria activada)

```ini
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
```

### .kiro/settings/kiro.json

**Ubicación:** `./.kiro/settings/kiro.json`  
**Propósito:** Configuración JSON de Kiro  
**Se sube a Git:** ❌ NO (ignorado en .gitignore)

```json
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
```

---

## 🎯 Beneficios

### 1. Experiencia de Usuario Mejorada
- ✅ No necesitas activar memoria manualmente
- ✅ Funciona inmediatamente después de inicializar
- ✅ Otros usuarios del proyecto también tienen memoria activada

### 2. Consistencia
- ✅ Todos los proyectos tienen la misma configuración
- ✅ No hay confusión sobre cómo activar memoria
- ✅ Documentación más simple

### 3. Productividad
- ✅ Ahorra tiempo en configuración
- ✅ Los agentes tienen contexto desde el inicio
- ✅ Menos pasos para empezar a trabajar

---

## 🔄 Actualizar Proyectos Existentes

Si ya tienes un proyecto con BetterAgentX pero sin activación automática:

### Opción 1: Reinicializar (Recomendado)

```bash
# Respalda tu memoria actual si tiene contenido importante
cp -r .kiro/memory .kiro/memory.backup

# Reinicializa
./BetterAgentX/scripts/init-betteragentx.sh

# Restaura contenido personalizado si es necesario
# (el script no sobrescribe archivos existentes)
```

### Opción 2: Crear .kirorc Manualmente

```bash
# Crea el archivo .kirorc
cat > .kirorc << 'EOF'
# BetterAgentX - Configuración de Kiro
memory.enabled=true
memory.autoLoad=true
memory.files=.kiro/memory/active-context.md,.kiro/memory/decision-log.md,.kiro/memory/progress.md,.kiro/memory/patterns.md
agents.enabled=true
agents.autoLoad=true
EOF

# Asegúrate de que NO esté en .gitignore
# (debe estar en el repositorio)
```

---

## ⚙️ Personalización

### Cambiar Archivos de Memoria Cargados

Edita `.kirorc`:

```ini
# Cargar solo algunos archivos
memory.files=.kiro/memory/active-context.md,.kiro/memory/progress.md

# O añadir archivos personalizados
memory.files=.kiro/memory/active-context.md,.kiro/memory/custom-notes.md
```

### Desactivar Memoria Temporalmente

Edita `.kirorc`:

```ini
# Desactivar memoria
memory.enabled=false
```

O usa flag al abrir Kiro:

```bash
kiro . --no-memory
```

### Activar Solo para Ciertos Agentes

Edita `.kiro/settings/kiro.json`:

```json
{
  "memory": {
    "enabled": true,
    "autoLoad": true,
    "files": [".kiro/memory/active-context.md"],
    "agents": ["agentx", "architect", "coder"]
  }
}
```

---

## 🐛 Solución de Problemas

### Problema: Memoria no se carga automáticamente

**Diagnóstico:**
```bash
# Verificar que existe .kirorc
ls -la .kirorc

# Verificar contenido
cat .kirorc

# Verificar archivos de memoria
ls -la .kiro/memory/
```

**Solución:**
```bash
# Reinicializar
./BetterAgentX/scripts/init-betteragentx.sh
```

### Problema: .kirorc no existe

**Causa:** Proyecto inicializado con versión anterior de BetterAgentX

**Solución:**
```bash
# Actualizar BetterAgentX
cd BetterAgentX
git pull
cd ..

# Reinicializar
./BetterAgentX/scripts/init-betteragentx.sh
```

### Problema: Memoria se carga pero está vacía

**Causa:** Archivos de memoria no tienen contenido

**Solución:**
```bash
# Editar contexto del proyecto
nano .kiro/memory/active-context.md

# Añadir información sobre tu proyecto
```

---

## 📚 Archivos de Memoria

### active-context.md
**Propósito:** Contexto actual del proyecto

**Contenido sugerido:**
- Objetivo del proyecto
- Stack tecnológico
- Estado actual
- Equipo

### decision-log.md
**Propósito:** Registro de decisiones técnicas (ADR)

**Contenido sugerido:**
- Decisiones arquitectónicas
- Elección de tecnologías
- Trade-offs considerados

### progress.md
**Propósito:** Seguimiento de progreso

**Contenido sugerido:**
- Tareas pendientes
- Tareas completadas
- Métricas de progreso

### patterns.md
**Propósito:** Patrones y soluciones reutilizables

**Contenido sugerido:**
- Soluciones a problemas comunes
- Patrones de diseño usados
- Mejores prácticas del proyecto

---

## 🎯 Mejores Prácticas

### 1. Mantén la Memoria Actualizada

```bash
# Edita regularmente
nano .kiro/memory/active-context.md
nano .kiro/memory/progress.md
```

### 2. Documenta Decisiones Importantes

Cuando tomes una decisión técnica importante:
```bash
nano .kiro/memory/decision-log.md
```

### 3. Comparte Patrones Útiles

Cuando encuentres una solución elegante:
```bash
nano .kiro/memory/patterns.md
```

### 4. Revisa la Memoria Periódicamente

```bash
# Ver contexto actual
cat .kiro/memory/active-context.md

# Ver progreso
cat .kiro/memory/progress.md
```

---

## 🔗 Enlaces Relacionados

- [Sistema de Memoria](../memory/README.md)
- [Guía de Integración](../../INTEGRATION.md)
- [Inicio Rápido](../../QUICKSTART-INTEGRATION.md)

---

## 📝 Notas Técnicas

### Precedencia de Configuración

1. `.kirorc` (raíz del proyecto) - **Prioridad alta**
2. `.kiro/settings/kiro.json` - Prioridad media
3. `~/.kiro/config.json` (global) - Prioridad baja

### Formato de Archivos

- **`.kirorc`**: Formato INI (key=value)
- **`.kiro/settings/kiro.json`**: Formato JSON

### Git y .kirorc

- ✅ `.kirorc` SÍ se sube a Git
- ❌ `.kiro/memory/` NO se sube a Git
- ❌ `.kiro/settings/kiro.json` NO se sube a Git

**Razón:** `.kirorc` contiene configuración del proyecto que debe ser compartida con el equipo.

---

## ✅ Checklist de Verificación

Después de inicializar, verifica:

- [ ] Existe archivo `.kirorc` en la raíz
- [ ] `.kirorc` contiene `memory.enabled=true`
- [ ] Existen 4 archivos en `.kiro/memory/`
- [ ] `.kirorc` NO está en `.gitignore`
- [ ] Al abrir Kiro, la memoria se carga automáticamente

---

**Versión:** 3.2.0+  
**Fecha:** 2026-02-13  
**Estado:** ✅ ACTIVO

---

**¡La memoria ahora se activa automáticamente! 🎉**
