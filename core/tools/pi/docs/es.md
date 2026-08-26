> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Pi Coding Agent
- **Tags:** ai, agent, coding
- **Código fuente:** https://github.com/badlogic/pi-mono
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Harness minimalista de programación agéntica adaptable a tu flujo.

## Binario y referencia CLI

**Binario:** `pi`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
VERSION="<release-version>"
tar -xzf "pi-${VERSION}-source.tar.gz"
cd "pi-${VERSION}"
./scripts/build-binaries.sh --offline-model-data --platform linux-x64 --out "$PWD/out"
VERSION="<release-version>"
tar -xzf "pi-${VERSION}-source.tar.gz"
cd "pi-${VERSION}"
./scripts/build-binaries.sh --offline-model-data --platform linux-x64 --out "$PWD/out"
```

## ¿Cómo usarlo?

```bash
core install pi        # instalar
core update pi         # actualizar
core uninstall pi      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
VERSION="<release-version>"
tar -xzf "pi-${VERSION}-source.tar.gz"
cd "pi-${VERSION}"
./scripts/build-binaries.sh --offline-model-data --platform linux-x64 --out "$PWD/out"
```

Full documentation: https://github.com/badlogic/pi-mono

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show pi`.
