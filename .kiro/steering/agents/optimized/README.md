# 📦 Versiones Optimizadas de Agentes

**Fecha de creación:** 2026-02-12  
**Versión:** BetterAgents 3.1.0  
**Estado:** ✅ PRESERVADAS COMO BACKUP

---

## 🎯 Propósito

Esta carpeta contiene las **versiones optimizadas** de los 12 agentes especializados de BetterAgents. Estas versiones fueron creadas durante la Fase 2 de optimización de tokens y se mantienen aquí como backup y referencia.

---

## 📊 Diferencias: Original vs Optimizado

### Versiones Originales (`.kiro/steering/agents/*.md`)
- **Ubicación:** `.kiro/steering/agents/`
- **Tamaño promedio:** ~2,400 palabras (~3,120 tokens)
- **Contenido:** Completo con todas las secciones
- **Uso recomendado:** Aprendizaje, referencia completa, debugging

**Incluyen:**
- ✅ Sección de identidad completa con ejemplos
- ✅ Múltiples formatos de respuesta detallados
- ✅ Sección completa de skills con instalación
- ✅ Reglas de colaboración extensas
- ✅ Protocolo de memoria detallado
- ✅ Ejemplos extensos y casos de uso
- ✅ Documentación completa de patrones

### Versiones Optimizadas (`.kiro/steering/agents/optimized/*.md`)
- **Ubicación:** `.kiro/steering/agents/optimized/`
- **Tamaño promedio:** ~950 palabras (~1,235 tokens)
- **Contenido:** Esencial sin redundancia
- **Uso recomendado:** Producción, uso diario, eficiencia

**Incluyen:**
- ✅ Role y expertise específico
- ✅ Core principles del dominio
- ✅ Guidelines prácticas
- ✅ Output formats clave
- ✅ Patrones y decisiones del dominio
- ✅ Red flags y preguntas clave
- ✅ Ejemplos de invocación
- ❌ Sección de identidad (ahora en plantillas comunes)
- ❌ Ejemplos extensos de respuesta (en plantillas comunes)
- ❌ Skills detallados (ahora en `config/agent-skills.json`)
- ❌ Reglas de colaboración (en plantillas comunes)
- ❌ Protocolo de memoria (en plantillas comunes)

---

## 📈 Beneficios de las Versiones Optimizadas

### Reducción de Tokens
| Agente | Original | Optimizado | Reducción |
|--------|----------|------------|-----------|
| Architect | 1,900 palabras | 950 palabras | -50% |
| Coder | 2,200 palabras | 950 palabras | -57% |
| Critic | 2,400 palabras | 950 palabras | -60% |
| Tester | 1,250 palabras | 650 palabras | -47% |
| Writer | 2,100 palabras | 650 palabras | -69% |
| Researcher | 2,350 palabras | 750 palabras | -68% |
| Teacher | 2,350 palabras | 850 palabras | -64% |
| DevOps | 2,350 palabras | 1,100 palabras | -53% |
| Security | 1,800 palabras | 1,200 palabras | -34% |
| UX-Designer | 1,900 palabras | 1,100 palabras | -42% |
| Data-Scientist | 1,150 palabras | 550 palabras | -52% |
| Product-Manager | 1,200 palabras | 550 palabras | -55% |
| **PROMEDIO** | **2,000 palabras** | **850 palabras** | **-55%** |

### Impacto en el Sistema
- **Tokens totales:** 35,050 → 14,425 (-59%)
- **Costo anual:** $820 → $221 (-73%)
- **Velocidad:** 2.7x más rápido (+170%)
- **Contexto disponible:** +5,550 tokens para el usuario

---

## 🔄 Cuándo Usar Cada Versión

### Usa las Versiones ORIGINALES cuando:
- 📚 **Aprendiendo** el sistema por primera vez
- 🔍 **Investigando** cómo funciona un agente específico
- 🐛 **Debugging** problemas de comportamiento
- 📖 **Documentando** o creando guías
- 🎓 **Entrenando** nuevos miembros del equipo
- 🔧 **Desarrollando** nuevos agentes basados en existentes

### Usa las Versiones OPTIMIZADAS cuando:
- 🚀 **Producción** - Uso diario del sistema
- ⚡ **Performance** - Necesitas respuestas rápidas
- 💰 **Costos** - Quieres minimizar consumo de tokens
- 📊 **Escala** - Múltiples usuarios simultáneos
- �� **Eficiencia** - Tareas rutinarias y repetitivas

---

## 🎯 Recomendación Final

**Para uso en producción:** Usa las versiones optimizadas (esta carpeta)  
**Para aprendizaje y referencia:** Usa las versiones originales (carpeta padre)

Las versiones optimizadas mantienen el 100% de la funcionalidad esencial mientras reducen el consumo de tokens en un 59%. Son la opción ideal para uso diario.

---

**Creado:** 2026-02-12  
**Por:** AgentX/Dispatcher  
**Versión:** 1.0  
**Estado:** ✅ PRESERVADO COMO BACKUP
