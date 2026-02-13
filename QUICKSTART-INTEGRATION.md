# 🚀 Inicio Rápido - Integración de BetterAgentX

**Integra BetterAgentX en tu proyecto en 3 pasos**

---

## ⚡ Opción A: Proyecto Nuevo

```bash
# 1. Crea tu proyecto
mkdir mi-proyecto
cd mi-proyecto

# 2. Clona BetterAgentX
git clone https://github.com/jemavidev/BetterAgentX.git

# 3. Inicializa
./BetterAgentX/scripts/init-betteragentx.sh

# 4. ¡Listo!
kiro .
```

---

## ⚡ Opción B: Proyecto Existente

```bash
# 1. Ve a tu proyecto
cd tu-proyecto-existente

# 2. Clona BetterAgentX
git clone https://github.com/jemavidev/BetterAgentX.git

# 3. Inicializa
./BetterAgentX/scripts/init-betteragentx.sh

# 4. ¡Listo!
kiro .
```

---

## ⚡ Opción C: BetterAgentX como Subproyecto

```bash
# 1. Añade como submódulo de Git
git submodule add https://github.com/jemavidev/BetterAgentX.git

# 2. Inicializa
./BetterAgentX/scripts/init-betteragentx.sh

# 3. ¡Listo!
kiro .
```

---

## 🎯 Primer Uso

Una vez inicializado:

```bash
# Abre Kiro Code
kiro .

# En el chat de Kiro, prueba:
@agentx Hola! ¿Puedes ayudarme con este proyecto?
```

---

## 📋 Estructura Creada

```
tu-proyecto/
├── BetterAgentX/              # Subproyecto (fuente)
│   ├── .kiro/steering/
│   │   ├── agents/            # 12 agentes
│   │   ├── agentx/            # Orquestador
│   │   └── _common/           # Config común
│   └── .agents/skills/        # Skills
│
├── .kiro/                     # Config Kiro (tu proyecto)
│   ├── steering/
│   │   ├── agents/    → symlink a BetterAgentX
│   │   ├── agentx/    → symlink a BetterAgentX
│   │   └── _common/   → symlink a BetterAgentX
│   ├── memory/                # Memoria (local)
│   │   ├── active-context.md
│   │   ├── decision-log.md
│   │   ├── progress.md
│   │   └── patterns.md
│   └── settings/              # Config (local)
│       ├── betteragents.json
│       └── agent-skills.json
│
└── .agents/
    └── skills/        → symlink a BetterAgentX
```

---

## ✅ Verificar Instalación

```bash
# Ejecuta el script de verificación
./BetterAgentX/scripts/verify-betteragentx.sh
```

Deberías ver:
```
✅ Todo está correcto
🚀 BetterAgentX está listo para usar
```

---

## 🎨 Personalizar

### Editar Contexto del Proyecto

```bash
nano .kiro/memory/active-context.md
```

Describe:
- Objetivo del proyecto
- Stack tecnológico
- Estado actual
- Equipo

### Configurar Agentes

```bash
nano .kiro/settings/betteragents.json
```

---

## 🔄 Actualizar BetterAgentX

```bash
cd BetterAgentX
git pull
cd ..
```

Los cambios se reflejan automáticamente (gracias a los symlinks).

---

## 🆘 Problemas Comunes

### "BetterAgentX no encontrado"

```bash
# Asegúrate de clonar primero
git clone https://github.com/jemavidev/BetterAgentX.git
```

### "Enlaces simbólicos rotos"

```bash
# Reinicializa
./BetterAgentX/scripts/init-betteragentx.sh
```

### "Agentes no responden"

```bash
# Verifica la instalación
./BetterAgentX/scripts/verify-betteragentx.sh
```

---

## 📚 Más Información

- **Guía Completa:** [INTEGRATION.md](INTEGRATION.md)
- **Documentación:** [README.md](README.md)
- **Agentes:** [docs/agents/README.md](docs/agents/README.md)

---

## 🎯 Comandos Útiles

```bash
# Verificar instalación
./BetterAgentX/scripts/verify-betteragentx.sh

# Actualizar BetterAgentX
cd BetterAgentX && git pull && cd ..

# Ver memoria del proyecto
cat .kiro/memory/active-context.md

# Editar progreso
nano .kiro/memory/progress.md

# Abrir Kiro
kiro .
```

---

**¡Listo! Ya puedes usar los 13 agentes especializados en tu proyecto.** 🎉
