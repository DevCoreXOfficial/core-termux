> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Jcode
- **Tags:** ai, agent, coding
- **Proyecto:** https://jcode.sh
- **Código fuente:** https://github.com/1jehuang/jcode
- **Dependencias:** ninguna (binario Rust independiente)

## ¿Qué es?

El harness de agentes de codificación más eficiente en RAM e inteligente, escrito en Rust. Jcode se enfoca en paralelismo, eficiencia de recursos y personalización de código abierto. Ejecuta docenas de agentes en paralelo con ~10 MB de RAM extra por sesión.

## ¿Cómo usarlo?

### Instalar vía Core

```bash
core install jcode        # instalar
core update jcode         # actualizar
core uninstall jcode      # eliminar
```

### Inicio rápido

```shell
# Iniciar la TUI
jcode

# Ejecutar un prompt sin interacción
jcode run "hola mundo"

# Reanudar una sesión anterior
jcode --resume fox

# Ejecutar como servidor persistente en segundo plano
jcode serve
jcode connect
```

### Primera ejecución

1. Ejecuta `jcode` en una terminal
2. Conecta un proveedor con `jcode login` (soporta Claude, OpenAI, Gemini, Copilot, Ollama y muchos más)
3. Empieza a programar

## Binario y referencia CLI

**Binario:** `jcode`

### Comandos comunes

```bash
jcode                          # iniciar TUI
jcode run "prompt"             # prompt sin interacción
jcode --resume <name>          # reanudar sesión por nombre
jcode serve                    # iniciar servidor en segundo plano
jcode connect                  # adjuntar cliente al servidor
jcode login                    # configurar autenticación del proveedor
jcode login --provider claude  # login con Claude
jcode login --provider openai  # login con OpenAI
jcode auth-test --all          # verificar todos los proveedores configurados
jcode browser setup            # configurar automatización del navegador
```

### Características principales

- **Swarm**: Genera múltiples agentes en paralelo con resolución automática de conflictos
- **Memory**: Recall automático de memoria basado en vectores semánticos
- **Browser**: Firefox Agent Bridge integrado para automatización web
- **Skills**: Paquetes de instrucciones Markdown cargados bajo demanda
- **Self-dev mode**: El agente puede modificar su propio código fuente

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux, requiere `glibc` y `patchelf` (se instalan automáticamente).
- La configuración vive en `~/.jcode/config.toml`.
- Documentación completa en inglés: `core show jcode`.
