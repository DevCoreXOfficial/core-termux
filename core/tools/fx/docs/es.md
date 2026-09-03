> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** fx
- **Tags:** ai, agent, coding
- **Proyecto:** https://fx.sh
- **Código fuente:** https://github.com/vercel-labs/fx
- **Dependencias:** ninguna (binario Zig independiente)

## ¿Qué es?

Harness de agentes de codificación pequeño, abierto y nativo escrito en Zig. Optimizado para investigación y compatibilidad con un binario de ~6 MB, inicio frío de 10µs y footprint mínimo de memoria. Compatible con modelos locales y en la nube.

## ¿Cómo usarlo?

### Instalar vía Core

```bash
core install fx          # instalar
core update fx           # actualizar
core uninstall fx        # eliminar
```

### Inicio rápido

```shell
# Iniciar sesión interactiva
fx

# Ejecutar un prompt
fx run "resume este código"
```

## Binario y referencia CLI

**Binario:** `fx`

### Características principales

- **Binario tiny**: ~6 MB, diseñado para instalación instantánea
- **Inicio frío instantáneo**: 10µs hasta el prompt
- **Memoria mínima**: Single-digit megabytes como base
- **UI tipo shell**: Salida mínima, historial de scroll preservado
- **Contexto eficiente**: System prompt y tools mínimos para TTFT óptimo
- **Empotrable**: Núcleo pequeño, extendido vía skills, plugins, MCPs
- **Agnóstico de modelos**: Funciona con modelos locales, gateways o APIs de proveedores
- **Soporte Wasm**: Puede compilarse a WebAssembly

## Notas

- Plataformas soportadas: **termux, ubuntu, wsl** (macOS y Linux en x86_64 y arm64).
- Licencia Apache-2.0.
- Documentación completa en inglés: `core show fx`.
