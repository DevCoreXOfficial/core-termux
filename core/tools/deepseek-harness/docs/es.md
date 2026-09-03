> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** DeepSeek Harness
- **Tags:** ai, agent, coding, deepseek
- **Proyecto:** https://deepseek.com/harness
- **Código fuente:** https://github.com/deepseek-ai/deepseek-harness
- **Dependencias:** nodejs, clang, make, cmake

## ¿Qué es?

Harness de agentes de código abierto por DeepSeek AI con arquitectura de plugins. Construido sobre Cordis, proporciona un agente de codificación completo con edición de archivos, acceso a terminal, búsqueda web, habilidades, planificación, objetivos, sub-agentes y flujos de trabajo.

## ¿Cómo usarlo?

### Instalar vía Core

```bash
core install deepseek-harness    # instalar
core update deepseek-harness     # actualizar
core uninstall deepseek-harness  # eliminar
```

### Inicio rápido

```shell
# Iniciar la Web UI (abre navegador en http://127.0.0.1:3080)
dsh web

# Ejecutar una tarea sin interfaz
dsh --profile headless "resume este repositorio"

# Iniciar servidor SDK
dsh --profile sdk
```

### Primera ejecución

1. Ejecuta `dsh web` para iniciar la Web UI
2. Abre Settings → Models e ingresa una API key de DeepSeek
3. Selecciona un directorio de trabajo
4. Inicia una sesión y escribe tu primera instrucción

## Binario y referencia CLI

**Binario:** `dsh`

### Modos de entrada

| Comando | Propósito |
|---------|-----------|
| `dsh web` | Iniciar la Web UI (alias de `--profile web`) |
| `dsh --profile headless "job"` | Ejecutar una tarea, imprimir resultado, salir |
| `dsh --profile sdk` | Servir clientes SDK vía JSON-RPC |
| `dsh --profile sdk-minimal` | SDK mínimo |
| `dsh --profile acp` | Servir clientes de automatización vía ACP |
| `dsh plugin --profile <name> <pnpm args>` | Gestionar plugins del perfil |

### Banderas comunes

```bash
dsh --profile web --port 8080     # puerto personalizado
dsh --profile web --no-open       # no abrir navegador
dsh --dump-default-config         # inspeccionar config por defecto
dsh --dump-config                 # inspeccionar config compuesta
```

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- Requiere Node.js LTS (se instala automáticamente si falta).
- Vista previa de desarrollador: pueden haber cambios que rompan compatibilidad.
- Documentación completa en inglés: `core show deepseek-harness`.
